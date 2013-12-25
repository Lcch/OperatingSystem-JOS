
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
  80003e:	e8 86 0b 00 00       	call   800bc9 <sys_getenvid>
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	53                   	push   %ebx
  800047:	50                   	push   %eax
  800048:	68 20 22 80 00       	push   $0x802220
  80004d:	e8 8a 01 00 00       	call   8001dc <cprintf>

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
  800081:	e8 ba 06 00 00       	call   800740 <strlen>
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	83 f8 02             	cmp    $0x2,%eax
  80008c:	7f 39                	jg     8000c7 <forkchild+0x57>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	53                   	push   %ebx
  800097:	68 31 22 80 00       	push   $0x802231
  80009c:	6a 04                	push   $0x4
  80009e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a1:	50                   	push   %eax
  8000a2:	e8 7d 06 00 00       	call   800724 <snprintf>
	if (fork() == 0) {
  8000a7:	83 c4 20             	add    $0x20,%esp
  8000aa:	e8 e3 0d 00 00       	call   800e92 <fork>
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 14                	jne    8000c7 <forkchild+0x57>
		forktree(nxt);
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	e8 75 ff ff ff       	call   800034 <forktree>
		exit();
  8000bf:	e8 6c 00 00 00       	call   800130 <exit>
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
  8000d2:	68 30 22 80 00       	push   $0x802230
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
  8000ef:	e8 d5 0a 00 00       	call   800bc9 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	89 c2                	mov    %eax,%edx
  8000fb:	c1 e2 07             	shl    $0x7,%edx
  8000fe:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800105:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 f6                	test   %esi,%esi
  80010c:	7e 07                	jle    800115 <libmain+0x31>
		binaryname = argv[0];
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	53                   	push   %ebx
  800119:	56                   	push   %esi
  80011a:	e8 ad ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80011f:	e8 0c 00 00 00       	call   800130 <exit>
  800124:	83 c4 10             	add    $0x10,%esp
}
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    
	...

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800136:	e8 a7 11 00 00       	call   8012e2 <close_all>
	sys_env_destroy(0);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	6a 00                	push   $0x0
  800140:	e8 62 0a 00 00       	call   800ba7 <sys_env_destroy>
  800145:	83 c4 10             	add    $0x10,%esp
}
  800148:	c9                   	leave  
  800149:	c3                   	ret    
	...

