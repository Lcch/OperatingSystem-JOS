
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
  80003d:	e8 5a 10 00 00       	call   80109c <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 42                	je     80008b <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 95 0b 00 00       	call   800be9 <sys_getenvid>
  800054:	83 ec 04             	sub    $0x4,%esp
  800057:	53                   	push   %ebx
  800058:	50                   	push   %eax
  800059:	68 00 22 80 00       	push   $0x802200
  80005e:	e8 99 01 00 00       	call   8001fc <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800063:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800066:	e8 7e 0b 00 00       	call   800be9 <sys_getenvid>
  80006b:	83 c4 0c             	add    $0xc,%esp
  80006e:	53                   	push   %ebx
  80006f:	50                   	push   %eax
  800070:	68 1a 22 80 00       	push   $0x80221a
  800075:	e8 82 01 00 00       	call   8001fc <cprintf>
		ipc_send(who, 0, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	6a 00                	push   $0x0
  800080:	ff 75 e4             	pushl  -0x1c(%ebp)
  800083:	e8 a5 10 00 00       	call   80112d <ipc_send>
  800088:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008b:	83 ec 04             	sub    $0x4,%esp
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	e8 1d 10 00 00       	call   8010b8 <ipc_recv>
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
  8000be:	68 30 22 80 00       	push   $0x802230
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
  8000e4:	e8 44 10 00 00       	call   80112d <ipc_send>
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
  800156:	e8 8f 12 00 00       	call   8013ea <close_all>
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
  800264:	e8 4b 1d 00 00       	call   801fb4 <__udivdi3>
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
  8002a0:	e8 2b 1e 00 00       	call   8020d0 <__umoddi3>
  8002a5:	83 c4 14             	add    $0x14,%esp
  8002a8:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
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
  8003ec:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  800498:	8b 04 85 00 25 80 00 	mov    0x802500(,%eax,4),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 1a                	jne    8004bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004a3:	52                   	push   %edx
  8004a4:	68 78 22 80 00       	push   $0x802278
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
  8004be:	68 d1 27 80 00       	push   $0x8027d1
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
  8004f4:	c7 45 d0 71 22 80 00 	movl   $0x802271,-0x30(%ebp)
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
  800b62:	68 5f 25 80 00       	push   $0x80255f
  800b67:	6a 42                	push   $0x42
  800b69:	68 7c 25 80 00       	push   $0x80257c
  800b6e:	e8 21 13 00 00       	call   801e94 <_panic>

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

00800d74 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d7a:	6a 00                	push   $0x0
  800d7c:	ff 75 14             	pushl  0x14(%ebp)
  800d7f:	ff 75 10             	pushl  0x10(%ebp)
  800d82:	ff 75 0c             	pushl  0xc(%ebp)
  800d85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d92:	e8 99 fd ff ff       	call   800b30 <syscall>
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    
  800d99:	00 00                	add    %al,(%eax)
	...

00800d9c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da6:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800da8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dac:	75 14                	jne    800dc2 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	68 8c 25 80 00       	push   $0x80258c
  800db6:	6a 20                	push   $0x20
  800db8:	68 d0 26 80 00       	push   $0x8026d0
  800dbd:	e8 d2 10 00 00       	call   801e94 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 16             	shr    $0x16,%eax
  800dc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dce:	a8 01                	test   $0x1,%al
  800dd0:	74 11                	je     800de3 <pgfault+0x47>
  800dd2:	89 d8                	mov    %ebx,%eax
  800dd4:	c1 e8 0c             	shr    $0xc,%eax
  800dd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dde:	f6 c4 08             	test   $0x8,%ah
  800de1:	75 14                	jne    800df7 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	68 b0 25 80 00       	push   $0x8025b0
  800deb:	6a 24                	push   $0x24
  800ded:	68 d0 26 80 00       	push   $0x8026d0
  800df2:	e8 9d 10 00 00       	call   801e94 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	6a 07                	push   $0x7
  800dfc:	68 00 f0 7f 00       	push   $0x7ff000
  800e01:	6a 00                	push   $0x0
  800e03:	e8 2c fe ff ff       	call   800c34 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0x85>
  800e0f:	50                   	push   %eax
  800e10:	68 d4 25 80 00       	push   $0x8025d4
  800e15:	6a 32                	push   $0x32
  800e17:	68 d0 26 80 00       	push   $0x8026d0
  800e1c:	e8 73 10 00 00       	call   801e94 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e21:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 00 10 00 00       	push   $0x1000
  800e2f:	53                   	push   %ebx
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	e8 a3 fb ff ff       	call   8009dd <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e3a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e41:	53                   	push   %ebx
  800e42:	6a 00                	push   $0x0
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 08 fe ff ff       	call   800c58 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e50:	83 c4 20             	add    $0x20,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	79 12                	jns    800e69 <pgfault+0xcd>
  800e57:	50                   	push   %eax
  800e58:	68 f8 25 80 00       	push   $0x8025f8
  800e5d:	6a 3a                	push   $0x3a
  800e5f:	68 d0 26 80 00       	push   $0x8026d0
  800e64:	e8 2b 10 00 00       	call   801e94 <_panic>

	return;
}
  800e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e77:	68 9c 0d 80 00       	push   $0x800d9c
  800e7c:	e8 5b 10 00 00       	call   801edc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e81:	ba 07 00 00 00       	mov    $0x7,%edx
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	cd 30                	int    $0x30
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	79 12                	jns    800ea8 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e96:	50                   	push   %eax
  800e97:	68 db 26 80 00       	push   $0x8026db
  800e9c:	6a 7f                	push   $0x7f
  800e9e:	68 d0 26 80 00       	push   $0x8026d0
  800ea3:	e8 ec 0f 00 00       	call   801e94 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ea8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eac:	75 25                	jne    800ed3 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800eae:	e8 36 fd ff ff       	call   800be9 <sys_getenvid>
  800eb3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ebf:	c1 e0 07             	shl    $0x7,%eax
  800ec2:	29 d0                	sub    %edx,%eax
  800ec4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec9:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800ece:	e9 be 01 00 00       	jmp    801091 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ed8:	89 d8                	mov    %ebx,%eax
  800eda:	c1 e8 16             	shr    $0x16,%eax
  800edd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee4:	a8 01                	test   $0x1,%al
  800ee6:	0f 84 10 01 00 00    	je     800ffc <fork+0x18e>
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	c1 e8 0c             	shr    $0xc,%eax
  800ef1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef8:	f6 c2 01             	test   $0x1,%dl
  800efb:	0f 84 fb 00 00 00    	je     800ffc <fork+0x18e>
  800f01:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f08:	f6 c2 04             	test   $0x4,%dl
  800f0b:	0f 84 eb 00 00 00    	je     800ffc <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f11:	89 c6                	mov    %eax,%esi
  800f13:	c1 e6 0c             	shl    $0xc,%esi
  800f16:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f1c:	0f 84 da 00 00 00    	je     800ffc <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f22:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f29:	f6 c6 04             	test   $0x4,%dh
  800f2c:	74 37                	je     800f65 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3d:	50                   	push   %eax
  800f3e:	56                   	push   %esi
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	6a 00                	push   $0x0
  800f43:	e8 10 fd ff ff       	call   800c58 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f48:	83 c4 20             	add    $0x20,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	0f 89 a9 00 00 00    	jns    800ffc <fork+0x18e>
  800f53:	50                   	push   %eax
  800f54:	68 1c 26 80 00       	push   $0x80261c
  800f59:	6a 54                	push   $0x54
  800f5b:	68 d0 26 80 00       	push   $0x8026d0
  800f60:	e8 2f 0f 00 00       	call   801e94 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f65:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6c:	f6 c2 02             	test   $0x2,%dl
  800f6f:	75 0c                	jne    800f7d <fork+0x10f>
  800f71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f78:	f6 c4 08             	test   $0x8,%ah
  800f7b:	74 57                	je     800fd4 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	68 05 08 00 00       	push   $0x805
  800f85:	56                   	push   %esi
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 c9 fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f8f:	83 c4 20             	add    $0x20,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 12                	jns    800fa8 <fork+0x13a>
  800f96:	50                   	push   %eax
  800f97:	68 1c 26 80 00       	push   $0x80261c
  800f9c:	6a 59                	push   $0x59
  800f9e:	68 d0 26 80 00       	push   $0x8026d0
  800fa3:	e8 ec 0e 00 00       	call   801e94 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fa8:	83 ec 0c             	sub    $0xc,%esp
  800fab:	68 05 08 00 00       	push   $0x805
  800fb0:	56                   	push   %esi
  800fb1:	6a 00                	push   $0x0
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 9d fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 3a                	jns    800ffc <fork+0x18e>
  800fc2:	50                   	push   %eax
  800fc3:	68 1c 26 80 00       	push   $0x80261c
  800fc8:	6a 5c                	push   $0x5c
  800fca:	68 d0 26 80 00       	push   $0x8026d0
  800fcf:	e8 c0 0e 00 00       	call   801e94 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	6a 05                	push   $0x5
  800fd9:	56                   	push   %esi
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 75 fc ff ff       	call   800c58 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 12                	jns    800ffc <fork+0x18e>
  800fea:	50                   	push   %eax
  800feb:	68 1c 26 80 00       	push   $0x80261c
  800ff0:	6a 60                	push   $0x60
  800ff2:	68 d0 26 80 00       	push   $0x8026d0
  800ff7:	e8 98 0e 00 00       	call   801e94 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800ffc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801002:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801008:	0f 85 ca fe ff ff    	jne    800ed8 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	6a 07                	push   $0x7
  801013:	68 00 f0 bf ee       	push   $0xeebff000
  801018:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101b:	e8 14 fc ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	79 15                	jns    80103c <fork+0x1ce>
  801027:	50                   	push   %eax
  801028:	68 40 26 80 00       	push   $0x802640
  80102d:	68 94 00 00 00       	push   $0x94
  801032:	68 d0 26 80 00       	push   $0x8026d0
  801037:	e8 58 0e 00 00       	call   801e94 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	68 48 1f 80 00       	push   $0x801f48
  801044:	ff 75 e4             	pushl  -0x1c(%ebp)
  801047:	e8 9b fc ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 15                	jns    801068 <fork+0x1fa>
  801053:	50                   	push   %eax
  801054:	68 78 26 80 00       	push   $0x802678
  801059:	68 99 00 00 00       	push   $0x99
  80105e:	68 d0 26 80 00       	push   $0x8026d0
  801063:	e8 2c 0e 00 00       	call   801e94 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	6a 02                	push   $0x2
  80106d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801070:	e8 2c fc ff ff       	call   800ca1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 15                	jns    801091 <fork+0x223>
  80107c:	50                   	push   %eax
  80107d:	68 9c 26 80 00       	push   $0x80269c
  801082:	68 a4 00 00 00       	push   $0xa4
  801087:	68 d0 26 80 00       	push   $0x8026d0
  80108c:	e8 03 0e 00 00       	call   801e94 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801091:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sfork>:

// Challenge!
int
sfork(void)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a2:	68 f8 26 80 00       	push   $0x8026f8
  8010a7:	68 b1 00 00 00       	push   $0xb1
  8010ac:	68 d0 26 80 00       	push   $0x8026d0
  8010b1:	e8 de 0d 00 00       	call   801e94 <_panic>
	...

008010b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8010c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	74 0e                	je     8010d8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	50                   	push   %eax
  8010ce:	e8 5c fc ff ff       	call   800d2f <sys_ipc_recv>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	eb 10                	jmp    8010e8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	68 00 00 c0 ee       	push   $0xeec00000
  8010e0:	e8 4a fc ff ff       	call   800d2f <sys_ipc_recv>
  8010e5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	75 26                	jne    801112 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010ec:	85 f6                	test   %esi,%esi
  8010ee:	74 0a                	je     8010fa <ipc_recv+0x42>
  8010f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f5:	8b 40 74             	mov    0x74(%eax),%eax
  8010f8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010fa:	85 db                	test   %ebx,%ebx
  8010fc:	74 0a                	je     801108 <ipc_recv+0x50>
  8010fe:	a1 08 40 80 00       	mov    0x804008,%eax
  801103:	8b 40 78             	mov    0x78(%eax),%eax
  801106:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801108:	a1 08 40 80 00       	mov    0x804008,%eax
  80110d:	8b 40 70             	mov    0x70(%eax),%eax
  801110:	eb 14                	jmp    801126 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801112:	85 f6                	test   %esi,%esi
  801114:	74 06                	je     80111c <ipc_recv+0x64>
  801116:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80111c:	85 db                	test   %ebx,%ebx
  80111e:	74 06                	je     801126 <ipc_recv+0x6e>
  801120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801139:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80113f:	85 db                	test   %ebx,%ebx
  801141:	75 25                	jne    801168 <ipc_send+0x3b>
  801143:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801148:	eb 1e                	jmp    801168 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80114a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80114d:	75 07                	jne    801156 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80114f:	e8 b9 fa ff ff       	call   800c0d <sys_yield>
  801154:	eb 12                	jmp    801168 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801156:	50                   	push   %eax
  801157:	68 0e 27 80 00       	push   $0x80270e
  80115c:	6a 43                	push   $0x43
  80115e:	68 21 27 80 00       	push   $0x802721
  801163:	e8 2c 0d 00 00       	call   801e94 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	57                   	push   %edi
  80116b:	ff 75 08             	pushl  0x8(%ebp)
  80116e:	e8 97 fb ff ff       	call   800d0a <sys_ipc_try_send>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	75 d0                	jne    80114a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80117a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5f                   	pop    %edi
  801180:	c9                   	leave  
  801181:	c3                   	ret    

