
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
  80003e:	e8 7a 0b 00 00       	call   800bbd <sys_getenvid>
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	53                   	push   %ebx
  800047:	50                   	push   %eax
  800048:	68 20 13 80 00       	push   $0x801320
  80004d:	e8 7e 01 00 00       	call   8001d0 <cprintf>

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
  800081:	e8 ae 06 00 00       	call   800734 <strlen>
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
  8000a2:	e8 71 06 00 00       	call   800718 <snprintf>
	if (fork() == 0) {
  8000a7:	83 c4 20             	add    $0x20,%esp
  8000aa:	e8 4b 0d 00 00       	call   800dfa <fork>
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 14                	jne    8000c7 <forkchild+0x57>
		forktree(nxt);
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	e8 75 ff ff ff       	call   800034 <forktree>
		exit();
  8000bf:	e8 68 00 00 00       	call   80012c <exit>
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
  8000ef:	e8 c9 0a 00 00       	call   800bbd <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	c1 e0 07             	shl    $0x7,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 f6                	test   %esi,%esi
  800108:	7e 07                	jle    800111 <libmain+0x2d>
		binaryname = argv[0];
  80010a:	8b 03                	mov    (%ebx),%eax
  80010c:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	53                   	push   %ebx
  800115:	56                   	push   %esi
  800116:	e8 b1 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80011b:	e8 0c 00 00 00       	call   80012c <exit>
  800120:	83 c4 10             	add    $0x10,%esp
}
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	c9                   	leave  
  800129:	c3                   	ret    
	...

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800132:	6a 00                	push   $0x0
  800134:	e8 62 0a 00 00       	call   800b9b <sys_env_destroy>
  800139:	83 c4 10             	add    $0x10,%esp
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    
	...

