
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cf 00 00 00       	call   800100 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 95 10 00 00       	call   8010d7 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 42                	je     80008b <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 91 0b 00 00       	call   800be5 <sys_getenvid>
  800054:	83 ec 04             	sub    $0x4,%esp
  800057:	53                   	push   %ebx
  800058:	50                   	push   %eax
  800059:	68 40 22 80 00       	push   $0x802240
  80005e:	e8 95 01 00 00       	call   8001f8 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800063:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800066:	e8 7a 0b 00 00       	call   800be5 <sys_getenvid>
  80006b:	83 c4 0c             	add    $0xc,%esp
  80006e:	53                   	push   %ebx
  80006f:	50                   	push   %eax
  800070:	68 5a 22 80 00       	push   $0x80225a
  800075:	e8 7e 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	6a 00                	push   $0x0
  800080:	ff 75 e4             	pushl  -0x1c(%ebp)
  800083:	e8 e1 10 00 00       	call   801169 <ipc_send>
  800088:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008b:	83 ec 04             	sub    $0x4,%esp
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	e8 59 10 00 00       	call   8010f4 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009b:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a1:	8b 73 48             	mov    0x48(%ebx),%esi
  8000a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000af:	e8 31 0b 00 00       	call   800be5 <sys_getenvid>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	57                   	push   %edi
  8000ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bd:	50                   	push   %eax
  8000be:	68 70 22 80 00       	push   $0x802270
  8000c3:	e8 30 01 00 00       	call   8001f8 <cprintf>
		if (val == 10)
  8000c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cd:	83 c4 20             	add    $0x20,%esp
  8000d0:	83 f8 0a             	cmp    $0xa,%eax
  8000d3:	74 20                	je     8000f5 <umain+0xc1>
			return;
		++val;
  8000d5:	40                   	inc    %eax
  8000d6:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000db:	6a 00                	push   $0x0
  8000dd:	6a 00                	push   $0x0
  8000df:	6a 00                	push   $0x0
  8000e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e4:	e8 80 10 00 00       	call   801169 <ipc_send>
		if (val == 10)
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f3:	75 96                	jne    80008b <umain+0x57>
			return;
	}

}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 75 08             	mov    0x8(%ebp),%esi
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010b:	e8 d5 0a 00 00       	call   800be5 <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	89 c2                	mov    %eax,%edx
  800117:	c1 e2 07             	shl    $0x7,%edx
  80011a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800121:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x31>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	53                   	push   %ebx
  800135:	56                   	push   %esi
  800136:	e8 f9 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013b:	e8 0c 00 00 00       	call   80014c <exit>
  800140:	83 c4 10             	add    $0x10,%esp
}
  800143:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	c9                   	leave  
  800149:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800152:	e8 bf 12 00 00       	call   801416 <close_all>
	sys_env_destroy(0);
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	6a 00                	push   $0x0
  80015c:	e8 62 0a 00 00       	call   800bc3 <sys_env_destroy>
  800161:	83 c4 10             	add    $0x10,%esp
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 1a                	jne    80019f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 e3 09 00 00       	call   800b79 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019f:	ff 43 04             	incl   0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 68 01 80 00       	push   $0x800168
  8001d6:	e8 82 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 89 09 00 00       	call   800b79 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 2c             	sub    $0x2c,%esp
  800215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800218:	89 d6                	mov    %edx,%esi
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800220:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800223:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800226:	8b 45 10             	mov    0x10(%ebp),%eax
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80022c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800232:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800239:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80023c:	72 0c                	jb     80024a <printnum+0x3e>
  80023e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800241:	76 07                	jbe    80024a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800243:	4b                   	dec    %ebx
  800244:	85 db                	test   %ebx,%ebx
  800246:	7f 31                	jg     800279 <printnum+0x6d>
  800248:	eb 3f                	jmp    800289 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	57                   	push   %edi
  80024e:	4b                   	dec    %ebx
  80024f:	53                   	push   %ebx
  800250:	50                   	push   %eax
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	ff 75 d4             	pushl  -0x2c(%ebp)
  800257:	ff 75 d0             	pushl  -0x30(%ebp)
  80025a:	ff 75 dc             	pushl  -0x24(%ebp)
  80025d:	ff 75 d8             	pushl  -0x28(%ebp)
  800260:	e8 7b 1d 00 00       	call   801fe0 <__udivdi3>
  800265:	83 c4 18             	add    $0x18,%esp
  800268:	52                   	push   %edx
  800269:	50                   	push   %eax
  80026a:	89 f2                	mov    %esi,%edx
  80026c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026f:	e8 98 ff ff ff       	call   80020c <printnum>
  800274:	83 c4 20             	add    $0x20,%esp
  800277:	eb 10                	jmp    800289 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	57                   	push   %edi
  80027e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800281:	4b                   	dec    %ebx
  800282:	83 c4 10             	add    $0x10,%esp
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f f0                	jg     800279 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 d4             	pushl  -0x2c(%ebp)
  800293:	ff 75 d0             	pushl  -0x30(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 5b 1e 00 00       	call   8020fc <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff 55 e4             	call   *-0x1c(%ebp)
  8002af:	83 c4 10             	add    $0x10,%esp
}
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getint+0x16>
		return va_arg(*ap, long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 1a                	jmp    800324 <getint+0x30>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 0c                	je     80031a <getint+0x26>
		return va_arg(*ap, long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
  800318:	eb 0a                	jmp    800324 <getint+0x30>
	else
		return va_arg(*ap, int);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	99                   	cltd   
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	3b 50 04             	cmp    0x4(%eax),%edx
  800334:	73 08                	jae    80033e <sprintputch+0x18>
		*b->buf++ = ch;
  800336:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800339:	88 0a                	mov    %cl,(%edx)
  80033b:	42                   	inc    %edx
  80033c:	89 10                	mov    %edx,(%eax)
}
  80033e:	c9                   	leave  
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
  800358:	83 c4 10             	add    $0x10,%esp
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800369:	8b 75 10             	mov    0x10(%ebp),%esi
  80036c:	eb 13                	jmp    800381 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036e:	85 c0                	test   %eax,%eax
  800370:	0f 84 6d 03 00 00    	je     8006e3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	57                   	push   %edi
  80037a:	50                   	push   %eax
  80037b:	ff 55 08             	call   *0x8(%ebp)
  80037e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e4                	jne    80036e <vprintfmt+0x11>
  80038a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80038e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800395:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80039c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a8:	eb 28                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003b0:	eb 20                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003b8:	eb 18                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c3:	eb 0d                	jmp    8003d2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8a 06                	mov    (%esi),%al
  8003d4:	0f b6 d0             	movzbl %al,%edx
  8003d7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003da:	83 e8 23             	sub    $0x23,%eax
  8003dd:	3c 55                	cmp    $0x55,%al
  8003df:	0f 87 e0 02 00 00    	ja     8006c5 <vprintfmt+0x368>
  8003e5:	0f b6 c0             	movzbl %al,%eax
  8003e8:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ef:	83 ea 30             	sub    $0x30,%edx
  8003f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003f8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003fb:	83 fa 09             	cmp    $0x9,%edx
  8003fe:	77 44                	ja     800444 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
  800402:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800405:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800406:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800409:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80040d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800410:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800413:	83 fb 09             	cmp    $0x9,%ebx
  800416:	76 ed                	jbe    800405 <vprintfmt+0xa8>
  800418:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80041b:	eb 29                	jmp    800446 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042d:	eb 17                	jmp    800446 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80042f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800433:	78 85                	js     8003ba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	89 de                	mov    %ebx,%esi
  800437:	eb 99                	jmp    8003d2 <vprintfmt+0x75>
  800439:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800442:	eb 8e                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800446:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044a:	79 86                	jns    8003d2 <vprintfmt+0x75>
  80044c:	e9 74 ff ff ff       	jmp    8003c5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800451:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	89 de                	mov    %ebx,%esi
  800454:	e9 79 ff ff ff       	jmp    8003d2 <vprintfmt+0x75>
  800459:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	57                   	push   %edi
  800469:	ff 30                	pushl  (%eax)
  80046b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80046e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800474:	e9 08 ff ff ff       	jmp    800381 <vprintfmt+0x24>
  800479:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	85 c0                	test   %eax,%eax
  800489:	79 02                	jns    80048d <vprintfmt+0x130>
  80048b:	f7 d8                	neg    %eax
  80048d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 04 85 40 25 80 00 	mov    0x802540(,%eax,4),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	75 1a                	jne    8004b9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80049f:	52                   	push   %edx
  8004a0:	68 b8 22 80 00       	push   $0x8022b8
  8004a5:	57                   	push   %edi
  8004a6:	ff 75 08             	pushl  0x8(%ebp)
  8004a9:	e8 92 fe ff ff       	call   800340 <printfmt>
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b4:	e9 c8 fe ff ff       	jmp    800381 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004b9:	50                   	push   %eax
  8004ba:	68 11 28 80 00       	push   $0x802811
  8004bf:	57                   	push   %edi
  8004c0:	ff 75 08             	pushl  0x8(%ebp)
  8004c3:	e8 78 fe ff ff       	call   800340 <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ce:	e9 ae fe ff ff       	jmp    800381 <vprintfmt+0x24>
  8004d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004d6:	89 de                	mov    %ebx,%esi
  8004d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	75 07                	jne    8004f7 <vprintfmt+0x19a>
				p = "(null)";
  8004f0:	c7 45 d0 b1 22 80 00 	movl   $0x8022b1,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004f7:	85 db                	test   %ebx,%ebx
  8004f9:	7e 42                	jle    80053d <vprintfmt+0x1e0>
  8004fb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004ff:	74 3c                	je     80053d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	51                   	push   %ecx
  800505:	ff 75 d0             	pushl  -0x30(%ebp)
  800508:	e8 6f 02 00 00       	call   80077c <strnlen>
  80050d:	29 c3                	sub    %eax,%ebx
  80050f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 db                	test   %ebx,%ebx
  800517:	7e 24                	jle    80053d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800519:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80051d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800520:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	57                   	push   %edi
  800527:	53                   	push   %ebx
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4e                   	dec    %esi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 f6                	test   %esi,%esi
  800531:	7f f0                	jg     800523 <vprintfmt+0x1c6>
  800533:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800536:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800540:	0f be 02             	movsbl (%edx),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	75 47                	jne    80058e <vprintfmt+0x231>
  800547:	eb 37                	jmp    800580 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054d:	74 16                	je     800565 <vprintfmt+0x208>
  80054f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800552:	83 fa 5e             	cmp    $0x5e,%edx
  800555:	76 0e                	jbe    800565 <vprintfmt+0x208>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	57                   	push   %edi
  80055b:	6a 3f                	push   $0x3f
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	eb 0b                	jmp    800570 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	57                   	push   %edi
  800569:	50                   	push   %eax
  80056a:	ff 55 08             	call   *0x8(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	ff 4d e4             	decl   -0x1c(%ebp)
  800573:	0f be 03             	movsbl (%ebx),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 03                	je     80057d <vprintfmt+0x220>
  80057a:	43                   	inc    %ebx
  80057b:	eb 1b                	jmp    800598 <vprintfmt+0x23b>
  80057d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800580:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800584:	7f 1e                	jg     8005a4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800589:	e9 f3 fd ff ff       	jmp    800381 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800591:	43                   	inc    %ebx
  800592:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800595:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 ad                	js     800549 <vprintfmt+0x1ec>
  80059c:	4e                   	dec    %esi
  80059d:	79 aa                	jns    800549 <vprintfmt+0x1ec>
  80059f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a2:	eb dc                	jmp    800580 <vprintfmt+0x223>
  8005a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	6a 20                	push   $0x20
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	4b                   	dec    %ebx
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f ef                	jg     8005a7 <vprintfmt+0x24a>
  8005b8:	e9 c4 fd ff ff       	jmp    800381 <vprintfmt+0x24>
  8005bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c0:	89 ca                	mov    %ecx,%edx
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 2a fd ff ff       	call   8002f4 <getint>
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	78 0a                	js     8005dc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 b0 00 00 00       	jmp    80068c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	57                   	push   %edi
  8005e0:	6a 2d                	push   $0x2d
  8005e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e5:	f7 db                	neg    %ebx
  8005e7:	83 d6 00             	adc    $0x0,%esi
  8005ea:	f7 de                	neg    %esi
  8005ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	e9 93 00 00 00       	jmp    80068c <vprintfmt+0x32f>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 b4 fc ff ff       	call   8002ba <getuint>
  800606:	89 c3                	mov    %eax,%ebx
  800608:	89 d6                	mov    %edx,%esi
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060f:	eb 7b                	jmp    80068c <vprintfmt+0x32f>
  800611:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 d6 fc ff ff       	call   8002f4 <getint>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800622:	85 d2                	test   %edx,%edx
  800624:	78 07                	js     80062d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800626:	b8 08 00 00 00       	mov    $0x8,%eax
  80062b:	eb 5f                	jmp    80068c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	6a 2d                	push   $0x2d
  800633:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800636:	f7 db                	neg    %ebx
  800638:	83 d6 00             	adc    $0x0,%esi
  80063b:	f7 de                	neg    %esi
  80063d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800640:	b8 08 00 00 00       	mov    $0x8,%eax
  800645:	eb 45                	jmp    80068c <vprintfmt+0x32f>
  800647:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	57                   	push   %edi
  80064e:	6a 30                	push   $0x30
  800650:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	57                   	push   %edi
  800657:	6a 78                	push   $0x78
  800659:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800665:	8b 18                	mov    (%eax),%ebx
  800667:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 16                	jmp    80068c <vprintfmt+0x32f>
  800676:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 37 fc ff ff       	call   8002ba <getuint>
  800683:	89 c3                	mov    %eax,%ebx
  800685:	89 d6                	mov    %edx,%esi
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800693:	52                   	push   %edx
  800694:	ff 75 e4             	pushl  -0x1c(%ebp)
  800697:	50                   	push   %eax
  800698:	56                   	push   %esi
  800699:	53                   	push   %ebx
  80069a:	89 fa                	mov    %edi,%edx
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	e8 68 fb ff ff       	call   80020c <printnum>
			break;
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006aa:	e9 d2 fc ff ff       	jmp    800381 <vprintfmt+0x24>
  8006af:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	57                   	push   %edi
  8006b6:	52                   	push   %edx
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c0:	e9 bc fc ff ff       	jmp    800381 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	57                   	push   %edi
  8006c9:	6a 25                	push   $0x25
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 02                	jmp    8006d5 <vprintfmt+0x378>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006dc:	75 f5                	jne    8006d3 <vprintfmt+0x376>
  8006de:	e9 9e fc ff ff       	jmp    800381 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5f                   	pop    %edi
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 18             	sub    $0x18,%esp
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 26                	je     800732 <vsnprintf+0x47>
  80070c:	85 d2                	test   %edx,%edx
  80070e:	7e 29                	jle    800739 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800710:	ff 75 14             	pushl  0x14(%ebp)
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	68 26 03 80 00       	push   $0x800326
  80071f:	e8 39 fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 0c                	jmp    80073e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800737:	eb 05                	jmp    80073e <vsnprintf+0x53>
  800739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 93 ff ff ff       	call   8006eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    
	...

0080075c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800762:	80 3a 00             	cmpb   $0x0,(%edx)
  800765:	74 0e                	je     800775 <strlen+0x19>
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80076c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f9                	jne    80076c <strlen+0x10>
  800773:	eb 05                	jmp    80077a <strlen+0x1e>
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	85 d2                	test   %edx,%edx
  800787:	74 17                	je     8007a0 <strnlen+0x24>
  800789:	80 39 00             	cmpb   $0x0,(%ecx)
  80078c:	74 19                	je     8007a7 <strnlen+0x2b>
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800793:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	39 d0                	cmp    %edx,%eax
  800796:	74 14                	je     8007ac <strnlen+0x30>
  800798:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079c:	75 f5                	jne    800793 <strnlen+0x17>
  80079e:	eb 0c                	jmp    8007ac <strnlen+0x30>
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 05                	jmp    8007ac <strnlen+0x30>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c3:	42                   	inc    %edx
  8007c4:	84 c9                	test   %cl,%cl
  8007c6:	75 f5                	jne    8007bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 84 ff ff ff       	call   80075c <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c7 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	85 f6                	test   %esi,%esi
  8007fe:	74 15                	je     800815 <strncpy+0x27>
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800805:	8a 1a                	mov    (%edx),%bl
  800807:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 3a 01             	cmpb   $0x1,(%edx)
  80080d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	41                   	inc    %ecx
  800811:	39 ce                	cmp    %ecx,%esi
  800813:	77 f0                	ja     800805 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800825:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 f6                	test   %esi,%esi
  80082a:	74 32                	je     80085e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80082c:	83 fe 01             	cmp    $0x1,%esi
  80082f:	74 22                	je     800853 <strlcpy+0x3a>
  800831:	8a 0b                	mov    (%ebx),%cl
  800833:	84 c9                	test   %cl,%cl
  800835:	74 20                	je     800857 <strlcpy+0x3e>
  800837:	89 f8                	mov    %edi,%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80083e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	88 08                	mov    %cl,(%eax)
  800843:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800844:	39 f2                	cmp    %esi,%edx
  800846:	74 11                	je     800859 <strlcpy+0x40>
  800848:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80084c:	42                   	inc    %edx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	75 f0                	jne    800841 <strlcpy+0x28>
  800851:	eb 06                	jmp    800859 <strlcpy+0x40>
  800853:	89 f8                	mov    %edi,%eax
  800855:	eb 02                	jmp    800859 <strlcpy+0x40>
  800857:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
  80085c:	eb 02                	jmp    800860 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800860:	29 f8                	sub    %edi,%eax
}
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	8a 01                	mov    (%ecx),%al
  800872:	84 c0                	test   %al,%al
  800874:	74 10                	je     800886 <strcmp+0x1f>
  800876:	3a 02                	cmp    (%edx),%al
  800878:	75 0c                	jne    800886 <strcmp+0x1f>
		p++, q++;
  80087a:	41                   	inc    %ecx
  80087b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087c:	8a 01                	mov    (%ecx),%al
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1f>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 f4                	je     80087a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 55 08             	mov    0x8(%ebp),%edx
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 1b                	je     8008bc <strncmp+0x2c>
  8008a1:	8a 1a                	mov    (%edx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	74 24                	je     8008cb <strncmp+0x3b>
  8008a7:	3a 19                	cmp    (%ecx),%bl
  8008a9:	75 20                	jne    8008cb <strncmp+0x3b>
  8008ab:	48                   	dec    %eax
  8008ac:	74 15                	je     8008c3 <strncmp+0x33>
		n--, p++, q++;
  8008ae:	42                   	inc    %edx
  8008af:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b0:	8a 1a                	mov    (%edx),%bl
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	74 15                	je     8008cb <strncmp+0x3b>
  8008b6:	3a 19                	cmp    (%ecx),%bl
  8008b8:	74 f1                	je     8008ab <strncmp+0x1b>
  8008ba:	eb 0f                	jmp    8008cb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 05                	jmp    8008c8 <strncmp+0x38>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 02             	movzbl (%edx),%eax
  8008ce:	0f b6 11             	movzbl (%ecx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
  8008d3:	eb f3                	jmp    8008c8 <strncmp+0x38>

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008de:	8a 10                	mov    (%eax),%dl
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	74 18                	je     8008fc <strchr+0x27>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	75 06                	jne    8008ee <strchr+0x19>
  8008e8:	eb 17                	jmp    800901 <strchr+0x2c>
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 13                	je     800901 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	8a 10                	mov    (%eax),%dl
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f5                	jne    8008ea <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 05                	jmp    800901 <strchr+0x2c>
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090c:	8a 10                	mov    (%eax),%dl
  80090e:	84 d2                	test   %dl,%dl
  800910:	74 11                	je     800923 <strfind+0x20>
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	75 06                	jne    80091c <strfind+0x19>
  800916:	eb 0b                	jmp    800923 <strfind+0x20>
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 07                	je     800923 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800934:	85 c9                	test   %ecx,%ecx
  800936:	74 30                	je     800968 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800938:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093e:	75 25                	jne    800965 <memset+0x40>
  800940:	f6 c1 03             	test   $0x3,%cl
  800943:	75 20                	jne    800965 <memset+0x40>
		c &= 0xFF;
  800945:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 08             	shl    $0x8,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 18             	shl    $0x18,%esi
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 10             	shl    $0x10,%eax
  800957:	09 f0                	or     %esi,%eax
  800959:	09 d0                	or     %edx,%eax
  80095b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800960:	fc                   	cld    
  800961:	f3 ab                	rep stos %eax,%es:(%edi)
  800963:	eb 03                	jmp    800968 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097d:	39 c6                	cmp    %eax,%esi
  80097f:	73 34                	jae    8009b5 <memmove+0x46>
  800981:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800984:	39 d0                	cmp    %edx,%eax
  800986:	73 2d                	jae    8009b5 <memmove+0x46>
		s += n;
		d += n;
  800988:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	f6 c2 03             	test   $0x3,%dl
  80098e:	75 1b                	jne    8009ab <memmove+0x3c>
  800990:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800996:	75 13                	jne    8009ab <memmove+0x3c>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0e                	jne    8009ab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099d:	83 ef 04             	sub    $0x4,%edi
  8009a0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a6:	fd                   	std    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 07                	jmp    8009b2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ab:	4f                   	dec    %edi
  8009ac:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009af:	fd                   	std    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b2:	fc                   	cld    
  8009b3:	eb 20                	jmp    8009d5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bb:	75 13                	jne    8009d0 <memmove+0x61>
  8009bd:	a8 03                	test   $0x3,%al
  8009bf:	75 0f                	jne    8009d0 <memmove+0x61>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009dc:	ff 75 10             	pushl  0x10(%ebp)
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	ff 75 08             	pushl  0x8(%ebp)
  8009e5:	e8 85 ff ff ff       	call   80096f <memmove>
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	85 ff                	test   %edi,%edi
  8009fd:	74 32                	je     800a31 <memcmp+0x45>
		if (*s1 != *s2)
  8009ff:	8a 03                	mov    (%ebx),%al
  800a01:	8a 0e                	mov    (%esi),%cl
  800a03:	38 c8                	cmp    %cl,%al
  800a05:	74 19                	je     800a20 <memcmp+0x34>
  800a07:	eb 0d                	jmp    800a16 <memcmp+0x2a>
  800a09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a0d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a11:	42                   	inc    %edx
  800a12:	38 c8                	cmp    %cl,%al
  800a14:	74 10                	je     800a26 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 c9             	movzbl %cl,%ecx
  800a1c:	29 c8                	sub    %ecx,%eax
  800a1e:	eb 16                	jmp    800a36 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	4f                   	dec    %edi
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	39 fa                	cmp    %edi,%edx
  800a28:	75 df                	jne    800a09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 05                	jmp    800a36 <memcmp+0x4a>
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a46:	39 d0                	cmp    %edx,%eax
  800a48:	73 12                	jae    800a5c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a4d:	38 08                	cmp    %cl,(%eax)
  800a4f:	75 06                	jne    800a57 <memfind+0x1c>
  800a51:	eb 09                	jmp    800a5c <memfind+0x21>
  800a53:	38 08                	cmp    %cl,(%eax)
  800a55:	74 05                	je     800a5c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a57:	40                   	inc    %eax
  800a58:	39 c2                	cmp    %eax,%edx
  800a5a:	77 f7                	ja     800a53 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 55 08             	mov    0x8(%ebp),%edx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 01                	jmp    800a6d <strtol+0xf>
		s++;
  800a6c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	8a 02                	mov    (%edx),%al
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f9                	je     800a6c <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f5                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 08                	jne    800a83 <strtol+0x25>
		s++;
  800a7b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a81:	eb 13                	jmp    800a96 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a83:	3c 2d                	cmp    $0x2d,%al
  800a85:	75 0a                	jne    800a91 <strtol+0x33>
		s++, neg = 1;
  800a87:	8d 52 01             	lea    0x1(%edx),%edx
  800a8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8f:	eb 05                	jmp    800a96 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	85 db                	test   %ebx,%ebx
  800a98:	74 05                	je     800a9f <strtol+0x41>
  800a9a:	83 fb 10             	cmp    $0x10,%ebx
  800a9d:	75 28                	jne    800ac7 <strtol+0x69>
  800a9f:	8a 02                	mov    (%edx),%al
  800aa1:	3c 30                	cmp    $0x30,%al
  800aa3:	75 10                	jne    800ab5 <strtol+0x57>
  800aa5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa9:	75 0a                	jne    800ab5 <strtol+0x57>
		s += 2, base = 16;
  800aab:	83 c2 02             	add    $0x2,%edx
  800aae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab3:	eb 12                	jmp    800ac7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab5:	85 db                	test   %ebx,%ebx
  800ab7:	75 0e                	jne    800ac7 <strtol+0x69>
  800ab9:	3c 30                	cmp    $0x30,%al
  800abb:	75 05                	jne    800ac2 <strtol+0x64>
		s++, base = 8;
  800abd:	42                   	inc    %edx
  800abe:	b3 08                	mov    $0x8,%bl
  800ac0:	eb 05                	jmp    800ac7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ace:	8a 0a                	mov    (%edx),%cl
  800ad0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad3:	80 fb 09             	cmp    $0x9,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0x82>
			dig = *s - '0';
  800ad8:	0f be c9             	movsbl %cl,%ecx
  800adb:	83 e9 30             	sub    $0x30,%ecx
  800ade:	eb 1e                	jmp    800afe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae8:	0f be c9             	movsbl %cl,%ecx
  800aeb:	83 e9 57             	sub    $0x57,%ecx
  800aee:	eb 0e                	jmp    800afe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 13                	ja     800b0b <strtol+0xad>
			dig = *s - 'A' + 10;
  800af8:	0f be c9             	movsbl %cl,%ecx
  800afb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afe:	39 f1                	cmp    %esi,%ecx
  800b00:	7d 0d                	jge    800b0f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b02:	42                   	inc    %edx
  800b03:	0f af c6             	imul   %esi,%eax
  800b06:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b09:	eb c3                	jmp    800ace <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	89 c1                	mov    %eax,%ecx
  800b0d:	eb 02                	jmp    800b11 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b15:	74 05                	je     800b1c <strtol+0xbe>
		*endptr = (char *) s;
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b1c:	85 ff                	test   %edi,%edi
  800b1e:	74 04                	je     800b24 <strtol+0xc6>
  800b20:	89 c8                	mov    %ecx,%eax
  800b22:	f7 d8                	neg    %eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    
  800b29:	00 00                	add    %al,(%eax)
	...

00800b2c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 1c             	sub    $0x1c,%esp
  800b35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b38:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b3b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b40:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b49:	cd 30                	int    $0x30
  800b4b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b51:	74 1c                	je     800b6f <syscall+0x43>
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7e 18                	jle    800b6f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b5e:	68 9f 25 80 00       	push   $0x80259f
  800b63:	6a 42                	push   $0x42
  800b65:	68 bc 25 80 00       	push   $0x8025bc
  800b6a:	e8 51 13 00 00       	call   801ec0 <_panic>

	return ret;
}
  800b6f:	89 d0                	mov    %edx,%eax
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	ff 75 0c             	pushl  0xc(%ebp)
  800b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	e8 92 ff ff ff       	call   800b2c <syscall>
  800b9a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbc:	e8 6b ff ff ff       	call   800b2c <syscall>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	e8 49 ff ff ff       	call   800b2c <syscall>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 02 00 00 00       	mov    $0x2,%eax
  800c02:	e8 25 ff ff ff       	call   800b2c <syscall>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <sys_yield>:

void
sys_yield(void)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c26:	e8 01 ff ff ff       	call   800b2c <syscall>
  800c2b:	83 c4 10             	add    $0x10,%esp
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	e8 da fe ff ff       	call   800b2c <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5a:	ff 75 18             	pushl  0x18(%ebp)
  800c5d:	ff 75 14             	pushl  0x14(%ebp)
  800c60:	ff 75 10             	pushl  0x10(%ebp)
  800c63:	ff 75 0c             	pushl  0xc(%ebp)
  800c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c69:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c73:	e8 b4 fe ff ff       	call   800b2c <syscall>
}
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c80:	6a 00                	push   $0x0
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	ff 75 0c             	pushl  0xc(%ebp)
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c91:	b8 06 00 00 00       	mov    $0x6,%eax
  800c96:	e8 91 fe ff ff       	call   800b2c <syscall>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb9:	e8 6e fe ff ff       	call   800b2c <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdc:	e8 4b fe ff ff       	call   800b2c <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cff:	e8 28 fe ff ff       	call   800b2c <syscall>
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d0c:	6a 00                	push   $0x0
  800d0e:	ff 75 14             	pushl  0x14(%ebp)
  800d11:	ff 75 10             	pushl  0x10(%ebp)
  800d14:	ff 75 0c             	pushl  0xc(%ebp)
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d24:	e8 03 fe ff ff       	call   800b2c <syscall>
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d46:	e8 e1 fd ff ff       	call   800b2c <syscall>
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d53:	6a 00                	push   $0x0
  800d55:	6a 00                	push   $0x0
  800d57:	6a 00                	push   $0x0
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
  800d5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d69:	e8 be fd ff ff       	call   800b2c <syscall>
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d76:	6a 00                	push   $0x0
  800d78:	ff 75 14             	pushl  0x14(%ebp)
  800d7b:	ff 75 10             	pushl  0x10(%ebp)
  800d7e:	ff 75 0c             	pushl  0xc(%ebp)
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d8e:	e8 99 fd ff ff       	call   800b2c <syscall>
} 
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	6a 00                	push   $0x0
  800da1:	6a 00                	push   $0x0
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 11 00 00 00       	mov    $0x11,%eax
  800db0:	e8 77 fd ff ff       	call   800b2c <syscall>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	6a 00                	push   $0x0
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcf:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd4:	e8 53 fd ff ff       	call   800b2c <syscall>
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    
	...

