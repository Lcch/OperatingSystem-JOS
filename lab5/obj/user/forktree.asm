
obj/user/forktree.debug:     file format elf32-i386


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
  80003e:	e8 8a 0b 00 00       	call   800bcd <sys_getenvid>
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	53                   	push   %ebx
  800047:	50                   	push   %eax
  800048:	68 c0 21 80 00       	push   $0x8021c0
  80004d:	e8 8e 01 00 00       	call   8001e0 <cprintf>

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
  800081:	e8 be 06 00 00       	call   800744 <strlen>
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 f8 02             	cmp    $0x2,%eax
  80008c:	7f 39                	jg     8000c7 <forkchild+0x57>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	53                   	push   %ebx
  800097:	68 d1 21 80 00       	push   $0x8021d1
  80009c:	6a 04                	push   $0x4
  80009e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a1:	50                   	push   %eax
  8000a2:	e8 81 06 00 00       	call   800728 <snprintf>
	if (fork() == 0) {
  8000a7:	83 c4 20             	add    $0x20,%esp
  8000aa:	e8 7b 0d 00 00       	call   800e2a <fork>
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
  8000d2:	68 d0 21 80 00       	push   $0x8021d0
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
  8000ef:	e8 d9 0a 00 00       	call   800bcd <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	29 d0                	sub    %edx,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 f6                	test   %esi,%esi
  800111:	7e 07                	jle    80011a <libmain+0x36>
		binaryname = argv[0];
  800113:	8b 03                	mov    (%ebx),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000
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
  800137:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013a:	e8 3f 11 00 00       	call   80127e <close_all>
	sys_env_destroy(0);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	6a 00                	push   $0x0
  800144:	e8 62 0a 00 00       	call   800bab <sys_env_destroy>
  800149:	83 c4 10             	add    $0x10,%esp
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    
	...

00800150 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	53                   	push   %ebx
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800163:	40                   	inc    %eax
  800164:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800166:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016b:	75 1a                	jne    800187 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	68 ff 00 00 00       	push   $0xff
  800175:	8d 43 08             	lea    0x8(%ebx),%eax
  800178:	50                   	push   %eax
  800179:	e8 e3 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  80017e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800184:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800187:	ff 43 04             	incl   0x4(%ebx)
}
  80018a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800198:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019f:	00 00 00 
	b.cnt = 0;
  8001a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ac:	ff 75 0c             	pushl  0xc(%ebp)
  8001af:	ff 75 08             	pushl  0x8(%ebp)
  8001b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b8:	50                   	push   %eax
  8001b9:	68 50 01 80 00       	push   $0x800150
  8001be:	e8 82 01 00 00       	call   800345 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 89 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  8001d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e9:	50                   	push   %eax
  8001ea:	ff 75 08             	pushl  0x8(%ebp)
  8001ed:	e8 9d ff ff ff       	call   80018f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
  8001fa:	83 ec 2c             	sub    $0x2c,%esp
  8001fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800200:	89 d6                	mov    %edx,%esi
  800202:	8b 45 08             	mov    0x8(%ebp),%eax
  800205:	8b 55 0c             	mov    0xc(%ebp),%edx
  800208:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80020e:	8b 45 10             	mov    0x10(%ebp),%eax
  800211:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800214:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800217:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80021a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800221:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800224:	72 0c                	jb     800232 <printnum+0x3e>
  800226:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800229:	76 07                	jbe    800232 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022b:	4b                   	dec    %ebx
  80022c:	85 db                	test   %ebx,%ebx
  80022e:	7f 31                	jg     800261 <printnum+0x6d>
  800230:	eb 3f                	jmp    800271 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	57                   	push   %edi
  800236:	4b                   	dec    %ebx
  800237:	53                   	push   %ebx
  800238:	50                   	push   %eax
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80023f:	ff 75 d0             	pushl  -0x30(%ebp)
  800242:	ff 75 dc             	pushl  -0x24(%ebp)
  800245:	ff 75 d8             	pushl  -0x28(%ebp)
  800248:	e8 23 1d 00 00       	call   801f70 <__udivdi3>
  80024d:	83 c4 18             	add    $0x18,%esp
  800250:	52                   	push   %edx
  800251:	50                   	push   %eax
  800252:	89 f2                	mov    %esi,%edx
  800254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800257:	e8 98 ff ff ff       	call   8001f4 <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 10                	jmp    800271 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	57                   	push   %edi
  800266:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800269:	4b                   	dec    %ebx
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	85 db                	test   %ebx,%ebx
  80026f:	7f f0                	jg     800261 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	83 ec 04             	sub    $0x4,%esp
  800278:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027b:	ff 75 d0             	pushl  -0x30(%ebp)
  80027e:	ff 75 dc             	pushl  -0x24(%ebp)
  800281:	ff 75 d8             	pushl  -0x28(%ebp)
  800284:	e8 03 1e 00 00       	call   80208c <__umoddi3>
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	0f be 80 e0 21 80 00 	movsbl 0x8021e0(%eax),%eax
  800293:	50                   	push   %eax
  800294:	ff 55 e4             	call   *-0x1c(%ebp)
  800297:	83 c4 10             	add    $0x10,%esp
}
  80029a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029d:	5b                   	pop    %ebx
  80029e:	5e                   	pop    %esi
  80029f:	5f                   	pop    %edi
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a5:	83 fa 01             	cmp    $0x1,%edx
  8002a8:	7e 0e                	jle    8002b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	8b 52 04             	mov    0x4(%edx),%edx
  8002b6:	eb 22                	jmp    8002da <getuint+0x38>
	else if (lflag)
  8002b8:	85 d2                	test   %edx,%edx
  8002ba:	74 10                	je     8002cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ca:	eb 0e                	jmp    8002da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002df:	83 fa 01             	cmp    $0x1,%edx
  8002e2:	7e 0e                	jle    8002f2 <getint+0x16>
		return va_arg(*ap, long long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	8b 52 04             	mov    0x4(%edx),%edx
  8002f0:	eb 1a                	jmp    80030c <getint+0x30>
	else if (lflag)
  8002f2:	85 d2                	test   %edx,%edx
  8002f4:	74 0c                	je     800302 <getint+0x26>
		return va_arg(*ap, long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	99                   	cltd   
  800300:	eb 0a                	jmp    80030c <getint+0x30>
	else
		return va_arg(*ap, int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	99                   	cltd   
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800314:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800317:	8b 10                	mov    (%eax),%edx
  800319:	3b 50 04             	cmp    0x4(%eax),%edx
  80031c:	73 08                	jae    800326 <sprintputch+0x18>
		*b->buf++ = ch;
  80031e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800321:	88 0a                	mov    %cl,(%edx)
  800323:	42                   	inc    %edx
  800324:	89 10                	mov    %edx,(%eax)
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800331:	50                   	push   %eax
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	ff 75 0c             	pushl  0xc(%ebp)
  800338:	ff 75 08             	pushl  0x8(%ebp)
  80033b:	e8 05 00 00 00       	call   800345 <vprintfmt>
	va_end(ap);
  800340:	83 c4 10             	add    $0x10,%esp
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 2c             	sub    $0x2c,%esp
  80034e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800351:	8b 75 10             	mov    0x10(%ebp),%esi
  800354:	eb 13                	jmp    800369 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800356:	85 c0                	test   %eax,%eax
  800358:	0f 84 6d 03 00 00    	je     8006cb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	57                   	push   %edi
  800362:	50                   	push   %eax
  800363:	ff 55 08             	call   *0x8(%ebp)
  800366:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	0f b6 06             	movzbl (%esi),%eax
  80036c:	46                   	inc    %esi
  80036d:	83 f8 25             	cmp    $0x25,%eax
  800370:	75 e4                	jne    800356 <vprintfmt+0x11>
  800372:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800376:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80037d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800384:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	eb 28                	jmp    8003ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800394:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800398:	eb 20                	jmp    8003ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003a0:	eb 18                	jmp    8003ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ab:	eb 0d                	jmp    8003ba <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8a 06                	mov    (%esi),%al
  8003bc:	0f b6 d0             	movzbl %al,%edx
  8003bf:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 e0 02 00 00    	ja     8006ad <vprintfmt+0x368>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d7:	83 ea 30             	sub    $0x30,%edx
  8003da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003dd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003e0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e3:	83 fa 09             	cmp    $0x9,%edx
  8003e6:	77 44                	ja     80042c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	89 de                	mov    %ebx,%esi
  8003ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ee:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003f1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003f5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003fb:	83 fb 09             	cmp    $0x9,%ebx
  8003fe:	76 ed                	jbe    8003ed <vprintfmt+0xa8>
  800400:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800403:	eb 29                	jmp    80042e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800415:	eb 17                	jmp    80042e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041b:	78 85                	js     8003a2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	89 de                	mov    %ebx,%esi
  80041f:	eb 99                	jmp    8003ba <vprintfmt+0x75>
  800421:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800423:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80042a:	eb 8e                	jmp    8003ba <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800432:	79 86                	jns    8003ba <vprintfmt+0x75>
  800434:	e9 74 ff ff ff       	jmp    8003ad <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800439:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
  80043c:	e9 79 ff ff ff       	jmp    8003ba <vprintfmt+0x75>
  800441:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	57                   	push   %edi
  800451:	ff 30                	pushl  (%eax)
  800453:	ff 55 08             	call   *0x8(%ebp)
			break;
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045c:	e9 08 ff ff ff       	jmp    800369 <vprintfmt+0x24>
  800461:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	85 c0                	test   %eax,%eax
  800471:	79 02                	jns    800475 <vprintfmt+0x130>
  800473:	f7 d8                	neg    %eax
  800475:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800477:	83 f8 0f             	cmp    $0xf,%eax
  80047a:	7f 0b                	jg     800487 <vprintfmt+0x142>
  80047c:	8b 04 85 80 24 80 00 	mov    0x802480(,%eax,4),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	75 1a                	jne    8004a1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800487:	52                   	push   %edx
  800488:	68 f8 21 80 00       	push   $0x8021f8
  80048d:	57                   	push   %edi
  80048e:	ff 75 08             	pushl  0x8(%ebp)
  800491:	e8 92 fe ff ff       	call   800328 <printfmt>
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049c:	e9 c8 fe ff ff       	jmp    800369 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004a1:	50                   	push   %eax
  8004a2:	68 35 27 80 00       	push   $0x802735
  8004a7:	57                   	push   %edi
  8004a8:	ff 75 08             	pushl  0x8(%ebp)
  8004ab:	e8 78 fe ff ff       	call   800328 <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004b6:	e9 ae fe ff ff       	jmp    800369 <vprintfmt+0x24>
  8004bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004be:	89 de                	mov    %ebx,%esi
  8004c0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	75 07                	jne    8004df <vprintfmt+0x19a>
				p = "(null)";
  8004d8:	c7 45 d0 f1 21 80 00 	movl   $0x8021f1,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004df:	85 db                	test   %ebx,%ebx
  8004e1:	7e 42                	jle    800525 <vprintfmt+0x1e0>
  8004e3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004e7:	74 3c                	je     800525 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	51                   	push   %ecx
  8004ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f0:	e8 6f 02 00 00       	call   800764 <strnlen>
  8004f5:	29 c3                	sub    %eax,%ebx
  8004f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	85 db                	test   %ebx,%ebx
  8004ff:	7e 24                	jle    800525 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800501:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800505:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800508:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	57                   	push   %edi
  80050f:	53                   	push   %ebx
  800510:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	4e                   	dec    %esi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 f6                	test   %esi,%esi
  800519:	7f f0                	jg     80050b <vprintfmt+0x1c6>
  80051b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80051e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800525:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800528:	0f be 02             	movsbl (%edx),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	75 47                	jne    800576 <vprintfmt+0x231>
  80052f:	eb 37                	jmp    800568 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800535:	74 16                	je     80054d <vprintfmt+0x208>
  800537:	8d 50 e0             	lea    -0x20(%eax),%edx
  80053a:	83 fa 5e             	cmp    $0x5e,%edx
  80053d:	76 0e                	jbe    80054d <vprintfmt+0x208>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	57                   	push   %edi
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0b                	jmp    800558 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	57                   	push   %edi
  800551:	50                   	push   %eax
  800552:	ff 55 08             	call   *0x8(%ebp)
  800555:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800558:	ff 4d e4             	decl   -0x1c(%ebp)
  80055b:	0f be 03             	movsbl (%ebx),%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 03                	je     800565 <vprintfmt+0x220>
  800562:	43                   	inc    %ebx
  800563:	eb 1b                	jmp    800580 <vprintfmt+0x23b>
  800565:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800568:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056c:	7f 1e                	jg     80058c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800571:	e9 f3 fd ff ff       	jmp    800369 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800579:	43                   	inc    %ebx
  80057a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80057d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800580:	85 f6                	test   %esi,%esi
  800582:	78 ad                	js     800531 <vprintfmt+0x1ec>
  800584:	4e                   	dec    %esi
  800585:	79 aa                	jns    800531 <vprintfmt+0x1ec>
  800587:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80058a:	eb dc                	jmp    800568 <vprintfmt+0x223>
  80058c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	57                   	push   %edi
  800593:	6a 20                	push   $0x20
  800595:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800598:	4b                   	dec    %ebx
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	7f ef                	jg     80058f <vprintfmt+0x24a>
  8005a0:	e9 c4 fd ff ff       	jmp    800369 <vprintfmt+0x24>
  8005a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a8:	89 ca                	mov    %ecx,%edx
  8005aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ad:	e8 2a fd ff ff       	call   8002dc <getint>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	78 0a                	js     8005c4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bf:	e9 b0 00 00 00       	jmp    800674 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	57                   	push   %edi
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005cd:	f7 db                	neg    %ebx
  8005cf:	83 d6 00             	adc    $0x0,%esi
  8005d2:	f7 de                	neg    %esi
  8005d4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dc:	e9 93 00 00 00       	jmp    800674 <vprintfmt+0x32f>
  8005e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 b4 fc ff ff       	call   8002a2 <getuint>
  8005ee:	89 c3                	mov    %eax,%ebx
  8005f0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f7:	eb 7b                	jmp    800674 <vprintfmt+0x32f>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 d6 fc ff ff       	call   8002dc <getint>
  800606:	89 c3                	mov    %eax,%ebx
  800608:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80060a:	85 d2                	test   %edx,%edx
  80060c:	78 07                	js     800615 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80060e:	b8 08 00 00 00       	mov    $0x8,%eax
  800613:	eb 5f                	jmp    800674 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	57                   	push   %edi
  800619:	6a 2d                	push   $0x2d
  80061b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80061e:	f7 db                	neg    %ebx
  800620:	83 d6 00             	adc    $0x0,%esi
  800623:	f7 de                	neg    %esi
  800625:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800628:	b8 08 00 00 00       	mov    $0x8,%eax
  80062d:	eb 45                	jmp    800674 <vprintfmt+0x32f>
  80062f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	6a 30                	push   $0x30
  800638:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	57                   	push   %edi
  80063f:	6a 78                	push   $0x78
  800641:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064d:	8b 18                	mov    (%eax),%ebx
  80064f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800657:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x32f>
  80065e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800661:	89 ca                	mov    %ecx,%edx
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 37 fc ff ff       	call   8002a2 <getuint>
  80066b:	89 c3                	mov    %eax,%ebx
  80066d:	89 d6                	mov    %edx,%esi
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800674:	83 ec 0c             	sub    $0xc,%esp
  800677:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80067b:	52                   	push   %edx
  80067c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80067f:	50                   	push   %eax
  800680:	56                   	push   %esi
  800681:	53                   	push   %ebx
  800682:	89 fa                	mov    %edi,%edx
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	e8 68 fb ff ff       	call   8001f4 <printnum>
			break;
  80068c:	83 c4 20             	add    $0x20,%esp
  80068f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800692:	e9 d2 fc ff ff       	jmp    800369 <vprintfmt+0x24>
  800697:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	57                   	push   %edi
  80069e:	52                   	push   %edx
  80069f:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a8:	e9 bc fc ff ff       	jmp    800369 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	57                   	push   %edi
  8006b1:	6a 25                	push   $0x25
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 02                	jmp    8006bd <vprintfmt+0x378>
  8006bb:	89 c6                	mov    %eax,%esi
  8006bd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006c0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c4:	75 f5                	jne    8006bb <vprintfmt+0x376>
  8006c6:	e9 9e fc ff ff       	jmp    800369 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 18             	sub    $0x18,%esp
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 26                	je     80071a <vsnprintf+0x47>
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	7e 29                	jle    800721 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 0e 03 80 00       	push   $0x80030e
  800707:	e8 39 fc ff ff       	call   800345 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	eb 0c                	jmp    800726 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071f:	eb 05                	jmp    800726 <vsnprintf+0x53>
  800721:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800731:	50                   	push   %eax
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	ff 75 08             	pushl  0x8(%ebp)
  80073b:	e8 93 ff ff ff       	call   8006d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    
	...

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3a 00             	cmpb   $0x0,(%edx)
  80074d:	74 0e                	je     80075d <strlen+0x19>
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800754:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800759:	75 f9                	jne    800754 <strlen+0x10>
  80075b:	eb 05                	jmp    800762 <strlen+0x1e>
  80075d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 17                	je     800788 <strnlen+0x24>
  800771:	80 39 00             	cmpb   $0x0,(%ecx)
  800774:	74 19                	je     80078f <strnlen+0x2b>
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80077b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	39 d0                	cmp    %edx,%eax
  80077e:	74 14                	je     800794 <strnlen+0x30>
  800780:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800784:	75 f5                	jne    80077b <strnlen+0x17>
  800786:	eb 0c                	jmp    800794 <strnlen+0x30>
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	eb 05                	jmp    800794 <strnlen+0x30>
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ab:	42                   	inc    %edx
  8007ac:	84 c9                	test   %cl,%cl
  8007ae:	75 f5                	jne    8007a5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ba:	53                   	push   %ebx
  8007bb:	e8 84 ff ff ff       	call   800744 <strlen>
  8007c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c7 ff ff ff       	call   800796 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	85 f6                	test   %esi,%esi
  8007e6:	74 15                	je     8007fd <strncpy+0x27>
  8007e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007ed:	8a 1a                	mov    (%edx),%bl
  8007ef:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	41                   	inc    %ecx
  8007f9:	39 ce                	cmp    %ecx,%esi
  8007fb:	77 f0                	ja     8007ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	57                   	push   %edi
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 f6                	test   %esi,%esi
  800812:	74 32                	je     800846 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800814:	83 fe 01             	cmp    $0x1,%esi
  800817:	74 22                	je     80083b <strlcpy+0x3a>
  800819:	8a 0b                	mov    (%ebx),%cl
  80081b:	84 c9                	test   %cl,%cl
  80081d:	74 20                	je     80083f <strlcpy+0x3e>
  80081f:	89 f8                	mov    %edi,%eax
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800826:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800829:	88 08                	mov    %cl,(%eax)
  80082b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082c:	39 f2                	cmp    %esi,%edx
  80082e:	74 11                	je     800841 <strlcpy+0x40>
  800830:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800834:	42                   	inc    %edx
  800835:	84 c9                	test   %cl,%cl
  800837:	75 f0                	jne    800829 <strlcpy+0x28>
  800839:	eb 06                	jmp    800841 <strlcpy+0x40>
  80083b:	89 f8                	mov    %edi,%eax
  80083d:	eb 02                	jmp    800841 <strlcpy+0x40>
  80083f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800841:	c6 00 00             	movb   $0x0,(%eax)
  800844:	eb 02                	jmp    800848 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800846:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800848:	29 f8                	sub    %edi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5f                   	pop    %edi
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800858:	8a 01                	mov    (%ecx),%al
  80085a:	84 c0                	test   %al,%al
  80085c:	74 10                	je     80086e <strcmp+0x1f>
  80085e:	3a 02                	cmp    (%edx),%al
  800860:	75 0c                	jne    80086e <strcmp+0x1f>
		p++, q++;
  800862:	41                   	inc    %ecx
  800863:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800864:	8a 01                	mov    (%ecx),%al
  800866:	84 c0                	test   %al,%al
  800868:	74 04                	je     80086e <strcmp+0x1f>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	74 f4                	je     800862 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 c0             	movzbl %al,%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 55 08             	mov    0x8(%ebp),%edx
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800885:	85 c0                	test   %eax,%eax
  800887:	74 1b                	je     8008a4 <strncmp+0x2c>
  800889:	8a 1a                	mov    (%edx),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	74 24                	je     8008b3 <strncmp+0x3b>
  80088f:	3a 19                	cmp    (%ecx),%bl
  800891:	75 20                	jne    8008b3 <strncmp+0x3b>
  800893:	48                   	dec    %eax
  800894:	74 15                	je     8008ab <strncmp+0x33>
		n--, p++, q++;
  800896:	42                   	inc    %edx
  800897:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800898:	8a 1a                	mov    (%edx),%bl
  80089a:	84 db                	test   %bl,%bl
  80089c:	74 15                	je     8008b3 <strncmp+0x3b>
  80089e:	3a 19                	cmp    (%ecx),%bl
  8008a0:	74 f1                	je     800893 <strncmp+0x1b>
  8008a2:	eb 0f                	jmp    8008b3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x38>
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 02             	movzbl (%edx),%eax
  8008b6:	0f b6 11             	movzbl (%ecx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
  8008bb:	eb f3                	jmp    8008b0 <strncmp+0x38>

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c6:	8a 10                	mov    (%eax),%dl
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	74 18                	je     8008e4 <strchr+0x27>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	75 06                	jne    8008d6 <strchr+0x19>
  8008d0:	eb 17                	jmp    8008e9 <strchr+0x2c>
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 13                	je     8008e9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	40                   	inc    %eax
  8008d7:	8a 10                	mov    (%eax),%dl
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f5                	jne    8008d2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	eb 05                	jmp    8008e9 <strchr+0x2c>
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f4:	8a 10                	mov    (%eax),%dl
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	74 11                	je     80090b <strfind+0x20>
		if (*s == c)
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	75 06                	jne    800904 <strfind+0x19>
  8008fe:	eb 0b                	jmp    80090b <strfind+0x20>
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 07                	je     80090b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 7d 08             	mov    0x8(%ebp),%edi
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091c:	85 c9                	test   %ecx,%ecx
  80091e:	74 30                	je     800950 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800920:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800926:	75 25                	jne    80094d <memset+0x40>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 20                	jne    80094d <memset+0x40>
		c &= 0xFF;
  80092d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800930:	89 d3                	mov    %edx,%ebx
  800932:	c1 e3 08             	shl    $0x8,%ebx
  800935:	89 d6                	mov    %edx,%esi
  800937:	c1 e6 18             	shl    $0x18,%esi
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	c1 e0 10             	shl    $0x10,%eax
  80093f:	09 f0                	or     %esi,%eax
  800941:	09 d0                	or     %edx,%eax
  800943:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800945:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800948:	fc                   	cld    
  800949:	f3 ab                	rep stos %eax,%es:(%edi)
  80094b:	eb 03                	jmp    800950 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	fc                   	cld    
  80094e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800950:	89 f8                	mov    %edi,%eax
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800965:	39 c6                	cmp    %eax,%esi
  800967:	73 34                	jae    80099d <memmove+0x46>
  800969:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096c:	39 d0                	cmp    %edx,%eax
  80096e:	73 2d                	jae    80099d <memmove+0x46>
		s += n;
		d += n;
  800970:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 1b                	jne    800993 <memmove+0x3c>
  800978:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097e:	75 13                	jne    800993 <memmove+0x3c>
  800980:	f6 c1 03             	test   $0x3,%cl
  800983:	75 0e                	jne    800993 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800985:	83 ef 04             	sub    $0x4,%edi
  800988:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098e:	fd                   	std    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 07                	jmp    80099a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800993:	4f                   	dec    %edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 20                	jmp    8009bd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a3:	75 13                	jne    8009b8 <memmove+0x61>
  8009a5:	a8 03                	test   $0x3,%al
  8009a7:	75 0f                	jne    8009b8 <memmove+0x61>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 0a                	jne    8009b8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 05                	jmp    8009bd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c4:	ff 75 10             	pushl  0x10(%ebp)
  8009c7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ca:	ff 75 08             	pushl  0x8(%ebp)
  8009cd:	e8 85 ff ff ff       	call   800957 <memmove>
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	85 ff                	test   %edi,%edi
  8009e5:	74 32                	je     800a19 <memcmp+0x45>
		if (*s1 != *s2)
  8009e7:	8a 03                	mov    (%ebx),%al
  8009e9:	8a 0e                	mov    (%esi),%cl
  8009eb:	38 c8                	cmp    %cl,%al
  8009ed:	74 19                	je     800a08 <memcmp+0x34>
  8009ef:	eb 0d                	jmp    8009fe <memcmp+0x2a>
  8009f1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009f5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009f9:	42                   	inc    %edx
  8009fa:	38 c8                	cmp    %cl,%al
  8009fc:	74 10                	je     800a0e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009fe:	0f b6 c0             	movzbl %al,%eax
  800a01:	0f b6 c9             	movzbl %cl,%ecx
  800a04:	29 c8                	sub    %ecx,%eax
  800a06:	eb 16                	jmp    800a1e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	4f                   	dec    %edi
  800a09:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0e:	39 fa                	cmp    %edi,%edx
  800a10:	75 df                	jne    8009f1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 05                	jmp    800a1e <memcmp+0x4a>
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2e:	39 d0                	cmp    %edx,%eax
  800a30:	73 12                	jae    800a44 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a32:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a35:	38 08                	cmp    %cl,(%eax)
  800a37:	75 06                	jne    800a3f <memfind+0x1c>
  800a39:	eb 09                	jmp    800a44 <memfind+0x21>
  800a3b:	38 08                	cmp    %cl,(%eax)
  800a3d:	74 05                	je     800a44 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3f:	40                   	inc    %eax
  800a40:	39 c2                	cmp    %eax,%edx
  800a42:	77 f7                	ja     800a3b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 01                	jmp    800a55 <strtol+0xf>
		s++;
  800a54:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	8a 02                	mov    (%edx),%al
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f9                	je     800a54 <strtol+0xe>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f5                	je     800a54 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	75 08                	jne    800a6b <strtol+0x25>
		s++;
  800a63:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
  800a69:	eb 13                	jmp    800a7e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	75 0a                	jne    800a79 <strtol+0x33>
		s++, neg = 1;
  800a6f:	8d 52 01             	lea    0x1(%edx),%edx
  800a72:	bf 01 00 00 00       	mov    $0x1,%edi
  800a77:	eb 05                	jmp    800a7e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	74 05                	je     800a87 <strtol+0x41>
  800a82:	83 fb 10             	cmp    $0x10,%ebx
  800a85:	75 28                	jne    800aaf <strtol+0x69>
  800a87:	8a 02                	mov    (%edx),%al
  800a89:	3c 30                	cmp    $0x30,%al
  800a8b:	75 10                	jne    800a9d <strtol+0x57>
  800a8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a91:	75 0a                	jne    800a9d <strtol+0x57>
		s += 2, base = 16;
  800a93:	83 c2 02             	add    $0x2,%edx
  800a96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9b:	eb 12                	jmp    800aaf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 0e                	jne    800aaf <strtol+0x69>
  800aa1:	3c 30                	cmp    $0x30,%al
  800aa3:	75 05                	jne    800aaa <strtol+0x64>
		s++, base = 8;
  800aa5:	42                   	inc    %edx
  800aa6:	b3 08                	mov    $0x8,%bl
  800aa8:	eb 05                	jmp    800aaf <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aaa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab6:	8a 0a                	mov    (%edx),%cl
  800ab8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abb:	80 fb 09             	cmp    $0x9,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0x82>
			dig = *s - '0';
  800ac0:	0f be c9             	movsbl %cl,%ecx
  800ac3:	83 e9 30             	sub    $0x30,%ecx
  800ac6:	eb 1e                	jmp    800ae6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ac8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad0:	0f be c9             	movsbl %cl,%ecx
  800ad3:	83 e9 57             	sub    $0x57,%ecx
  800ad6:	eb 0e                	jmp    800ae6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ad8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 13                	ja     800af3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ae0:	0f be c9             	movsbl %cl,%ecx
  800ae3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae6:	39 f1                	cmp    %esi,%ecx
  800ae8:	7d 0d                	jge    800af7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aea:	42                   	inc    %edx
  800aeb:	0f af c6             	imul   %esi,%eax
  800aee:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800af1:	eb c3                	jmp    800ab6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af3:	89 c1                	mov    %eax,%ecx
  800af5:	eb 02                	jmp    800af9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 05                	je     800b04 <strtol+0xbe>
		*endptr = (char *) s;
  800aff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b02:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b04:	85 ff                	test   %edi,%edi
  800b06:	74 04                	je     800b0c <strtol+0xc6>
  800b08:	89 c8                	mov    %ecx,%eax
  800b0a:	f7 d8                	neg    %eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    
  800b11:	00 00                	add    %al,(%eax)
	...

00800b14 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 1c             	sub    $0x1c,%esp
  800b1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b20:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b23:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	8b 75 14             	mov    0x14(%ebp),%esi
  800b28:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	cd 30                	int    $0x30
  800b33:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b35:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b39:	74 1c                	je     800b57 <syscall+0x43>
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 18                	jle    800b57 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b46:	68 df 24 80 00       	push   $0x8024df
  800b4b:	6a 42                	push   $0x42
  800b4d:	68 fc 24 80 00       	push   $0x8024fc
  800b52:	e8 d1 11 00 00       	call   801d28 <_panic>

	return ret;
}
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	ff 75 0c             	pushl  0xc(%ebp)
  800b70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	e8 92 ff ff ff       	call   800b14 <syscall>
  800b82:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	e8 6b ff ff ff       	call   800b14 <syscall>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbc:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	e8 49 ff ff ff       	call   800b14 <syscall>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bea:	e8 25 ff ff ff       	call   800b14 <syscall>
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <sys_yield>:

void
sys_yield(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	6a 00                	push   $0x0
  800bff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	e8 01 ff ff ff       	call   800b14 <syscall>
  800c13:	83 c4 10             	add    $0x10,%esp
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c1e:	6a 00                	push   $0x0
  800c20:	6a 00                	push   $0x0
  800c22:	ff 75 10             	pushl  0x10(%ebp)
  800c25:	ff 75 0c             	pushl  0xc(%ebp)
  800c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c30:	b8 04 00 00 00       	mov    $0x4,%eax
  800c35:	e8 da fe ff ff       	call   800b14 <syscall>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c42:	ff 75 18             	pushl  0x18(%ebp)
  800c45:	ff 75 14             	pushl  0x14(%ebp)
  800c48:	ff 75 10             	pushl  0x10(%ebp)
  800c4b:	ff 75 0c             	pushl  0xc(%ebp)
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	ba 01 00 00 00       	mov    $0x1,%edx
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	e8 b4 fe ff ff       	call   800b14 <syscall>
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	ff 75 0c             	pushl  0xc(%ebp)
  800c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c74:	ba 01 00 00 00       	mov    $0x1,%edx
  800c79:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7e:	e8 91 fe ff ff       	call   800b14 <syscall>
}
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c8b:	6a 00                	push   $0x0
  800c8d:	6a 00                	push   $0x0
  800c8f:	6a 00                	push   $0x0
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c97:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca1:	e8 6e fe ff ff       	call   800b14 <syscall>
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	6a 00                	push   $0x0
  800cb4:	ff 75 0c             	pushl  0xc(%ebp)
  800cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cba:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc4:	e8 4b fe ff ff       	call   800b14 <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	ff 75 0c             	pushl  0xc(%ebp)
  800cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdd:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce7:	e8 28 fe ff ff       	call   800b14 <syscall>
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cf4:	6a 00                	push   $0x0
  800cf6:	ff 75 14             	pushl  0x14(%ebp)
  800cf9:	ff 75 10             	pushl  0x10(%ebp)
  800cfc:	ff 75 0c             	pushl  0xc(%ebp)
  800cff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0c:	e8 03 fe ff ff       	call   800b14 <syscall>
}
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d19:	6a 00                	push   $0x0
  800d1b:	6a 00                	push   $0x0
  800d1d:	6a 00                	push   $0x0
  800d1f:	6a 00                	push   $0x0
  800d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d24:	ba 01 00 00 00       	mov    $0x1,%edx
  800d29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2e:	e8 e1 fd ff ff       	call   800b14 <syscall>
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d3b:	6a 00                	push   $0x0
  800d3d:	6a 00                	push   $0x0
  800d3f:	6a 00                	push   $0x0
  800d41:	ff 75 0c             	pushl  0xc(%ebp)
  800d44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d47:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d51:	e8 be fd ff ff       	call   800b14 <syscall>
}
  800d56:	c9                   	leave  
  800d57:	c3                   	ret    

00800d58 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d62:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d68:	75 14                	jne    800d7e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 0c 25 80 00       	push   $0x80250c
  800d72:	6a 20                	push   $0x20
  800d74:	68 50 26 80 00       	push   $0x802650
  800d79:	e8 aa 0f 00 00       	call   801d28 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d7e:	89 d8                	mov    %ebx,%eax
  800d80:	c1 e8 16             	shr    $0x16,%eax
  800d83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d8a:	a8 01                	test   $0x1,%al
  800d8c:	74 11                	je     800d9f <pgfault+0x47>
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	c1 e8 0c             	shr    $0xc,%eax
  800d93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d9a:	f6 c4 08             	test   $0x8,%ah
  800d9d:	75 14                	jne    800db3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 30 25 80 00       	push   $0x802530
  800da7:	6a 24                	push   $0x24
  800da9:	68 50 26 80 00       	push   $0x802650
  800dae:	e8 75 0f 00 00       	call   801d28 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	6a 07                	push   $0x7
  800db8:	68 00 f0 7f 00       	push   $0x7ff000
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 54 fe ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	79 12                	jns    800ddd <pgfault+0x85>
  800dcb:	50                   	push   %eax
  800dcc:	68 54 25 80 00       	push   $0x802554
  800dd1:	6a 32                	push   $0x32
  800dd3:	68 50 26 80 00       	push   $0x802650
  800dd8:	e8 4b 0f 00 00       	call   801d28 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800ddd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	68 00 10 00 00       	push   $0x1000
  800deb:	53                   	push   %ebx
  800dec:	68 00 f0 7f 00       	push   $0x7ff000
  800df1:	e8 cb fb ff ff       	call   8009c1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800df6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dfd:	53                   	push   %ebx
  800dfe:	6a 00                	push   $0x0
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	6a 00                	push   $0x0
  800e07:	e8 30 fe ff ff       	call   800c3c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e0c:	83 c4 20             	add    $0x20,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	79 12                	jns    800e25 <pgfault+0xcd>
  800e13:	50                   	push   %eax
  800e14:	68 78 25 80 00       	push   $0x802578
  800e19:	6a 3a                	push   $0x3a
  800e1b:	68 50 26 80 00       	push   $0x802650
  800e20:	e8 03 0f 00 00       	call   801d28 <_panic>

	return;
}
  800e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e33:	68 58 0d 80 00       	push   $0x800d58
  800e38:	e8 33 0f 00 00       	call   801d70 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e3d:	ba 07 00 00 00       	mov    $0x7,%edx
  800e42:	89 d0                	mov    %edx,%eax
  800e44:	cd 30                	int    $0x30
  800e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e49:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	79 12                	jns    800e64 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e52:	50                   	push   %eax
  800e53:	68 5b 26 80 00       	push   $0x80265b
  800e58:	6a 7f                	push   $0x7f
  800e5a:	68 50 26 80 00       	push   $0x802650
  800e5f:	e8 c4 0e 00 00       	call   801d28 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e68:	75 25                	jne    800e8f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e6a:	e8 5e fd ff ff       	call   800bcd <sys_getenvid>
  800e6f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e7b:	c1 e0 07             	shl    $0x7,%eax
  800e7e:	29 d0                	sub    %edx,%eax
  800e80:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e85:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800e8a:	e9 be 01 00 00       	jmp    80104d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	c1 e8 16             	shr    $0x16,%eax
  800e99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea0:	a8 01                	test   $0x1,%al
  800ea2:	0f 84 10 01 00 00    	je     800fb8 <fork+0x18e>
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	c1 e8 0c             	shr    $0xc,%eax
  800ead:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	0f 84 fb 00 00 00    	je     800fb8 <fork+0x18e>
  800ebd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec4:	f6 c2 04             	test   $0x4,%dl
  800ec7:	0f 84 eb 00 00 00    	je     800fb8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ecd:	89 c6                	mov    %eax,%esi
  800ecf:	c1 e6 0c             	shl    $0xc,%esi
  800ed2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ed8:	0f 84 da 00 00 00    	je     800fb8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800ede:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee5:	f6 c6 04             	test   $0x4,%dh
  800ee8:	74 37                	je     800f21 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800eea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef9:	50                   	push   %eax
  800efa:	56                   	push   %esi
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	6a 00                	push   $0x0
  800eff:	e8 38 fd ff ff       	call   800c3c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f04:	83 c4 20             	add    $0x20,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	0f 89 a9 00 00 00    	jns    800fb8 <fork+0x18e>
  800f0f:	50                   	push   %eax
  800f10:	68 9c 25 80 00       	push   $0x80259c
  800f15:	6a 54                	push   $0x54
  800f17:	68 50 26 80 00       	push   $0x802650
  800f1c:	e8 07 0e 00 00       	call   801d28 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f21:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f28:	f6 c2 02             	test   $0x2,%dl
  800f2b:	75 0c                	jne    800f39 <fork+0x10f>
  800f2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f34:	f6 c4 08             	test   $0x8,%ah
  800f37:	74 57                	je     800f90 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	68 05 08 00 00       	push   $0x805
  800f41:	56                   	push   %esi
  800f42:	57                   	push   %edi
  800f43:	56                   	push   %esi
  800f44:	6a 00                	push   $0x0
  800f46:	e8 f1 fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f4b:	83 c4 20             	add    $0x20,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	79 12                	jns    800f64 <fork+0x13a>
  800f52:	50                   	push   %eax
  800f53:	68 9c 25 80 00       	push   $0x80259c
  800f58:	6a 59                	push   $0x59
  800f5a:	68 50 26 80 00       	push   $0x802650
  800f5f:	e8 c4 0d 00 00       	call   801d28 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	68 05 08 00 00       	push   $0x805
  800f6c:	56                   	push   %esi
  800f6d:	6a 00                	push   $0x0
  800f6f:	56                   	push   %esi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 c5 fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 3a                	jns    800fb8 <fork+0x18e>
  800f7e:	50                   	push   %eax
  800f7f:	68 9c 25 80 00       	push   $0x80259c
  800f84:	6a 5c                	push   $0x5c
  800f86:	68 50 26 80 00       	push   $0x802650
  800f8b:	e8 98 0d 00 00       	call   801d28 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	6a 05                	push   $0x5
  800f95:	56                   	push   %esi
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 9d fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 12                	jns    800fb8 <fork+0x18e>
  800fa6:	50                   	push   %eax
  800fa7:	68 9c 25 80 00       	push   $0x80259c
  800fac:	6a 60                	push   $0x60
  800fae:	68 50 26 80 00       	push   $0x802650
  800fb3:	e8 70 0d 00 00       	call   801d28 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fb8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbe:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fc4:	0f 85 ca fe ff ff    	jne    800e94 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	6a 07                	push   $0x7
  800fcf:	68 00 f0 bf ee       	push   $0xeebff000
  800fd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd7:	e8 3c fc ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 15                	jns    800ff8 <fork+0x1ce>
  800fe3:	50                   	push   %eax
  800fe4:	68 c0 25 80 00       	push   $0x8025c0
  800fe9:	68 94 00 00 00       	push   $0x94
  800fee:	68 50 26 80 00       	push   $0x802650
  800ff3:	e8 30 0d 00 00       	call   801d28 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	68 dc 1d 80 00       	push   $0x801ddc
  801000:	ff 75 e4             	pushl  -0x1c(%ebp)
  801003:	e8 c3 fc ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 15                	jns    801024 <fork+0x1fa>
  80100f:	50                   	push   %eax
  801010:	68 f8 25 80 00       	push   $0x8025f8
  801015:	68 99 00 00 00       	push   $0x99
  80101a:	68 50 26 80 00       	push   $0x802650
  80101f:	e8 04 0d 00 00       	call   801d28 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	6a 02                	push   $0x2
  801029:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102c:	e8 54 fc ff ff       	call   800c85 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	79 15                	jns    80104d <fork+0x223>
  801038:	50                   	push   %eax
  801039:	68 1c 26 80 00       	push   $0x80261c
  80103e:	68 a4 00 00 00       	push   $0xa4
  801043:	68 50 26 80 00       	push   $0x802650
  801048:	e8 db 0c 00 00       	call   801d28 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80104d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <sfork>:

// Challenge!
int
sfork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105e:	68 78 26 80 00       	push   $0x802678
  801063:	68 b1 00 00 00       	push   $0xb1
  801068:	68 50 26 80 00       	push   $0x802650
  80106d:	e8 b6 0c 00 00       	call   801d28 <_panic>
	...

00801074 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	05 00 00 00 30       	add    $0x30000000,%eax
  80107f:	c1 e8 0c             	shr    $0xc,%eax
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801087:	ff 75 08             	pushl  0x8(%ebp)
  80108a:	e8 e5 ff ff ff       	call   801074 <fd2num>
  80108f:	83 c4 04             	add    $0x4,%esp
  801092:	05 20 00 0d 00       	add    $0xd0020,%eax
  801097:	c1 e0 0c             	shl    $0xc,%eax
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	53                   	push   %ebx
  8010a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010a8:	a8 01                	test   $0x1,%al
  8010aa:	74 34                	je     8010e0 <fd_alloc+0x44>
  8010ac:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010b1:	a8 01                	test   $0x1,%al
  8010b3:	74 32                	je     8010e7 <fd_alloc+0x4b>
  8010b5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010ba:	89 c1                	mov    %eax,%ecx
  8010bc:	89 c2                	mov    %eax,%edx
  8010be:	c1 ea 16             	shr    $0x16,%edx
  8010c1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c8:	f6 c2 01             	test   $0x1,%dl
  8010cb:	74 1f                	je     8010ec <fd_alloc+0x50>
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	c1 ea 0c             	shr    $0xc,%edx
  8010d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d9:	f6 c2 01             	test   $0x1,%dl
  8010dc:	75 17                	jne    8010f5 <fd_alloc+0x59>
  8010de:	eb 0c                	jmp    8010ec <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010e0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010e5:	eb 05                	jmp    8010ec <fd_alloc+0x50>
  8010e7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010ec:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f3:	eb 17                	jmp    80110c <fd_alloc+0x70>
  8010f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ff:	75 b9                	jne    8010ba <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801107:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110c:	5b                   	pop    %ebx
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801115:	83 f8 1f             	cmp    $0x1f,%eax
  801118:	77 36                	ja     801150 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80111f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801122:	89 c2                	mov    %eax,%edx
  801124:	c1 ea 16             	shr    $0x16,%edx
  801127:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112e:	f6 c2 01             	test   $0x1,%dl
  801131:	74 24                	je     801157 <fd_lookup+0x48>
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 0c             	shr    $0xc,%edx
  801138:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 1a                	je     80115e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801144:	8b 55 0c             	mov    0xc(%ebp),%edx
  801147:	89 02                	mov    %eax,(%edx)
	return 0;
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	eb 13                	jmp    801163 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801155:	eb 0c                	jmp    801163 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115c:	eb 05                	jmp    801163 <fd_lookup+0x54>
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	53                   	push   %ebx
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801172:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801178:	74 0d                	je     801187 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 14                	jmp    801195 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801181:	39 0a                	cmp    %ecx,(%edx)
  801183:	75 10                	jne    801195 <dev_lookup+0x30>
  801185:	eb 05                	jmp    80118c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801187:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80118c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	eb 31                	jmp    8011c6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801195:	40                   	inc    %eax
  801196:	8b 14 85 0c 27 80 00 	mov    0x80270c(,%eax,4),%edx
  80119d:	85 d2                	test   %edx,%edx
  80119f:	75 e0                	jne    801181 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	51                   	push   %ecx
  8011ad:	50                   	push   %eax
  8011ae:	68 90 26 80 00       	push   $0x802690
  8011b3:	e8 28 f0 ff ff       	call   8001e0 <cprintf>
	*dev = 0;
  8011b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 20             	sub    $0x20,%esp
  8011d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d6:	8a 45 0c             	mov    0xc(%ebp),%al
  8011d9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011dc:	56                   	push   %esi
  8011dd:	e8 92 fe ff ff       	call   801074 <fd2num>
  8011e2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011e5:	89 14 24             	mov    %edx,(%esp)
  8011e8:	50                   	push   %eax
  8011e9:	e8 21 ff ff ff       	call   80110f <fd_lookup>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 05                	js     8011fc <fd_close+0x31>
	    || fd != fd2)
  8011f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011fa:	74 0d                	je     801209 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011fc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801200:	75 48                	jne    80124a <fd_close+0x7f>
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	eb 41                	jmp    80124a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 36                	pushl  (%esi)
  801212:	e8 4e ff ff ff       	call   801165 <dev_lookup>
  801217:	89 c3                	mov    %eax,%ebx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 1c                	js     80123c <fd_close+0x71>
		if (dev->dev_close)
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	8b 40 10             	mov    0x10(%eax),%eax
  801226:	85 c0                	test   %eax,%eax
  801228:	74 0d                	je     801237 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	56                   	push   %esi
  80122e:	ff d0                	call   *%eax
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	eb 05                	jmp    80123c <fd_close+0x71>
		else
			r = 0;
  801237:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	56                   	push   %esi
  801240:	6a 00                	push   $0x0
  801242:	e8 1b fa ff ff       	call   800c62 <sys_page_unmap>
	return r;
  801247:	83 c4 10             	add    $0x10,%esp
}
  80124a:	89 d8                	mov    %ebx,%eax
  80124c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 aa fe ff ff       	call   80110f <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 10                	js     80127c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	6a 01                	push   $0x1
  801271:	ff 75 f4             	pushl  -0xc(%ebp)
  801274:	e8 52 ff ff ff       	call   8011cb <fd_close>
  801279:	83 c4 10             	add    $0x10,%esp
}
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <close_all>:

void
close_all(void)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801285:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	53                   	push   %ebx
  80128e:	e8 c0 ff ff ff       	call   801253 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801293:	43                   	inc    %ebx
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	83 fb 20             	cmp    $0x20,%ebx
  80129a:	75 ee                	jne    80128a <close_all+0xc>
		close(i);
}
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 2c             	sub    $0x2c,%esp
  8012aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	e8 56 fe ff ff       	call   80110f <fd_lookup>
  8012b9:	89 c3                	mov    %eax,%ebx
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	0f 88 c0 00 00 00    	js     801386 <dup+0xe5>
		return r;
	close(newfdnum);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	57                   	push   %edi
  8012ca:	e8 84 ff ff ff       	call   801253 <close>

	newfd = INDEX2FD(newfdnum);
  8012cf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012d5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8012d8:	83 c4 04             	add    $0x4,%esp
  8012db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012de:	e8 a1 fd ff ff       	call   801084 <fd2data>
  8012e3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e5:	89 34 24             	mov    %esi,(%esp)
  8012e8:	e8 97 fd ff ff       	call   801084 <fd2data>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f3:	89 d8                	mov    %ebx,%eax
  8012f5:	c1 e8 16             	shr    $0x16,%eax
  8012f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	74 37                	je     80133a <dup+0x99>
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 26                	je     80133a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801314:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	25 07 0e 00 00       	and    $0xe07,%eax
  801323:	50                   	push   %eax
  801324:	ff 75 d4             	pushl  -0x2c(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	53                   	push   %ebx
  80132a:	6a 00                	push   $0x0
  80132c:	e8 0b f9 ff ff       	call   800c3c <sys_page_map>
  801331:	89 c3                	mov    %eax,%ebx
  801333:	83 c4 20             	add    $0x20,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 2d                	js     801367 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	c1 ea 0c             	shr    $0xc,%edx
  801342:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801352:	52                   	push   %edx
  801353:	56                   	push   %esi
  801354:	6a 00                	push   $0x0
  801356:	50                   	push   %eax
  801357:	6a 00                	push   $0x0
  801359:	e8 de f8 ff ff       	call   800c3c <sys_page_map>
  80135e:	89 c3                	mov    %eax,%ebx
  801360:	83 c4 20             	add    $0x20,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	79 1d                	jns    801384 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	56                   	push   %esi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 f0 f8 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801372:	83 c4 08             	add    $0x8,%esp
  801375:	ff 75 d4             	pushl  -0x2c(%ebp)
  801378:	6a 00                	push   $0x0
  80137a:	e8 e3 f8 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 02                	jmp    801386 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801384:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801386:	89 d8                	mov    %ebx,%eax
  801388:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	53                   	push   %ebx
  801394:	83 ec 14             	sub    $0x14,%esp
  801397:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	53                   	push   %ebx
  80139f:	e8 6b fd ff ff       	call   80110f <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 67                	js     801412 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 a9 fd ff ff       	call   801165 <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 4f                	js     801412 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	8b 50 08             	mov    0x8(%eax),%edx
  8013c9:	83 e2 03             	and    $0x3,%edx
  8013cc:	83 fa 01             	cmp    $0x1,%edx
  8013cf:	75 21                	jne    8013f2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d6:	8b 40 48             	mov    0x48(%eax),%eax
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	50                   	push   %eax
  8013de:	68 d1 26 80 00       	push   $0x8026d1
  8013e3:	e8 f8 ed ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f0:	eb 20                	jmp    801412 <read+0x82>
	}
	if (!dev->dev_read)
  8013f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f5:	8b 52 08             	mov    0x8(%edx),%edx
  8013f8:	85 d2                	test   %edx,%edx
  8013fa:	74 11                	je     80140d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	ff 75 10             	pushl  0x10(%ebp)
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	50                   	push   %eax
  801406:	ff d2                	call   *%edx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb 05                	jmp    801412 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80140d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	57                   	push   %edi
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	8b 7d 08             	mov    0x8(%ebp),%edi
  801423:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801426:	85 f6                	test   %esi,%esi
  801428:	74 31                	je     80145b <readn+0x44>
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	89 f2                	mov    %esi,%edx
  801439:	29 c2                	sub    %eax,%edx
  80143b:	52                   	push   %edx
  80143c:	03 45 0c             	add    0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	57                   	push   %edi
  801441:	e8 4a ff ff ff       	call   801390 <read>
		if (m < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 17                	js     801464 <readn+0x4d>
			return m;
		if (m == 0)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	74 11                	je     801462 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801451:	01 c3                	add    %eax,%ebx
  801453:	89 d8                	mov    %ebx,%eax
  801455:	39 f3                	cmp    %esi,%ebx
  801457:	72 db                	jb     801434 <readn+0x1d>
  801459:	eb 09                	jmp    801464 <readn+0x4d>
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	eb 02                	jmp    801464 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801462:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801464:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5f                   	pop    %edi
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 14             	sub    $0x14,%esp
  801473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	53                   	push   %ebx
  80147b:	e8 8f fc ff ff       	call   80110f <fd_lookup>
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 62                	js     8014e9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 cd fc ff ff       	call   801165 <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4a                	js     8014e9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a6:	75 21                	jne    8014c9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ad:	8b 40 48             	mov    0x48(%eax),%eax
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	53                   	push   %ebx
  8014b4:	50                   	push   %eax
  8014b5:	68 ed 26 80 00       	push   $0x8026ed
  8014ba:	e8 21 ed ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c7:	eb 20                	jmp    8014e9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cf:	85 d2                	test   %edx,%edx
  8014d1:	74 11                	je     8014e4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	ff 75 10             	pushl  0x10(%ebp)
  8014d9:	ff 75 0c             	pushl  0xc(%ebp)
  8014dc:	50                   	push   %eax
  8014dd:	ff d2                	call   *%edx
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	eb 05                	jmp    8014e9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	e8 0f fc ff ff       	call   80110f <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 0e                	js     801515 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801507:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80150a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801510:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	53                   	push   %ebx
  80151b:	83 ec 14             	sub    $0x14,%esp
  80151e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	53                   	push   %ebx
  801526:	e8 e4 fb ff ff       	call   80110f <fd_lookup>
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 5f                	js     801591 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 22 fc ff ff       	call   801165 <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 47                	js     801591 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801551:	75 21                	jne    801574 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801553:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	53                   	push   %ebx
  80155f:	50                   	push   %eax
  801560:	68 b0 26 80 00       	push   $0x8026b0
  801565:	e8 76 ec ff ff       	call   8001e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801572:	eb 1d                	jmp    801591 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801574:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801577:	8b 52 18             	mov    0x18(%edx),%edx
  80157a:	85 d2                	test   %edx,%edx
  80157c:	74 0e                	je     80158c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	50                   	push   %eax
  801585:	ff d2                	call   *%edx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb 05                	jmp    801591 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	53                   	push   %ebx
  80159a:	83 ec 14             	sub    $0x14,%esp
  80159d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 63 fb ff ff       	call   80110f <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 52                	js     801605 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 a1 fb ff ff       	call   801165 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 3a                	js     801605 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d2:	74 2c                	je     801600 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015de:	00 00 00 
	stat->st_isdir = 0;
  8015e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e8:	00 00 00 
	stat->st_dev = dev;
  8015eb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f8:	ff 50 14             	call   *0x14(%eax)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 05                	jmp    801605 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801600:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	6a 00                	push   $0x0
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 78 01 00 00       	call   801794 <open>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 1b                	js     801640 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	e8 65 ff ff ff       	call   801596 <fstat>
  801631:	89 c6                	mov    %eax,%esi
	close(fd);
  801633:	89 1c 24             	mov    %ebx,(%esp)
  801636:	e8 18 fc ff ff       	call   801253 <close>
	return r;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	89 f3                	mov    %esi,%ebx
}
  801640:	89 d8                	mov    %ebx,%eax
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	c9                   	leave  
  801648:	c3                   	ret    
  801649:	00 00                	add    %al,(%eax)
	...