0080014c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	53                   	push   %ebx
  800150:	83 ec 04             	sub    $0x4,%esp
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800156:	8b 03                	mov    (%ebx),%eax
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015f:	40                   	inc    %eax
  800160:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800162:	3d ff 00 00 00       	cmp    $0xff,%eax
  800167:	75 1a                	jne    800183 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	68 ff 00 00 00       	push   $0xff
  800171:	8d 43 08             	lea    0x8(%ebx),%eax
  800174:	50                   	push   %eax
  800175:	e8 e3 09 00 00       	call   800b5d <sys_cputs>
		b->idx = 0;
  80017a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800180:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800183:	ff 43 04             	incl   0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800194:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019b:	00 00 00 
	b.cnt = 0;
  80019e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a8:	ff 75 0c             	pushl  0xc(%ebp)
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b4:	50                   	push   %eax
  8001b5:	68 4c 01 80 00       	push   $0x80014c
  8001ba:	e8 82 01 00 00       	call   800341 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bf:	83 c4 08             	add    $0x8,%esp
  8001c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 89 09 00 00       	call   800b5d <sys_cputs>

	return b.cnt;
}
  8001d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e5:	50                   	push   %eax
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	e8 9d ff ff ff       	call   80018b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 2c             	sub    $0x2c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	8b 55 0c             	mov    0xc(%ebp),%edx
  800204:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800207:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800216:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80021d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800220:	72 0c                	jb     80022e <printnum+0x3e>
  800222:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800225:	76 07                	jbe    80022e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800227:	4b                   	dec    %ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f 31                	jg     80025d <printnum+0x6d>
  80022c:	eb 3f                	jmp    80026d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022e:	83 ec 0c             	sub    $0xc,%esp
  800231:	57                   	push   %edi
  800232:	4b                   	dec    %ebx
  800233:	53                   	push   %ebx
  800234:	50                   	push   %eax
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	ff 75 d4             	pushl  -0x2c(%ebp)
  80023b:	ff 75 d0             	pushl  -0x30(%ebp)
  80023e:	ff 75 dc             	pushl  -0x24(%ebp)
  800241:	ff 75 d8             	pushl  -0x28(%ebp)
  800244:	e8 7b 1d 00 00       	call   801fc4 <__udivdi3>
  800249:	83 c4 18             	add    $0x18,%esp
  80024c:	52                   	push   %edx
  80024d:	50                   	push   %eax
  80024e:	89 f2                	mov    %esi,%edx
  800250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800253:	e8 98 ff ff ff       	call   8001f0 <printnum>
  800258:	83 c4 20             	add    $0x20,%esp
  80025b:	eb 10                	jmp    80026d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	56                   	push   %esi
  800261:	57                   	push   %edi
  800262:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800265:	4b                   	dec    %ebx
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	85 db                	test   %ebx,%ebx
  80026b:	7f f0                	jg     80025d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	83 ec 04             	sub    $0x4,%esp
  800274:	ff 75 d4             	pushl  -0x2c(%ebp)
  800277:	ff 75 d0             	pushl  -0x30(%ebp)
  80027a:	ff 75 dc             	pushl  -0x24(%ebp)
  80027d:	ff 75 d8             	pushl  -0x28(%ebp)
  800280:	e8 5b 1e 00 00       	call   8020e0 <__umoddi3>
  800285:	83 c4 14             	add    $0x14,%esp
  800288:	0f be 80 40 22 80 00 	movsbl 0x802240(%eax),%eax
  80028f:	50                   	push   %eax
  800290:	ff 55 e4             	call   *-0x1c(%ebp)
  800293:	83 c4 10             	add    $0x10,%esp
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getint+0x16>
		return va_arg(*ap, long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 1a                	jmp    800308 <getint+0x30>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 0c                	je     8002fe <getint+0x26>
		return va_arg(*ap, long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	99                   	cltd   
  8002fc:	eb 0a                	jmp    800308 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	99                   	cltd   
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 08                	jae    800322 <sprintputch+0x18>
		*b->buf++ = ch;
  80031a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031d:	88 0a                	mov    %cl,(%edx)
  80031f:	42                   	inc    %edx
  800320:	89 10                	mov    %edx,(%eax)
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032d:	50                   	push   %eax
  80032e:	ff 75 10             	pushl  0x10(%ebp)
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	e8 05 00 00 00       	call   800341 <vprintfmt>
	va_end(ap);
  80033c:	83 c4 10             	add    $0x10,%esp
}
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 2c             	sub    $0x2c,%esp
  80034a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80034d:	8b 75 10             	mov    0x10(%ebp),%esi
  800350:	eb 13                	jmp    800365 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800352:	85 c0                	test   %eax,%eax
  800354:	0f 84 6d 03 00 00    	je     8006c7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	57                   	push   %edi
  80035e:	50                   	push   %eax
  80035f:	ff 55 08             	call   *0x8(%ebp)
  800362:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	0f b6 06             	movzbl (%esi),%eax
  800368:	46                   	inc    %esi
  800369:	83 f8 25             	cmp    $0x25,%eax
  80036c:	75 e4                	jne    800352 <vprintfmt+0x11>
  80036e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800372:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800379:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800380:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800387:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038c:	eb 28                	jmp    8003b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800390:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800394:	eb 20                	jmp    8003b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80039c:	eb 18                	jmp    8003b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a7:	eb 0d                	jmp    8003b6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003af:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8a 06                	mov    (%esi),%al
  8003b8:	0f b6 d0             	movzbl %al,%edx
  8003bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003be:	83 e8 23             	sub    $0x23,%eax
  8003c1:	3c 55                	cmp    $0x55,%al
  8003c3:	0f 87 e0 02 00 00    	ja     8006a9 <vprintfmt+0x368>
  8003c9:	0f b6 c0             	movzbl %al,%eax
  8003cc:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d3:	83 ea 30             	sub    $0x30,%edx
  8003d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003d9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003dc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003df:	83 fa 09             	cmp    $0x9,%edx
  8003e2:	77 44                	ja     800428 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	89 de                	mov    %ebx,%esi
  8003e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ea:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ed:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003f1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003f7:	83 fb 09             	cmp    $0x9,%ebx
  8003fa:	76 ed                	jbe    8003e9 <vprintfmt+0xa8>
  8003fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ff:	eb 29                	jmp    80042a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800411:	eb 17                	jmp    80042a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800413:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800417:	78 85                	js     80039e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	89 de                	mov    %ebx,%esi
  80041b:	eb 99                	jmp    8003b6 <vprintfmt+0x75>
  80041d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800426:	eb 8e                	jmp    8003b6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042e:	79 86                	jns    8003b6 <vprintfmt+0x75>
  800430:	e9 74 ff ff ff       	jmp    8003a9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
  800438:	e9 79 ff ff ff       	jmp    8003b6 <vprintfmt+0x75>
  80043d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	57                   	push   %edi
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800458:	e9 08 ff ff ff       	jmp    800365 <vprintfmt+0x24>
  80045d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	79 02                	jns    800471 <vprintfmt+0x130>
  80046f:	f7 d8                	neg    %eax
  800471:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 0f             	cmp    $0xf,%eax
  800476:	7f 0b                	jg     800483 <vprintfmt+0x142>
  800478:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  80047f:	85 c0                	test   %eax,%eax
  800481:	75 1a                	jne    80049d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800483:	52                   	push   %edx
  800484:	68 58 22 80 00       	push   $0x802258
  800489:	57                   	push   %edi
  80048a:	ff 75 08             	pushl  0x8(%ebp)
  80048d:	e8 92 fe ff ff       	call   800324 <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800498:	e9 c8 fe ff ff       	jmp    800365 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80049d:	50                   	push   %eax
  80049e:	68 95 27 80 00       	push   $0x802795
  8004a3:	57                   	push   %edi
  8004a4:	ff 75 08             	pushl  0x8(%ebp)
  8004a7:	e8 78 fe ff ff       	call   800324 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004b2:	e9 ae fe ff ff       	jmp    800365 <vprintfmt+0x24>
  8004b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	75 07                	jne    8004db <vprintfmt+0x19a>
				p = "(null)";
  8004d4:	c7 45 d0 51 22 80 00 	movl   $0x802251,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004db:	85 db                	test   %ebx,%ebx
  8004dd:	7e 42                	jle    800521 <vprintfmt+0x1e0>
  8004df:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004e3:	74 3c                	je     800521 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	51                   	push   %ecx
  8004e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ec:	e8 6f 02 00 00       	call   800760 <strnlen>
  8004f1:	29 c3                	sub    %eax,%ebx
  8004f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 db                	test   %ebx,%ebx
  8004fb:	7e 24                	jle    800521 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004fd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800501:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800504:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	57                   	push   %edi
  80050b:	53                   	push   %ebx
  80050c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	4e                   	dec    %esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 f6                	test   %esi,%esi
  800515:	7f f0                	jg     800507 <vprintfmt+0x1c6>
  800517:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80051a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800521:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800524:	0f be 02             	movsbl (%edx),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 47                	jne    800572 <vprintfmt+0x231>
  80052b:	eb 37                	jmp    800564 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80052d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800531:	74 16                	je     800549 <vprintfmt+0x208>
  800533:	8d 50 e0             	lea    -0x20(%eax),%edx
  800536:	83 fa 5e             	cmp    $0x5e,%edx
  800539:	76 0e                	jbe    800549 <vprintfmt+0x208>
					putch('?', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	57                   	push   %edi
  80053f:	6a 3f                	push   $0x3f
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	eb 0b                	jmp    800554 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	57                   	push   %edi
  80054d:	50                   	push   %eax
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800554:	ff 4d e4             	decl   -0x1c(%ebp)
  800557:	0f be 03             	movsbl (%ebx),%eax
  80055a:	85 c0                	test   %eax,%eax
  80055c:	74 03                	je     800561 <vprintfmt+0x220>
  80055e:	43                   	inc    %ebx
  80055f:	eb 1b                	jmp    80057c <vprintfmt+0x23b>
  800561:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800564:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800568:	7f 1e                	jg     800588 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80056d:	e9 f3 fd ff ff       	jmp    800365 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800572:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800575:	43                   	inc    %ebx
  800576:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800579:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 ad                	js     80052d <vprintfmt+0x1ec>
  800580:	4e                   	dec    %esi
  800581:	79 aa                	jns    80052d <vprintfmt+0x1ec>
  800583:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800586:	eb dc                	jmp    800564 <vprintfmt+0x223>
  800588:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	57                   	push   %edi
  80058f:	6a 20                	push   $0x20
  800591:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	4b                   	dec    %ebx
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	85 db                	test   %ebx,%ebx
  80059a:	7f ef                	jg     80058b <vprintfmt+0x24a>
  80059c:	e9 c4 fd ff ff       	jmp    800365 <vprintfmt+0x24>
  8005a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a4:	89 ca                	mov    %ecx,%edx
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 2a fd ff ff       	call   8002d8 <getint>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 b0 00 00 00       	jmp    800670 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	57                   	push   %edi
  8005c4:	6a 2d                	push   $0x2d
  8005c6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c9:	f7 db                	neg    %ebx
  8005cb:	83 d6 00             	adc    $0x0,%esi
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 93 00 00 00       	jmp    800670 <vprintfmt+0x32f>
  8005dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	89 ca                	mov    %ecx,%edx
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 b4 fc ff ff       	call   80029e <getuint>
  8005ea:	89 c3                	mov    %eax,%ebx
  8005ec:	89 d6                	mov    %edx,%esi
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f3:	eb 7b                	jmp    800670 <vprintfmt+0x32f>
  8005f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 d6 fc ff ff       	call   8002d8 <getint>
  800602:	89 c3                	mov    %eax,%ebx
  800604:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800606:	85 d2                	test   %edx,%edx
  800608:	78 07                	js     800611 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80060a:	b8 08 00 00 00       	mov    $0x8,%eax
  80060f:	eb 5f                	jmp    800670 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	57                   	push   %edi
  800615:	6a 2d                	push   $0x2d
  800617:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80061a:	f7 db                	neg    %ebx
  80061c:	83 d6 00             	adc    $0x0,%esi
  80061f:	f7 de                	neg    %esi
  800621:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800624:	b8 08 00 00 00       	mov    $0x8,%eax
  800629:	eb 45                	jmp    800670 <vprintfmt+0x32f>
  80062b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	57                   	push   %edi
  800632:	6a 30                	push   $0x30
  800634:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 78                	push   $0x78
  80063d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800649:	8b 18                	mov    (%eax),%ebx
  80064b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800650:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800658:	eb 16                	jmp    800670 <vprintfmt+0x32f>
  80065a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065d:	89 ca                	mov    %ecx,%edx
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 37 fc ff ff       	call   80029e <getuint>
  800667:	89 c3                	mov    %eax,%ebx
  800669:	89 d6                	mov    %edx,%esi
			base = 16;
  80066b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800677:	52                   	push   %edx
  800678:	ff 75 e4             	pushl  -0x1c(%ebp)
  80067b:	50                   	push   %eax
  80067c:	56                   	push   %esi
  80067d:	53                   	push   %ebx
  80067e:	89 fa                	mov    %edi,%edx
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	e8 68 fb ff ff       	call   8001f0 <printnum>
			break;
  800688:	83 c4 20             	add    $0x20,%esp
  80068b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80068e:	e9 d2 fc ff ff       	jmp    800365 <vprintfmt+0x24>
  800693:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	57                   	push   %edi
  80069a:	52                   	push   %edx
  80069b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80069e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a4:	e9 bc fc ff ff       	jmp    800365 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	57                   	push   %edi
  8006ad:	6a 25                	push   $0x25
  8006af:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb 02                	jmp    8006b9 <vprintfmt+0x378>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c0:	75 f5                	jne    8006b7 <vprintfmt+0x376>
  8006c2:	e9 9e fc ff ff       	jmp    800365 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 18             	sub    $0x18,%esp
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 26                	je     800716 <vsnprintf+0x47>
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	7e 29                	jle    80071d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f4:	ff 75 14             	pushl  0x14(%ebp)
  8006f7:	ff 75 10             	pushl  0x10(%ebp)
  8006fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	68 0a 03 80 00       	push   $0x80030a
  800703:	e8 39 fc ff ff       	call   800341 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 0c                	jmp    800722 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x53>
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 93 ff ff ff       	call   8006cf <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    
	...

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3a 00             	cmpb   $0x0,(%edx)
  800749:	74 0e                	je     800759 <strlen+0x19>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800750:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f9                	jne    800750 <strlen+0x10>
  800757:	eb 05                	jmp    80075e <strlen+0x1e>
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 17                	je     800784 <strnlen+0x24>
  80076d:	80 39 00             	cmpb   $0x0,(%ecx)
  800770:	74 19                	je     80078b <strnlen+0x2b>
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800777:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800778:	39 d0                	cmp    %edx,%eax
  80077a:	74 14                	je     800790 <strnlen+0x30>
  80077c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800780:	75 f5                	jne    800777 <strnlen+0x17>
  800782:	eb 0c                	jmp    800790 <strnlen+0x30>
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 05                	jmp    800790 <strnlen+0x30>
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079c:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a7:	42                   	inc    %edx
  8007a8:	84 c9                	test   %cl,%cl
  8007aa:	75 f5                	jne    8007a1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b6:	53                   	push   %ebx
  8007b7:	e8 84 ff ff ff       	call   800740 <strlen>
  8007bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007c5:	50                   	push   %eax
  8007c6:	e8 c7 ff ff ff       	call   800792 <strcpy>
	return dst;
}
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	85 f6                	test   %esi,%esi
  8007e2:	74 15                	je     8007f9 <strncpy+0x27>
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e9:	8a 1a                	mov    (%edx),%bl
  8007eb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ee:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	41                   	inc    %ecx
  8007f5:	39 ce                	cmp    %ecx,%esi
  8007f7:	77 f0                	ja     8007e9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	57                   	push   %edi
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 7d 08             	mov    0x8(%ebp),%edi
  800806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800809:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080c:	85 f6                	test   %esi,%esi
  80080e:	74 32                	je     800842 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800810:	83 fe 01             	cmp    $0x1,%esi
  800813:	74 22                	je     800837 <strlcpy+0x3a>
  800815:	8a 0b                	mov    (%ebx),%cl
  800817:	84 c9                	test   %cl,%cl
  800819:	74 20                	je     80083b <strlcpy+0x3e>
  80081b:	89 f8                	mov    %edi,%eax
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800822:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	88 08                	mov    %cl,(%eax)
  800827:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800828:	39 f2                	cmp    %esi,%edx
  80082a:	74 11                	je     80083d <strlcpy+0x40>
  80082c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800830:	42                   	inc    %edx
  800831:	84 c9                	test   %cl,%cl
  800833:	75 f0                	jne    800825 <strlcpy+0x28>
  800835:	eb 06                	jmp    80083d <strlcpy+0x40>
  800837:	89 f8                	mov    %edi,%eax
  800839:	eb 02                	jmp    80083d <strlcpy+0x40>
  80083b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083d:	c6 00 00             	movb   $0x0,(%eax)
  800840:	eb 02                	jmp    800844 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800842:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800844:	29 f8                	sub    %edi,%eax
}
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800854:	8a 01                	mov    (%ecx),%al
  800856:	84 c0                	test   %al,%al
  800858:	74 10                	je     80086a <strcmp+0x1f>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	75 0c                	jne    80086a <strcmp+0x1f>
		p++, q++;
  80085e:	41                   	inc    %ecx
  80085f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800860:	8a 01                	mov    (%ecx),%al
  800862:	84 c0                	test   %al,%al
  800864:	74 04                	je     80086a <strcmp+0x1f>
  800866:	3a 02                	cmp    (%edx),%al
  800868:	74 f4                	je     80085e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 c0             	movzbl %al,%eax
  80086d:	0f b6 12             	movzbl (%edx),%edx
  800870:	29 d0                	sub    %edx,%eax
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	53                   	push   %ebx
  800878:	8b 55 08             	mov    0x8(%ebp),%edx
  80087b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800881:	85 c0                	test   %eax,%eax
  800883:	74 1b                	je     8008a0 <strncmp+0x2c>
  800885:	8a 1a                	mov    (%edx),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	74 24                	je     8008af <strncmp+0x3b>
  80088b:	3a 19                	cmp    (%ecx),%bl
  80088d:	75 20                	jne    8008af <strncmp+0x3b>
  80088f:	48                   	dec    %eax
  800890:	74 15                	je     8008a7 <strncmp+0x33>
		n--, p++, q++;
  800892:	42                   	inc    %edx
  800893:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800894:	8a 1a                	mov    (%edx),%bl
  800896:	84 db                	test   %bl,%bl
  800898:	74 15                	je     8008af <strncmp+0x3b>
  80089a:	3a 19                	cmp    (%ecx),%bl
  80089c:	74 f1                	je     80088f <strncmp+0x1b>
  80089e:	eb 0f                	jmp    8008af <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	eb 05                	jmp    8008ac <strncmp+0x38>
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ac:	5b                   	pop    %ebx
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 02             	movzbl (%edx),%eax
  8008b2:	0f b6 11             	movzbl (%ecx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb f3                	jmp    8008ac <strncmp+0x38>

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c2:	8a 10                	mov    (%eax),%dl
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	74 18                	je     8008e0 <strchr+0x27>
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	75 06                	jne    8008d2 <strchr+0x19>
  8008cc:	eb 17                	jmp    8008e5 <strchr+0x2c>
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 13                	je     8008e5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	40                   	inc    %eax
  8008d3:	8a 10                	mov    (%eax),%dl
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f5                	jne    8008ce <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	eb 05                	jmp    8008e5 <strchr+0x2c>
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f0:	8a 10                	mov    (%eax),%dl
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	74 11                	je     800907 <strfind+0x20>
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	75 06                	jne    800900 <strfind+0x19>
  8008fa:	eb 0b                	jmp    800907 <strfind+0x20>
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 07                	je     800907 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800900:	40                   	inc    %eax
  800901:	8a 10                	mov    (%eax),%dl
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f5                	jne    8008fc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800912:	8b 45 0c             	mov    0xc(%ebp),%eax
  800915:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 30                	je     80094c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800922:	75 25                	jne    800949 <memset+0x40>
  800924:	f6 c1 03             	test   $0x3,%cl
  800927:	75 20                	jne    800949 <memset+0x40>
		c &= 0xFF;
  800929:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092c:	89 d3                	mov    %edx,%ebx
  80092e:	c1 e3 08             	shl    $0x8,%ebx
  800931:	89 d6                	mov    %edx,%esi
  800933:	c1 e6 18             	shl    $0x18,%esi
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e0 10             	shl    $0x10,%eax
  80093b:	09 f0                	or     %esi,%eax
  80093d:	09 d0                	or     %edx,%eax
  80093f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800941:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800944:	fc                   	cld    
  800945:	f3 ab                	rep stos %eax,%es:(%edi)
  800947:	eb 03                	jmp    80094c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800949:	fc                   	cld    
  80094a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800961:	39 c6                	cmp    %eax,%esi
  800963:	73 34                	jae    800999 <memmove+0x46>
  800965:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800968:	39 d0                	cmp    %edx,%eax
  80096a:	73 2d                	jae    800999 <memmove+0x46>
		s += n;
		d += n;
  80096c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 1b                	jne    80098f <memmove+0x3c>
  800974:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097a:	75 13                	jne    80098f <memmove+0x3c>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 0e                	jne    80098f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800981:	83 ef 04             	sub    $0x4,%edi
  800984:	8d 72 fc             	lea    -0x4(%edx),%esi
  800987:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098a:	fd                   	std    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 07                	jmp    800996 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098f:	4f                   	dec    %edi
  800990:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800993:	fd                   	std    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800996:	fc                   	cld    
  800997:	eb 20                	jmp    8009b9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099f:	75 13                	jne    8009b4 <memmove+0x61>
  8009a1:	a8 03                	test   $0x3,%al
  8009a3:	75 0f                	jne    8009b4 <memmove+0x61>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0a                	jne    8009b4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009aa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ad:	89 c7                	mov    %eax,%edi
  8009af:	fc                   	cld    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 05                	jmp    8009b9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c0:	ff 75 10             	pushl  0x10(%ebp)
  8009c3:	ff 75 0c             	pushl  0xc(%ebp)
  8009c6:	ff 75 08             	pushl  0x8(%ebp)
  8009c9:	e8 85 ff ff ff       	call   800953 <memmove>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	85 ff                	test   %edi,%edi
  8009e1:	74 32                	je     800a15 <memcmp+0x45>
		if (*s1 != *s2)
  8009e3:	8a 03                	mov    (%ebx),%al
  8009e5:	8a 0e                	mov    (%esi),%cl
  8009e7:	38 c8                	cmp    %cl,%al
  8009e9:	74 19                	je     800a04 <memcmp+0x34>
  8009eb:	eb 0d                	jmp    8009fa <memcmp+0x2a>
  8009ed:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009f1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009f5:	42                   	inc    %edx
  8009f6:	38 c8                	cmp    %cl,%al
  8009f8:	74 10                	je     800a0a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009fa:	0f b6 c0             	movzbl %al,%eax
  8009fd:	0f b6 c9             	movzbl %cl,%ecx
  800a00:	29 c8                	sub    %ecx,%eax
  800a02:	eb 16                	jmp    800a1a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a04:	4f                   	dec    %edi
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	39 fa                	cmp    %edi,%edx
  800a0c:	75 df                	jne    8009ed <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x4a>
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5f                   	pop    %edi
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a25:	89 c2                	mov    %eax,%edx
  800a27:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2a:	39 d0                	cmp    %edx,%eax
  800a2c:	73 12                	jae    800a40 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a31:	38 08                	cmp    %cl,(%eax)
  800a33:	75 06                	jne    800a3b <memfind+0x1c>
  800a35:	eb 09                	jmp    800a40 <memfind+0x21>
  800a37:	38 08                	cmp    %cl,(%eax)
  800a39:	74 05                	je     800a40 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	40                   	inc    %eax
  800a3c:	39 c2                	cmp    %eax,%edx
  800a3e:	77 f7                	ja     800a37 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4e:	eb 01                	jmp    800a51 <strtol+0xf>
		s++;
  800a50:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	8a 02                	mov    (%edx),%al
  800a53:	3c 20                	cmp    $0x20,%al
  800a55:	74 f9                	je     800a50 <strtol+0xe>
  800a57:	3c 09                	cmp    $0x9,%al
  800a59:	74 f5                	je     800a50 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5b:	3c 2b                	cmp    $0x2b,%al
  800a5d:	75 08                	jne    800a67 <strtol+0x25>
		s++;
  800a5f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
  800a65:	eb 13                	jmp    800a7a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a67:	3c 2d                	cmp    $0x2d,%al
  800a69:	75 0a                	jne    800a75 <strtol+0x33>
		s++, neg = 1;
  800a6b:	8d 52 01             	lea    0x1(%edx),%edx
  800a6e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a73:	eb 05                	jmp    800a7a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	74 05                	je     800a83 <strtol+0x41>
  800a7e:	83 fb 10             	cmp    $0x10,%ebx
  800a81:	75 28                	jne    800aab <strtol+0x69>
  800a83:	8a 02                	mov    (%edx),%al
  800a85:	3c 30                	cmp    $0x30,%al
  800a87:	75 10                	jne    800a99 <strtol+0x57>
  800a89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a8d:	75 0a                	jne    800a99 <strtol+0x57>
		s += 2, base = 16;
  800a8f:	83 c2 02             	add    $0x2,%edx
  800a92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a97:	eb 12                	jmp    800aab <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 0e                	jne    800aab <strtol+0x69>
  800a9d:	3c 30                	cmp    $0x30,%al
  800a9f:	75 05                	jne    800aa6 <strtol+0x64>
		s++, base = 8;
  800aa1:	42                   	inc    %edx
  800aa2:	b3 08                	mov    $0x8,%bl
  800aa4:	eb 05                	jmp    800aab <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab2:	8a 0a                	mov    (%edx),%cl
  800ab4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab7:	80 fb 09             	cmp    $0x9,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x82>
			dig = *s - '0';
  800abc:	0f be c9             	movsbl %cl,%ecx
  800abf:	83 e9 30             	sub    $0x30,%ecx
  800ac2:	eb 1e                	jmp    800ae2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ac4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac7:	80 fb 19             	cmp    $0x19,%bl
  800aca:	77 08                	ja     800ad4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800acc:	0f be c9             	movsbl %cl,%ecx
  800acf:	83 e9 57             	sub    $0x57,%ecx
  800ad2:	eb 0e                	jmp    800ae2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ad4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad7:	80 fb 19             	cmp    $0x19,%bl
  800ada:	77 13                	ja     800aef <strtol+0xad>
			dig = *s - 'A' + 10;
  800adc:	0f be c9             	movsbl %cl,%ecx
  800adf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae2:	39 f1                	cmp    %esi,%ecx
  800ae4:	7d 0d                	jge    800af3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ae6:	42                   	inc    %edx
  800ae7:	0f af c6             	imul   %esi,%eax
  800aea:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aed:	eb c3                	jmp    800ab2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	eb 02                	jmp    800af5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af9:	74 05                	je     800b00 <strtol+0xbe>
		*endptr = (char *) s;
  800afb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afe:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b00:	85 ff                	test   %edi,%edi
  800b02:	74 04                	je     800b08 <strtol+0xc6>
  800b04:	89 c8                	mov    %ecx,%eax
  800b06:	f7 d8                	neg    %eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	83 ec 1c             	sub    $0x1c,%esp
  800b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b1c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b1f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	8b 75 14             	mov    0x14(%ebp),%esi
  800b24:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	cd 30                	int    $0x30
  800b2f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b35:	74 1c                	je     800b53 <syscall+0x43>
  800b37:	85 c0                	test   %eax,%eax
  800b39:	7e 18                	jle    800b53 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	50                   	push   %eax
  800b3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b42:	68 3f 25 80 00       	push   $0x80253f
  800b47:	6a 42                	push   $0x42
  800b49:	68 5c 25 80 00       	push   $0x80255c
  800b4e:	e8 39 12 00 00       	call   801d8c <_panic>

	return ret;
}
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	ff 75 0c             	pushl  0xc(%ebp)
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
  800b79:	e8 92 ff ff ff       	call   800b10 <syscall>
  800b7e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba0:	e8 6b ff ff ff       	call   800b10 <syscall>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bbd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc2:	e8 49 ff ff ff       	call   800b10 <syscall>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	e8 25 ff ff ff       	call   800b10 <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_yield>:

void
sys_yield(void)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0a:	e8 01 ff ff ff       	call   800b10 <syscall>
  800c0f:	83 c4 10             	add    $0x10,%esp
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c1a:	6a 00                	push   $0x0
  800c1c:	6a 00                	push   $0x0
  800c1e:	ff 75 10             	pushl  0x10(%ebp)
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c27:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c31:	e8 da fe ff ff       	call   800b10 <syscall>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c3e:	ff 75 18             	pushl  0x18(%ebp)
  800c41:	ff 75 14             	pushl  0x14(%ebp)
  800c44:	ff 75 10             	pushl  0x10(%ebp)
  800c47:	ff 75 0c             	pushl  0xc(%ebp)
  800c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	e8 b4 fe ff ff       	call   800b10 <syscall>
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c64:	6a 00                	push   $0x0
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	ff 75 0c             	pushl  0xc(%ebp)
  800c6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c70:	ba 01 00 00 00       	mov    $0x1,%edx
  800c75:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7a:	e8 91 fe ff ff       	call   800b10 <syscall>
}
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	6a 00                	push   $0x0
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c93:	ba 01 00 00 00       	mov    $0x1,%edx
  800c98:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9d:	e8 6e fe ff ff       	call   800b10 <syscall>
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800caa:	6a 00                	push   $0x0
  800cac:	6a 00                	push   $0x0
  800cae:	6a 00                	push   $0x0
  800cb0:	ff 75 0c             	pushl  0xc(%ebp)
  800cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc0:	e8 4b fe ff ff       	call   800b10 <syscall>
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ccd:	6a 00                	push   $0x0
  800ccf:	6a 00                	push   $0x0
  800cd1:	6a 00                	push   $0x0
  800cd3:	ff 75 0c             	pushl  0xc(%ebp)
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cde:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce3:	e8 28 fe ff ff       	call   800b10 <syscall>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cf0:	6a 00                	push   $0x0
  800cf2:	ff 75 14             	pushl  0x14(%ebp)
  800cf5:	ff 75 10             	pushl  0x10(%ebp)
  800cf8:	ff 75 0c             	pushl  0xc(%ebp)
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d08:	e8 03 fe ff ff       	call   800b10 <syscall>
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d15:	6a 00                	push   $0x0
  800d17:	6a 00                	push   $0x0
  800d19:	6a 00                	push   $0x0
  800d1b:	6a 00                	push   $0x0
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	ba 01 00 00 00       	mov    $0x1,%edx
  800d25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2a:	e8 e1 fd ff ff       	call   800b10 <syscall>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	ff 75 0c             	pushl  0xc(%ebp)
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	ba 00 00 00 00       	mov    $0x0,%edx
  800d48:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d4d:	e8 be fd ff ff       	call   800b10 <syscall>
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d5a:	6a 00                	push   $0x0
  800d5c:	ff 75 14             	pushl  0x14(%ebp)
  800d5f:	ff 75 10             	pushl  0x10(%ebp)
  800d62:	ff 75 0c             	pushl  0xc(%ebp)
  800d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d68:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d72:	e8 99 fd ff ff       	call   800b10 <syscall>
} 
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d7f:	6a 00                	push   $0x0
  800d81:	6a 00                	push   $0x0
  800d83:	6a 00                	push   $0x0
  800d85:	6a 00                	push   $0x0
  800d87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 11 00 00 00       	mov    $0x11,%eax
  800d94:	e8 77 fd ff ff       	call   800b10 <syscall>
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800da1:	6a 00                	push   $0x0
  800da3:	6a 00                	push   $0x0
  800da5:	6a 00                	push   $0x0
  800da7:	6a 00                	push   $0x0
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
  800db3:	b8 10 00 00 00       	mov    $0x10,%eax
  800db8:	e8 53 fd ff ff       	call   800b10 <syscall>
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    
	...

