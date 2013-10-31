
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
  80003d:	e8 32 10 00 00       	call   801074 <sfork>
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
  800083:	e8 7d 10 00 00       	call   801105 <ipc_send>
  800088:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008b:	83 ec 04             	sub    $0x4,%esp
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	e8 f5 0f 00 00       	call   801090 <ipc_recv>
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
  8000e4:	e8 1c 10 00 00       	call   801105 <ipc_send>
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
  800156:	e8 67 12 00 00       	call   8013c2 <close_all>
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
  800264:	e8 23 1d 00 00       	call   801f8c <__udivdi3>
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
  8002a0:	e8 03 1e 00 00       	call   8020a8 <__umoddi3>
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
  8004be:	68 b1 27 80 00       	push   $0x8027b1
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
  800b6e:	e8 f9 12 00 00       	call   801e6c <_panic>

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
  800d95:	e8 d2 10 00 00       	call   801e6c <_panic>

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
  800dca:	e8 9d 10 00 00       	call   801e6c <_panic>
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
  800df4:	e8 73 10 00 00       	call   801e6c <_panic>

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
  800e3c:	e8 2b 10 00 00       	call   801e6c <_panic>

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
  800e54:	e8 5b 10 00 00       	call   801eb4 <set_pgfault_handler>
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
  800e74:	6a 7f                	push   $0x7f
  800e76:	68 b0 26 80 00       	push   $0x8026b0
  800e7b:	e8 ec 0f 00 00       	call   801e6c <_panic>
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
  800ea6:	e9 be 01 00 00       	jmp    801069 <fork+0x223>
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
  800ebe:	0f 84 10 01 00 00    	je     800fd4 <fork+0x18e>
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
  800ec9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed0:	f6 c2 01             	test   $0x1,%dl
  800ed3:	0f 84 fb 00 00 00    	je     800fd4 <fork+0x18e>
  800ed9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee0:	f6 c2 04             	test   $0x4,%dl
  800ee3:	0f 84 eb 00 00 00    	je     800fd4 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ee9:	89 c6                	mov    %eax,%esi
  800eeb:	c1 e6 0c             	shl    $0xc,%esi
  800eee:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ef4:	0f 84 da 00 00 00    	je     800fd4 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800efa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f01:	f6 c6 04             	test   $0x4,%dh
  800f04:	74 37                	je     800f3d <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	25 07 0e 00 00       	and    $0xe07,%eax
  800f15:	50                   	push   %eax
  800f16:	56                   	push   %esi
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 38 fd ff ff       	call   800c58 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	0f 89 a9 00 00 00    	jns    800fd4 <fork+0x18e>
  800f2b:	50                   	push   %eax
  800f2c:	68 fc 25 80 00       	push   $0x8025fc
  800f31:	6a 54                	push   $0x54
  800f33:	68 b0 26 80 00       	push   $0x8026b0
  800f38:	e8 2f 0f 00 00       	call   801e6c <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f44:	f6 c2 02             	test   $0x2,%dl
  800f47:	75 0c                	jne    800f55 <fork+0x10f>
  800f49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f50:	f6 c4 08             	test   $0x8,%ah
  800f53:	74 57                	je     800fac <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	68 05 08 00 00       	push   $0x805
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	6a 00                	push   $0x0
  800f62:	e8 f1 fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f67:	83 c4 20             	add    $0x20,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 12                	jns    800f80 <fork+0x13a>
  800f6e:	50                   	push   %eax
  800f6f:	68 fc 25 80 00       	push   $0x8025fc
  800f74:	6a 59                	push   $0x59
  800f76:	68 b0 26 80 00       	push   $0x8026b0
  800f7b:	e8 ec 0e 00 00       	call   801e6c <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	68 05 08 00 00       	push   $0x805
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 c5 fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 3a                	jns    800fd4 <fork+0x18e>
  800f9a:	50                   	push   %eax
  800f9b:	68 fc 25 80 00       	push   $0x8025fc
  800fa0:	6a 5c                	push   $0x5c
  800fa2:	68 b0 26 80 00       	push   $0x8026b0
  800fa7:	e8 c0 0e 00 00       	call   801e6c <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	6a 05                	push   $0x5
  800fb1:	56                   	push   %esi
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 9d fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 12                	jns    800fd4 <fork+0x18e>
  800fc2:	50                   	push   %eax
  800fc3:	68 fc 25 80 00       	push   $0x8025fc
  800fc8:	6a 60                	push   $0x60
  800fca:	68 b0 26 80 00       	push   $0x8026b0
  800fcf:	e8 98 0e 00 00       	call   801e6c <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fd4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fda:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fe0:	0f 85 ca fe ff ff    	jne    800eb0 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	6a 07                	push   $0x7
  800feb:	68 00 f0 bf ee       	push   $0xeebff000
  800ff0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff3:	e8 3c fc ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 15                	jns    801014 <fork+0x1ce>
  800fff:	50                   	push   %eax
  801000:	68 20 26 80 00       	push   $0x802620
  801005:	68 94 00 00 00       	push   $0x94
  80100a:	68 b0 26 80 00       	push   $0x8026b0
  80100f:	e8 58 0e 00 00       	call   801e6c <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	68 20 1f 80 00       	push   $0x801f20
  80101c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101f:	e8 c3 fc ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 15                	jns    801040 <fork+0x1fa>
  80102b:	50                   	push   %eax
  80102c:	68 58 26 80 00       	push   $0x802658
  801031:	68 99 00 00 00       	push   $0x99
  801036:	68 b0 26 80 00       	push   $0x8026b0
  80103b:	e8 2c 0e 00 00       	call   801e6c <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	6a 02                	push   $0x2
  801045:	ff 75 e4             	pushl  -0x1c(%ebp)
  801048:	e8 54 fc ff ff       	call   800ca1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 15                	jns    801069 <fork+0x223>
  801054:	50                   	push   %eax
  801055:	68 7c 26 80 00       	push   $0x80267c
  80105a:	68 a4 00 00 00       	push   $0xa4
  80105f:	68 b0 26 80 00       	push   $0x8026b0
  801064:	e8 03 0e 00 00       	call   801e6c <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <sfork>:

// Challenge!
int
sfork(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80107a:	68 d8 26 80 00       	push   $0x8026d8
  80107f:	68 b1 00 00 00       	push   $0xb1
  801084:	68 b0 26 80 00       	push   $0x8026b0
  801089:	e8 de 0d 00 00       	call   801e6c <_panic>
	...

00801090 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	8b 75 08             	mov    0x8(%ebp),%esi
  801098:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	74 0e                	je     8010b0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	50                   	push   %eax
  8010a6:	e8 84 fc ff ff       	call   800d2f <sys_ipc_recv>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	eb 10                	jmp    8010c0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	68 00 00 c0 ee       	push   $0xeec00000
  8010b8:	e8 72 fc ff ff       	call   800d2f <sys_ipc_recv>
  8010bd:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	75 26                	jne    8010ea <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010c4:	85 f6                	test   %esi,%esi
  8010c6:	74 0a                	je     8010d2 <ipc_recv+0x42>
  8010c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cd:	8b 40 74             	mov    0x74(%eax),%eax
  8010d0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010d2:	85 db                	test   %ebx,%ebx
  8010d4:	74 0a                	je     8010e0 <ipc_recv+0x50>
  8010d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8010db:	8b 40 78             	mov    0x78(%eax),%eax
  8010de:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8010e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e5:	8b 40 70             	mov    0x70(%eax),%eax
  8010e8:	eb 14                	jmp    8010fe <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8010ea:	85 f6                	test   %esi,%esi
  8010ec:	74 06                	je     8010f4 <ipc_recv+0x64>
  8010ee:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8010f4:	85 db                	test   %ebx,%ebx
  8010f6:	74 06                	je     8010fe <ipc_recv+0x6e>
  8010f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8010fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801111:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801114:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801117:	85 db                	test   %ebx,%ebx
  801119:	75 25                	jne    801140 <ipc_send+0x3b>
  80111b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801120:	eb 1e                	jmp    801140 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801122:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801125:	75 07                	jne    80112e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801127:	e8 e1 fa ff ff       	call   800c0d <sys_yield>
  80112c:	eb 12                	jmp    801140 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80112e:	50                   	push   %eax
  80112f:	68 ee 26 80 00       	push   $0x8026ee
  801134:	6a 43                	push   $0x43
  801136:	68 01 27 80 00       	push   $0x802701
  80113b:	e8 2c 0d 00 00       	call   801e6c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	57                   	push   %edi
  801143:	ff 75 08             	pushl  0x8(%ebp)
  801146:	e8 bf fb ff ff       	call   800d0a <sys_ipc_try_send>
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	75 d0                	jne    801122 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801161:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801167:	74 22                	je     80118b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801169:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80116e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 e2 07             	shl    $0x7,%edx
  80117a:	29 ca                	sub    %ecx,%edx
  80117c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801182:	8b 52 50             	mov    0x50(%edx),%edx
  801185:	39 da                	cmp    %ebx,%edx
  801187:	75 1d                	jne    8011a6 <ipc_find_env+0x4c>
  801189:	eb 05                	jmp    801190 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801190:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801197:	c1 e0 07             	shl    $0x7,%eax
  80119a:	29 d0                	sub    %edx,%eax
  80119c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8011a1:	8b 40 40             	mov    0x40(%eax),%eax
  8011a4:	eb 0c                	jmp    8011b2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011a6:	40                   	inc    %eax
  8011a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ac:	75 c0                	jne    80116e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011ae:	66 b8 00 00          	mov    $0x0,%ax
}
  8011b2:	5b                   	pop    %ebx
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    
  8011b5:	00 00                	add    %al,(%eax)
	...

008011b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011be:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011cb:	ff 75 08             	pushl  0x8(%ebp)
  8011ce:	e8 e5 ff ff ff       	call   8011b8 <fd2num>
  8011d3:	83 c4 04             	add    $0x4,%esp
  8011d6:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011db:	c1 e0 0c             	shl    $0xc,%eax
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	53                   	push   %ebx
  8011e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011ec:	a8 01                	test   $0x1,%al
  8011ee:	74 34                	je     801224 <fd_alloc+0x44>
  8011f0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011f5:	a8 01                	test   $0x1,%al
  8011f7:	74 32                	je     80122b <fd_alloc+0x4b>
  8011f9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011fe:	89 c1                	mov    %eax,%ecx
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 16             	shr    $0x16,%edx
  801205:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	74 1f                	je     801230 <fd_alloc+0x50>
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 ea 0c             	shr    $0xc,%edx
  801216:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121d:	f6 c2 01             	test   $0x1,%dl
  801220:	75 17                	jne    801239 <fd_alloc+0x59>
  801222:	eb 0c                	jmp    801230 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801224:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801229:	eb 05                	jmp    801230 <fd_alloc+0x50>
  80122b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801230:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	eb 17                	jmp    801250 <fd_alloc+0x70>
  801239:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801243:	75 b9                	jne    8011fe <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801245:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80124b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801250:	5b                   	pop    %ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801259:	83 f8 1f             	cmp    $0x1f,%eax
  80125c:	77 36                	ja     801294 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801263:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 16             	shr    $0x16,%edx
  80126b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	74 24                	je     80129b <fd_lookup+0x48>
  801277:	89 c2                	mov    %eax,%edx
  801279:	c1 ea 0c             	shr    $0xc,%edx
  80127c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	74 1a                	je     8012a2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801288:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128b:	89 02                	mov    %eax,(%edx)
	return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	eb 13                	jmp    8012a7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801299:	eb 0c                	jmp    8012a7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a0:	eb 05                	jmp    8012a7 <fd_lookup+0x54>
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012b6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012bc:	74 0d                	je     8012cb <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c3:	eb 14                	jmp    8012d9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012c5:	39 0a                	cmp    %ecx,(%edx)
  8012c7:	75 10                	jne    8012d9 <dev_lookup+0x30>
  8012c9:	eb 05                	jmp    8012d0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cb:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012d0:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	eb 31                	jmp    80130a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d9:	40                   	inc    %eax
  8012da:	8b 14 85 88 27 80 00 	mov    0x802788(,%eax,4),%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	75 e0                	jne    8012c5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ea:	8b 40 48             	mov    0x48(%eax),%eax
  8012ed:	83 ec 04             	sub    $0x4,%esp
  8012f0:	51                   	push   %ecx
  8012f1:	50                   	push   %eax
  8012f2:	68 0c 27 80 00       	push   $0x80270c
  8012f7:	e8 00 ef ff ff       	call   8001fc <cprintf>
	*dev = 0;
  8012fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	83 ec 20             	sub    $0x20,%esp
  801317:	8b 75 08             	mov    0x8(%ebp),%esi
  80131a:	8a 45 0c             	mov    0xc(%ebp),%al
  80131d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801320:	56                   	push   %esi
  801321:	e8 92 fe ff ff       	call   8011b8 <fd2num>
  801326:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801329:	89 14 24             	mov    %edx,(%esp)
  80132c:	50                   	push   %eax
  80132d:	e8 21 ff ff ff       	call   801253 <fd_lookup>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 05                	js     801340 <fd_close+0x31>
	    || fd != fd2)
  80133b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80133e:	74 0d                	je     80134d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801340:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801344:	75 48                	jne    80138e <fd_close+0x7f>
  801346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134b:	eb 41                	jmp    80138e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 36                	pushl  (%esi)
  801356:	e8 4e ff ff ff       	call   8012a9 <dev_lookup>
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 1c                	js     801380 <fd_close+0x71>
		if (dev->dev_close)
  801364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801367:	8b 40 10             	mov    0x10(%eax),%eax
  80136a:	85 c0                	test   %eax,%eax
  80136c:	74 0d                	je     80137b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	56                   	push   %esi
  801372:	ff d0                	call   *%eax
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	eb 05                	jmp    801380 <fd_close+0x71>
		else
			r = 0;
  80137b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	56                   	push   %esi
  801384:	6a 00                	push   $0x0
  801386:	e8 f3 f8 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  80138b:	83 c4 10             	add    $0x10,%esp
}
  80138e:	89 d8                	mov    %ebx,%eax
  801390:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 aa fe ff ff       	call   801253 <fd_lookup>
  8013a9:	83 c4 08             	add    $0x8,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 10                	js     8013c0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	6a 01                	push   $0x1
  8013b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b8:	e8 52 ff ff ff       	call   80130f <fd_close>
  8013bd:	83 c4 10             	add    $0x10,%esp
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <close_all>:

void
close_all(void)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	53                   	push   %ebx
  8013d2:	e8 c0 ff ff ff       	call   801397 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d7:	43                   	inc    %ebx
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	83 fb 20             	cmp    $0x20,%ebx
  8013de:	75 ee                	jne    8013ce <close_all+0xc>
		close(i);
}
  8013e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	57                   	push   %edi
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 2c             	sub    $0x2c,%esp
  8013ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f4:	50                   	push   %eax
  8013f5:	ff 75 08             	pushl  0x8(%ebp)
  8013f8:	e8 56 fe ff ff       	call   801253 <fd_lookup>
  8013fd:	89 c3                	mov    %eax,%ebx
  8013ff:	83 c4 08             	add    $0x8,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	0f 88 c0 00 00 00    	js     8014ca <dup+0xe5>
		return r;
	close(newfdnum);
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	57                   	push   %edi
  80140e:	e8 84 ff ff ff       	call   801397 <close>

	newfd = INDEX2FD(newfdnum);
  801413:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801419:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80141c:	83 c4 04             	add    $0x4,%esp
  80141f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801422:	e8 a1 fd ff ff       	call   8011c8 <fd2data>
  801427:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801429:	89 34 24             	mov    %esi,(%esp)
  80142c:	e8 97 fd ff ff       	call   8011c8 <fd2data>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801437:	89 d8                	mov    %ebx,%eax
  801439:	c1 e8 16             	shr    $0x16,%eax
  80143c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801443:	a8 01                	test   $0x1,%al
  801445:	74 37                	je     80147e <dup+0x99>
  801447:	89 d8                	mov    %ebx,%eax
  801449:	c1 e8 0c             	shr    $0xc,%eax
  80144c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801453:	f6 c2 01             	test   $0x1,%dl
  801456:	74 26                	je     80147e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801458:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	25 07 0e 00 00       	and    $0xe07,%eax
  801467:	50                   	push   %eax
  801468:	ff 75 d4             	pushl  -0x2c(%ebp)
  80146b:	6a 00                	push   $0x0
  80146d:	53                   	push   %ebx
  80146e:	6a 00                	push   $0x0
  801470:	e8 e3 f7 ff ff       	call   800c58 <sys_page_map>
  801475:	89 c3                	mov    %eax,%ebx
  801477:	83 c4 20             	add    $0x20,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 2d                	js     8014ab <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801481:	89 c2                	mov    %eax,%edx
  801483:	c1 ea 0c             	shr    $0xc,%edx
  801486:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801496:	52                   	push   %edx
  801497:	56                   	push   %esi
  801498:	6a 00                	push   $0x0
  80149a:	50                   	push   %eax
  80149b:	6a 00                	push   $0x0
  80149d:	e8 b6 f7 ff ff       	call   800c58 <sys_page_map>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	83 c4 20             	add    $0x20,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	79 1d                	jns    8014c8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	56                   	push   %esi
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 c8 f7 ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b6:	83 c4 08             	add    $0x8,%esp
  8014b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014bc:	6a 00                	push   $0x0
  8014be:	e8 bb f7 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	eb 02                	jmp    8014ca <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014c8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ca:	89 d8                	mov    %ebx,%eax
  8014cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cf:	5b                   	pop    %ebx
  8014d0:	5e                   	pop    %esi
  8014d1:	5f                   	pop    %edi
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	53                   	push   %ebx
  8014d8:	83 ec 14             	sub    $0x14,%esp
  8014db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	53                   	push   %ebx
  8014e3:	e8 6b fd ff ff       	call   801253 <fd_lookup>
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 67                	js     801556 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f9:	ff 30                	pushl  (%eax)
  8014fb:	e8 a9 fd ff ff       	call   8012a9 <dev_lookup>
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 4f                	js     801556 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	8b 50 08             	mov    0x8(%eax),%edx
  80150d:	83 e2 03             	and    $0x3,%edx
  801510:	83 fa 01             	cmp    $0x1,%edx
  801513:	75 21                	jne    801536 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801515:	a1 08 40 80 00       	mov    0x804008,%eax
  80151a:	8b 40 48             	mov    0x48(%eax),%eax
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	53                   	push   %ebx
  801521:	50                   	push   %eax
  801522:	68 4d 27 80 00       	push   $0x80274d
  801527:	e8 d0 ec ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801534:	eb 20                	jmp    801556 <read+0x82>
	}
	if (!dev->dev_read)
  801536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801539:	8b 52 08             	mov    0x8(%edx),%edx
  80153c:	85 d2                	test   %edx,%edx
  80153e:	74 11                	je     801551 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	ff 75 10             	pushl  0x10(%ebp)
  801546:	ff 75 0c             	pushl  0xc(%ebp)
  801549:	50                   	push   %eax
  80154a:	ff d2                	call   *%edx
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	eb 05                	jmp    801556 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801551:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	8b 7d 08             	mov    0x8(%ebp),%edi
  801567:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156a:	85 f6                	test   %esi,%esi
  80156c:	74 31                	je     80159f <readn+0x44>
  80156e:	b8 00 00 00 00       	mov    $0x0,%eax
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801578:	83 ec 04             	sub    $0x4,%esp
  80157b:	89 f2                	mov    %esi,%edx
  80157d:	29 c2                	sub    %eax,%edx
  80157f:	52                   	push   %edx
  801580:	03 45 0c             	add    0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	57                   	push   %edi
  801585:	e8 4a ff ff ff       	call   8014d4 <read>
		if (m < 0)
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 17                	js     8015a8 <readn+0x4d>
			return m;
		if (m == 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	74 11                	je     8015a6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801595:	01 c3                	add    %eax,%ebx
  801597:	89 d8                	mov    %ebx,%eax
  801599:	39 f3                	cmp    %esi,%ebx
  80159b:	72 db                	jb     801578 <readn+0x1d>
  80159d:	eb 09                	jmp    8015a8 <readn+0x4d>
  80159f:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a4:	eb 02                	jmp    8015a8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015a6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 14             	sub    $0x14,%esp
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	53                   	push   %ebx
  8015bf:	e8 8f fc ff ff       	call   801253 <fd_lookup>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 62                	js     80162d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	ff 30                	pushl  (%eax)
  8015d7:	e8 cd fc ff ff       	call   8012a9 <dev_lookup>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 4a                	js     80162d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ea:	75 21                	jne    80160d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f1:	8b 40 48             	mov    0x48(%eax),%eax
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	50                   	push   %eax
  8015f9:	68 69 27 80 00       	push   $0x802769
  8015fe:	e8 f9 eb ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160b:	eb 20                	jmp    80162d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801610:	8b 52 0c             	mov    0xc(%edx),%edx
  801613:	85 d2                	test   %edx,%edx
  801615:	74 11                	je     801628 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	ff 75 0c             	pushl  0xc(%ebp)
  801620:	50                   	push   %eax
  801621:	ff d2                	call   *%edx
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 05                	jmp    80162d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801628:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <seek>:

int
seek(int fdnum, off_t offset)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801638:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 0f fc ff ff       	call   801253 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 0e                	js     801659 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801651:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801654:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 14             	sub    $0x14,%esp
  801662:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801665:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	53                   	push   %ebx
  80166a:	e8 e4 fb ff ff       	call   801253 <fd_lookup>
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 5f                	js     8016d5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	ff 30                	pushl  (%eax)
  801682:	e8 22 fc ff ff       	call   8012a9 <dev_lookup>
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 47                	js     8016d5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801691:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801695:	75 21                	jne    8016b8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801697:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169c:	8b 40 48             	mov    0x48(%eax),%eax
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	53                   	push   %ebx
  8016a3:	50                   	push   %eax
  8016a4:	68 2c 27 80 00       	push   $0x80272c
  8016a9:	e8 4e eb ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b6:	eb 1d                	jmp    8016d5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bb:	8b 52 18             	mov    0x18(%edx),%edx
  8016be:	85 d2                	test   %edx,%edx
  8016c0:	74 0e                	je     8016d0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	50                   	push   %eax
  8016c9:	ff d2                	call   *%edx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	eb 05                	jmp    8016d5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 14             	sub    $0x14,%esp
  8016e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 08             	pushl  0x8(%ebp)
  8016eb:	e8 63 fb ff ff       	call   801253 <fd_lookup>
  8016f0:	83 c4 08             	add    $0x8,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 52                	js     801749 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	ff 30                	pushl  (%eax)
  801703:	e8 a1 fb ff ff       	call   8012a9 <dev_lookup>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 3a                	js     801749 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801716:	74 2c                	je     801744 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801718:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801722:	00 00 00 
	stat->st_isdir = 0;
  801725:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80172c:	00 00 00 
	stat->st_dev = dev;
  80172f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	53                   	push   %ebx
  801739:	ff 75 f0             	pushl  -0x10(%ebp)
  80173c:	ff 50 14             	call   *0x14(%eax)
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	eb 05                	jmp    801749 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801744:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	6a 00                	push   $0x0
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 78 01 00 00       	call   8018d8 <open>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 1b                	js     801784 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	50                   	push   %eax
  801770:	e8 65 ff ff ff       	call   8016da <fstat>
  801775:	89 c6                	mov    %eax,%esi
	close(fd);
  801777:	89 1c 24             	mov    %ebx,(%esp)
  80177a:	e8 18 fc ff ff       	call   801397 <close>
	return r;
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	89 f3                	mov    %esi,%ebx
}
  801784:	89 d8                	mov    %ebx,%eax
  801786:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    
  80178d:	00 00                	add    %al,(%eax)
	...