0080164c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	89 c3                	mov    %eax,%ebx
  801653:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801655:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80165c:	75 12                	jne    801670 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	6a 01                	push   $0x1
  801663:	e8 66 08 00 00       	call   801ece <ipc_find_env>
  801668:	a3 00 40 80 00       	mov    %eax,0x804000
  80166d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801670:	6a 07                	push   $0x7
  801672:	68 00 50 80 00       	push   $0x805000
  801677:	53                   	push   %ebx
  801678:	ff 35 00 40 80 00    	pushl  0x804000
  80167e:	e8 f6 07 00 00       	call   801e79 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801683:	83 c4 0c             	add    $0xc,%esp
  801686:	6a 00                	push   $0x0
  801688:	56                   	push   %esi
  801689:	6a 00                	push   $0x0
  80168b:	e8 74 07 00 00       	call   801e04 <ipc_recv>
}
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b6:	e8 91 ff ff ff       	call   80164c <fsipc>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 2c                	js     8016eb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bf:	83 ec 08             	sub    $0x8,%esp
  8016c2:	68 00 50 80 00       	push   $0x805000
  8016c7:	53                   	push   %ebx
  8016c8:	e8 c9 f0 ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8016dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 06 00 00 00       	mov    $0x6,%eax
  80170b:	e8 3c ff ff ff       	call   80164c <fsipc>
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 40 0c             	mov    0xc(%eax),%eax
  801720:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801725:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	b8 03 00 00 00       	mov    $0x3,%eax
  801735:	e8 12 ff ff ff       	call   80164c <fsipc>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 4b                	js     80178b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801740:	39 c6                	cmp    %eax,%esi
  801742:	73 16                	jae    80175a <devfile_read+0x48>
  801744:	68 1c 27 80 00       	push   $0x80271c
  801749:	68 23 27 80 00       	push   $0x802723
  80174e:	6a 7d                	push   $0x7d
  801750:	68 38 27 80 00       	push   $0x802738
  801755:	e8 ce 05 00 00       	call   801d28 <_panic>
	assert(r <= PGSIZE);
  80175a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80175f:	7e 16                	jle    801777 <devfile_read+0x65>
  801761:	68 43 27 80 00       	push   $0x802743
  801766:	68 23 27 80 00       	push   $0x802723
  80176b:	6a 7e                	push   $0x7e
  80176d:	68 38 27 80 00       	push   $0x802738
  801772:	e8 b1 05 00 00       	call   801d28 <_panic>
	memmove(buf, &fsipcbuf, r);
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	50                   	push   %eax
  80177b:	68 00 50 80 00       	push   $0x805000
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	e8 cf f1 ff ff       	call   800957 <memmove>
	return r;
  801788:	83 c4 10             	add    $0x10,%esp
}
  80178b:	89 d8                	mov    %ebx,%eax
  80178d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	83 ec 1c             	sub    $0x1c,%esp
  80179c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80179f:	56                   	push   %esi
  8017a0:	e8 9f ef ff ff       	call   800744 <strlen>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017ad:	7f 65                	jg     801814 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	e8 e1 f8 ff ff       	call   80109c <fd_alloc>
  8017bb:	89 c3                	mov    %eax,%ebx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 55                	js     801819 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	56                   	push   %esi
  8017c8:	68 00 50 80 00       	push   $0x805000
  8017cd:	e8 c4 ef ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e2:	e8 65 fe ff ff       	call   80164c <fsipc>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	79 12                	jns    801802 <open+0x6e>
		fd_close(fd, 0);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	6a 00                	push   $0x0
  8017f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f8:	e8 ce f9 ff ff       	call   8011cb <fd_close>
		return r;
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	eb 17                	jmp    801819 <open+0x85>
	}

	return fd2num(fd);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	ff 75 f4             	pushl  -0xc(%ebp)
  801808:	e8 67 f8 ff ff       	call   801074 <fd2num>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	eb 05                	jmp    801819 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801814:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	c9                   	leave  
  801821:	c3                   	ret    
	...