00800dc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dca:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800dcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd0:	75 14                	jne    800de6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	68 6c 25 80 00       	push   $0x80256c
  800dda:	6a 20                	push   $0x20
  800ddc:	68 b0 26 80 00       	push   $0x8026b0
  800de1:	e8 a6 0f 00 00       	call   801d8c <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	c1 e8 16             	shr    $0x16,%eax
  800deb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800df2:	a8 01                	test   $0x1,%al
  800df4:	74 11                	je     800e07 <pgfault+0x47>
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	c1 e8 0c             	shr    $0xc,%eax
  800dfb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e02:	f6 c4 08             	test   $0x8,%ah
  800e05:	75 14                	jne    800e1b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	68 90 25 80 00       	push   $0x802590
  800e0f:	6a 24                	push   $0x24
  800e11:	68 b0 26 80 00       	push   $0x8026b0
  800e16:	e8 71 0f 00 00       	call   801d8c <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	6a 07                	push   $0x7
  800e20:	68 00 f0 7f 00       	push   $0x7ff000
  800e25:	6a 00                	push   $0x0
  800e27:	e8 e8 fd ff ff       	call   800c14 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	79 12                	jns    800e45 <pgfault+0x85>
  800e33:	50                   	push   %eax
  800e34:	68 b4 25 80 00       	push   $0x8025b4
  800e39:	6a 32                	push   $0x32
  800e3b:	68 b0 26 80 00       	push   $0x8026b0
  800e40:	e8 47 0f 00 00       	call   801d8c <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e45:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 00 10 00 00       	push   $0x1000
  800e53:	53                   	push   %ebx
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	e8 5f fb ff ff       	call   8009bd <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e5e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e65:	53                   	push   %ebx
  800e66:	6a 00                	push   $0x0
  800e68:	68 00 f0 7f 00       	push   $0x7ff000
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 c4 fd ff ff       	call   800c38 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e74:	83 c4 20             	add    $0x20,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	79 12                	jns    800e8d <pgfault+0xcd>
  800e7b:	50                   	push   %eax
  800e7c:	68 d8 25 80 00       	push   $0x8025d8
  800e81:	6a 3a                	push   $0x3a
  800e83:	68 b0 26 80 00       	push   $0x8026b0
  800e88:	e8 ff 0e 00 00       	call   801d8c <_panic>

	return;
}
  800e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e9b:	68 c0 0d 80 00       	push   $0x800dc0
  800ea0:	e8 2f 0f 00 00       	call   801dd4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ea5:	ba 07 00 00 00       	mov    $0x7,%edx
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	cd 30                	int    $0x30
  800eae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eb1:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 12                	jns    800ecc <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800eba:	50                   	push   %eax
  800ebb:	68 bb 26 80 00       	push   $0x8026bb
  800ec0:	6a 7f                	push   $0x7f
  800ec2:	68 b0 26 80 00       	push   $0x8026b0
  800ec7:	e8 c0 0e 00 00       	call   801d8c <_panic>
	}
	int r;

	if (childpid == 0) {
  800ecc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed0:	75 20                	jne    800ef2 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed2:	e8 f2 fc ff ff       	call   800bc9 <sys_getenvid>
  800ed7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	c1 e2 07             	shl    $0x7,%edx
  800ee1:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800ee8:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800eed:	e9 be 01 00 00       	jmp    8010b0 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	c1 e8 16             	shr    $0x16,%eax
  800efc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f03:	a8 01                	test   $0x1,%al
  800f05:	0f 84 10 01 00 00    	je     80101b <fork+0x189>
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	0f 84 fb 00 00 00    	je     80101b <fork+0x189>
  800f20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f27:	f6 c2 04             	test   $0x4,%dl
  800f2a:	0f 84 eb 00 00 00    	je     80101b <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f30:	89 c6                	mov    %eax,%esi
  800f32:	c1 e6 0c             	shl    $0xc,%esi
  800f35:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f3b:	0f 84 da 00 00 00    	je     80101b <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f41:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f48:	f6 c6 04             	test   $0x4,%dh
  800f4b:	74 37                	je     800f84 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5c:	50                   	push   %eax
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	6a 00                	push   $0x0
  800f62:	e8 d1 fc ff ff       	call   800c38 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f67:	83 c4 20             	add    $0x20,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	0f 89 a9 00 00 00    	jns    80101b <fork+0x189>
  800f72:	50                   	push   %eax
  800f73:	68 fc 25 80 00       	push   $0x8025fc
  800f78:	6a 54                	push   $0x54
  800f7a:	68 b0 26 80 00       	push   $0x8026b0
  800f7f:	e8 08 0e 00 00       	call   801d8c <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f84:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8b:	f6 c2 02             	test   $0x2,%dl
  800f8e:	75 0c                	jne    800f9c <fork+0x10a>
  800f90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f97:	f6 c4 08             	test   $0x8,%ah
  800f9a:	74 57                	je     800ff3 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	68 05 08 00 00       	push   $0x805
  800fa4:	56                   	push   %esi
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 8a fc ff ff       	call   800c38 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fae:	83 c4 20             	add    $0x20,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 12                	jns    800fc7 <fork+0x135>
  800fb5:	50                   	push   %eax
  800fb6:	68 fc 25 80 00       	push   $0x8025fc
  800fbb:	6a 59                	push   $0x59
  800fbd:	68 b0 26 80 00       	push   $0x8026b0
  800fc2:	e8 c5 0d 00 00       	call   801d8c <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	68 05 08 00 00       	push   $0x805
  800fcf:	56                   	push   %esi
  800fd0:	6a 00                	push   $0x0
  800fd2:	56                   	push   %esi
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 5e fc ff ff       	call   800c38 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 3a                	jns    80101b <fork+0x189>
  800fe1:	50                   	push   %eax
  800fe2:	68 fc 25 80 00       	push   $0x8025fc
  800fe7:	6a 5c                	push   $0x5c
  800fe9:	68 b0 26 80 00       	push   $0x8026b0
  800fee:	e8 99 0d 00 00       	call   801d8c <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	6a 05                	push   $0x5
  800ff8:	56                   	push   %esi
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 36 fc ff ff       	call   800c38 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801002:	83 c4 20             	add    $0x20,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	79 12                	jns    80101b <fork+0x189>
  801009:	50                   	push   %eax
  80100a:	68 fc 25 80 00       	push   $0x8025fc
  80100f:	6a 60                	push   $0x60
  801011:	68 b0 26 80 00       	push   $0x8026b0
  801016:	e8 71 0d 00 00       	call   801d8c <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80101b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801021:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801027:	0f 85 ca fe ff ff    	jne    800ef7 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	6a 07                	push   $0x7
  801032:	68 00 f0 bf ee       	push   $0xeebff000
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	e8 d5 fb ff ff       	call   800c14 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	79 15                	jns    80105b <fork+0x1c9>
  801046:	50                   	push   %eax
  801047:	68 20 26 80 00       	push   $0x802620
  80104c:	68 94 00 00 00       	push   $0x94
  801051:	68 b0 26 80 00       	push   $0x8026b0
  801056:	e8 31 0d 00 00       	call   801d8c <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	68 40 1e 80 00       	push   $0x801e40
  801063:	ff 75 e4             	pushl  -0x1c(%ebp)
  801066:	e8 5c fc ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 15                	jns    801087 <fork+0x1f5>
  801072:	50                   	push   %eax
  801073:	68 58 26 80 00       	push   $0x802658
  801078:	68 99 00 00 00       	push   $0x99
  80107d:	68 b0 26 80 00       	push   $0x8026b0
  801082:	e8 05 0d 00 00       	call   801d8c <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	6a 02                	push   $0x2
  80108c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108f:	e8 ed fb ff ff       	call   800c81 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	79 15                	jns    8010b0 <fork+0x21e>
  80109b:	50                   	push   %eax
  80109c:	68 7c 26 80 00       	push   $0x80267c
  8010a1:	68 a4 00 00 00       	push   $0xa4
  8010a6:	68 b0 26 80 00       	push   $0x8026b0
  8010ab:	e8 dc 0c 00 00       	call   801d8c <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <sfork>:

// Challenge!
int
sfork(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c1:	68 d8 26 80 00       	push   $0x8026d8
  8010c6:	68 b1 00 00 00       	push   $0xb1
  8010cb:	68 b0 26 80 00       	push   $0x8026b0
  8010d0:	e8 b7 0c 00 00       	call   801d8c <_panic>
  8010d5:	00 00                	add    %al,(%eax)
	...

008010d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010eb:	ff 75 08             	pushl  0x8(%ebp)
  8010ee:	e8 e5 ff ff ff       	call   8010d8 <fd2num>
  8010f3:	83 c4 04             	add    $0x4,%esp
  8010f6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010fb:	c1 e0 0c             	shl    $0xc,%eax
}
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801107:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80110c:	a8 01                	test   $0x1,%al
  80110e:	74 34                	je     801144 <fd_alloc+0x44>
  801110:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801115:	a8 01                	test   $0x1,%al
  801117:	74 32                	je     80114b <fd_alloc+0x4b>
  801119:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80111e:	89 c1                	mov    %eax,%ecx
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 ea 16             	shr    $0x16,%edx
  801125:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	74 1f                	je     801150 <fd_alloc+0x50>
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 0c             	shr    $0xc,%edx
  801136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	75 17                	jne    801159 <fd_alloc+0x59>
  801142:	eb 0c                	jmp    801150 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801144:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801149:	eb 05                	jmp    801150 <fd_alloc+0x50>
  80114b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801150:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
  801157:	eb 17                	jmp    801170 <fd_alloc+0x70>
  801159:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801163:	75 b9                	jne    80111e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80116b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801170:	5b                   	pop    %ebx
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801179:	83 f8 1f             	cmp    $0x1f,%eax
  80117c:	77 36                	ja     8011b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80117e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801183:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801186:	89 c2                	mov    %eax,%edx
  801188:	c1 ea 16             	shr    $0x16,%edx
  80118b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 24                	je     8011bb <fd_lookup+0x48>
  801197:	89 c2                	mov    %eax,%edx
  801199:	c1 ea 0c             	shr    $0xc,%edx
  80119c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	74 1a                	je     8011c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b2:	eb 13                	jmp    8011c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b9:	eb 0c                	jmp    8011c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c0:	eb 05                	jmp    8011c7 <fd_lookup+0x54>
  8011c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c7:	c9                   	leave  
  8011c8:	c3                   	ret    

008011c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011d6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011dc:	74 0d                	je     8011eb <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e3:	eb 14                	jmp    8011f9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011e5:	39 0a                	cmp    %ecx,(%edx)
  8011e7:	75 10                	jne    8011f9 <dev_lookup+0x30>
  8011e9:	eb 05                	jmp    8011f0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011eb:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011f0:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f7:	eb 31                	jmp    80122a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f9:	40                   	inc    %eax
  8011fa:	8b 14 85 6c 27 80 00 	mov    0x80276c(,%eax,4),%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	75 e0                	jne    8011e5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801205:	a1 04 40 80 00       	mov    0x804004,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	51                   	push   %ecx
  801211:	50                   	push   %eax
  801212:	68 f0 26 80 00       	push   $0x8026f0
  801217:	e8 c0 ef ff ff       	call   8001dc <cprintf>
	*dev = 0;
  80121c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 20             	sub    $0x20,%esp
  801237:	8b 75 08             	mov    0x8(%ebp),%esi
  80123a:	8a 45 0c             	mov    0xc(%ebp),%al
  80123d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801240:	56                   	push   %esi
  801241:	e8 92 fe ff ff       	call   8010d8 <fd2num>
  801246:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801249:	89 14 24             	mov    %edx,(%esp)
  80124c:	50                   	push   %eax
  80124d:	e8 21 ff ff ff       	call   801173 <fd_lookup>
  801252:	89 c3                	mov    %eax,%ebx
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 05                	js     801260 <fd_close+0x31>
	    || fd != fd2)
  80125b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125e:	74 0d                	je     80126d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801260:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801264:	75 48                	jne    8012ae <fd_close+0x7f>
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126b:	eb 41                	jmp    8012ae <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	ff 36                	pushl  (%esi)
  801276:	e8 4e ff ff ff       	call   8011c9 <dev_lookup>
  80127b:	89 c3                	mov    %eax,%ebx
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 1c                	js     8012a0 <fd_close+0x71>
		if (dev->dev_close)
  801284:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801287:	8b 40 10             	mov    0x10(%eax),%eax
  80128a:	85 c0                	test   %eax,%eax
  80128c:	74 0d                	je     80129b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	56                   	push   %esi
  801292:	ff d0                	call   *%eax
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	eb 05                	jmp    8012a0 <fd_close+0x71>
		else
			r = 0;
  80129b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	56                   	push   %esi
  8012a4:	6a 00                	push   $0x0
  8012a6:	e8 b3 f9 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  8012ab:	83 c4 10             	add    $0x10,%esp
}
  8012ae:	89 d8                	mov    %ebx,%eax
  8012b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 75 08             	pushl  0x8(%ebp)
  8012c4:	e8 aa fe ff ff       	call   801173 <fd_lookup>
  8012c9:	83 c4 08             	add    $0x8,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 10                	js     8012e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	6a 01                	push   $0x1
  8012d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d8:	e8 52 ff ff ff       	call   80122f <fd_close>
  8012dd:	83 c4 10             	add    $0x10,%esp
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <close_all>:

void
close_all(void)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	53                   	push   %ebx
  8012f2:	e8 c0 ff ff ff       	call   8012b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f7:	43                   	inc    %ebx
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	83 fb 20             	cmp    $0x20,%ebx
  8012fe:	75 ee                	jne    8012ee <close_all+0xc>
		close(i);
}
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 2c             	sub    $0x2c,%esp
  80130e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801311:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 56 fe ff ff       	call   801173 <fd_lookup>
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 08             	add    $0x8,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	0f 88 c0 00 00 00    	js     8013ea <dup+0xe5>
		return r;
	close(newfdnum);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	57                   	push   %edi
  80132e:	e8 84 ff ff ff       	call   8012b7 <close>

	newfd = INDEX2FD(newfdnum);
  801333:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801339:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80133c:	83 c4 04             	add    $0x4,%esp
  80133f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801342:	e8 a1 fd ff ff       	call   8010e8 <fd2data>
  801347:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801349:	89 34 24             	mov    %esi,(%esp)
  80134c:	e8 97 fd ff ff       	call   8010e8 <fd2data>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801357:	89 d8                	mov    %ebx,%eax
  801359:	c1 e8 16             	shr    $0x16,%eax
  80135c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801363:	a8 01                	test   $0x1,%al
  801365:	74 37                	je     80139e <dup+0x99>
  801367:	89 d8                	mov    %ebx,%eax
  801369:	c1 e8 0c             	shr    $0xc,%eax
  80136c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801373:	f6 c2 01             	test   $0x1,%dl
  801376:	74 26                	je     80139e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801378:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137f:	83 ec 0c             	sub    $0xc,%esp
  801382:	25 07 0e 00 00       	and    $0xe07,%eax
  801387:	50                   	push   %eax
  801388:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138b:	6a 00                	push   $0x0
  80138d:	53                   	push   %ebx
  80138e:	6a 00                	push   $0x0
  801390:	e8 a3 f8 ff ff       	call   800c38 <sys_page_map>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 20             	add    $0x20,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 2d                	js     8013cb <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a1:	89 c2                	mov    %eax,%edx
  8013a3:	c1 ea 0c             	shr    $0xc,%edx
  8013a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013b6:	52                   	push   %edx
  8013b7:	56                   	push   %esi
  8013b8:	6a 00                	push   $0x0
  8013ba:	50                   	push   %eax
  8013bb:	6a 00                	push   $0x0
  8013bd:	e8 76 f8 ff ff       	call   800c38 <sys_page_map>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	83 c4 20             	add    $0x20,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	79 1d                	jns    8013e8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	56                   	push   %esi
  8013cf:	6a 00                	push   $0x0
  8013d1:	e8 88 f8 ff ff       	call   800c5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 7b f8 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb 02                	jmp    8013ea <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013ea:	89 d8                	mov    %ebx,%eax
  8013ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ef:	5b                   	pop    %ebx
  8013f0:	5e                   	pop    %esi
  8013f1:	5f                   	pop    %edi
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 14             	sub    $0x14,%esp
  8013fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	53                   	push   %ebx
  801403:	e8 6b fd ff ff       	call   801173 <fd_lookup>
  801408:	83 c4 08             	add    $0x8,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 67                	js     801476 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801419:	ff 30                	pushl  (%eax)
  80141b:	e8 a9 fd ff ff       	call   8011c9 <dev_lookup>
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 4f                	js     801476 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	8b 50 08             	mov    0x8(%eax),%edx
  80142d:	83 e2 03             	and    $0x3,%edx
  801430:	83 fa 01             	cmp    $0x1,%edx
  801433:	75 21                	jne    801456 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801435:	a1 04 40 80 00       	mov    0x804004,%eax
  80143a:	8b 40 48             	mov    0x48(%eax),%eax
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	53                   	push   %ebx
  801441:	50                   	push   %eax
  801442:	68 31 27 80 00       	push   $0x802731
  801447:	e8 90 ed ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801454:	eb 20                	jmp    801476 <read+0x82>
	}
	if (!dev->dev_read)
  801456:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801459:	8b 52 08             	mov    0x8(%edx),%edx
  80145c:	85 d2                	test   %edx,%edx
  80145e:	74 11                	je     801471 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	ff 75 10             	pushl  0x10(%ebp)
  801466:	ff 75 0c             	pushl  0xc(%ebp)
  801469:	50                   	push   %eax
  80146a:	ff d2                	call   *%edx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	eb 05                	jmp    801476 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801471:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	57                   	push   %edi
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	83 ec 0c             	sub    $0xc,%esp
  801484:	8b 7d 08             	mov    0x8(%ebp),%edi
  801487:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148a:	85 f6                	test   %esi,%esi
  80148c:	74 31                	je     8014bf <readn+0x44>
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	89 f2                	mov    %esi,%edx
  80149d:	29 c2                	sub    %eax,%edx
  80149f:	52                   	push   %edx
  8014a0:	03 45 0c             	add    0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	57                   	push   %edi
  8014a5:	e8 4a ff ff ff       	call   8013f4 <read>
		if (m < 0)
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 17                	js     8014c8 <readn+0x4d>
			return m;
		if (m == 0)
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	74 11                	je     8014c6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b5:	01 c3                	add    %eax,%ebx
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	39 f3                	cmp    %esi,%ebx
  8014bb:	72 db                	jb     801498 <readn+0x1d>
  8014bd:	eb 09                	jmp    8014c8 <readn+0x4d>
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c4:	eb 02                	jmp    8014c8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014c6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 14             	sub    $0x14,%esp
  8014d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	53                   	push   %ebx
  8014df:	e8 8f fc ff ff       	call   801173 <fd_lookup>
  8014e4:	83 c4 08             	add    $0x8,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 62                	js     80154d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	ff 30                	pushl  (%eax)
  8014f7:	e8 cd fc ff ff       	call   8011c9 <dev_lookup>
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 4a                	js     80154d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80150a:	75 21                	jne    80152d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150c:	a1 04 40 80 00       	mov    0x804004,%eax
  801511:	8b 40 48             	mov    0x48(%eax),%eax
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	53                   	push   %ebx
  801518:	50                   	push   %eax
  801519:	68 4d 27 80 00       	push   $0x80274d
  80151e:	e8 b9 ec ff ff       	call   8001dc <cprintf>
		return -E_INVAL;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb 20                	jmp    80154d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801530:	8b 52 0c             	mov    0xc(%edx),%edx
  801533:	85 d2                	test   %edx,%edx
  801535:	74 11                	je     801548 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	ff 75 10             	pushl  0x10(%ebp)
  80153d:	ff 75 0c             	pushl  0xc(%ebp)
  801540:	50                   	push   %eax
  801541:	ff d2                	call   *%edx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	eb 05                	jmp    80154d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801548:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80154d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <seek>:

int
seek(int fdnum, off_t offset)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801558:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	ff 75 08             	pushl  0x8(%ebp)
  80155f:	e8 0f fc ff ff       	call   801173 <fd_lookup>
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	85 c0                	test   %eax,%eax
  801569:	78 0e                	js     801579 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80156e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801571:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801574:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	53                   	push   %ebx
  80157f:	83 ec 14             	sub    $0x14,%esp
  801582:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801585:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	53                   	push   %ebx
  80158a:	e8 e4 fb ff ff       	call   801173 <fd_lookup>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 5f                	js     8015f5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	ff 30                	pushl  (%eax)
  8015a2:	e8 22 fc ff ff       	call   8011c9 <dev_lookup>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 47                	js     8015f5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b5:	75 21                	jne    8015d8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015bc:	8b 40 48             	mov    0x48(%eax),%eax
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	50                   	push   %eax
  8015c4:	68 10 27 80 00       	push   $0x802710
  8015c9:	e8 0e ec ff ff       	call   8001dc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d6:	eb 1d                	jmp    8015f5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015db:	8b 52 18             	mov    0x18(%edx),%edx
  8015de:	85 d2                	test   %edx,%edx
  8015e0:	74 0e                	je     8015f0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	ff 75 0c             	pushl  0xc(%ebp)
  8015e8:	50                   	push   %eax
  8015e9:	ff d2                	call   *%edx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	eb 05                	jmp    8015f5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 14             	sub    $0x14,%esp
  801601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 63 fb ff ff       	call   801173 <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 52                	js     801669 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 a1 fb ff ff       	call   8011c9 <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 3a                	js     801669 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80162f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801632:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801636:	74 2c                	je     801664 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801638:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80163b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801642:	00 00 00 
	stat->st_isdir = 0;
  801645:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164c:	00 00 00 
	stat->st_dev = dev;
  80164f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	53                   	push   %ebx
  801659:	ff 75 f0             	pushl  -0x10(%ebp)
  80165c:	ff 50 14             	call   *0x14(%eax)
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 05                	jmp    801669 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801664:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	6a 00                	push   $0x0
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	e8 78 01 00 00       	call   8017f8 <open>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 1b                	js     8016a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	ff 75 0c             	pushl  0xc(%ebp)
  80168f:	50                   	push   %eax
  801690:	e8 65 ff ff ff       	call   8015fa <fstat>
  801695:	89 c6                	mov    %eax,%esi
	close(fd);
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 18 fc ff ff       	call   8012b7 <close>
	return r;
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	89 f3                	mov    %esi,%ebx
}
  8016a4:	89 d8                	mov    %ebx,%eax
  8016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    
  8016ad:	00 00                	add    %al,(%eax)
	...

008016b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c0:	75 12                	jne    8016d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	6a 01                	push   $0x1
  8016c7:	e8 66 08 00 00       	call   801f32 <ipc_find_env>
  8016cc:	a3 00 40 80 00       	mov    %eax,0x804000
  8016d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d4:	6a 07                	push   $0x7
  8016d6:	68 00 50 80 00       	push   $0x805000
  8016db:	53                   	push   %ebx
  8016dc:	ff 35 00 40 80 00    	pushl  0x804000
  8016e2:	e8 f6 07 00 00       	call   801edd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016e7:	83 c4 0c             	add    $0xc,%esp
  8016ea:	6a 00                	push   $0x0
  8016ec:	56                   	push   %esi
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 74 07 00 00       	call   801e68 <ipc_recv>
}
  8016f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 04             	sub    $0x4,%esp
  801702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	8b 40 0c             	mov    0xc(%eax),%eax
  80170b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	b8 05 00 00 00       	mov    $0x5,%eax
  80171a:	e8 91 ff ff ff       	call   8016b0 <fsipc>
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 2c                	js     80174f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	68 00 50 80 00       	push   $0x805000
  80172b:	53                   	push   %ebx
  80172c:	e8 61 f0 ff ff       	call   800792 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801731:	a1 80 50 80 00       	mov    0x805080,%eax
  801736:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173c:	a1 84 50 80 00       	mov    0x805084,%eax
  801741:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 40 0c             	mov    0xc(%eax),%eax
  801760:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801765:	ba 00 00 00 00       	mov    $0x0,%edx
  80176a:	b8 06 00 00 00       	mov    $0x6,%eax
  80176f:	e8 3c ff ff ff       	call   8016b0 <fsipc>
}
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801789:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 03 00 00 00       	mov    $0x3,%eax
  801799:	e8 12 ff ff ff       	call   8016b0 <fsipc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 4b                	js     8017ef <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017a4:	39 c6                	cmp    %eax,%esi
  8017a6:	73 16                	jae    8017be <devfile_read+0x48>
  8017a8:	68 7c 27 80 00       	push   $0x80277c
  8017ad:	68 83 27 80 00       	push   $0x802783
  8017b2:	6a 7d                	push   $0x7d
  8017b4:	68 98 27 80 00       	push   $0x802798
  8017b9:	e8 ce 05 00 00       	call   801d8c <_panic>
	assert(r <= PGSIZE);
  8017be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c3:	7e 16                	jle    8017db <devfile_read+0x65>
  8017c5:	68 a3 27 80 00       	push   $0x8027a3
  8017ca:	68 83 27 80 00       	push   $0x802783
  8017cf:	6a 7e                	push   $0x7e
  8017d1:	68 98 27 80 00       	push   $0x802798
  8017d6:	e8 b1 05 00 00       	call   801d8c <_panic>
	memmove(buf, &fsipcbuf, r);
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	50                   	push   %eax
  8017df:	68 00 50 80 00       	push   $0x805000
  8017e4:	ff 75 0c             	pushl  0xc(%ebp)
  8017e7:	e8 67 f1 ff ff       	call   800953 <memmove>
	return r;
  8017ec:	83 c4 10             	add    $0x10,%esp
}
  8017ef:	89 d8                	mov    %ebx,%eax
  8017f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 1c             	sub    $0x1c,%esp
  801800:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801803:	56                   	push   %esi
  801804:	e8 37 ef ff ff       	call   800740 <strlen>
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801811:	7f 65                	jg     801878 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	e8 e1 f8 ff ff       	call   801100 <fd_alloc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 55                	js     80187d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	56                   	push   %esi
  80182c:	68 00 50 80 00       	push   $0x805000
  801831:	e8 5c ef ff ff       	call   800792 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801841:	b8 01 00 00 00       	mov    $0x1,%eax
  801846:	e8 65 fe ff ff       	call   8016b0 <fsipc>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	79 12                	jns    801866 <open+0x6e>
		fd_close(fd, 0);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	6a 00                	push   $0x0
  801859:	ff 75 f4             	pushl  -0xc(%ebp)
  80185c:	e8 ce f9 ff ff       	call   80122f <fd_close>
		return r;
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	eb 17                	jmp    80187d <open+0x85>
	}

	return fd2num(fd);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	e8 67 f8 ff ff       	call   8010d8 <fd2num>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	eb 05                	jmp    80187d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801878:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80187d:	89 d8                	mov    %ebx,%eax
  80187f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	c9                   	leave  
  801885:	c3                   	ret    
	...

00801888 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	56                   	push   %esi
  80188c:	53                   	push   %ebx
  80188d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 08             	pushl  0x8(%ebp)
  801896:	e8 4d f8 ff ff       	call   8010e8 <fd2data>
  80189b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80189d:	83 c4 08             	add    $0x8,%esp
  8018a0:	68 af 27 80 00       	push   $0x8027af
  8018a5:	56                   	push   %esi
  8018a6:	e8 e7 ee ff ff       	call   800792 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ab:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ae:	2b 03                	sub    (%ebx),%eax
  8018b0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018b6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018bd:	00 00 00 
	stat->st_dev = &devpipe;
  8018c0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018c7:	30 80 00 
	return 0;
}
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018e0:	53                   	push   %ebx
  8018e1:	6a 00                	push   $0x0
  8018e3:	e8 76 f3 ff ff       	call   800c5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e8:	89 1c 24             	mov    %ebx,(%esp)
  8018eb:	e8 f8 f7 ff ff       	call   8010e8 <fd2data>
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	50                   	push   %eax
  8018f4:	6a 00                	push   $0x0
  8018f6:	e8 63 f3 ff ff       	call   800c5e <sys_page_unmap>
}
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	57                   	push   %edi
  801904:	56                   	push   %esi
  801905:	53                   	push   %ebx
  801906:	83 ec 1c             	sub    $0x1c,%esp
  801909:	89 c7                	mov    %eax,%edi
  80190b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80190e:	a1 04 40 80 00       	mov    0x804004,%eax
  801913:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801916:	83 ec 0c             	sub    $0xc,%esp
  801919:	57                   	push   %edi
  80191a:	e8 61 06 00 00       	call   801f80 <pageref>
  80191f:	89 c6                	mov    %eax,%esi
  801921:	83 c4 04             	add    $0x4,%esp
  801924:	ff 75 e4             	pushl  -0x1c(%ebp)
  801927:	e8 54 06 00 00       	call   801f80 <pageref>
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	39 c6                	cmp    %eax,%esi
  801931:	0f 94 c0             	sete   %al
  801934:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801937:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80193d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801940:	39 cb                	cmp    %ecx,%ebx
  801942:	75 08                	jne    80194c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801944:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5f                   	pop    %edi
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80194c:	83 f8 01             	cmp    $0x1,%eax
  80194f:	75 bd                	jne    80190e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801951:	8b 42 58             	mov    0x58(%edx),%eax
  801954:	6a 01                	push   $0x1
  801956:	50                   	push   %eax
  801957:	53                   	push   %ebx
  801958:	68 b6 27 80 00       	push   $0x8027b6
  80195d:	e8 7a e8 ff ff       	call   8001dc <cprintf>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	eb a7                	jmp    80190e <_pipeisclosed+0xe>

