
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
  800048:	68 e0 21 80 00       	push   $0x8021e0
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
  800097:	68 f1 21 80 00       	push   $0x8021f1
  80009c:	6a 04                	push   $0x4
  80009e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a1:	50                   	push   %eax
  8000a2:	e8 81 06 00 00       	call   800728 <snprintf>
	if (fork() == 0) {
  8000a7:	83 c4 20             	add    $0x20,%esp
  8000aa:	e8 a3 0d 00 00       	call   800e52 <fork>
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
  8000d2:	68 f0 21 80 00       	push   $0x8021f0
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
  80013a:	e8 67 11 00 00       	call   8012a6 <close_all>
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
  800248:	e8 4b 1d 00 00       	call   801f98 <__udivdi3>
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
  800284:	e8 2b 1e 00 00       	call   8020b4 <__umoddi3>
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	0f be 80 00 22 80 00 	movsbl 0x802200(%eax),%eax
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
  8003d0:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
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
  80047c:	8b 04 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	75 1a                	jne    8004a1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800487:	52                   	push   %edx
  800488:	68 18 22 80 00       	push   $0x802218
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
  8004a2:	68 55 27 80 00       	push   $0x802755
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
  8004d8:	c7 45 d0 11 22 80 00 	movl   $0x802211,-0x30(%ebp)
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
  800b46:	68 ff 24 80 00       	push   $0x8024ff
  800b4b:	6a 42                	push   $0x42
  800b4d:	68 1c 25 80 00       	push   $0x80251c
  800b52:	e8 f9 11 00 00       	call   801d50 <_panic>

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

00800d58 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d5e:	6a 00                	push   $0x0
  800d60:	ff 75 14             	pushl  0x14(%ebp)
  800d63:	ff 75 10             	pushl  0x10(%ebp)
  800d66:	ff 75 0c             	pushl  0xc(%ebp)
  800d69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d76:	e8 99 fd ff ff       	call   800b14 <syscall>
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    
  800d7d:	00 00                	add    %al,(%eax)
	...

00800d80 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d8a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d8c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d90:	75 14                	jne    800da6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 2c 25 80 00       	push   $0x80252c
  800d9a:	6a 20                	push   $0x20
  800d9c:	68 70 26 80 00       	push   $0x802670
  800da1:	e8 aa 0f 00 00       	call   801d50 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800da6:	89 d8                	mov    %ebx,%eax
  800da8:	c1 e8 16             	shr    $0x16,%eax
  800dab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800db2:	a8 01                	test   $0x1,%al
  800db4:	74 11                	je     800dc7 <pgfault+0x47>
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	c1 e8 0c             	shr    $0xc,%eax
  800dbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc2:	f6 c4 08             	test   $0x8,%ah
  800dc5:	75 14                	jne    800ddb <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	68 50 25 80 00       	push   $0x802550
  800dcf:	6a 24                	push   $0x24
  800dd1:	68 70 26 80 00       	push   $0x802670
  800dd6:	e8 75 0f 00 00       	call   801d50 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	6a 07                	push   $0x7
  800de0:	68 00 f0 7f 00       	push   $0x7ff000
  800de5:	6a 00                	push   $0x0
  800de7:	e8 2c fe ff ff       	call   800c18 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 12                	jns    800e05 <pgfault+0x85>
  800df3:	50                   	push   %eax
  800df4:	68 74 25 80 00       	push   $0x802574
  800df9:	6a 32                	push   $0x32
  800dfb:	68 70 26 80 00       	push   $0x802670
  800e00:	e8 4b 0f 00 00       	call   801d50 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e05:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	68 00 10 00 00       	push   $0x1000
  800e13:	53                   	push   %ebx
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	e8 a3 fb ff ff       	call   8009c1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e1e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e25:	53                   	push   %ebx
  800e26:	6a 00                	push   $0x0
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 08 fe ff ff       	call   800c3c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e34:	83 c4 20             	add    $0x20,%esp
  800e37:	85 c0                	test   %eax,%eax
  800e39:	79 12                	jns    800e4d <pgfault+0xcd>
  800e3b:	50                   	push   %eax
  800e3c:	68 98 25 80 00       	push   $0x802598
  800e41:	6a 3a                	push   $0x3a
  800e43:	68 70 26 80 00       	push   $0x802670
  800e48:	e8 03 0f 00 00       	call   801d50 <_panic>

	return;
}
  800e4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e5b:	68 80 0d 80 00       	push   $0x800d80
  800e60:	e8 33 0f 00 00       	call   801d98 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e65:	ba 07 00 00 00       	mov    $0x7,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	cd 30                	int    $0x30
  800e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e71:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	79 12                	jns    800e8c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e7a:	50                   	push   %eax
  800e7b:	68 7b 26 80 00       	push   $0x80267b
  800e80:	6a 7f                	push   $0x7f
  800e82:	68 70 26 80 00       	push   $0x802670
  800e87:	e8 c4 0e 00 00       	call   801d50 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e90:	75 25                	jne    800eb7 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e92:	e8 36 fd ff ff       	call   800bcd <sys_getenvid>
  800e97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ea3:	c1 e0 07             	shl    $0x7,%eax
  800ea6:	29 d0                	sub    %edx,%eax
  800ea8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ead:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800eb2:	e9 be 01 00 00       	jmp    801075 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	c1 e8 16             	shr    $0x16,%eax
  800ec1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec8:	a8 01                	test   $0x1,%al
  800eca:	0f 84 10 01 00 00    	je     800fe0 <fork+0x18e>
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	c1 e8 0c             	shr    $0xc,%eax
  800ed5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	0f 84 fb 00 00 00    	je     800fe0 <fork+0x18e>
  800ee5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eec:	f6 c2 04             	test   $0x4,%dl
  800eef:	0f 84 eb 00 00 00    	je     800fe0 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ef5:	89 c6                	mov    %eax,%esi
  800ef7:	c1 e6 0c             	shl    $0xc,%esi
  800efa:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f00:	0f 84 da 00 00 00    	je     800fe0 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0d:	f6 c6 04             	test   $0x4,%dh
  800f10:	74 37                	je     800f49 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f19:	83 ec 0c             	sub    $0xc,%esp
  800f1c:	25 07 0e 00 00       	and    $0xe07,%eax
  800f21:	50                   	push   %eax
  800f22:	56                   	push   %esi
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	6a 00                	push   $0x0
  800f27:	e8 10 fd ff ff       	call   800c3c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f2c:	83 c4 20             	add    $0x20,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	0f 89 a9 00 00 00    	jns    800fe0 <fork+0x18e>
  800f37:	50                   	push   %eax
  800f38:	68 bc 25 80 00       	push   $0x8025bc
  800f3d:	6a 54                	push   $0x54
  800f3f:	68 70 26 80 00       	push   $0x802670
  800f44:	e8 07 0e 00 00       	call   801d50 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f50:	f6 c2 02             	test   $0x2,%dl
  800f53:	75 0c                	jne    800f61 <fork+0x10f>
  800f55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5c:	f6 c4 08             	test   $0x8,%ah
  800f5f:	74 57                	je     800fb8 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	68 05 08 00 00       	push   $0x805
  800f69:	56                   	push   %esi
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 c9 fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 12                	jns    800f8c <fork+0x13a>
  800f7a:	50                   	push   %eax
  800f7b:	68 bc 25 80 00       	push   $0x8025bc
  800f80:	6a 59                	push   $0x59
  800f82:	68 70 26 80 00       	push   $0x802670
  800f87:	e8 c4 0d 00 00       	call   801d50 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	68 05 08 00 00       	push   $0x805
  800f94:	56                   	push   %esi
  800f95:	6a 00                	push   $0x0
  800f97:	56                   	push   %esi
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 9d fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 3a                	jns    800fe0 <fork+0x18e>
  800fa6:	50                   	push   %eax
  800fa7:	68 bc 25 80 00       	push   $0x8025bc
  800fac:	6a 5c                	push   $0x5c
  800fae:	68 70 26 80 00       	push   $0x802670
  800fb3:	e8 98 0d 00 00       	call   801d50 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	6a 05                	push   $0x5
  800fbd:	56                   	push   %esi
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 75 fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fc7:	83 c4 20             	add    $0x20,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	79 12                	jns    800fe0 <fork+0x18e>
  800fce:	50                   	push   %eax
  800fcf:	68 bc 25 80 00       	push   $0x8025bc
  800fd4:	6a 60                	push   $0x60
  800fd6:	68 70 26 80 00       	push   $0x802670
  800fdb:	e8 70 0d 00 00       	call   801d50 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fe0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fec:	0f 85 ca fe ff ff    	jne    800ebc <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	6a 07                	push   $0x7
  800ff7:	68 00 f0 bf ee       	push   $0xeebff000
  800ffc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fff:	e8 14 fc ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 15                	jns    801020 <fork+0x1ce>
  80100b:	50                   	push   %eax
  80100c:	68 e0 25 80 00       	push   $0x8025e0
  801011:	68 94 00 00 00       	push   $0x94
  801016:	68 70 26 80 00       	push   $0x802670
  80101b:	e8 30 0d 00 00       	call   801d50 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 04 1e 80 00       	push   $0x801e04
  801028:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102b:	e8 9b fc ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	79 15                	jns    80104c <fork+0x1fa>
  801037:	50                   	push   %eax
  801038:	68 18 26 80 00       	push   $0x802618
  80103d:	68 99 00 00 00       	push   $0x99
  801042:	68 70 26 80 00       	push   $0x802670
  801047:	e8 04 0d 00 00       	call   801d50 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	ff 75 e4             	pushl  -0x1c(%ebp)
  801054:	e8 2c fc ff ff       	call   800c85 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 15                	jns    801075 <fork+0x223>
  801060:	50                   	push   %eax
  801061:	68 3c 26 80 00       	push   $0x80263c
  801066:	68 a4 00 00 00       	push   $0xa4
  80106b:	68 70 26 80 00       	push   $0x802670
  801070:	e8 db 0c 00 00       	call   801d50 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801078:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <sfork>:

// Challenge!
int
sfork(void)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801086:	68 98 26 80 00       	push   $0x802698
  80108b:	68 b1 00 00 00       	push   $0xb1
  801090:	68 70 26 80 00       	push   $0x802670
  801095:	e8 b6 0c 00 00       	call   801d50 <_panic>
	...

0080109c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	e8 e5 ff ff ff       	call   80109c <fd2num>
  8010b7:	83 c4 04             	add    $0x4,%esp
  8010ba:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010bf:	c1 e0 0c             	shl    $0xc,%eax
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010cb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 34                	je     801108 <fd_alloc+0x44>
  8010d4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010d9:	a8 01                	test   $0x1,%al
  8010db:	74 32                	je     80110f <fd_alloc+0x4b>
  8010dd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010e2:	89 c1                	mov    %eax,%ecx
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 1f                	je     801114 <fd_alloc+0x50>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	75 17                	jne    80111d <fd_alloc+0x59>
  801106:	eb 0c                	jmp    801114 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801108:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80110d:	eb 05                	jmp    801114 <fd_alloc+0x50>
  80110f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801114:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
  80111b:	eb 17                	jmp    801134 <fd_alloc+0x70>
  80111d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801122:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801127:	75 b9                	jne    8010e2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80112f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801134:	5b                   	pop    %ebx
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80113d:	83 f8 1f             	cmp    $0x1f,%eax
  801140:	77 36                	ja     801178 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801142:	05 00 00 0d 00       	add    $0xd0000,%eax
  801147:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80114a:	89 c2                	mov    %eax,%edx
  80114c:	c1 ea 16             	shr    $0x16,%edx
  80114f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801156:	f6 c2 01             	test   $0x1,%dl
  801159:	74 24                	je     80117f <fd_lookup+0x48>
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 0c             	shr    $0xc,%edx
  801160:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801167:	f6 c2 01             	test   $0x1,%dl
  80116a:	74 1a                	je     801186 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 02                	mov    %eax,(%edx)
	return 0;
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
  801176:	eb 13                	jmp    80118b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801178:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117d:	eb 0c                	jmp    80118b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80117f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801184:	eb 05                	jmp    80118b <fd_lookup+0x54>
  801186:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	53                   	push   %ebx
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80119a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011a0:	74 0d                	je     8011af <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	eb 14                	jmp    8011bd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011a9:	39 0a                	cmp    %ecx,(%edx)
  8011ab:	75 10                	jne    8011bd <dev_lookup+0x30>
  8011ad:	eb 05                	jmp    8011b4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011af:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011b4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	eb 31                	jmp    8011ee <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bd:	40                   	inc    %eax
  8011be:	8b 14 85 2c 27 80 00 	mov    0x80272c(,%eax,4),%edx
  8011c5:	85 d2                	test   %edx,%edx
  8011c7:	75 e0                	jne    8011a9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	51                   	push   %ecx
  8011d5:	50                   	push   %eax
  8011d6:	68 b0 26 80 00       	push   $0x8026b0
  8011db:	e8 00 f0 ff ff       	call   8001e0 <cprintf>
	*dev = 0;
  8011e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 20             	sub    $0x20,%esp
  8011fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fe:	8a 45 0c             	mov    0xc(%ebp),%al
  801201:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801204:	56                   	push   %esi
  801205:	e8 92 fe ff ff       	call   80109c <fd2num>
  80120a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80120d:	89 14 24             	mov    %edx,(%esp)
  801210:	50                   	push   %eax
  801211:	e8 21 ff ff ff       	call   801137 <fd_lookup>
  801216:	89 c3                	mov    %eax,%ebx
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 05                	js     801224 <fd_close+0x31>
	    || fd != fd2)
  80121f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801222:	74 0d                	je     801231 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801224:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801228:	75 48                	jne    801272 <fd_close+0x7f>
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122f:	eb 41                	jmp    801272 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 36                	pushl  (%esi)
  80123a:	e8 4e ff ff ff       	call   80118d <dev_lookup>
  80123f:	89 c3                	mov    %eax,%ebx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 1c                	js     801264 <fd_close+0x71>
		if (dev->dev_close)
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	8b 40 10             	mov    0x10(%eax),%eax
  80124e:	85 c0                	test   %eax,%eax
  801250:	74 0d                	je     80125f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	56                   	push   %esi
  801256:	ff d0                	call   *%eax
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	eb 05                	jmp    801264 <fd_close+0x71>
		else
			r = 0;
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	56                   	push   %esi
  801268:	6a 00                	push   $0x0
  80126a:	e8 f3 f9 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  80126f:	83 c4 10             	add    $0x10,%esp
}
  801272:	89 d8                	mov    %ebx,%eax
  801274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 aa fe ff ff       	call   801137 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 10                	js     8012a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	6a 01                	push   $0x1
  801299:	ff 75 f4             	pushl  -0xc(%ebp)
  80129c:	e8 52 ff ff ff       	call   8011f3 <fd_close>
  8012a1:	83 c4 10             	add    $0x10,%esp
}
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <close_all>:

void
close_all(void)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012b2:	83 ec 0c             	sub    $0xc,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	e8 c0 ff ff ff       	call   80127b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bb:	43                   	inc    %ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	83 fb 20             	cmp    $0x20,%ebx
  8012c2:	75 ee                	jne    8012b2 <close_all+0xc>
		close(i);
}
  8012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 2c             	sub    $0x2c,%esp
  8012d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 56 fe ff ff       	call   801137 <fd_lookup>
  8012e1:	89 c3                	mov    %eax,%ebx
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	0f 88 c0 00 00 00    	js     8013ae <dup+0xe5>
		return r;
	close(newfdnum);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	57                   	push   %edi
  8012f2:	e8 84 ff ff ff       	call   80127b <close>

	newfd = INDEX2FD(newfdnum);
  8012f7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012fd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801300:	83 c4 04             	add    $0x4,%esp
  801303:	ff 75 e4             	pushl  -0x1c(%ebp)
  801306:	e8 a1 fd ff ff       	call   8010ac <fd2data>
  80130b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80130d:	89 34 24             	mov    %esi,(%esp)
  801310:	e8 97 fd ff ff       	call   8010ac <fd2data>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80131b:	89 d8                	mov    %ebx,%eax
  80131d:	c1 e8 16             	shr    $0x16,%eax
  801320:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801327:	a8 01                	test   $0x1,%al
  801329:	74 37                	je     801362 <dup+0x99>
  80132b:	89 d8                	mov    %ebx,%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
  801330:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 26                	je     801362 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80133c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	25 07 0e 00 00       	and    $0xe07,%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	53                   	push   %ebx
  801352:	6a 00                	push   $0x0
  801354:	e8 e3 f8 ff ff       	call   800c3c <sys_page_map>
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 20             	add    $0x20,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 2d                	js     80138f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801365:	89 c2                	mov    %eax,%edx
  801367:	c1 ea 0c             	shr    $0xc,%edx
  80136a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80137a:	52                   	push   %edx
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	50                   	push   %eax
  80137f:	6a 00                	push   $0x0
  801381:	e8 b6 f8 ff ff       	call   800c3c <sys_page_map>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 20             	add    $0x20,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	79 1d                	jns    8013ac <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	56                   	push   %esi
  801393:	6a 00                	push   $0x0
  801395:	e8 c8 f8 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 bb f8 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb 02                	jmp    8013ae <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013ac:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013ae:	89 d8                	mov    %ebx,%eax
  8013b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	53                   	push   %ebx
  8013bc:	83 ec 14             	sub    $0x14,%esp
  8013bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	53                   	push   %ebx
  8013c7:	e8 6b fd ff ff       	call   801137 <fd_lookup>
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 67                	js     80143a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013dd:	ff 30                	pushl  (%eax)
  8013df:	e8 a9 fd ff ff       	call   80118d <dev_lookup>
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 4f                	js     80143a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	8b 50 08             	mov    0x8(%eax),%edx
  8013f1:	83 e2 03             	and    $0x3,%edx
  8013f4:	83 fa 01             	cmp    $0x1,%edx
  8013f7:	75 21                	jne    80141a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fe:	8b 40 48             	mov    0x48(%eax),%eax
  801401:	83 ec 04             	sub    $0x4,%esp
  801404:	53                   	push   %ebx
  801405:	50                   	push   %eax
  801406:	68 f1 26 80 00       	push   $0x8026f1
  80140b:	e8 d0 ed ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801418:	eb 20                	jmp    80143a <read+0x82>
	}
	if (!dev->dev_read)
  80141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141d:	8b 52 08             	mov    0x8(%edx),%edx
  801420:	85 d2                	test   %edx,%edx
  801422:	74 11                	je     801435 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	ff 75 10             	pushl  0x10(%ebp)
  80142a:	ff 75 0c             	pushl  0xc(%ebp)
  80142d:	50                   	push   %eax
  80142e:	ff d2                	call   *%edx
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	eb 05                	jmp    80143a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801435:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144e:	85 f6                	test   %esi,%esi
  801450:	74 31                	je     801483 <readn+0x44>
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
  801457:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	89 f2                	mov    %esi,%edx
  801461:	29 c2                	sub    %eax,%edx
  801463:	52                   	push   %edx
  801464:	03 45 0c             	add    0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	57                   	push   %edi
  801469:	e8 4a ff ff ff       	call   8013b8 <read>
		if (m < 0)
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 17                	js     80148c <readn+0x4d>
			return m;
		if (m == 0)
  801475:	85 c0                	test   %eax,%eax
  801477:	74 11                	je     80148a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801479:	01 c3                	add    %eax,%ebx
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	39 f3                	cmp    %esi,%ebx
  80147f:	72 db                	jb     80145c <readn+0x1d>
  801481:	eb 09                	jmp    80148c <readn+0x4d>
  801483:	b8 00 00 00 00       	mov    $0x0,%eax
  801488:	eb 02                	jmp    80148c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80148a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80148c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5f                   	pop    %edi
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 14             	sub    $0x14,%esp
  80149b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	53                   	push   %ebx
  8014a3:	e8 8f fc ff ff       	call   801137 <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 62                	js     801511 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	ff 30                	pushl  (%eax)
  8014bb:	e8 cd fc ff ff       	call   80118d <dev_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4a                	js     801511 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ce:	75 21                	jne    8014f1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d5:	8b 40 48             	mov    0x48(%eax),%eax
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	53                   	push   %ebx
  8014dc:	50                   	push   %eax
  8014dd:	68 0d 27 80 00       	push   $0x80270d
  8014e2:	e8 f9 ec ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ef:	eb 20                	jmp    801511 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f7:	85 d2                	test   %edx,%edx
  8014f9:	74 11                	je     80150c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	ff 75 10             	pushl  0x10(%ebp)
  801501:	ff 75 0c             	pushl  0xc(%ebp)
  801504:	50                   	push   %eax
  801505:	ff d2                	call   *%edx
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 05                	jmp    801511 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80150c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <seek>:

int
seek(int fdnum, off_t offset)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 0f fc ff ff       	call   801137 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 0e                	js     80153d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801532:	8b 55 0c             	mov    0xc(%ebp),%edx
  801535:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	53                   	push   %ebx
  801543:	83 ec 14             	sub    $0x14,%esp
  801546:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801549:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	53                   	push   %ebx
  80154e:	e8 e4 fb ff ff       	call   801137 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 5f                	js     8015b9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 22 fc ff ff       	call   80118d <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 47                	js     8015b9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801579:	75 21                	jne    80159c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801580:	8b 40 48             	mov    0x48(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 d0 26 80 00       	push   $0x8026d0
  80158d:	e8 4e ec ff ff       	call   8001e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159a:	eb 1d                	jmp    8015b9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	8b 52 18             	mov    0x18(%edx),%edx
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 0e                	je     8015b4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 05                	jmp    8015b9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 14             	sub    $0x14,%esp
  8015c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 63 fb ff ff       	call   801137 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 52                	js     80162d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 a1 fb ff ff       	call   80118d <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 3a                	js     80162d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fa:	74 2c                	je     801628 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801606:	00 00 00 
	stat->st_isdir = 0;
  801609:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801610:	00 00 00 
	stat->st_dev = dev;
  801613:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	53                   	push   %ebx
  80161d:	ff 75 f0             	pushl  -0x10(%ebp)
  801620:	ff 50 14             	call   *0x14(%eax)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 05                	jmp    80162d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801628:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	6a 00                	push   $0x0
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 78 01 00 00       	call   8017bc <open>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 1b                	js     801668 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	50                   	push   %eax
  801654:	e8 65 ff ff ff       	call   8015be <fstat>
  801659:	89 c6                	mov    %eax,%esi
	close(fd);
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 18 fc ff ff       	call   80127b <close>
	return r;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 f3                	mov    %esi,%ebx
}
  801668:	89 d8                	mov    %ebx,%eax
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	c9                   	leave  
  801670:	c3                   	ret    
  801671:	00 00                	add    %al,(%eax)
	...

00801674 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80167d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801684:	75 12                	jne    801698 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	6a 01                	push   $0x1
  80168b:	e8 66 08 00 00       	call   801ef6 <ipc_find_env>
  801690:	a3 00 40 80 00       	mov    %eax,0x804000
  801695:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801698:	6a 07                	push   $0x7
  80169a:	68 00 50 80 00       	push   $0x805000
  80169f:	53                   	push   %ebx
  8016a0:	ff 35 00 40 80 00    	pushl  0x804000
  8016a6:	e8 f6 07 00 00       	call   801ea1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016ab:	83 c4 0c             	add    $0xc,%esp
  8016ae:	6a 00                	push   $0x0
  8016b0:	56                   	push   %esi
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 74 07 00 00       	call   801e2c <ipc_recv>
}
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016de:	e8 91 ff ff ff       	call   801674 <fsipc>
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 2c                	js     801713 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	68 00 50 80 00       	push   $0x805000
  8016ef:	53                   	push   %ebx
  8016f0:	e8 a1 f0 ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f5:	a1 80 50 80 00       	mov    0x805080,%eax
  8016fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801700:	a1 84 50 80 00       	mov    0x805084,%eax
  801705:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	8b 40 0c             	mov    0xc(%eax),%eax
  801724:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	b8 06 00 00 00       	mov    $0x6,%eax
  801733:	e8 3c ff ff ff       	call   801674 <fsipc>
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	8b 40 0c             	mov    0xc(%eax),%eax
  801748:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80174d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 03 00 00 00       	mov    $0x3,%eax
  80175d:	e8 12 ff ff ff       	call   801674 <fsipc>
  801762:	89 c3                	mov    %eax,%ebx
  801764:	85 c0                	test   %eax,%eax
  801766:	78 4b                	js     8017b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801768:	39 c6                	cmp    %eax,%esi
  80176a:	73 16                	jae    801782 <devfile_read+0x48>
  80176c:	68 3c 27 80 00       	push   $0x80273c
  801771:	68 43 27 80 00       	push   $0x802743
  801776:	6a 7d                	push   $0x7d
  801778:	68 58 27 80 00       	push   $0x802758
  80177d:	e8 ce 05 00 00       	call   801d50 <_panic>
	assert(r <= PGSIZE);
  801782:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801787:	7e 16                	jle    80179f <devfile_read+0x65>
  801789:	68 63 27 80 00       	push   $0x802763
  80178e:	68 43 27 80 00       	push   $0x802743
  801793:	6a 7e                	push   $0x7e
  801795:	68 58 27 80 00       	push   $0x802758
  80179a:	e8 b1 05 00 00       	call   801d50 <_panic>
	memmove(buf, &fsipcbuf, r);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	50                   	push   %eax
  8017a3:	68 00 50 80 00       	push   $0x805000
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	e8 a7 f1 ff ff       	call   800957 <memmove>
	return r;
  8017b0:	83 c4 10             	add    $0x10,%esp
}
  8017b3:	89 d8                	mov    %ebx,%eax
  8017b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 1c             	sub    $0x1c,%esp
  8017c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c7:	56                   	push   %esi
  8017c8:	e8 77 ef ff ff       	call   800744 <strlen>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d5:	7f 65                	jg     80183c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 e1 f8 ff ff       	call   8010c4 <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 55                	js     801841 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	56                   	push   %esi
  8017f0:	68 00 50 80 00       	push   $0x805000
  8017f5:	e8 9c ef ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801802:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801805:	b8 01 00 00 00       	mov    $0x1,%eax
  80180a:	e8 65 fe ff ff       	call   801674 <fsipc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	79 12                	jns    80182a <open+0x6e>
		fd_close(fd, 0);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	6a 00                	push   $0x0
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 ce f9 ff ff       	call   8011f3 <fd_close>
		return r;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	eb 17                	jmp    801841 <open+0x85>
	}

	return fd2num(fd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	e8 67 f8 ff ff       	call   80109c <fd2num>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 05                	jmp    801841 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801841:	89 d8                	mov    %ebx,%eax
  801843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	c9                   	leave  
  801849:	c3                   	ret    
	...

0080184c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	56                   	push   %esi
  801850:	53                   	push   %ebx
  801851:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	e8 4d f8 ff ff       	call   8010ac <fd2data>
  80185f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801861:	83 c4 08             	add    $0x8,%esp
  801864:	68 6f 27 80 00       	push   $0x80276f
  801869:	56                   	push   %esi
  80186a:	e8 27 ef ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80186f:	8b 43 04             	mov    0x4(%ebx),%eax
  801872:	2b 03                	sub    (%ebx),%eax
  801874:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80187a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801881:	00 00 00 
	stat->st_dev = &devpipe;
  801884:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80188b:	30 80 00 
	return 0;
}
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
  801893:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801896:	5b                   	pop    %ebx
  801897:	5e                   	pop    %esi
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	53                   	push   %ebx
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018a4:	53                   	push   %ebx
  8018a5:	6a 00                	push   $0x0
  8018a7:	e8 b6 f3 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ac:	89 1c 24             	mov    %ebx,(%esp)
  8018af:	e8 f8 f7 ff ff       	call   8010ac <fd2data>
  8018b4:	83 c4 08             	add    $0x8,%esp
  8018b7:	50                   	push   %eax
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 a3 f3 ff ff       	call   800c62 <sys_page_unmap>
}
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	57                   	push   %edi
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 1c             	sub    $0x1c,%esp
  8018cd:	89 c7                	mov    %eax,%edi
  8018cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	57                   	push   %edi
  8018de:	e8 71 06 00 00       	call   801f54 <pageref>
  8018e3:	89 c6                	mov    %eax,%esi
  8018e5:	83 c4 04             	add    $0x4,%esp
  8018e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018eb:	e8 64 06 00 00       	call   801f54 <pageref>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	39 c6                	cmp    %eax,%esi
  8018f5:	0f 94 c0             	sete   %al
  8018f8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018fb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801901:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801904:	39 cb                	cmp    %ecx,%ebx
  801906:	75 08                	jne    801910 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801908:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801910:	83 f8 01             	cmp    $0x1,%eax
  801913:	75 bd                	jne    8018d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801915:	8b 42 58             	mov    0x58(%edx),%eax
  801918:	6a 01                	push   $0x1
  80191a:	50                   	push   %eax
  80191b:	53                   	push   %ebx
  80191c:	68 76 27 80 00       	push   $0x802776
  801921:	e8 ba e8 ff ff       	call   8001e0 <cprintf>
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	eb a7                	jmp    8018d2 <_pipeisclosed+0xe>

