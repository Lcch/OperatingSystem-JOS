
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
  80013a:	e8 fb 10 00 00       	call   80123a <close_all>
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
  800248:	e8 2f 1d 00 00       	call   801f7c <__udivdi3>
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
  800284:	e8 0f 1e 00 00       	call   802098 <__umoddi3>
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
  8004a2:	68 5b 27 80 00       	push   $0x80275b
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
  800b52:	e8 ad 11 00 00       	call   801d04 <_panic>

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
  800d6d:	68 2c 25 80 00       	push   $0x80252c
  800d72:	6a 20                	push   $0x20
  800d74:	68 70 26 80 00       	push   $0x802670
  800d79:	e8 86 0f 00 00       	call   801d04 <_panic>

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
  800da2:	68 50 25 80 00       	push   $0x802550
  800da7:	6a 24                	push   $0x24
  800da9:	68 70 26 80 00       	push   $0x802670
  800dae:	e8 51 0f 00 00       	call   801d04 <_panic>
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
  800dcc:	68 74 25 80 00       	push   $0x802574
  800dd1:	6a 32                	push   $0x32
  800dd3:	68 70 26 80 00       	push   $0x802670
  800dd8:	e8 27 0f 00 00       	call   801d04 <_panic>

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
  800e14:	68 98 25 80 00       	push   $0x802598
  800e19:	6a 3a                	push   $0x3a
  800e1b:	68 70 26 80 00       	push   $0x802670
  800e20:	e8 df 0e 00 00       	call   801d04 <_panic>

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
  800e38:	e8 0f 0f 00 00       	call   801d4c <set_pgfault_handler>
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
  800e53:	68 7b 26 80 00       	push   $0x80267b
  800e58:	6a 7b                	push   $0x7b
  800e5a:	68 70 26 80 00       	push   $0x802670
  800e5f:	e8 a0 0e 00 00       	call   801d04 <_panic>
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
  800e8a:	e9 7b 01 00 00       	jmp    80100a <fork+0x1e0>
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
  800ea2:	0f 84 cd 00 00 00    	je     800f75 <fork+0x14b>
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	c1 e8 0c             	shr    $0xc,%eax
  800ead:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	0f 84 b8 00 00 00    	je     800f75 <fork+0x14b>
  800ebd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec4:	f6 c2 04             	test   $0x4,%dl
  800ec7:	0f 84 a8 00 00 00    	je     800f75 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ecd:	89 c6                	mov    %eax,%esi
  800ecf:	c1 e6 0c             	shl    $0xc,%esi
  800ed2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ed8:	0f 84 97 00 00 00    	je     800f75 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ede:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee5:	f6 c2 02             	test   $0x2,%dl
  800ee8:	75 0c                	jne    800ef6 <fork+0xcc>
  800eea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef1:	f6 c4 08             	test   $0x8,%ah
  800ef4:	74 57                	je     800f4d <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	68 05 08 00 00       	push   $0x805
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	6a 00                	push   $0x0
  800f03:	e8 34 fd ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	79 12                	jns    800f21 <fork+0xf7>
  800f0f:	50                   	push   %eax
  800f10:	68 bc 25 80 00       	push   $0x8025bc
  800f15:	6a 55                	push   $0x55
  800f17:	68 70 26 80 00       	push   $0x802670
  800f1c:	e8 e3 0d 00 00       	call   801d04 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	68 05 08 00 00       	push   $0x805
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	56                   	push   %esi
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 08 fd ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 3a                	jns    800f75 <fork+0x14b>
  800f3b:	50                   	push   %eax
  800f3c:	68 bc 25 80 00       	push   $0x8025bc
  800f41:	6a 58                	push   $0x58
  800f43:	68 70 26 80 00       	push   $0x802670
  800f48:	e8 b7 0d 00 00       	call   801d04 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	6a 05                	push   $0x5
  800f52:	56                   	push   %esi
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	6a 00                	push   $0x0
  800f57:	e8 e0 fc ff ff       	call   800c3c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <fork+0x14b>
  800f63:	50                   	push   %eax
  800f64:	68 bc 25 80 00       	push   $0x8025bc
  800f69:	6a 5c                	push   $0x5c
  800f6b:	68 70 26 80 00       	push   $0x802670
  800f70:	e8 8f 0d 00 00       	call   801d04 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f81:	0f 85 0d ff ff ff    	jne    800e94 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	6a 07                	push   $0x7
  800f8c:	68 00 f0 bf ee       	push   $0xeebff000
  800f91:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f94:	e8 7f fc ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	79 15                	jns    800fb5 <fork+0x18b>
  800fa0:	50                   	push   %eax
  800fa1:	68 e0 25 80 00       	push   $0x8025e0
  800fa6:	68 90 00 00 00       	push   $0x90
  800fab:	68 70 26 80 00       	push   $0x802670
  800fb0:	e8 4f 0d 00 00       	call   801d04 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	68 b8 1d 80 00       	push   $0x801db8
  800fbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc0:	e8 06 fd ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 15                	jns    800fe1 <fork+0x1b7>
  800fcc:	50                   	push   %eax
  800fcd:	68 18 26 80 00       	push   $0x802618
  800fd2:	68 95 00 00 00       	push   $0x95
  800fd7:	68 70 26 80 00       	push   $0x802670
  800fdc:	e8 23 0d 00 00       	call   801d04 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	6a 02                	push   $0x2
  800fe6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe9:	e8 97 fc ff ff       	call   800c85 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 15                	jns    80100a <fork+0x1e0>
  800ff5:	50                   	push   %eax
  800ff6:	68 3c 26 80 00       	push   $0x80263c
  800ffb:	68 a0 00 00 00       	push   $0xa0
  801000:	68 70 26 80 00       	push   $0x802670
  801005:	e8 fa 0c 00 00       	call   801d04 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80100a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <sfork>:

// Challenge!
int
sfork(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80101b:	68 98 26 80 00       	push   $0x802698
  801020:	68 ad 00 00 00       	push   $0xad
  801025:	68 70 26 80 00       	push   $0x802670
  80102a:	e8 d5 0c 00 00       	call   801d04 <_panic>
	...

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801043:	ff 75 08             	pushl  0x8(%ebp)
  801046:	e8 e5 ff ff ff       	call   801030 <fd2num>
  80104b:	83 c4 04             	add    $0x4,%esp
  80104e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801053:	c1 e0 0c             	shl    $0xc,%eax
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80105f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801064:	a8 01                	test   $0x1,%al
  801066:	74 34                	je     80109c <fd_alloc+0x44>
  801068:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80106d:	a8 01                	test   $0x1,%al
  80106f:	74 32                	je     8010a3 <fd_alloc+0x4b>
  801071:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801076:	89 c1                	mov    %eax,%ecx
  801078:	89 c2                	mov    %eax,%edx
  80107a:	c1 ea 16             	shr    $0x16,%edx
  80107d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801084:	f6 c2 01             	test   $0x1,%dl
  801087:	74 1f                	je     8010a8 <fd_alloc+0x50>
  801089:	89 c2                	mov    %eax,%edx
  80108b:	c1 ea 0c             	shr    $0xc,%edx
  80108e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801095:	f6 c2 01             	test   $0x1,%dl
  801098:	75 17                	jne    8010b1 <fd_alloc+0x59>
  80109a:	eb 0c                	jmp    8010a8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80109c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010a1:	eb 05                	jmp    8010a8 <fd_alloc+0x50>
  8010a3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010a8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010af:	eb 17                	jmp    8010c8 <fd_alloc+0x70>
  8010b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010bb:	75 b9                	jne    801076 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8010c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c8:	5b                   	pop    %ebx
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d1:	83 f8 1f             	cmp    $0x1f,%eax
  8010d4:	77 36                	ja     80110c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010db:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 16             	shr    $0x16,%edx
  8010e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 24                	je     801113 <fd_lookup+0x48>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	c1 ea 0c             	shr    $0xc,%edx
  8010f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fb:	f6 c2 01             	test   $0x1,%dl
  8010fe:	74 1a                	je     80111a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801100:	8b 55 0c             	mov    0xc(%ebp),%edx
  801103:	89 02                	mov    %eax,(%edx)
	return 0;
  801105:	b8 00 00 00 00       	mov    $0x0,%eax
  80110a:	eb 13                	jmp    80111f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801111:	eb 0c                	jmp    80111f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801113:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801118:	eb 05                	jmp    80111f <fd_lookup+0x54>
  80111a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	53                   	push   %ebx
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80112e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801134:	74 0d                	je     801143 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801136:	b8 00 00 00 00       	mov    $0x0,%eax
  80113b:	eb 14                	jmp    801151 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80113d:	39 0a                	cmp    %ecx,(%edx)
  80113f:	75 10                	jne    801151 <dev_lookup+0x30>
  801141:	eb 05                	jmp    801148 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801143:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801148:	89 13                	mov    %edx,(%ebx)
			return 0;
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
  80114f:	eb 31                	jmp    801182 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801151:	40                   	inc    %eax
  801152:	8b 14 85 2c 27 80 00 	mov    0x80272c(,%eax,4),%edx
  801159:	85 d2                	test   %edx,%edx
  80115b:	75 e0                	jne    80113d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80115d:	a1 04 40 80 00       	mov    0x804004,%eax
  801162:	8b 40 48             	mov    0x48(%eax),%eax
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	51                   	push   %ecx
  801169:	50                   	push   %eax
  80116a:	68 b0 26 80 00       	push   $0x8026b0
  80116f:	e8 6c f0 ff ff       	call   8001e0 <cprintf>
	*dev = 0;
  801174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	83 ec 20             	sub    $0x20,%esp
  80118f:	8b 75 08             	mov    0x8(%ebp),%esi
  801192:	8a 45 0c             	mov    0xc(%ebp),%al
  801195:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801198:	56                   	push   %esi
  801199:	e8 92 fe ff ff       	call   801030 <fd2num>
  80119e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011a1:	89 14 24             	mov    %edx,(%esp)
  8011a4:	50                   	push   %eax
  8011a5:	e8 21 ff ff ff       	call   8010cb <fd_lookup>
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 08             	add    $0x8,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 05                	js     8011b8 <fd_close+0x31>
	    || fd != fd2)
  8011b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b6:	74 0d                	je     8011c5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011b8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011bc:	75 48                	jne    801206 <fd_close+0x7f>
  8011be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c3:	eb 41                	jmp    801206 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff 36                	pushl  (%esi)
  8011ce:	e8 4e ff ff ff       	call   801121 <dev_lookup>
  8011d3:	89 c3                	mov    %eax,%ebx
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 1c                	js     8011f8 <fd_close+0x71>
		if (dev->dev_close)
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	8b 40 10             	mov    0x10(%eax),%eax
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 0d                	je     8011f3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8011e6:	83 ec 0c             	sub    $0xc,%esp
  8011e9:	56                   	push   %esi
  8011ea:	ff d0                	call   *%eax
  8011ec:	89 c3                	mov    %eax,%ebx
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	eb 05                	jmp    8011f8 <fd_close+0x71>
		else
			r = 0;
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	56                   	push   %esi
  8011fc:	6a 00                	push   $0x0
  8011fe:	e8 5f fa ff ff       	call   800c62 <sys_page_unmap>
	return r;
  801203:	83 c4 10             	add    $0x10,%esp
}
  801206:	89 d8                	mov    %ebx,%eax
  801208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 75 08             	pushl  0x8(%ebp)
  80121c:	e8 aa fe ff ff       	call   8010cb <fd_lookup>
  801221:	83 c4 08             	add    $0x8,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 10                	js     801238 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	6a 01                	push   $0x1
  80122d:	ff 75 f4             	pushl  -0xc(%ebp)
  801230:	e8 52 ff ff ff       	call   801187 <fd_close>
  801235:	83 c4 10             	add    $0x10,%esp
}
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <close_all>:

void
close_all(void)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	53                   	push   %ebx
  80123e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801241:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	53                   	push   %ebx
  80124a:	e8 c0 ff ff ff       	call   80120f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80124f:	43                   	inc    %ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	83 fb 20             	cmp    $0x20,%ebx
  801256:	75 ee                	jne    801246 <close_all+0xc>
		close(i);
}
  801258:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 2c             	sub    $0x2c,%esp
  801266:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801269:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 56 fe ff ff       	call   8010cb <fd_lookup>
  801275:	89 c3                	mov    %eax,%ebx
  801277:	83 c4 08             	add    $0x8,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	0f 88 c0 00 00 00    	js     801342 <dup+0xe5>
		return r;
	close(newfdnum);
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	57                   	push   %edi
  801286:	e8 84 ff ff ff       	call   80120f <close>

	newfd = INDEX2FD(newfdnum);
  80128b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801291:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801294:	83 c4 04             	add    $0x4,%esp
  801297:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129a:	e8 a1 fd ff ff       	call   801040 <fd2data>
  80129f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012a1:	89 34 24             	mov    %esi,(%esp)
  8012a4:	e8 97 fd ff ff       	call   801040 <fd2data>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012af:	89 d8                	mov    %ebx,%eax
  8012b1:	c1 e8 16             	shr    $0x16,%eax
  8012b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012bb:	a8 01                	test   $0x1,%al
  8012bd:	74 37                	je     8012f6 <dup+0x99>
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	c1 e8 0c             	shr    $0xc,%eax
  8012c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012cb:	f6 c2 01             	test   $0x1,%dl
  8012ce:	74 26                	je     8012f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	25 07 0e 00 00       	and    $0xe07,%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e3:	6a 00                	push   $0x0
  8012e5:	53                   	push   %ebx
  8012e6:	6a 00                	push   $0x0
  8012e8:	e8 4f f9 ff ff       	call   800c3c <sys_page_map>
  8012ed:	89 c3                	mov    %eax,%ebx
  8012ef:	83 c4 20             	add    $0x20,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 2d                	js     801323 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 0c             	shr    $0xc,%edx
  8012fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80130e:	52                   	push   %edx
  80130f:	56                   	push   %esi
  801310:	6a 00                	push   $0x0
  801312:	50                   	push   %eax
  801313:	6a 00                	push   $0x0
  801315:	e8 22 f9 ff ff       	call   800c3c <sys_page_map>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 20             	add    $0x20,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	79 1d                	jns    801340 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	56                   	push   %esi
  801327:	6a 00                	push   $0x0
  801329:	e8 34 f9 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	ff 75 d4             	pushl  -0x2c(%ebp)
  801334:	6a 00                	push   $0x0
  801336:	e8 27 f9 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	eb 02                	jmp    801342 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801340:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801342:	89 d8                	mov    %ebx,%eax
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 14             	sub    $0x14,%esp
  801353:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801356:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	53                   	push   %ebx
  80135b:	e8 6b fd ff ff       	call   8010cb <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 67                	js     8013ce <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136d:	50                   	push   %eax
  80136e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801371:	ff 30                	pushl  (%eax)
  801373:	e8 a9 fd ff ff       	call   801121 <dev_lookup>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 4f                	js     8013ce <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801382:	8b 50 08             	mov    0x8(%eax),%edx
  801385:	83 e2 03             	and    $0x3,%edx
  801388:	83 fa 01             	cmp    $0x1,%edx
  80138b:	75 21                	jne    8013ae <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138d:	a1 04 40 80 00       	mov    0x804004,%eax
  801392:	8b 40 48             	mov    0x48(%eax),%eax
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	53                   	push   %ebx
  801399:	50                   	push   %eax
  80139a:	68 f1 26 80 00       	push   $0x8026f1
  80139f:	e8 3c ee ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ac:	eb 20                	jmp    8013ce <read+0x82>
	}
	if (!dev->dev_read)
  8013ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b1:	8b 52 08             	mov    0x8(%edx),%edx
  8013b4:	85 d2                	test   %edx,%edx
  8013b6:	74 11                	je     8013c9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	ff 75 10             	pushl  0x10(%ebp)
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	50                   	push   %eax
  8013c2:	ff d2                	call   *%edx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	eb 05                	jmp    8013ce <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	57                   	push   %edi
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e2:	85 f6                	test   %esi,%esi
  8013e4:	74 31                	je     801417 <readn+0x44>
  8013e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f0:	83 ec 04             	sub    $0x4,%esp
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	29 c2                	sub    %eax,%edx
  8013f7:	52                   	push   %edx
  8013f8:	03 45 0c             	add    0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	57                   	push   %edi
  8013fd:	e8 4a ff ff ff       	call   80134c <read>
		if (m < 0)
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 17                	js     801420 <readn+0x4d>
			return m;
		if (m == 0)
  801409:	85 c0                	test   %eax,%eax
  80140b:	74 11                	je     80141e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140d:	01 c3                	add    %eax,%ebx
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	39 f3                	cmp    %esi,%ebx
  801413:	72 db                	jb     8013f0 <readn+0x1d>
  801415:	eb 09                	jmp    801420 <readn+0x4d>
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	eb 02                	jmp    801420 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80141e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 14             	sub    $0x14,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	e8 8f fc ff ff       	call   8010cb <fd_lookup>
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 62                	js     8014a5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 cd fc ff ff       	call   801121 <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 4a                	js     8014a5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	75 21                	jne    801485 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801464:	a1 04 40 80 00       	mov    0x804004,%eax
  801469:	8b 40 48             	mov    0x48(%eax),%eax
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	53                   	push   %ebx
  801470:	50                   	push   %eax
  801471:	68 0d 27 80 00       	push   $0x80270d
  801476:	e8 65 ed ff ff       	call   8001e0 <cprintf>
		return -E_INVAL;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801483:	eb 20                	jmp    8014a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801485:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801488:	8b 52 0c             	mov    0xc(%edx),%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 11                	je     8014a0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	ff 75 10             	pushl  0x10(%ebp)
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	50                   	push   %eax
  801499:	ff d2                	call   *%edx
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	eb 05                	jmp    8014a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 08             	pushl  0x8(%ebp)
  8014b7:	e8 0f fc ff ff       	call   8010cb <fd_lookup>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 0e                	js     8014d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 14             	sub    $0x14,%esp
  8014da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	53                   	push   %ebx
  8014e2:	e8 e4 fb ff ff       	call   8010cb <fd_lookup>
  8014e7:	83 c4 08             	add    $0x8,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 5f                	js     80154d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f8:	ff 30                	pushl  (%eax)
  8014fa:	e8 22 fc ff ff       	call   801121 <dev_lookup>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 47                	js     80154d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150d:	75 21                	jne    801530 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80150f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	50                   	push   %eax
  80151c:	68 d0 26 80 00       	push   $0x8026d0
  801521:	e8 ba ec ff ff       	call   8001e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152e:	eb 1d                	jmp    80154d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801530:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801533:	8b 52 18             	mov    0x18(%edx),%edx
  801536:	85 d2                	test   %edx,%edx
  801538:	74 0e                	je     801548 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	ff 75 0c             	pushl  0xc(%ebp)
  801540:	50                   	push   %eax
  801541:	ff d2                	call   *%edx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	eb 05                	jmp    80154d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801548:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80154d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 14             	sub    $0x14,%esp
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 63 fb ff ff       	call   8010cb <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 52                	js     8015c1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	ff 30                	pushl  (%eax)
  80157b:	e8 a1 fb ff ff       	call   801121 <dev_lookup>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 3a                	js     8015c1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801587:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158e:	74 2c                	je     8015bc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801590:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801593:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80159a:	00 00 00 
	stat->st_isdir = 0;
  80159d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a4:	00 00 00 
	stat->st_dev = dev;
  8015a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b4:	ff 50 14             	call   *0x14(%eax)
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 05                	jmp    8015c1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 08             	pushl  0x8(%ebp)
  8015d3:	e8 8b 01 00 00       	call   801763 <open>
  8015d8:	89 c3                	mov    %eax,%ebx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 1b                	js     8015fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	50                   	push   %eax
  8015e8:	e8 65 ff ff ff       	call   801552 <fstat>
  8015ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ef:	89 1c 24             	mov    %ebx,(%esp)
  8015f2:	e8 18 fc ff ff       	call   80120f <close>
	return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 f3                	mov    %esi,%ebx
}
  8015fc:	89 d8                	mov    %ebx,%eax
  8015fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	c9                   	leave  
  801604:	c3                   	ret    
  801605:	00 00                	add    %al,(%eax)
	...

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801611:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801618:	75 12                	jne    80162c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	6a 01                	push   $0x1
  80161f:	e8 b9 08 00 00       	call   801edd <ipc_find_env>
  801624:	a3 00 40 80 00       	mov    %eax,0x804000
  801629:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162c:	6a 07                	push   $0x7
  80162e:	68 00 50 80 00       	push   $0x805000
  801633:	53                   	push   %ebx
  801634:	ff 35 00 40 80 00    	pushl  0x804000
  80163a:	e8 49 08 00 00       	call   801e88 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80163f:	83 c4 0c             	add    $0xc,%esp
  801642:	6a 00                	push   $0x0
  801644:	56                   	push   %esi
  801645:	6a 00                	push   $0x0
  801647:	e8 94 07 00 00       	call   801de0 <ipc_recv>
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	53                   	push   %ebx
  801657:	83 ec 04             	sub    $0x4,%esp
  80165a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
  801660:	8b 40 0c             	mov    0xc(%eax),%eax
  801663:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801668:	ba 00 00 00 00       	mov    $0x0,%edx
  80166d:	b8 05 00 00 00       	mov    $0x5,%eax
  801672:	e8 91 ff ff ff       	call   801608 <fsipc>
  801677:	85 c0                	test   %eax,%eax
  801679:	78 39                	js     8016b4 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	68 3c 27 80 00       	push   $0x80273c
  801683:	e8 58 eb ff ff       	call   8001e0 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	68 00 50 80 00       	push   $0x805000
  801690:	53                   	push   %ebx
  801691:	e8 00 f1 ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801696:	a1 80 50 80 00       	mov    0x805080,%eax
  80169b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8016a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d4:	e8 2f ff ff ff       	call   801608 <fsipc>
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fe:	e8 05 ff ff ff       	call   801608 <fsipc>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	85 c0                	test   %eax,%eax
  801707:	78 51                	js     80175a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801709:	39 c6                	cmp    %eax,%esi
  80170b:	73 19                	jae    801726 <devfile_read+0x4b>
  80170d:	68 42 27 80 00       	push   $0x802742
  801712:	68 49 27 80 00       	push   $0x802749
  801717:	68 80 00 00 00       	push   $0x80
  80171c:	68 5e 27 80 00       	push   $0x80275e
  801721:	e8 de 05 00 00       	call   801d04 <_panic>
	assert(r <= PGSIZE);
  801726:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80172b:	7e 19                	jle    801746 <devfile_read+0x6b>
  80172d:	68 69 27 80 00       	push   $0x802769
  801732:	68 49 27 80 00       	push   $0x802749
  801737:	68 81 00 00 00       	push   $0x81
  80173c:	68 5e 27 80 00       	push   $0x80275e
  801741:	e8 be 05 00 00       	call   801d04 <_panic>
	memmove(buf, &fsipcbuf, r);
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	50                   	push   %eax
  80174a:	68 00 50 80 00       	push   $0x805000
  80174f:	ff 75 0c             	pushl  0xc(%ebp)
  801752:	e8 00 f2 ff ff       	call   800957 <memmove>
	return r;
  801757:	83 c4 10             	add    $0x10,%esp
}
  80175a:	89 d8                	mov    %ebx,%eax
  80175c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 1c             	sub    $0x1c,%esp
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176e:	56                   	push   %esi
  80176f:	e8 d0 ef ff ff       	call   800744 <strlen>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80177c:	7f 72                	jg     8017f0 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801784:	50                   	push   %eax
  801785:	e8 ce f8 ff ff       	call   801058 <fd_alloc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 62                	js     8017f5 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	56                   	push   %esi
  801797:	68 00 50 80 00       	push   $0x805000
  80179c:	e8 f5 ef ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a4:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b1:	e8 52 fe ff ff       	call   801608 <fsipc>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	79 12                	jns    8017d1 <open+0x6e>
		fd_close(fd, 0);
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	6a 00                	push   $0x0
  8017c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c7:	e8 bb f9 ff ff       	call   801187 <fd_close>
		return r;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	eb 24                	jmp    8017f5 <open+0x92>
	}


	cprintf("OPEN\n");
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	68 75 27 80 00       	push   $0x802775
  8017d9:	e8 02 ea ff ff       	call   8001e0 <cprintf>

	return fd2num(fd);
  8017de:	83 c4 04             	add    $0x4,%esp
  8017e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e4:	e8 47 f8 ff ff       	call   801030 <fd2num>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	eb 05                	jmp    8017f5 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8017f5:	89 d8                	mov    %ebx,%eax
  8017f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    
	...