00800140 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	53                   	push   %ebx
  800144:	83 ec 04             	sub    $0x4,%esp
  800147:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014a:	8b 03                	mov    (%ebx),%eax
  80014c:	8b 55 08             	mov    0x8(%ebp),%edx
  80014f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800153:	40                   	inc    %eax
  800154:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800156:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015b:	75 1a                	jne    800177 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80015d:	83 ec 08             	sub    $0x8,%esp
  800160:	68 ff 00 00 00       	push   $0xff
  800165:	8d 43 08             	lea    0x8(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 e3 09 00 00       	call   800b51 <sys_cputs>
		b->idx = 0;
  80016e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800174:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800177:	ff 43 04             	incl   0x4(%ebx)
}
  80017a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	ff 75 0c             	pushl  0xc(%ebp)
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	68 40 01 80 00       	push   $0x800140
  8001ae:	e8 82 01 00 00       	call   800335 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	83 c4 08             	add    $0x8,%esp
  8001b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 89 09 00 00       	call   800b51 <sys_cputs>

	return b.cnt;
}
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d9:	50                   	push   %eax
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 9d ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 2c             	sub    $0x2c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d6                	mov    %edx,%esi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800201:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800204:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800207:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80020a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800211:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800214:	72 0c                	jb     800222 <printnum+0x3e>
  800216:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800219:	76 07                	jbe    800222 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021b:	4b                   	dec    %ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f 31                	jg     800251 <printnum+0x6d>
  800220:	eb 3f                	jmp    800261 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	57                   	push   %edi
  800226:	4b                   	dec    %ebx
  800227:	53                   	push   %ebx
  800228:	50                   	push   %eax
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022f:	ff 75 d0             	pushl  -0x30(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 97 0e 00 00       	call   8010d4 <__udivdi3>
  80023d:	83 c4 18             	add    $0x18,%esp
  800240:	52                   	push   %edx
  800241:	50                   	push   %eax
  800242:	89 f2                	mov    %esi,%edx
  800244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800247:	e8 98 ff ff ff       	call   8001e4 <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 10                	jmp    800261 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	57                   	push   %edi
  800256:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800259:	4b                   	dec    %ebx
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7f f0                	jg     800251 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	83 ec 04             	sub    $0x4,%esp
  800268:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026b:	ff 75 d0             	pushl  -0x30(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 77 0f 00 00       	call   8011f0 <__umoddi3>
  800279:	83 c4 14             	add    $0x14,%esp
  80027c:	0f be 80 40 13 80 00 	movsbl 0x801340(%eax),%eax
  800283:	50                   	push   %eax
  800284:	ff 55 e4             	call   *-0x1c(%ebp)
  800287:	83 c4 10             	add    $0x10,%esp
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cf:	83 fa 01             	cmp    $0x1,%edx
  8002d2:	7e 0e                	jle    8002e2 <getint+0x16>
		return va_arg(*ap, long long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	8b 52 04             	mov    0x4(%edx),%edx
  8002e0:	eb 1a                	jmp    8002fc <getint+0x30>
	else if (lflag)
  8002e2:	85 d2                	test   %edx,%edx
  8002e4:	74 0c                	je     8002f2 <getint+0x26>
		return va_arg(*ap, long);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	99                   	cltd   
  8002f0:	eb 0a                	jmp    8002fc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	99                   	cltd   
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800304:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 08                	jae    800316 <sprintputch+0x18>
		*b->buf++ = ch;
  80030e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800311:	88 0a                	mov    %cl,(%edx)
  800313:	42                   	inc    %edx
  800314:	89 10                	mov    %edx,(%eax)
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	e8 05 00 00 00       	call   800335 <vprintfmt>
	va_end(ap);
  800330:	83 c4 10             	add    $0x10,%esp
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 2c             	sub    $0x2c,%esp
  80033e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800341:	8b 75 10             	mov    0x10(%ebp),%esi
  800344:	eb 13                	jmp    800359 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 6d 03 00 00    	je     8006bb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	57                   	push   %edi
  800352:	50                   	push   %eax
  800353:	ff 55 08             	call   *0x8(%ebp)
  800356:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	0f b6 06             	movzbl (%esi),%eax
  80035c:	46                   	inc    %esi
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e4                	jne    800346 <vprintfmt+0x11>
  800362:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800366:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80036d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800374:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80037b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800380:	eb 28                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800388:	eb 20                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800390:	eb 18                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800394:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80039b:	eb 0d                	jmp    8003aa <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8a 06                	mov    (%esi),%al
  8003ac:	0f b6 d0             	movzbl %al,%edx
  8003af:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003b2:	83 e8 23             	sub    $0x23,%eax
  8003b5:	3c 55                	cmp    $0x55,%al
  8003b7:	0f 87 e0 02 00 00    	ja     80069d <vprintfmt+0x368>
  8003bd:	0f b6 c0             	movzbl %al,%eax
  8003c0:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c7:	83 ea 30             	sub    $0x30,%edx
  8003ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003cd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003d0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d3:	83 fa 09             	cmp    $0x9,%edx
  8003d6:	77 44                	ja     80041c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	89 de                	mov    %ebx,%esi
  8003da:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003de:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003e1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003e5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003eb:	83 fb 09             	cmp    $0x9,%ebx
  8003ee:	76 ed                	jbe    8003dd <vprintfmt+0xa8>
  8003f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003f3:	eb 29                	jmp    80041e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 50 04             	lea    0x4(%eax),%edx
  8003fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800405:	eb 17                	jmp    80041e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800407:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040b:	78 85                	js     800392 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	89 de                	mov    %ebx,%esi
  80040f:	eb 99                	jmp    8003aa <vprintfmt+0x75>
  800411:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800413:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80041a:	eb 8e                	jmp    8003aa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800422:	79 86                	jns    8003aa <vprintfmt+0x75>
  800424:	e9 74 ff ff ff       	jmp    80039d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	89 de                	mov    %ebx,%esi
  80042c:	e9 79 ff ff ff       	jmp    8003aa <vprintfmt+0x75>
  800431:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	57                   	push   %edi
  800441:	ff 30                	pushl  (%eax)
  800443:	ff 55 08             	call   *0x8(%ebp)
			break;
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044c:	e9 08 ff ff ff       	jmp    800359 <vprintfmt+0x24>
  800451:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 02                	jns    800465 <vprintfmt+0x130>
  800463:	f7 d8                	neg    %eax
  800465:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800467:	83 f8 08             	cmp    $0x8,%eax
  80046a:	7f 0b                	jg     800477 <vprintfmt+0x142>
  80046c:	8b 04 85 60 15 80 00 	mov    0x801560(,%eax,4),%eax
  800473:	85 c0                	test   %eax,%eax
  800475:	75 1a                	jne    800491 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800477:	52                   	push   %edx
  800478:	68 58 13 80 00       	push   $0x801358
  80047d:	57                   	push   %edi
  80047e:	ff 75 08             	pushl  0x8(%ebp)
  800481:	e8 92 fe ff ff       	call   800318 <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 c8 fe ff ff       	jmp    800359 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	50                   	push   %eax
  800492:	68 61 13 80 00       	push   $0x801361
  800497:	57                   	push   %edi
  800498:	ff 75 08             	pushl  0x8(%ebp)
  80049b:	e8 78 fe ff ff       	call   800318 <printfmt>
  8004a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004a6:	e9 ae fe ff ff       	jmp    800359 <vprintfmt+0x24>
  8004ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ae:	89 de                	mov    %ebx,%esi
  8004b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 07                	jne    8004cf <vprintfmt+0x19a>
				p = "(null)";
  8004c8:	c7 45 d0 51 13 80 00 	movl   $0x801351,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004cf:	85 db                	test   %ebx,%ebx
  8004d1:	7e 42                	jle    800515 <vprintfmt+0x1e0>
  8004d3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004d7:	74 3c                	je     800515 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	51                   	push   %ecx
  8004dd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e0:	e8 6f 02 00 00       	call   800754 <strnlen>
  8004e5:	29 c3                	sub    %eax,%ebx
  8004e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	7e 24                	jle    800515 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004f1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004f5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	57                   	push   %edi
  8004ff:	53                   	push   %ebx
  800500:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	4e                   	dec    %esi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	85 f6                	test   %esi,%esi
  800509:	7f f0                	jg     8004fb <vprintfmt+0x1c6>
  80050b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80050e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800515:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800518:	0f be 02             	movsbl (%edx),%eax
  80051b:	85 c0                	test   %eax,%eax
  80051d:	75 47                	jne    800566 <vprintfmt+0x231>
  80051f:	eb 37                	jmp    800558 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800525:	74 16                	je     80053d <vprintfmt+0x208>
  800527:	8d 50 e0             	lea    -0x20(%eax),%edx
  80052a:	83 fa 5e             	cmp    $0x5e,%edx
  80052d:	76 0e                	jbe    80053d <vprintfmt+0x208>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	6a 3f                	push   $0x3f
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 0b                	jmp    800548 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	57                   	push   %edi
  800541:	50                   	push   %eax
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	ff 4d e4             	decl   -0x1c(%ebp)
  80054b:	0f be 03             	movsbl (%ebx),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 03                	je     800555 <vprintfmt+0x220>
  800552:	43                   	inc    %ebx
  800553:	eb 1b                	jmp    800570 <vprintfmt+0x23b>
  800555:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800558:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055c:	7f 1e                	jg     80057c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800561:	e9 f3 fd ff ff       	jmp    800359 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800569:	43                   	inc    %ebx
  80056a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80056d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800570:	85 f6                	test   %esi,%esi
  800572:	78 ad                	js     800521 <vprintfmt+0x1ec>
  800574:	4e                   	dec    %esi
  800575:	79 aa                	jns    800521 <vprintfmt+0x1ec>
  800577:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80057a:	eb dc                	jmp    800558 <vprintfmt+0x223>
  80057c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	6a 20                	push   $0x20
  800585:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800588:	4b                   	dec    %ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ef                	jg     80057f <vprintfmt+0x24a>
  800590:	e9 c4 fd ff ff       	jmp    800359 <vprintfmt+0x24>
  800595:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800598:	89 ca                	mov    %ecx,%edx
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 2a fd ff ff       	call   8002cc <getint>
  8005a2:	89 c3                	mov    %eax,%ebx
  8005a4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	78 0a                	js     8005b4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 b0 00 00 00       	jmp    800664 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	57                   	push   %edi
  8005b8:	6a 2d                	push   $0x2d
  8005ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bd:	f7 db                	neg    %ebx
  8005bf:	83 d6 00             	adc    $0x0,%esi
  8005c2:	f7 de                	neg    %esi
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 93 00 00 00       	jmp    800664 <vprintfmt+0x32f>
  8005d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 b4 fc ff ff       	call   800292 <getuint>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e7:	eb 7b                	jmp    800664 <vprintfmt+0x32f>
  8005e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005ec:	89 ca                	mov    %ecx,%edx
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 d6 fc ff ff       	call   8002cc <getint>
  8005f6:	89 c3                	mov    %eax,%ebx
  8005f8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	78 07                	js     800605 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800603:	eb 5f                	jmp    800664 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	57                   	push   %edi
  800609:	6a 2d                	push   $0x2d
  80060b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80060e:	f7 db                	neg    %ebx
  800610:	83 d6 00             	adc    $0x0,%esi
  800613:	f7 de                	neg    %esi
  800615:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800618:	b8 08 00 00 00       	mov    $0x8,%eax
  80061d:	eb 45                	jmp    800664 <vprintfmt+0x32f>
  80061f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 30                	push   $0x30
  800628:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 78                	push   $0x78
  800631:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063d:	8b 18                	mov    (%eax),%ebx
  80063f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800644:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064c:	eb 16                	jmp    800664 <vprintfmt+0x32f>
  80064e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800651:	89 ca                	mov    %ecx,%edx
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 37 fc ff ff       	call   800292 <getuint>
  80065b:	89 c3                	mov    %eax,%ebx
  80065d:	89 d6                	mov    %edx,%esi
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80066b:	52                   	push   %edx
  80066c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066f:	50                   	push   %eax
  800670:	56                   	push   %esi
  800671:	53                   	push   %ebx
  800672:	89 fa                	mov    %edi,%edx
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	e8 68 fb ff ff       	call   8001e4 <printnum>
			break;
  80067c:	83 c4 20             	add    $0x20,%esp
  80067f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800682:	e9 d2 fc ff ff       	jmp    800359 <vprintfmt+0x24>
  800687:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	57                   	push   %edi
  80068e:	52                   	push   %edx
  80068f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800692:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800698:	e9 bc fc ff ff       	jmp    800359 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	57                   	push   %edi
  8006a1:	6a 25                	push   $0x25
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	eb 02                	jmp    8006ad <vprintfmt+0x378>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006b0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b4:	75 f5                	jne    8006ab <vprintfmt+0x376>
  8006b6:	e9 9e fc ff ff       	jmp    800359 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5f                   	pop    %edi
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 18             	sub    $0x18,%esp
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 26                	je     80070a <vsnprintf+0x47>
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e 29                	jle    800711 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e8:	ff 75 14             	pushl  0x14(%ebp)
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	68 fe 02 80 00       	push   $0x8002fe
  8006f7:	e8 39 fc ff ff       	call   800335 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 0c                	jmp    800716 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb 05                	jmp    800716 <vsnprintf+0x53>
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800721:	50                   	push   %eax
  800722:	ff 75 10             	pushl  0x10(%ebp)
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	ff 75 08             	pushl  0x8(%ebp)
  80072b:	e8 93 ff ff ff       	call   8006c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    
	...

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3a 00             	cmpb   $0x0,(%edx)
  80073d:	74 0e                	je     80074d <strlen+0x19>
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800744:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800749:	75 f9                	jne    800744 <strlen+0x10>
  80074b:	eb 05                	jmp    800752 <strlen+0x1e>
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	85 d2                	test   %edx,%edx
  80075f:	74 17                	je     800778 <strnlen+0x24>
  800761:	80 39 00             	cmpb   $0x0,(%ecx)
  800764:	74 19                	je     80077f <strnlen+0x2b>
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80076b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 d0                	cmp    %edx,%eax
  80076e:	74 14                	je     800784 <strnlen+0x30>
  800770:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800774:	75 f5                	jne    80076b <strnlen+0x17>
  800776:	eb 0c                	jmp    800784 <strnlen+0x30>
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 05                	jmp    800784 <strnlen+0x30>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
  800795:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800798:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80079b:	42                   	inc    %edx
  80079c:	84 c9                	test   %cl,%cl
  80079e:	75 f5                	jne    800795 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 84 ff ff ff       	call   800734 <strlen>
  8007b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 c7 ff ff ff       	call   800786 <strcpy>
	return dst;
}
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	85 f6                	test   %esi,%esi
  8007d6:	74 15                	je     8007ed <strncpy+0x27>
  8007d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007dd:	8a 1a                	mov    (%edx),%bl
  8007df:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	41                   	inc    %ecx
  8007e9:	39 ce                	cmp    %ecx,%esi
  8007eb:	77 f0                	ja     8007dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	57                   	push   %edi
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	85 f6                	test   %esi,%esi
  800802:	74 32                	je     800836 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800804:	83 fe 01             	cmp    $0x1,%esi
  800807:	74 22                	je     80082b <strlcpy+0x3a>
  800809:	8a 0b                	mov    (%ebx),%cl
  80080b:	84 c9                	test   %cl,%cl
  80080d:	74 20                	je     80082f <strlcpy+0x3e>
  80080f:	89 f8                	mov    %edi,%eax
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800816:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800819:	88 08                	mov    %cl,(%eax)
  80081b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081c:	39 f2                	cmp    %esi,%edx
  80081e:	74 11                	je     800831 <strlcpy+0x40>
  800820:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800824:	42                   	inc    %edx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 f0                	jne    800819 <strlcpy+0x28>
  800829:	eb 06                	jmp    800831 <strlcpy+0x40>
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	eb 02                	jmp    800831 <strlcpy+0x40>
  80082f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800831:	c6 00 00             	movb   $0x0,(%eax)
  800834:	eb 02                	jmp    800838 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800838:	29 f8                	sub    %edi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5f                   	pop    %edi
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800848:	8a 01                	mov    (%ecx),%al
  80084a:	84 c0                	test   %al,%al
  80084c:	74 10                	je     80085e <strcmp+0x1f>
  80084e:	3a 02                	cmp    (%edx),%al
  800850:	75 0c                	jne    80085e <strcmp+0x1f>
		p++, q++;
  800852:	41                   	inc    %ecx
  800853:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800854:	8a 01                	mov    (%ecx),%al
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1f>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 f4                	je     800852 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800875:	85 c0                	test   %eax,%eax
  800877:	74 1b                	je     800894 <strncmp+0x2c>
  800879:	8a 1a                	mov    (%edx),%bl
  80087b:	84 db                	test   %bl,%bl
  80087d:	74 24                	je     8008a3 <strncmp+0x3b>
  80087f:	3a 19                	cmp    (%ecx),%bl
  800881:	75 20                	jne    8008a3 <strncmp+0x3b>
  800883:	48                   	dec    %eax
  800884:	74 15                	je     80089b <strncmp+0x33>
		n--, p++, q++;
  800886:	42                   	inc    %edx
  800887:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800888:	8a 1a                	mov    (%edx),%bl
  80088a:	84 db                	test   %bl,%bl
  80088c:	74 15                	je     8008a3 <strncmp+0x3b>
  80088e:	3a 19                	cmp    (%ecx),%bl
  800890:	74 f1                	je     800883 <strncmp+0x1b>
  800892:	eb 0f                	jmp    8008a3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	eb 05                	jmp    8008a0 <strncmp+0x38>
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 02             	movzbl (%edx),%eax
  8008a6:	0f b6 11             	movzbl (%ecx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
  8008ab:	eb f3                	jmp    8008a0 <strncmp+0x38>

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b6:	8a 10                	mov    (%eax),%dl
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 18                	je     8008d4 <strchr+0x27>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	75 06                	jne    8008c6 <strchr+0x19>
  8008c0:	eb 17                	jmp    8008d9 <strchr+0x2c>
  8008c2:	38 ca                	cmp    %cl,%dl
  8008c4:	74 13                	je     8008d9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c6:	40                   	inc    %eax
  8008c7:	8a 10                	mov    (%eax),%dl
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f5                	jne    8008c2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb 05                	jmp    8008d9 <strchr+0x2c>
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e4:	8a 10                	mov    (%eax),%dl
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 11                	je     8008fb <strfind+0x20>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	75 06                	jne    8008f4 <strfind+0x19>
  8008ee:	eb 0b                	jmp    8008fb <strfind+0x20>
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 07                	je     8008fb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	40                   	inc    %eax
  8008f5:	8a 10                	mov    (%eax),%dl
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f5                	jne    8008f0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 30                	je     800940 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800916:	75 25                	jne    80093d <memset+0x40>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 20                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800920:	89 d3                	mov    %edx,%ebx
  800922:	c1 e3 08             	shl    $0x8,%ebx
  800925:	89 d6                	mov    %edx,%esi
  800927:	c1 e6 18             	shl    $0x18,%esi
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 10             	shl    $0x10,%eax
  80092f:	09 f0                	or     %esi,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800935:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 03                	jmp    800940 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 34                	jae    80098d <memmove+0x46>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2d                	jae    80098d <memmove+0x46>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	f6 c2 03             	test   $0x3,%dl
  800966:	75 1b                	jne    800983 <memmove+0x3c>
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 13                	jne    800983 <memmove+0x3c>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 07                	jmp    80098a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	4f                   	dec    %edi
  800984:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800987:	fd                   	std    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098a:	fc                   	cld    
  80098b:	eb 20                	jmp    8009ad <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800993:	75 13                	jne    8009a8 <memmove+0x61>
  800995:	a8 03                	test   $0x3,%al
  800997:	75 0f                	jne    8009a8 <memmove+0x61>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0a                	jne    8009a8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 05                	jmp    8009ad <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 85 ff ff ff       	call   800947 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	85 ff                	test   %edi,%edi
  8009d5:	74 32                	je     800a09 <memcmp+0x45>
		if (*s1 != *s2)
  8009d7:	8a 03                	mov    (%ebx),%al
  8009d9:	8a 0e                	mov    (%esi),%cl
  8009db:	38 c8                	cmp    %cl,%al
  8009dd:	74 19                	je     8009f8 <memcmp+0x34>
  8009df:	eb 0d                	jmp    8009ee <memcmp+0x2a>
  8009e1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009e5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009e9:	42                   	inc    %edx
  8009ea:	38 c8                	cmp    %cl,%al
  8009ec:	74 10                	je     8009fe <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ee:	0f b6 c0             	movzbl %al,%eax
  8009f1:	0f b6 c9             	movzbl %cl,%ecx
  8009f4:	29 c8                	sub    %ecx,%eax
  8009f6:	eb 16                	jmp    800a0e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	4f                   	dec    %edi
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	39 fa                	cmp    %edi,%edx
  800a00:	75 df                	jne    8009e1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 05                	jmp    800a0e <memcmp+0x4a>
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1e:	39 d0                	cmp    %edx,%eax
  800a20:	73 12                	jae    800a34 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a22:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a25:	38 08                	cmp    %cl,(%eax)
  800a27:	75 06                	jne    800a2f <memfind+0x1c>
  800a29:	eb 09                	jmp    800a34 <memfind+0x21>
  800a2b:	38 08                	cmp    %cl,(%eax)
  800a2d:	74 05                	je     800a34 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2f:	40                   	inc    %eax
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	77 f7                	ja     800a2b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	eb 01                	jmp    800a45 <strtol+0xf>
		s++;
  800a44:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	8a 02                	mov    (%edx),%al
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f9                	je     800a44 <strtol+0xe>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f5                	je     800a44 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	75 08                	jne    800a5b <strtol+0x25>
		s++;
  800a53:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
  800a59:	eb 13                	jmp    800a6e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5b:	3c 2d                	cmp    $0x2d,%al
  800a5d:	75 0a                	jne    800a69 <strtol+0x33>
		s++, neg = 1;
  800a5f:	8d 52 01             	lea    0x1(%edx),%edx
  800a62:	bf 01 00 00 00       	mov    $0x1,%edi
  800a67:	eb 05                	jmp    800a6e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	74 05                	je     800a77 <strtol+0x41>
  800a72:	83 fb 10             	cmp    $0x10,%ebx
  800a75:	75 28                	jne    800a9f <strtol+0x69>
  800a77:	8a 02                	mov    (%edx),%al
  800a79:	3c 30                	cmp    $0x30,%al
  800a7b:	75 10                	jne    800a8d <strtol+0x57>
  800a7d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a81:	75 0a                	jne    800a8d <strtol+0x57>
		s += 2, base = 16;
  800a83:	83 c2 02             	add    $0x2,%edx
  800a86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8b:	eb 12                	jmp    800a9f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 0e                	jne    800a9f <strtol+0x69>
  800a91:	3c 30                	cmp    $0x30,%al
  800a93:	75 05                	jne    800a9a <strtol+0x64>
		s++, base = 8;
  800a95:	42                   	inc    %edx
  800a96:	b3 08                	mov    $0x8,%bl
  800a98:	eb 05                	jmp    800a9f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a9a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa6:	8a 0a                	mov    (%edx),%cl
  800aa8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aab:	80 fb 09             	cmp    $0x9,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0x82>
			dig = *s - '0';
  800ab0:	0f be c9             	movsbl %cl,%ecx
  800ab3:	83 e9 30             	sub    $0x30,%ecx
  800ab6:	eb 1e                	jmp    800ad6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ab8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800abb:	80 fb 19             	cmp    $0x19,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac0:	0f be c9             	movsbl %cl,%ecx
  800ac3:	83 e9 57             	sub    $0x57,%ecx
  800ac6:	eb 0e                	jmp    800ad6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ac8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 13                	ja     800ae3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ad0:	0f be c9             	movsbl %cl,%ecx
  800ad3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad6:	39 f1                	cmp    %esi,%ecx
  800ad8:	7d 0d                	jge    800ae7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ada:	42                   	inc    %edx
  800adb:	0f af c6             	imul   %esi,%eax
  800ade:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ae1:	eb c3                	jmp    800aa6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae3:	89 c1                	mov    %eax,%ecx
  800ae5:	eb 02                	jmp    800ae9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aed:	74 05                	je     800af4 <strtol+0xbe>
		*endptr = (char *) s;
  800aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af4:	85 ff                	test   %edi,%edi
  800af6:	74 04                	je     800afc <strtol+0xc6>
  800af8:	89 c8                	mov    %ecx,%eax
  800afa:	f7 d8                	neg    %eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    
  800b01:	00 00                	add    %al,(%eax)
	...

00800b04 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 1c             	sub    $0x1c,%esp
  800b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b10:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b13:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	8b 75 14             	mov    0x14(%ebp),%esi
  800b18:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	cd 30                	int    $0x30
  800b23:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b29:	74 1c                	je     800b47 <syscall+0x43>
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 18                	jle    800b47 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b36:	68 84 15 80 00       	push   $0x801584
  800b3b:	6a 42                	push   $0x42
  800b3d:	68 a1 15 80 00       	push   $0x8015a1
  800b42:	e8 b1 04 00 00       	call   800ff8 <_panic>

	return ret;
}
  800b47:	89 d0                	mov    %edx,%eax
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	ff 75 0c             	pushl  0xc(%ebp)
  800b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	e8 92 ff ff ff       	call   800b04 <syscall>
  800b72:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	e8 6b ff ff ff       	call   800b04 <syscall>
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bac:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb6:	e8 49 ff ff ff       	call   800b04 <syscall>
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	e8 25 ff ff ff       	call   800b04 <syscall>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_yield>:

void
sys_yield(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfe:	e8 01 ff ff ff       	call   800b04 <syscall>
  800c03:	83 c4 10             	add    $0x10,%esp
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	6a 00                	push   $0x0
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c20:	b8 04 00 00 00       	mov    $0x4,%eax
  800c25:	e8 da fe ff ff       	call   800b04 <syscall>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c32:	ff 75 18             	pushl  0x18(%ebp)
  800c35:	ff 75 14             	pushl  0x14(%ebp)
  800c38:	ff 75 10             	pushl  0x10(%ebp)
  800c3b:	ff 75 0c             	pushl  0xc(%ebp)
  800c3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c41:	ba 01 00 00 00       	mov    $0x1,%edx
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	e8 b4 fe ff ff       	call   800b04 <syscall>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 0c             	pushl  0xc(%ebp)
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	ba 01 00 00 00       	mov    $0x1,%edx
  800c69:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6e:	e8 91 fe ff ff       	call   800b04 <syscall>
}
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	6a 00                	push   $0x0
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c91:	e8 6e fe ff ff       	call   800b04 <syscall>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	ff 75 0c             	pushl  0xc(%ebp)
  800ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caa:	ba 01 00 00 00       	mov    $0x1,%edx
  800caf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb4:	e8 4b fe ff ff       	call   800b04 <syscall>
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	ff 75 14             	pushl  0x14(%ebp)
  800cc6:	ff 75 10             	pushl  0x10(%ebp)
  800cc9:	ff 75 0c             	pushl  0xc(%ebp)
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd9:	e8 26 fe ff ff       	call   800b04 <syscall>
}
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce6:	6a 00                	push   $0x0
  800ce8:	6a 00                	push   $0x0
  800cea:	6a 00                	push   $0x0
  800cec:	6a 00                	push   $0x0
  800cee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf1:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfb:	e8 04 fe ff ff       	call   800b04 <syscall>
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d08:	6a 00                	push   $0x0
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	ff 75 0c             	pushl  0xc(%ebp)
  800d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
  800d19:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1e:	e8 e1 fd ff ff       	call   800b04 <syscall>
}
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    
  800d25:	00 00                	add    %al,(%eax)
	...