0080192b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 28             	sub    $0x28,%esp
  801934:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801937:	56                   	push   %esi
  801938:	e8 6f f7 ff ff       	call   8010ac <fd2data>
  80193d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801946:	75 4a                	jne    801992 <devpipe_write+0x67>
  801948:	bf 00 00 00 00       	mov    $0x0,%edi
  80194d:	eb 56                	jmp    8019a5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80194f:	89 da                	mov    %ebx,%edx
  801951:	89 f0                	mov    %esi,%eax
  801953:	e8 6c ff ff ff       	call   8018c4 <_pipeisclosed>
  801958:	85 c0                	test   %eax,%eax
  80195a:	75 4d                	jne    8019a9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80195c:	e8 90 f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801961:	8b 43 04             	mov    0x4(%ebx),%eax
  801964:	8b 13                	mov    (%ebx),%edx
  801966:	83 c2 20             	add    $0x20,%edx
  801969:	39 d0                	cmp    %edx,%eax
  80196b:	73 e2                	jae    80194f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80196d:	89 c2                	mov    %eax,%edx
  80196f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801975:	79 05                	jns    80197c <devpipe_write+0x51>
  801977:	4a                   	dec    %edx
  801978:	83 ca e0             	or     $0xffffffe0,%edx
  80197b:	42                   	inc    %edx
  80197c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801982:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801986:	40                   	inc    %eax
  801987:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198a:	47                   	inc    %edi
  80198b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80198e:	77 07                	ja     801997 <devpipe_write+0x6c>
  801990:	eb 13                	jmp    8019a5 <devpipe_write+0x7a>
  801992:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801997:	8b 43 04             	mov    0x4(%ebx),%eax
  80199a:	8b 13                	mov    (%ebx),%edx
  80199c:	83 c2 20             	add    $0x20,%edx
  80199f:	39 d0                	cmp    %edx,%eax
  8019a1:	73 ac                	jae    80194f <devpipe_write+0x24>
  8019a3:	eb c8                	jmp    80196d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019a5:	89 f8                	mov    %edi,%eax
  8019a7:	eb 05                	jmp    8019ae <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	57                   	push   %edi
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 18             	sub    $0x18,%esp
  8019bf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019c2:	57                   	push   %edi
  8019c3:	e8 e4 f6 ff ff       	call   8010ac <fd2data>
  8019c8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d1:	75 44                	jne    801a17 <devpipe_read+0x61>
  8019d3:	be 00 00 00 00       	mov    $0x0,%esi
  8019d8:	eb 4f                	jmp    801a29 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8019da:	89 f0                	mov    %esi,%eax
  8019dc:	eb 54                	jmp    801a32 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019de:	89 da                	mov    %ebx,%edx
  8019e0:	89 f8                	mov    %edi,%eax
  8019e2:	e8 dd fe ff ff       	call   8018c4 <_pipeisclosed>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	75 42                	jne    801a2d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019eb:	e8 01 f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f0:	8b 03                	mov    (%ebx),%eax
  8019f2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019f5:	74 e7                	je     8019de <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019f7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019fc:	79 05                	jns    801a03 <devpipe_read+0x4d>
  8019fe:	48                   	dec    %eax
  8019ff:	83 c8 e0             	or     $0xffffffe0,%eax
  801a02:	40                   	inc    %eax
  801a03:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a0d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0f:	46                   	inc    %esi
  801a10:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a13:	77 07                	ja     801a1c <devpipe_read+0x66>
  801a15:	eb 12                	jmp    801a29 <devpipe_read+0x73>
  801a17:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a1c:	8b 03                	mov    (%ebx),%eax
  801a1e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a21:	75 d4                	jne    8019f7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a23:	85 f6                	test   %esi,%esi
  801a25:	75 b3                	jne    8019da <devpipe_read+0x24>
  801a27:	eb b5                	jmp    8019de <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a29:	89 f0                	mov    %esi,%eax
  801a2b:	eb 05                	jmp    801a32 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5f                   	pop    %edi
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	57                   	push   %edi
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 28             	sub    $0x28,%esp
  801a43:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 75 f6 ff ff       	call   8010c4 <fd_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 24 01 00 00    	js     801b80 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 aa f1 ff ff       	call   800c18 <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 05 01 00 00    	js     801b80 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a81:	50                   	push   %eax
  801a82:	e8 3d f6 ff ff       	call   8010c4 <fd_alloc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	0f 88 dc 00 00 00    	js     801b70 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 72 f1 ff ff       	call   800c18 <sys_page_alloc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	0f 88 bd 00 00 00    	js     801b70 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab9:	e8 ee f5 ff ff       	call   8010ac <fd2data>
  801abe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	83 c4 0c             	add    $0xc,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	50                   	push   %eax
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 48 f1 ff ff       	call   800c18 <sys_page_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 88 83 00 00 00    	js     801b60 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae3:	e8 c4 f5 ff ff       	call   8010ac <fd2data>
  801ae8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aef:	50                   	push   %eax
  801af0:	6a 00                	push   $0x0
  801af2:	56                   	push   %esi
  801af3:	6a 00                	push   $0x0
  801af5:	e8 42 f1 ff ff       	call   800c3c <sys_page_map>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	83 c4 20             	add    $0x20,%esp
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 4f                	js     801b52 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b23:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b33:	e8 64 f5 ff ff       	call   80109c <fd2num>
  801b38:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b3a:	83 c4 04             	add    $0x4,%esp
  801b3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b40:	e8 57 f5 ff ff       	call   80109c <fd2num>
  801b45:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b50:	eb 2e                	jmp    801b80 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	56                   	push   %esi
  801b56:	6a 00                	push   $0x0
  801b58:	e8 05 f1 ff ff       	call   800c62 <sys_page_unmap>
  801b5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	ff 75 e0             	pushl  -0x20(%ebp)
  801b66:	6a 00                	push   $0x0
  801b68:	e8 f5 f0 ff ff       	call   800c62 <sys_page_unmap>
  801b6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b76:	6a 00                	push   $0x0
  801b78:	e8 e5 f0 ff ff       	call   800c62 <sys_page_unmap>
  801b7d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b93:	50                   	push   %eax
  801b94:	ff 75 08             	pushl  0x8(%ebp)
  801b97:	e8 9b f5 ff ff       	call   801137 <fd_lookup>
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 18                	js     801bbb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba9:	e8 fe f4 ff ff       	call   8010ac <fd2data>
	return _pipeisclosed(fd, p);
  801bae:	89 c2                	mov    %eax,%edx
  801bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb3:	e8 0c fd ff ff       	call   8018c4 <_pipeisclosed>
  801bb8:	83 c4 10             	add    $0x10,%esp
}
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    
  801bbd:	00 00                	add    %al,(%eax)
	...

