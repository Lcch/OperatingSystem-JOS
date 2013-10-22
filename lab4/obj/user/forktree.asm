
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 04             	sub    $0x4,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 82 0b 00 00       	call   800bc5 <sys_getenvid>
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	53                   	push   %ebx
  800047:	50                   	push   %eax
  800048:	68 20 13 80 00       	push   $0x801320
  80004d:	e8 86 01 00 00       	call   8001d8 <cprintf>

	forkchild(cur, '0');
  800052:	83 c4 08             	add    $0x8,%esp
  800055:	6a 30                	push   $0x30
  800057:	53                   	push   %ebx
  800058:	e8 13 00 00 00       	call   800070 <forkchild>
	forkchild(cur, '1');
  80005d:	83 c4 08             	add    $0x8,%esp
  800060:	6a 31                	push   $0x31
  800062:	53                   	push   %ebx
  800063:	e8 08 00 00 00       	call   800070 <forkchild>
  800068:	83 c4 10             	add    $0x10,%esp
}
  80006b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	53                   	push   %ebx
  800074:	83 ec 30             	sub    $0x30,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8a 45 0c             	mov    0xc(%ebp),%al
  80007d:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800080:	53                   	push   %ebx
  800081:	e8 b6 06 00 00       	call   80073c <strlen>
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 f8 02             	cmp    $0x2,%eax
  80008c:	7f 39                	jg     8000c7 <forkchild+0x57>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	53                   	push   %ebx
  800097:	68 31 13 80 00       	push   $0x801331
  80009c:	6a 04                	push   $0x4
  80009e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a1:	50                   	push   %eax
  8000a2:	e8 79 06 00 00       	call   800720 <snprintf>
	if (fork() == 0) {
  8000a7:	83 c4 20             	add    $0x20,%esp
  8000aa:	e8 2f 0d 00 00       	call   800dde <fork>
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 14                	jne    8000c7 <forkchild+0x57>
		forktree(nxt);
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	e8 75 ff ff ff       	call   800034 <forktree>
		exit();
  8000bf:	e8 70 00 00 00       	call   800134 <exit>
  8000c4:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 30 13 80 00       	push   $0x801330
  8000d7:	e8 58 ff ff ff       	call   800034 <forktree>
  8000dc:	83 c4 10             	add    $0x10,%esp
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ef:	e8 d1 0a 00 00       	call   800bc5 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	29 d0                	sub    %edx,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 f6                	test   %esi,%esi
  800111:	7e 07                	jle    80011a <libmain+0x36>
		binaryname = argv[0];
  800113:	8b 03                	mov    (%ebx),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	53                   	push   %ebx
  80011e:	56                   	push   %esi
  80011f:	e8 a8 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
  800129:	83 c4 10             	add    $0x10,%esp
}
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	c9                   	leave  
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013a:	6a 00                	push   $0x0
  80013c:	e8 62 0a 00 00       	call   800ba3 <sys_env_destroy>
  800141:	83 c4 10             	add    $0x10,%esp
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    
	...