00801182 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	53                   	push   %ebx
  801186:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801189:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80118f:	74 22                	je     8011b3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801191:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801196:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 e2 07             	shl    $0x7,%edx
  8011a2:	29 ca                	sub    %ecx,%edx
  8011a4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011aa:	8b 52 50             	mov    0x50(%edx),%edx
  8011ad:	39 da                	cmp    %ebx,%edx
  8011af:	75 1d                	jne    8011ce <ipc_find_env+0x4c>
  8011b1:	eb 05                	jmp    8011b8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011bf:	c1 e0 07             	shl    $0x7,%eax
  8011c2:	29 d0                	sub    %edx,%eax
  8011c4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8011c9:	8b 40 40             	mov    0x40(%eax),%eax
  8011cc:	eb 0c                	jmp    8011da <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ce:	40                   	inc    %eax
  8011cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d4:	75 c0                	jne    801196 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d6:	66 b8 00 00          	mov    $0x0,%ax
}
  8011da:	5b                   	pop    %ebx
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    
  8011dd:	00 00                	add    %al,(%eax)
	...

008011e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f3:	ff 75 08             	pushl  0x8(%ebp)
  8011f6:	e8 e5 ff ff ff       	call   8011e0 <fd2num>
  8011fb:	83 c4 04             	add    $0x4,%esp
  8011fe:	05 20 00 0d 00       	add    $0xd0020,%eax
  801203:	c1 e0 0c             	shl    $0xc,%eax
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	53                   	push   %ebx
  80120c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801214:	a8 01                	test   $0x1,%al
  801216:	74 34                	je     80124c <fd_alloc+0x44>
  801218:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80121d:	a8 01                	test   $0x1,%al
  80121f:	74 32                	je     801253 <fd_alloc+0x4b>
  801221:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801226:	89 c1                	mov    %eax,%ecx
  801228:	89 c2                	mov    %eax,%edx
  80122a:	c1 ea 16             	shr    $0x16,%edx
  80122d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801234:	f6 c2 01             	test   $0x1,%dl
  801237:	74 1f                	je     801258 <fd_alloc+0x50>
  801239:	89 c2                	mov    %eax,%edx
  80123b:	c1 ea 0c             	shr    $0xc,%edx
  80123e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801245:	f6 c2 01             	test   $0x1,%dl
  801248:	75 17                	jne    801261 <fd_alloc+0x59>
  80124a:	eb 0c                	jmp    801258 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80124c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801251:	eb 05                	jmp    801258 <fd_alloc+0x50>
  801253:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801258:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 17                	jmp    801278 <fd_alloc+0x70>
  801261:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801266:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126b:	75 b9                	jne    801226 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80126d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801273:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801278:	5b                   	pop    %ebx
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801281:	83 f8 1f             	cmp    $0x1f,%eax
  801284:	77 36                	ja     8012bc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801286:	05 00 00 0d 00       	add    $0xd0000,%eax
  80128b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128e:	89 c2                	mov    %eax,%edx
  801290:	c1 ea 16             	shr    $0x16,%edx
  801293:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129a:	f6 c2 01             	test   $0x1,%dl
  80129d:	74 24                	je     8012c3 <fd_lookup+0x48>
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	c1 ea 0c             	shr    $0xc,%edx
  8012a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 1a                	je     8012ca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ba:	eb 13                	jmp    8012cf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c1:	eb 0c                	jmp    8012cf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb 05                	jmp    8012cf <fd_lookup+0x54>
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 04             	sub    $0x4,%esp
  8012d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012de:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012e4:	74 0d                	je     8012f3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb 14                	jmp    801301 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012ed:	39 0a                	cmp    %ecx,(%edx)
  8012ef:	75 10                	jne    801301 <dev_lookup+0x30>
  8012f1:	eb 05                	jmp    8012f8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f3:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012f8:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ff:	eb 31                	jmp    801332 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801301:	40                   	inc    %eax
  801302:	8b 14 85 a8 27 80 00 	mov    0x8027a8(,%eax,4),%edx
  801309:	85 d2                	test   %edx,%edx
  80130b:	75 e0                	jne    8012ed <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130d:	a1 08 40 80 00       	mov    0x804008,%eax
  801312:	8b 40 48             	mov    0x48(%eax),%eax
  801315:	83 ec 04             	sub    $0x4,%esp
  801318:	51                   	push   %ecx
  801319:	50                   	push   %eax
  80131a:	68 2c 27 80 00       	push   $0x80272c
  80131f:	e8 d8 ee ff ff       	call   8001fc <cprintf>
	*dev = 0;
  801324:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	83 ec 20             	sub    $0x20,%esp
  80133f:	8b 75 08             	mov    0x8(%ebp),%esi
  801342:	8a 45 0c             	mov    0xc(%ebp),%al
  801345:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801348:	56                   	push   %esi
  801349:	e8 92 fe ff ff       	call   8011e0 <fd2num>
  80134e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801351:	89 14 24             	mov    %edx,(%esp)
  801354:	50                   	push   %eax
  801355:	e8 21 ff ff ff       	call   80127b <fd_lookup>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 05                	js     801368 <fd_close+0x31>
	    || fd != fd2)
  801363:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801366:	74 0d                	je     801375 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801368:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80136c:	75 48                	jne    8013b6 <fd_close+0x7f>
  80136e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801373:	eb 41                	jmp    8013b6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 36                	pushl  (%esi)
  80137e:	e8 4e ff ff ff       	call   8012d1 <dev_lookup>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1c                	js     8013a8 <fd_close+0x71>
		if (dev->dev_close)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 40 10             	mov    0x10(%eax),%eax
  801392:	85 c0                	test   %eax,%eax
  801394:	74 0d                	je     8013a3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	ff d0                	call   *%eax
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	eb 05                	jmp    8013a8 <fd_close+0x71>
		else
			r = 0;
  8013a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	56                   	push   %esi
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 cb f8 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8013b3:	83 c4 10             	add    $0x10,%esp
}
  8013b6:	89 d8                	mov    %ebx,%eax
  8013b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5e                   	pop    %esi
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	ff 75 08             	pushl  0x8(%ebp)
  8013cc:	e8 aa fe ff ff       	call   80127b <fd_lookup>
  8013d1:	83 c4 08             	add    $0x8,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 10                	js     8013e8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	6a 01                	push   $0x1
  8013dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e0:	e8 52 ff ff ff       	call   801337 <fd_close>
  8013e5:	83 c4 10             	add    $0x10,%esp
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <close_all>:

void
close_all(void)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	53                   	push   %ebx
  8013fa:	e8 c0 ff ff ff       	call   8013bf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ff:	43                   	inc    %ebx
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	83 fb 20             	cmp    $0x20,%ebx
  801406:	75 ee                	jne    8013f6 <close_all+0xc>
		close(i);
}
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 2c             	sub    $0x2c,%esp
  801416:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801419:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 56 fe ff ff       	call   80127b <fd_lookup>
  801425:	89 c3                	mov    %eax,%ebx
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	0f 88 c0 00 00 00    	js     8014f2 <dup+0xe5>
		return r;
	close(newfdnum);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	57                   	push   %edi
  801436:	e8 84 ff ff ff       	call   8013bf <close>

	newfd = INDEX2FD(newfdnum);
  80143b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801441:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801444:	83 c4 04             	add    $0x4,%esp
  801447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144a:	e8 a1 fd ff ff       	call   8011f0 <fd2data>
  80144f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801451:	89 34 24             	mov    %esi,(%esp)
  801454:	e8 97 fd ff ff       	call   8011f0 <fd2data>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	c1 e8 16             	shr    $0x16,%eax
  801464:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146b:	a8 01                	test   $0x1,%al
  80146d:	74 37                	je     8014a6 <dup+0x99>
  80146f:	89 d8                	mov    %ebx,%eax
  801471:	c1 e8 0c             	shr    $0xc,%eax
  801474:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147b:	f6 c2 01             	test   $0x1,%dl
  80147e:	74 26                	je     8014a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801480:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	25 07 0e 00 00       	and    $0xe07,%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 d4             	pushl  -0x2c(%ebp)
  801493:	6a 00                	push   $0x0
  801495:	53                   	push   %ebx
  801496:	6a 00                	push   $0x0
  801498:	e8 bb f7 ff ff       	call   800c58 <sys_page_map>
  80149d:	89 c3                	mov    %eax,%ebx
  80149f:	83 c4 20             	add    $0x20,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 2d                	js     8014d3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 ea 0c             	shr    $0xc,%edx
  8014ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014be:	52                   	push   %edx
  8014bf:	56                   	push   %esi
  8014c0:	6a 00                	push   $0x0
  8014c2:	50                   	push   %eax
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 8e f7 ff ff       	call   800c58 <sys_page_map>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	83 c4 20             	add    $0x20,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	79 1d                	jns    8014f0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	56                   	push   %esi
  8014d7:	6a 00                	push   $0x0
  8014d9:	e8 a0 f7 ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014de:	83 c4 08             	add    $0x8,%esp
  8014e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e4:	6a 00                	push   $0x0
  8014e6:	e8 93 f7 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb 02                	jmp    8014f2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014f0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f2:	89 d8                	mov    %ebx,%eax
  8014f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 14             	sub    $0x14,%esp
  801503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	53                   	push   %ebx
  80150b:	e8 6b fd ff ff       	call   80127b <fd_lookup>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 67                	js     80157e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	ff 30                	pushl  (%eax)
  801523:	e8 a9 fd ff ff       	call   8012d1 <dev_lookup>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 4f                	js     80157e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	8b 50 08             	mov    0x8(%eax),%edx
  801535:	83 e2 03             	and    $0x3,%edx
  801538:	83 fa 01             	cmp    $0x1,%edx
  80153b:	75 21                	jne    80155e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153d:	a1 08 40 80 00       	mov    0x804008,%eax
  801542:	8b 40 48             	mov    0x48(%eax),%eax
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	53                   	push   %ebx
  801549:	50                   	push   %eax
  80154a:	68 6d 27 80 00       	push   $0x80276d
  80154f:	e8 a8 ec ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 20                	jmp    80157e <read+0x82>
	}
	if (!dev->dev_read)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 52 08             	mov    0x8(%edx),%edx
  801564:	85 d2                	test   %edx,%edx
  801566:	74 11                	je     801579 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	ff 75 10             	pushl  0x10(%ebp)
  80156e:	ff 75 0c             	pushl  0xc(%ebp)
  801571:	50                   	push   %eax
  801572:	ff d2                	call   *%edx
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	eb 05                	jmp    80157e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801579:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	57                   	push   %edi
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801592:	85 f6                	test   %esi,%esi
  801594:	74 31                	je     8015c7 <readn+0x44>
  801596:	b8 00 00 00 00       	mov    $0x0,%eax
  80159b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	89 f2                	mov    %esi,%edx
  8015a5:	29 c2                	sub    %eax,%edx
  8015a7:	52                   	push   %edx
  8015a8:	03 45 0c             	add    0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	57                   	push   %edi
  8015ad:	e8 4a ff ff ff       	call   8014fc <read>
		if (m < 0)
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 17                	js     8015d0 <readn+0x4d>
			return m;
		if (m == 0)
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	74 11                	je     8015ce <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bd:	01 c3                	add    %eax,%ebx
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	39 f3                	cmp    %esi,%ebx
  8015c3:	72 db                	jb     8015a0 <readn+0x1d>
  8015c5:	eb 09                	jmp    8015d0 <readn+0x4d>
  8015c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cc:	eb 02                	jmp    8015d0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015ce:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d3:	5b                   	pop    %ebx
  8015d4:	5e                   	pop    %esi
  8015d5:	5f                   	pop    %edi
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 14             	sub    $0x14,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	53                   	push   %ebx
  8015e7:	e8 8f fc ff ff       	call   80127b <fd_lookup>
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 62                	js     801655 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fd:	ff 30                	pushl  (%eax)
  8015ff:	e8 cd fc ff ff       	call   8012d1 <dev_lookup>
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 4a                	js     801655 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801612:	75 21                	jne    801635 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801614:	a1 08 40 80 00       	mov    0x804008,%eax
  801619:	8b 40 48             	mov    0x48(%eax),%eax
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	53                   	push   %ebx
  801620:	50                   	push   %eax
  801621:	68 89 27 80 00       	push   $0x802789
  801626:	e8 d1 eb ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801633:	eb 20                	jmp    801655 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801635:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801638:	8b 52 0c             	mov    0xc(%edx),%edx
  80163b:	85 d2                	test   %edx,%edx
  80163d:	74 11                	je     801650 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	ff 75 10             	pushl  0x10(%ebp)
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	50                   	push   %eax
  801649:	ff d2                	call   *%edx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 05                	jmp    801655 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801650:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <seek>:

int
seek(int fdnum, off_t offset)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801660:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 0f fc ff ff       	call   80127b <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 0e                	js     801681 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801673:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
  801679:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	e8 e4 fb ff ff       	call   80127b <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 5f                	js     8016fd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a8:	ff 30                	pushl  (%eax)
  8016aa:	e8 22 fc ff ff       	call   8012d1 <dev_lookup>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 47                	js     8016fd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016bd:	75 21                	jne    8016e0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016bf:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c4:	8b 40 48             	mov    0x48(%eax),%eax
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	53                   	push   %ebx
  8016cb:	50                   	push   %eax
  8016cc:	68 4c 27 80 00       	push   $0x80274c
  8016d1:	e8 26 eb ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016de:	eb 1d                	jmp    8016fd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e3:	8b 52 18             	mov    0x18(%edx),%edx
  8016e6:	85 d2                	test   %edx,%edx
  8016e8:	74 0e                	je     8016f8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	50                   	push   %eax
  8016f1:	ff d2                	call   *%edx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	eb 05                	jmp    8016fd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	83 ec 14             	sub    $0x14,%esp
  801709:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	ff 75 08             	pushl  0x8(%ebp)
  801713:	e8 63 fb ff ff       	call   80127b <fd_lookup>
  801718:	83 c4 08             	add    $0x8,%esp
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 52                	js     801771 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801729:	ff 30                	pushl  (%eax)
  80172b:	e8 a1 fb ff ff       	call   8012d1 <dev_lookup>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 3a                	js     801771 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173e:	74 2c                	je     80176c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801740:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801743:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174a:	00 00 00 
	stat->st_isdir = 0;
  80174d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801754:	00 00 00 
	stat->st_dev = dev;
  801757:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	53                   	push   %ebx
  801761:	ff 75 f0             	pushl  -0x10(%ebp)
  801764:	ff 50 14             	call   *0x14(%eax)
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	eb 05                	jmp    801771 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80176c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	6a 00                	push   $0x0
  801780:	ff 75 08             	pushl  0x8(%ebp)
  801783:	e8 78 01 00 00       	call   801900 <open>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 1b                	js     8017ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	50                   	push   %eax
  801798:	e8 65 ff ff ff       	call   801702 <fstat>
  80179d:	89 c6                	mov    %eax,%esi
	close(fd);
  80179f:	89 1c 24             	mov    %ebx,(%esp)
  8017a2:	e8 18 fc ff ff       	call   8013bf <close>
	return r;
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	89 f3                	mov    %esi,%ebx
}
  8017ac:	89 d8                	mov    %ebx,%eax
  8017ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    
  8017b5:	00 00                	add    %al,(%eax)
	...