00801824 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	ff 75 08             	pushl  0x8(%ebp)
  801832:	e8 4d f8 ff ff       	call   801084 <fd2data>
  801837:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801839:	83 c4 08             	add    $0x8,%esp
  80183c:	68 4f 27 80 00       	push   $0x80274f
  801841:	56                   	push   %esi
  801842:	e8 4f ef ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801847:	8b 43 04             	mov    0x4(%ebx),%eax
  80184a:	2b 03                	sub    (%ebx),%eax
  80184c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801852:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801859:	00 00 00 
	stat->st_dev = &devpipe;
  80185c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801863:	30 80 00 
	return 0;
}
  801866:	b8 00 00 00 00       	mov    $0x0,%eax
  80186b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186e:	5b                   	pop    %ebx
  80186f:	5e                   	pop    %esi
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80187c:	53                   	push   %ebx
  80187d:	6a 00                	push   $0x0
  80187f:	e8 de f3 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801884:	89 1c 24             	mov    %ebx,(%esp)
  801887:	e8 f8 f7 ff ff       	call   801084 <fd2data>
  80188c:	83 c4 08             	add    $0x8,%esp
  80188f:	50                   	push   %eax
  801890:	6a 00                	push   $0x0
  801892:	e8 cb f3 ff ff       	call   800c62 <sys_page_unmap>
}
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 1c             	sub    $0x1c,%esp
  8018a5:	89 c7                	mov    %eax,%edi
  8018a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8018af:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018b2:	83 ec 0c             	sub    $0xc,%esp
  8018b5:	57                   	push   %edi
  8018b6:	e8 71 06 00 00       	call   801f2c <pageref>
  8018bb:	89 c6                	mov    %eax,%esi
  8018bd:	83 c4 04             	add    $0x4,%esp
  8018c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018c3:	e8 64 06 00 00       	call   801f2c <pageref>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	39 c6                	cmp    %eax,%esi
  8018cd:	0f 94 c0             	sete   %al
  8018d0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018d3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018d9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018dc:	39 cb                	cmp    %ecx,%ebx
  8018de:	75 08                	jne    8018e8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018e8:	83 f8 01             	cmp    $0x1,%eax
  8018eb:	75 bd                	jne    8018aa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018ed:	8b 42 58             	mov    0x58(%edx),%eax
  8018f0:	6a 01                	push   $0x1
  8018f2:	50                   	push   %eax
  8018f3:	53                   	push   %ebx
  8018f4:	68 56 27 80 00       	push   $0x802756
  8018f9:	e8 e2 e8 ff ff       	call   8001e0 <cprintf>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb a7                	jmp    8018aa <_pipeisclosed+0xe>