00800ddc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de6:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800de8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dec:	75 14                	jne    800e02 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 cc 25 80 00       	push   $0x8025cc
  800df6:	6a 20                	push   $0x20
  800df8:	68 10 27 80 00       	push   $0x802710
  800dfd:	e8 be 10 00 00       	call   801ec0 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e02:	89 d8                	mov    %ebx,%eax
  800e04:	c1 e8 16             	shr    $0x16,%eax
  800e07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e0e:	a8 01                	test   $0x1,%al
  800e10:	74 11                	je     800e23 <pgfault+0x47>
  800e12:	89 d8                	mov    %ebx,%eax
  800e14:	c1 e8 0c             	shr    $0xc,%eax
  800e17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1e:	f6 c4 08             	test   $0x8,%ah
  800e21:	75 14                	jne    800e37 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	68 f0 25 80 00       	push   $0x8025f0
  800e2b:	6a 24                	push   $0x24
  800e2d:	68 10 27 80 00       	push   $0x802710
  800e32:	e8 89 10 00 00       	call   801ec0 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	6a 07                	push   $0x7
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 e8 fd ff ff       	call   800c30 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0x85>
  800e4f:	50                   	push   %eax
  800e50:	68 14 26 80 00       	push   $0x802614
  800e55:	6a 32                	push   $0x32
  800e57:	68 10 27 80 00       	push   $0x802710
  800e5c:	e8 5f 10 00 00       	call   801ec0 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 00 10 00 00       	push   $0x1000
  800e6f:	53                   	push   %ebx
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	e8 5f fb ff ff       	call   8009d9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e7a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e81:	53                   	push   %ebx
  800e82:	6a 00                	push   $0x0
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 c4 fd ff ff       	call   800c54 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e90:	83 c4 20             	add    $0x20,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 12                	jns    800ea9 <pgfault+0xcd>
  800e97:	50                   	push   %eax
  800e98:	68 38 26 80 00       	push   $0x802638
  800e9d:	6a 3a                	push   $0x3a
  800e9f:	68 10 27 80 00       	push   $0x802710
  800ea4:	e8 17 10 00 00       	call   801ec0 <_panic>

	return;
}
  800ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800eb7:	68 dc 0d 80 00       	push   $0x800ddc
  800ebc:	e8 47 10 00 00       	call   801f08 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ec1:	ba 07 00 00 00       	mov    $0x7,%edx
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	cd 30                	int    $0x30
  800eca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ecd:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 12                	jns    800ee8 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800ed6:	50                   	push   %eax
  800ed7:	68 1b 27 80 00       	push   $0x80271b
  800edc:	6a 7f                	push   $0x7f
  800ede:	68 10 27 80 00       	push   $0x802710
  800ee3:	e8 d8 0f 00 00       	call   801ec0 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ee8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eec:	75 20                	jne    800f0e <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800eee:	e8 f2 fc ff ff       	call   800be5 <sys_getenvid>
  800ef3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef8:	89 c2                	mov    %eax,%edx
  800efa:	c1 e2 07             	shl    $0x7,%edx
  800efd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f04:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800f09:	e9 be 01 00 00       	jmp    8010cc <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f0e:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f13:	89 d8                	mov    %ebx,%eax
  800f15:	c1 e8 16             	shr    $0x16,%eax
  800f18:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1f:	a8 01                	test   $0x1,%al
  800f21:	0f 84 10 01 00 00    	je     801037 <fork+0x189>
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	0f 84 fb 00 00 00    	je     801037 <fork+0x189>
  800f3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f43:	f6 c2 04             	test   $0x4,%dl
  800f46:	0f 84 eb 00 00 00    	je     801037 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f4c:	89 c6                	mov    %eax,%esi
  800f4e:	c1 e6 0c             	shl    $0xc,%esi
  800f51:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f57:	0f 84 da 00 00 00    	je     801037 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f64:	f6 c6 04             	test   $0x4,%dh
  800f67:	74 37                	je     800fa0 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	25 07 0e 00 00       	and    $0xe07,%eax
  800f78:	50                   	push   %eax
  800f79:	56                   	push   %esi
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 d1 fc ff ff       	call   800c54 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	0f 89 a9 00 00 00    	jns    801037 <fork+0x189>
  800f8e:	50                   	push   %eax
  800f8f:	68 5c 26 80 00       	push   $0x80265c
  800f94:	6a 54                	push   $0x54
  800f96:	68 10 27 80 00       	push   $0x802710
  800f9b:	e8 20 0f 00 00       	call   801ec0 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fa0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa7:	f6 c2 02             	test   $0x2,%dl
  800faa:	75 0c                	jne    800fb8 <fork+0x10a>
  800fac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb3:	f6 c4 08             	test   $0x8,%ah
  800fb6:	74 57                	je     80100f <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	68 05 08 00 00       	push   $0x805
  800fc0:	56                   	push   %esi
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 8a fc ff ff       	call   800c54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 12                	jns    800fe3 <fork+0x135>
  800fd1:	50                   	push   %eax
  800fd2:	68 5c 26 80 00       	push   $0x80265c
  800fd7:	6a 59                	push   $0x59
  800fd9:	68 10 27 80 00       	push   $0x802710
  800fde:	e8 dd 0e 00 00       	call   801ec0 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	68 05 08 00 00       	push   $0x805
  800feb:	56                   	push   %esi
  800fec:	6a 00                	push   $0x0
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 5e fc ff ff       	call   800c54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ff6:	83 c4 20             	add    $0x20,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 3a                	jns    801037 <fork+0x189>
  800ffd:	50                   	push   %eax
  800ffe:	68 5c 26 80 00       	push   $0x80265c
  801003:	6a 5c                	push   $0x5c
  801005:	68 10 27 80 00       	push   $0x802710
  80100a:	e8 b1 0e 00 00       	call   801ec0 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	6a 05                	push   $0x5
  801014:	56                   	push   %esi
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 36 fc ff ff       	call   800c54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	79 12                	jns    801037 <fork+0x189>
  801025:	50                   	push   %eax
  801026:	68 5c 26 80 00       	push   $0x80265c
  80102b:	6a 60                	push   $0x60
  80102d:	68 10 27 80 00       	push   $0x802710
  801032:	e8 89 0e 00 00       	call   801ec0 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801037:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801043:	0f 85 ca fe ff ff    	jne    800f13 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	6a 07                	push   $0x7
  80104e:	68 00 f0 bf ee       	push   $0xeebff000
  801053:	ff 75 e4             	pushl  -0x1c(%ebp)
  801056:	e8 d5 fb ff ff       	call   800c30 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	79 15                	jns    801077 <fork+0x1c9>
  801062:	50                   	push   %eax
  801063:	68 80 26 80 00       	push   $0x802680
  801068:	68 94 00 00 00       	push   $0x94
  80106d:	68 10 27 80 00       	push   $0x802710
  801072:	e8 49 0e 00 00       	call   801ec0 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	68 74 1f 80 00       	push   $0x801f74
  80107f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801082:	e8 5c fc ff ff       	call   800ce3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	79 15                	jns    8010a3 <fork+0x1f5>
  80108e:	50                   	push   %eax
  80108f:	68 b8 26 80 00       	push   $0x8026b8
  801094:	68 99 00 00 00       	push   $0x99
  801099:	68 10 27 80 00       	push   $0x802710
  80109e:	e8 1d 0e 00 00       	call   801ec0 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	6a 02                	push   $0x2
  8010a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ab:	e8 ed fb ff ff       	call   800c9d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 15                	jns    8010cc <fork+0x21e>
  8010b7:	50                   	push   %eax
  8010b8:	68 dc 26 80 00       	push   $0x8026dc
  8010bd:	68 a4 00 00 00       	push   $0xa4
  8010c2:	68 10 27 80 00       	push   $0x802710
  8010c7:	e8 f4 0d 00 00       	call   801ec0 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010dd:	68 38 27 80 00       	push   $0x802738
  8010e2:	68 b1 00 00 00       	push   $0xb1
  8010e7:	68 10 27 80 00       	push   $0x802710
  8010ec:	e8 cf 0d 00 00       	call   801ec0 <_panic>
  8010f1:	00 00                	add    %al,(%eax)
	...