008017b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c8:	75 12                	jne    8017dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	6a 01                	push   $0x1
  8017cf:	e8 ae f9 ff ff       	call   801182 <ipc_find_env>
  8017d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017dc:	6a 07                	push   $0x7
  8017de:	68 00 50 80 00       	push   $0x805000
  8017e3:	53                   	push   %ebx
  8017e4:	ff 35 00 40 80 00    	pushl  0x804000
  8017ea:	e8 3e f9 ff ff       	call   80112d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017ef:	83 c4 0c             	add    $0xc,%esp
  8017f2:	6a 00                	push   $0x0
  8017f4:	56                   	push   %esi
  8017f5:	6a 00                	push   $0x0
  8017f7:	e8 bc f8 ff ff       	call   8010b8 <ipc_recv>
}
  8017fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ff:	5b                   	pop    %ebx
  801800:	5e                   	pop    %esi
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 05 00 00 00       	mov    $0x5,%eax
  801822:	e8 91 ff ff ff       	call   8017b8 <fsipc>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 2c                	js     801857 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	53                   	push   %ebx
  801834:	e8 79 ef ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801839:	a1 80 50 80 00       	mov    0x805080,%eax
  80183e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801844:	a1 84 50 80 00       	mov    0x805084,%eax
  801849:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 06 00 00 00       	mov    $0x6,%eax
  801877:	e8 3c ff ff ff       	call   8017b8 <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	56                   	push   %esi
  801882:	53                   	push   %ebx
  801883:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	8b 40 0c             	mov    0xc(%eax),%eax
  80188c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801891:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a1:	e8 12 ff ff ff       	call   8017b8 <fsipc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 4b                	js     8018f7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ac:	39 c6                	cmp    %eax,%esi
  8018ae:	73 16                	jae    8018c6 <devfile_read+0x48>
  8018b0:	68 b8 27 80 00       	push   $0x8027b8
  8018b5:	68 bf 27 80 00       	push   $0x8027bf
  8018ba:	6a 7d                	push   $0x7d
  8018bc:	68 d4 27 80 00       	push   $0x8027d4
  8018c1:	e8 ce 05 00 00       	call   801e94 <_panic>
	assert(r <= PGSIZE);
  8018c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cb:	7e 16                	jle    8018e3 <devfile_read+0x65>
  8018cd:	68 df 27 80 00       	push   $0x8027df
  8018d2:	68 bf 27 80 00       	push   $0x8027bf
  8018d7:	6a 7e                	push   $0x7e
  8018d9:	68 d4 27 80 00       	push   $0x8027d4
  8018de:	e8 b1 05 00 00       	call   801e94 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018e3:	83 ec 04             	sub    $0x4,%esp
  8018e6:	50                   	push   %eax
  8018e7:	68 00 50 80 00       	push   $0x805000
  8018ec:	ff 75 0c             	pushl  0xc(%ebp)
  8018ef:	e8 7f f0 ff ff       	call   800973 <memmove>
	return r;
  8018f4:	83 c4 10             	add    $0x10,%esp
}
  8018f7:	89 d8                	mov    %ebx,%eax
  8018f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	83 ec 1c             	sub    $0x1c,%esp
  801908:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80190b:	56                   	push   %esi
  80190c:	e8 4f ee ff ff       	call   800760 <strlen>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801919:	7f 65                	jg     801980 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801921:	50                   	push   %eax
  801922:	e8 e1 f8 ff ff       	call   801208 <fd_alloc>
  801927:	89 c3                	mov    %eax,%ebx
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 55                	js     801985 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	56                   	push   %esi
  801934:	68 00 50 80 00       	push   $0x805000
  801939:	e8 74 ee ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80193e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801941:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801946:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801949:	b8 01 00 00 00       	mov    $0x1,%eax
  80194e:	e8 65 fe ff ff       	call   8017b8 <fsipc>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	79 12                	jns    80196e <open+0x6e>
		fd_close(fd, 0);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	6a 00                	push   $0x0
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 ce f9 ff ff       	call   801337 <fd_close>
		return r;
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	eb 17                	jmp    801985 <open+0x85>
	}

	return fd2num(fd);
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	ff 75 f4             	pushl  -0xc(%ebp)
  801974:	e8 67 f8 ff ff       	call   8011e0 <fd2num>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 05                	jmp    801985 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801980:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801985:	89 d8                	mov    %ebx,%eax
  801987:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    
	...

00801990 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	e8 4d f8 ff ff       	call   8011f0 <fd2data>
  8019a3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019a5:	83 c4 08             	add    $0x8,%esp
  8019a8:	68 eb 27 80 00       	push   $0x8027eb
  8019ad:	56                   	push   %esi
  8019ae:	e8 ff ed ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019b6:	2b 03                	sub    (%ebx),%eax
  8019b8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019be:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019c5:	00 00 00 
	stat->st_dev = &devpipe;
  8019c8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019cf:	30 80 00 
	return 0;
}
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e8:	53                   	push   %ebx
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 8e f2 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f0:	89 1c 24             	mov    %ebx,(%esp)
  8019f3:	e8 f8 f7 ff ff       	call   8011f0 <fd2data>
  8019f8:	83 c4 08             	add    $0x8,%esp
  8019fb:	50                   	push   %eax
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 7b f2 ff ff       	call   800c7e <sys_page_unmap>
}
  801a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	57                   	push   %edi
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 1c             	sub    $0x1c,%esp
  801a11:	89 c7                	mov    %eax,%edi
  801a13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a16:	a1 08 40 80 00       	mov    0x804008,%eax
  801a1b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	57                   	push   %edi
  801a22:	e8 49 05 00 00       	call   801f70 <pageref>
  801a27:	89 c6                	mov    %eax,%esi
  801a29:	83 c4 04             	add    $0x4,%esp
  801a2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a2f:	e8 3c 05 00 00       	call   801f70 <pageref>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	39 c6                	cmp    %eax,%esi
  801a39:	0f 94 c0             	sete   %al
  801a3c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a3f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a45:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a48:	39 cb                	cmp    %ecx,%ebx
  801a4a:	75 08                	jne    801a54 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5f                   	pop    %edi
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a54:	83 f8 01             	cmp    $0x1,%eax
  801a57:	75 bd                	jne    801a16 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a59:	8b 42 58             	mov    0x58(%edx),%eax
  801a5c:	6a 01                	push   $0x1
  801a5e:	50                   	push   %eax
  801a5f:	53                   	push   %ebx
  801a60:	68 f2 27 80 00       	push   $0x8027f2
  801a65:	e8 92 e7 ff ff       	call   8001fc <cprintf>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	eb a7                	jmp    801a16 <_pipeisclosed+0xe>