00801967 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	57                   	push   %edi
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 28             	sub    $0x28,%esp
  801970:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801973:	56                   	push   %esi
  801974:	e8 6f f7 ff ff       	call   8010e8 <fd2data>
  801979:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801982:	75 4a                	jne    8019ce <devpipe_write+0x67>
  801984:	bf 00 00 00 00       	mov    $0x0,%edi
  801989:	eb 56                	jmp    8019e1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80198b:	89 da                	mov    %ebx,%edx
  80198d:	89 f0                	mov    %esi,%eax
  80198f:	e8 6c ff ff ff       	call   801900 <_pipeisclosed>
  801994:	85 c0                	test   %eax,%eax
  801996:	75 4d                	jne    8019e5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801998:	e8 50 f2 ff ff       	call   800bed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80199d:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a0:	8b 13                	mov    (%ebx),%edx
  8019a2:	83 c2 20             	add    $0x20,%edx
  8019a5:	39 d0                	cmp    %edx,%eax
  8019a7:	73 e2                	jae    80198b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019b1:	79 05                	jns    8019b8 <devpipe_write+0x51>
  8019b3:	4a                   	dec    %edx
  8019b4:	83 ca e0             	or     $0xffffffe0,%edx
  8019b7:	42                   	inc    %edx
  8019b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8019be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019c2:	40                   	inc    %eax
  8019c3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c6:	47                   	inc    %edi
  8019c7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8019ca:	77 07                	ja     8019d3 <devpipe_write+0x6c>
  8019cc:	eb 13                	jmp    8019e1 <devpipe_write+0x7a>
  8019ce:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d6:	8b 13                	mov    (%ebx),%edx
  8019d8:	83 c2 20             	add    $0x20,%edx
  8019db:	39 d0                	cmp    %edx,%eax
  8019dd:	73 ac                	jae    80198b <devpipe_write+0x24>
  8019df:	eb c8                	jmp    8019a9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019e1:	89 f8                	mov    %edi,%eax
  8019e3:	eb 05                	jmp    8019ea <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5f                   	pop    %edi
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 18             	sub    $0x18,%esp
  8019fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019fe:	57                   	push   %edi
  8019ff:	e8 e4 f6 ff ff       	call   8010e8 <fd2data>
  801a04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a0d:	75 44                	jne    801a53 <devpipe_read+0x61>
  801a0f:	be 00 00 00 00       	mov    $0x0,%esi
  801a14:	eb 4f                	jmp    801a65 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a16:	89 f0                	mov    %esi,%eax
  801a18:	eb 54                	jmp    801a6e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a1a:	89 da                	mov    %ebx,%edx
  801a1c:	89 f8                	mov    %edi,%eax
  801a1e:	e8 dd fe ff ff       	call   801900 <_pipeisclosed>
  801a23:	85 c0                	test   %eax,%eax
  801a25:	75 42                	jne    801a69 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a27:	e8 c1 f1 ff ff       	call   800bed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a2c:	8b 03                	mov    (%ebx),%eax
  801a2e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a31:	74 e7                	je     801a1a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a33:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a38:	79 05                	jns    801a3f <devpipe_read+0x4d>
  801a3a:	48                   	dec    %eax
  801a3b:	83 c8 e0             	or     $0xffffffe0,%eax
  801a3e:	40                   	inc    %eax
  801a3f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a46:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a49:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4b:	46                   	inc    %esi
  801a4c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a4f:	77 07                	ja     801a58 <devpipe_read+0x66>
  801a51:	eb 12                	jmp    801a65 <devpipe_read+0x73>
  801a53:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a58:	8b 03                	mov    (%ebx),%eax
  801a5a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a5d:	75 d4                	jne    801a33 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5f:	85 f6                	test   %esi,%esi
  801a61:	75 b3                	jne    801a16 <devpipe_read+0x24>
  801a63:	eb b5                	jmp    801a1a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a65:	89 f0                	mov    %esi,%eax
  801a67:	eb 05                	jmp    801a6e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a69:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 28             	sub    $0x28,%esp
  801a7f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	e8 75 f6 ff ff       	call   801100 <fd_alloc>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	0f 88 24 01 00 00    	js     801bbc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	68 07 04 00 00       	push   $0x407
  801aa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 6a f1 ff ff       	call   800c14 <sys_page_alloc>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	0f 88 05 01 00 00    	js     801bbc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801abd:	50                   	push   %eax
  801abe:	e8 3d f6 ff ff       	call   801100 <fd_alloc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	0f 88 dc 00 00 00    	js     801bac <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad0:	83 ec 04             	sub    $0x4,%esp
  801ad3:	68 07 04 00 00       	push   $0x407
  801ad8:	ff 75 e0             	pushl  -0x20(%ebp)
  801adb:	6a 00                	push   $0x0
  801add:	e8 32 f1 ff ff       	call   800c14 <sys_page_alloc>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	0f 88 bd 00 00 00    	js     801bac <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af5:	e8 ee f5 ff ff       	call   8010e8 <fd2data>
  801afa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afc:	83 c4 0c             	add    $0xc,%esp
  801aff:	68 07 04 00 00       	push   $0x407
  801b04:	50                   	push   %eax
  801b05:	6a 00                	push   $0x0
  801b07:	e8 08 f1 ff ff       	call   800c14 <sys_page_alloc>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	0f 88 83 00 00 00    	js     801b9c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1f:	e8 c4 f5 ff ff       	call   8010e8 <fd2data>
  801b24:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b2b:	50                   	push   %eax
  801b2c:	6a 00                	push   $0x0
  801b2e:	56                   	push   %esi
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 02 f1 ff ff       	call   800c38 <sys_page_map>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	83 c4 20             	add    $0x20,%esp
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 4f                	js     801b8e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b3f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b48:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b54:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b5d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b62:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b69:	83 ec 0c             	sub    $0xc,%esp
  801b6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b6f:	e8 64 f5 ff ff       	call   8010d8 <fd2num>
  801b74:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b76:	83 c4 04             	add    $0x4,%esp
  801b79:	ff 75 e0             	pushl  -0x20(%ebp)
  801b7c:	e8 57 f5 ff ff       	call   8010d8 <fd2num>
  801b81:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8c:	eb 2e                	jmp    801bbc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b8e:	83 ec 08             	sub    $0x8,%esp
  801b91:	56                   	push   %esi
  801b92:	6a 00                	push   $0x0
  801b94:	e8 c5 f0 ff ff       	call   800c5e <sys_page_unmap>
  801b99:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 b5 f0 ff ff       	call   800c5e <sys_page_unmap>
  801ba9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 a5 f0 ff ff       	call   800c5e <sys_page_unmap>
  801bb9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc1:	5b                   	pop    %ebx
  801bc2:	5e                   	pop    %esi
  801bc3:	5f                   	pop    %edi
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcf:	50                   	push   %eax
  801bd0:	ff 75 08             	pushl  0x8(%ebp)
  801bd3:	e8 9b f5 ff ff       	call   801173 <fd_lookup>
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 18                	js     801bf7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	ff 75 f4             	pushl  -0xc(%ebp)
  801be5:	e8 fe f4 ff ff       	call   8010e8 <fd2data>
	return _pipeisclosed(fd, p);
  801bea:	89 c2                	mov    %eax,%edx
  801bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bef:	e8 0c fd ff ff       	call   801900 <_pipeisclosed>
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    
  801bf9:	00 00                	add    %al,(%eax)
	...

00801bfc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c0c:	68 ce 27 80 00       	push   $0x8027ce
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	e8 79 eb ff ff       	call   800792 <strcpy>
	return 0;
}
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	57                   	push   %edi
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c30:	74 45                	je     801c77 <devcons_write+0x57>
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
  801c37:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c45:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c47:	83 fb 7f             	cmp    $0x7f,%ebx
  801c4a:	76 05                	jbe    801c51 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c4c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	53                   	push   %ebx
  801c55:	03 45 0c             	add    0xc(%ebp),%eax
  801c58:	50                   	push   %eax
  801c59:	57                   	push   %edi
  801c5a:	e8 f4 ec ff ff       	call   800953 <memmove>
		sys_cputs(buf, m);
  801c5f:	83 c4 08             	add    $0x8,%esp
  801c62:	53                   	push   %ebx
  801c63:	57                   	push   %edi
  801c64:	e8 f4 ee ff ff       	call   800b5d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c69:	01 de                	add    %ebx,%esi
  801c6b:	89 f0                	mov    %esi,%eax
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c73:	72 cd                	jb     801c42 <devcons_write+0x22>
  801c75:	eb 05                	jmp    801c7c <devcons_write+0x5c>
  801c77:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c90:	75 07                	jne    801c99 <devcons_read+0x13>
  801c92:	eb 25                	jmp    801cb9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c94:	e8 54 ef ff ff       	call   800bed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c99:	e8 e5 ee ff ff       	call   800b83 <sys_cgetc>
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	74 f2                	je     801c94 <devcons_read+0xe>
  801ca2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 1d                	js     801cc5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca8:	83 f8 04             	cmp    $0x4,%eax
  801cab:	74 13                	je     801cc0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb0:	88 10                	mov    %dl,(%eax)
	return 1;
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb 0c                	jmp    801cc5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	eb 05                	jmp    801cc5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd3:	6a 01                	push   $0x1
  801cd5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	e8 7f ee ff ff       	call   800b5d <sys_cputs>
  801cde:	83 c4 10             	add    $0x10,%esp
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <getchar>:

int
getchar(void)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce9:	6a 01                	push   $0x1
  801ceb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 fe f6 ff ff       	call   8013f4 <read>
	if (r < 0)
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 0f                	js     801d0c <getchar+0x29>
		return r;
	if (r < 1)
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	7e 06                	jle    801d07 <getchar+0x24>
		return -E_EOF;
	return c;
  801d01:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d05:	eb 05                	jmp    801d0c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d07:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	ff 75 08             	pushl  0x8(%ebp)
  801d1b:	e8 53 f4 ff ff       	call   801173 <fd_lookup>
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 11                	js     801d38 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d30:	39 10                	cmp    %edx,(%eax)
  801d32:	0f 94 c0             	sete   %al
  801d35:	0f b6 c0             	movzbl %al,%eax
}
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <opencons>:

int
opencons(void)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d43:	50                   	push   %eax
  801d44:	e8 b7 f3 ff ff       	call   801100 <fd_alloc>
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 3a                	js     801d8a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d50:	83 ec 04             	sub    $0x4,%esp
  801d53:	68 07 04 00 00       	push   $0x407
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 b2 ee ff ff       	call   800c14 <sys_page_alloc>
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 21                	js     801d8a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	50                   	push   %eax
  801d82:	e8 51 f3 ff ff       	call   8010d8 <fd2num>
  801d87:	83 c4 10             	add    $0x10,%esp
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d91:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d94:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d9a:	e8 2a ee ff ff       	call   800bc9 <sys_getenvid>
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	ff 75 0c             	pushl  0xc(%ebp)
  801da5:	ff 75 08             	pushl  0x8(%ebp)
  801da8:	53                   	push   %ebx
  801da9:	50                   	push   %eax
  801daa:	68 dc 27 80 00       	push   $0x8027dc
  801daf:	e8 28 e4 ff ff       	call   8001dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db4:	83 c4 18             	add    $0x18,%esp
  801db7:	56                   	push   %esi
  801db8:	ff 75 10             	pushl  0x10(%ebp)
  801dbb:	e8 cb e3 ff ff       	call   80018b <vcprintf>
	cprintf("\n");
  801dc0:	c7 04 24 2f 22 80 00 	movl   $0x80222f,(%esp)
  801dc7:	e8 10 e4 ff ff       	call   8001dc <cprintf>
  801dcc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dcf:	cc                   	int3   
  801dd0:	eb fd                	jmp    801dcf <_panic+0x43>
	...

