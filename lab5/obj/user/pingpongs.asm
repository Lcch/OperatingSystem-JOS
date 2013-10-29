
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
  80003d:	e8 ef 0f 00 00       	call   801031 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 42                	je     80008b <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 95 0b 00 00       	call   800be9 <sys_getenvid>
  800054:	83 ec 04             	sub    $0x4,%esp
  800057:	53                   	push   %ebx
  800058:	50                   	push   %eax
  800059:	68 e0 21 80 00       	push   $0x8021e0
  80005e:	e8 99 01 00 00       	call   8001fc <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800063:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800066:	e8 7e 0b 00 00       	call   800be9 <sys_getenvid>
  80006b:	83 c4 0c             	add    $0xc,%esp
  80006e:	53                   	push   %ebx
  80006f:	50                   	push   %eax
  800070:	68 fa 21 80 00       	push   $0x8021fa
  800075:	e8 82 01 00 00       	call   8001fc <cprintf>
		ipc_send(who, 0, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	6a 00                	push   $0x0
  800080:	ff 75 e4             	pushl  -0x1c(%ebp)
  800083:	e8 6c 10 00 00       	call   8010f4 <ipc_send>
  800088:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008b:	83 ec 04             	sub    $0x4,%esp
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	e8 b1 0f 00 00       	call   80104c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009b:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a1:	8b 73 48             	mov    0x48(%ebx),%esi
  8000a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000af:	e8 35 0b 00 00       	call   800be9 <sys_getenvid>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	57                   	push   %edi
  8000ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bd:	50                   	push   %eax
  8000be:	68 10 22 80 00       	push   $0x802210
  8000c3:	e8 34 01 00 00       	call   8001fc <cprintf>
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
  8000e4:	e8 0b 10 00 00       	call   8010f4 <ipc_send>
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
  80010b:	e8 d9 0a 00 00       	call   800be9 <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011c:	c1 e0 07             	shl    $0x7,%eax
  80011f:	29 d0                	sub    %edx,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x36>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	53                   	push   %ebx
  80013a:	56                   	push   %esi
  80013b:	e8 f4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800140:	e8 0b 00 00 00       	call   800150 <exit>
  800145:	83 c4 10             	add    $0x10,%esp
}
  800148:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800156:	e8 53 12 00 00       	call   8013ae <close_all>
	sys_env_destroy(0);
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	6a 00                	push   $0x0
  800160:	e8 62 0a 00 00       	call   800bc7 <sys_env_destroy>
  800165:	83 c4 10             	add    $0x10,%esp
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    
	...

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 03                	mov    (%ebx),%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017f:	40                   	inc    %eax
  800180:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800182:	3d ff 00 00 00       	cmp    $0xff,%eax
  800187:	75 1a                	jne    8001a3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800189:	83 ec 08             	sub    $0x8,%esp
  80018c:	68 ff 00 00 00       	push   $0xff
  800191:	8d 43 08             	lea    0x8(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 e3 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80019a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a3:	ff 43 04             	incl   0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bb:	00 00 00 
	b.cnt = 0;
  8001be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c8:	ff 75 0c             	pushl  0xc(%ebp)
  8001cb:	ff 75 08             	pushl  0x8(%ebp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	50                   	push   %eax
  8001d5:	68 6c 01 80 00       	push   $0x80016c
  8001da:	e8 82 01 00 00       	call   800361 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	83 c4 08             	add    $0x8,%esp
  8001e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 89 09 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 9d ff ff ff       	call   8001ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 2c             	sub    $0x2c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
  80022d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800230:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800236:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80023d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800240:	72 0c                	jb     80024e <printnum+0x3e>
  800242:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800245:	76 07                	jbe    80024e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	4b                   	dec    %ebx
  800248:	85 db                	test   %ebx,%ebx
  80024a:	7f 31                	jg     80027d <printnum+0x6d>
  80024c:	eb 3f                	jmp    80028d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	57                   	push   %edi
  800252:	4b                   	dec    %ebx
  800253:	53                   	push   %ebx
  800254:	50                   	push   %eax
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 2f 1d 00 00       	call   801f98 <__udivdi3>
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	52                   	push   %edx
  80026d:	50                   	push   %eax
  80026e:	89 f2                	mov    %esi,%edx
  800270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800273:	e8 98 ff ff ff       	call   800210 <printnum>
  800278:	83 c4 20             	add    $0x20,%esp
  80027b:	eb 10                	jmp    80028d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	57                   	push   %edi
  800282:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800285:	4b                   	dec    %ebx
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	85 db                	test   %ebx,%ebx
  80028b:	7f f0                	jg     80027d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	56                   	push   %esi
  800291:	83 ec 04             	sub    $0x4,%esp
  800294:	ff 75 d4             	pushl  -0x2c(%ebp)
  800297:	ff 75 d0             	pushl  -0x30(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 0f 1e 00 00       	call   8020b4 <__umoddi3>
  8002a5:	83 c4 14             	add    $0x14,%esp
  8002a8:	0f be 80 40 22 80 00 	movsbl 0x802240(%eax),%eax
  8002af:	50                   	push   %eax
  8002b0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002b3:	83 c4 10             	add    $0x10,%esp
}
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fb:	83 fa 01             	cmp    $0x1,%edx
  8002fe:	7e 0e                	jle    80030e <getint+0x16>
		return va_arg(*ap, long long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 08             	lea    0x8(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	8b 52 04             	mov    0x4(%edx),%edx
  80030c:	eb 1a                	jmp    800328 <getint+0x30>
	else if (lflag)
  80030e:	85 d2                	test   %edx,%edx
  800310:	74 0c                	je     80031e <getint+0x26>
		return va_arg(*ap, long);
  800312:	8b 10                	mov    (%eax),%edx
  800314:	8d 4a 04             	lea    0x4(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 02                	mov    (%edx),%eax
  80031b:	99                   	cltd   
  80031c:	eb 0a                	jmp    800328 <getint+0x30>
	else
		return va_arg(*ap, int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	99                   	cltd   
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800330:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800333:	8b 10                	mov    (%eax),%edx
  800335:	3b 50 04             	cmp    0x4(%eax),%edx
  800338:	73 08                	jae    800342 <sprintputch+0x18>
		*b->buf++ = ch;
  80033a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033d:	88 0a                	mov    %cl,(%edx)
  80033f:	42                   	inc    %edx
  800340:	89 10                	mov    %edx,(%eax)
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034d:	50                   	push   %eax
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	e8 05 00 00 00       	call   800361 <vprintfmt>
	va_end(ap);
  80035c:	83 c4 10             	add    $0x10,%esp
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
  800367:	83 ec 2c             	sub    $0x2c,%esp
  80036a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80036d:	8b 75 10             	mov    0x10(%ebp),%esi
  800370:	eb 13                	jmp    800385 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800372:	85 c0                	test   %eax,%eax
  800374:	0f 84 6d 03 00 00    	je     8006e7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	57                   	push   %edi
  80037e:	50                   	push   %eax
  80037f:	ff 55 08             	call   *0x8(%ebp)
  800382:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800385:	0f b6 06             	movzbl (%esi),%eax
  800388:	46                   	inc    %esi
  800389:	83 f8 25             	cmp    $0x25,%eax
  80038c:	75 e4                	jne    800372 <vprintfmt+0x11>
  80038e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800392:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800399:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ac:	eb 28                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003b4:	eb 20                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003bc:	eb 18                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c7:	eb 0d                	jmp    8003d6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8a 06                	mov    (%esi),%al
  8003d8:	0f b6 d0             	movzbl %al,%edx
  8003db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003de:	83 e8 23             	sub    $0x23,%eax
  8003e1:	3c 55                	cmp    $0x55,%al
  8003e3:	0f 87 e0 02 00 00    	ja     8006c9 <vprintfmt+0x368>
  8003e9:	0f b6 c0             	movzbl %al,%eax
  8003ec:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f3:	83 ea 30             	sub    $0x30,%edx
  8003f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003fc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ff:	83 fa 09             	cmp    $0x9,%edx
  800402:	77 44                	ja     800448 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	89 de                	mov    %ebx,%esi
  800406:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80040a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80040d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800411:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800414:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800417:	83 fb 09             	cmp    $0x9,%ebx
  80041a:	76 ed                	jbe    800409 <vprintfmt+0xa8>
  80041c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80041f:	eb 29                	jmp    80044a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800431:	eb 17                	jmp    80044a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	78 85                	js     8003be <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	89 de                	mov    %ebx,%esi
  80043b:	eb 99                	jmp    8003d6 <vprintfmt+0x75>
  80043d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800446:	eb 8e                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044e:	79 86                	jns    8003d6 <vprintfmt+0x75>
  800450:	e9 74 ff ff ff       	jmp    8003c9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800455:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	89 de                	mov    %ebx,%esi
  800458:	e9 79 ff ff ff       	jmp    8003d6 <vprintfmt+0x75>
  80045d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	57                   	push   %edi
  80046d:	ff 30                	pushl  (%eax)
  80046f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800478:	e9 08 ff ff ff       	jmp    800385 <vprintfmt+0x24>
  80047d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	79 02                	jns    800491 <vprintfmt+0x130>
  80048f:	f7 d8                	neg    %eax
  800491:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 0f             	cmp    $0xf,%eax
  800496:	7f 0b                	jg     8004a3 <vprintfmt+0x142>
  800498:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 1a                	jne    8004bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004a3:	52                   	push   %edx
  8004a4:	68 58 22 80 00       	push   $0x802258
  8004a9:	57                   	push   %edi
  8004aa:	ff 75 08             	pushl  0x8(%ebp)
  8004ad:	e8 92 fe ff ff       	call   800344 <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b8:	e9 c8 fe ff ff       	jmp    800385 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004bd:	50                   	push   %eax
  8004be:	68 cd 27 80 00       	push   $0x8027cd
  8004c3:	57                   	push   %edi
  8004c4:	ff 75 08             	pushl  0x8(%ebp)
  8004c7:	e8 78 fe ff ff       	call   800344 <printfmt>
  8004cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d2:	e9 ae fe ff ff       	jmp    800385 <vprintfmt+0x24>
  8004d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	75 07                	jne    8004fb <vprintfmt+0x19a>
				p = "(null)";
  8004f4:	c7 45 d0 51 22 80 00 	movl   $0x802251,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004fb:	85 db                	test   %ebx,%ebx
  8004fd:	7e 42                	jle    800541 <vprintfmt+0x1e0>
  8004ff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800503:	74 3c                	je     800541 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	51                   	push   %ecx
  800509:	ff 75 d0             	pushl  -0x30(%ebp)
  80050c:	e8 6f 02 00 00       	call   800780 <strnlen>
  800511:	29 c3                	sub    %eax,%ebx
  800513:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	85 db                	test   %ebx,%ebx
  80051b:	7e 24                	jle    800541 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80051d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800521:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800524:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	57                   	push   %edi
  80052b:	53                   	push   %ebx
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4e                   	dec    %esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 f6                	test   %esi,%esi
  800535:	7f f0                	jg     800527 <vprintfmt+0x1c6>
  800537:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80053a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800544:	0f be 02             	movsbl (%edx),%eax
  800547:	85 c0                	test   %eax,%eax
  800549:	75 47                	jne    800592 <vprintfmt+0x231>
  80054b:	eb 37                	jmp    800584 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	74 16                	je     800569 <vprintfmt+0x208>
  800553:	8d 50 e0             	lea    -0x20(%eax),%edx
  800556:	83 fa 5e             	cmp    $0x5e,%edx
  800559:	76 0e                	jbe    800569 <vprintfmt+0x208>
					putch('?', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	57                   	push   %edi
  80055f:	6a 3f                	push   $0x3f
  800561:	ff 55 08             	call   *0x8(%ebp)
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	57                   	push   %edi
  80056d:	50                   	push   %eax
  80056e:	ff 55 08             	call   *0x8(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800574:	ff 4d e4             	decl   -0x1c(%ebp)
  800577:	0f be 03             	movsbl (%ebx),%eax
  80057a:	85 c0                	test   %eax,%eax
  80057c:	74 03                	je     800581 <vprintfmt+0x220>
  80057e:	43                   	inc    %ebx
  80057f:	eb 1b                	jmp    80059c <vprintfmt+0x23b>
  800581:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800588:	7f 1e                	jg     8005a8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80058d:	e9 f3 fd ff ff       	jmp    800385 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800595:	43                   	inc    %ebx
  800596:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800599:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80059c:	85 f6                	test   %esi,%esi
  80059e:	78 ad                	js     80054d <vprintfmt+0x1ec>
  8005a0:	4e                   	dec    %esi
  8005a1:	79 aa                	jns    80054d <vprintfmt+0x1ec>
  8005a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a6:	eb dc                	jmp    800584 <vprintfmt+0x223>
  8005a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	6a 20                	push   $0x20
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	4b                   	dec    %ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7f ef                	jg     8005ab <vprintfmt+0x24a>
  8005bc:	e9 c4 fd ff ff       	jmp    800385 <vprintfmt+0x24>
  8005c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c4:	89 ca                	mov    %ecx,%edx
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 2a fd ff ff       	call   8002f8 <getint>
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	78 0a                	js     8005e0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005db:	e9 b0 00 00 00       	jmp    800690 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	6a 2d                	push   $0x2d
  8005e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e9:	f7 db                	neg    %ebx
  8005eb:	83 d6 00             	adc    $0x0,%esi
  8005ee:	f7 de                	neg    %esi
  8005f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	e9 93 00 00 00       	jmp    800690 <vprintfmt+0x32f>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800600:	89 ca                	mov    %ecx,%edx
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 b4 fc ff ff       	call   8002be <getuint>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	89 d6                	mov    %edx,%esi
			base = 10;
  80060e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800613:	eb 7b                	jmp    800690 <vprintfmt+0x32f>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 d6 fc ff ff       	call   8002f8 <getint>
  800622:	89 c3                	mov    %eax,%ebx
  800624:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800626:	85 d2                	test   %edx,%edx
  800628:	78 07                	js     800631 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80062a:	b8 08 00 00 00       	mov    $0x8,%eax
  80062f:	eb 5f                	jmp    800690 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	57                   	push   %edi
  800635:	6a 2d                	push   $0x2d
  800637:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80063a:	f7 db                	neg    %ebx
  80063c:	83 d6 00             	adc    $0x0,%esi
  80063f:	f7 de                	neg    %esi
  800641:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800644:	b8 08 00 00 00       	mov    $0x8,%eax
  800649:	eb 45                	jmp    800690 <vprintfmt+0x32f>
  80064b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	57                   	push   %edi
  800652:	6a 30                	push   $0x30
  800654:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	57                   	push   %edi
  80065b:	6a 78                	push   $0x78
  80065d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800669:	8b 18                	mov    (%eax),%ebx
  80066b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800670:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800673:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800678:	eb 16                	jmp    800690 <vprintfmt+0x32f>
  80067a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 37 fc ff ff       	call   8002be <getuint>
  800687:	89 c3                	mov    %eax,%ebx
  800689:	89 d6                	mov    %edx,%esi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800697:	52                   	push   %edx
  800698:	ff 75 e4             	pushl  -0x1c(%ebp)
  80069b:	50                   	push   %eax
  80069c:	56                   	push   %esi
  80069d:	53                   	push   %ebx
  80069e:	89 fa                	mov    %edi,%edx
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	e8 68 fb ff ff       	call   800210 <printnum>
			break;
  8006a8:	83 c4 20             	add    $0x20,%esp
  8006ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ae:	e9 d2 fc ff ff       	jmp    800385 <vprintfmt+0x24>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	57                   	push   %edi
  8006ba:	52                   	push   %edx
  8006bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c4:	e9 bc fc ff ff       	jmp    800385 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	57                   	push   %edi
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb 02                	jmp    8006d9 <vprintfmt+0x378>
  8006d7:	89 c6                	mov    %eax,%esi
  8006d9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e0:	75 f5                	jne    8006d7 <vprintfmt+0x376>
  8006e2:	e9 9e fc ff ff       	jmp    800385 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ea:	5b                   	pop    %ebx
  8006eb:	5e                   	pop    %esi
  8006ec:	5f                   	pop    %edi
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 18             	sub    $0x18,%esp
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800702:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 26                	je     800736 <vsnprintf+0x47>
  800710:	85 d2                	test   %edx,%edx
  800712:	7e 29                	jle    80073d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800714:	ff 75 14             	pushl  0x14(%ebp)
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	68 2a 03 80 00       	push   $0x80032a
  800723:	e8 39 fc ff ff       	call   800361 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb 0c                	jmp    800742 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x53>
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 93 ff ff ff       	call   8006ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
	...

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3a 00             	cmpb   $0x0,(%edx)
  800769:	74 0e                	je     800779 <strlen+0x19>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800770:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f9                	jne    800770 <strlen+0x10>
  800777:	eb 05                	jmp    80077e <strlen+0x1e>
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 17                	je     8007a4 <strnlen+0x24>
  80078d:	80 39 00             	cmpb   $0x0,(%ecx)
  800790:	74 19                	je     8007ab <strnlen+0x2b>
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800797:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	39 d0                	cmp    %edx,%eax
  80079a:	74 14                	je     8007b0 <strnlen+0x30>
  80079c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a0:	75 f5                	jne    800797 <strnlen+0x17>
  8007a2:	eb 0c                	jmp    8007b0 <strnlen+0x30>
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 05                	jmp    8007b0 <strnlen+0x30>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c7:	42                   	inc    %edx
  8007c8:	84 c9                	test   %cl,%cl
  8007ca:	75 f5                	jne    8007c1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cc:	5b                   	pop    %ebx
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	53                   	push   %ebx
  8007d7:	e8 84 ff ff ff       	call   800760 <strlen>
  8007dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007e5:	50                   	push   %eax
  8007e6:	e8 c7 ff ff ff       	call   8007b2 <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	85 f6                	test   %esi,%esi
  800802:	74 15                	je     800819 <strncpy+0x27>
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800809:	8a 1a                	mov    (%edx),%bl
  80080b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080e:	80 3a 01             	cmpb   $0x1,(%edx)
  800811:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800814:	41                   	inc    %ecx
  800815:	39 ce                	cmp    %ecx,%esi
  800817:	77 f0                	ja     800809 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	57                   	push   %edi
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 7d 08             	mov    0x8(%ebp),%edi
  800826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800829:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	85 f6                	test   %esi,%esi
  80082e:	74 32                	je     800862 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800830:	83 fe 01             	cmp    $0x1,%esi
  800833:	74 22                	je     800857 <strlcpy+0x3a>
  800835:	8a 0b                	mov    (%ebx),%cl
  800837:	84 c9                	test   %cl,%cl
  800839:	74 20                	je     80085b <strlcpy+0x3e>
  80083b:	89 f8                	mov    %edi,%eax
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800842:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800845:	88 08                	mov    %cl,(%eax)
  800847:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800848:	39 f2                	cmp    %esi,%edx
  80084a:	74 11                	je     80085d <strlcpy+0x40>
  80084c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800850:	42                   	inc    %edx
  800851:	84 c9                	test   %cl,%cl
  800853:	75 f0                	jne    800845 <strlcpy+0x28>
  800855:	eb 06                	jmp    80085d <strlcpy+0x40>
  800857:	89 f8                	mov    %edi,%eax
  800859:	eb 02                	jmp    80085d <strlcpy+0x40>
  80085b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085d:	c6 00 00             	movb   $0x0,(%eax)
  800860:	eb 02                	jmp    800864 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800864:	29 f8                	sub    %edi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5f                   	pop    %edi
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	8a 01                	mov    (%ecx),%al
  800876:	84 c0                	test   %al,%al
  800878:	74 10                	je     80088a <strcmp+0x1f>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	75 0c                	jne    80088a <strcmp+0x1f>
		p++, q++;
  80087e:	41                   	inc    %ecx
  80087f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800880:	8a 01                	mov    (%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 04                	je     80088a <strcmp+0x1f>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	74 f4                	je     80087e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	74 1b                	je     8008c0 <strncmp+0x2c>
  8008a5:	8a 1a                	mov    (%edx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	74 24                	je     8008cf <strncmp+0x3b>
  8008ab:	3a 19                	cmp    (%ecx),%bl
  8008ad:	75 20                	jne    8008cf <strncmp+0x3b>
  8008af:	48                   	dec    %eax
  8008b0:	74 15                	je     8008c7 <strncmp+0x33>
		n--, p++, q++;
  8008b2:	42                   	inc    %edx
  8008b3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b4:	8a 1a                	mov    (%edx),%bl
  8008b6:	84 db                	test   %bl,%bl
  8008b8:	74 15                	je     8008cf <strncmp+0x3b>
  8008ba:	3a 19                	cmp    (%ecx),%bl
  8008bc:	74 f1                	je     8008af <strncmp+0x1b>
  8008be:	eb 0f                	jmp    8008cf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 05                	jmp    8008cc <strncmp+0x38>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 02             	movzbl (%edx),%eax
  8008d2:	0f b6 11             	movzbl (%ecx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
  8008d7:	eb f3                	jmp    8008cc <strncmp+0x38>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e2:	8a 10                	mov    (%eax),%dl
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	74 18                	je     800900 <strchr+0x27>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	75 06                	jne    8008f2 <strchr+0x19>
  8008ec:	eb 17                	jmp    800905 <strchr+0x2c>
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 13                	je     800905 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f2:	40                   	inc    %eax
  8008f3:	8a 10                	mov    (%eax),%dl
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f5                	jne    8008ee <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb 05                	jmp    800905 <strchr+0x2c>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800910:	8a 10                	mov    (%eax),%dl
  800912:	84 d2                	test   %dl,%dl
  800914:	74 11                	je     800927 <strfind+0x20>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	75 06                	jne    800920 <strfind+0x19>
  80091a:	eb 0b                	jmp    800927 <strfind+0x20>
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 07                	je     800927 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 30                	je     80096c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800942:	75 25                	jne    800969 <memset+0x40>
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 20                	jne    800969 <memset+0x40>
		c &= 0xFF;
  800949:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094c:	89 d3                	mov    %edx,%ebx
  80094e:	c1 e3 08             	shl    $0x8,%ebx
  800951:	89 d6                	mov    %edx,%esi
  800953:	c1 e6 18             	shl    $0x18,%esi
  800956:	89 d0                	mov    %edx,%eax
  800958:	c1 e0 10             	shl    $0x10,%eax
  80095b:	09 f0                	or     %esi,%eax
  80095d:	09 d0                	or     %edx,%eax
  80095f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800961:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb 03                	jmp    80096c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800981:	39 c6                	cmp    %eax,%esi
  800983:	73 34                	jae    8009b9 <memmove+0x46>
  800985:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	73 2d                	jae    8009b9 <memmove+0x46>
		s += n;
		d += n;
  80098c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	75 1b                	jne    8009af <memmove+0x3c>
  800994:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099a:	75 13                	jne    8009af <memmove+0x3c>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0e                	jne    8009af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 07                	jmp    8009b6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	4f                   	dec    %edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 20                	jmp    8009d9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x61>
  8009c1:	a8 03                	test   $0x3,%al
  8009c3:	75 0f                	jne    8009d4 <memmove+0x61>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 0a                	jne    8009d4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 05                	jmp    8009d9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e0:	ff 75 10             	pushl  0x10(%ebp)
  8009e3:	ff 75 0c             	pushl  0xc(%ebp)
  8009e6:	ff 75 08             	pushl  0x8(%ebp)
  8009e9:	e8 85 ff ff ff       	call   800973 <memmove>
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	85 ff                	test   %edi,%edi
  800a01:	74 32                	je     800a35 <memcmp+0x45>
		if (*s1 != *s2)
  800a03:	8a 03                	mov    (%ebx),%al
  800a05:	8a 0e                	mov    (%esi),%cl
  800a07:	38 c8                	cmp    %cl,%al
  800a09:	74 19                	je     800a24 <memcmp+0x34>
  800a0b:	eb 0d                	jmp    800a1a <memcmp+0x2a>
  800a0d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a11:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a15:	42                   	inc    %edx
  800a16:	38 c8                	cmp    %cl,%al
  800a18:	74 10                	je     800a2a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c0             	movzbl %al,%eax
  800a1d:	0f b6 c9             	movzbl %cl,%ecx
  800a20:	29 c8                	sub    %ecx,%eax
  800a22:	eb 16                	jmp    800a3a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	4f                   	dec    %edi
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	39 fa                	cmp    %edi,%edx
  800a2c:	75 df                	jne    800a0d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 05                	jmp    800a3a <memcmp+0x4a>
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a45:	89 c2                	mov    %eax,%edx
  800a47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 12                	jae    800a60 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	75 06                	jne    800a5b <memfind+0x1c>
  800a55:	eb 09                	jmp    800a60 <memfind+0x21>
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	40                   	inc    %eax
  800a5c:	39 c2                	cmp    %eax,%edx
  800a5e:	77 f7                	ja     800a57 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 01                	jmp    800a71 <strtol+0xf>
		s++;
  800a70:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	8a 02                	mov    (%edx),%al
  800a73:	3c 20                	cmp    $0x20,%al
  800a75:	74 f9                	je     800a70 <strtol+0xe>
  800a77:	3c 09                	cmp    $0x9,%al
  800a79:	74 f5                	je     800a70 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7b:	3c 2b                	cmp    $0x2b,%al
  800a7d:	75 08                	jne    800a87 <strtol+0x25>
		s++;
  800a7f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
  800a85:	eb 13                	jmp    800a9a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	75 0a                	jne    800a95 <strtol+0x33>
		s++, neg = 1;
  800a8b:	8d 52 01             	lea    0x1(%edx),%edx
  800a8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a93:	eb 05                	jmp    800a9a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9a:	85 db                	test   %ebx,%ebx
  800a9c:	74 05                	je     800aa3 <strtol+0x41>
  800a9e:	83 fb 10             	cmp    $0x10,%ebx
  800aa1:	75 28                	jne    800acb <strtol+0x69>
  800aa3:	8a 02                	mov    (%edx),%al
  800aa5:	3c 30                	cmp    $0x30,%al
  800aa7:	75 10                	jne    800ab9 <strtol+0x57>
  800aa9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aad:	75 0a                	jne    800ab9 <strtol+0x57>
		s += 2, base = 16;
  800aaf:	83 c2 02             	add    $0x2,%edx
  800ab2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab7:	eb 12                	jmp    800acb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 0e                	jne    800acb <strtol+0x69>
  800abd:	3c 30                	cmp    $0x30,%al
  800abf:	75 05                	jne    800ac6 <strtol+0x64>
		s++, base = 8;
  800ac1:	42                   	inc    %edx
  800ac2:	b3 08                	mov    $0x8,%bl
  800ac4:	eb 05                	jmp    800acb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	8a 0a                	mov    (%edx),%cl
  800ad4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad7:	80 fb 09             	cmp    $0x9,%bl
  800ada:	77 08                	ja     800ae4 <strtol+0x82>
			dig = *s - '0';
  800adc:	0f be c9             	movsbl %cl,%ecx
  800adf:	83 e9 30             	sub    $0x30,%ecx
  800ae2:	eb 1e                	jmp    800b02 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aec:	0f be c9             	movsbl %cl,%ecx
  800aef:	83 e9 57             	sub    $0x57,%ecx
  800af2:	eb 0e                	jmp    800b02 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 13                	ja     800b0f <strtol+0xad>
			dig = *s - 'A' + 10;
  800afc:	0f be c9             	movsbl %cl,%ecx
  800aff:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b02:	39 f1                	cmp    %esi,%ecx
  800b04:	7d 0d                	jge    800b13 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b06:	42                   	inc    %edx
  800b07:	0f af c6             	imul   %esi,%eax
  800b0a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b0d:	eb c3                	jmp    800ad2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0f:	89 c1                	mov    %eax,%ecx
  800b11:	eb 02                	jmp    800b15 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b13:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b19:	74 05                	je     800b20 <strtol+0xbe>
		*endptr = (char *) s;
  800b1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b20:	85 ff                	test   %edi,%edi
  800b22:	74 04                	je     800b28 <strtol+0xc6>
  800b24:	89 c8                	mov    %ecx,%eax
  800b26:	f7 d8                	neg    %eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    
  800b2d:	00 00                	add    %al,(%eax)
	...

00800b30 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 1c             	sub    $0x1c,%esp
  800b39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b3f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	8b 75 14             	mov    0x14(%ebp),%esi
  800b44:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	cd 30                	int    $0x30
  800b4f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b55:	74 1c                	je     800b73 <syscall+0x43>
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 18                	jle    800b73 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b62:	68 3f 25 80 00       	push   $0x80253f
  800b67:	6a 42                	push   $0x42
  800b69:	68 5c 25 80 00       	push   $0x80255c
  800b6e:	e8 05 13 00 00       	call   801e78 <_panic>

	return ret;
}
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	ff 75 0c             	pushl  0xc(%ebp)
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	e8 92 ff ff ff       	call   800b30 <syscall>
  800b9e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc0:	e8 6b ff ff ff       	call   800b30 <syscall>
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	e8 49 ff ff ff       	call   800b30 <syscall>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 02 00 00 00       	mov    $0x2,%eax
  800c06:	e8 25 ff ff ff       	call   800b30 <syscall>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <sys_yield>:

void
sys_yield(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	6a 00                	push   $0x0
  800c19:	6a 00                	push   $0x0
  800c1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	e8 01 ff ff ff       	call   800b30 <syscall>
  800c2f:	83 c4 10             	add    $0x10,%esp
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c3a:	6a 00                	push   $0x0
  800c3c:	6a 00                	push   $0x0
  800c3e:	ff 75 10             	pushl  0x10(%ebp)
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c47:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c51:	e8 da fe ff ff       	call   800b30 <syscall>
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5e:	ff 75 18             	pushl  0x18(%ebp)
  800c61:	ff 75 14             	pushl  0x14(%ebp)
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	e8 b4 fe ff ff       	call   800b30 <syscall>
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c90:	ba 01 00 00 00       	mov    $0x1,%edx
  800c95:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9a:	e8 91 fe ff ff       	call   800b30 <syscall>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ca7:	6a 00                	push   $0x0
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbd:	e8 6e fe ff ff       	call   800b30 <syscall>
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	6a 00                	push   $0x0
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	e8 4b fe ff ff       	call   800b30 <syscall>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d03:	e8 28 fe ff ff       	call   800b30 <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d10:	6a 00                	push   $0x0
  800d12:	ff 75 14             	pushl  0x14(%ebp)
  800d15:	ff 75 10             	pushl  0x10(%ebp)
  800d18:	ff 75 0c             	pushl  0xc(%ebp)
  800d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	e8 03 fe ff ff       	call   800b30 <syscall>
}
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	ba 01 00 00 00       	mov    $0x1,%edx
  800d45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4a:	e8 e1 fd ff ff       	call   800b30 <syscall>
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d57:	6a 00                	push   $0x0
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
  800d68:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d6d:	e8 be fd ff ff       	call   800b30 <syscall>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	53                   	push   %ebx
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7e:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d80:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d84:	75 14                	jne    800d9a <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 6c 25 80 00       	push   $0x80256c
  800d8e:	6a 20                	push   $0x20
  800d90:	68 b0 26 80 00       	push   $0x8026b0
  800d95:	e8 de 10 00 00       	call   801e78 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d9a:	89 d8                	mov    %ebx,%eax
  800d9c:	c1 e8 16             	shr    $0x16,%eax
  800d9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800da6:	a8 01                	test   $0x1,%al
  800da8:	74 11                	je     800dbb <pgfault+0x47>
  800daa:	89 d8                	mov    %ebx,%eax
  800dac:	c1 e8 0c             	shr    $0xc,%eax
  800daf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800db6:	f6 c4 08             	test   $0x8,%ah
  800db9:	75 14                	jne    800dcf <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	68 90 25 80 00       	push   $0x802590
  800dc3:	6a 24                	push   $0x24
  800dc5:	68 b0 26 80 00       	push   $0x8026b0
  800dca:	e8 a9 10 00 00       	call   801e78 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	6a 07                	push   $0x7
  800dd4:	68 00 f0 7f 00       	push   $0x7ff000
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 54 fe ff ff       	call   800c34 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	79 12                	jns    800df9 <pgfault+0x85>
  800de7:	50                   	push   %eax
  800de8:	68 b4 25 80 00       	push   $0x8025b4
  800ded:	6a 32                	push   $0x32
  800def:	68 b0 26 80 00       	push   $0x8026b0
  800df4:	e8 7f 10 00 00       	call   801e78 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800df9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	68 00 10 00 00       	push   $0x1000
  800e07:	53                   	push   %ebx
  800e08:	68 00 f0 7f 00       	push   $0x7ff000
  800e0d:	e8 cb fb ff ff       	call   8009dd <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e12:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e19:	53                   	push   %ebx
  800e1a:	6a 00                	push   $0x0
  800e1c:	68 00 f0 7f 00       	push   $0x7ff000
  800e21:	6a 00                	push   $0x0
  800e23:	e8 30 fe ff ff       	call   800c58 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 12                	jns    800e41 <pgfault+0xcd>
  800e2f:	50                   	push   %eax
  800e30:	68 d8 25 80 00       	push   $0x8025d8
  800e35:	6a 3a                	push   $0x3a
  800e37:	68 b0 26 80 00       	push   $0x8026b0
  800e3c:	e8 37 10 00 00       	call   801e78 <_panic>

	return;
}
  800e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e4f:	68 74 0d 80 00       	push   $0x800d74
  800e54:	e8 67 10 00 00       	call   801ec0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e59:	ba 07 00 00 00       	mov    $0x7,%edx
  800e5e:	89 d0                	mov    %edx,%eax
  800e60:	cd 30                	int    $0x30
  800e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e65:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	79 12                	jns    800e80 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e6e:	50                   	push   %eax
  800e6f:	68 bb 26 80 00       	push   $0x8026bb
  800e74:	6a 7b                	push   $0x7b
  800e76:	68 b0 26 80 00       	push   $0x8026b0
  800e7b:	e8 f8 0f 00 00       	call   801e78 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e84:	75 25                	jne    800eab <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e86:	e8 5e fd ff ff       	call   800be9 <sys_getenvid>
  800e8b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e97:	c1 e0 07             	shl    $0x7,%eax
  800e9a:	29 d0                	sub    %edx,%eax
  800e9c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea1:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800ea6:	e9 7b 01 00 00       	jmp    801026 <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800eab:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	c1 e8 16             	shr    $0x16,%eax
  800eb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ebc:	a8 01                	test   $0x1,%al
  800ebe:	0f 84 cd 00 00 00    	je     800f91 <fork+0x14b>
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
  800ec9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed0:	f6 c2 01             	test   $0x1,%dl
  800ed3:	0f 84 b8 00 00 00    	je     800f91 <fork+0x14b>
  800ed9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee0:	f6 c2 04             	test   $0x4,%dl
  800ee3:	0f 84 a8 00 00 00    	je     800f91 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ee9:	89 c6                	mov    %eax,%esi
  800eeb:	c1 e6 0c             	shl    $0xc,%esi
  800eee:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ef4:	0f 84 97 00 00 00    	je     800f91 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800efa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f01:	f6 c2 02             	test   $0x2,%dl
  800f04:	75 0c                	jne    800f12 <fork+0xcc>
  800f06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0d:	f6 c4 08             	test   $0x8,%ah
  800f10:	74 57                	je     800f69 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	68 05 08 00 00       	push   $0x805
  800f1a:	56                   	push   %esi
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	6a 00                	push   $0x0
  800f1f:	e8 34 fd ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f24:	83 c4 20             	add    $0x20,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 12                	jns    800f3d <fork+0xf7>
  800f2b:	50                   	push   %eax
  800f2c:	68 fc 25 80 00       	push   $0x8025fc
  800f31:	6a 55                	push   $0x55
  800f33:	68 b0 26 80 00       	push   $0x8026b0
  800f38:	e8 3b 0f 00 00       	call   801e78 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	68 05 08 00 00       	push   $0x805
  800f45:	56                   	push   %esi
  800f46:	6a 00                	push   $0x0
  800f48:	56                   	push   %esi
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 08 fd ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 3a                	jns    800f91 <fork+0x14b>
  800f57:	50                   	push   %eax
  800f58:	68 fc 25 80 00       	push   $0x8025fc
  800f5d:	6a 58                	push   $0x58
  800f5f:	68 b0 26 80 00       	push   $0x8026b0
  800f64:	e8 0f 0f 00 00       	call   801e78 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	6a 05                	push   $0x5
  800f6e:	56                   	push   %esi
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	6a 00                	push   $0x0
  800f73:	e8 e0 fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	79 12                	jns    800f91 <fork+0x14b>
  800f7f:	50                   	push   %eax
  800f80:	68 fc 25 80 00       	push   $0x8025fc
  800f85:	6a 5c                	push   $0x5c
  800f87:	68 b0 26 80 00       	push   $0x8026b0
  800f8c:	e8 e7 0e 00 00       	call   801e78 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f91:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f97:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f9d:	0f 85 0d ff ff ff    	jne    800eb0 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fa3:	83 ec 04             	sub    $0x4,%esp
  800fa6:	6a 07                	push   $0x7
  800fa8:	68 00 f0 bf ee       	push   $0xeebff000
  800fad:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb0:	e8 7f fc ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 15                	jns    800fd1 <fork+0x18b>
  800fbc:	50                   	push   %eax
  800fbd:	68 20 26 80 00       	push   $0x802620
  800fc2:	68 90 00 00 00       	push   $0x90
  800fc7:	68 b0 26 80 00       	push   $0x8026b0
  800fcc:	e8 a7 0e 00 00       	call   801e78 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fd1:	83 ec 08             	sub    $0x8,%esp
  800fd4:	68 2c 1f 80 00       	push   $0x801f2c
  800fd9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdc:	e8 06 fd ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	79 15                	jns    800ffd <fork+0x1b7>
  800fe8:	50                   	push   %eax
  800fe9:	68 58 26 80 00       	push   $0x802658
  800fee:	68 95 00 00 00       	push   $0x95
  800ff3:	68 b0 26 80 00       	push   $0x8026b0
  800ff8:	e8 7b 0e 00 00       	call   801e78 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	6a 02                	push   $0x2
  801002:	ff 75 e4             	pushl  -0x1c(%ebp)
  801005:	e8 97 fc ff ff       	call   800ca1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 15                	jns    801026 <fork+0x1e0>
  801011:	50                   	push   %eax
  801012:	68 7c 26 80 00       	push   $0x80267c
  801017:	68 a0 00 00 00       	push   $0xa0
  80101c:	68 b0 26 80 00       	push   $0x8026b0
  801021:	e8 52 0e 00 00       	call   801e78 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801029:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <sfork>:

// Challenge!
int
sfork(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801037:	68 d8 26 80 00       	push   $0x8026d8
  80103c:	68 ad 00 00 00       	push   $0xad
  801041:	68 b0 26 80 00       	push   $0x8026b0
  801046:	e8 2d 0e 00 00       	call   801e78 <_panic>
	...

0080104c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	8b 7d 08             	mov    0x8(%ebp),%edi
  801058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80105b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	57                   	push   %edi
  801061:	68 ee 26 80 00       	push   $0x8026ee
  801066:	e8 91 f1 ff ff       	call   8001fc <cprintf>
	int r;
	if (pg != NULL) {
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 db                	test   %ebx,%ebx
  801070:	74 28                	je     80109a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	68 fe 26 80 00       	push   $0x8026fe
  80107a:	e8 7d f1 ff ff       	call   8001fc <cprintf>
		r = sys_ipc_recv(pg);
  80107f:	89 1c 24             	mov    %ebx,(%esp)
  801082:	e8 a8 fc ff ff       	call   800d2f <sys_ipc_recv>
  801087:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801089:	c7 04 24 05 27 80 00 	movl   $0x802705,(%esp)
  801090:	e8 67 f1 ff ff       	call   8001fc <cprintf>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	eb 12                	jmp    8010ac <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	68 00 00 c0 ee       	push   $0xeec00000
  8010a2:	e8 88 fc ff ff       	call   800d2f <sys_ipc_recv>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010ac:	85 db                	test   %ebx,%ebx
  8010ae:	75 26                	jne    8010d6 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	74 0a                	je     8010be <ipc_recv+0x72>
  8010b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b9:	8b 40 74             	mov    0x74(%eax),%eax
  8010bc:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010be:	85 f6                	test   %esi,%esi
  8010c0:	74 0a                	je     8010cc <ipc_recv+0x80>
  8010c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c7:	8b 40 78             	mov    0x78(%eax),%eax
  8010ca:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  8010cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d1:	8b 58 70             	mov    0x70(%eax),%ebx
  8010d4:	eb 14                	jmp    8010ea <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8010d6:	85 ff                	test   %edi,%edi
  8010d8:	74 06                	je     8010e0 <ipc_recv+0x94>
  8010da:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  8010e0:	85 f6                	test   %esi,%esi
  8010e2:	74 06                	je     8010ea <ipc_recv+0x9e>
  8010e4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801100:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801103:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801106:	85 db                	test   %ebx,%ebx
  801108:	75 25                	jne    80112f <ipc_send+0x3b>
  80110a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80110f:	eb 1e                	jmp    80112f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801111:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801114:	75 07                	jne    80111d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801116:	e8 f2 fa ff ff       	call   800c0d <sys_yield>
  80111b:	eb 12                	jmp    80112f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80111d:	50                   	push   %eax
  80111e:	68 0b 27 80 00       	push   $0x80270b
  801123:	6a 45                	push   $0x45
  801125:	68 1e 27 80 00       	push   $0x80271e
  80112a:	e8 49 0d 00 00       	call   801e78 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	57                   	push   %edi
  801132:	ff 75 08             	pushl  0x8(%ebp)
  801135:	e8 d0 fb ff ff       	call   800d0a <sys_ipc_try_send>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	75 d0                	jne    801111 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801150:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801156:	74 22                	je     80117a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801158:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80115d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 e2 07             	shl    $0x7,%edx
  801169:	29 ca                	sub    %ecx,%edx
  80116b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801171:	8b 52 50             	mov    0x50(%edx),%edx
  801174:	39 da                	cmp    %ebx,%edx
  801176:	75 1d                	jne    801195 <ipc_find_env+0x4c>
  801178:	eb 05                	jmp    80117f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80117f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801186:	c1 e0 07             	shl    $0x7,%eax
  801189:	29 d0                	sub    %edx,%eax
  80118b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801190:	8b 40 40             	mov    0x40(%eax),%eax
  801193:	eb 0c                	jmp    8011a1 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801195:	40                   	inc    %eax
  801196:	3d 00 04 00 00       	cmp    $0x400,%eax
  80119b:	75 c0                	jne    80115d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80119d:	66 b8 00 00          	mov    $0x0,%ax
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8011af:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b7:	ff 75 08             	pushl  0x8(%ebp)
  8011ba:	e8 e5 ff ff ff       	call   8011a4 <fd2num>
  8011bf:	83 c4 04             	add    $0x4,%esp
  8011c2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011c7:	c1 e0 0c             	shl    $0xc,%eax
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011d8:	a8 01                	test   $0x1,%al
  8011da:	74 34                	je     801210 <fd_alloc+0x44>
  8011dc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011e1:	a8 01                	test   $0x1,%al
  8011e3:	74 32                	je     801217 <fd_alloc+0x4b>
  8011e5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011ea:	89 c1                	mov    %eax,%ecx
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 ea 16             	shr    $0x16,%edx
  8011f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f8:	f6 c2 01             	test   $0x1,%dl
  8011fb:	74 1f                	je     80121c <fd_alloc+0x50>
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	c1 ea 0c             	shr    $0xc,%edx
  801202:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801209:	f6 c2 01             	test   $0x1,%dl
  80120c:	75 17                	jne    801225 <fd_alloc+0x59>
  80120e:	eb 0c                	jmp    80121c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801210:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801215:	eb 05                	jmp    80121c <fd_alloc+0x50>
  801217:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80121c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 17                	jmp    80123c <fd_alloc+0x70>
  801225:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80122a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122f:	75 b9                	jne    8011ea <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801237:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123c:	5b                   	pop    %ebx
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801245:	83 f8 1f             	cmp    $0x1f,%eax
  801248:	77 36                	ja     801280 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80124f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801252:	89 c2                	mov    %eax,%edx
  801254:	c1 ea 16             	shr    $0x16,%edx
  801257:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125e:	f6 c2 01             	test   $0x1,%dl
  801261:	74 24                	je     801287 <fd_lookup+0x48>
  801263:	89 c2                	mov    %eax,%edx
  801265:	c1 ea 0c             	shr    $0xc,%edx
  801268:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 1a                	je     80128e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801274:	8b 55 0c             	mov    0xc(%ebp),%edx
  801277:	89 02                	mov    %eax,(%edx)
	return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb 13                	jmp    801293 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801285:	eb 0c                	jmp    801293 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb 05                	jmp    801293 <fd_lookup+0x54>
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	53                   	push   %ebx
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012a2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012a8:	74 0d                	je     8012b7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012af:	eb 14                	jmp    8012c5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012b1:	39 0a                	cmp    %ecx,(%edx)
  8012b3:	75 10                	jne    8012c5 <dev_lookup+0x30>
  8012b5:	eb 05                	jmp    8012bc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012bc:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	eb 31                	jmp    8012f6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c5:	40                   	inc    %eax
  8012c6:	8b 14 85 a4 27 80 00 	mov    0x8027a4(,%eax,4),%edx
  8012cd:	85 d2                	test   %edx,%edx
  8012cf:	75 e0                	jne    8012b1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	51                   	push   %ecx
  8012dd:	50                   	push   %eax
  8012de:	68 28 27 80 00       	push   $0x802728
  8012e3:	e8 14 ef ff ff       	call   8001fc <cprintf>
	*dev = 0;
  8012e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 20             	sub    $0x20,%esp
  801303:	8b 75 08             	mov    0x8(%ebp),%esi
  801306:	8a 45 0c             	mov    0xc(%ebp),%al
  801309:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130c:	56                   	push   %esi
  80130d:	e8 92 fe ff ff       	call   8011a4 <fd2num>
  801312:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801315:	89 14 24             	mov    %edx,(%esp)
  801318:	50                   	push   %eax
  801319:	e8 21 ff ff ff       	call   80123f <fd_lookup>
  80131e:	89 c3                	mov    %eax,%ebx
  801320:	83 c4 08             	add    $0x8,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 05                	js     80132c <fd_close+0x31>
	    || fd != fd2)
  801327:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80132a:	74 0d                	je     801339 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80132c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801330:	75 48                	jne    80137a <fd_close+0x7f>
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
  801337:	eb 41                	jmp    80137a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 36                	pushl  (%esi)
  801342:	e8 4e ff ff ff       	call   801295 <dev_lookup>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 1c                	js     80136c <fd_close+0x71>
		if (dev->dev_close)
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	8b 40 10             	mov    0x10(%eax),%eax
  801356:	85 c0                	test   %eax,%eax
  801358:	74 0d                	je     801367 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	56                   	push   %esi
  80135e:	ff d0                	call   *%eax
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	eb 05                	jmp    80136c <fd_close+0x71>
		else
			r = 0;
  801367:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	56                   	push   %esi
  801370:	6a 00                	push   $0x0
  801372:	e8 07 f9 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  801377:	83 c4 10             	add    $0x10,%esp
}
  80137a:	89 d8                	mov    %ebx,%eax
  80137c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 aa fe ff ff       	call   80123f <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 10                	js     8013ac <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	6a 01                	push   $0x1
  8013a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a4:	e8 52 ff ff ff       	call   8012fb <fd_close>
  8013a9:	83 c4 10             	add    $0x10,%esp
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <close_all>:

void
close_all(void)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	53                   	push   %ebx
  8013be:	e8 c0 ff ff ff       	call   801383 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c3:	43                   	inc    %ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	83 fb 20             	cmp    $0x20,%ebx
  8013ca:	75 ee                	jne    8013ba <close_all+0xc>
		close(i);
}
  8013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	57                   	push   %edi
  8013d5:	56                   	push   %esi
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 2c             	sub    $0x2c,%esp
  8013da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 56 fe ff ff       	call   80123f <fd_lookup>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	0f 88 c0 00 00 00    	js     8014b6 <dup+0xe5>
		return r;
	close(newfdnum);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	57                   	push   %edi
  8013fa:	e8 84 ff ff ff       	call   801383 <close>

	newfd = INDEX2FD(newfdnum);
  8013ff:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801405:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801408:	83 c4 04             	add    $0x4,%esp
  80140b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140e:	e8 a1 fd ff ff       	call   8011b4 <fd2data>
  801413:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801415:	89 34 24             	mov    %esi,(%esp)
  801418:	e8 97 fd ff ff       	call   8011b4 <fd2data>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801423:	89 d8                	mov    %ebx,%eax
  801425:	c1 e8 16             	shr    $0x16,%eax
  801428:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142f:	a8 01                	test   $0x1,%al
  801431:	74 37                	je     80146a <dup+0x99>
  801433:	89 d8                	mov    %ebx,%eax
  801435:	c1 e8 0c             	shr    $0xc,%eax
  801438:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 26                	je     80146a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801444:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	25 07 0e 00 00       	and    $0xe07,%eax
  801453:	50                   	push   %eax
  801454:	ff 75 d4             	pushl  -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	53                   	push   %ebx
  80145a:	6a 00                	push   $0x0
  80145c:	e8 f7 f7 ff ff       	call   800c58 <sys_page_map>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	83 c4 20             	add    $0x20,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 2d                	js     801497 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	c1 ea 0c             	shr    $0xc,%edx
  801472:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801482:	52                   	push   %edx
  801483:	56                   	push   %esi
  801484:	6a 00                	push   $0x0
  801486:	50                   	push   %eax
  801487:	6a 00                	push   $0x0
  801489:	e8 ca f7 ff ff       	call   800c58 <sys_page_map>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	83 c4 20             	add    $0x20,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	79 1d                	jns    8014b4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	56                   	push   %esi
  80149b:	6a 00                	push   $0x0
  80149d:	e8 dc f7 ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 cf f7 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb 02                	jmp    8014b6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014b4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 14             	sub    $0x14,%esp
  8014c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	53                   	push   %ebx
  8014cf:	e8 6b fd ff ff       	call   80123f <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 67                	js     801542 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e5:	ff 30                	pushl  (%eax)
  8014e7:	e8 a9 fd ff ff       	call   801295 <dev_lookup>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 4f                	js     801542 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f6:	8b 50 08             	mov    0x8(%eax),%edx
  8014f9:	83 e2 03             	and    $0x3,%edx
  8014fc:	83 fa 01             	cmp    $0x1,%edx
  8014ff:	75 21                	jne    801522 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801501:	a1 08 40 80 00       	mov    0x804008,%eax
  801506:	8b 40 48             	mov    0x48(%eax),%eax
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	53                   	push   %ebx
  80150d:	50                   	push   %eax
  80150e:	68 69 27 80 00       	push   $0x802769
  801513:	e8 e4 ec ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801520:	eb 20                	jmp    801542 <read+0x82>
	}
	if (!dev->dev_read)
  801522:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801525:	8b 52 08             	mov    0x8(%edx),%edx
  801528:	85 d2                	test   %edx,%edx
  80152a:	74 11                	je     80153d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	ff 75 10             	pushl  0x10(%ebp)
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	50                   	push   %eax
  801536:	ff d2                	call   *%edx
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb 05                	jmp    801542 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	57                   	push   %edi
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 7d 08             	mov    0x8(%ebp),%edi
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801556:	85 f6                	test   %esi,%esi
  801558:	74 31                	je     80158b <readn+0x44>
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	89 f2                	mov    %esi,%edx
  801569:	29 c2                	sub    %eax,%edx
  80156b:	52                   	push   %edx
  80156c:	03 45 0c             	add    0xc(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	57                   	push   %edi
  801571:	e8 4a ff ff ff       	call   8014c0 <read>
		if (m < 0)
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 17                	js     801594 <readn+0x4d>
			return m;
		if (m == 0)
  80157d:	85 c0                	test   %eax,%eax
  80157f:	74 11                	je     801592 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801581:	01 c3                	add    %eax,%ebx
  801583:	89 d8                	mov    %ebx,%eax
  801585:	39 f3                	cmp    %esi,%ebx
  801587:	72 db                	jb     801564 <readn+0x1d>
  801589:	eb 09                	jmp    801594 <readn+0x4d>
  80158b:	b8 00 00 00 00       	mov    $0x0,%eax
  801590:	eb 02                	jmp    801594 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801592:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 14             	sub    $0x14,%esp
  8015a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	53                   	push   %ebx
  8015ab:	e8 8f fc ff ff       	call   80123f <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 62                	js     801619 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 cd fc ff ff       	call   801295 <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 4a                	js     801619 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d6:	75 21                	jne    8015f9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8015dd:	8b 40 48             	mov    0x48(%eax),%eax
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	50                   	push   %eax
  8015e5:	68 85 27 80 00       	push   $0x802785
  8015ea:	e8 0d ec ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f7:	eb 20                	jmp    801619 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ff:	85 d2                	test   %edx,%edx
  801601:	74 11                	je     801614 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	ff 75 10             	pushl  0x10(%ebp)
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	50                   	push   %eax
  80160d:	ff d2                	call   *%edx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb 05                	jmp    801619 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801614:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <seek>:

int
seek(int fdnum, off_t offset)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801624:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 0f fc ff ff       	call   80123f <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 0e                	js     801645 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801637:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 e4 fb ff ff       	call   80123f <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 5f                	js     8016c1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 22 fc ff ff       	call   801295 <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 47                	js     8016c1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801681:	75 21                	jne    8016a4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801683:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 48 27 80 00       	push   $0x802748
  801695:	e8 62 eb ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a2:	eb 1d                	jmp    8016c1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a7:	8b 52 18             	mov    0x18(%edx),%edx
  8016aa:	85 d2                	test   %edx,%edx
  8016ac:	74 0e                	je     8016bc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	ff d2                	call   *%edx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	eb 05                	jmp    8016c1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 14             	sub    $0x14,%esp
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 63 fb ff ff       	call   80123f <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 52                	js     801735 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ed:	ff 30                	pushl  (%eax)
  8016ef:	e8 a1 fb ff ff       	call   801295 <dev_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 3a                	js     801735 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801702:	74 2c                	je     801730 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801704:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801707:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170e:	00 00 00 
	stat->st_isdir = 0;
  801711:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801718:	00 00 00 
	stat->st_dev = dev;
  80171b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	53                   	push   %ebx
  801725:	ff 75 f0             	pushl  -0x10(%ebp)
  801728:	ff 50 14             	call   *0x14(%eax)
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 05                	jmp    801735 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801730:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	6a 00                	push   $0x0
  801744:	ff 75 08             	pushl  0x8(%ebp)
  801747:	e8 8b 01 00 00       	call   8018d7 <open>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 1b                	js     801770 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	50                   	push   %eax
  80175c:	e8 65 ff ff ff       	call   8016c6 <fstat>
  801761:	89 c6                	mov    %eax,%esi
	close(fd);
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 18 fc ff ff       	call   801383 <close>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	89 f3                	mov    %esi,%ebx
}
  801770:	89 d8                	mov    %ebx,%eax
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	c9                   	leave  
  801778:	c3                   	ret    
  801779:	00 00                	add    %al,(%eax)
	...

0080177c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	89 c3                	mov    %eax,%ebx
  801783:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801785:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80178c:	75 12                	jne    8017a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	6a 01                	push   $0x1
  801793:	e8 b1 f9 ff ff       	call   801149 <ipc_find_env>
  801798:	a3 00 40 80 00       	mov    %eax,0x804000
  80179d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 50 80 00       	push   $0x805000
  8017a7:	53                   	push   %ebx
  8017a8:	ff 35 00 40 80 00    	pushl  0x804000
  8017ae:	e8 41 f9 ff ff       	call   8010f4 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017b3:	83 c4 0c             	add    $0xc,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	56                   	push   %esi
  8017b9:	6a 00                	push   $0x0
  8017bb:	e8 8c f8 ff ff       	call   80104c <ipc_recv>
}
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e6:	e8 91 ff ff ff       	call   80177c <fsipc>
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 39                	js     801828 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	68 05 27 80 00       	push   $0x802705
  8017f7:	e8 00 ea ff ff       	call   8001fc <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fc:	83 c4 08             	add    $0x8,%esp
  8017ff:	68 00 50 80 00       	push   $0x805000
  801804:	53                   	push   %ebx
  801805:	e8 a8 ef ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180a:	a1 80 50 80 00       	mov    0x805080,%eax
  80180f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801815:	a1 84 50 80 00       	mov    0x805084,%eax
  80181a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	8b 40 0c             	mov    0xc(%eax),%eax
  801839:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 06 00 00 00       	mov    $0x6,%eax
  801848:	e8 2f ff ff ff       	call   80177c <fsipc>
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	8b 40 0c             	mov    0xc(%eax),%eax
  80185d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801862:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 03 00 00 00       	mov    $0x3,%eax
  801872:	e8 05 ff ff ff       	call   80177c <fsipc>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 51                	js     8018ce <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80187d:	39 c6                	cmp    %eax,%esi
  80187f:	73 19                	jae    80189a <devfile_read+0x4b>
  801881:	68 b4 27 80 00       	push   $0x8027b4
  801886:	68 bb 27 80 00       	push   $0x8027bb
  80188b:	68 80 00 00 00       	push   $0x80
  801890:	68 d0 27 80 00       	push   $0x8027d0
  801895:	e8 de 05 00 00       	call   801e78 <_panic>
	assert(r <= PGSIZE);
  80189a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80189f:	7e 19                	jle    8018ba <devfile_read+0x6b>
  8018a1:	68 db 27 80 00       	push   $0x8027db
  8018a6:	68 bb 27 80 00       	push   $0x8027bb
  8018ab:	68 81 00 00 00       	push   $0x81
  8018b0:	68 d0 27 80 00       	push   $0x8027d0
  8018b5:	e8 be 05 00 00       	call   801e78 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	50                   	push   %eax
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	e8 a8 f0 ff ff       	call   800973 <memmove>
	return r;
  8018cb:	83 c4 10             	add    $0x10,%esp
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 1c             	sub    $0x1c,%esp
  8018df:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e2:	56                   	push   %esi
  8018e3:	e8 78 ee ff ff       	call   800760 <strlen>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f0:	7f 72                	jg     801964 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	e8 ce f8 ff ff       	call   8011cc <fd_alloc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	78 62                	js     801969 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	56                   	push   %esi
  80190b:	68 00 50 80 00       	push   $0x805000
  801910:	e8 9d ee ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801920:	b8 01 00 00 00       	mov    $0x1,%eax
  801925:	e8 52 fe ff ff       	call   80177c <fsipc>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 12                	jns    801945 <open+0x6e>
		fd_close(fd, 0);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	6a 00                	push   $0x0
  801938:	ff 75 f4             	pushl  -0xc(%ebp)
  80193b:	e8 bb f9 ff ff       	call   8012fb <fd_close>
		return r;
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb 24                	jmp    801969 <open+0x92>
	}


	cprintf("OPEN\n");
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	68 e7 27 80 00       	push   $0x8027e7
  80194d:	e8 aa e8 ff ff       	call   8001fc <cprintf>

	return fd2num(fd);
  801952:	83 c4 04             	add    $0x4,%esp
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 47 f8 ff ff       	call   8011a4 <fd2num>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 05                	jmp    801969 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801964:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801969:	89 d8                	mov    %ebx,%eax
  80196b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	c9                   	leave  
  801971:	c3                   	ret    
	...

00801974 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	ff 75 08             	pushl  0x8(%ebp)
  801982:	e8 2d f8 ff ff       	call   8011b4 <fd2data>
  801987:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801989:	83 c4 08             	add    $0x8,%esp
  80198c:	68 ed 27 80 00       	push   $0x8027ed
  801991:	56                   	push   %esi
  801992:	e8 1b ee ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801997:	8b 43 04             	mov    0x4(%ebx),%eax
  80199a:	2b 03                	sub    (%ebx),%eax
  80199c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019a2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019a9:	00 00 00 
	stat->st_dev = &devpipe;
  8019ac:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019b3:	30 80 00 
	return 0;
}
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019cc:	53                   	push   %ebx
  8019cd:	6a 00                	push   $0x0
  8019cf:	e8 aa f2 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019d4:	89 1c 24             	mov    %ebx,(%esp)
  8019d7:	e8 d8 f7 ff ff       	call   8011b4 <fd2data>
  8019dc:	83 c4 08             	add    $0x8,%esp
  8019df:	50                   	push   %eax
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 97 f2 ff ff       	call   800c7e <sys_page_unmap>
}
  8019e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	57                   	push   %edi
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 1c             	sub    $0x1c,%esp
  8019f5:	89 c7                	mov    %eax,%edi
  8019f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8019ff:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	57                   	push   %edi
  801a06:	e8 49 05 00 00       	call   801f54 <pageref>
  801a0b:	89 c6                	mov    %eax,%esi
  801a0d:	83 c4 04             	add    $0x4,%esp
  801a10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a13:	e8 3c 05 00 00       	call   801f54 <pageref>
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	39 c6                	cmp    %eax,%esi
  801a1d:	0f 94 c0             	sete   %al
  801a20:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a23:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a2c:	39 cb                	cmp    %ecx,%ebx
  801a2e:	75 08                	jne    801a38 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5f                   	pop    %edi
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a38:	83 f8 01             	cmp    $0x1,%eax
  801a3b:	75 bd                	jne    8019fa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3d:	8b 42 58             	mov    0x58(%edx),%eax
  801a40:	6a 01                	push   $0x1
  801a42:	50                   	push   %eax
  801a43:	53                   	push   %ebx
  801a44:	68 f4 27 80 00       	push   $0x8027f4
  801a49:	e8 ae e7 ff ff       	call   8001fc <cprintf>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	eb a7                	jmp    8019fa <_pipeisclosed+0xe>

00801a53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 28             	sub    $0x28,%esp
  801a5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5f:	56                   	push   %esi
  801a60:	e8 4f f7 ff ff       	call   8011b4 <fd2data>
  801a65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a6e:	75 4a                	jne    801aba <devpipe_write+0x67>
  801a70:	bf 00 00 00 00       	mov    $0x0,%edi
  801a75:	eb 56                	jmp    801acd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a77:	89 da                	mov    %ebx,%edx
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	e8 6c ff ff ff       	call   8019ec <_pipeisclosed>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	75 4d                	jne    801ad1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a84:	e8 84 f1 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a89:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8c:	8b 13                	mov    (%ebx),%edx
  801a8e:	83 c2 20             	add    $0x20,%edx
  801a91:	39 d0                	cmp    %edx,%eax
  801a93:	73 e2                	jae    801a77 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a9d:	79 05                	jns    801aa4 <devpipe_write+0x51>
  801a9f:	4a                   	dec    %edx
  801aa0:	83 ca e0             	or     $0xffffffe0,%edx
  801aa3:	42                   	inc    %edx
  801aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801aaa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aae:	40                   	inc    %eax
  801aaf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab2:	47                   	inc    %edi
  801ab3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ab6:	77 07                	ja     801abf <devpipe_write+0x6c>
  801ab8:	eb 13                	jmp    801acd <devpipe_write+0x7a>
  801aba:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abf:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac2:	8b 13                	mov    (%ebx),%edx
  801ac4:	83 c2 20             	add    $0x20,%edx
  801ac7:	39 d0                	cmp    %edx,%eax
  801ac9:	73 ac                	jae    801a77 <devpipe_write+0x24>
  801acb:	eb c8                	jmp    801a95 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acd:	89 f8                	mov    %edi,%eax
  801acf:	eb 05                	jmp    801ad6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aea:	57                   	push   %edi
  801aeb:	e8 c4 f6 ff ff       	call   8011b4 <fd2data>
  801af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af9:	75 44                	jne    801b3f <devpipe_read+0x61>
  801afb:	be 00 00 00 00       	mov    $0x0,%esi
  801b00:	eb 4f                	jmp    801b51 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b02:	89 f0                	mov    %esi,%eax
  801b04:	eb 54                	jmp    801b5a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b06:	89 da                	mov    %ebx,%edx
  801b08:	89 f8                	mov    %edi,%eax
  801b0a:	e8 dd fe ff ff       	call   8019ec <_pipeisclosed>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	75 42                	jne    801b55 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b13:	e8 f5 f0 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b18:	8b 03                	mov    (%ebx),%eax
  801b1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b1d:	74 e7                	je     801b06 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b24:	79 05                	jns    801b2b <devpipe_read+0x4d>
  801b26:	48                   	dec    %eax
  801b27:	83 c8 e0             	or     $0xffffffe0,%eax
  801b2a:	40                   	inc    %eax
  801b2b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b32:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b35:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b37:	46                   	inc    %esi
  801b38:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b3b:	77 07                	ja     801b44 <devpipe_read+0x66>
  801b3d:	eb 12                	jmp    801b51 <devpipe_read+0x73>
  801b3f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b44:	8b 03                	mov    (%ebx),%eax
  801b46:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b49:	75 d4                	jne    801b1f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4b:	85 f6                	test   %esi,%esi
  801b4d:	75 b3                	jne    801b02 <devpipe_read+0x24>
  801b4f:	eb b5                	jmp    801b06 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b51:	89 f0                	mov    %esi,%eax
  801b53:	eb 05                	jmp    801b5a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 28             	sub    $0x28,%esp
  801b6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	e8 55 f6 ff ff       	call   8011cc <fd_alloc>
  801b77:	89 c3                	mov    %eax,%ebx
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	0f 88 24 01 00 00    	js     801ca8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 9e f0 ff ff       	call   800c34 <sys_page_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 05 01 00 00    	js     801ca8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ba9:	50                   	push   %eax
  801baa:	e8 1d f6 ff ff       	call   8011cc <fd_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 dc 00 00 00    	js     801c98 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	68 07 04 00 00       	push   $0x407
  801bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc7:	6a 00                	push   $0x0
  801bc9:	e8 66 f0 ff ff       	call   800c34 <sys_page_alloc>
  801bce:	89 c3                	mov    %eax,%ebx
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 bd 00 00 00    	js     801c98 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be1:	e8 ce f5 ff ff       	call   8011b4 <fd2data>
  801be6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 c4 0c             	add    $0xc,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	50                   	push   %eax
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 3c f0 ff ff       	call   800c34 <sys_page_alloc>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 83 00 00 00    	js     801c88 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0b:	e8 a4 f5 ff ff       	call   8011b4 <fd2data>
  801c10:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c17:	50                   	push   %eax
  801c18:	6a 00                	push   $0x0
  801c1a:	56                   	push   %esi
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 36 f0 ff ff       	call   800c58 <sys_page_map>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	78 4f                	js     801c7a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c34:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c49:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5b:	e8 44 f5 ff ff       	call   8011a4 <fd2num>
  801c60:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c62:	83 c4 04             	add    $0x4,%esp
  801c65:	ff 75 e0             	pushl  -0x20(%ebp)
  801c68:	e8 37 f5 ff ff       	call   8011a4 <fd2num>
  801c6d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c78:	eb 2e                	jmp    801ca8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	56                   	push   %esi
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 f9 ef ff ff       	call   800c7e <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 e9 ef ff ff       	call   800c7e <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 d9 ef ff ff       	call   800c7e <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	ff 75 08             	pushl  0x8(%ebp)
  801cbf:	e8 7b f5 ff ff       	call   80123f <fd_lookup>
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 18                	js     801ce3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 de f4 ff ff       	call   8011b4 <fd2data>
	return _pipeisclosed(fd, p);
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	e8 0c fd ff ff       	call   8019ec <_pipeisclosed>
  801ce0:	83 c4 10             	add    $0x10,%esp
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    
  801ce5:	00 00                	add    %al,(%eax)
	...

00801ce8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf8:	68 0c 28 80 00       	push   $0x80280c
  801cfd:	ff 75 0c             	pushl  0xc(%ebp)
  801d00:	e8 ad ea ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d1c:	74 45                	je     801d63 <devcons_write+0x57>
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d31:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d33:	83 fb 7f             	cmp    $0x7f,%ebx
  801d36:	76 05                	jbe    801d3d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d38:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d3d:	83 ec 04             	sub    $0x4,%esp
  801d40:	53                   	push   %ebx
  801d41:	03 45 0c             	add    0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	57                   	push   %edi
  801d46:	e8 28 ec ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801d4b:	83 c4 08             	add    $0x8,%esp
  801d4e:	53                   	push   %ebx
  801d4f:	57                   	push   %edi
  801d50:	e8 28 ee ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d55:	01 de                	add    %ebx,%esi
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5f:	72 cd                	jb     801d2e <devcons_write+0x22>
  801d61:	eb 05                	jmp    801d68 <devcons_write+0x5c>
  801d63:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	75 07                	jne    801d85 <devcons_read+0x13>
  801d7e:	eb 25                	jmp    801da5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d80:	e8 88 ee ff ff       	call   800c0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d85:	e8 19 ee ff ff       	call   800ba3 <sys_cgetc>
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	74 f2                	je     801d80 <devcons_read+0xe>
  801d8e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 1d                	js     801db1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d94:	83 f8 04             	cmp    $0x4,%eax
  801d97:	74 13                	je     801dac <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9c:	88 10                	mov    %dl,(%eax)
	return 1;
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	eb 0c                	jmp    801db1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
  801daa:	eb 05                	jmp    801db1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dbf:	6a 01                	push   $0x1
  801dc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc4:	50                   	push   %eax
  801dc5:	e8 b3 ed ff ff       	call   800b7d <sys_cputs>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <getchar>:

int
getchar(void)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd5:	6a 01                	push   $0x1
  801dd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 de f6 ff ff       	call   8014c0 <read>
	if (r < 0)
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 0f                	js     801df8 <getchar+0x29>
		return r;
	if (r < 1)
  801de9:	85 c0                	test   %eax,%eax
  801deb:	7e 06                	jle    801df3 <getchar+0x24>
		return -E_EOF;
	return c;
  801ded:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df1:	eb 05                	jmp    801df8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801df3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	ff 75 08             	pushl  0x8(%ebp)
  801e07:	e8 33 f4 ff ff       	call   80123f <fd_lookup>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 11                	js     801e24 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1c:	39 10                	cmp    %edx,(%eax)
  801e1e:	0f 94 c0             	sete   %al
  801e21:	0f b6 c0             	movzbl %al,%eax
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <opencons>:

int
opencons(void)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	e8 97 f3 ff ff       	call   8011cc <fd_alloc>
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 3a                	js     801e76 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	68 07 04 00 00       	push   $0x407
  801e44:	ff 75 f4             	pushl  -0xc(%ebp)
  801e47:	6a 00                	push   $0x0
  801e49:	e8 e6 ed ff ff       	call   800c34 <sys_page_alloc>
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 21                	js     801e76 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e63:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	50                   	push   %eax
  801e6e:	e8 31 f3 ff ff       	call   8011a4 <fd2num>
  801e73:	83 c4 10             	add    $0x10,%esp
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e7d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e80:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e86:	e8 5e ed ff ff       	call   800be9 <sys_getenvid>
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	53                   	push   %ebx
  801e95:	50                   	push   %eax
  801e96:	68 18 28 80 00       	push   $0x802818
  801e9b:	e8 5c e3 ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea0:	83 c4 18             	add    $0x18,%esp
  801ea3:	56                   	push   %esi
  801ea4:	ff 75 10             	pushl  0x10(%ebp)
  801ea7:	e8 ff e2 ff ff       	call   8001ab <vcprintf>
	cprintf("\n");
  801eac:	c7 04 24 eb 27 80 00 	movl   $0x8027eb,(%esp)
  801eb3:	e8 44 e3 ff ff       	call   8001fc <cprintf>
  801eb8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ebb:	cc                   	int3   
  801ebc:	eb fd                	jmp    801ebb <_panic+0x43>
	...

00801ec0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ecd:	75 52                	jne    801f21 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ecf:	83 ec 04             	sub    $0x4,%esp
  801ed2:	6a 07                	push   $0x7
  801ed4:	68 00 f0 bf ee       	push   $0xeebff000
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 54 ed ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) {
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	79 12                	jns    801ef9 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ee7:	50                   	push   %eax
  801ee8:	68 3b 28 80 00       	push   $0x80283b
  801eed:	6a 24                	push   $0x24
  801eef:	68 56 28 80 00       	push   $0x802856
  801ef4:	e8 7f ff ff ff       	call   801e78 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ef9:	83 ec 08             	sub    $0x8,%esp
  801efc:	68 2c 1f 80 00       	push   $0x801f2c
  801f01:	6a 00                	push   $0x0
  801f03:	e8 df ed ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	79 12                	jns    801f21 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f0f:	50                   	push   %eax
  801f10:	68 64 28 80 00       	push   $0x802864
  801f15:	6a 2a                	push   $0x2a
  801f17:	68 56 28 80 00       	push   $0x802856
  801f1c:	e8 57 ff ff ff       	call   801e78 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    
	...

00801f2c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f2c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f2d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f32:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f34:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f37:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f3b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f3e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f42:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f46:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f48:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f4b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f4c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f4f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f50:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f51:	c3                   	ret    
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