00800d28 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 04             	sub    $0x4,%esp
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d32:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d38:	75 14                	jne    800d4e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	68 b0 15 80 00       	push   $0x8015b0
  800d42:	6a 20                	push   $0x20
  800d44:	68 f4 16 80 00       	push   $0x8016f4
  800d49:	e8 aa 02 00 00       	call   800ff8 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d4e:	89 d8                	mov    %ebx,%eax
  800d50:	c1 e8 16             	shr    $0x16,%eax
  800d53:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d5a:	a8 01                	test   $0x1,%al
  800d5c:	74 11                	je     800d6f <pgfault+0x47>
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	c1 e8 0c             	shr    $0xc,%eax
  800d63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d6a:	f6 c4 08             	test   $0x8,%ah
  800d6d:	75 14                	jne    800d83 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	68 d4 15 80 00       	push   $0x8015d4
  800d77:	6a 24                	push   $0x24
  800d79:	68 f4 16 80 00       	push   $0x8016f4
  800d7e:	e8 75 02 00 00       	call   800ff8 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 f0 7f 00       	push   $0x7ff000
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 74 fe ff ff       	call   800c08 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 12                	jns    800dad <pgfault+0x85>
  800d9b:	50                   	push   %eax
  800d9c:	68 f8 15 80 00       	push   $0x8015f8
  800da1:	6a 32                	push   $0x32
  800da3:	68 f4 16 80 00       	push   $0x8016f4
  800da8:	e8 4b 02 00 00       	call   800ff8 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800dad:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 00 10 00 00       	push   $0x1000
  800dbb:	53                   	push   %ebx
  800dbc:	68 00 f0 7f 00       	push   $0x7ff000
  800dc1:	e8 eb fb ff ff       	call   8009b1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800dc6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dcd:	53                   	push   %ebx
  800dce:	6a 00                	push   $0x0
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 50 fe ff ff       	call   800c2c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800ddc:	83 c4 20             	add    $0x20,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	79 12                	jns    800df5 <pgfault+0xcd>
  800de3:	50                   	push   %eax
  800de4:	68 1c 16 80 00       	push   $0x80161c
  800de9:	6a 3a                	push   $0x3a
  800deb:	68 f4 16 80 00       	push   $0x8016f4
  800df0:	e8 03 02 00 00       	call   800ff8 <_panic>

	return;
}
  800df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e03:	68 28 0d 80 00       	push   $0x800d28
  800e08:	e8 33 02 00 00       	call   801040 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e0d:	ba 07 00 00 00       	mov    $0x7,%edx
  800e12:	89 d0                	mov    %edx,%eax
  800e14:	cd 30                	int    $0x30
  800e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e19:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 12                	jns    800e34 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e22:	50                   	push   %eax
  800e23:	68 ff 16 80 00       	push   $0x8016ff
  800e28:	6a 7b                	push   $0x7b
  800e2a:	68 f4 16 80 00       	push   $0x8016f4
  800e2f:	e8 c4 01 00 00       	call   800ff8 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e34:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e38:	75 1c                	jne    800e56 <fork+0x5c>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e3a:	e8 7e fd ff ff       	call   800bbd <sys_getenvid>
  800e3f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e44:	c1 e0 07             	shl    $0x7,%eax
  800e47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4c:	a3 04 20 80 00       	mov    %eax,0x802004
		// cprintf("fork child ok\n");
		return 0;
  800e51:	e9 7b 01 00 00       	jmp    800fd1 <fork+0x1d7>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	c1 e8 16             	shr    $0x16,%eax
  800e60:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e67:	a8 01                	test   $0x1,%al
  800e69:	0f 84 cd 00 00 00    	je     800f3c <fork+0x142>
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	c1 e8 0c             	shr    $0xc,%eax
  800e74:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	0f 84 b8 00 00 00    	je     800f3c <fork+0x142>
  800e84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e8b:	f6 c2 04             	test   $0x4,%dl
  800e8e:	0f 84 a8 00 00 00    	je     800f3c <fork+0x142>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800e94:	89 c6                	mov    %eax,%esi
  800e96:	c1 e6 0c             	shl    $0xc,%esi
  800e99:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800e9f:	0f 84 97 00 00 00    	je     800f3c <fork+0x142>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ea5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eac:	f6 c2 02             	test   $0x2,%dl
  800eaf:	75 0c                	jne    800ebd <fork+0xc3>
  800eb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb8:	f6 c4 08             	test   $0x8,%ah
  800ebb:	74 57                	je     800f14 <fork+0x11a>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	68 05 08 00 00       	push   $0x805
  800ec5:	56                   	push   %esi
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 5d fd ff ff       	call   800c2c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ecf:	83 c4 20             	add    $0x20,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 12                	jns    800ee8 <fork+0xee>
  800ed6:	50                   	push   %eax
  800ed7:	68 40 16 80 00       	push   $0x801640
  800edc:	6a 55                	push   $0x55
  800ede:	68 f4 16 80 00       	push   $0x8016f4
  800ee3:	e8 10 01 00 00       	call   800ff8 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	68 05 08 00 00       	push   $0x805
  800ef0:	56                   	push   %esi
  800ef1:	6a 00                	push   $0x0
  800ef3:	56                   	push   %esi
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 31 fd ff ff       	call   800c2c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800efb:	83 c4 20             	add    $0x20,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	79 3a                	jns    800f3c <fork+0x142>
  800f02:	50                   	push   %eax
  800f03:	68 40 16 80 00       	push   $0x801640
  800f08:	6a 58                	push   $0x58
  800f0a:	68 f4 16 80 00       	push   $0x8016f4
  800f0f:	e8 e4 00 00 00       	call   800ff8 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	6a 05                	push   $0x5
  800f19:	56                   	push   %esi
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 09 fd ff ff       	call   800c2c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f23:	83 c4 20             	add    $0x20,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 12                	jns    800f3c <fork+0x142>
  800f2a:	50                   	push   %eax
  800f2b:	68 40 16 80 00       	push   $0x801640
  800f30:	6a 5c                	push   $0x5c
  800f32:	68 f4 16 80 00       	push   $0x8016f4
  800f37:	e8 bc 00 00 00       	call   800ff8 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f42:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f48:	0f 85 0d ff ff ff    	jne    800e5b <fork+0x61>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	6a 07                	push   $0x7
  800f53:	68 00 f0 bf ee       	push   $0xeebff000
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 a8 fc ff ff       	call   800c08 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 15                	jns    800f7c <fork+0x182>
  800f67:	50                   	push   %eax
  800f68:	68 64 16 80 00       	push   $0x801664
  800f6d:	68 90 00 00 00       	push   $0x90
  800f72:	68 f4 16 80 00       	push   $0x8016f4
  800f77:	e8 7c 00 00 00       	call   800ff8 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	68 ac 10 80 00       	push   $0x8010ac
  800f84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f87:	e8 0c fd ff ff       	call   800c98 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 15                	jns    800fa8 <fork+0x1ae>
  800f93:	50                   	push   %eax
  800f94:	68 9c 16 80 00       	push   $0x80169c
  800f99:	68 95 00 00 00       	push   $0x95
  800f9e:	68 f4 16 80 00       	push   $0x8016f4
  800fa3:	e8 50 00 00 00       	call   800ff8 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	6a 02                	push   $0x2
  800fad:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb0:	e8 c0 fc ff ff       	call   800c75 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 15                	jns    800fd1 <fork+0x1d7>
  800fbc:	50                   	push   %eax
  800fbd:	68 c0 16 80 00       	push   $0x8016c0
  800fc2:	68 a0 00 00 00       	push   $0xa0
  800fc7:	68 f4 16 80 00       	push   $0x8016f4
  800fcc:	e8 27 00 00 00       	call   800ff8 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  800fd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <sfork>:

// Challenge!
int
sfork(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe2:	68 1c 17 80 00       	push   $0x80171c
  800fe7:	68 ad 00 00 00       	push   $0xad
  800fec:	68 f4 16 80 00       	push   $0x8016f4
  800ff1:	e8 02 00 00 00       	call   800ff8 <_panic>
	...

00800ff8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801000:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801006:	e8 b2 fb ff ff       	call   800bbd <sys_getenvid>
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	ff 75 0c             	pushl  0xc(%ebp)
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	53                   	push   %ebx
  801015:	50                   	push   %eax
  801016:	68 34 17 80 00       	push   $0x801734
  80101b:	e8 b0 f1 ff ff       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801020:	83 c4 18             	add    $0x18,%esp
  801023:	56                   	push   %esi
  801024:	ff 75 10             	pushl  0x10(%ebp)
  801027:	e8 53 f1 ff ff       	call   80017f <vcprintf>
	cprintf("\n");
  80102c:	c7 04 24 2f 13 80 00 	movl   $0x80132f,(%esp)
  801033:	e8 98 f1 ff ff       	call   8001d0 <cprintf>
  801038:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103b:	cc                   	int3   
  80103c:	eb fd                	jmp    80103b <_panic+0x43>
	...

00801040 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801046:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80104d:	75 52                	jne    8010a1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	6a 07                	push   $0x7
  801054:	68 00 f0 bf ee       	push   $0xeebff000
  801059:	6a 00                	push   $0x0
  80105b:	e8 a8 fb ff ff       	call   800c08 <sys_page_alloc>
		if (r < 0) {
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	79 12                	jns    801079 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801067:	50                   	push   %eax
  801068:	68 57 17 80 00       	push   $0x801757
  80106d:	6a 24                	push   $0x24
  80106f:	68 72 17 80 00       	push   $0x801772
  801074:	e8 7f ff ff ff       	call   800ff8 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	68 ac 10 80 00       	push   $0x8010ac
  801081:	6a 00                	push   $0x0
  801083:	e8 10 fc ff ff       	call   800c98 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 12                	jns    8010a1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80108f:	50                   	push   %eax
  801090:	68 80 17 80 00       	push   $0x801780
  801095:	6a 2a                	push   $0x2a
  801097:	68 72 17 80 00       	push   $0x801772
  80109c:	e8 57 ff ff ff       	call   800ff8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a4:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    
	...

008010ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010ad:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8010b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010b4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8010b7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8010bb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8010be:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8010c2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8010c6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8010c8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8010cb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8010cc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8010cf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010d0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010d1:	c3                   	ret    
	...

008010d4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	83 ec 10             	sub    $0x10,%esp
  8010dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010df:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8010e2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8010e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8010e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010eb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	75 2e                	jne    801120 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8010f2:	39 f1                	cmp    %esi,%ecx
  8010f4:	77 5a                	ja     801150 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010f6:	85 c9                	test   %ecx,%ecx
  8010f8:	75 0b                	jne    801105 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ff:	31 d2                	xor    %edx,%edx
  801101:	f7 f1                	div    %ecx
  801103:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801105:	31 d2                	xor    %edx,%edx
  801107:	89 f0                	mov    %esi,%eax
  801109:	f7 f1                	div    %ecx
  80110b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80110d:	89 f8                	mov    %edi,%eax
  80110f:	f7 f1                	div    %ecx
  801111:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801113:	89 f8                	mov    %edi,%eax
  801115:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801120:	39 f0                	cmp    %esi,%eax
  801122:	77 1c                	ja     801140 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801124:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801127:	83 f7 1f             	xor    $0x1f,%edi
  80112a:	75 3c                	jne    801168 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80112c:	39 f0                	cmp    %esi,%eax
  80112e:	0f 82 90 00 00 00    	jb     8011c4 <__udivdi3+0xf0>
  801134:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801137:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80113a:	0f 86 84 00 00 00    	jbe    8011c4 <__udivdi3+0xf0>
  801140:	31 f6                	xor    %esi,%esi
  801142:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801144:	89 f8                	mov    %edi,%eax
  801146:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    
  80114f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801150:	89 f2                	mov    %esi,%edx
  801152:	89 f8                	mov    %edi,%eax
  801154:	f7 f1                	div    %ecx
  801156:	89 c7                	mov    %eax,%edi
  801158:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80115a:	89 f8                	mov    %edi,%eax
  80115c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	c9                   	leave  
  801164:	c3                   	ret    
  801165:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801168:	89 f9                	mov    %edi,%ecx
  80116a:	d3 e0                	shl    %cl,%eax
  80116c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80116f:	b8 20 00 00 00       	mov    $0x20,%eax
  801174:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801176:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801179:	88 c1                	mov    %al,%cl
  80117b:	d3 ea                	shr    %cl,%edx
  80117d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801180:	09 ca                	or     %ecx,%edx
  801182:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801185:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801188:	89 f9                	mov    %edi,%ecx
  80118a:	d3 e2                	shl    %cl,%edx
  80118c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80118f:	89 f2                	mov    %esi,%edx
  801191:	88 c1                	mov    %al,%cl
  801193:	d3 ea                	shr    %cl,%edx
  801195:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801198:	89 f2                	mov    %esi,%edx
  80119a:	89 f9                	mov    %edi,%ecx
  80119c:	d3 e2                	shl    %cl,%edx
  80119e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011a1:	88 c1                	mov    %al,%cl
  8011a3:	d3 ee                	shr    %cl,%esi
  8011a5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011a7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8011aa:	89 f0                	mov    %esi,%eax
  8011ac:	89 ca                	mov    %ecx,%edx
  8011ae:	f7 75 ec             	divl   -0x14(%ebp)
  8011b1:	89 d1                	mov    %edx,%ecx
  8011b3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8011b5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011b8:	39 d1                	cmp    %edx,%ecx
  8011ba:	72 28                	jb     8011e4 <__udivdi3+0x110>
  8011bc:	74 1a                	je     8011d8 <__udivdi3+0x104>
  8011be:	89 f7                	mov    %esi,%edi
  8011c0:	31 f6                	xor    %esi,%esi
  8011c2:	eb 80                	jmp    801144 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011c4:	31 f6                	xor    %esi,%esi
  8011c6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011cb:	89 f8                	mov    %edi,%eax
  8011cd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    
  8011d6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011db:	89 f9                	mov    %edi,%ecx
  8011dd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011df:	39 c2                	cmp    %eax,%edx
  8011e1:	73 db                	jae    8011be <__udivdi3+0xea>
  8011e3:	90                   	nop
		{
		  q0--;
  8011e4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011e7:	31 f6                	xor    %esi,%esi
  8011e9:	e9 56 ff ff ff       	jmp    801144 <__udivdi3+0x70>
	...

008011f0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	83 ec 20             	sub    $0x20,%esp
  8011f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8011fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801201:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801204:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801207:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80120a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80120d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80120f:	85 ff                	test   %edi,%edi
  801211:	75 15                	jne    801228 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801213:	39 f1                	cmp    %esi,%ecx
  801215:	0f 86 99 00 00 00    	jbe    8012b4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80121b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80121d:	89 d0                	mov    %edx,%eax
  80121f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801221:	83 c4 20             	add    $0x20,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	c9                   	leave  
  801227:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801228:	39 f7                	cmp    %esi,%edi
  80122a:	0f 87 a4 00 00 00    	ja     8012d4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801230:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801233:	83 f0 1f             	xor    $0x1f,%eax
  801236:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801239:	0f 84 a1 00 00 00    	je     8012e0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80123f:	89 f8                	mov    %edi,%eax
  801241:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801244:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801246:	bf 20 00 00 00       	mov    $0x20,%edi
  80124b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80124e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801251:	89 f9                	mov    %edi,%ecx
  801253:	d3 ea                	shr    %cl,%edx
  801255:	09 c2                	or     %eax,%edx
  801257:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80125a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801260:	d3 e0                	shl    %cl,%eax
  801262:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801265:	89 f2                	mov    %esi,%edx
  801267:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801269:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80126c:	d3 e0                	shl    %cl,%eax
  80126e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801271:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801274:	89 f9                	mov    %edi,%ecx
  801276:	d3 e8                	shr    %cl,%eax
  801278:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80127a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80127c:	89 f2                	mov    %esi,%edx
  80127e:	f7 75 f0             	divl   -0x10(%ebp)
  801281:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801283:	f7 65 f4             	mull   -0xc(%ebp)
  801286:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801289:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80128b:	39 d6                	cmp    %edx,%esi
  80128d:	72 71                	jb     801300 <__umoddi3+0x110>
  80128f:	74 7f                	je     801310 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801294:	29 c8                	sub    %ecx,%eax
  801296:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801298:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80129b:	d3 e8                	shr    %cl,%eax
  80129d:	89 f2                	mov    %esi,%edx
  80129f:	89 f9                	mov    %edi,%ecx
  8012a1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8012a3:	09 d0                	or     %edx,%eax
  8012a5:	89 f2                	mov    %esi,%edx
  8012a7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012aa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012ac:	83 c4 20             	add    $0x20,%esp
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    
  8012b3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8012b4:	85 c9                	test   %ecx,%ecx
  8012b6:	75 0b                	jne    8012c3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8012b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bd:	31 d2                	xor    %edx,%edx
  8012bf:	f7 f1                	div    %ecx
  8012c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8012c3:	89 f0                	mov    %esi,%eax
  8012c5:	31 d2                	xor    %edx,%edx
  8012c7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cc:	f7 f1                	div    %ecx
  8012ce:	e9 4a ff ff ff       	jmp    80121d <__umoddi3+0x2d>
  8012d3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8012d4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012d6:	83 c4 20             	add    $0x20,%esp
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    
  8012dd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8012e0:	39 f7                	cmp    %esi,%edi
  8012e2:	72 05                	jb     8012e9 <__umoddi3+0xf9>
  8012e4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8012e7:	77 0c                	ja     8012f5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012e9:	89 f2                	mov    %esi,%edx
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	29 c8                	sub    %ecx,%eax
  8012f0:	19 fa                	sbb    %edi,%edx
  8012f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012f8:	83 c4 20             	add    $0x20,%esp
  8012fb:	5e                   	pop    %esi
  8012fc:	5f                   	pop    %edi
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    
  8012ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801300:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801303:	89 c1                	mov    %eax,%ecx
  801305:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801308:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80130b:	eb 84                	jmp    801291 <__umoddi3+0xa1>
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801310:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801313:	72 eb                	jb     801300 <__umoddi3+0x110>
  801315:	89 f2                	mov    %esi,%edx
  801317:	e9 75 ff ff ff       	jmp    801291 <__umoddi3+0xa1>