00801800 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801808:	83 ec 0c             	sub    $0xc,%esp
  80180b:	ff 75 08             	pushl  0x8(%ebp)
  80180e:	e8 2d f8 ff ff       	call   801040 <fd2data>
  801813:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801815:	83 c4 08             	add    $0x8,%esp
  801818:	68 7b 27 80 00       	push   $0x80277b
  80181d:	56                   	push   %esi
  80181e:	e8 73 ef ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801823:	8b 43 04             	mov    0x4(%ebx),%eax
  801826:	2b 03                	sub    (%ebx),%eax
  801828:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80182e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801835:	00 00 00 
	stat->st_dev = &devpipe;
  801838:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80183f:	30 80 00 
	return 0;
}
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801858:	53                   	push   %ebx
  801859:	6a 00                	push   $0x0
  80185b:	e8 02 f4 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801860:	89 1c 24             	mov    %ebx,(%esp)
  801863:	e8 d8 f7 ff ff       	call   801040 <fd2data>
  801868:	83 c4 08             	add    $0x8,%esp
  80186b:	50                   	push   %eax
  80186c:	6a 00                	push   $0x0
  80186e:	e8 ef f3 ff ff       	call   800c62 <sys_page_unmap>
}
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 1c             	sub    $0x1c,%esp
  801881:	89 c7                	mov    %eax,%edi
  801883:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801886:	a1 04 40 80 00       	mov    0x804004,%eax
  80188b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	57                   	push   %edi
  801892:	e8 a1 06 00 00       	call   801f38 <pageref>
  801897:	89 c6                	mov    %eax,%esi
  801899:	83 c4 04             	add    $0x4,%esp
  80189c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80189f:	e8 94 06 00 00       	call   801f38 <pageref>
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	39 c6                	cmp    %eax,%esi
  8018a9:	0f 94 c0             	sete   %al
  8018ac:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018af:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018b8:	39 cb                	cmp    %ecx,%ebx
  8018ba:	75 08                	jne    8018c4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018bf:	5b                   	pop    %ebx
  8018c0:	5e                   	pop    %esi
  8018c1:	5f                   	pop    %edi
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018c4:	83 f8 01             	cmp    $0x1,%eax
  8018c7:	75 bd                	jne    801886 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c9:	8b 42 58             	mov    0x58(%edx),%eax
  8018cc:	6a 01                	push   $0x1
  8018ce:	50                   	push   %eax
  8018cf:	53                   	push   %ebx
  8018d0:	68 82 27 80 00       	push   $0x802782
  8018d5:	e8 06 e9 ff ff       	call   8001e0 <cprintf>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	eb a7                	jmp    801886 <_pipeisclosed+0xe>