008010f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	56                   	push   %esi
  8010f8:	53                   	push   %ebx
  8010f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801102:	85 c0                	test   %eax,%eax
  801104:	74 0e                	je     801114 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	50                   	push   %eax
  80110a:	e8 1c fc ff ff       	call   800d2b <sys_ipc_recv>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	eb 10                	jmp    801124 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	68 00 00 c0 ee       	push   $0xeec00000
  80111c:	e8 0a fc ff ff       	call   800d2b <sys_ipc_recv>
  801121:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801124:	85 c0                	test   %eax,%eax
  801126:	75 26                	jne    80114e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801128:	85 f6                	test   %esi,%esi
  80112a:	74 0a                	je     801136 <ipc_recv+0x42>
  80112c:	a1 08 40 80 00       	mov    0x804008,%eax
  801131:	8b 40 74             	mov    0x74(%eax),%eax
  801134:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801136:	85 db                	test   %ebx,%ebx
  801138:	74 0a                	je     801144 <ipc_recv+0x50>
  80113a:	a1 08 40 80 00       	mov    0x804008,%eax
  80113f:	8b 40 78             	mov    0x78(%eax),%eax
  801142:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801144:	a1 08 40 80 00       	mov    0x804008,%eax
  801149:	8b 40 70             	mov    0x70(%eax),%eax
  80114c:	eb 14                	jmp    801162 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80114e:	85 f6                	test   %esi,%esi
  801150:	74 06                	je     801158 <ipc_recv+0x64>
  801152:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801158:	85 db                	test   %ebx,%ebx
  80115a:	74 06                	je     801162 <ipc_recv+0x6e>
  80115c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801162:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801175:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801178:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80117b:	85 db                	test   %ebx,%ebx
  80117d:	75 25                	jne    8011a4 <ipc_send+0x3b>
  80117f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801184:	eb 1e                	jmp    8011a4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801186:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801189:	75 07                	jne    801192 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80118b:	e8 79 fa ff ff       	call   800c09 <sys_yield>
  801190:	eb 12                	jmp    8011a4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801192:	50                   	push   %eax
  801193:	68 4e 27 80 00       	push   $0x80274e
  801198:	6a 43                	push   $0x43
  80119a:	68 61 27 80 00       	push   $0x802761
  80119f:	e8 1c 0d 00 00       	call   801ec0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	57                   	push   %edi
  8011a7:	ff 75 08             	pushl  0x8(%ebp)
  8011aa:	e8 57 fb ff ff       	call   800d06 <sys_ipc_try_send>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	75 d0                	jne    801186 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8011b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011c4:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8011ca:	74 1a                	je     8011e6 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011cc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 e2 07             	shl    $0x7,%edx
  8011d6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8011dd:	8b 52 50             	mov    0x50(%edx),%edx
  8011e0:	39 ca                	cmp    %ecx,%edx
  8011e2:	75 18                	jne    8011fc <ipc_find_env+0x3e>
  8011e4:	eb 05                	jmp    8011eb <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	c1 e2 07             	shl    $0x7,%edx
  8011f0:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8011f7:	8b 40 40             	mov    0x40(%eax),%eax
  8011fa:	eb 0c                	jmp    801208 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011fc:	40                   	inc    %eax
  8011fd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801202:	75 cd                	jne    8011d1 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801204:	66 b8 00 00          	mov    $0x0,%ax
}
  801208:	c9                   	leave  
  801209:	c3                   	ret    
	...