00801bc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bd0:	68 8e 27 80 00       	push   $0x80278e
  801bd5:	ff 75 0c             	pushl  0xc(%ebp)
  801bd8:	e8 b9 eb ff ff       	call   800796 <strcpy>
	return 0;
}
  801bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf4:	74 45                	je     801c3b <devcons_write+0x57>
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c00:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c09:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c0b:	83 fb 7f             	cmp    $0x7f,%ebx
  801c0e:	76 05                	jbe    801c15 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c10:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c15:	83 ec 04             	sub    $0x4,%esp
  801c18:	53                   	push   %ebx
  801c19:	03 45 0c             	add    0xc(%ebp),%eax
  801c1c:	50                   	push   %eax
  801c1d:	57                   	push   %edi
  801c1e:	e8 34 ed ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801c23:	83 c4 08             	add    $0x8,%esp
  801c26:	53                   	push   %ebx
  801c27:	57                   	push   %edi
  801c28:	e8 34 ef ff ff       	call   800b61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2d:	01 de                	add    %ebx,%esi
  801c2f:	89 f0                	mov    %esi,%eax
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c37:	72 cd                	jb     801c06 <devcons_write+0x22>
  801c39:	eb 05                	jmp    801c40 <devcons_write+0x5c>
  801c3b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c40:	89 f0                	mov    %esi,%eax
  801c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5f                   	pop    %edi
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c54:	75 07                	jne    801c5d <devcons_read+0x13>
  801c56:	eb 25                	jmp    801c7d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c58:	e8 94 ef ff ff       	call   800bf1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c5d:	e8 25 ef ff ff       	call   800b87 <sys_cgetc>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	74 f2                	je     801c58 <devcons_read+0xe>
  801c66:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 1d                	js     801c89 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c6c:	83 f8 04             	cmp    $0x4,%eax
  801c6f:	74 13                	je     801c84 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c74:	88 10                	mov    %dl,(%eax)
	return 1;
  801c76:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7b:	eb 0c                	jmp    801c89 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c82:	eb 05                	jmp    801c89 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c97:	6a 01                	push   $0x1
  801c99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	e8 bf ee ff ff       	call   800b61 <sys_cputs>
  801ca2:	83 c4 10             	add    $0x10,%esp
}
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <getchar>:

int
getchar(void)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cad:	6a 01                	push   $0x1
  801caf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb2:	50                   	push   %eax
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 fe f6 ff ff       	call   8013b8 <read>
	if (r < 0)
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 0f                	js     801cd0 <getchar+0x29>
		return r;
	if (r < 1)
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	7e 06                	jle    801ccb <getchar+0x24>
		return -E_EOF;
	return c;
  801cc5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc9:	eb 05                	jmp    801cd0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ccb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdb:	50                   	push   %eax
  801cdc:	ff 75 08             	pushl  0x8(%ebp)
  801cdf:	e8 53 f4 ff ff       	call   801137 <fd_lookup>
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 11                	js     801cfc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf4:	39 10                	cmp    %edx,(%eax)
  801cf6:	0f 94 c0             	sete   %al
  801cf9:	0f b6 c0             	movzbl %al,%eax
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <opencons>:

int
opencons(void)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	e8 b7 f3 ff ff       	call   8010c4 <fd_alloc>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 3a                	js     801d4e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d14:	83 ec 04             	sub    $0x4,%esp
  801d17:	68 07 04 00 00       	push   $0x407
  801d1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 f2 ee ff ff       	call   800c18 <sys_page_alloc>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 21                	js     801d4e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	50                   	push   %eax
  801d46:	e8 51 f3 ff ff       	call   80109c <fd2num>
  801d4b:	83 c4 10             	add    $0x10,%esp
}
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    

00801d50 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d55:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d58:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d5e:	e8 6a ee ff ff       	call   800bcd <sys_getenvid>
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	ff 75 08             	pushl  0x8(%ebp)
  801d6c:	53                   	push   %ebx
  801d6d:	50                   	push   %eax
  801d6e:	68 9c 27 80 00       	push   $0x80279c
  801d73:	e8 68 e4 ff ff       	call   8001e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d78:	83 c4 18             	add    $0x18,%esp
  801d7b:	56                   	push   %esi
  801d7c:	ff 75 10             	pushl  0x10(%ebp)
  801d7f:	e8 0b e4 ff ff       	call   80018f <vcprintf>
	cprintf("\n");
  801d84:	c7 04 24 ef 21 80 00 	movl   $0x8021ef,(%esp)
  801d8b:	e8 50 e4 ff ff       	call   8001e0 <cprintf>
  801d90:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d93:	cc                   	int3   
  801d94:	eb fd                	jmp    801d93 <_panic+0x43>
	...