00801903 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	57                   	push   %edi
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	83 ec 28             	sub    $0x28,%esp
  80190c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80190f:	56                   	push   %esi
  801910:	e8 6f f7 ff ff       	call   801084 <fd2data>
  801915:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80191e:	75 4a                	jne    80196a <devpipe_write+0x67>
  801920:	bf 00 00 00 00       	mov    $0x0,%edi
  801925:	eb 56                	jmp    80197d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801927:	89 da                	mov    %ebx,%edx
  801929:	89 f0                	mov    %esi,%eax
  80192b:	e8 6c ff ff ff       	call   80189c <_pipeisclosed>
  801930:	85 c0                	test   %eax,%eax
  801932:	75 4d                	jne    801981 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801934:	e8 b8 f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801939:	8b 43 04             	mov    0x4(%ebx),%eax
  80193c:	8b 13                	mov    (%ebx),%edx
  80193e:	83 c2 20             	add    $0x20,%edx
  801941:	39 d0                	cmp    %edx,%eax
  801943:	73 e2                	jae    801927 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801945:	89 c2                	mov    %eax,%edx
  801947:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80194d:	79 05                	jns    801954 <devpipe_write+0x51>
  80194f:	4a                   	dec    %edx
  801950:	83 ca e0             	or     $0xffffffe0,%edx
  801953:	42                   	inc    %edx
  801954:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801957:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80195a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80195e:	40                   	inc    %eax
  80195f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801962:	47                   	inc    %edi
  801963:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801966:	77 07                	ja     80196f <devpipe_write+0x6c>
  801968:	eb 13                	jmp    80197d <devpipe_write+0x7a>
  80196a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196f:	8b 43 04             	mov    0x4(%ebx),%eax
  801972:	8b 13                	mov    (%ebx),%edx
  801974:	83 c2 20             	add    $0x20,%edx
  801977:	39 d0                	cmp    %edx,%eax
  801979:	73 ac                	jae    801927 <devpipe_write+0x24>
  80197b:	eb c8                	jmp    801945 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197d:	89 f8                	mov    %edi,%eax
  80197f:	eb 05                	jmp    801986 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5f                   	pop    %edi
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	83 ec 18             	sub    $0x18,%esp
  801997:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199a:	57                   	push   %edi
  80199b:	e8 e4 f6 ff ff       	call   801084 <fd2data>
  8019a0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a9:	75 44                	jne    8019ef <devpipe_read+0x61>
  8019ab:	be 00 00 00 00       	mov    $0x0,%esi
  8019b0:	eb 4f                	jmp    801a01 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8019b2:	89 f0                	mov    %esi,%eax
  8019b4:	eb 54                	jmp    801a0a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b6:	89 da                	mov    %ebx,%edx
  8019b8:	89 f8                	mov    %edi,%eax
  8019ba:	e8 dd fe ff ff       	call   80189c <_pipeisclosed>
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	75 42                	jne    801a05 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c3:	e8 29 f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c8:	8b 03                	mov    (%ebx),%eax
  8019ca:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019cd:	74 e7                	je     8019b6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019cf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019d4:	79 05                	jns    8019db <devpipe_read+0x4d>
  8019d6:	48                   	dec    %eax
  8019d7:	83 c8 e0             	or     $0xffffffe0,%eax
  8019da:	40                   	inc    %eax
  8019db:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019e5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	46                   	inc    %esi
  8019e8:	39 75 10             	cmp    %esi,0x10(%ebp)
  8019eb:	77 07                	ja     8019f4 <devpipe_read+0x66>
  8019ed:	eb 12                	jmp    801a01 <devpipe_read+0x73>
  8019ef:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019f4:	8b 03                	mov    (%ebx),%eax
  8019f6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019f9:	75 d4                	jne    8019cf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019fb:	85 f6                	test   %esi,%esi
  8019fd:	75 b3                	jne    8019b2 <devpipe_read+0x24>
  8019ff:	eb b5                	jmp    8019b6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a01:	89 f0                	mov    %esi,%eax
  801a03:	eb 05                	jmp    801a0a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5f                   	pop    %edi
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	57                   	push   %edi
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 28             	sub    $0x28,%esp
  801a1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a1e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a21:	50                   	push   %eax
  801a22:	e8 75 f6 ff ff       	call   80109c <fd_alloc>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	0f 88 24 01 00 00    	js     801b58 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a34:	83 ec 04             	sub    $0x4,%esp
  801a37:	68 07 04 00 00       	push   $0x407
  801a3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 d2 f1 ff ff       	call   800c18 <sys_page_alloc>
  801a46:	89 c3                	mov    %eax,%ebx
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	0f 88 05 01 00 00    	js     801b58 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	e8 3d f6 ff ff       	call   80109c <fd_alloc>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 dc 00 00 00    	js     801b48 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	ff 75 e0             	pushl  -0x20(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 9a f1 ff ff       	call   800c18 <sys_page_alloc>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	0f 88 bd 00 00 00    	js     801b48 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a91:	e8 ee f5 ff ff       	call   801084 <fd2data>
  801a96:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a98:	83 c4 0c             	add    $0xc,%esp
  801a9b:	68 07 04 00 00       	push   $0x407
  801aa0:	50                   	push   %eax
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 70 f1 ff ff       	call   800c18 <sys_page_alloc>
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	0f 88 83 00 00 00    	js     801b38 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 e0             	pushl  -0x20(%ebp)
  801abb:	e8 c4 f5 ff ff       	call   801084 <fd2data>
  801ac0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ac7:	50                   	push   %eax
  801ac8:	6a 00                	push   $0x0
  801aca:	56                   	push   %esi
  801acb:	6a 00                	push   $0x0
  801acd:	e8 6a f1 ff ff       	call   800c3c <sys_page_map>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 20             	add    $0x20,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 4f                	js     801b2a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801adb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ae6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801af0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801afb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801afe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b0b:	e8 64 f5 ff ff       	call   801074 <fd2num>
  801b10:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b12:	83 c4 04             	add    $0x4,%esp
  801b15:	ff 75 e0             	pushl  -0x20(%ebp)
  801b18:	e8 57 f5 ff ff       	call   801074 <fd2num>
  801b1d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b28:	eb 2e                	jmp    801b58 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b2a:	83 ec 08             	sub    $0x8,%esp
  801b2d:	56                   	push   %esi
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 2d f1 ff ff       	call   800c62 <sys_page_unmap>
  801b35:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 1d f1 ff ff       	call   800c62 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 0d f1 ff ff       	call   800c62 <sys_page_unmap>
  801b55:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b58:	89 d8                	mov    %ebx,%eax
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6b:	50                   	push   %eax
  801b6c:	ff 75 08             	pushl  0x8(%ebp)
  801b6f:	e8 9b f5 ff ff       	call   80110f <fd_lookup>
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 18                	js     801b93 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b81:	e8 fe f4 ff ff       	call   801084 <fd2data>
	return _pipeisclosed(fd, p);
  801b86:	89 c2                	mov    %eax,%edx
  801b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8b:	e8 0c fd ff ff       	call   80189c <_pipeisclosed>
  801b90:	83 c4 10             	add    $0x10,%esp
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    
  801b95:	00 00                	add    %al,(%eax)
	...

00801b98 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ba8:	68 6e 27 80 00       	push   $0x80276e
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	e8 e1 eb ff ff       	call   800796 <strcpy>
	return 0;
}
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	57                   	push   %edi
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bcc:	74 45                	je     801c13 <devcons_write+0x57>
  801bce:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801be1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801be3:	83 fb 7f             	cmp    $0x7f,%ebx
  801be6:	76 05                	jbe    801bed <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801be8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	53                   	push   %ebx
  801bf1:	03 45 0c             	add    0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	57                   	push   %edi
  801bf6:	e8 5c ed ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801bfb:	83 c4 08             	add    $0x8,%esp
  801bfe:	53                   	push   %ebx
  801bff:	57                   	push   %edi
  801c00:	e8 5c ef ff ff       	call   800b61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c05:	01 de                	add    %ebx,%esi
  801c07:	89 f0                	mov    %esi,%eax
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0f:	72 cd                	jb     801bde <devcons_write+0x22>
  801c11:	eb 05                	jmp    801c18 <devcons_write+0x5c>
  801c13:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c18:	89 f0                	mov    %esi,%eax
  801c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c2c:	75 07                	jne    801c35 <devcons_read+0x13>
  801c2e:	eb 25                	jmp    801c55 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c30:	e8 bc ef ff ff       	call   800bf1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c35:	e8 4d ef ff ff       	call   800b87 <sys_cgetc>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	74 f2                	je     801c30 <devcons_read+0xe>
  801c3e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 1d                	js     801c61 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c44:	83 f8 04             	cmp    $0x4,%eax
  801c47:	74 13                	je     801c5c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4c:	88 10                	mov    %dl,(%eax)
	return 1;
  801c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c53:	eb 0c                	jmp    801c61 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5a:	eb 05                	jmp    801c61 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c6f:	6a 01                	push   $0x1
  801c71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c74:	50                   	push   %eax
  801c75:	e8 e7 ee ff ff       	call   800b61 <sys_cputs>
  801c7a:	83 c4 10             	add    $0x10,%esp
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <getchar>:

int
getchar(void)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c85:	6a 01                	push   $0x1
  801c87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8a:	50                   	push   %eax
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 fe f6 ff ff       	call   801390 <read>
	if (r < 0)
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 0f                	js     801ca8 <getchar+0x29>
		return r;
	if (r < 1)
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	7e 06                	jle    801ca3 <getchar+0x24>
		return -E_EOF;
	return c;
  801c9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ca1:	eb 05                	jmp    801ca8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ca3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb3:	50                   	push   %eax
  801cb4:	ff 75 08             	pushl  0x8(%ebp)
  801cb7:	e8 53 f4 ff ff       	call   80110f <fd_lookup>
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 11                	js     801cd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ccc:	39 10                	cmp    %edx,(%eax)
  801cce:	0f 94 c0             	sete   %al
  801cd1:	0f b6 c0             	movzbl %al,%eax
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <opencons>:

int
opencons(void)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdf:	50                   	push   %eax
  801ce0:	e8 b7 f3 ff ff       	call   80109c <fd_alloc>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 3a                	js     801d26 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cec:	83 ec 04             	sub    $0x4,%esp
  801cef:	68 07 04 00 00       	push   $0x407
  801cf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 1a ef ff ff       	call   800c18 <sys_page_alloc>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 21                	js     801d26 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d05:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	50                   	push   %eax
  801d1e:	e8 51 f3 ff ff       	call   801074 <fd2num>
  801d23:	83 c4 10             	add    $0x10,%esp
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	56                   	push   %esi
  801d2c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d2d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d30:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d36:	e8 92 ee ff ff       	call   800bcd <sys_getenvid>
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff 75 0c             	pushl  0xc(%ebp)
  801d41:	ff 75 08             	pushl  0x8(%ebp)
  801d44:	53                   	push   %ebx
  801d45:	50                   	push   %eax
  801d46:	68 7c 27 80 00       	push   $0x80277c
  801d4b:	e8 90 e4 ff ff       	call   8001e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d50:	83 c4 18             	add    $0x18,%esp
  801d53:	56                   	push   %esi
  801d54:	ff 75 10             	pushl  0x10(%ebp)
  801d57:	e8 33 e4 ff ff       	call   80018f <vcprintf>
	cprintf("\n");
  801d5c:	c7 04 24 cf 21 80 00 	movl   $0x8021cf,(%esp)
  801d63:	e8 78 e4 ff ff       	call   8001e0 <cprintf>
  801d68:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d6b:	cc                   	int3   
  801d6c:	eb fd                	jmp    801d6b <_panic+0x43>
	...

00801d70 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d76:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d7d:	75 52                	jne    801dd1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	6a 07                	push   $0x7
  801d84:	68 00 f0 bf ee       	push   $0xeebff000
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 88 ee ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) {
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	79 12                	jns    801da9 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801d97:	50                   	push   %eax
  801d98:	68 9f 27 80 00       	push   $0x80279f
  801d9d:	6a 24                	push   $0x24
  801d9f:	68 ba 27 80 00       	push   $0x8027ba
  801da4:	e8 7f ff ff ff       	call   801d28 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801da9:	83 ec 08             	sub    $0x8,%esp
  801dac:	68 dc 1d 80 00       	push   $0x801ddc
  801db1:	6a 00                	push   $0x0
  801db3:	e8 13 ef ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	79 12                	jns    801dd1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801dbf:	50                   	push   %eax
  801dc0:	68 c8 27 80 00       	push   $0x8027c8
  801dc5:	6a 2a                	push   $0x2a
  801dc7:	68 ba 27 80 00       	push   $0x8027ba
  801dcc:	e8 57 ff ff ff       	call   801d28 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    
	...

00801ddc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ddc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ddd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801de2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801de4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801de7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801deb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801dee:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801df2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801df6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801df8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801dfb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801dfc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801dff:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e00:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e01:	c3                   	ret    
	...

00801e04 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e12:	85 c0                	test   %eax,%eax
  801e14:	74 0e                	je     801e24 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e16:	83 ec 0c             	sub    $0xc,%esp
  801e19:	50                   	push   %eax
  801e1a:	e8 f4 ee ff ff       	call   800d13 <sys_ipc_recv>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	eb 10                	jmp    801e34 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	68 00 00 c0 ee       	push   $0xeec00000
  801e2c:	e8 e2 ee ff ff       	call   800d13 <sys_ipc_recv>
  801e31:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e34:	85 c0                	test   %eax,%eax
  801e36:	75 26                	jne    801e5e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e38:	85 f6                	test   %esi,%esi
  801e3a:	74 0a                	je     801e46 <ipc_recv+0x42>
  801e3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e41:	8b 40 74             	mov    0x74(%eax),%eax
  801e44:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 0a                	je     801e54 <ipc_recv+0x50>
  801e4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4f:	8b 40 78             	mov    0x78(%eax),%eax
  801e52:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 40 70             	mov    0x70(%eax),%eax
  801e5c:	eb 14                	jmp    801e72 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e5e:	85 f6                	test   %esi,%esi
  801e60:	74 06                	je     801e68 <ipc_recv+0x64>
  801e62:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801e68:	85 db                	test   %ebx,%ebx
  801e6a:	74 06                	je     801e72 <ipc_recv+0x6e>
  801e6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 0c             	sub    $0xc,%esp
  801e82:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e88:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	75 25                	jne    801eb4 <ipc_send+0x3b>
  801e8f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e94:	eb 1e                	jmp    801eb4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801e96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e99:	75 07                	jne    801ea2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801e9b:	e8 51 ed ff ff       	call   800bf1 <sys_yield>
  801ea0:	eb 12                	jmp    801eb4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ea2:	50                   	push   %eax
  801ea3:	68 f0 27 80 00       	push   $0x8027f0
  801ea8:	6a 43                	push   $0x43
  801eaa:	68 03 28 80 00       	push   $0x802803
  801eaf:	e8 74 fe ff ff       	call   801d28 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	57                   	push   %edi
  801eb7:	ff 75 08             	pushl  0x8(%ebp)
  801eba:	e8 2f ee ff ff       	call   800cee <sys_ipc_try_send>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	75 d0                	jne    801e96 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec9:	5b                   	pop    %ebx
  801eca:	5e                   	pop    %esi
  801ecb:	5f                   	pop    %edi
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	53                   	push   %ebx
  801ed2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ed5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801edb:	74 22                	je     801eff <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801edd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ee2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ee9:	89 c2                	mov    %eax,%edx
  801eeb:	c1 e2 07             	shl    $0x7,%edx
  801eee:	29 ca                	sub    %ecx,%edx
  801ef0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef6:	8b 52 50             	mov    0x50(%edx),%edx
  801ef9:	39 da                	cmp    %ebx,%edx
  801efb:	75 1d                	jne    801f1a <ipc_find_env+0x4c>
  801efd:	eb 05                	jmp    801f04 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f0b:	c1 e0 07             	shl    $0x7,%eax
  801f0e:	29 d0                	sub    %edx,%eax
  801f10:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f15:	8b 40 40             	mov    0x40(%eax),%eax
  801f18:	eb 0c                	jmp    801f26 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f1a:	40                   	inc    %eax
  801f1b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f20:	75 c0                	jne    801ee2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f22:	66 b8 00 00          	mov    $0x0,%ax
}
  801f26:	5b                   	pop    %ebx
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    
  801f29:	00 00                	add    %al,(%eax)
	...