0080120c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
  801212:	05 00 00 00 30       	add    $0x30000000,%eax
  801217:	c1 e8 0c             	shr    $0xc,%eax
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80121f:	ff 75 08             	pushl  0x8(%ebp)
  801222:	e8 e5 ff ff ff       	call   80120c <fd2num>
  801227:	83 c4 04             	add    $0x4,%esp
  80122a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80122f:	c1 e0 0c             	shl    $0xc,%eax
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	53                   	push   %ebx
  801238:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80123b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801240:	a8 01                	test   $0x1,%al
  801242:	74 34                	je     801278 <fd_alloc+0x44>
  801244:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801249:	a8 01                	test   $0x1,%al
  80124b:	74 32                	je     80127f <fd_alloc+0x4b>
  80124d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801252:	89 c1                	mov    %eax,%ecx
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 16             	shr    $0x16,%edx
  801259:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801260:	f6 c2 01             	test   $0x1,%dl
  801263:	74 1f                	je     801284 <fd_alloc+0x50>
  801265:	89 c2                	mov    %eax,%edx
  801267:	c1 ea 0c             	shr    $0xc,%edx
  80126a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801271:	f6 c2 01             	test   $0x1,%dl
  801274:	75 17                	jne    80128d <fd_alloc+0x59>
  801276:	eb 0c                	jmp    801284 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801278:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80127d:	eb 05                	jmp    801284 <fd_alloc+0x50>
  80127f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801284:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
  80128b:	eb 17                	jmp    8012a4 <fd_alloc+0x70>
  80128d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801292:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801297:	75 b9                	jne    801252 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801299:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80129f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a4:	5b                   	pop    %ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ad:	83 f8 1f             	cmp    $0x1f,%eax
  8012b0:	77 36                	ja     8012e8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012b7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	c1 ea 16             	shr    $0x16,%edx
  8012bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 24                	je     8012ef <fd_lookup+0x48>
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	c1 ea 0c             	shr    $0xc,%edx
  8012d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d7:	f6 c2 01             	test   $0x1,%dl
  8012da:	74 1a                	je     8012f6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e6:	eb 13                	jmp    8012fb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ed:	eb 0c                	jmp    8012fb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f4:	eb 05                	jmp    8012fb <fd_lookup+0x54>
  8012f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 04             	sub    $0x4,%esp
  801304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80130a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801310:	74 0d                	je     80131f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
  801317:	eb 14                	jmp    80132d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801319:	39 0a                	cmp    %ecx,(%edx)
  80131b:	75 10                	jne    80132d <dev_lookup+0x30>
  80131d:	eb 05                	jmp    801324 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801324:	89 13                	mov    %edx,(%ebx)
			return 0;
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	eb 31                	jmp    80135e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132d:	40                   	inc    %eax
  80132e:	8b 14 85 e8 27 80 00 	mov    0x8027e8(,%eax,4),%edx
  801335:	85 d2                	test   %edx,%edx
  801337:	75 e0                	jne    801319 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801339:	a1 08 40 80 00       	mov    0x804008,%eax
  80133e:	8b 40 48             	mov    0x48(%eax),%eax
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	51                   	push   %ecx
  801345:	50                   	push   %eax
  801346:	68 6c 27 80 00       	push   $0x80276c
  80134b:	e8 a8 ee ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  801350:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	83 ec 20             	sub    $0x20,%esp
  80136b:	8b 75 08             	mov    0x8(%ebp),%esi
  80136e:	8a 45 0c             	mov    0xc(%ebp),%al
  801371:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801374:	56                   	push   %esi
  801375:	e8 92 fe ff ff       	call   80120c <fd2num>
  80137a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80137d:	89 14 24             	mov    %edx,(%esp)
  801380:	50                   	push   %eax
  801381:	e8 21 ff ff ff       	call   8012a7 <fd_lookup>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 05                	js     801394 <fd_close+0x31>
	    || fd != fd2)
  80138f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801392:	74 0d                	je     8013a1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801394:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801398:	75 48                	jne    8013e2 <fd_close+0x7f>
  80139a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139f:	eb 41                	jmp    8013e2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a7:	50                   	push   %eax
  8013a8:	ff 36                	pushl  (%esi)
  8013aa:	e8 4e ff ff ff       	call   8012fd <dev_lookup>
  8013af:	89 c3                	mov    %eax,%ebx
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 1c                	js     8013d4 <fd_close+0x71>
		if (dev->dev_close)
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	8b 40 10             	mov    0x10(%eax),%eax
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	74 0d                	je     8013cf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8013c2:	83 ec 0c             	sub    $0xc,%esp
  8013c5:	56                   	push   %esi
  8013c6:	ff d0                	call   *%eax
  8013c8:	89 c3                	mov    %eax,%ebx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	eb 05                	jmp    8013d4 <fd_close+0x71>
		else
			r = 0;
  8013cf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	56                   	push   %esi
  8013d8:	6a 00                	push   $0x0
  8013da:	e8 9b f8 ff ff       	call   800c7a <sys_page_unmap>
	return r;
  8013df:	83 c4 10             	add    $0x10,%esp
}
  8013e2:	89 d8                	mov    %ebx,%eax
  8013e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f4:	50                   	push   %eax
  8013f5:	ff 75 08             	pushl  0x8(%ebp)
  8013f8:	e8 aa fe ff ff       	call   8012a7 <fd_lookup>
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 10                	js     801414 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 01                	push   $0x1
  801409:	ff 75 f4             	pushl  -0xc(%ebp)
  80140c:	e8 52 ff ff ff       	call   801363 <fd_close>
  801411:	83 c4 10             	add    $0x10,%esp
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <close_all>:

void
close_all(void)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	53                   	push   %ebx
  801426:	e8 c0 ff ff ff       	call   8013eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142b:	43                   	inc    %ebx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	83 fb 20             	cmp    $0x20,%ebx
  801432:	75 ee                	jne    801422 <close_all+0xc>
		close(i);
}
  801434:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	57                   	push   %edi
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	83 ec 2c             	sub    $0x2c,%esp
  801442:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801445:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	ff 75 08             	pushl  0x8(%ebp)
  80144c:	e8 56 fe ff ff       	call   8012a7 <fd_lookup>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	0f 88 c0 00 00 00    	js     80151e <dup+0xe5>
		return r;
	close(newfdnum);
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	57                   	push   %edi
  801462:	e8 84 ff ff ff       	call   8013eb <close>

	newfd = INDEX2FD(newfdnum);
  801467:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80146d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801470:	83 c4 04             	add    $0x4,%esp
  801473:	ff 75 e4             	pushl  -0x1c(%ebp)
  801476:	e8 a1 fd ff ff       	call   80121c <fd2data>
  80147b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80147d:	89 34 24             	mov    %esi,(%esp)
  801480:	e8 97 fd ff ff       	call   80121c <fd2data>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	c1 e8 16             	shr    $0x16,%eax
  801490:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801497:	a8 01                	test   $0x1,%al
  801499:	74 37                	je     8014d2 <dup+0x99>
  80149b:	89 d8                	mov    %ebx,%eax
  80149d:	c1 e8 0c             	shr    $0xc,%eax
  8014a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	74 26                	je     8014d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014bf:	6a 00                	push   $0x0
  8014c1:	53                   	push   %ebx
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 8b f7 ff ff       	call   800c54 <sys_page_map>
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	83 c4 20             	add    $0x20,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 2d                	js     8014ff <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	c1 ea 0c             	shr    $0xc,%edx
  8014da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014ea:	52                   	push   %edx
  8014eb:	56                   	push   %esi
  8014ec:	6a 00                	push   $0x0
  8014ee:	50                   	push   %eax
  8014ef:	6a 00                	push   $0x0
  8014f1:	e8 5e f7 ff ff       	call   800c54 <sys_page_map>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 20             	add    $0x20,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	79 1d                	jns    80151c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	56                   	push   %esi
  801503:	6a 00                	push   $0x0
  801505:	e8 70 f7 ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801510:	6a 00                	push   $0x0
  801512:	e8 63 f7 ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	eb 02                	jmp    80151e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80151c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801532:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	53                   	push   %ebx
  801537:	e8 6b fd ff ff       	call   8012a7 <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 67                	js     8015aa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 a9 fd ff ff       	call   8012fd <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 4f                	js     8015aa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155e:	8b 50 08             	mov    0x8(%eax),%edx
  801561:	83 e2 03             	and    $0x3,%edx
  801564:	83 fa 01             	cmp    $0x1,%edx
  801567:	75 21                	jne    80158a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801569:	a1 08 40 80 00       	mov    0x804008,%eax
  80156e:	8b 40 48             	mov    0x48(%eax),%eax
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	53                   	push   %ebx
  801575:	50                   	push   %eax
  801576:	68 ad 27 80 00       	push   $0x8027ad
  80157b:	e8 78 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801588:	eb 20                	jmp    8015aa <read+0x82>
	}
	if (!dev->dev_read)
  80158a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158d:	8b 52 08             	mov    0x8(%edx),%edx
  801590:	85 d2                	test   %edx,%edx
  801592:	74 11                	je     8015a5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	ff 75 10             	pushl  0x10(%ebp)
  80159a:	ff 75 0c             	pushl  0xc(%ebp)
  80159d:	50                   	push   %eax
  80159e:	ff d2                	call   *%edx
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	eb 05                	jmp    8015aa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015be:	85 f6                	test   %esi,%esi
  8015c0:	74 31                	je     8015f3 <readn+0x44>
  8015c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	89 f2                	mov    %esi,%edx
  8015d1:	29 c2                	sub    %eax,%edx
  8015d3:	52                   	push   %edx
  8015d4:	03 45 0c             	add    0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	57                   	push   %edi
  8015d9:	e8 4a ff ff ff       	call   801528 <read>
		if (m < 0)
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 17                	js     8015fc <readn+0x4d>
			return m;
		if (m == 0)
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	74 11                	je     8015fa <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e9:	01 c3                	add    %eax,%ebx
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	39 f3                	cmp    %esi,%ebx
  8015ef:	72 db                	jb     8015cc <readn+0x1d>
  8015f1:	eb 09                	jmp    8015fc <readn+0x4d>
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f8:	eb 02                	jmp    8015fc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015fa:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	53                   	push   %ebx
  801608:	83 ec 14             	sub    $0x14,%esp
  80160b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	53                   	push   %ebx
  801613:	e8 8f fc ff ff       	call   8012a7 <fd_lookup>
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 62                	js     801681 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	ff 30                	pushl  (%eax)
  80162b:	e8 cd fc ff ff       	call   8012fd <dev_lookup>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 4a                	js     801681 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163e:	75 21                	jne    801661 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801640:	a1 08 40 80 00       	mov    0x804008,%eax
  801645:	8b 40 48             	mov    0x48(%eax),%eax
  801648:	83 ec 04             	sub    $0x4,%esp
  80164b:	53                   	push   %ebx
  80164c:	50                   	push   %eax
  80164d:	68 c9 27 80 00       	push   $0x8027c9
  801652:	e8 a1 eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165f:	eb 20                	jmp    801681 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801664:	8b 52 0c             	mov    0xc(%edx),%edx
  801667:	85 d2                	test   %edx,%edx
  801669:	74 11                	je     80167c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	50                   	push   %eax
  801675:	ff d2                	call   *%edx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <seek>:

int
seek(int fdnum, off_t offset)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 0f fc ff ff       	call   8012a7 <fd_lookup>
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 0e                	js     8016ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80169f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 14             	sub    $0x14,%esp
  8016b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bc:	50                   	push   %eax
  8016bd:	53                   	push   %ebx
  8016be:	e8 e4 fb ff ff       	call   8012a7 <fd_lookup>
  8016c3:	83 c4 08             	add    $0x8,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 5f                	js     801729 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	ff 30                	pushl  (%eax)
  8016d6:	e8 22 fc ff ff       	call   8012fd <dev_lookup>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 47                	js     801729 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e9:	75 21                	jne    80170c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016eb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016f0:	8b 40 48             	mov    0x48(%eax),%eax
  8016f3:	83 ec 04             	sub    $0x4,%esp
  8016f6:	53                   	push   %ebx
  8016f7:	50                   	push   %eax
  8016f8:	68 8c 27 80 00       	push   $0x80278c
  8016fd:	e8 f6 ea ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170a:	eb 1d                	jmp    801729 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80170c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170f:	8b 52 18             	mov    0x18(%edx),%edx
  801712:	85 d2                	test   %edx,%edx
  801714:	74 0e                	je     801724 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	ff 75 0c             	pushl  0xc(%ebp)
  80171c:	50                   	push   %eax
  80171d:	ff d2                	call   *%edx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 05                	jmp    801729 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801724:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 14             	sub    $0x14,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 63 fb ff ff       	call   8012a7 <fd_lookup>
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 52                	js     80179d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	ff 30                	pushl  (%eax)
  801757:	e8 a1 fb ff ff       	call   8012fd <dev_lookup>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 3a                	js     80179d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801766:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176a:	74 2c                	je     801798 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801776:	00 00 00 
	stat->st_isdir = 0;
  801779:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801780:	00 00 00 
	stat->st_dev = dev;
  801783:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	53                   	push   %ebx
  80178d:	ff 75 f0             	pushl  -0x10(%ebp)
  801790:	ff 50 14             	call   *0x14(%eax)
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	eb 05                	jmp    80179d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801798:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 78 01 00 00       	call   80192c <open>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 1b                	js     8017d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	50                   	push   %eax
  8017c4:	e8 65 ff ff ff       	call   80172e <fstat>
  8017c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8017cb:	89 1c 24             	mov    %ebx,(%esp)
  8017ce:	e8 18 fc ff ff       	call   8013eb <close>
	return r;
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	89 f3                	mov    %esi,%ebx
}
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    
  8017e1:	00 00                	add    %al,(%eax)
	...

008017e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f4:	75 12                	jne    801808 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	6a 01                	push   $0x1
  8017fb:	e8 be f9 ff ff       	call   8011be <ipc_find_env>
  801800:	a3 00 40 80 00       	mov    %eax,0x804000
  801805:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801808:	6a 07                	push   $0x7
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	53                   	push   %ebx
  801810:	ff 35 00 40 80 00    	pushl  0x804000
  801816:	e8 4e f9 ff ff       	call   801169 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80181b:	83 c4 0c             	add    $0xc,%esp
  80181e:	6a 00                	push   $0x0
  801820:	56                   	push   %esi
  801821:	6a 00                	push   $0x0
  801823:	e8 cc f8 ff ff       	call   8010f4 <ipc_recv>
}
  801828:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 04             	sub    $0x4,%esp
  801836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801844:	ba 00 00 00 00       	mov    $0x0,%edx
  801849:	b8 05 00 00 00       	mov    $0x5,%eax
  80184e:	e8 91 ff ff ff       	call   8017e4 <fsipc>
  801853:	85 c0                	test   %eax,%eax
  801855:	78 2c                	js     801883 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	68 00 50 80 00       	push   $0x805000
  80185f:	53                   	push   %ebx
  801860:	e8 49 ef ff ff       	call   8007ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801865:	a1 80 50 80 00       	mov    0x805080,%eax
  80186a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801870:	a1 84 50 80 00       	mov    0x805084,%eax
  801875:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	8b 40 0c             	mov    0xc(%eax),%eax
  801894:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a3:	e8 3c ff ff ff       	call   8017e4 <fsipc>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
  8018af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cd:	e8 12 ff ff ff       	call   8017e4 <fsipc>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 4b                	js     801923 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d8:	39 c6                	cmp    %eax,%esi
  8018da:	73 16                	jae    8018f2 <devfile_read+0x48>
  8018dc:	68 f8 27 80 00       	push   $0x8027f8
  8018e1:	68 ff 27 80 00       	push   $0x8027ff
  8018e6:	6a 7d                	push   $0x7d
  8018e8:	68 14 28 80 00       	push   $0x802814
  8018ed:	e8 ce 05 00 00       	call   801ec0 <_panic>
	assert(r <= PGSIZE);
  8018f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f7:	7e 16                	jle    80190f <devfile_read+0x65>
  8018f9:	68 1f 28 80 00       	push   $0x80281f
  8018fe:	68 ff 27 80 00       	push   $0x8027ff
  801903:	6a 7e                	push   $0x7e
  801905:	68 14 28 80 00       	push   $0x802814
  80190a:	e8 b1 05 00 00       	call   801ec0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	50                   	push   %eax
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	ff 75 0c             	pushl  0xc(%ebp)
  80191b:	e8 4f f0 ff ff       	call   80096f <memmove>
	return r;
  801920:	83 c4 10             	add    $0x10,%esp
}
  801923:	89 d8                	mov    %ebx,%eax
  801925:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 1c             	sub    $0x1c,%esp
  801934:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801937:	56                   	push   %esi
  801938:	e8 1f ee ff ff       	call   80075c <strlen>
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801945:	7f 65                	jg     8019ac <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194d:	50                   	push   %eax
  80194e:	e8 e1 f8 ff ff       	call   801234 <fd_alloc>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 55                	js     8019b1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	56                   	push   %esi
  801960:	68 00 50 80 00       	push   $0x805000
  801965:	e8 44 ee ff ff       	call   8007ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801972:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801975:	b8 01 00 00 00       	mov    $0x1,%eax
  80197a:	e8 65 fe ff ff       	call   8017e4 <fsipc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	79 12                	jns    80199a <open+0x6e>
		fd_close(fd, 0);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	6a 00                	push   $0x0
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	e8 ce f9 ff ff       	call   801363 <fd_close>
		return r;
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	eb 17                	jmp    8019b1 <open+0x85>
	}

	return fd2num(fd);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a0:	e8 67 f8 ff ff       	call   80120c <fd2num>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	eb 05                	jmp    8019b1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ac:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b1:	89 d8                	mov    %ebx,%eax
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    
	...

008019bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 4d f8 ff ff       	call   80121c <fd2data>
  8019cf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019d1:	83 c4 08             	add    $0x8,%esp
  8019d4:	68 2b 28 80 00       	push   $0x80282b
  8019d9:	56                   	push   %esi
  8019da:	e8 cf ed ff ff       	call   8007ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019df:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e2:	2b 03                	sub    (%ebx),%eax
  8019e4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019ea:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019f1:	00 00 00 
	stat->st_dev = &devpipe;
  8019f4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019fb:	30 80 00 
	return 0;
}
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801a03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a14:	53                   	push   %ebx
  801a15:	6a 00                	push   $0x0
  801a17:	e8 5e f2 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1c:	89 1c 24             	mov    %ebx,(%esp)
  801a1f:	e8 f8 f7 ff ff       	call   80121c <fd2data>
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	50                   	push   %eax
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 4b f2 ff ff       	call   800c7a <sys_page_unmap>
}
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 1c             	sub    $0x1c,%esp
  801a3d:	89 c7                	mov    %eax,%edi
  801a3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a42:	a1 08 40 80 00       	mov    0x804008,%eax
  801a47:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	57                   	push   %edi
  801a4e:	e8 49 05 00 00       	call   801f9c <pageref>
  801a53:	89 c6                	mov    %eax,%esi
  801a55:	83 c4 04             	add    $0x4,%esp
  801a58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5b:	e8 3c 05 00 00       	call   801f9c <pageref>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	39 c6                	cmp    %eax,%esi
  801a65:	0f 94 c0             	sete   %al
  801a68:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a6b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a71:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a74:	39 cb                	cmp    %ecx,%ebx
  801a76:	75 08                	jne    801a80 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a80:	83 f8 01             	cmp    $0x1,%eax
  801a83:	75 bd                	jne    801a42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a85:	8b 42 58             	mov    0x58(%edx),%eax
  801a88:	6a 01                	push   $0x1
  801a8a:	50                   	push   %eax
  801a8b:	53                   	push   %ebx
  801a8c:	68 32 28 80 00       	push   $0x802832
  801a91:	e8 62 e7 ff ff       	call   8001f8 <cprintf>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	eb a7                	jmp    801a42 <_pipeisclosed+0xe>