00800148 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	53                   	push   %ebx
  80014c:	83 ec 04             	sub    $0x4,%esp
  80014f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800152:	8b 03                	mov    (%ebx),%eax
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015b:	40                   	inc    %eax
  80015c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800163:	75 1a                	jne    80017f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	68 ff 00 00 00       	push   $0xff
  80016d:	8d 43 08             	lea    0x8(%ebx),%eax
  800170:	50                   	push   %eax
  800171:	e8 e3 09 00 00       	call   800b59 <sys_cputs>
		b->idx = 0;
  800176:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017f:	ff 43 04             	incl   0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 48 01 80 00       	push   $0x800148
  8001b6:	e8 82 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 89 09 00 00       	call   800b59 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 2c             	sub    $0x2c,%esp
  8001f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f8:	89 d6                	mov    %edx,%esi
  8001fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800200:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800203:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800206:	8b 45 10             	mov    0x10(%ebp),%eax
  800209:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800212:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800219:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80021c:	72 0c                	jb     80022a <printnum+0x3e>
  80021e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800221:	76 07                	jbe    80022a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800223:	4b                   	dec    %ebx
  800224:	85 db                	test   %ebx,%ebx
  800226:	7f 31                	jg     800259 <printnum+0x6d>
  800228:	eb 3f                	jmp    800269 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	57                   	push   %edi
  80022e:	4b                   	dec    %ebx
  80022f:	53                   	push   %ebx
  800230:	50                   	push   %eax
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	ff 75 d4             	pushl  -0x2c(%ebp)
  800237:	ff 75 d0             	pushl  -0x30(%ebp)
  80023a:	ff 75 dc             	pushl  -0x24(%ebp)
  80023d:	ff 75 d8             	pushl  -0x28(%ebp)
  800240:	e8 7b 0e 00 00       	call   8010c0 <__udivdi3>
  800245:	83 c4 18             	add    $0x18,%esp
  800248:	52                   	push   %edx
  800249:	50                   	push   %eax
  80024a:	89 f2                	mov    %esi,%edx
  80024c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024f:	e8 98 ff ff ff       	call   8001ec <printnum>
  800254:	83 c4 20             	add    $0x20,%esp
  800257:	eb 10                	jmp    800269 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	56                   	push   %esi
  80025d:	57                   	push   %edi
  80025e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800261:	4b                   	dec    %ebx
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	85 db                	test   %ebx,%ebx
  800267:	7f f0                	jg     800259 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	83 ec 04             	sub    $0x4,%esp
  800270:	ff 75 d4             	pushl  -0x2c(%ebp)
  800273:	ff 75 d0             	pushl  -0x30(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 5b 0f 00 00       	call   8011dc <__umoddi3>
  800281:	83 c4 14             	add    $0x14,%esp
  800284:	0f be 80 40 13 80 00 	movsbl 0x801340(%eax),%eax
  80028b:	50                   	push   %eax
  80028c:	ff 55 e4             	call   *-0x1c(%ebp)
  80028f:	83 c4 10             	add    $0x10,%esp
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029d:	83 fa 01             	cmp    $0x1,%edx
  8002a0:	7e 0e                	jle    8002b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	8b 52 04             	mov    0x4(%edx),%edx
  8002ae:	eb 22                	jmp    8002d2 <getuint+0x38>
	else if (lflag)
  8002b0:	85 d2                	test   %edx,%edx
  8002b2:	74 10                	je     8002c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c2:	eb 0e                	jmp    8002d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 fa 01             	cmp    $0x1,%edx
  8002da:	7e 0e                	jle    8002ea <getint+0x16>
		return va_arg(*ap, long long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	8b 52 04             	mov    0x4(%edx),%edx
  8002e8:	eb 1a                	jmp    800304 <getint+0x30>
	else if (lflag)
  8002ea:	85 d2                	test   %edx,%edx
  8002ec:	74 0c                	je     8002fa <getint+0x26>
		return va_arg(*ap, long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	99                   	cltd   
  8002f8:	eb 0a                	jmp    800304 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	99                   	cltd   
}
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 08                	jae    80031e <sprintputch+0x18>
		*b->buf++ = ch;
  800316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800319:	88 0a                	mov    %cl,(%edx)
  80031b:	42                   	inc    %edx
  80031c:	89 10                	mov    %edx,(%eax)
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800326:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800329:	50                   	push   %eax
  80032a:	ff 75 10             	pushl  0x10(%ebp)
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	e8 05 00 00 00       	call   80033d <vprintfmt>
	va_end(ap);
  800338:	83 c4 10             	add    $0x10,%esp
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 2c             	sub    $0x2c,%esp
  800346:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800349:	8b 75 10             	mov    0x10(%ebp),%esi
  80034c:	eb 13                	jmp    800361 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 6d 03 00 00    	je     8006c3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	57                   	push   %edi
  80035a:	50                   	push   %eax
  80035b:	ff 55 08             	call   *0x8(%ebp)
  80035e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800361:	0f b6 06             	movzbl (%esi),%eax
  800364:	46                   	inc    %esi
  800365:	83 f8 25             	cmp    $0x25,%eax
  800368:	75 e4                	jne    80034e <vprintfmt+0x11>
  80036a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80036e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800375:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80037c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800383:	b9 00 00 00 00       	mov    $0x0,%ecx
  800388:	eb 28                	jmp    8003b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800390:	eb 20                	jmp    8003b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800394:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800398:	eb 18                	jmp    8003b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80039c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a3:	eb 0d                	jmp    8003b2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8a 06                	mov    (%esi),%al
  8003b4:	0f b6 d0             	movzbl %al,%edx
  8003b7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ba:	83 e8 23             	sub    $0x23,%eax
  8003bd:	3c 55                	cmp    $0x55,%al
  8003bf:	0f 87 e0 02 00 00    	ja     8006a5 <vprintfmt+0x368>
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cf:	83 ea 30             	sub    $0x30,%edx
  8003d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003d5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003d8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003db:	83 fa 09             	cmp    $0x9,%edx
  8003de:	77 44                	ja     800424 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	89 de                	mov    %ebx,%esi
  8003e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003e6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003e9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003ed:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003f3:	83 fb 09             	cmp    $0x9,%ebx
  8003f6:	76 ed                	jbe    8003e5 <vprintfmt+0xa8>
  8003f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003fb:	eb 29                	jmp    800426 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	8b 00                	mov    (%eax),%eax
  800408:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040d:	eb 17                	jmp    800426 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80040f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800413:	78 85                	js     80039a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	89 de                	mov    %ebx,%esi
  800417:	eb 99                	jmp    8003b2 <vprintfmt+0x75>
  800419:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800422:	eb 8e                	jmp    8003b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800426:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042a:	79 86                	jns    8003b2 <vprintfmt+0x75>
  80042c:	e9 74 ff ff ff       	jmp    8003a5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800431:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	89 de                	mov    %ebx,%esi
  800434:	e9 79 ff ff ff       	jmp    8003b2 <vprintfmt+0x75>
  800439:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 50 04             	lea    0x4(%eax),%edx
  800442:	89 55 14             	mov    %edx,0x14(%ebp)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	57                   	push   %edi
  800449:	ff 30                	pushl  (%eax)
  80044b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 08 ff ff ff       	jmp    800361 <vprintfmt+0x24>
  800459:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	79 02                	jns    80046d <vprintfmt+0x130>
  80046b:	f7 d8                	neg    %eax
  80046d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046f:	83 f8 08             	cmp    $0x8,%eax
  800472:	7f 0b                	jg     80047f <vprintfmt+0x142>
  800474:	8b 04 85 60 15 80 00 	mov    0x801560(,%eax,4),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	75 1a                	jne    800499 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80047f:	52                   	push   %edx
  800480:	68 58 13 80 00       	push   $0x801358
  800485:	57                   	push   %edi
  800486:	ff 75 08             	pushl  0x8(%ebp)
  800489:	e8 92 fe ff ff       	call   800320 <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800494:	e9 c8 fe ff ff       	jmp    800361 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800499:	50                   	push   %eax
  80049a:	68 61 13 80 00       	push   $0x801361
  80049f:	57                   	push   %edi
  8004a0:	ff 75 08             	pushl  0x8(%ebp)
  8004a3:	e8 78 fe ff ff       	call   800320 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ae:	e9 ae fe ff ff       	jmp    800361 <vprintfmt+0x24>
  8004b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004b6:	89 de                	mov    %ebx,%esi
  8004b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 07                	jne    8004d7 <vprintfmt+0x19a>
				p = "(null)";
  8004d0:	c7 45 d0 51 13 80 00 	movl   $0x801351,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004d7:	85 db                	test   %ebx,%ebx
  8004d9:	7e 42                	jle    80051d <vprintfmt+0x1e0>
  8004db:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004df:	74 3c                	je     80051d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	51                   	push   %ecx
  8004e5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e8:	e8 6f 02 00 00       	call   80075c <strnlen>
  8004ed:	29 c3                	sub    %eax,%ebx
  8004ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 db                	test   %ebx,%ebx
  8004f7:	7e 24                	jle    80051d <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004f9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004fd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800500:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	57                   	push   %edi
  800507:	53                   	push   %ebx
  800508:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	4e                   	dec    %esi
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	85 f6                	test   %esi,%esi
  800511:	7f f0                	jg     800503 <vprintfmt+0x1c6>
  800513:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800516:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800520:	0f be 02             	movsbl (%edx),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	75 47                	jne    80056e <vprintfmt+0x231>
  800527:	eb 37                	jmp    800560 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052d:	74 16                	je     800545 <vprintfmt+0x208>
  80052f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800532:	83 fa 5e             	cmp    $0x5e,%edx
  800535:	76 0e                	jbe    800545 <vprintfmt+0x208>
					putch('?', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	57                   	push   %edi
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 0b                	jmp    800550 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	57                   	push   %edi
  800549:	50                   	push   %eax
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	ff 4d e4             	decl   -0x1c(%ebp)
  800553:	0f be 03             	movsbl (%ebx),%eax
  800556:	85 c0                	test   %eax,%eax
  800558:	74 03                	je     80055d <vprintfmt+0x220>
  80055a:	43                   	inc    %ebx
  80055b:	eb 1b                	jmp    800578 <vprintfmt+0x23b>
  80055d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800560:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800564:	7f 1e                	jg     800584 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800569:	e9 f3 fd ff ff       	jmp    800361 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800571:	43                   	inc    %ebx
  800572:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800575:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 ad                	js     800529 <vprintfmt+0x1ec>
  80057c:	4e                   	dec    %esi
  80057d:	79 aa                	jns    800529 <vprintfmt+0x1ec>
  80057f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800582:	eb dc                	jmp    800560 <vprintfmt+0x223>
  800584:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 20                	push   $0x20
  80058d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	4b                   	dec    %ebx
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ef                	jg     800587 <vprintfmt+0x24a>
  800598:	e9 c4 fd ff ff       	jmp    800361 <vprintfmt+0x24>
  80059d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a0:	89 ca                	mov    %ecx,%edx
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a5:	e8 2a fd ff ff       	call   8002d4 <getint>
  8005aa:	89 c3                	mov    %eax,%ebx
  8005ac:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	78 0a                	js     8005bc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 b0 00 00 00       	jmp    80066c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	57                   	push   %edi
  8005c0:	6a 2d                	push   $0x2d
  8005c2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c5:	f7 db                	neg    %ebx
  8005c7:	83 d6 00             	adc    $0x0,%esi
  8005ca:	f7 de                	neg    %esi
  8005cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d4:	e9 93 00 00 00       	jmp    80066c <vprintfmt+0x32f>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 b4 fc ff ff       	call   80029a <getuint>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	89 d6                	mov    %edx,%esi
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ef:	eb 7b                	jmp    80066c <vprintfmt+0x32f>
  8005f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005f4:	89 ca                	mov    %ecx,%edx
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 d6 fc ff ff       	call   8002d4 <getint>
  8005fe:	89 c3                	mov    %eax,%ebx
  800600:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800602:	85 d2                	test   %edx,%edx
  800604:	78 07                	js     80060d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800606:	b8 08 00 00 00       	mov    $0x8,%eax
  80060b:	eb 5f                	jmp    80066c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	6a 2d                	push   $0x2d
  800613:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800616:	f7 db                	neg    %ebx
  800618:	83 d6 00             	adc    $0x0,%esi
  80061b:	f7 de                	neg    %esi
  80061d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800620:	b8 08 00 00 00       	mov    $0x8,%eax
  800625:	eb 45                	jmp    80066c <vprintfmt+0x32f>
  800627:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	57                   	push   %edi
  80062e:	6a 30                	push   $0x30
  800630:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	57                   	push   %edi
  800637:	6a 78                	push   $0x78
  800639:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800645:	8b 18                	mov    (%eax),%ebx
  800647:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800654:	eb 16                	jmp    80066c <vprintfmt+0x32f>
  800656:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 37 fc ff ff       	call   80029a <getuint>
  800663:	89 c3                	mov    %eax,%ebx
  800665:	89 d6                	mov    %edx,%esi
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066c:	83 ec 0c             	sub    $0xc,%esp
  80066f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800673:	52                   	push   %edx
  800674:	ff 75 e4             	pushl  -0x1c(%ebp)
  800677:	50                   	push   %eax
  800678:	56                   	push   %esi
  800679:	53                   	push   %ebx
  80067a:	89 fa                	mov    %edi,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 68 fb ff ff       	call   8001ec <printnum>
			break;
  800684:	83 c4 20             	add    $0x20,%esp
  800687:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80068a:	e9 d2 fc ff ff       	jmp    800361 <vprintfmt+0x24>
  80068f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	57                   	push   %edi
  800696:	52                   	push   %edx
  800697:	ff 55 08             	call   *0x8(%ebp)
			break;
  80069a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a0:	e9 bc fc ff ff       	jmp    800361 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	57                   	push   %edi
  8006a9:	6a 25                	push   $0x25
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb 02                	jmp    8006b5 <vprintfmt+0x378>
  8006b3:	89 c6                	mov    %eax,%esi
  8006b5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006b8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006bc:	75 f5                	jne    8006b3 <vprintfmt+0x376>
  8006be:	e9 9e fc ff ff       	jmp    800361 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    

008006cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 18             	sub    $0x18,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 26                	je     800712 <vsnprintf+0x47>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 29                	jle    800719 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 06 03 80 00       	push   $0x800306
  8006ff:	e8 39 fc ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 0c                	jmp    80071e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb 05                	jmp    80071e <vsnprintf+0x53>
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 93 ff ff ff       	call   8006cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    
	...

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	80 3a 00             	cmpb   $0x0,(%edx)
  800745:	74 0e                	je     800755 <strlen+0x19>
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80074c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f9                	jne    80074c <strlen+0x10>
  800753:	eb 05                	jmp    80075a <strlen+0x1e>
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	85 d2                	test   %edx,%edx
  800767:	74 17                	je     800780 <strnlen+0x24>
  800769:	80 39 00             	cmpb   $0x0,(%ecx)
  80076c:	74 19                	je     800787 <strnlen+0x2b>
  80076e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800773:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	39 d0                	cmp    %edx,%eax
  800776:	74 14                	je     80078c <strnlen+0x30>
  800778:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077c:	75 f5                	jne    800773 <strnlen+0x17>
  80077e:	eb 0c                	jmp    80078c <strnlen+0x30>
  800780:	b8 00 00 00 00       	mov    $0x0,%eax
  800785:	eb 05                	jmp    80078c <strnlen+0x30>
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	53                   	push   %ebx
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800798:	ba 00 00 00 00       	mov    $0x0,%edx
  80079d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a3:	42                   	inc    %edx
  8007a4:	84 c9                	test   %cl,%cl
  8007a6:	75 f5                	jne    80079d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b2:	53                   	push   %ebx
  8007b3:	e8 84 ff ff ff       	call   80073c <strlen>
  8007b8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007c1:	50                   	push   %eax
  8007c2:	e8 c7 ff ff ff       	call   80078e <strcpy>
	return dst;
}
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	85 f6                	test   %esi,%esi
  8007de:	74 15                	je     8007f5 <strncpy+0x27>
  8007e0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e5:	8a 1a                	mov    (%edx),%bl
  8007e7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ea:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f0:	41                   	inc    %ecx
  8007f1:	39 ce                	cmp    %ecx,%esi
  8007f3:	77 f0                	ja     8007e5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5e                   	pop    %esi
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	57                   	push   %edi
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800805:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	85 f6                	test   %esi,%esi
  80080a:	74 32                	je     80083e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80080c:	83 fe 01             	cmp    $0x1,%esi
  80080f:	74 22                	je     800833 <strlcpy+0x3a>
  800811:	8a 0b                	mov    (%ebx),%cl
  800813:	84 c9                	test   %cl,%cl
  800815:	74 20                	je     800837 <strlcpy+0x3e>
  800817:	89 f8                	mov    %edi,%eax
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80081e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	88 08                	mov    %cl,(%eax)
  800823:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800824:	39 f2                	cmp    %esi,%edx
  800826:	74 11                	je     800839 <strlcpy+0x40>
  800828:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80082c:	42                   	inc    %edx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 f0                	jne    800821 <strlcpy+0x28>
  800831:	eb 06                	jmp    800839 <strlcpy+0x40>
  800833:	89 f8                	mov    %edi,%eax
  800835:	eb 02                	jmp    800839 <strlcpy+0x40>
  800837:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
  80083c:	eb 02                	jmp    800840 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800840:	29 f8                	sub    %edi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5f                   	pop    %edi
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800850:	8a 01                	mov    (%ecx),%al
  800852:	84 c0                	test   %al,%al
  800854:	74 10                	je     800866 <strcmp+0x1f>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	75 0c                	jne    800866 <strcmp+0x1f>
		p++, q++;
  80085a:	41                   	inc    %ecx
  80085b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085c:	8a 01                	mov    (%ecx),%al
  80085e:	84 c0                	test   %al,%al
  800860:	74 04                	je     800866 <strcmp+0x1f>
  800862:	3a 02                	cmp    (%edx),%al
  800864:	74 f4                	je     80085a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800866:	0f b6 c0             	movzbl %al,%eax
  800869:	0f b6 12             	movzbl (%edx),%edx
  80086c:	29 d0                	sub    %edx,%eax
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	8b 55 08             	mov    0x8(%ebp),%edx
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 1b                	je     80089c <strncmp+0x2c>
  800881:	8a 1a                	mov    (%edx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	74 24                	je     8008ab <strncmp+0x3b>
  800887:	3a 19                	cmp    (%ecx),%bl
  800889:	75 20                	jne    8008ab <strncmp+0x3b>
  80088b:	48                   	dec    %eax
  80088c:	74 15                	je     8008a3 <strncmp+0x33>
		n--, p++, q++;
  80088e:	42                   	inc    %edx
  80088f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800890:	8a 1a                	mov    (%edx),%bl
  800892:	84 db                	test   %bl,%bl
  800894:	74 15                	je     8008ab <strncmp+0x3b>
  800896:	3a 19                	cmp    (%ecx),%bl
  800898:	74 f1                	je     80088b <strncmp+0x1b>
  80089a:	eb 0f                	jmp    8008ab <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	eb 05                	jmp    8008a8 <strncmp+0x38>
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 02             	movzbl (%edx),%eax
  8008ae:	0f b6 11             	movzbl (%ecx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
  8008b3:	eb f3                	jmp    8008a8 <strncmp+0x38>

008008b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008be:	8a 10                	mov    (%eax),%dl
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	74 18                	je     8008dc <strchr+0x27>
		if (*s == c)
  8008c4:	38 ca                	cmp    %cl,%dl
  8008c6:	75 06                	jne    8008ce <strchr+0x19>
  8008c8:	eb 17                	jmp    8008e1 <strchr+0x2c>
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 13                	je     8008e1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	40                   	inc    %eax
  8008cf:	8a 10                	mov    (%eax),%dl
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f5                	jne    8008ca <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008da:	eb 05                	jmp    8008e1 <strchr+0x2c>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ec:	8a 10                	mov    (%eax),%dl
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	74 11                	je     800903 <strfind+0x20>
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	75 06                	jne    8008fc <strfind+0x19>
  8008f6:	eb 0b                	jmp    800903 <strfind+0x20>
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 07                	je     800903 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fc:	40                   	inc    %eax
  8008fd:	8a 10                	mov    (%eax),%dl
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f5                	jne    8008f8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800914:	85 c9                	test   %ecx,%ecx
  800916:	74 30                	je     800948 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800918:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091e:	75 25                	jne    800945 <memset+0x40>
  800920:	f6 c1 03             	test   $0x3,%cl
  800923:	75 20                	jne    800945 <memset+0x40>
		c &= 0xFF;
  800925:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800928:	89 d3                	mov    %edx,%ebx
  80092a:	c1 e3 08             	shl    $0x8,%ebx
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	c1 e6 18             	shl    $0x18,%esi
  800932:	89 d0                	mov    %edx,%eax
  800934:	c1 e0 10             	shl    $0x10,%eax
  800937:	09 f0                	or     %esi,%eax
  800939:	09 d0                	or     %edx,%eax
  80093b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80093d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800940:	fc                   	cld    
  800941:	f3 ab                	rep stos %eax,%es:(%edi)
  800943:	eb 03                	jmp    800948 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800945:	fc                   	cld    
  800946:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800948:	89 f8                	mov    %edi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095d:	39 c6                	cmp    %eax,%esi
  80095f:	73 34                	jae    800995 <memmove+0x46>
  800961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800964:	39 d0                	cmp    %edx,%eax
  800966:	73 2d                	jae    800995 <memmove+0x46>
		s += n;
		d += n;
  800968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	f6 c2 03             	test   $0x3,%dl
  80096e:	75 1b                	jne    80098b <memmove+0x3c>
  800970:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800976:	75 13                	jne    80098b <memmove+0x3c>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0e                	jne    80098b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097d:	83 ef 04             	sub    $0x4,%edi
  800980:	8d 72 fc             	lea    -0x4(%edx),%esi
  800983:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800986:	fd                   	std    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 07                	jmp    800992 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098b:	4f                   	dec    %edi
  80098c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098f:	fd                   	std    
  800990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800992:	fc                   	cld    
  800993:	eb 20                	jmp    8009b5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099b:	75 13                	jne    8009b0 <memmove+0x61>
  80099d:	a8 03                	test   $0x3,%al
  80099f:	75 0f                	jne    8009b0 <memmove+0x61>
  8009a1:	f6 c1 03             	test   $0x3,%cl
  8009a4:	75 0a                	jne    8009b0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 05                	jmp    8009b5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b0:	89 c7                	mov    %eax,%edi
  8009b2:	fc                   	cld    
  8009b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bc:	ff 75 10             	pushl  0x10(%ebp)
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	ff 75 08             	pushl  0x8(%ebp)
  8009c5:	e8 85 ff ff ff       	call   80094f <memmove>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	85 ff                	test   %edi,%edi
  8009dd:	74 32                	je     800a11 <memcmp+0x45>
		if (*s1 != *s2)
  8009df:	8a 03                	mov    (%ebx),%al
  8009e1:	8a 0e                	mov    (%esi),%cl
  8009e3:	38 c8                	cmp    %cl,%al
  8009e5:	74 19                	je     800a00 <memcmp+0x34>
  8009e7:	eb 0d                	jmp    8009f6 <memcmp+0x2a>
  8009e9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009ed:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009f1:	42                   	inc    %edx
  8009f2:	38 c8                	cmp    %cl,%al
  8009f4:	74 10                	je     800a06 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009f6:	0f b6 c0             	movzbl %al,%eax
  8009f9:	0f b6 c9             	movzbl %cl,%ecx
  8009fc:	29 c8                	sub    %ecx,%eax
  8009fe:	eb 16                	jmp    800a16 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a00:	4f                   	dec    %edi
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
  800a06:	39 fa                	cmp    %edi,%edx
  800a08:	75 df                	jne    8009e9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0f:	eb 05                	jmp    800a16 <memcmp+0x4a>
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a21:	89 c2                	mov    %eax,%edx
  800a23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a26:	39 d0                	cmp    %edx,%eax
  800a28:	73 12                	jae    800a3c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a2d:	38 08                	cmp    %cl,(%eax)
  800a2f:	75 06                	jne    800a37 <memfind+0x1c>
  800a31:	eb 09                	jmp    800a3c <memfind+0x21>
  800a33:	38 08                	cmp    %cl,(%eax)
  800a35:	74 05                	je     800a3c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	40                   	inc    %eax
  800a38:	39 c2                	cmp    %eax,%edx
  800a3a:	77 f7                	ja     800a33 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
  800a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	eb 01                	jmp    800a4d <strtol+0xf>
		s++;
  800a4c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	8a 02                	mov    (%edx),%al
  800a4f:	3c 20                	cmp    $0x20,%al
  800a51:	74 f9                	je     800a4c <strtol+0xe>
  800a53:	3c 09                	cmp    $0x9,%al
  800a55:	74 f5                	je     800a4c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a57:	3c 2b                	cmp    $0x2b,%al
  800a59:	75 08                	jne    800a63 <strtol+0x25>
		s++;
  800a5b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a61:	eb 13                	jmp    800a76 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	75 0a                	jne    800a71 <strtol+0x33>
		s++, neg = 1;
  800a67:	8d 52 01             	lea    0x1(%edx),%edx
  800a6a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6f:	eb 05                	jmp    800a76 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	74 05                	je     800a7f <strtol+0x41>
  800a7a:	83 fb 10             	cmp    $0x10,%ebx
  800a7d:	75 28                	jne    800aa7 <strtol+0x69>
  800a7f:	8a 02                	mov    (%edx),%al
  800a81:	3c 30                	cmp    $0x30,%al
  800a83:	75 10                	jne    800a95 <strtol+0x57>
  800a85:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a89:	75 0a                	jne    800a95 <strtol+0x57>
		s += 2, base = 16;
  800a8b:	83 c2 02             	add    $0x2,%edx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb 12                	jmp    800aa7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 0e                	jne    800aa7 <strtol+0x69>
  800a99:	3c 30                	cmp    $0x30,%al
  800a9b:	75 05                	jne    800aa2 <strtol+0x64>
		s++, base = 8;
  800a9d:	42                   	inc    %edx
  800a9e:	b3 08                	mov    $0x8,%bl
  800aa0:	eb 05                	jmp    800aa7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aae:	8a 0a                	mov    (%edx),%cl
  800ab0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab3:	80 fb 09             	cmp    $0x9,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0x82>
			dig = *s - '0';
  800ab8:	0f be c9             	movsbl %cl,%ecx
  800abb:	83 e9 30             	sub    $0x30,%ecx
  800abe:	eb 1e                	jmp    800ade <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ac0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac8:	0f be c9             	movsbl %cl,%ecx
  800acb:	83 e9 57             	sub    $0x57,%ecx
  800ace:	eb 0e                	jmp    800ade <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ad0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 13                	ja     800aeb <strtol+0xad>
			dig = *s - 'A' + 10;
  800ad8:	0f be c9             	movsbl %cl,%ecx
  800adb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ade:	39 f1                	cmp    %esi,%ecx
  800ae0:	7d 0d                	jge    800aef <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ae2:	42                   	inc    %edx
  800ae3:	0f af c6             	imul   %esi,%eax
  800ae6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ae9:	eb c3                	jmp    800aae <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aeb:	89 c1                	mov    %eax,%ecx
  800aed:	eb 02                	jmp    800af1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aef:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af5:	74 05                	je     800afc <strtol+0xbe>
		*endptr = (char *) s;
  800af7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800afc:	85 ff                	test   %edi,%edi
  800afe:	74 04                	je     800b04 <strtol+0xc6>
  800b00:	89 c8                	mov    %ecx,%eax
  800b02:	f7 d8                	neg    %eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    
  800b09:	00 00                	add    %al,(%eax)
	...

00800b0c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 1c             	sub    $0x1c,%esp
  800b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b18:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b1b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b20:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	cd 30                	int    $0x30
  800b2b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b31:	74 1c                	je     800b4f <syscall+0x43>
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 18                	jle    800b4f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b3e:	68 84 15 80 00       	push   $0x801584
  800b43:	6a 42                	push   $0x42
  800b45:	68 a1 15 80 00       	push   $0x8015a1
  800b4a:	e8 95 04 00 00       	call   800fe4 <_panic>

	return ret;
}
  800b4f:	89 d0                	mov    %edx,%eax
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	ff 75 0c             	pushl  0xc(%ebp)
  800b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	e8 92 ff ff ff       	call   800b0c <syscall>
  800b7a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9c:	e8 6b ff ff ff       	call   800b0c <syscall>
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbe:	e8 49 ff ff ff       	call   800b0c <syscall>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 02 00 00 00       	mov    $0x2,%eax
  800be2:	e8 25 ff ff ff       	call   800b0c <syscall>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c06:	e8 01 ff ff ff       	call   800b0c <syscall>
  800c0b:	83 c4 10             	add    $0x10,%esp
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c16:	6a 00                	push   $0x0
  800c18:	6a 00                	push   $0x0
  800c1a:	ff 75 10             	pushl  0x10(%ebp)
  800c1d:	ff 75 0c             	pushl  0xc(%ebp)
  800c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c23:	ba 01 00 00 00       	mov    $0x1,%edx
  800c28:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2d:	e8 da fe ff ff       	call   800b0c <syscall>
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c3a:	ff 75 18             	pushl  0x18(%ebp)
  800c3d:	ff 75 14             	pushl  0x14(%ebp)
  800c40:	ff 75 10             	pushl  0x10(%ebp)
  800c43:	ff 75 0c             	pushl  0xc(%ebp)
  800c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c49:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c53:	e8 b4 fe ff ff       	call   800b0c <syscall>
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	6a 00                	push   $0x0
  800c66:	ff 75 0c             	pushl  0xc(%ebp)
  800c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c71:	b8 06 00 00 00       	mov    $0x6,%eax
  800c76:	e8 91 fe ff ff       	call   800b0c <syscall>
}
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c83:	6a 00                	push   $0x0
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	ff 75 0c             	pushl  0xc(%ebp)
  800c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c94:	b8 08 00 00 00       	mov    $0x8,%eax
  800c99:	e8 6e fe ff ff       	call   800b0c <syscall>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ca6:	6a 00                	push   $0x0
  800ca8:	6a 00                	push   $0x0
  800caa:	6a 00                	push   $0x0
  800cac:	ff 75 0c             	pushl  0xc(%ebp)
  800caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbc:	e8 4b fe ff ff       	call   800b0c <syscall>
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cc9:	6a 00                	push   $0x0
  800ccb:	ff 75 14             	pushl  0x14(%ebp)
  800cce:	ff 75 10             	pushl  0x10(%ebp)
  800cd1:	ff 75 0c             	pushl  0xc(%ebp)
  800cd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce1:	e8 26 fe ff ff       	call   800b0c <syscall>
}
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cee:	6a 00                	push   $0x0
  800cf0:	6a 00                	push   $0x0
  800cf2:	6a 00                	push   $0x0
  800cf4:	6a 00                	push   $0x0
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	e8 04 fe ff ff       	call   800b0c <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    
	...

00800d0c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d16:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d18:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d1c:	75 14                	jne    800d32 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d1e:	83 ec 04             	sub    $0x4,%esp
  800d21:	68 b0 15 80 00       	push   $0x8015b0
  800d26:	6a 20                	push   $0x20
  800d28:	68 f4 16 80 00       	push   $0x8016f4
  800d2d:	e8 b2 02 00 00       	call   800fe4 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d32:	89 d8                	mov    %ebx,%eax
  800d34:	c1 e8 16             	shr    $0x16,%eax
  800d37:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d3e:	a8 01                	test   $0x1,%al
  800d40:	74 11                	je     800d53 <pgfault+0x47>
  800d42:	89 d8                	mov    %ebx,%eax
  800d44:	c1 e8 0c             	shr    $0xc,%eax
  800d47:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4e:	f6 c4 08             	test   $0x8,%ah
  800d51:	75 14                	jne    800d67 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 d4 15 80 00       	push   $0x8015d4
  800d5b:	6a 24                	push   $0x24
  800d5d:	68 f4 16 80 00       	push   $0x8016f4
  800d62:	e8 7d 02 00 00       	call   800fe4 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	6a 07                	push   $0x7
  800d6c:	68 00 f0 7f 00       	push   $0x7ff000
  800d71:	6a 00                	push   $0x0
  800d73:	e8 98 fe ff ff       	call   800c10 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	79 12                	jns    800d91 <pgfault+0x85>
  800d7f:	50                   	push   %eax
  800d80:	68 f8 15 80 00       	push   $0x8015f8
  800d85:	6a 32                	push   $0x32
  800d87:	68 f4 16 80 00       	push   $0x8016f4
  800d8c:	e8 53 02 00 00       	call   800fe4 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800d91:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800d97:	83 ec 04             	sub    $0x4,%esp
  800d9a:	68 00 10 00 00       	push   $0x1000
  800d9f:	53                   	push   %ebx
  800da0:	68 00 f0 7f 00       	push   $0x7ff000
  800da5:	e8 0f fc ff ff       	call   8009b9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800daa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800db1:	53                   	push   %ebx
  800db2:	6a 00                	push   $0x0
  800db4:	68 00 f0 7f 00       	push   $0x7ff000
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 74 fe ff ff       	call   800c34 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800dc0:	83 c4 20             	add    $0x20,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 12                	jns    800dd9 <pgfault+0xcd>
  800dc7:	50                   	push   %eax
  800dc8:	68 1c 16 80 00       	push   $0x80161c
  800dcd:	6a 3a                	push   $0x3a
  800dcf:	68 f4 16 80 00       	push   $0x8016f4
  800dd4:	e8 0b 02 00 00       	call   800fe4 <_panic>

	return;
}
  800dd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    