008018df <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 28             	sub    $0x28,%esp
  8018e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018eb:	56                   	push   %esi
  8018ec:	e8 4f f7 ff ff       	call   801040 <fd2data>
  8018f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fa:	75 4a                	jne    801946 <devpipe_write+0x67>
  8018fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801901:	eb 56                	jmp    801959 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801903:	89 da                	mov    %ebx,%edx
  801905:	89 f0                	mov    %esi,%eax
  801907:	e8 6c ff ff ff       	call   801878 <_pipeisclosed>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	75 4d                	jne    80195d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801910:	e8 dc f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801915:	8b 43 04             	mov    0x4(%ebx),%eax
  801918:	8b 13                	mov    (%ebx),%edx
  80191a:	83 c2 20             	add    $0x20,%edx
  80191d:	39 d0                	cmp    %edx,%eax
  80191f:	73 e2                	jae    801903 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801921:	89 c2                	mov    %eax,%edx
  801923:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801929:	79 05                	jns    801930 <devpipe_write+0x51>
  80192b:	4a                   	dec    %edx
  80192c:	83 ca e0             	or     $0xffffffe0,%edx
  80192f:	42                   	inc    %edx
  801930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801933:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801936:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80193a:	40                   	inc    %eax
  80193b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80193e:	47                   	inc    %edi
  80193f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801942:	77 07                	ja     80194b <devpipe_write+0x6c>
  801944:	eb 13                	jmp    801959 <devpipe_write+0x7a>
  801946:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80194b:	8b 43 04             	mov    0x4(%ebx),%eax
  80194e:	8b 13                	mov    (%ebx),%edx
  801950:	83 c2 20             	add    $0x20,%edx
  801953:	39 d0                	cmp    %edx,%eax
  801955:	73 ac                	jae    801903 <devpipe_write+0x24>
  801957:	eb c8                	jmp    801921 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801959:	89 f8                	mov    %edi,%eax
  80195b:	eb 05                	jmp    801962 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801965:	5b                   	pop    %ebx
  801966:	5e                   	pop    %esi
  801967:	5f                   	pop    %edi
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	57                   	push   %edi
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 18             	sub    $0x18,%esp
  801973:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801976:	57                   	push   %edi
  801977:	e8 c4 f6 ff ff       	call   801040 <fd2data>
  80197c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801985:	75 44                	jne    8019cb <devpipe_read+0x61>
  801987:	be 00 00 00 00       	mov    $0x0,%esi
  80198c:	eb 4f                	jmp    8019dd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80198e:	89 f0                	mov    %esi,%eax
  801990:	eb 54                	jmp    8019e6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801992:	89 da                	mov    %ebx,%edx
  801994:	89 f8                	mov    %edi,%eax
  801996:	e8 dd fe ff ff       	call   801878 <_pipeisclosed>
  80199b:	85 c0                	test   %eax,%eax
  80199d:	75 42                	jne    8019e1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80199f:	e8 4d f2 ff ff       	call   800bf1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a4:	8b 03                	mov    (%ebx),%eax
  8019a6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019a9:	74 e7                	je     801992 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ab:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019b0:	79 05                	jns    8019b7 <devpipe_read+0x4d>
  8019b2:	48                   	dec    %eax
  8019b3:	83 c8 e0             	or     $0xffffffe0,%eax
  8019b6:	40                   	inc    %eax
  8019b7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019be:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019c1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c3:	46                   	inc    %esi
  8019c4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8019c7:	77 07                	ja     8019d0 <devpipe_read+0x66>
  8019c9:	eb 12                	jmp    8019dd <devpipe_read+0x73>
  8019cb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019d0:	8b 03                	mov    (%ebx),%eax
  8019d2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019d5:	75 d4                	jne    8019ab <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019d7:	85 f6                	test   %esi,%esi
  8019d9:	75 b3                	jne    80198e <devpipe_read+0x24>
  8019db:	eb b5                	jmp    801992 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019dd:	89 f0                	mov    %esi,%eax
  8019df:	eb 05                	jmp    8019e6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 28             	sub    $0x28,%esp
  8019f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019fd:	50                   	push   %eax
  8019fe:	e8 55 f6 ff ff       	call   801058 <fd_alloc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	0f 88 24 01 00 00    	js     801b34 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	68 07 04 00 00       	push   $0x407
  801a18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 f6 f1 ff ff       	call   800c18 <sys_page_alloc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	0f 88 05 01 00 00    	js     801b34 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a35:	50                   	push   %eax
  801a36:	e8 1d f6 ff ff       	call   801058 <fd_alloc>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	0f 88 dc 00 00 00    	js     801b24 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	68 07 04 00 00       	push   $0x407
  801a50:	ff 75 e0             	pushl  -0x20(%ebp)
  801a53:	6a 00                	push   $0x0
  801a55:	e8 be f1 ff ff       	call   800c18 <sys_page_alloc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	0f 88 bd 00 00 00    	js     801b24 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6d:	e8 ce f5 ff ff       	call   801040 <fd2data>
  801a72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a74:	83 c4 0c             	add    $0xc,%esp
  801a77:	68 07 04 00 00       	push   $0x407
  801a7c:	50                   	push   %eax
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 94 f1 ff ff       	call   800c18 <sys_page_alloc>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	0f 88 83 00 00 00    	js     801b14 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	ff 75 e0             	pushl  -0x20(%ebp)
  801a97:	e8 a4 f5 ff ff       	call   801040 <fd2data>
  801a9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aa3:	50                   	push   %eax
  801aa4:	6a 00                	push   $0x0
  801aa6:	56                   	push   %esi
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 8e f1 ff ff       	call   800c3c <sys_page_map>
  801aae:	89 c3                	mov    %eax,%ebx
  801ab0:	83 c4 20             	add    $0x20,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 4f                	js     801b06 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ab7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801acc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ad5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ad7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ada:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae7:	e8 44 f5 ff ff       	call   801030 <fd2num>
  801aec:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801aee:	83 c4 04             	add    $0x4,%esp
  801af1:	ff 75 e0             	pushl  -0x20(%ebp)
  801af4:	e8 37 f5 ff ff       	call   801030 <fd2num>
  801af9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b04:	eb 2e                	jmp    801b34 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	56                   	push   %esi
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 51 f1 ff ff       	call   800c62 <sys_page_unmap>
  801b11:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b14:	83 ec 08             	sub    $0x8,%esp
  801b17:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 41 f1 ff ff       	call   800c62 <sys_page_unmap>
  801b21:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 31 f1 ff ff       	call   800c62 <sys_page_unmap>
  801b31:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	ff 75 08             	pushl  0x8(%ebp)
  801b4b:	e8 7b f5 ff ff       	call   8010cb <fd_lookup>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 18                	js     801b6f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5d:	e8 de f4 ff ff       	call   801040 <fd2data>
	return _pipeisclosed(fd, p);
  801b62:	89 c2                	mov    %eax,%edx
  801b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b67:	e8 0c fd ff ff       	call   801878 <_pipeisclosed>
  801b6c:	83 c4 10             	add    $0x10,%esp
}
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    
  801b71:	00 00                	add    %al,(%eax)
	...