00801790 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	89 c3                	mov    %eax,%ebx
  801797:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801799:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a0:	75 12                	jne    8017b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	6a 01                	push   $0x1
  8017a7:	e8 ae f9 ff ff       	call   80115a <ipc_find_env>
  8017ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b4:	6a 07                	push   $0x7
  8017b6:	68 00 50 80 00       	push   $0x805000
  8017bb:	53                   	push   %ebx
  8017bc:	ff 35 00 40 80 00    	pushl  0x804000
  8017c2:	e8 3e f9 ff ff       	call   801105 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017c7:	83 c4 0c             	add    $0xc,%esp
  8017ca:	6a 00                	push   $0x0
  8017cc:	56                   	push   %esi
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 bc f8 ff ff       	call   801090 <ipc_recv>
}
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fa:	e8 91 ff ff ff       	call   801790 <fsipc>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 2c                	js     80182f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	68 00 50 80 00       	push   $0x805000
  80180b:	53                   	push   %ebx
  80180c:	e8 a1 ef ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801811:	a1 80 50 80 00       	mov    0x805080,%eax
  801816:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181c:	a1 84 50 80 00       	mov    0x805084,%eax
  801821:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 06 00 00 00       	mov    $0x6,%eax
  80184f:	e8 3c ff ff ff       	call   801790 <fsipc>
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	56                   	push   %esi
  80185a:	53                   	push   %ebx
  80185b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185e:	8b 45 08             	mov    0x8(%ebp),%eax
  801861:	8b 40 0c             	mov    0xc(%eax),%eax
  801864:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801869:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 03 00 00 00       	mov    $0x3,%eax
  801879:	e8 12 ff ff ff       	call   801790 <fsipc>
  80187e:	89 c3                	mov    %eax,%ebx
  801880:	85 c0                	test   %eax,%eax
  801882:	78 4b                	js     8018cf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801884:	39 c6                	cmp    %eax,%esi
  801886:	73 16                	jae    80189e <devfile_read+0x48>
  801888:	68 98 27 80 00       	push   $0x802798
  80188d:	68 9f 27 80 00       	push   $0x80279f
  801892:	6a 7d                	push   $0x7d
  801894:	68 b4 27 80 00       	push   $0x8027b4
  801899:	e8 ce 05 00 00       	call   801e6c <_panic>
	assert(r <= PGSIZE);
  80189e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a3:	7e 16                	jle    8018bb <devfile_read+0x65>
  8018a5:	68 bf 27 80 00       	push   $0x8027bf
  8018aa:	68 9f 27 80 00       	push   $0x80279f
  8018af:	6a 7e                	push   $0x7e
  8018b1:	68 b4 27 80 00       	push   $0x8027b4
  8018b6:	e8 b1 05 00 00       	call   801e6c <_panic>
	memmove(buf, &fsipcbuf, r);
  8018bb:	83 ec 04             	sub    $0x4,%esp
  8018be:	50                   	push   %eax
  8018bf:	68 00 50 80 00       	push   $0x805000
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	e8 a7 f0 ff ff       	call   800973 <memmove>
	return r;
  8018cc:	83 c4 10             	add    $0x10,%esp
}
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 1c             	sub    $0x1c,%esp
  8018e0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e3:	56                   	push   %esi
  8018e4:	e8 77 ee ff ff       	call   800760 <strlen>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f1:	7f 65                	jg     801958 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 e1 f8 ff ff       	call   8011e0 <fd_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 55                	js     80195d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	56                   	push   %esi
  80190c:	68 00 50 80 00       	push   $0x805000
  801911:	e8 9c ee ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801916:	8b 45 0c             	mov    0xc(%ebp),%eax
  801919:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801921:	b8 01 00 00 00       	mov    $0x1,%eax
  801926:	e8 65 fe ff ff       	call   801790 <fsipc>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	85 c0                	test   %eax,%eax
  801932:	79 12                	jns    801946 <open+0x6e>
		fd_close(fd, 0);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	6a 00                	push   $0x0
  801939:	ff 75 f4             	pushl  -0xc(%ebp)
  80193c:	e8 ce f9 ff ff       	call   80130f <fd_close>
		return r;
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	eb 17                	jmp    80195d <open+0x85>
	}

	return fd2num(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 f4             	pushl  -0xc(%ebp)
  80194c:	e8 67 f8 ff ff       	call   8011b8 <fd2num>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	eb 05                	jmp    80195d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801958:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80195d:	89 d8                	mov    %ebx,%eax
  80195f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	c9                   	leave  
  801965:	c3                   	ret    
	...

00801968 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	ff 75 08             	pushl  0x8(%ebp)
  801976:	e8 4d f8 ff ff       	call   8011c8 <fd2data>
  80197b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80197d:	83 c4 08             	add    $0x8,%esp
  801980:	68 cb 27 80 00       	push   $0x8027cb
  801985:	56                   	push   %esi
  801986:	e8 27 ee ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198b:	8b 43 04             	mov    0x4(%ebx),%eax
  80198e:	2b 03                	sub    (%ebx),%eax
  801990:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801996:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80199d:	00 00 00 
	stat->st_dev = &devpipe;
  8019a0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019a7:	30 80 00 
	return 0;
}
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c0:	53                   	push   %ebx
  8019c1:	6a 00                	push   $0x0
  8019c3:	e8 b6 f2 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019c8:	89 1c 24             	mov    %ebx,(%esp)
  8019cb:	e8 f8 f7 ff ff       	call   8011c8 <fd2data>
  8019d0:	83 c4 08             	add    $0x8,%esp
  8019d3:	50                   	push   %eax
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 a3 f2 ff ff       	call   800c7e <sys_page_unmap>
}
  8019db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	57                   	push   %edi
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 1c             	sub    $0x1c,%esp
  8019e9:	89 c7                	mov    %eax,%edi
  8019eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8019f3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	57                   	push   %edi
  8019fa:	e8 49 05 00 00       	call   801f48 <pageref>
  8019ff:	89 c6                	mov    %eax,%esi
  801a01:	83 c4 04             	add    $0x4,%esp
  801a04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a07:	e8 3c 05 00 00       	call   801f48 <pageref>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	39 c6                	cmp    %eax,%esi
  801a11:	0f 94 c0             	sete   %al
  801a14:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a17:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a20:	39 cb                	cmp    %ecx,%ebx
  801a22:	75 08                	jne    801a2c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a2c:	83 f8 01             	cmp    $0x1,%eax
  801a2f:	75 bd                	jne    8019ee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a31:	8b 42 58             	mov    0x58(%edx),%eax
  801a34:	6a 01                	push   $0x1
  801a36:	50                   	push   %eax
  801a37:	53                   	push   %ebx
  801a38:	68 d2 27 80 00       	push   $0x8027d2
  801a3d:	e8 ba e7 ff ff       	call   8001fc <cprintf>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	eb a7                	jmp    8019ee <_pipeisclosed+0xe>