00801a9b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 28             	sub    $0x28,%esp
  801aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa7:	56                   	push   %esi
  801aa8:	e8 6f f7 ff ff       	call   80121c <fd2data>
  801aad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab6:	75 4a                	jne    801b02 <devpipe_write+0x67>
  801ab8:	bf 00 00 00 00       	mov    $0x0,%edi
  801abd:	eb 56                	jmp    801b15 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801abf:	89 da                	mov    %ebx,%edx
  801ac1:	89 f0                	mov    %esi,%eax
  801ac3:	e8 6c ff ff ff       	call   801a34 <_pipeisclosed>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	75 4d                	jne    801b19 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acc:	e8 38 f1 ff ff       	call   800c09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad4:	8b 13                	mov    (%ebx),%edx
  801ad6:	83 c2 20             	add    $0x20,%edx
  801ad9:	39 d0                	cmp    %edx,%eax
  801adb:	73 e2                	jae    801abf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801add:	89 c2                	mov    %eax,%edx
  801adf:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ae5:	79 05                	jns    801aec <devpipe_write+0x51>
  801ae7:	4a                   	dec    %edx
  801ae8:	83 ca e0             	or     $0xffffffe0,%edx
  801aeb:	42                   	inc    %edx
  801aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aef:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801af2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af6:	40                   	inc    %eax
  801af7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afa:	47                   	inc    %edi
  801afb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801afe:	77 07                	ja     801b07 <devpipe_write+0x6c>
  801b00:	eb 13                	jmp    801b15 <devpipe_write+0x7a>
  801b02:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b07:	8b 43 04             	mov    0x4(%ebx),%eax
  801b0a:	8b 13                	mov    (%ebx),%edx
  801b0c:	83 c2 20             	add    $0x20,%edx
  801b0f:	39 d0                	cmp    %edx,%eax
  801b11:	73 ac                	jae    801abf <devpipe_write+0x24>
  801b13:	eb c8                	jmp    801add <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b15:	89 f8                	mov    %edi,%eax
  801b17:	eb 05                	jmp    801b1e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	57                   	push   %edi
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 18             	sub    $0x18,%esp
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b32:	57                   	push   %edi
  801b33:	e8 e4 f6 ff ff       	call   80121c <fd2data>
  801b38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b41:	75 44                	jne    801b87 <devpipe_read+0x61>
  801b43:	be 00 00 00 00       	mov    $0x0,%esi
  801b48:	eb 4f                	jmp    801b99 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	eb 54                	jmp    801ba2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4e:	89 da                	mov    %ebx,%edx
  801b50:	89 f8                	mov    %edi,%eax
  801b52:	e8 dd fe ff ff       	call   801a34 <_pipeisclosed>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 42                	jne    801b9d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5b:	e8 a9 f0 ff ff       	call   800c09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b60:	8b 03                	mov    (%ebx),%eax
  801b62:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b65:	74 e7                	je     801b4e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b67:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b6c:	79 05                	jns    801b73 <devpipe_read+0x4d>
  801b6e:	48                   	dec    %eax
  801b6f:	83 c8 e0             	or     $0xffffffe0,%eax
  801b72:	40                   	inc    %eax
  801b73:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b7d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7f:	46                   	inc    %esi
  801b80:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b83:	77 07                	ja     801b8c <devpipe_read+0x66>
  801b85:	eb 12                	jmp    801b99 <devpipe_read+0x73>
  801b87:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b8c:	8b 03                	mov    (%ebx),%eax
  801b8e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b91:	75 d4                	jne    801b67 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b93:	85 f6                	test   %esi,%esi
  801b95:	75 b3                	jne    801b4a <devpipe_read+0x24>
  801b97:	eb b5                	jmp    801b4e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b99:	89 f0                	mov    %esi,%eax
  801b9b:	eb 05                	jmp    801ba2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5f                   	pop    %edi
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	57                   	push   %edi
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	83 ec 28             	sub    $0x28,%esp
  801bb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	e8 75 f6 ff ff       	call   801234 <fd_alloc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 24 01 00 00    	js     801cf0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	68 07 04 00 00       	push   $0x407
  801bd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 52 f0 ff ff       	call   800c30 <sys_page_alloc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 05 01 00 00    	js     801cf0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 3d f6 ff ff       	call   801234 <fd_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 dc 00 00 00    	js     801ce0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 1a f0 ff ff       	call   800c30 <sys_page_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 bd 00 00 00    	js     801ce0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c29:	e8 ee f5 ff ff       	call   80121c <fd2data>
  801c2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 c4 0c             	add    $0xc,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	50                   	push   %eax
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 f0 ef ff ff       	call   800c30 <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 88 83 00 00 00    	js     801cd0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 e0             	pushl  -0x20(%ebp)
  801c53:	e8 c4 f5 ff ff       	call   80121c <fd2data>
  801c58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5f:	50                   	push   %eax
  801c60:	6a 00                	push   $0x0
  801c62:	56                   	push   %esi
  801c63:	6a 00                	push   $0x0
  801c65:	e8 ea ef ff ff       	call   800c54 <sys_page_map>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 20             	add    $0x20,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 4f                	js     801cc2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ca3:	e8 64 f5 ff ff       	call   80120c <fd2num>
  801ca8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801caa:	83 c4 04             	add    $0x4,%esp
  801cad:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb0:	e8 57 f5 ff ff       	call   80120c <fd2num>
  801cb5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc0:	eb 2e                	jmp    801cf0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	56                   	push   %esi
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 ad ef ff ff       	call   800c7a <sys_page_unmap>
  801ccd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 e0             	pushl  -0x20(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 9d ef ff ff       	call   800c7a <sys_page_unmap>
  801cdd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 8d ef ff ff       	call   800c7a <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5f                   	pop    %edi
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	ff 75 08             	pushl  0x8(%ebp)
  801d07:	e8 9b f5 ff ff       	call   8012a7 <fd_lookup>
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 18                	js     801d2b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	e8 fe f4 ff ff       	call   80121c <fd2data>
	return _pipeisclosed(fd, p);
  801d1e:	89 c2                	mov    %eax,%edx
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	e8 0c fd ff ff       	call   801a34 <_pipeisclosed>
  801d28:	83 c4 10             	add    $0x10,%esp
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    
  801d2d:	00 00                	add    %al,(%eax)
	...

00801d30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d40:	68 4a 28 80 00       	push   $0x80284a
  801d45:	ff 75 0c             	pushl  0xc(%ebp)
  801d48:	e8 61 ea ff ff       	call   8007ae <strcpy>
	return 0;
}
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	57                   	push   %edi
  801d58:	56                   	push   %esi
  801d59:	53                   	push   %ebx
  801d5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d64:	74 45                	je     801dab <devcons_write+0x57>
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d70:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d79:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d7b:	83 fb 7f             	cmp    $0x7f,%ebx
  801d7e:	76 05                	jbe    801d85 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d80:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d85:	83 ec 04             	sub    $0x4,%esp
  801d88:	53                   	push   %ebx
  801d89:	03 45 0c             	add    0xc(%ebp),%eax
  801d8c:	50                   	push   %eax
  801d8d:	57                   	push   %edi
  801d8e:	e8 dc eb ff ff       	call   80096f <memmove>
		sys_cputs(buf, m);
  801d93:	83 c4 08             	add    $0x8,%esp
  801d96:	53                   	push   %ebx
  801d97:	57                   	push   %edi
  801d98:	e8 dc ed ff ff       	call   800b79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9d:	01 de                	add    %ebx,%esi
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da7:	72 cd                	jb     801d76 <devcons_write+0x22>
  801da9:	eb 05                	jmp    801db0 <devcons_write+0x5c>
  801dab:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dc4:	75 07                	jne    801dcd <devcons_read+0x13>
  801dc6:	eb 25                	jmp    801ded <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc8:	e8 3c ee ff ff       	call   800c09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dcd:	e8 cd ed ff ff       	call   800b9f <sys_cgetc>
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	74 f2                	je     801dc8 <devcons_read+0xe>
  801dd6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 1d                	js     801df9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ddc:	83 f8 04             	cmp    $0x4,%eax
  801ddf:	74 13                	je     801df4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de4:	88 10                	mov    %dl,(%eax)
	return 1;
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	eb 0c                	jmp    801df9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ded:	b8 00 00 00 00       	mov    $0x0,%eax
  801df2:	eb 05                	jmp    801df9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
  801e04:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e07:	6a 01                	push   $0x1
  801e09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	e8 67 ed ff ff       	call   800b79 <sys_cputs>
  801e12:	83 c4 10             	add    $0x10,%esp
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <getchar>:

int
getchar(void)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1d:	6a 01                	push   $0x1
  801e1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	6a 00                	push   $0x0
  801e25:	e8 fe f6 ff ff       	call   801528 <read>
	if (r < 0)
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 0f                	js     801e40 <getchar+0x29>
		return r;
	if (r < 1)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	7e 06                	jle    801e3b <getchar+0x24>
		return -E_EOF;
	return c;
  801e35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e39:	eb 05                	jmp    801e40 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	ff 75 08             	pushl  0x8(%ebp)
  801e4f:	e8 53 f4 ff ff       	call   8012a7 <fd_lookup>
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 11                	js     801e6c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e64:	39 10                	cmp    %edx,(%eax)
  801e66:	0f 94 c0             	sete   %al
  801e69:	0f b6 c0             	movzbl %al,%eax
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <opencons>:

int
opencons(void)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	e8 b7 f3 ff ff       	call   801234 <fd_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 3a                	js     801ebe <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	68 07 04 00 00       	push   $0x407
  801e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 9a ed ff ff       	call   800c30 <sys_page_alloc>
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 21                	js     801ebe <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	50                   	push   %eax
  801eb6:	e8 51 f3 ff ff       	call   80120c <fd2num>
  801ebb:	83 c4 10             	add    $0x10,%esp
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ec5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ec8:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ece:	e8 12 ed ff ff       	call   800be5 <sys_getenvid>
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	ff 75 0c             	pushl  0xc(%ebp)
  801ed9:	ff 75 08             	pushl  0x8(%ebp)
  801edc:	53                   	push   %ebx
  801edd:	50                   	push   %eax
  801ede:	68 58 28 80 00       	push   $0x802858
  801ee3:	e8 10 e3 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ee8:	83 c4 18             	add    $0x18,%esp
  801eeb:	56                   	push   %esi
  801eec:	ff 75 10             	pushl  0x10(%ebp)
  801eef:	e8 b3 e2 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801ef4:	c7 04 24 43 28 80 00 	movl   $0x802843,(%esp)
  801efb:	e8 f8 e2 ff ff       	call   8001f8 <cprintf>
  801f00:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f03:	cc                   	int3   
  801f04:	eb fd                	jmp    801f03 <_panic+0x43>
	...