00801b74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b84:	68 9a 27 80 00       	push   $0x80279a
  801b89:	ff 75 0c             	pushl  0xc(%ebp)
  801b8c:	e8 05 ec ff ff       	call   800796 <strcpy>
	return 0;
}
  801b91:	b8 00 00 00 00       	mov    $0x0,%eax
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	57                   	push   %edi
  801b9c:	56                   	push   %esi
  801b9d:	53                   	push   %ebx
  801b9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba8:	74 45                	je     801bef <devcons_write+0x57>
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
  801baf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bb4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bbd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801bbf:	83 fb 7f             	cmp    $0x7f,%ebx
  801bc2:	76 05                	jbe    801bc9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801bc4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bc9:	83 ec 04             	sub    $0x4,%esp
  801bcc:	53                   	push   %ebx
  801bcd:	03 45 0c             	add    0xc(%ebp),%eax
  801bd0:	50                   	push   %eax
  801bd1:	57                   	push   %edi
  801bd2:	e8 80 ed ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801bd7:	83 c4 08             	add    $0x8,%esp
  801bda:	53                   	push   %ebx
  801bdb:	57                   	push   %edi
  801bdc:	e8 80 ef ff ff       	call   800b61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be1:	01 de                	add    %ebx,%esi
  801be3:	89 f0                	mov    %esi,%eax
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801beb:	72 cd                	jb     801bba <devcons_write+0x22>
  801bed:	eb 05                	jmp    801bf4 <devcons_write+0x5c>
  801bef:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf4:	89 f0                	mov    %esi,%eax
  801bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c08:	75 07                	jne    801c11 <devcons_read+0x13>
  801c0a:	eb 25                	jmp    801c31 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c0c:	e8 e0 ef ff ff       	call   800bf1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c11:	e8 71 ef ff ff       	call   800b87 <sys_cgetc>
  801c16:	85 c0                	test   %eax,%eax
  801c18:	74 f2                	je     801c0c <devcons_read+0xe>
  801c1a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 1d                	js     801c3d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c20:	83 f8 04             	cmp    $0x4,%eax
  801c23:	74 13                	je     801c38 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c28:	88 10                	mov    %dl,(%eax)
	return 1;
  801c2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2f:	eb 0c                	jmp    801c3d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	eb 05                	jmp    801c3d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4b:	6a 01                	push   $0x1
  801c4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 0b ef ff ff       	call   800b61 <sys_cputs>
  801c56:	83 c4 10             	add    $0x10,%esp
}
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <getchar>:

int
getchar(void)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c61:	6a 01                	push   $0x1
  801c63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	6a 00                	push   $0x0
  801c69:	e8 de f6 ff ff       	call   80134c <read>
	if (r < 0)
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 0f                	js     801c84 <getchar+0x29>
		return r;
	if (r < 1)
  801c75:	85 c0                	test   %eax,%eax
  801c77:	7e 06                	jle    801c7f <getchar+0x24>
		return -E_EOF;
	return c;
  801c79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7d:	eb 05                	jmp    801c84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	ff 75 08             	pushl  0x8(%ebp)
  801c93:	e8 33 f4 ff ff       	call   8010cb <fd_lookup>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 11                	js     801cb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca8:	39 10                	cmp    %edx,(%eax)
  801caa:	0f 94 c0             	sete   %al
  801cad:	0f b6 c0             	movzbl %al,%eax
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <opencons>:

int
opencons(void)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	e8 97 f3 ff ff       	call   801058 <fd_alloc>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 3a                	js     801d02 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 3e ef ff ff       	call   800c18 <sys_page_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 21                	js     801d02 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	50                   	push   %eax
  801cfa:	e8 31 f3 ff ff       	call   801030 <fd2num>
  801cff:	83 c4 10             	add    $0x10,%esp
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d09:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d0c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d12:	e8 b6 ee ff ff       	call   800bcd <sys_getenvid>
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	ff 75 0c             	pushl  0xc(%ebp)
  801d1d:	ff 75 08             	pushl  0x8(%ebp)
  801d20:	53                   	push   %ebx
  801d21:	50                   	push   %eax
  801d22:	68 a8 27 80 00       	push   $0x8027a8
  801d27:	e8 b4 e4 ff ff       	call   8001e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d2c:	83 c4 18             	add    $0x18,%esp
  801d2f:	56                   	push   %esi
  801d30:	ff 75 10             	pushl  0x10(%ebp)
  801d33:	e8 57 e4 ff ff       	call   80018f <vcprintf>
	cprintf("\n");
  801d38:	c7 04 24 ef 21 80 00 	movl   $0x8021ef,(%esp)
  801d3f:	e8 9c e4 ff ff       	call   8001e0 <cprintf>
  801d44:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d47:	cc                   	int3   
  801d48:	eb fd                	jmp    801d47 <_panic+0x43>
	...