00801a47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	57                   	push   %edi
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 28             	sub    $0x28,%esp
  801a50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a53:	56                   	push   %esi
  801a54:	e8 6f f7 ff ff       	call   8011c8 <fd2data>
  801a59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a62:	75 4a                	jne    801aae <devpipe_write+0x67>
  801a64:	bf 00 00 00 00       	mov    $0x0,%edi
  801a69:	eb 56                	jmp    801ac1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6b:	89 da                	mov    %ebx,%edx
  801a6d:	89 f0                	mov    %esi,%eax
  801a6f:	e8 6c ff ff ff       	call   8019e0 <_pipeisclosed>
  801a74:	85 c0                	test   %eax,%eax
  801a76:	75 4d                	jne    801ac5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a78:	e8 90 f1 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a7d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a80:	8b 13                	mov    (%ebx),%edx
  801a82:	83 c2 20             	add    $0x20,%edx
  801a85:	39 d0                	cmp    %edx,%eax
  801a87:	73 e2                	jae    801a6b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a89:	89 c2                	mov    %eax,%edx
  801a8b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a91:	79 05                	jns    801a98 <devpipe_write+0x51>
  801a93:	4a                   	dec    %edx
  801a94:	83 ca e0             	or     $0xffffffe0,%edx
  801a97:	42                   	inc    %edx
  801a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a9e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa2:	40                   	inc    %eax
  801aa3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa6:	47                   	inc    %edi
  801aa7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801aaa:	77 07                	ja     801ab3 <devpipe_write+0x6c>
  801aac:	eb 13                	jmp    801ac1 <devpipe_write+0x7a>
  801aae:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab3:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab6:	8b 13                	mov    (%ebx),%edx
  801ab8:	83 c2 20             	add    $0x20,%edx
  801abb:	39 d0                	cmp    %edx,%eax
  801abd:	73 ac                	jae    801a6b <devpipe_write+0x24>
  801abf:	eb c8                	jmp    801a89 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	eb 05                	jmp    801aca <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5f                   	pop    %edi
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	57                   	push   %edi
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 18             	sub    $0x18,%esp
  801adb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ade:	57                   	push   %edi
  801adf:	e8 e4 f6 ff ff       	call   8011c8 <fd2data>
  801ae4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aed:	75 44                	jne    801b33 <devpipe_read+0x61>
  801aef:	be 00 00 00 00       	mov    $0x0,%esi
  801af4:	eb 4f                	jmp    801b45 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801af6:	89 f0                	mov    %esi,%eax
  801af8:	eb 54                	jmp    801b4e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801afa:	89 da                	mov    %ebx,%edx
  801afc:	89 f8                	mov    %edi,%eax
  801afe:	e8 dd fe ff ff       	call   8019e0 <_pipeisclosed>
  801b03:	85 c0                	test   %eax,%eax
  801b05:	75 42                	jne    801b49 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b07:	e8 01 f1 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b0c:	8b 03                	mov    (%ebx),%eax
  801b0e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b11:	74 e7                	je     801afa <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b13:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b18:	79 05                	jns    801b1f <devpipe_read+0x4d>
  801b1a:	48                   	dec    %eax
  801b1b:	83 c8 e0             	or     $0xffffffe0,%eax
  801b1e:	40                   	inc    %eax
  801b1f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b26:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b29:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2b:	46                   	inc    %esi
  801b2c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b2f:	77 07                	ja     801b38 <devpipe_read+0x66>
  801b31:	eb 12                	jmp    801b45 <devpipe_read+0x73>
  801b33:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b38:	8b 03                	mov    (%ebx),%eax
  801b3a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b3d:	75 d4                	jne    801b13 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b3f:	85 f6                	test   %esi,%esi
  801b41:	75 b3                	jne    801af6 <devpipe_read+0x24>
  801b43:	eb b5                	jmp    801afa <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	eb 05                	jmp    801b4e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 28             	sub    $0x28,%esp
  801b5f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	e8 75 f6 ff ff       	call   8011e0 <fd_alloc>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 88 24 01 00 00    	js     801c9c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	68 07 04 00 00       	push   $0x407
  801b80:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b83:	6a 00                	push   $0x0
  801b85:	e8 aa f0 ff ff       	call   800c34 <sys_page_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 05 01 00 00    	js     801c9c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 3d f6 ff ff       	call   8011e0 <fd_alloc>
  801ba3:	89 c3                	mov    %eax,%ebx
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	0f 88 dc 00 00 00    	js     801c8c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 72 f0 ff ff       	call   800c34 <sys_page_alloc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 bd 00 00 00    	js     801c8c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd5:	e8 ee f5 ff ff       	call   8011c8 <fd2data>
  801bda:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdc:	83 c4 0c             	add    $0xc,%esp
  801bdf:	68 07 04 00 00       	push   $0x407
  801be4:	50                   	push   %eax
  801be5:	6a 00                	push   $0x0
  801be7:	e8 48 f0 ff ff       	call   800c34 <sys_page_alloc>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 83 00 00 00    	js     801c7c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	83 ec 0c             	sub    $0xc,%esp
  801bfc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bff:	e8 c4 f5 ff ff       	call   8011c8 <fd2data>
  801c04:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0b:	50                   	push   %eax
  801c0c:	6a 00                	push   $0x0
  801c0e:	56                   	push   %esi
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 42 f0 ff ff       	call   800c58 <sys_page_map>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 20             	add    $0x20,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 4f                	js     801c6e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c1f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c28:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c3d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c42:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c4f:	e8 64 f5 ff ff       	call   8011b8 <fd2num>
  801c54:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c56:	83 c4 04             	add    $0x4,%esp
  801c59:	ff 75 e0             	pushl  -0x20(%ebp)
  801c5c:	e8 57 f5 ff ff       	call   8011b8 <fd2num>
  801c61:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6c:	eb 2e                	jmp    801c9c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	56                   	push   %esi
  801c72:	6a 00                	push   $0x0
  801c74:	e8 05 f0 ff ff       	call   800c7e <sys_page_unmap>
  801c79:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 f5 ef ff ff       	call   800c7e <sys_page_unmap>
  801c89:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c8c:	83 ec 08             	sub    $0x8,%esp
  801c8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c92:	6a 00                	push   $0x0
  801c94:	e8 e5 ef ff ff       	call   800c7e <sys_page_unmap>
  801c99:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca1:	5b                   	pop    %ebx
  801ca2:	5e                   	pop    %esi
  801ca3:	5f                   	pop    %edi
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	ff 75 08             	pushl  0x8(%ebp)
  801cb3:	e8 9b f5 ff ff       	call   801253 <fd_lookup>
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 18                	js     801cd7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 fe f4 ff ff       	call   8011c8 <fd2data>
	return _pipeisclosed(fd, p);
  801cca:	89 c2                	mov    %eax,%edx
  801ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccf:	e8 0c fd ff ff       	call   8019e0 <_pipeisclosed>
  801cd4:	83 c4 10             	add    $0x10,%esp
}
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    
  801cd9:	00 00                	add    %al,(%eax)
	...