00801dd4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dda:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de1:	75 52                	jne    801e35 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801de3:	83 ec 04             	sub    $0x4,%esp
  801de6:	6a 07                	push   $0x7
  801de8:	68 00 f0 bf ee       	push   $0xeebff000
  801ded:	6a 00                	push   $0x0
  801def:	e8 20 ee ff ff       	call   800c14 <sys_page_alloc>
		if (r < 0) {
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	79 12                	jns    801e0d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801dfb:	50                   	push   %eax
  801dfc:	68 ff 27 80 00       	push   $0x8027ff
  801e01:	6a 24                	push   $0x24
  801e03:	68 1a 28 80 00       	push   $0x80281a
  801e08:	e8 7f ff ff ff       	call   801d8c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801e0d:	83 ec 08             	sub    $0x8,%esp
  801e10:	68 40 1e 80 00       	push   $0x801e40
  801e15:	6a 00                	push   $0x0
  801e17:	e8 ab ee ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	79 12                	jns    801e35 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801e23:	50                   	push   %eax
  801e24:	68 28 28 80 00       	push   $0x802828
  801e29:	6a 2a                	push   $0x2a
  801e2b:	68 1a 28 80 00       	push   $0x80281a
  801e30:	e8 57 ff ff ff       	call   801d8c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    
	...

00801e40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e41:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e48:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e4b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e4f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e52:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e56:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e5a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e5c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e5f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e60:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e63:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e64:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e65:	c3                   	ret    
	...

00801e68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e76:	85 c0                	test   %eax,%eax
  801e78:	74 0e                	je     801e88 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	50                   	push   %eax
  801e7e:	e8 8c ee ff ff       	call   800d0f <sys_ipc_recv>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	eb 10                	jmp    801e98 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e88:	83 ec 0c             	sub    $0xc,%esp
  801e8b:	68 00 00 c0 ee       	push   $0xeec00000
  801e90:	e8 7a ee ff ff       	call   800d0f <sys_ipc_recv>
  801e95:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	75 26                	jne    801ec2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e9c:	85 f6                	test   %esi,%esi
  801e9e:	74 0a                	je     801eaa <ipc_recv+0x42>
  801ea0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea5:	8b 40 74             	mov    0x74(%eax),%eax
  801ea8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801eaa:	85 db                	test   %ebx,%ebx
  801eac:	74 0a                	je     801eb8 <ipc_recv+0x50>
  801eae:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb3:	8b 40 78             	mov    0x78(%eax),%eax
  801eb6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801eb8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebd:	8b 40 70             	mov    0x70(%eax),%eax
  801ec0:	eb 14                	jmp    801ed6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ec2:	85 f6                	test   %esi,%esi
  801ec4:	74 06                	je     801ecc <ipc_recv+0x64>
  801ec6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	74 06                	je     801ed6 <ipc_recv+0x6e>
  801ed0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	57                   	push   %edi
  801ee1:	56                   	push   %esi
  801ee2:	53                   	push   %ebx
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eec:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801eef:	85 db                	test   %ebx,%ebx
  801ef1:	75 25                	jne    801f18 <ipc_send+0x3b>
  801ef3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ef8:	eb 1e                	jmp    801f18 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801efa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efd:	75 07                	jne    801f06 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801eff:	e8 e9 ec ff ff       	call   800bed <sys_yield>
  801f04:	eb 12                	jmp    801f18 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801f06:	50                   	push   %eax
  801f07:	68 50 28 80 00       	push   $0x802850
  801f0c:	6a 43                	push   $0x43
  801f0e:	68 63 28 80 00       	push   $0x802863
  801f13:	e8 74 fe ff ff       	call   801d8c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	57                   	push   %edi
  801f1b:	ff 75 08             	pushl  0x8(%ebp)
  801f1e:	e8 c7 ed ff ff       	call   800cea <sys_ipc_try_send>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 d0                	jne    801efa <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f38:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801f3e:	74 1a                	je     801f5a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f40:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f45:	89 c2                	mov    %eax,%edx
  801f47:	c1 e2 07             	shl    $0x7,%edx
  801f4a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f51:	8b 52 50             	mov    0x50(%edx),%edx
  801f54:	39 ca                	cmp    %ecx,%edx
  801f56:	75 18                	jne    801f70 <ipc_find_env+0x3e>
  801f58:	eb 05                	jmp    801f5f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f5f:	89 c2                	mov    %eax,%edx
  801f61:	c1 e2 07             	shl    $0x7,%edx
  801f64:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801f6b:	8b 40 40             	mov    0x40(%eax),%eax
  801f6e:	eb 0c                	jmp    801f7c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f70:	40                   	inc    %eax
  801f71:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f76:	75 cd                	jne    801f45 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f78:	66 b8 00 00          	mov    $0x0,%ax
}
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    
	...

00801f80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	c1 ea 16             	shr    $0x16,%edx
  801f8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f92:	f6 c2 01             	test   $0x1,%dl
  801f95:	74 1e                	je     801fb5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f97:	c1 e8 0c             	shr    $0xc,%eax
  801f9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fa1:	a8 01                	test   $0x1,%al
  801fa3:	74 17                	je     801fbc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa5:	c1 e8 0c             	shr    $0xc,%eax
  801fa8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801faf:	ef 
  801fb0:	0f b7 c0             	movzwl %ax,%eax
  801fb3:	eb 0c                	jmp    801fc1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fba:	eb 05                	jmp    801fc1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    
	...

00801fc4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	57                   	push   %edi
  801fc8:	56                   	push   %esi
  801fc9:	83 ec 10             	sub    $0x10,%esp
  801fcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fd2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fdb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	75 2e                	jne    802010 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fe2:	39 f1                	cmp    %esi,%ecx
  801fe4:	77 5a                	ja     802040 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fe6:	85 c9                	test   %ecx,%ecx
  801fe8:	75 0b                	jne    801ff5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fea:	b8 01 00 00 00       	mov    $0x1,%eax
  801fef:	31 d2                	xor    %edx,%edx
  801ff1:	f7 f1                	div    %ecx
  801ff3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ff5:	31 d2                	xor    %edx,%edx
  801ff7:	89 f0                	mov    %esi,%eax
  801ff9:	f7 f1                	div    %ecx
  801ffb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ffd:	89 f8                	mov    %edi,%eax
  801fff:	f7 f1                	div    %ecx
  802001:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802003:	89 f8                	mov    %edi,%eax
  802005:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    
  80200e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802010:	39 f0                	cmp    %esi,%eax
  802012:	77 1c                	ja     802030 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802014:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	75 3c                	jne    802058 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80201c:	39 f0                	cmp    %esi,%eax
  80201e:	0f 82 90 00 00 00    	jb     8020b4 <__udivdi3+0xf0>
  802024:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802027:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80202a:	0f 86 84 00 00 00    	jbe    8020b4 <__udivdi3+0xf0>
  802030:	31 f6                	xor    %esi,%esi
  802032:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802034:	89 f8                	mov    %edi,%eax
  802036:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	5e                   	pop    %esi
  80203c:	5f                   	pop    %edi
  80203d:	c9                   	leave  
  80203e:	c3                   	ret    
  80203f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802040:	89 f2                	mov    %esi,%edx
  802042:	89 f8                	mov    %edi,%eax
  802044:	f7 f1                	div    %ecx
  802046:	89 c7                	mov    %eax,%edi
  802048:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80204a:	89 f8                	mov    %edi,%eax
  80204c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	c9                   	leave  
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802058:	89 f9                	mov    %edi,%ecx
  80205a:	d3 e0                	shl    %cl,%eax
  80205c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80205f:	b8 20 00 00 00       	mov    $0x20,%eax
  802064:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802066:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802069:	88 c1                	mov    %al,%cl
  80206b:	d3 ea                	shr    %cl,%edx
  80206d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802070:	09 ca                	or     %ecx,%edx
  802072:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802075:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802078:	89 f9                	mov    %edi,%ecx
  80207a:	d3 e2                	shl    %cl,%edx
  80207c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80207f:	89 f2                	mov    %esi,%edx
  802081:	88 c1                	mov    %al,%cl
  802083:	d3 ea                	shr    %cl,%edx
  802085:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802088:	89 f2                	mov    %esi,%edx
  80208a:	89 f9                	mov    %edi,%ecx
  80208c:	d3 e2                	shl    %cl,%edx
  80208e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802091:	88 c1                	mov    %al,%cl
  802093:	d3 ee                	shr    %cl,%esi
  802095:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802097:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80209a:	89 f0                	mov    %esi,%eax
  80209c:	89 ca                	mov    %ecx,%edx
  80209e:	f7 75 ec             	divl   -0x14(%ebp)
  8020a1:	89 d1                	mov    %edx,%ecx
  8020a3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020a5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020a8:	39 d1                	cmp    %edx,%ecx
  8020aa:	72 28                	jb     8020d4 <__udivdi3+0x110>
  8020ac:	74 1a                	je     8020c8 <__udivdi3+0x104>
  8020ae:	89 f7                	mov    %esi,%edi
  8020b0:	31 f6                	xor    %esi,%esi
  8020b2:	eb 80                	jmp    802034 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020b4:	31 f6                	xor    %esi,%esi
  8020b6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020bb:	89 f8                	mov    %edi,%eax
  8020bd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	c9                   	leave  
  8020c5:	c3                   	ret    
  8020c6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020cb:	89 f9                	mov    %edi,%ecx
  8020cd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020cf:	39 c2                	cmp    %eax,%edx
  8020d1:	73 db                	jae    8020ae <__udivdi3+0xea>
  8020d3:	90                   	nop
		{
		  q0--;
  8020d4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020d7:	31 f6                	xor    %esi,%esi
  8020d9:	e9 56 ff ff ff       	jmp    802034 <__udivdi3+0x70>
	...

008020e0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	83 ec 20             	sub    $0x20,%esp
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020f4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020fd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ff:	85 ff                	test   %edi,%edi
  802101:	75 15                	jne    802118 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802103:	39 f1                	cmp    %esi,%ecx
  802105:	0f 86 99 00 00 00    	jbe    8021a4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80210b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80210d:	89 d0                	mov    %edx,%eax
  80210f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802111:	83 c4 20             	add    $0x20,%esp
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	c9                   	leave  
  802117:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802118:	39 f7                	cmp    %esi,%edi
  80211a:	0f 87 a4 00 00 00    	ja     8021c4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802120:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802123:	83 f0 1f             	xor    $0x1f,%eax
  802126:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802129:	0f 84 a1 00 00 00    	je     8021d0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80212f:	89 f8                	mov    %edi,%eax
  802131:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802134:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802136:	bf 20 00 00 00       	mov    $0x20,%edi
  80213b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80213e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 ea                	shr    %cl,%edx
  802145:	09 c2                	or     %eax,%edx
  802147:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80214a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802150:	d3 e0                	shl    %cl,%eax
  802152:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802155:	89 f2                	mov    %esi,%edx
  802157:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802159:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802161:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802164:	89 f9                	mov    %edi,%ecx
  802166:	d3 e8                	shr    %cl,%eax
  802168:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80216a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80216c:	89 f2                	mov    %esi,%edx
  80216e:	f7 75 f0             	divl   -0x10(%ebp)
  802171:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802173:	f7 65 f4             	mull   -0xc(%ebp)
  802176:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802179:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80217b:	39 d6                	cmp    %edx,%esi
  80217d:	72 71                	jb     8021f0 <__umoddi3+0x110>
  80217f:	74 7f                	je     802200 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802181:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802184:	29 c8                	sub    %ecx,%eax
  802186:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802188:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	89 f9                	mov    %edi,%ecx
  802191:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802193:	09 d0                	or     %edx,%eax
  802195:	89 f2                	mov    %esi,%edx
  802197:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80219a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80219c:	83 c4 20             	add    $0x20,%esp
  80219f:	5e                   	pop    %esi
  8021a0:	5f                   	pop    %edi
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    
  8021a3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021a4:	85 c9                	test   %ecx,%ecx
  8021a6:	75 0b                	jne    8021b3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	f7 f1                	div    %ecx
  8021b1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021b3:	89 f0                	mov    %esi,%eax
  8021b5:	31 d2                	xor    %edx,%edx
  8021b7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021bc:	f7 f1                	div    %ecx
  8021be:	e9 4a ff ff ff       	jmp    80210d <__umoddi3+0x2d>
  8021c3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021c4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c6:	83 c4 20             	add    $0x20,%esp
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021d0:	39 f7                	cmp    %esi,%edi
  8021d2:	72 05                	jb     8021d9 <__umoddi3+0xf9>
  8021d4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021d7:	77 0c                	ja     8021e5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021d9:	89 f2                	mov    %esi,%edx
  8021db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021de:	29 c8                	sub    %ecx,%eax
  8021e0:	19 fa                	sbb    %edi,%edx
  8021e2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e8:	83 c4 20             	add    $0x20,%esp
  8021eb:	5e                   	pop    %esi
  8021ec:	5f                   	pop    %edi
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    
  8021ef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021f3:	89 c1                	mov    %eax,%ecx
  8021f5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021f8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021fb:	eb 84                	jmp    802181 <__umoddi3+0xa1>
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802200:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802203:	72 eb                	jb     8021f0 <__umoddi3+0x110>
  802205:	89 f2                	mov    %esi,%edx
  802207:	e9 75 ff ff ff       	jmp    802181 <__umoddi3+0xa1>