00801d4c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d52:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d59:	75 52                	jne    801dad <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d5b:	83 ec 04             	sub    $0x4,%esp
  801d5e:	6a 07                	push   $0x7
  801d60:	68 00 f0 bf ee       	push   $0xeebff000
  801d65:	6a 00                	push   $0x0
  801d67:	e8 ac ee ff ff       	call   800c18 <sys_page_alloc>
		if (r < 0) {
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	79 12                	jns    801d85 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801d73:	50                   	push   %eax
  801d74:	68 cb 27 80 00       	push   $0x8027cb
  801d79:	6a 24                	push   $0x24
  801d7b:	68 e6 27 80 00       	push   $0x8027e6
  801d80:	e8 7f ff ff ff       	call   801d04 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801d85:	83 ec 08             	sub    $0x8,%esp
  801d88:	68 b8 1d 80 00       	push   $0x801db8
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 37 ef ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	79 12                	jns    801dad <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801d9b:	50                   	push   %eax
  801d9c:	68 f4 27 80 00       	push   $0x8027f4
  801da1:	6a 2a                	push   $0x2a
  801da3:	68 e6 27 80 00       	push   $0x8027e6
  801da8:	e8 57 ff ff ff       	call   801d04 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    
	...

00801db8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801db8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801db9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dbe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dc0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801dc3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801dc7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801dca:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801dce:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801dd2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801dd4:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801dd7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801dd8:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801ddb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801ddc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ddd:	c3                   	ret    
	...

00801de0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801def:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	57                   	push   %edi
  801df5:	68 1c 28 80 00       	push   $0x80281c
  801dfa:	e8 e1 e3 ff ff       	call   8001e0 <cprintf>
	int r;
	if (pg != NULL) {
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 db                	test   %ebx,%ebx
  801e04:	74 28                	je     801e2e <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	68 2c 28 80 00       	push   $0x80282c
  801e0e:	e8 cd e3 ff ff       	call   8001e0 <cprintf>
		r = sys_ipc_recv(pg);
  801e13:	89 1c 24             	mov    %ebx,(%esp)
  801e16:	e8 f8 ee ff ff       	call   800d13 <sys_ipc_recv>
  801e1b:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801e1d:	c7 04 24 3c 27 80 00 	movl   $0x80273c,(%esp)
  801e24:	e8 b7 e3 ff ff       	call   8001e0 <cprintf>
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	eb 12                	jmp    801e40 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	68 00 00 c0 ee       	push   $0xeec00000
  801e36:	e8 d8 ee ff ff       	call   800d13 <sys_ipc_recv>
  801e3b:	89 c3                	mov    %eax,%ebx
  801e3d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e40:	85 db                	test   %ebx,%ebx
  801e42:	75 26                	jne    801e6a <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e44:	85 ff                	test   %edi,%edi
  801e46:	74 0a                	je     801e52 <ipc_recv+0x72>
  801e48:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4d:	8b 40 74             	mov    0x74(%eax),%eax
  801e50:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e52:	85 f6                	test   %esi,%esi
  801e54:	74 0a                	je     801e60 <ipc_recv+0x80>
  801e56:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5b:	8b 40 78             	mov    0x78(%eax),%eax
  801e5e:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801e60:	a1 04 40 80 00       	mov    0x804004,%eax
  801e65:	8b 58 70             	mov    0x70(%eax),%ebx
  801e68:	eb 14                	jmp    801e7e <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e6a:	85 ff                	test   %edi,%edi
  801e6c:	74 06                	je     801e74 <ipc_recv+0x94>
  801e6e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801e74:	85 f6                	test   %esi,%esi
  801e76:	74 06                	je     801e7e <ipc_recv+0x9e>
  801e78:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801e7e:	89 d8                	mov    %ebx,%eax
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	57                   	push   %edi
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e97:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801e9a:	85 db                	test   %ebx,%ebx
  801e9c:	75 25                	jne    801ec3 <ipc_send+0x3b>
  801e9e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ea3:	eb 1e                	jmp    801ec3 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ea5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea8:	75 07                	jne    801eb1 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801eaa:	e8 42 ed ff ff       	call   800bf1 <sys_yield>
  801eaf:	eb 12                	jmp    801ec3 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801eb1:	50                   	push   %eax
  801eb2:	68 33 28 80 00       	push   $0x802833
  801eb7:	6a 45                	push   $0x45
  801eb9:	68 46 28 80 00       	push   $0x802846
  801ebe:	e8 41 fe ff ff       	call   801d04 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	57                   	push   %edi
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	e8 20 ee ff ff       	call   800cee <sys_ipc_try_send>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	75 d0                	jne    801ea5 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ed5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed8:	5b                   	pop    %ebx
  801ed9:	5e                   	pop    %esi
  801eda:	5f                   	pop    %edi
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	53                   	push   %ebx
  801ee1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ee4:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801eea:	74 22                	je     801f0e <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eec:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ef1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ef8:	89 c2                	mov    %eax,%edx
  801efa:	c1 e2 07             	shl    $0x7,%edx
  801efd:	29 ca                	sub    %ecx,%edx
  801eff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f05:	8b 52 50             	mov    0x50(%edx),%edx
  801f08:	39 da                	cmp    %ebx,%edx
  801f0a:	75 1d                	jne    801f29 <ipc_find_env+0x4c>
  801f0c:	eb 05                	jmp    801f13 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f1a:	c1 e0 07             	shl    $0x7,%eax
  801f1d:	29 d0                	sub    %edx,%eax
  801f1f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f24:	8b 40 40             	mov    0x40(%eax),%eax
  801f27:	eb 0c                	jmp    801f35 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f29:	40                   	inc    %eax
  801f2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2f:	75 c0                	jne    801ef1 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f31:	66 b8 00 00          	mov    $0x0,%ax
}
  801f35:	5b                   	pop    %ebx
  801f36:	c9                   	leave  
  801f37:	c3                   	ret    

00801f38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	c1 ea 16             	shr    $0x16,%edx
  801f43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f4a:	f6 c2 01             	test   $0x1,%dl
  801f4d:	74 1e                	je     801f6d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4f:	c1 e8 0c             	shr    $0xc,%eax
  801f52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f59:	a8 01                	test   $0x1,%al
  801f5b:	74 17                	je     801f74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5d:	c1 e8 0c             	shr    $0xc,%eax
  801f60:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f67:	ef 
  801f68:	0f b7 c0             	movzwl %ax,%eax
  801f6b:	eb 0c                	jmp    801f79 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f72:	eb 05                	jmp    801f79 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    
	...

00801f7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	57                   	push   %edi
  801f80:	56                   	push   %esi
  801f81:	83 ec 10             	sub    $0x10,%esp
  801f84:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f87:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f8a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f90:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f93:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f96:	85 c0                	test   %eax,%eax
  801f98:	75 2e                	jne    801fc8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f9a:	39 f1                	cmp    %esi,%ecx
  801f9c:	77 5a                	ja     801ff8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f9e:	85 c9                	test   %ecx,%ecx
  801fa0:	75 0b                	jne    801fad <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa7:	31 d2                	xor    %edx,%edx
  801fa9:	f7 f1                	div    %ecx
  801fab:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fad:	31 d2                	xor    %edx,%edx
  801faf:	89 f0                	mov    %esi,%eax
  801fb1:	f7 f1                	div    %ecx
  801fb3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fb5:	89 f8                	mov    %edi,%eax
  801fb7:	f7 f1                	div    %ecx
  801fb9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fbb:	89 f8                	mov    %edi,%eax
  801fbd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fc8:	39 f0                	cmp    %esi,%eax
  801fca:	77 1c                	ja     801fe8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fcc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fcf:	83 f7 1f             	xor    $0x1f,%edi
  801fd2:	75 3c                	jne    802010 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fd4:	39 f0                	cmp    %esi,%eax
  801fd6:	0f 82 90 00 00 00    	jb     80206c <__udivdi3+0xf0>
  801fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fdf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fe2:	0f 86 84 00 00 00    	jbe    80206c <__udivdi3+0xf0>
  801fe8:	31 f6                	xor    %esi,%esi
  801fea:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fec:	89 f8                	mov    %edi,%eax
  801fee:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	5e                   	pop    %esi
  801ff4:	5f                   	pop    %edi
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    
  801ff7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ff8:	89 f2                	mov    %esi,%edx
  801ffa:	89 f8                	mov    %edi,%eax
  801ffc:	f7 f1                	div    %ecx
  801ffe:	89 c7                	mov    %eax,%edi
  802000:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802002:	89 f8                	mov    %edi,%eax
  802004:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    
  80200d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802010:	89 f9                	mov    %edi,%ecx
  802012:	d3 e0                	shl    %cl,%eax
  802014:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802017:	b8 20 00 00 00       	mov    $0x20,%eax
  80201c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80201e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802021:	88 c1                	mov    %al,%cl
  802023:	d3 ea                	shr    %cl,%edx
  802025:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802028:	09 ca                	or     %ecx,%edx
  80202a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80202d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802030:	89 f9                	mov    %edi,%ecx
  802032:	d3 e2                	shl    %cl,%edx
  802034:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802037:	89 f2                	mov    %esi,%edx
  802039:	88 c1                	mov    %al,%cl
  80203b:	d3 ea                	shr    %cl,%edx
  80203d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802040:	89 f2                	mov    %esi,%edx
  802042:	89 f9                	mov    %edi,%ecx
  802044:	d3 e2                	shl    %cl,%edx
  802046:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802049:	88 c1                	mov    %al,%cl
  80204b:	d3 ee                	shr    %cl,%esi
  80204d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80204f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802052:	89 f0                	mov    %esi,%eax
  802054:	89 ca                	mov    %ecx,%edx
  802056:	f7 75 ec             	divl   -0x14(%ebp)
  802059:	89 d1                	mov    %edx,%ecx
  80205b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80205d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802060:	39 d1                	cmp    %edx,%ecx
  802062:	72 28                	jb     80208c <__udivdi3+0x110>
  802064:	74 1a                	je     802080 <__udivdi3+0x104>
  802066:	89 f7                	mov    %esi,%edi
  802068:	31 f6                	xor    %esi,%esi
  80206a:	eb 80                	jmp    801fec <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80206c:	31 f6                	xor    %esi,%esi
  80206e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802073:	89 f8                	mov    %edi,%eax
  802075:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802080:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802083:	89 f9                	mov    %edi,%ecx
  802085:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802087:	39 c2                	cmp    %eax,%edx
  802089:	73 db                	jae    802066 <__udivdi3+0xea>
  80208b:	90                   	nop
		{
		  q0--;
  80208c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80208f:	31 f6                	xor    %esi,%esi
  802091:	e9 56 ff ff ff       	jmp    801fec <__udivdi3+0x70>
	...

00802098 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	57                   	push   %edi
  80209c:	56                   	push   %esi
  80209d:	83 ec 20             	sub    $0x20,%esp
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020ac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020af:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020b5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020b7:	85 ff                	test   %edi,%edi
  8020b9:	75 15                	jne    8020d0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020bb:	39 f1                	cmp    %esi,%ecx
  8020bd:	0f 86 99 00 00 00    	jbe    80215c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020c3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020c5:	89 d0                	mov    %edx,%eax
  8020c7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020c9:	83 c4 20             	add    $0x20,%esp
  8020cc:	5e                   	pop    %esi
  8020cd:	5f                   	pop    %edi
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020d0:	39 f7                	cmp    %esi,%edi
  8020d2:	0f 87 a4 00 00 00    	ja     80217c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020d8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020db:	83 f0 1f             	xor    $0x1f,%eax
  8020de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020e1:	0f 84 a1 00 00 00    	je     802188 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020e7:	89 f8                	mov    %edi,%eax
  8020e9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020ec:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020ee:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	d3 ea                	shr    %cl,%edx
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802105:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802108:	d3 e0                	shl    %cl,%eax
  80210a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802111:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802114:	d3 e0                	shl    %cl,%eax
  802116:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802119:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80211c:	89 f9                	mov    %edi,%ecx
  80211e:	d3 e8                	shr    %cl,%eax
  802120:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802122:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802124:	89 f2                	mov    %esi,%edx
  802126:	f7 75 f0             	divl   -0x10(%ebp)
  802129:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80212b:	f7 65 f4             	mull   -0xc(%ebp)
  80212e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802131:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802133:	39 d6                	cmp    %edx,%esi
  802135:	72 71                	jb     8021a8 <__umoddi3+0x110>
  802137:	74 7f                	je     8021b8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213c:	29 c8                	sub    %ecx,%eax
  80213e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802140:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802143:	d3 e8                	shr    %cl,%eax
  802145:	89 f2                	mov    %esi,%edx
  802147:	89 f9                	mov    %edi,%ecx
  802149:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80214b:	09 d0                	or     %edx,%eax
  80214d:	89 f2                	mov    %esi,%edx
  80214f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802152:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802154:	83 c4 20             	add    $0x20,%esp
  802157:	5e                   	pop    %esi
  802158:	5f                   	pop    %edi
  802159:	c9                   	leave  
  80215a:	c3                   	ret    
  80215b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80215c:	85 c9                	test   %ecx,%ecx
  80215e:	75 0b                	jne    80216b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802160:	b8 01 00 00 00       	mov    $0x1,%eax
  802165:	31 d2                	xor    %edx,%edx
  802167:	f7 f1                	div    %ecx
  802169:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	31 d2                	xor    %edx,%edx
  80216f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802174:	f7 f1                	div    %ecx
  802176:	e9 4a ff ff ff       	jmp    8020c5 <__umoddi3+0x2d>
  80217b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80217c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80217e:	83 c4 20             	add    $0x20,%esp
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	c9                   	leave  
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802188:	39 f7                	cmp    %esi,%edi
  80218a:	72 05                	jb     802191 <__umoddi3+0xf9>
  80218c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80218f:	77 0c                	ja     80219d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802191:	89 f2                	mov    %esi,%edx
  802193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802196:	29 c8                	sub    %ecx,%eax
  802198:	19 fa                	sbb    %edi,%edx
  80219a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80219d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021a0:	83 c4 20             	add    $0x20,%esp
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    
  8021a7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021ab:	89 c1                	mov    %eax,%ecx
  8021ad:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021b0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021b3:	eb 84                	jmp    802139 <__umoddi3+0xa1>
  8021b5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021bb:	72 eb                	jb     8021a8 <__umoddi3+0x110>
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	e9 75 ff ff ff       	jmp    802139 <__umoddi3+0xa1>