00801a6f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 28             	sub    $0x28,%esp
  801a78:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a7b:	56                   	push   %esi
  801a7c:	e8 6f f7 ff ff       	call   8011f0 <fd2data>
  801a81:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a8a:	75 4a                	jne    801ad6 <devpipe_write+0x67>
  801a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a91:	eb 56                	jmp    801ae9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a93:	89 da                	mov    %ebx,%edx
  801a95:	89 f0                	mov    %esi,%eax
  801a97:	e8 6c ff ff ff       	call   801a08 <_pipeisclosed>
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	75 4d                	jne    801aed <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa0:	e8 68 f1 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa5:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa8:	8b 13                	mov    (%ebx),%edx
  801aaa:	83 c2 20             	add    $0x20,%edx
  801aad:	39 d0                	cmp    %edx,%eax
  801aaf:	73 e2                	jae    801a93 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab1:	89 c2                	mov    %eax,%edx
  801ab3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ab9:	79 05                	jns    801ac0 <devpipe_write+0x51>
  801abb:	4a                   	dec    %edx
  801abc:	83 ca e0             	or     $0xffffffe0,%edx
  801abf:	42                   	inc    %edx
  801ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ac6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aca:	40                   	inc    %eax
  801acb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ace:	47                   	inc    %edi
  801acf:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ad2:	77 07                	ja     801adb <devpipe_write+0x6c>
  801ad4:	eb 13                	jmp    801ae9 <devpipe_write+0x7a>
  801ad6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801adb:	8b 43 04             	mov    0x4(%ebx),%eax
  801ade:	8b 13                	mov    (%ebx),%edx
  801ae0:	83 c2 20             	add    $0x20,%edx
  801ae3:	39 d0                	cmp    %edx,%eax
  801ae5:	73 ac                	jae    801a93 <devpipe_write+0x24>
  801ae7:	eb c8                	jmp    801ab1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae9:	89 f8                	mov    %edi,%eax
  801aeb:	eb 05                	jmp    801af2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	57                   	push   %edi
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	83 ec 18             	sub    $0x18,%esp
  801b03:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b06:	57                   	push   %edi
  801b07:	e8 e4 f6 ff ff       	call   8011f0 <fd2data>
  801b0c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b15:	75 44                	jne    801b5b <devpipe_read+0x61>
  801b17:	be 00 00 00 00       	mov    $0x0,%esi
  801b1c:	eb 4f                	jmp    801b6d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b1e:	89 f0                	mov    %esi,%eax
  801b20:	eb 54                	jmp    801b76 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b22:	89 da                	mov    %ebx,%edx
  801b24:	89 f8                	mov    %edi,%eax
  801b26:	e8 dd fe ff ff       	call   801a08 <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 42                	jne    801b71 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2f:	e8 d9 f0 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b34:	8b 03                	mov    (%ebx),%eax
  801b36:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b39:	74 e7                	je     801b22 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b40:	79 05                	jns    801b47 <devpipe_read+0x4d>
  801b42:	48                   	dec    %eax
  801b43:	83 c8 e0             	or     $0xffffffe0,%eax
  801b46:	40                   	inc    %eax
  801b47:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b51:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	46                   	inc    %esi
  801b54:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b57:	77 07                	ja     801b60 <devpipe_read+0x66>
  801b59:	eb 12                	jmp    801b6d <devpipe_read+0x73>
  801b5b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b60:	8b 03                	mov    (%ebx),%eax
  801b62:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b65:	75 d4                	jne    801b3b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b67:	85 f6                	test   %esi,%esi
  801b69:	75 b3                	jne    801b1e <devpipe_read+0x24>
  801b6b:	eb b5                	jmp    801b22 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6d:	89 f0                	mov    %esi,%eax
  801b6f:	eb 05                	jmp    801b76 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5f                   	pop    %edi
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 28             	sub    $0x28,%esp
  801b87:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 75 f6 ff ff       	call   801208 <fd_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 24 01 00 00    	js     801cc4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	68 07 04 00 00       	push   $0x407
  801ba8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bab:	6a 00                	push   $0x0
  801bad:	e8 82 f0 ff ff       	call   800c34 <sys_page_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 05 01 00 00    	js     801cc4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 3d f6 ff ff       	call   801208 <fd_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 dc 00 00 00    	js     801cb4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 07 04 00 00       	push   $0x407
  801be0:	ff 75 e0             	pushl  -0x20(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 4a f0 ff ff       	call   800c34 <sys_page_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 bd 00 00 00    	js     801cb4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bfd:	e8 ee f5 ff ff       	call   8011f0 <fd2data>
  801c02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 c4 0c             	add    $0xc,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	50                   	push   %eax
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 20 f0 ff ff       	call   800c34 <sys_page_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 83 00 00 00    	js     801ca4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	ff 75 e0             	pushl  -0x20(%ebp)
  801c27:	e8 c4 f5 ff ff       	call   8011f0 <fd2data>
  801c2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c33:	50                   	push   %eax
  801c34:	6a 00                	push   $0x0
  801c36:	56                   	push   %esi
  801c37:	6a 00                	push   $0x0
  801c39:	e8 1a f0 ff ff       	call   800c58 <sys_page_map>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 4f                	js     801c96 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c77:	e8 64 f5 ff ff       	call   8011e0 <fd2num>
  801c7c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c7e:	83 c4 04             	add    $0x4,%esp
  801c81:	ff 75 e0             	pushl  -0x20(%ebp)
  801c84:	e8 57 f5 ff ff       	call   8011e0 <fd2num>
  801c89:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c94:	eb 2e                	jmp    801cc4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	56                   	push   %esi
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 dd ef ff ff       	call   800c7e <sys_page_unmap>
  801ca1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	ff 75 e0             	pushl  -0x20(%ebp)
  801caa:	6a 00                	push   $0x0
  801cac:	e8 cd ef ff ff       	call   800c7e <sys_page_unmap>
  801cb1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 bd ef ff ff       	call   800c7e <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd7:	50                   	push   %eax
  801cd8:	ff 75 08             	pushl  0x8(%ebp)
  801cdb:	e8 9b f5 ff ff       	call   80127b <fd_lookup>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 18                	js     801cff <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	e8 fe f4 ff ff       	call   8011f0 <fd2data>
	return _pipeisclosed(fd, p);
  801cf2:	89 c2                	mov    %eax,%edx
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	e8 0c fd ff ff       	call   801a08 <_pipeisclosed>
  801cfc:	83 c4 10             	add    $0x10,%esp
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    
  801d01:	00 00                	add    %al,(%eax)
	...

00801d04 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d14:	68 0a 28 80 00       	push   $0x80280a
  801d19:	ff 75 0c             	pushl  0xc(%ebp)
  801d1c:	e8 91 ea ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d38:	74 45                	je     801d7f <devcons_write+0x57>
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d44:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d4d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d4f:	83 fb 7f             	cmp    $0x7f,%ebx
  801d52:	76 05                	jbe    801d59 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d54:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	53                   	push   %ebx
  801d5d:	03 45 0c             	add    0xc(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	57                   	push   %edi
  801d62:	e8 0c ec ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801d67:	83 c4 08             	add    $0x8,%esp
  801d6a:	53                   	push   %ebx
  801d6b:	57                   	push   %edi
  801d6c:	e8 0c ee ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d71:	01 de                	add    %ebx,%esi
  801d73:	89 f0                	mov    %esi,%eax
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d7b:	72 cd                	jb     801d4a <devcons_write+0x22>
  801d7d:	eb 05                	jmp    801d84 <devcons_write+0x5c>
  801d7f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d98:	75 07                	jne    801da1 <devcons_read+0x13>
  801d9a:	eb 25                	jmp    801dc1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d9c:	e8 6c ee ff ff       	call   800c0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da1:	e8 fd ed ff ff       	call   800ba3 <sys_cgetc>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	74 f2                	je     801d9c <devcons_read+0xe>
  801daa:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 1d                	js     801dcd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801db0:	83 f8 04             	cmp    $0x4,%eax
  801db3:	74 13                	je     801dc8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801db5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db8:	88 10                	mov    %dl,(%eax)
	return 1;
  801dba:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbf:	eb 0c                	jmp    801dcd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc6:	eb 05                	jmp    801dcd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ddb:	6a 01                	push   $0x1
  801ddd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	e8 97 ed ff ff       	call   800b7d <sys_cputs>
  801de6:	83 c4 10             	add    $0x10,%esp
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <getchar>:

int
getchar(void)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df1:	6a 01                	push   $0x1
  801df3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df6:	50                   	push   %eax
  801df7:	6a 00                	push   $0x0
  801df9:	e8 fe f6 ff ff       	call   8014fc <read>
	if (r < 0)
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 0f                	js     801e14 <getchar+0x29>
		return r;
	if (r < 1)
  801e05:	85 c0                	test   %eax,%eax
  801e07:	7e 06                	jle    801e0f <getchar+0x24>
		return -E_EOF;
	return c;
  801e09:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e0d:	eb 05                	jmp    801e14 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e0f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	ff 75 08             	pushl  0x8(%ebp)
  801e23:	e8 53 f4 ff ff       	call   80127b <fd_lookup>
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 11                	js     801e40 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e32:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e38:	39 10                	cmp    %edx,(%eax)
  801e3a:	0f 94 c0             	sete   %al
  801e3d:	0f b6 c0             	movzbl %al,%eax
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <opencons>:

int
opencons(void)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	e8 b7 f3 ff ff       	call   801208 <fd_alloc>
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 3a                	js     801e92 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e58:	83 ec 04             	sub    $0x4,%esp
  801e5b:	68 07 04 00 00       	push   $0x407
  801e60:	ff 75 f4             	pushl  -0xc(%ebp)
  801e63:	6a 00                	push   $0x0
  801e65:	e8 ca ed ff ff       	call   800c34 <sys_page_alloc>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 21                	js     801e92 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e71:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	50                   	push   %eax
  801e8a:	e8 51 f3 ff ff       	call   8011e0 <fd2num>
  801e8f:	83 c4 10             	add    $0x10,%esp
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e99:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e9c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ea2:	e8 42 ed ff ff       	call   800be9 <sys_getenvid>
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	ff 75 0c             	pushl  0xc(%ebp)
  801ead:	ff 75 08             	pushl  0x8(%ebp)
  801eb0:	53                   	push   %ebx
  801eb1:	50                   	push   %eax
  801eb2:	68 18 28 80 00       	push   $0x802818
  801eb7:	e8 40 e3 ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ebc:	83 c4 18             	add    $0x18,%esp
  801ebf:	56                   	push   %esi
  801ec0:	ff 75 10             	pushl  0x10(%ebp)
  801ec3:	e8 e3 e2 ff ff       	call   8001ab <vcprintf>
	cprintf("\n");
  801ec8:	c7 04 24 03 28 80 00 	movl   $0x802803,(%esp)
  801ecf:	e8 28 e3 ff ff       	call   8001fc <cprintf>
  801ed4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed7:	cc                   	int3   
  801ed8:	eb fd                	jmp    801ed7 <_panic+0x43>
	...

00801edc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee9:	75 52                	jne    801f3d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801eeb:	83 ec 04             	sub    $0x4,%esp
  801eee:	6a 07                	push   $0x7
  801ef0:	68 00 f0 bf ee       	push   $0xeebff000
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 38 ed ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) {
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	79 12                	jns    801f15 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801f03:	50                   	push   %eax
  801f04:	68 3b 28 80 00       	push   $0x80283b
  801f09:	6a 24                	push   $0x24
  801f0b:	68 56 28 80 00       	push   $0x802856
  801f10:	e8 7f ff ff ff       	call   801e94 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	68 48 1f 80 00       	push   $0x801f48
  801f1d:	6a 00                	push   $0x0
  801f1f:	e8 c3 ed ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	79 12                	jns    801f3d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f2b:	50                   	push   %eax
  801f2c:	68 64 28 80 00       	push   $0x802864
  801f31:	6a 2a                	push   $0x2a
  801f33:	68 56 28 80 00       	push   $0x802856
  801f38:	e8 57 ff ff ff       	call   801e94 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f40:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    
	...

00801f48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f49:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f50:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f53:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f57:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f5a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f5e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f62:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f64:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f67:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f68:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f6b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f6c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f6d:	c3                   	ret    
	...

00801f70 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f76:	89 c2                	mov    %eax,%edx
  801f78:	c1 ea 16             	shr    $0x16,%edx
  801f7b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f82:	f6 c2 01             	test   $0x1,%dl
  801f85:	74 1e                	je     801fa5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f87:	c1 e8 0c             	shr    $0xc,%eax
  801f8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f91:	a8 01                	test   $0x1,%al
  801f93:	74 17                	je     801fac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f95:	c1 e8 0c             	shr    $0xc,%eax
  801f98:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f9f:	ef 
  801fa0:	0f b7 c0             	movzwl %ax,%eax
  801fa3:	eb 0c                	jmp    801fb1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	eb 05                	jmp    801fb1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    
	...

00801fb4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	83 ec 10             	sub    $0x10,%esp
  801fbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fc2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	75 2e                	jne    802000 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fd2:	39 f1                	cmp    %esi,%ecx
  801fd4:	77 5a                	ja     802030 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fd6:	85 c9                	test   %ecx,%ecx
  801fd8:	75 0b                	jne    801fe5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fda:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdf:	31 d2                	xor    %edx,%edx
  801fe1:	f7 f1                	div    %ecx
  801fe3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fe5:	31 d2                	xor    %edx,%edx
  801fe7:	89 f0                	mov    %esi,%eax
  801fe9:	f7 f1                	div    %ecx
  801feb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fed:	89 f8                	mov    %edi,%eax
  801fef:	f7 f1                	div    %ecx
  801ff1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ff3:	89 f8                	mov    %edi,%eax
  801ff5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    
  801ffe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802000:	39 f0                	cmp    %esi,%eax
  802002:	77 1c                	ja     802020 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802004:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	75 3c                	jne    802048 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80200c:	39 f0                	cmp    %esi,%eax
  80200e:	0f 82 90 00 00 00    	jb     8020a4 <__udivdi3+0xf0>
  802014:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802017:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80201a:	0f 86 84 00 00 00    	jbe    8020a4 <__udivdi3+0xf0>
  802020:	31 f6                	xor    %esi,%esi
  802022:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802024:	89 f8                	mov    %edi,%eax
  802026:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	5e                   	pop    %esi
  80202c:	5f                   	pop    %edi
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    
  80202f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802030:	89 f2                	mov    %esi,%edx
  802032:	89 f8                	mov    %edi,%eax
  802034:	f7 f1                	div    %ecx
  802036:	89 c7                	mov    %eax,%edi
  802038:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80203a:	89 f8                	mov    %edi,%eax
  80203c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	c9                   	leave  
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802048:	89 f9                	mov    %edi,%ecx
  80204a:	d3 e0                	shl    %cl,%eax
  80204c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80204f:	b8 20 00 00 00       	mov    $0x20,%eax
  802054:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802056:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802059:	88 c1                	mov    %al,%cl
  80205b:	d3 ea                	shr    %cl,%edx
  80205d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802060:	09 ca                	or     %ecx,%edx
  802062:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802065:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802068:	89 f9                	mov    %edi,%ecx
  80206a:	d3 e2                	shl    %cl,%edx
  80206c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80206f:	89 f2                	mov    %esi,%edx
  802071:	88 c1                	mov    %al,%cl
  802073:	d3 ea                	shr    %cl,%edx
  802075:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802078:	89 f2                	mov    %esi,%edx
  80207a:	89 f9                	mov    %edi,%ecx
  80207c:	d3 e2                	shl    %cl,%edx
  80207e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802081:	88 c1                	mov    %al,%cl
  802083:	d3 ee                	shr    %cl,%esi
  802085:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802087:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80208a:	89 f0                	mov    %esi,%eax
  80208c:	89 ca                	mov    %ecx,%edx
  80208e:	f7 75 ec             	divl   -0x14(%ebp)
  802091:	89 d1                	mov    %edx,%ecx
  802093:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802095:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802098:	39 d1                	cmp    %edx,%ecx
  80209a:	72 28                	jb     8020c4 <__udivdi3+0x110>
  80209c:	74 1a                	je     8020b8 <__udivdi3+0x104>
  80209e:	89 f7                	mov    %esi,%edi
  8020a0:	31 f6                	xor    %esi,%esi
  8020a2:	eb 80                	jmp    802024 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020a4:	31 f6                	xor    %esi,%esi
  8020a6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020ab:	89 f8                	mov    %edi,%eax
  8020ad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    
  8020b6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020bb:	89 f9                	mov    %edi,%ecx
  8020bd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020bf:	39 c2                	cmp    %eax,%edx
  8020c1:	73 db                	jae    80209e <__udivdi3+0xea>
  8020c3:	90                   	nop
		{
		  q0--;
  8020c4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020c7:	31 f6                	xor    %esi,%esi
  8020c9:	e9 56 ff ff ff       	jmp    802024 <__udivdi3+0x70>
	...

008020d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	57                   	push   %edi
  8020d4:	56                   	push   %esi
  8020d5:	83 ec 20             	sub    $0x20,%esp
  8020d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020db:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020e4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020ed:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ef:	85 ff                	test   %edi,%edi
  8020f1:	75 15                	jne    802108 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020f3:	39 f1                	cmp    %esi,%ecx
  8020f5:	0f 86 99 00 00 00    	jbe    802194 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020fb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020fd:	89 d0                	mov    %edx,%eax
  8020ff:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802101:	83 c4 20             	add    $0x20,%esp
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	c9                   	leave  
  802107:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802108:	39 f7                	cmp    %esi,%edi
  80210a:	0f 87 a4 00 00 00    	ja     8021b4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802110:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802113:	83 f0 1f             	xor    $0x1f,%eax
  802116:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802119:	0f 84 a1 00 00 00    	je     8021c0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80211f:	89 f8                	mov    %edi,%eax
  802121:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802124:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802126:	bf 20 00 00 00       	mov    $0x20,%edi
  80212b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80212e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 ea                	shr    %cl,%edx
  802135:	09 c2                	or     %eax,%edx
  802137:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802140:	d3 e0                	shl    %cl,%eax
  802142:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802145:	89 f2                	mov    %esi,%edx
  802147:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802149:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802151:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802154:	89 f9                	mov    %edi,%ecx
  802156:	d3 e8                	shr    %cl,%eax
  802158:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80215a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	f7 75 f0             	divl   -0x10(%ebp)
  802161:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802163:	f7 65 f4             	mull   -0xc(%ebp)
  802166:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802169:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80216b:	39 d6                	cmp    %edx,%esi
  80216d:	72 71                	jb     8021e0 <__umoddi3+0x110>
  80216f:	74 7f                	je     8021f0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802174:	29 c8                	sub    %ecx,%eax
  802176:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802178:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802183:	09 d0                	or     %edx,%eax
  802185:	89 f2                	mov    %esi,%edx
  802187:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80218a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80218c:	83 c4 20             	add    $0x20,%esp
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	c9                   	leave  
  802192:	c3                   	ret    
  802193:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802194:	85 c9                	test   %ecx,%ecx
  802196:	75 0b                	jne    8021a3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802198:	b8 01 00 00 00       	mov    $0x1,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	f7 f1                	div    %ecx
  8021a1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	31 d2                	xor    %edx,%edx
  8021a7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ac:	f7 f1                	div    %ecx
  8021ae:	e9 4a ff ff ff       	jmp    8020fd <__umoddi3+0x2d>
  8021b3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021b4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b6:	83 c4 20             	add    $0x20,%esp
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021c0:	39 f7                	cmp    %esi,%edi
  8021c2:	72 05                	jb     8021c9 <__umoddi3+0xf9>
  8021c4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021c7:	77 0c                	ja     8021d5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c9:	89 f2                	mov    %esi,%edx
  8021cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ce:	29 c8                	sub    %ecx,%eax
  8021d0:	19 fa                	sbb    %edi,%edx
  8021d2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d8:	83 c4 20             	add    $0x20,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    
  8021df:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021e8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021eb:	eb 84                	jmp    802171 <__umoddi3+0xa1>
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021f0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021f3:	72 eb                	jb     8021e0 <__umoddi3+0x110>
  8021f5:	89 f2                	mov    %esi,%edx
  8021f7:	e9 75 ff ff ff       	jmp    802171 <__umoddi3+0xa1>