00801cdc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cec:	68 ea 27 80 00       	push   $0x8027ea
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	e8 b9 ea ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	57                   	push   %edi
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d10:	74 45                	je     801d57 <devcons_write+0x57>
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
  801d17:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d25:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d27:	83 fb 7f             	cmp    $0x7f,%ebx
  801d2a:	76 05                	jbe    801d31 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d2c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	53                   	push   %ebx
  801d35:	03 45 0c             	add    0xc(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	57                   	push   %edi
  801d3a:	e8 34 ec ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801d3f:	83 c4 08             	add    $0x8,%esp
  801d42:	53                   	push   %ebx
  801d43:	57                   	push   %edi
  801d44:	e8 34 ee ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d49:	01 de                	add    %ebx,%esi
  801d4b:	89 f0                	mov    %esi,%eax
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d53:	72 cd                	jb     801d22 <devcons_write+0x22>
  801d55:	eb 05                	jmp    801d5c <devcons_write+0x5c>
  801d57:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d5c:	89 f0                	mov    %esi,%eax
  801d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d70:	75 07                	jne    801d79 <devcons_read+0x13>
  801d72:	eb 25                	jmp    801d99 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d74:	e8 94 ee ff ff       	call   800c0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d79:	e8 25 ee ff ff       	call   800ba3 <sys_cgetc>
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	74 f2                	je     801d74 <devcons_read+0xe>
  801d82:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 1d                	js     801da5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d88:	83 f8 04             	cmp    $0x4,%eax
  801d8b:	74 13                	je     801da0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d90:	88 10                	mov    %dl,(%eax)
	return 1;
  801d92:	b8 01 00 00 00       	mov    $0x1,%eax
  801d97:	eb 0c                	jmp    801da5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	eb 05                	jmp    801da5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db3:	6a 01                	push   $0x1
  801db5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	e8 bf ed ff ff       	call   800b7d <sys_cputs>
  801dbe:	83 c4 10             	add    $0x10,%esp
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <getchar>:

int
getchar(void)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc9:	6a 01                	push   $0x1
  801dcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 fe f6 ff ff       	call   8014d4 <read>
	if (r < 0)
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 0f                	js     801dec <getchar+0x29>
		return r;
	if (r < 1)
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	7e 06                	jle    801de7 <getchar+0x24>
		return -E_EOF;
	return c;
  801de1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de5:	eb 05                	jmp    801dec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df7:	50                   	push   %eax
  801df8:	ff 75 08             	pushl  0x8(%ebp)
  801dfb:	e8 53 f4 ff ff       	call   801253 <fd_lookup>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 11                	js     801e18 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e10:	39 10                	cmp    %edx,(%eax)
  801e12:	0f 94 c0             	sete   %al
  801e15:	0f b6 c0             	movzbl %al,%eax
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <opencons>:

int
opencons(void)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	e8 b7 f3 ff ff       	call   8011e0 <fd_alloc>
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 3a                	js     801e6a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e30:	83 ec 04             	sub    $0x4,%esp
  801e33:	68 07 04 00 00       	push   $0x407
  801e38:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 f2 ed ff ff       	call   800c34 <sys_page_alloc>
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	78 21                	js     801e6a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e49:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e52:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	50                   	push   %eax
  801e62:	e8 51 f3 ff ff       	call   8011b8 <fd2num>
  801e67:	83 c4 10             	add    $0x10,%esp
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e71:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e74:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e7a:	e8 6a ed ff ff       	call   800be9 <sys_getenvid>
  801e7f:	83 ec 0c             	sub    $0xc,%esp
  801e82:	ff 75 0c             	pushl  0xc(%ebp)
  801e85:	ff 75 08             	pushl  0x8(%ebp)
  801e88:	53                   	push   %ebx
  801e89:	50                   	push   %eax
  801e8a:	68 f8 27 80 00       	push   $0x8027f8
  801e8f:	e8 68 e3 ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e94:	83 c4 18             	add    $0x18,%esp
  801e97:	56                   	push   %esi
  801e98:	ff 75 10             	pushl  0x10(%ebp)
  801e9b:	e8 0b e3 ff ff       	call   8001ab <vcprintf>
	cprintf("\n");
  801ea0:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  801ea7:	e8 50 e3 ff ff       	call   8001fc <cprintf>
  801eac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eaf:	cc                   	int3   
  801eb0:	eb fd                	jmp    801eaf <_panic+0x43>
	...

00801eb4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eba:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ec1:	75 52                	jne    801f15 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	6a 07                	push   $0x7
  801ec8:	68 00 f0 bf ee       	push   $0xeebff000
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 60 ed ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) {
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	79 12                	jns    801eed <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801edb:	50                   	push   %eax
  801edc:	68 1b 28 80 00       	push   $0x80281b
  801ee1:	6a 24                	push   $0x24
  801ee3:	68 36 28 80 00       	push   $0x802836
  801ee8:	e8 7f ff ff ff       	call   801e6c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	68 20 1f 80 00       	push   $0x801f20
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 eb ed ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	79 12                	jns    801f15 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f03:	50                   	push   %eax
  801f04:	68 44 28 80 00       	push   $0x802844
  801f09:	6a 2a                	push   $0x2a
  801f0b:	68 36 28 80 00       	push   $0x802836
  801f10:	e8 57 ff ff ff       	call   801e6c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f15:	8b 45 08             	mov    0x8(%ebp),%eax
  801f18:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f1d:	c9                   	leave  
  801f1e:	c3                   	ret    
	...

00801f20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f21:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f28:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f2b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f2f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f32:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f36:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f3a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f3c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f3f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f40:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f43:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f44:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f45:	c3                   	ret    
	...

00801f48 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	c1 ea 16             	shr    $0x16,%edx
  801f53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f5a:	f6 c2 01             	test   $0x1,%dl
  801f5d:	74 1e                	je     801f7d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f5f:	c1 e8 0c             	shr    $0xc,%eax
  801f62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f69:	a8 01                	test   $0x1,%al
  801f6b:	74 17                	je     801f84 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6d:	c1 e8 0c             	shr    $0xc,%eax
  801f70:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f77:	ef 
  801f78:	0f b7 c0             	movzwl %ax,%eax
  801f7b:	eb 0c                	jmp    801f89 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f82:	eb 05                	jmp    801f89 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    
	...

00801f8c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	57                   	push   %edi
  801f90:	56                   	push   %esi
  801f91:	83 ec 10             	sub    $0x10,%esp
  801f94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f97:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f9a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fa0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fa3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	75 2e                	jne    801fd8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801faa:	39 f1                	cmp    %esi,%ecx
  801fac:	77 5a                	ja     802008 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fae:	85 c9                	test   %ecx,%ecx
  801fb0:	75 0b                	jne    801fbd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb7:	31 d2                	xor    %edx,%edx
  801fb9:	f7 f1                	div    %ecx
  801fbb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fbd:	31 d2                	xor    %edx,%edx
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	f7 f1                	div    %ecx
  801fc3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	f7 f1                	div    %ecx
  801fc9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fcb:	89 f8                	mov    %edi,%eax
  801fcd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fd8:	39 f0                	cmp    %esi,%eax
  801fda:	77 1c                	ja     801ff8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fdc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fdf:	83 f7 1f             	xor    $0x1f,%edi
  801fe2:	75 3c                	jne    802020 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fe4:	39 f0                	cmp    %esi,%eax
  801fe6:	0f 82 90 00 00 00    	jb     80207c <__udivdi3+0xf0>
  801fec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fef:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ff2:	0f 86 84 00 00 00    	jbe    80207c <__udivdi3+0xf0>
  801ff8:	31 f6                	xor    %esi,%esi
  801ffa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ffc:	89 f8                	mov    %edi,%eax
  801ffe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	5e                   	pop    %esi
  802004:	5f                   	pop    %edi
  802005:	c9                   	leave  
  802006:	c3                   	ret    
  802007:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802008:	89 f2                	mov    %esi,%edx
  80200a:	89 f8                	mov    %edi,%eax
  80200c:	f7 f1                	div    %ecx
  80200e:	89 c7                	mov    %eax,%edi
  802010:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802012:	89 f8                	mov    %edi,%eax
  802014:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    
  80201d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802020:	89 f9                	mov    %edi,%ecx
  802022:	d3 e0                	shl    %cl,%eax
  802024:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802027:	b8 20 00 00 00       	mov    $0x20,%eax
  80202c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80202e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802031:	88 c1                	mov    %al,%cl
  802033:	d3 ea                	shr    %cl,%edx
  802035:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802038:	09 ca                	or     %ecx,%edx
  80203a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80203d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802040:	89 f9                	mov    %edi,%ecx
  802042:	d3 e2                	shl    %cl,%edx
  802044:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802047:	89 f2                	mov    %esi,%edx
  802049:	88 c1                	mov    %al,%cl
  80204b:	d3 ea                	shr    %cl,%edx
  80204d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802050:	89 f2                	mov    %esi,%edx
  802052:	89 f9                	mov    %edi,%ecx
  802054:	d3 e2                	shl    %cl,%edx
  802056:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802059:	88 c1                	mov    %al,%cl
  80205b:	d3 ee                	shr    %cl,%esi
  80205d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80205f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802062:	89 f0                	mov    %esi,%eax
  802064:	89 ca                	mov    %ecx,%edx
  802066:	f7 75 ec             	divl   -0x14(%ebp)
  802069:	89 d1                	mov    %edx,%ecx
  80206b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80206d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802070:	39 d1                	cmp    %edx,%ecx
  802072:	72 28                	jb     80209c <__udivdi3+0x110>
  802074:	74 1a                	je     802090 <__udivdi3+0x104>
  802076:	89 f7                	mov    %esi,%edi
  802078:	31 f6                	xor    %esi,%esi
  80207a:	eb 80                	jmp    801ffc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80207c:	31 f6                	xor    %esi,%esi
  80207e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802083:	89 f8                	mov    %edi,%eax
  802085:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802090:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802093:	89 f9                	mov    %edi,%ecx
  802095:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802097:	39 c2                	cmp    %eax,%edx
  802099:	73 db                	jae    802076 <__udivdi3+0xea>
  80209b:	90                   	nop
		{
		  q0--;
  80209c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80209f:	31 f6                	xor    %esi,%esi
  8020a1:	e9 56 ff ff ff       	jmp    801ffc <__udivdi3+0x70>
	...

008020a8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	57                   	push   %edi
  8020ac:	56                   	push   %esi
  8020ad:	83 ec 20             	sub    $0x20,%esp
  8020b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020bc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020c5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020c7:	85 ff                	test   %edi,%edi
  8020c9:	75 15                	jne    8020e0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020cb:	39 f1                	cmp    %esi,%ecx
  8020cd:	0f 86 99 00 00 00    	jbe    80216c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020d3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020d5:	89 d0                	mov    %edx,%eax
  8020d7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020d9:	83 c4 20             	add    $0x20,%esp
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020e0:	39 f7                	cmp    %esi,%edi
  8020e2:	0f 87 a4 00 00 00    	ja     80218c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020e8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020eb:	83 f0 1f             	xor    $0x1f,%eax
  8020ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f1:	0f 84 a1 00 00 00    	je     802198 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020f7:	89 f8                	mov    %edi,%eax
  8020f9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020fc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020fe:	bf 20 00 00 00       	mov    $0x20,%edi
  802103:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802106:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802109:	89 f9                	mov    %edi,%ecx
  80210b:	d3 ea                	shr    %cl,%edx
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802118:	d3 e0                	shl    %cl,%eax
  80211a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802121:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802124:	d3 e0                	shl    %cl,%eax
  802126:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802129:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80212c:	89 f9                	mov    %edi,%ecx
  80212e:	d3 e8                	shr    %cl,%eax
  802130:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802132:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802134:	89 f2                	mov    %esi,%edx
  802136:	f7 75 f0             	divl   -0x10(%ebp)
  802139:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80213b:	f7 65 f4             	mull   -0xc(%ebp)
  80213e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802141:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802143:	39 d6                	cmp    %edx,%esi
  802145:	72 71                	jb     8021b8 <__umoddi3+0x110>
  802147:	74 7f                	je     8021c8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80214c:	29 c8                	sub    %ecx,%eax
  80214e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802150:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802153:	d3 e8                	shr    %cl,%eax
  802155:	89 f2                	mov    %esi,%edx
  802157:	89 f9                	mov    %edi,%ecx
  802159:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80215b:	09 d0                	or     %edx,%eax
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802162:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802164:	83 c4 20             	add    $0x20,%esp
  802167:	5e                   	pop    %esi
  802168:	5f                   	pop    %edi
  802169:	c9                   	leave  
  80216a:	c3                   	ret    
  80216b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80216c:	85 c9                	test   %ecx,%ecx
  80216e:	75 0b                	jne    80217b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802170:	b8 01 00 00 00       	mov    $0x1,%eax
  802175:	31 d2                	xor    %edx,%edx
  802177:	f7 f1                	div    %ecx
  802179:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80217b:	89 f0                	mov    %esi,%eax
  80217d:	31 d2                	xor    %edx,%edx
  80217f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802184:	f7 f1                	div    %ecx
  802186:	e9 4a ff ff ff       	jmp    8020d5 <__umoddi3+0x2d>
  80218b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80218c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80218e:	83 c4 20             	add    $0x20,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	c9                   	leave  
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802198:	39 f7                	cmp    %esi,%edi
  80219a:	72 05                	jb     8021a1 <__umoddi3+0xf9>
  80219c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80219f:	77 0c                	ja     8021ad <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021a1:	89 f2                	mov    %esi,%edx
  8021a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a6:	29 c8                	sub    %ecx,%eax
  8021a8:	19 fa                	sbb    %edi,%edx
  8021aa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b0:	83 c4 20             	add    $0x20,%esp
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	c9                   	leave  
  8021b6:	c3                   	ret    
  8021b7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021bb:	89 c1                	mov    %eax,%ecx
  8021bd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021c0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021c3:	eb 84                	jmp    802149 <__umoddi3+0xa1>
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021cb:	72 eb                	jb     8021b8 <__umoddi3+0x110>
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	e9 75 ff ff ff       	jmp    802149 <__umoddi3+0xa1>