00801d98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da5:	75 52                	jne    801df9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	6a 07                	push   $0x7
  801dac:	68 00 f0 bf ee       	push   $0xeebff000
  801db1:	6a 00                	push   $0x0
  801db3:	e8 60 ee ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) {
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	79 12                	jns    801dd1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801dbf:	50                   	push   %eax
  801dc0:	68 bf 27 80 00       	push   $0x8027bf
  801dc5:	6a 24                	push   $0x24
  801dc7:	68 da 27 80 00       	push   $0x8027da
  801dcc:	e8 7f ff ff ff       	call   801d50 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	68 04 1e 80 00       	push   $0x801e04
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 eb ee ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	79 12                	jns    801df9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801de7:	50                   	push   %eax
  801de8:	68 e8 27 80 00       	push   $0x8027e8
  801ded:	6a 2a                	push   $0x2a
  801def:	68 da 27 80 00       	push   $0x8027da
  801df4:	e8 57 ff ff ff       	call   801d50 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    
	...

00801e04 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e04:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e05:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e0a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e0c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e0f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e13:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e16:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e1a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e1e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e20:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e23:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e24:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e27:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e28:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e29:	c3                   	ret    
	...

00801e2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	56                   	push   %esi
  801e30:	53                   	push   %ebx
  801e31:	8b 75 08             	mov    0x8(%ebp),%esi
  801e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	74 0e                	je     801e4c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	50                   	push   %eax
  801e42:	e8 cc ee ff ff       	call   800d13 <sys_ipc_recv>
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	eb 10                	jmp    801e5c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	68 00 00 c0 ee       	push   $0xeec00000
  801e54:	e8 ba ee ff ff       	call   800d13 <sys_ipc_recv>
  801e59:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	75 26                	jne    801e86 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e60:	85 f6                	test   %esi,%esi
  801e62:	74 0a                	je     801e6e <ipc_recv+0x42>
  801e64:	a1 04 40 80 00       	mov    0x804004,%eax
  801e69:	8b 40 74             	mov    0x74(%eax),%eax
  801e6c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e6e:	85 db                	test   %ebx,%ebx
  801e70:	74 0a                	je     801e7c <ipc_recv+0x50>
  801e72:	a1 04 40 80 00       	mov    0x804004,%eax
  801e77:	8b 40 78             	mov    0x78(%eax),%eax
  801e7a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 40 70             	mov    0x70(%eax),%eax
  801e84:	eb 14                	jmp    801e9a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e86:	85 f6                	test   %esi,%esi
  801e88:	74 06                	je     801e90 <ipc_recv+0x64>
  801e8a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801e90:	85 db                	test   %ebx,%ebx
  801e92:	74 06                	je     801e9a <ipc_recv+0x6e>
  801e94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	57                   	push   %edi
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eb0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801eb3:	85 db                	test   %ebx,%ebx
  801eb5:	75 25                	jne    801edc <ipc_send+0x3b>
  801eb7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ebc:	eb 1e                	jmp    801edc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ebe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec1:	75 07                	jne    801eca <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ec3:	e8 29 ed ff ff       	call   800bf1 <sys_yield>
  801ec8:	eb 12                	jmp    801edc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801eca:	50                   	push   %eax
  801ecb:	68 10 28 80 00       	push   $0x802810
  801ed0:	6a 43                	push   $0x43
  801ed2:	68 23 28 80 00       	push   $0x802823
  801ed7:	e8 74 fe ff ff       	call   801d50 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	57                   	push   %edi
  801edf:	ff 75 08             	pushl  0x8(%ebp)
  801ee2:	e8 07 ee ff ff       	call   800cee <sys_ipc_try_send>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	75 d0                	jne    801ebe <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801eee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5f                   	pop    %edi
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	53                   	push   %ebx
  801efa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801efd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801f03:	74 22                	je     801f27 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f05:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f0a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f11:	89 c2                	mov    %eax,%edx
  801f13:	c1 e2 07             	shl    $0x7,%edx
  801f16:	29 ca                	sub    %ecx,%edx
  801f18:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1e:	8b 52 50             	mov    0x50(%edx),%edx
  801f21:	39 da                	cmp    %ebx,%edx
  801f23:	75 1d                	jne    801f42 <ipc_find_env+0x4c>
  801f25:	eb 05                	jmp    801f2c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f33:	c1 e0 07             	shl    $0x7,%eax
  801f36:	29 d0                	sub    %edx,%eax
  801f38:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f3d:	8b 40 40             	mov    0x40(%eax),%eax
  801f40:	eb 0c                	jmp    801f4e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f42:	40                   	inc    %eax
  801f43:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f48:	75 c0                	jne    801f0a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f4a:	66 b8 00 00          	mov    $0x0,%ax
}
  801f4e:	5b                   	pop    %ebx
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    
  801f51:	00 00                	add    %al,(%eax)
	...

00801f54 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	c1 ea 16             	shr    $0x16,%edx
  801f5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f66:	f6 c2 01             	test   $0x1,%dl
  801f69:	74 1e                	je     801f89 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6b:	c1 e8 0c             	shr    $0xc,%eax
  801f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f75:	a8 01                	test   $0x1,%al
  801f77:	74 17                	je     801f90 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f79:	c1 e8 0c             	shr    $0xc,%eax
  801f7c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f83:	ef 
  801f84:	0f b7 c0             	movzwl %ax,%eax
  801f87:	eb 0c                	jmp    801f95 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	eb 05                	jmp    801f95 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    
	...