00800dde <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800de7:	68 0c 0d 80 00       	push   $0x800d0c
  800dec:	e8 3b 02 00 00       	call   80102c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800df1:	ba 07 00 00 00       	mov    $0x7,%edx
  800df6:	89 d0                	mov    %edx,%eax
  800df8:	cd 30                	int    $0x30
  800dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800dfd:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 12                	jns    800e18 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e06:	50                   	push   %eax
  800e07:	68 ff 16 80 00       	push   $0x8016ff
  800e0c:	6a 79                	push   $0x79
  800e0e:	68 f4 16 80 00       	push   $0x8016f4
  800e13:	e8 cc 01 00 00       	call   800fe4 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e1c:	75 25                	jne    800e43 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e1e:	e8 a2 fd ff ff       	call   800bc5 <sys_getenvid>
  800e23:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e2f:	c1 e0 07             	shl    $0x7,%eax
  800e32:	29 d0                	sub    %edx,%eax
  800e34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e39:	a3 04 20 80 00       	mov    %eax,0x802004
		// cprintf("fork child ok\n");
		return 0;
  800e3e:	e9 7b 01 00 00       	jmp    800fbe <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	c1 e8 16             	shr    $0x16,%eax
  800e4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e54:	a8 01                	test   $0x1,%al
  800e56:	0f 84 cd 00 00 00    	je     800f29 <fork+0x14b>
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
  800e61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e68:	f6 c2 01             	test   $0x1,%dl
  800e6b:	0f 84 b8 00 00 00    	je     800f29 <fork+0x14b>
  800e71:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e78:	f6 c2 04             	test   $0x4,%dl
  800e7b:	0f 84 a8 00 00 00    	je     800f29 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800e81:	89 c6                	mov    %eax,%esi
  800e83:	c1 e6 0c             	shl    $0xc,%esi
  800e86:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800e8c:	0f 84 97 00 00 00    	je     800f29 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800e92:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e99:	f6 c2 02             	test   $0x2,%dl
  800e9c:	75 0c                	jne    800eaa <fork+0xcc>
  800e9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea5:	f6 c4 08             	test   $0x8,%ah
  800ea8:	74 57                	je     800f01 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	68 05 08 00 00       	push   $0x805
  800eb2:	56                   	push   %esi
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 78 fd ff ff       	call   800c34 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <fork+0xf7>
  800ec3:	50                   	push   %eax
  800ec4:	68 40 16 80 00       	push   $0x801640
  800ec9:	6a 55                	push   $0x55
  800ecb:	68 f4 16 80 00       	push   $0x8016f4
  800ed0:	e8 0f 01 00 00       	call   800fe4 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	68 05 08 00 00       	push   $0x805
  800edd:	56                   	push   %esi
  800ede:	6a 00                	push   $0x0
  800ee0:	56                   	push   %esi
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 4c fd ff ff       	call   800c34 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	79 3a                	jns    800f29 <fork+0x14b>
  800eef:	50                   	push   %eax
  800ef0:	68 40 16 80 00       	push   $0x801640
  800ef5:	6a 58                	push   $0x58
  800ef7:	68 f4 16 80 00       	push   $0x8016f4
  800efc:	e8 e3 00 00 00       	call   800fe4 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	6a 05                	push   $0x5
  800f06:	56                   	push   %esi
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	6a 00                	push   $0x0
  800f0b:	e8 24 fd ff ff       	call   800c34 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 12                	jns    800f29 <fork+0x14b>
  800f17:	50                   	push   %eax
  800f18:	68 40 16 80 00       	push   $0x801640
  800f1d:	6a 5c                	push   $0x5c
  800f1f:	68 f4 16 80 00       	push   $0x8016f4
  800f24:	e8 bb 00 00 00       	call   800fe4 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f29:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f2f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f35:	0f 85 0d ff ff ff    	jne    800e48 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	6a 07                	push   $0x7
  800f40:	68 00 f0 bf ee       	push   $0xeebff000
  800f45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f48:	e8 c3 fc ff ff       	call   800c10 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 15                	jns    800f69 <fork+0x18b>
  800f54:	50                   	push   %eax
  800f55:	68 64 16 80 00       	push   $0x801664
  800f5a:	68 8e 00 00 00       	push   $0x8e
  800f5f:	68 f4 16 80 00       	push   $0x8016f4
  800f64:	e8 7b 00 00 00       	call   800fe4 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	68 98 10 80 00       	push   $0x801098
  800f71:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f74:	e8 27 fd ff ff       	call   800ca0 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 15                	jns    800f95 <fork+0x1b7>
  800f80:	50                   	push   %eax
  800f81:	68 9c 16 80 00       	push   $0x80169c
  800f86:	68 93 00 00 00       	push   $0x93
  800f8b:	68 f4 16 80 00       	push   $0x8016f4
  800f90:	e8 4f 00 00 00       	call   800fe4 <_panic>

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	6a 02                	push   $0x2
  800f9a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9d:	e8 db fc ff ff       	call   800c7d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 15                	jns    800fbe <fork+0x1e0>
  800fa9:	50                   	push   %eax
  800faa:	68 c0 16 80 00       	push   $0x8016c0
  800faf:	68 97 00 00 00       	push   $0x97
  800fb4:	68 f4 16 80 00       	push   $0x8016f4
  800fb9:	e8 26 00 00 00       	call   800fe4 <_panic>
		// cprintf("fork father ok!");
		return childpid;
	}

	panic("fork not implemented");
}
  800fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <sfork>:

// Challenge!
int
sfork(void)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fcf:	68 1c 17 80 00       	push   $0x80171c
  800fd4:	68 a4 00 00 00       	push   $0xa4
  800fd9:	68 f4 16 80 00       	push   $0x8016f4
  800fde:	e8 01 00 00 00       	call   800fe4 <_panic>
	...

00800fe4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fec:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ff2:	e8 ce fb ff ff       	call   800bc5 <sys_getenvid>
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	ff 75 0c             	pushl  0xc(%ebp)
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	53                   	push   %ebx
  801001:	50                   	push   %eax
  801002:	68 34 17 80 00       	push   $0x801734
  801007:	e8 cc f1 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80100c:	83 c4 18             	add    $0x18,%esp
  80100f:	56                   	push   %esi
  801010:	ff 75 10             	pushl  0x10(%ebp)
  801013:	e8 6f f1 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  801018:	c7 04 24 2f 13 80 00 	movl   $0x80132f,(%esp)
  80101f:	e8 b4 f1 ff ff       	call   8001d8 <cprintf>
  801024:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801027:	cc                   	int3   
  801028:	eb fd                	jmp    801027 <_panic+0x43>
	...

0080102c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801032:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801039:	75 52                	jne    80108d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	6a 07                	push   $0x7
  801040:	68 00 f0 bf ee       	push   $0xeebff000
  801045:	6a 00                	push   $0x0
  801047:	e8 c4 fb ff ff       	call   800c10 <sys_page_alloc>
		if (r < 0) {
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 12                	jns    801065 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801053:	50                   	push   %eax
  801054:	68 57 17 80 00       	push   $0x801757
  801059:	6a 24                	push   $0x24
  80105b:	68 72 17 80 00       	push   $0x801772
  801060:	e8 7f ff ff ff       	call   800fe4 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	68 98 10 80 00       	push   $0x801098
  80106d:	6a 00                	push   $0x0
  80106f:	e8 2c fc ff ff       	call   800ca0 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	79 12                	jns    80108d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80107b:	50                   	push   %eax
  80107c:	68 80 17 80 00       	push   $0x801780
  801081:	6a 2a                	push   $0x2a
  801083:	68 72 17 80 00       	push   $0x801772
  801088:	e8 57 ff ff ff       	call   800fe4 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    
	...

00801098 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801098:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801099:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80109e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010a0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8010a3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8010a7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8010aa:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8010ae:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8010b2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8010b4:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8010b7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8010b8:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8010bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010bc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010bd:	c3                   	ret    
	...

008010c0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	83 ec 10             	sub    $0x10,%esp
  8010c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8010ce:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8010d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8010d4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010d7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	75 2e                	jne    80110c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8010de:	39 f1                	cmp    %esi,%ecx
  8010e0:	77 5a                	ja     80113c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010e2:	85 c9                	test   %ecx,%ecx
  8010e4:	75 0b                	jne    8010f1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f1                	div    %ecx
  8010ef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	89 f0                	mov    %esi,%eax
  8010f5:	f7 f1                	div    %ecx
  8010f7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	f7 f1                	div    %ecx
  8010fd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8010ff:	89 f8                	mov    %edi,%eax
  801101:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	c9                   	leave  
  801109:	c3                   	ret    
  80110a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80110c:	39 f0                	cmp    %esi,%eax
  80110e:	77 1c                	ja     80112c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801110:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801113:	83 f7 1f             	xor    $0x1f,%edi
  801116:	75 3c                	jne    801154 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801118:	39 f0                	cmp    %esi,%eax
  80111a:	0f 82 90 00 00 00    	jb     8011b0 <__udivdi3+0xf0>
  801120:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801123:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801126:	0f 86 84 00 00 00    	jbe    8011b0 <__udivdi3+0xf0>
  80112c:	31 f6                	xor    %esi,%esi
  80112e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801130:	89 f8                	mov    %edi,%eax
  801132:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	c9                   	leave  
  80113a:	c3                   	ret    
  80113b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80113c:	89 f2                	mov    %esi,%edx
  80113e:	89 f8                	mov    %edi,%eax
  801140:	f7 f1                	div    %ecx
  801142:	89 c7                	mov    %eax,%edi
  801144:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801146:	89 f8                	mov    %edi,%eax
  801148:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	c9                   	leave  
  801150:	c3                   	ret    
  801151:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801154:	89 f9                	mov    %edi,%ecx
  801156:	d3 e0                	shl    %cl,%eax
  801158:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80115b:	b8 20 00 00 00       	mov    $0x20,%eax
  801160:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801162:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801165:	88 c1                	mov    %al,%cl
  801167:	d3 ea                	shr    %cl,%edx
  801169:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80116c:	09 ca                	or     %ecx,%edx
  80116e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801171:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801174:	89 f9                	mov    %edi,%ecx
  801176:	d3 e2                	shl    %cl,%edx
  801178:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	88 c1                	mov    %al,%cl
  80117f:	d3 ea                	shr    %cl,%edx
  801181:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801184:	89 f2                	mov    %esi,%edx
  801186:	89 f9                	mov    %edi,%ecx
  801188:	d3 e2                	shl    %cl,%edx
  80118a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80118d:	88 c1                	mov    %al,%cl
  80118f:	d3 ee                	shr    %cl,%esi
  801191:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801193:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801196:	89 f0                	mov    %esi,%eax
  801198:	89 ca                	mov    %ecx,%edx
  80119a:	f7 75 ec             	divl   -0x14(%ebp)
  80119d:	89 d1                	mov    %edx,%ecx
  80119f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8011a1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011a4:	39 d1                	cmp    %edx,%ecx
  8011a6:	72 28                	jb     8011d0 <__udivdi3+0x110>
  8011a8:	74 1a                	je     8011c4 <__udivdi3+0x104>
  8011aa:	89 f7                	mov    %esi,%edi
  8011ac:	31 f6                	xor    %esi,%esi
  8011ae:	eb 80                	jmp    801130 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011b0:	31 f6                	xor    %esi,%esi
  8011b2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011b7:	89 f8                	mov    %edi,%eax
  8011b9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    
  8011c2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c7:	89 f9                	mov    %edi,%ecx
  8011c9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011cb:	39 c2                	cmp    %eax,%edx
  8011cd:	73 db                	jae    8011aa <__udivdi3+0xea>
  8011cf:	90                   	nop
		{
		  q0--;
  8011d0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011d3:	31 f6                	xor    %esi,%esi
  8011d5:	e9 56 ff ff ff       	jmp    801130 <__udivdi3+0x70>
	...

008011dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	83 ec 20             	sub    $0x20,%esp
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8011ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8011ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8011f0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8011f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8011f9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011fb:	85 ff                	test   %edi,%edi
  8011fd:	75 15                	jne    801214 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8011ff:	39 f1                	cmp    %esi,%ecx
  801201:	0f 86 99 00 00 00    	jbe    8012a0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801207:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801209:	89 d0                	mov    %edx,%eax
  80120b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80120d:	83 c4 20             	add    $0x20,%esp
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	c9                   	leave  
  801213:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801214:	39 f7                	cmp    %esi,%edi
  801216:	0f 87 a4 00 00 00    	ja     8012c0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80121c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80121f:	83 f0 1f             	xor    $0x1f,%eax
  801222:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801225:	0f 84 a1 00 00 00    	je     8012cc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80122b:	89 f8                	mov    %edi,%eax
  80122d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801230:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801232:	bf 20 00 00 00       	mov    $0x20,%edi
  801237:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80123a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123d:	89 f9                	mov    %edi,%ecx
  80123f:	d3 ea                	shr    %cl,%edx
  801241:	09 c2                	or     %eax,%edx
  801243:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801249:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80124c:	d3 e0                	shl    %cl,%eax
  80124e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801251:	89 f2                	mov    %esi,%edx
  801253:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801255:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801258:	d3 e0                	shl    %cl,%eax
  80125a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80125d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801260:	89 f9                	mov    %edi,%ecx
  801262:	d3 e8                	shr    %cl,%eax
  801264:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801266:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801268:	89 f2                	mov    %esi,%edx
  80126a:	f7 75 f0             	divl   -0x10(%ebp)
  80126d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80126f:	f7 65 f4             	mull   -0xc(%ebp)
  801272:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801275:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801277:	39 d6                	cmp    %edx,%esi
  801279:	72 71                	jb     8012ec <__umoddi3+0x110>
  80127b:	74 7f                	je     8012fc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80127d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801280:	29 c8                	sub    %ecx,%eax
  801282:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801284:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801287:	d3 e8                	shr    %cl,%eax
  801289:	89 f2                	mov    %esi,%edx
  80128b:	89 f9                	mov    %edi,%ecx
  80128d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80128f:	09 d0                	or     %edx,%eax
  801291:	89 f2                	mov    %esi,%edx
  801293:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801296:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801298:	83 c4 20             	add    $0x20,%esp
  80129b:	5e                   	pop    %esi
  80129c:	5f                   	pop    %edi
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    
  80129f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8012a0:	85 c9                	test   %ecx,%ecx
  8012a2:	75 0b                	jne    8012af <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8012a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a9:	31 d2                	xor    %edx,%edx
  8012ab:	f7 f1                	div    %ecx
  8012ad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8012af:	89 f0                	mov    %esi,%eax
  8012b1:	31 d2                	xor    %edx,%edx
  8012b3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b8:	f7 f1                	div    %ecx
  8012ba:	e9 4a ff ff ff       	jmp    801209 <__umoddi3+0x2d>
  8012bf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8012c0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012c2:	83 c4 20             	add    $0x20,%esp
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    
  8012c9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8012cc:	39 f7                	cmp    %esi,%edi
  8012ce:	72 05                	jb     8012d5 <__umoddi3+0xf9>
  8012d0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8012d3:	77 0c                	ja     8012e1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012d5:	89 f2                	mov    %esi,%edx
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	29 c8                	sub    %ecx,%eax
  8012dc:	19 fa                	sbb    %edi,%edx
  8012de:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012e4:	83 c4 20             	add    $0x20,%esp
  8012e7:	5e                   	pop    %esi
  8012e8:	5f                   	pop    %edi
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    
  8012eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012ef:	89 c1                	mov    %eax,%ecx
  8012f1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8012f4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8012f7:	eb 84                	jmp    80127d <__umoddi3+0xa1>
  8012f9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8012ff:	72 eb                	jb     8012ec <__umoddi3+0x110>
  801301:	89 f2                	mov    %esi,%edx
  801303:	e9 75 ff ff ff       	jmp    80127d <__umoddi3+0xa1>