00801f08 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f0e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f15:	75 52                	jne    801f69 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801f17:	83 ec 04             	sub    $0x4,%esp
  801f1a:	6a 07                	push   $0x7
  801f1c:	68 00 f0 bf ee       	push   $0xeebff000
  801f21:	6a 00                	push   $0x0
  801f23:	e8 08 ed ff ff       	call   800c30 <sys_page_alloc>
		if (r < 0) {
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	79 12                	jns    801f41 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801f2f:	50                   	push   %eax
  801f30:	68 7b 28 80 00       	push   $0x80287b
  801f35:	6a 24                	push   $0x24
  801f37:	68 96 28 80 00       	push   $0x802896
  801f3c:	e8 7f ff ff ff       	call   801ec0 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	68 74 1f 80 00       	push   $0x801f74
  801f49:	6a 00                	push   $0x0
  801f4b:	e8 93 ed ff ff       	call   800ce3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	85 c0                	test   %eax,%eax
  801f55:	79 12                	jns    801f69 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f57:	50                   	push   %eax
  801f58:	68 a4 28 80 00       	push   $0x8028a4
  801f5d:	6a 2a                	push   $0x2a
  801f5f:	68 96 28 80 00       	push   $0x802896
  801f64:	e8 57 ff ff ff       	call   801ec0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    
	...

00801f74 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f74:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f75:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f7a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f7c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f7f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f83:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f86:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f8a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f8e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f90:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f93:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f94:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f97:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f98:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f99:	c3                   	ret    
	...

00801f9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	c1 ea 16             	shr    $0x16,%edx
  801fa7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fae:	f6 c2 01             	test   $0x1,%dl
  801fb1:	74 1e                	je     801fd1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb3:	c1 e8 0c             	shr    $0xc,%eax
  801fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fbd:	a8 01                	test   $0x1,%al
  801fbf:	74 17                	je     801fd8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc1:	c1 e8 0c             	shr    $0xc,%eax
  801fc4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fcb:	ef 
  801fcc:	0f b7 c0             	movzwl %ax,%eax
  801fcf:	eb 0c                	jmp    801fdd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd6:	eb 05                	jmp    801fdd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    
	...

00801fe0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	83 ec 10             	sub    $0x10,%esp
  801fe8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801feb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fee:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ff1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ff4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ff7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	75 2e                	jne    80202c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ffe:	39 f1                	cmp    %esi,%ecx
  802000:	77 5a                	ja     80205c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802002:	85 c9                	test   %ecx,%ecx
  802004:	75 0b                	jne    802011 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802006:	b8 01 00 00 00       	mov    $0x1,%eax
  80200b:	31 d2                	xor    %edx,%edx
  80200d:	f7 f1                	div    %ecx
  80200f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802011:	31 d2                	xor    %edx,%edx
  802013:	89 f0                	mov    %esi,%eax
  802015:	f7 f1                	div    %ecx
  802017:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802019:	89 f8                	mov    %edi,%eax
  80201b:	f7 f1                	div    %ecx
  80201d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80201f:	89 f8                	mov    %edi,%eax
  802021:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	c9                   	leave  
  802029:	c3                   	ret    
  80202a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80202c:	39 f0                	cmp    %esi,%eax
  80202e:	77 1c                	ja     80204c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802030:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802033:	83 f7 1f             	xor    $0x1f,%edi
  802036:	75 3c                	jne    802074 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	0f 82 90 00 00 00    	jb     8020d0 <__udivdi3+0xf0>
  802040:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802043:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802046:	0f 86 84 00 00 00    	jbe    8020d0 <__udivdi3+0xf0>
  80204c:	31 f6                	xor    %esi,%esi
  80204e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802050:	89 f8                	mov    %edi,%eax
  802052:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	c9                   	leave  
  80205a:	c3                   	ret    
  80205b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	89 f8                	mov    %edi,%eax
  802060:	f7 f1                	div    %ecx
  802062:	89 c7                	mov    %eax,%edi
  802064:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802066:	89 f8                	mov    %edi,%eax
  802068:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	5e                   	pop    %esi
  80206e:	5f                   	pop    %edi
  80206f:	c9                   	leave  
  802070:	c3                   	ret    
  802071:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802074:	89 f9                	mov    %edi,%ecx
  802076:	d3 e0                	shl    %cl,%eax
  802078:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80207b:	b8 20 00 00 00       	mov    $0x20,%eax
  802080:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802082:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802085:	88 c1                	mov    %al,%cl
  802087:	d3 ea                	shr    %cl,%edx
  802089:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80208c:	09 ca                	or     %ecx,%edx
  80208e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802091:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802094:	89 f9                	mov    %edi,%ecx
  802096:	d3 e2                	shl    %cl,%edx
  802098:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80209b:	89 f2                	mov    %esi,%edx
  80209d:	88 c1                	mov    %al,%cl
  80209f:	d3 ea                	shr    %cl,%edx
  8020a1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8020a4:	89 f2                	mov    %esi,%edx
  8020a6:	89 f9                	mov    %edi,%ecx
  8020a8:	d3 e2                	shl    %cl,%edx
  8020aa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020ad:	88 c1                	mov    %al,%cl
  8020af:	d3 ee                	shr    %cl,%esi
  8020b1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020b3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8020b6:	89 f0                	mov    %esi,%eax
  8020b8:	89 ca                	mov    %ecx,%edx
  8020ba:	f7 75 ec             	divl   -0x14(%ebp)
  8020bd:	89 d1                	mov    %edx,%ecx
  8020bf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020c1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c4:	39 d1                	cmp    %edx,%ecx
  8020c6:	72 28                	jb     8020f0 <__udivdi3+0x110>
  8020c8:	74 1a                	je     8020e4 <__udivdi3+0x104>
  8020ca:	89 f7                	mov    %esi,%edi
  8020cc:	31 f6                	xor    %esi,%esi
  8020ce:	eb 80                	jmp    802050 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020d0:	31 f6                	xor    %esi,%esi
  8020d2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020d7:	89 f8                	mov    %edi,%eax
  8020d9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    
  8020e2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020e7:	89 f9                	mov    %edi,%ecx
  8020e9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020eb:	39 c2                	cmp    %eax,%edx
  8020ed:	73 db                	jae    8020ca <__udivdi3+0xea>
  8020ef:	90                   	nop
		{
		  q0--;
  8020f0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020f3:	31 f6                	xor    %esi,%esi
  8020f5:	e9 56 ff ff ff       	jmp    802050 <__udivdi3+0x70>
	...

008020fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	57                   	push   %edi
  802100:	56                   	push   %esi
  802101:	83 ec 20             	sub    $0x20,%esp
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80210a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80210d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802110:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802113:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802116:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802119:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80211b:	85 ff                	test   %edi,%edi
  80211d:	75 15                	jne    802134 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80211f:	39 f1                	cmp    %esi,%ecx
  802121:	0f 86 99 00 00 00    	jbe    8021c0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802127:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80212d:	83 c4 20             	add    $0x20,%esp
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	c9                   	leave  
  802133:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802134:	39 f7                	cmp    %esi,%edi
  802136:	0f 87 a4 00 00 00    	ja     8021e0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80213c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80213f:	83 f0 1f             	xor    $0x1f,%eax
  802142:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802145:	0f 84 a1 00 00 00    	je     8021ec <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80214b:	89 f8                	mov    %edi,%eax
  80214d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802150:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802152:	bf 20 00 00 00       	mov    $0x20,%edi
  802157:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80215a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80215d:	89 f9                	mov    %edi,%ecx
  80215f:	d3 ea                	shr    %cl,%edx
  802161:	09 c2                	or     %eax,%edx
  802163:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802169:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802171:	89 f2                	mov    %esi,%edx
  802173:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802175:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802178:	d3 e0                	shl    %cl,%eax
  80217a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80217d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802180:	89 f9                	mov    %edi,%ecx
  802182:	d3 e8                	shr    %cl,%eax
  802184:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802186:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802188:	89 f2                	mov    %esi,%edx
  80218a:	f7 75 f0             	divl   -0x10(%ebp)
  80218d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80218f:	f7 65 f4             	mull   -0xc(%ebp)
  802192:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802195:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802197:	39 d6                	cmp    %edx,%esi
  802199:	72 71                	jb     80220c <__umoddi3+0x110>
  80219b:	74 7f                	je     80221c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80219d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021a0:	29 c8                	sub    %ecx,%eax
  8021a2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021a4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 f2                	mov    %esi,%edx
  8021ab:	89 f9                	mov    %edi,%ecx
  8021ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021af:	09 d0                	or     %edx,%eax
  8021b1:	89 f2                	mov    %esi,%edx
  8021b3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021b6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b8:	83 c4 20             	add    $0x20,%esp
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    
  8021bf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021c0:	85 c9                	test   %ecx,%ecx
  8021c2:	75 0b                	jne    8021cf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c9:	31 d2                	xor    %edx,%edx
  8021cb:	f7 f1                	div    %ecx
  8021cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d8:	f7 f1                	div    %ecx
  8021da:	e9 4a ff ff ff       	jmp    802129 <__umoddi3+0x2d>
  8021df:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021e0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e2:	83 c4 20             	add    $0x20,%esp
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	c9                   	leave  
  8021e8:	c3                   	ret    
  8021e9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	72 05                	jb     8021f5 <__umoddi3+0xf9>
  8021f0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021f3:	77 0c                	ja     802201 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021f5:	89 f2                	mov    %esi,%edx
  8021f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021fa:	29 c8                	sub    %ecx,%eax
  8021fc:	19 fa                	sbb    %edi,%edx
  8021fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802204:	83 c4 20             	add    $0x20,%esp
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	c9                   	leave  
  80220a:	c3                   	ret    
  80220b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80220c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802214:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802217:	eb 84                	jmp    80219d <__umoddi3+0xa1>
  802219:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80221c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80221f:	72 eb                	jb     80220c <__umoddi3+0x110>
  802221:	89 f2                	mov    %esi,%edx
  802223:	e9 75 ff ff ff       	jmp    80219d <__umoddi3+0xa1>