00801f2c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f32:	89 c2                	mov    %eax,%edx
  801f34:	c1 ea 16             	shr    $0x16,%edx
  801f37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f3e:	f6 c2 01             	test   $0x1,%dl
  801f41:	74 1e                	je     801f61 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f43:	c1 e8 0c             	shr    $0xc,%eax
  801f46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f4d:	a8 01                	test   $0x1,%al
  801f4f:	74 17                	je     801f68 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f51:	c1 e8 0c             	shr    $0xc,%eax
  801f54:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f5b:	ef 
  801f5c:	0f b7 c0             	movzwl %ax,%eax
  801f5f:	eb 0c                	jmp    801f6d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f61:	b8 00 00 00 00       	mov    $0x0,%eax
  801f66:	eb 05                	jmp    801f6d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f68:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    
	...

00801f70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	57                   	push   %edi
  801f74:	56                   	push   %esi
  801f75:	83 ec 10             	sub    $0x10,%esp
  801f78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f7e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f87:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	75 2e                	jne    801fbc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f8e:	39 f1                	cmp    %esi,%ecx
  801f90:	77 5a                	ja     801fec <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f92:	85 c9                	test   %ecx,%ecx
  801f94:	75 0b                	jne    801fa1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f1                	div    %ecx
  801f9f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fa1:	31 d2                	xor    %edx,%edx
  801fa3:	89 f0                	mov    %esi,%eax
  801fa5:	f7 f1                	div    %ecx
  801fa7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fa9:	89 f8                	mov    %edi,%eax
  801fab:	f7 f1                	div    %ecx
  801fad:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    
  801fba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fbc:	39 f0                	cmp    %esi,%eax
  801fbe:	77 1c                	ja     801fdc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fc0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fc3:	83 f7 1f             	xor    $0x1f,%edi
  801fc6:	75 3c                	jne    802004 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fc8:	39 f0                	cmp    %esi,%eax
  801fca:	0f 82 90 00 00 00    	jb     802060 <__udivdi3+0xf0>
  801fd0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fd3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fd6:	0f 86 84 00 00 00    	jbe    802060 <__udivdi3+0xf0>
  801fdc:	31 f6                	xor    %esi,%esi
  801fde:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fe0:	89 f8                	mov    %edi,%eax
  801fe2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    
  801feb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fec:	89 f2                	mov    %esi,%edx
  801fee:	89 f8                	mov    %edi,%eax
  801ff0:	f7 f1                	div    %ecx
  801ff2:	89 c7                	mov    %eax,%edi
  801ff4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ff6:	89 f8                	mov    %edi,%eax
  801ff8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	5e                   	pop    %esi
  801ffe:	5f                   	pop    %edi
  801fff:	c9                   	leave  
  802000:	c3                   	ret    
  802001:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802004:	89 f9                	mov    %edi,%ecx
  802006:	d3 e0                	shl    %cl,%eax
  802008:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80200b:	b8 20 00 00 00       	mov    $0x20,%eax
  802010:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802012:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802015:	88 c1                	mov    %al,%cl
  802017:	d3 ea                	shr    %cl,%edx
  802019:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80201c:	09 ca                	or     %ecx,%edx
  80201e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802021:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802024:	89 f9                	mov    %edi,%ecx
  802026:	d3 e2                	shl    %cl,%edx
  802028:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	88 c1                	mov    %al,%cl
  80202f:	d3 ea                	shr    %cl,%edx
  802031:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802034:	89 f2                	mov    %esi,%edx
  802036:	89 f9                	mov    %edi,%ecx
  802038:	d3 e2                	shl    %cl,%edx
  80203a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80203d:	88 c1                	mov    %al,%cl
  80203f:	d3 ee                	shr    %cl,%esi
  802041:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802043:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802046:	89 f0                	mov    %esi,%eax
  802048:	89 ca                	mov    %ecx,%edx
  80204a:	f7 75 ec             	divl   -0x14(%ebp)
  80204d:	89 d1                	mov    %edx,%ecx
  80204f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802051:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802054:	39 d1                	cmp    %edx,%ecx
  802056:	72 28                	jb     802080 <__udivdi3+0x110>
  802058:	74 1a                	je     802074 <__udivdi3+0x104>
  80205a:	89 f7                	mov    %esi,%edi
  80205c:	31 f6                	xor    %esi,%esi
  80205e:	eb 80                	jmp    801fe0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802060:	31 f6                	xor    %esi,%esi
  802062:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802067:	89 f8                	mov    %edi,%eax
  802069:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	c9                   	leave  
  802071:	c3                   	ret    
  802072:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802074:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802077:	89 f9                	mov    %edi,%ecx
  802079:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80207b:	39 c2                	cmp    %eax,%edx
  80207d:	73 db                	jae    80205a <__udivdi3+0xea>
  80207f:	90                   	nop
		{
		  q0--;
  802080:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802083:	31 f6                	xor    %esi,%esi
  802085:	e9 56 ff ff ff       	jmp    801fe0 <__udivdi3+0x70>
	...

0080208c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	57                   	push   %edi
  802090:	56                   	push   %esi
  802091:	83 ec 20             	sub    $0x20,%esp
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80209a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80209d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020a0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020a9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	75 15                	jne    8020c4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020af:	39 f1                	cmp    %esi,%ecx
  8020b1:	0f 86 99 00 00 00    	jbe    802150 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020b7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020bd:	83 c4 20             	add    $0x20,%esp
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	c9                   	leave  
  8020c3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c4:	39 f7                	cmp    %esi,%edi
  8020c6:	0f 87 a4 00 00 00    	ja     802170 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020cc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020cf:	83 f0 1f             	xor    $0x1f,%eax
  8020d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d5:	0f 84 a1 00 00 00    	je     80217c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020db:	89 f8                	mov    %edi,%eax
  8020dd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020e0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ed:	89 f9                	mov    %edi,%ecx
  8020ef:	d3 ea                	shr    %cl,%edx
  8020f1:	09 c2                	or     %eax,%edx
  8020f3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020fc:	d3 e0                	shl    %cl,%eax
  8020fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802101:	89 f2                	mov    %esi,%edx
  802103:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802105:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802108:	d3 e0                	shl    %cl,%eax
  80210a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80210d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802110:	89 f9                	mov    %edi,%ecx
  802112:	d3 e8                	shr    %cl,%eax
  802114:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802116:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802118:	89 f2                	mov    %esi,%edx
  80211a:	f7 75 f0             	divl   -0x10(%ebp)
  80211d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80211f:	f7 65 f4             	mull   -0xc(%ebp)
  802122:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802125:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802127:	39 d6                	cmp    %edx,%esi
  802129:	72 71                	jb     80219c <__umoddi3+0x110>
  80212b:	74 7f                	je     8021ac <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80212d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802130:	29 c8                	sub    %ecx,%eax
  802132:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802134:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 f2                	mov    %esi,%edx
  80213b:	89 f9                	mov    %edi,%ecx
  80213d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80213f:	09 d0                	or     %edx,%eax
  802141:	89 f2                	mov    %esi,%edx
  802143:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802146:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802148:	83 c4 20             	add    $0x20,%esp
  80214b:	5e                   	pop    %esi
  80214c:	5f                   	pop    %edi
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    
  80214f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802150:	85 c9                	test   %ecx,%ecx
  802152:	75 0b                	jne    80215f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802154:	b8 01 00 00 00       	mov    $0x1,%eax
  802159:	31 d2                	xor    %edx,%edx
  80215b:	f7 f1                	div    %ecx
  80215d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80215f:	89 f0                	mov    %esi,%eax
  802161:	31 d2                	xor    %edx,%edx
  802163:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802168:	f7 f1                	div    %ecx
  80216a:	e9 4a ff ff ff       	jmp    8020b9 <__umoddi3+0x2d>
  80216f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802170:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802172:	83 c4 20             	add    $0x20,%esp
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	c9                   	leave  
  802178:	c3                   	ret    
  802179:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	72 05                	jb     802185 <__umoddi3+0xf9>
  802180:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802183:	77 0c                	ja     802191 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802185:	89 f2                	mov    %esi,%edx
  802187:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80218a:	29 c8                	sub    %ecx,%eax
  80218c:	19 fa                	sbb    %edi,%edx
  80218e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802194:	83 c4 20             	add    $0x20,%esp
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	c9                   	leave  
  80219a:	c3                   	ret    
  80219b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80219c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021a4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021a7:	eb 84                	jmp    80212d <__umoddi3+0xa1>
  8021a9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021af:	72 eb                	jb     80219c <__umoddi3+0x110>
  8021b1:	89 f2                	mov    %esi,%edx
  8021b3:	e9 75 ff ff ff       	jmp    80212d <__umoddi3+0xa1>