00801f98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	57                   	push   %edi
  801f9c:	56                   	push   %esi
  801f9d:	83 ec 10             	sub    $0x10,%esp
  801fa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fa6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801faf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	75 2e                	jne    801fe4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fb6:	39 f1                	cmp    %esi,%ecx
  801fb8:	77 5a                	ja     802014 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fba:	85 c9                	test   %ecx,%ecx
  801fbc:	75 0b                	jne    801fc9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc3:	31 d2                	xor    %edx,%edx
  801fc5:	f7 f1                	div    %ecx
  801fc7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fc9:	31 d2                	xor    %edx,%edx
  801fcb:	89 f0                	mov    %esi,%eax
  801fcd:	f7 f1                	div    %ecx
  801fcf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fd1:	89 f8                	mov    %edi,%eax
  801fd3:	f7 f1                	div    %ecx
  801fd5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd7:	89 f8                	mov    %edi,%eax
  801fd9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    
  801fe2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fe4:	39 f0                	cmp    %esi,%eax
  801fe6:	77 1c                	ja     802004 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fe8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801feb:	83 f7 1f             	xor    $0x1f,%edi
  801fee:	75 3c                	jne    80202c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff0:	39 f0                	cmp    %esi,%eax
  801ff2:	0f 82 90 00 00 00    	jb     802088 <__udivdi3+0xf0>
  801ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ffb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ffe:	0f 86 84 00 00 00    	jbe    802088 <__udivdi3+0xf0>
  802004:	31 f6                	xor    %esi,%esi
  802006:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802008:	89 f8                	mov    %edi,%eax
  80200a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	c9                   	leave  
  802012:	c3                   	ret    
  802013:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802014:	89 f2                	mov    %esi,%edx
  802016:	89 f8                	mov    %edi,%eax
  802018:	f7 f1                	div    %ecx
  80201a:	89 c7                	mov    %eax,%edi
  80201c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80201e:	89 f8                	mov    %edi,%eax
  802020:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	c9                   	leave  
  802028:	c3                   	ret    
  802029:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80202c:	89 f9                	mov    %edi,%ecx
  80202e:	d3 e0                	shl    %cl,%eax
  802030:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802033:	b8 20 00 00 00       	mov    $0x20,%eax
  802038:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80203a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203d:	88 c1                	mov    %al,%cl
  80203f:	d3 ea                	shr    %cl,%edx
  802041:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802044:	09 ca                	or     %ecx,%edx
  802046:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802049:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204c:	89 f9                	mov    %edi,%ecx
  80204e:	d3 e2                	shl    %cl,%edx
  802050:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802053:	89 f2                	mov    %esi,%edx
  802055:	88 c1                	mov    %al,%cl
  802057:	d3 ea                	shr    %cl,%edx
  802059:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	89 f9                	mov    %edi,%ecx
  802060:	d3 e2                	shl    %cl,%edx
  802062:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802065:	88 c1                	mov    %al,%cl
  802067:	d3 ee                	shr    %cl,%esi
  802069:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80206b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80206e:	89 f0                	mov    %esi,%eax
  802070:	89 ca                	mov    %ecx,%edx
  802072:	f7 75 ec             	divl   -0x14(%ebp)
  802075:	89 d1                	mov    %edx,%ecx
  802077:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802079:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80207c:	39 d1                	cmp    %edx,%ecx
  80207e:	72 28                	jb     8020a8 <__udivdi3+0x110>
  802080:	74 1a                	je     80209c <__udivdi3+0x104>
  802082:	89 f7                	mov    %esi,%edi
  802084:	31 f6                	xor    %esi,%esi
  802086:	eb 80                	jmp    802008 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802088:	31 f6                	xor    %esi,%esi
  80208a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80208f:	89 f8                	mov    %edi,%eax
  802091:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	c9                   	leave  
  802099:	c3                   	ret    
  80209a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80209c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80209f:	89 f9                	mov    %edi,%ecx
  8020a1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020a3:	39 c2                	cmp    %eax,%edx
  8020a5:	73 db                	jae    802082 <__udivdi3+0xea>
  8020a7:	90                   	nop
		{
		  q0--;
  8020a8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020ab:	31 f6                	xor    %esi,%esi
  8020ad:	e9 56 ff ff ff       	jmp    802008 <__udivdi3+0x70>
	...

008020b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	57                   	push   %edi
  8020b8:	56                   	push   %esi
  8020b9:	83 ec 20             	sub    $0x20,%esp
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020d1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020d3:	85 ff                	test   %edi,%edi
  8020d5:	75 15                	jne    8020ec <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020d7:	39 f1                	cmp    %esi,%ecx
  8020d9:	0f 86 99 00 00 00    	jbe    802178 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020df:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020e1:	89 d0                	mov    %edx,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020e5:	83 c4 20             	add    $0x20,%esp
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	0f 87 a4 00 00 00    	ja     802198 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020f4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020f7:	83 f0 1f             	xor    $0x1f,%eax
  8020fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020fd:	0f 84 a1 00 00 00    	je     8021a4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802103:	89 f8                	mov    %edi,%eax
  802105:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802108:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80210a:	bf 20 00 00 00       	mov    $0x20,%edi
  80210f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802112:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 ea                	shr    %cl,%edx
  802119:	09 c2                	or     %eax,%edx
  80211b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802124:	d3 e0                	shl    %cl,%eax
  802126:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802129:	89 f2                	mov    %esi,%edx
  80212b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80212d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802130:	d3 e0                	shl    %cl,%eax
  802132:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802135:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802138:	89 f9                	mov    %edi,%ecx
  80213a:	d3 e8                	shr    %cl,%eax
  80213c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80213e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802140:	89 f2                	mov    %esi,%edx
  802142:	f7 75 f0             	divl   -0x10(%ebp)
  802145:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802147:	f7 65 f4             	mull   -0xc(%ebp)
  80214a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80214d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80214f:	39 d6                	cmp    %edx,%esi
  802151:	72 71                	jb     8021c4 <__umoddi3+0x110>
  802153:	74 7f                	je     8021d4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802158:	29 c8                	sub    %ecx,%eax
  80215a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80215c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80215f:	d3 e8                	shr    %cl,%eax
  802161:	89 f2                	mov    %esi,%edx
  802163:	89 f9                	mov    %edi,%ecx
  802165:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802167:	09 d0                	or     %edx,%eax
  802169:	89 f2                	mov    %esi,%edx
  80216b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80216e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802170:	83 c4 20             	add    $0x20,%esp
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	c9                   	leave  
  802176:	c3                   	ret    
  802177:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802178:	85 c9                	test   %ecx,%ecx
  80217a:	75 0b                	jne    802187 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80217c:	b8 01 00 00 00       	mov    $0x1,%eax
  802181:	31 d2                	xor    %edx,%edx
  802183:	f7 f1                	div    %ecx
  802185:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802187:	89 f0                	mov    %esi,%eax
  802189:	31 d2                	xor    %edx,%edx
  80218b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802190:	f7 f1                	div    %ecx
  802192:	e9 4a ff ff ff       	jmp    8020e1 <__umoddi3+0x2d>
  802197:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802198:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80219a:	83 c4 20             	add    $0x20,%esp
  80219d:	5e                   	pop    %esi
  80219e:	5f                   	pop    %edi
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    
  8021a1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021a4:	39 f7                	cmp    %esi,%edi
  8021a6:	72 05                	jb     8021ad <__umoddi3+0xf9>
  8021a8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021ab:	77 0c                	ja     8021b9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b2:	29 c8                	sub    %ecx,%eax
  8021b4:	19 fa                	sbb    %edi,%edx
  8021b6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021bc:	83 c4 20             	add    $0x20,%esp
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    
  8021c3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021cc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021cf:	eb 84                	jmp    802155 <__umoddi3+0xa1>
  8021d1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021d4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021d7:	72 eb                	jb     8021c4 <__umoddi3+0x110>
  8021d9:	89 f2                	mov    %esi,%edx
  8021db:	e9 75 ff ff ff       	jmp    802155 <__umoddi3+0xa1>
