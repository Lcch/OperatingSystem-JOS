
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	68 60 1e 80 00       	push   $0x801e60
  80003f:	e8 f8 01 00 00       	call   80023c <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800044:	83 c4 10             	add    $0x10,%esp
  800047:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80004e:	75 11                	jne    800061 <umain+0x2d>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800050:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800055:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  80005c:	00 
  80005d:	74 19                	je     800078 <umain+0x44>
  80005f:	eb 05                	jmp    800066 <umain+0x32>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800061:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800066:	50                   	push   %eax
  800067:	68 db 1e 80 00       	push   $0x801edb
  80006c:	6a 11                	push   $0x11
  80006e:	68 f8 1e 80 00       	push   $0x801ef8
  800073:	e8 ec 00 00 00       	call   800164 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800078:	40                   	inc    %eax
  800079:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007e:	75 d5                	jne    800055 <umain+0x21>
  800080:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800085:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008c:	40                   	inc    %eax
  80008d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800092:	75 f1                	jne    800085 <umain+0x51>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800094:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  80009b:	75 10                	jne    8000ad <umain+0x79>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  80009d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000a2:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  8000a9:	74 19                	je     8000c4 <umain+0x90>
  8000ab:	eb 05                	jmp    8000b2 <umain+0x7e>
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000b2:	50                   	push   %eax
  8000b3:	68 80 1e 80 00       	push   $0x801e80
  8000b8:	6a 16                	push   $0x16
  8000ba:	68 f8 1e 80 00       	push   $0x801ef8
  8000bf:	e8 a0 00 00 00       	call   800164 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c4:	40                   	inc    %eax
  8000c5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000ca:	75 d6                	jne    8000a2 <umain+0x6e>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	68 a8 1e 80 00       	push   $0x801ea8
  8000d4:	e8 63 01 00 00       	call   80023c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d9:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000e0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e3:	83 c4 0c             	add    $0xc,%esp
  8000e6:	68 07 1f 80 00       	push   $0x801f07
  8000eb:	6a 1a                	push   $0x1a
  8000ed:	68 f8 1e 80 00       	push   $0x801ef8
  8000f2:	e8 6d 00 00 00       	call   800164 <_panic>
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800103:	e8 21 0b 00 00       	call   800c29 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	29 d0                	sub    %edx,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 f6                	test   %esi,%esi
  800125:	7e 07                	jle    80012e <libmain+0x36>
		binaryname = argv[0];
  800127:	8b 03                	mov    (%ebx),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	53                   	push   %ebx
  800132:	56                   	push   %esi
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
  80013d:	83 c4 10             	add    $0x10,%esp
}
  800140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	c9                   	leave  
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014e:	e8 93 0e 00 00       	call   800fe6 <close_all>
	sys_env_destroy(0);
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	6a 00                	push   $0x0
  800158:	e8 aa 0a 00 00       	call   800c07 <sys_env_destroy>
  80015d:	83 c4 10             	add    $0x10,%esp
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800169:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800172:	e8 b2 0a 00 00       	call   800c29 <sys_getenvid>
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	ff 75 0c             	pushl  0xc(%ebp)
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	53                   	push   %ebx
  800181:	50                   	push   %eax
  800182:	68 28 1f 80 00       	push   $0x801f28
  800187:	e8 b0 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	83 c4 18             	add    $0x18,%esp
  80018f:	56                   	push   %esi
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	e8 53 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 f6 1e 80 00 	movl   $0x801ef6,(%esp)
  80019f:	e8 98 00 00 00       	call   80023c <cprintf>
  8001a4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x43>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 1a                	jne    8001e3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 e3 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e3:	ff 43 04             	incl   0x4(%ebx)
}
  8001e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	ff 75 0c             	pushl  0xc(%ebp)
  80020b:	ff 75 08             	pushl  0x8(%ebp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	50                   	push   %eax
  800215:	68 ac 01 80 00       	push   $0x8001ac
  80021a:	e8 82 01 00 00       	call   8003a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021f:	83 c4 08             	add    $0x8,%esp
  800222:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800228:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 89 09 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  800234:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800242:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800245:	50                   	push   %eax
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 9d ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800267:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800270:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800276:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80027d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800280:	72 0c                	jb     80028e <printnum+0x3e>
  800282:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800285:	76 07                	jbe    80028e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	4b                   	dec    %ebx
  800288:	85 db                	test   %ebx,%ebx
  80028a:	7f 31                	jg     8002bd <printnum+0x6d>
  80028c:	eb 3f                	jmp    8002cd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	57                   	push   %edi
  800292:	4b                   	dec    %ebx
  800293:	53                   	push   %ebx
  800294:	50                   	push   %eax
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029b:	ff 75 d0             	pushl  -0x30(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 53 19 00 00       	call   801bfc <__udivdi3>
  8002a9:	83 c4 18             	add    $0x18,%esp
  8002ac:	52                   	push   %edx
  8002ad:	50                   	push   %eax
  8002ae:	89 f2                	mov    %esi,%edx
  8002b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b3:	e8 98 ff ff ff       	call   800250 <printnum>
  8002b8:	83 c4 20             	add    $0x20,%esp
  8002bb:	eb 10                	jmp    8002cd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	57                   	push   %edi
  8002c2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c5:	4b                   	dec    %ebx
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	85 db                	test   %ebx,%ebx
  8002cb:	7f f0                	jg     8002bd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e0:	e8 33 1a 00 00       	call   801d18 <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 4b 1f 80 00 	movsbl 0x801f4b(%eax),%eax
  8002ef:	50                   	push   %eax
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002f3:	83 c4 10             	add    $0x10,%esp
}
  8002f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f9:	5b                   	pop    %ebx
  8002fa:	5e                   	pop    %esi
  8002fb:	5f                   	pop    %edi
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800301:	83 fa 01             	cmp    $0x1,%edx
  800304:	7e 0e                	jle    800314 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	8b 52 04             	mov    0x4(%edx),%edx
  800312:	eb 22                	jmp    800336 <getuint+0x38>
	else if (lflag)
  800314:	85 d2                	test   %edx,%edx
  800316:	74 10                	je     800328 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	eb 0e                	jmp    800336 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033b:	83 fa 01             	cmp    $0x1,%edx
  80033e:	7e 0e                	jle    80034e <getint+0x16>
		return va_arg(*ap, long long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 08             	lea    0x8(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	8b 52 04             	mov    0x4(%edx),%edx
  80034c:	eb 1a                	jmp    800368 <getint+0x30>
	else if (lflag)
  80034e:	85 d2                	test   %edx,%edx
  800350:	74 0c                	je     80035e <getint+0x26>
		return va_arg(*ap, long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	99                   	cltd   
  80035c:	eb 0a                	jmp    800368 <getint+0x30>
	else
		return va_arg(*ap, int);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 04             	lea    0x4(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	99                   	cltd   
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 08                	jae    800382 <sprintputch+0x18>
		*b->buf++ = ch;
  80037a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037d:	88 0a                	mov    %cl,(%edx)
  80037f:	42                   	inc    %edx
  800380:	89 10                	mov    %edx,(%eax)
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038d:	50                   	push   %eax
  80038e:	ff 75 10             	pushl  0x10(%ebp)
  800391:	ff 75 0c             	pushl  0xc(%ebp)
  800394:	ff 75 08             	pushl  0x8(%ebp)
  800397:	e8 05 00 00 00       	call   8003a1 <vprintfmt>
	va_end(ap);
  80039c:	83 c4 10             	add    $0x10,%esp
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    

008003a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 2c             	sub    $0x2c,%esp
  8003aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b0:	eb 13                	jmp    8003c5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	0f 84 6d 03 00 00    	je     800727 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	57                   	push   %edi
  8003be:	50                   	push   %eax
  8003bf:	ff 55 08             	call   *0x8(%ebp)
  8003c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	0f b6 06             	movzbl (%esi),%eax
  8003c8:	46                   	inc    %esi
  8003c9:	83 f8 25             	cmp    $0x25,%eax
  8003cc:	75 e4                	jne    8003b2 <vprintfmt+0x11>
  8003ce:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003e0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ec:	eb 28                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003f4:	eb 20                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003fc:	eb 18                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800400:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800407:	eb 0d                	jmp    800416 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800409:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8a 06                	mov    (%esi),%al
  800418:	0f b6 d0             	movzbl %al,%edx
  80041b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80041e:	83 e8 23             	sub    $0x23,%eax
  800421:	3c 55                	cmp    $0x55,%al
  800423:	0f 87 e0 02 00 00    	ja     800709 <vprintfmt+0x368>
  800429:	0f b6 c0             	movzbl %al,%eax
  80042c:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800433:	83 ea 30             	sub    $0x30,%edx
  800436:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800439:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80043c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 44                	ja     800488 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 de                	mov    %ebx,%esi
  800446:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800449:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80044a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80044d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800451:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800454:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800457:	83 fb 09             	cmp    $0x9,%ebx
  80045a:	76 ed                	jbe    800449 <vprintfmt+0xa8>
  80045c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80045f:	eb 29                	jmp    80048a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800471:	eb 17                	jmp    80048a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800473:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800477:	78 85                	js     8003fe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	89 de                	mov    %ebx,%esi
  80047b:	eb 99                	jmp    800416 <vprintfmt+0x75>
  80047d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800486:	eb 8e                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80048a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048e:	79 86                	jns    800416 <vprintfmt+0x75>
  800490:	e9 74 ff ff ff       	jmp    800409 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800495:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	89 de                	mov    %ebx,%esi
  800498:	e9 79 ff ff ff       	jmp    800416 <vprintfmt+0x75>
  80049d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	ff 30                	pushl  (%eax)
  8004af:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b8:	e9 08 ff ff ff       	jmp    8003c5 <vprintfmt+0x24>
  8004bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	79 02                	jns    8004d1 <vprintfmt+0x130>
  8004cf:	f7 d8                	neg    %eax
  8004d1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d3:	83 f8 0f             	cmp    $0xf,%eax
  8004d6:	7f 0b                	jg     8004e3 <vprintfmt+0x142>
  8004d8:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 1a                	jne    8004fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004e3:	52                   	push   %edx
  8004e4:	68 63 1f 80 00       	push   $0x801f63
  8004e9:	57                   	push   %edi
  8004ea:	ff 75 08             	pushl  0x8(%ebp)
  8004ed:	e8 92 fe ff ff       	call   800384 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 c8 fe ff ff       	jmp    8003c5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	50                   	push   %eax
  8004fe:	68 15 23 80 00       	push   $0x802315
  800503:	57                   	push   %edi
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 78 fe ff ff       	call   800384 <printfmt>
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800512:	e9 ae fe ff ff       	jmp    8003c5 <vprintfmt+0x24>
  800517:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80051a:	89 de                	mov    %ebx,%esi
  80051c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800530:	85 c0                	test   %eax,%eax
  800532:	75 07                	jne    80053b <vprintfmt+0x19a>
				p = "(null)";
  800534:	c7 45 d0 5c 1f 80 00 	movl   $0x801f5c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80053b:	85 db                	test   %ebx,%ebx
  80053d:	7e 42                	jle    800581 <vprintfmt+0x1e0>
  80053f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800543:	74 3c                	je     800581 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	51                   	push   %ecx
  800549:	ff 75 d0             	pushl  -0x30(%ebp)
  80054c:	e8 6f 02 00 00       	call   8007c0 <strnlen>
  800551:	29 c3                	sub    %eax,%ebx
  800553:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 db                	test   %ebx,%ebx
  80055b:	7e 24                	jle    800581 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80055d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800561:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800564:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	53                   	push   %ebx
  80056c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	4e                   	dec    %esi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 f6                	test   %esi,%esi
  800575:	7f f0                	jg     800567 <vprintfmt+0x1c6>
  800577:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80057a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800581:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800584:	0f be 02             	movsbl (%edx),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	75 47                	jne    8005d2 <vprintfmt+0x231>
  80058b:	eb 37                	jmp    8005c4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	74 16                	je     8005a9 <vprintfmt+0x208>
  800593:	8d 50 e0             	lea    -0x20(%eax),%edx
  800596:	83 fa 5e             	cmp    $0x5e,%edx
  800599:	76 0e                	jbe    8005a9 <vprintfmt+0x208>
					putch('?', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	6a 3f                	push   $0x3f
  8005a1:	ff 55 08             	call   *0x8(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 0b                	jmp    8005b4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	57                   	push   %edi
  8005ad:	50                   	push   %eax
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b7:	0f be 03             	movsbl (%ebx),%eax
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	74 03                	je     8005c1 <vprintfmt+0x220>
  8005be:	43                   	inc    %ebx
  8005bf:	eb 1b                	jmp    8005dc <vprintfmt+0x23b>
  8005c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c8:	7f 1e                	jg     8005e8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005cd:	e9 f3 fd ff ff       	jmp    8003c5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d5:	43                   	inc    %ebx
  8005d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005dc:	85 f6                	test   %esi,%esi
  8005de:	78 ad                	js     80058d <vprintfmt+0x1ec>
  8005e0:	4e                   	dec    %esi
  8005e1:	79 aa                	jns    80058d <vprintfmt+0x1ec>
  8005e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005e6:	eb dc                	jmp    8005c4 <vprintfmt+0x223>
  8005e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f4:	4b                   	dec    %ebx
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f ef                	jg     8005eb <vprintfmt+0x24a>
  8005fc:	e9 c4 fd ff ff       	jmp    8003c5 <vprintfmt+0x24>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 2a fd ff ff       	call   800338 <getint>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800612:	85 d2                	test   %edx,%edx
  800614:	78 0a                	js     800620 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	e9 b0 00 00 00       	jmp    8006d0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	57                   	push   %edi
  800624:	6a 2d                	push   $0x2d
  800626:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800629:	f7 db                	neg    %ebx
  80062b:	83 d6 00             	adc    $0x0,%esi
  80062e:	f7 de                	neg    %esi
  800630:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	e9 93 00 00 00       	jmp    8006d0 <vprintfmt+0x32f>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 b4 fc ff ff       	call   8002fe <getuint>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	89 d6                	mov    %edx,%esi
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800653:	eb 7b                	jmp    8006d0 <vprintfmt+0x32f>
  800655:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 d6 fc ff ff       	call   800338 <getint>
  800662:	89 c3                	mov    %eax,%ebx
  800664:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800666:	85 d2                	test   %edx,%edx
  800668:	78 07                	js     800671 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
  80066f:	eb 5f                	jmp    8006d0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	57                   	push   %edi
  800675:	6a 2d                	push   $0x2d
  800677:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80067a:	f7 db                	neg    %ebx
  80067c:	83 d6 00             	adc    $0x0,%esi
  80067f:	f7 de                	neg    %esi
  800681:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
  800689:	eb 45                	jmp    8006d0 <vprintfmt+0x32f>
  80068b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	57                   	push   %edi
  800692:	6a 30                	push   $0x30
  800694:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	57                   	push   %edi
  80069b:	6a 78                	push   $0x78
  80069d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 18                	mov    (%eax),%ebx
  8006ab:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b8:	eb 16                	jmp    8006d0 <vprintfmt+0x32f>
  8006ba:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 37 fc ff ff       	call   8002fe <getuint>
  8006c7:	89 c3                	mov    %eax,%ebx
  8006c9:	89 d6                	mov    %edx,%esi
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006d7:	52                   	push   %edx
  8006d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006db:	50                   	push   %eax
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	89 fa                	mov    %edi,%edx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	e8 68 fb ff ff       	call   800250 <printnum>
			break;
  8006e8:	83 c4 20             	add    $0x20,%esp
  8006eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ee:	e9 d2 fc ff ff       	jmp    8003c5 <vprintfmt+0x24>
  8006f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	57                   	push   %edi
  8006fa:	52                   	push   %edx
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800704:	e9 bc fc ff ff       	jmp    8003c5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	6a 25                	push   $0x25
  80070f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb 02                	jmp    800719 <vprintfmt+0x378>
  800717:	89 c6                	mov    %eax,%esi
  800719:	8d 46 ff             	lea    -0x1(%esi),%eax
  80071c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800720:	75 f5                	jne    800717 <vprintfmt+0x376>
  800722:	e9 9e fc ff ff       	jmp    8003c5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072a:	5b                   	pop    %ebx
  80072b:	5e                   	pop    %esi
  80072c:	5f                   	pop    %edi
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800742:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	74 26                	je     800776 <vsnprintf+0x47>
  800750:	85 d2                	test   %edx,%edx
  800752:	7e 29                	jle    80077d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800754:	ff 75 14             	pushl  0x14(%ebp)
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 6a 03 80 00       	push   $0x80036a
  800763:	e8 39 fc ff ff       	call   8003a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 0c                	jmp    800782 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb 05                	jmp    800782 <vsnprintf+0x53>
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 93 ff ff ff       	call   80072f <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    
	...

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a9:	74 0e                	je     8007b9 <strlen+0x19>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b5:	75 f9                	jne    8007b0 <strlen+0x10>
  8007b7:	eb 05                	jmp    8007be <strlen+0x1e>
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	74 17                	je     8007e4 <strnlen+0x24>
  8007cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007d0:	74 19                	je     8007eb <strnlen+0x2b>
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	39 d0                	cmp    %edx,%eax
  8007da:	74 14                	je     8007f0 <strnlen+0x30>
  8007dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e0:	75 f5                	jne    8007d7 <strnlen+0x17>
  8007e2:	eb 0c                	jmp    8007f0 <strnlen+0x30>
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	eb 05                	jmp    8007f0 <strnlen+0x30>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800801:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800804:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800807:	42                   	inc    %edx
  800808:	84 c9                	test   %cl,%cl
  80080a:	75 f5                	jne    800801 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	53                   	push   %ebx
  800817:	e8 84 ff ff ff       	call   8007a0 <strlen>
  80081c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800825:	50                   	push   %eax
  800826:	e8 c7 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	85 f6                	test   %esi,%esi
  800842:	74 15                	je     800859 <strncpy+0x27>
  800844:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800849:	8a 1a                	mov    (%edx),%bl
  80084b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 3a 01             	cmpb   $0x1,(%edx)
  800851:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	41                   	inc    %ecx
  800855:	39 ce                	cmp    %ecx,%esi
  800857:	77 f0                	ja     800849 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800869:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	85 f6                	test   %esi,%esi
  80086e:	74 32                	je     8008a2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800870:	83 fe 01             	cmp    $0x1,%esi
  800873:	74 22                	je     800897 <strlcpy+0x3a>
  800875:	8a 0b                	mov    (%ebx),%cl
  800877:	84 c9                	test   %cl,%cl
  800879:	74 20                	je     80089b <strlcpy+0x3e>
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800882:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800885:	88 08                	mov    %cl,(%eax)
  800887:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800888:	39 f2                	cmp    %esi,%edx
  80088a:	74 11                	je     80089d <strlcpy+0x40>
  80088c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800890:	42                   	inc    %edx
  800891:	84 c9                	test   %cl,%cl
  800893:	75 f0                	jne    800885 <strlcpy+0x28>
  800895:	eb 06                	jmp    80089d <strlcpy+0x40>
  800897:	89 f8                	mov    %edi,%eax
  800899:	eb 02                	jmp    80089d <strlcpy+0x40>
  80089b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089d:	c6 00 00             	movb   $0x0,(%eax)
  8008a0:	eb 02                	jmp    8008a4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008a4:	29 f8                	sub    %edi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b4:	8a 01                	mov    (%ecx),%al
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 10                	je     8008ca <strcmp+0x1f>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	75 0c                	jne    8008ca <strcmp+0x1f>
		p++, q++;
  8008be:	41                   	inc    %ecx
  8008bf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c0:	8a 01                	mov    (%ecx),%al
  8008c2:	84 c0                	test   %al,%al
  8008c4:	74 04                	je     8008ca <strcmp+0x1f>
  8008c6:	3a 02                	cmp    (%edx),%al
  8008c8:	74 f4                	je     8008be <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 c0             	movzbl %al,%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	74 1b                	je     800900 <strncmp+0x2c>
  8008e5:	8a 1a                	mov    (%edx),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	74 24                	je     80090f <strncmp+0x3b>
  8008eb:	3a 19                	cmp    (%ecx),%bl
  8008ed:	75 20                	jne    80090f <strncmp+0x3b>
  8008ef:	48                   	dec    %eax
  8008f0:	74 15                	je     800907 <strncmp+0x33>
		n--, p++, q++;
  8008f2:	42                   	inc    %edx
  8008f3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f4:	8a 1a                	mov    (%edx),%bl
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	74 15                	je     80090f <strncmp+0x3b>
  8008fa:	3a 19                	cmp    (%ecx),%bl
  8008fc:	74 f1                	je     8008ef <strncmp+0x1b>
  8008fe:	eb 0f                	jmp    80090f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x38>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 02             	movzbl (%edx),%eax
  800912:	0f b6 11             	movzbl (%ecx),%edx
  800915:	29 d0                	sub    %edx,%eax
  800917:	eb f3                	jmp    80090c <strncmp+0x38>

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	74 18                	je     800940 <strchr+0x27>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	75 06                	jne    800932 <strchr+0x19>
  80092c:	eb 17                	jmp    800945 <strchr+0x2c>
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 13                	je     800945 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800932:	40                   	inc    %eax
  800933:	8a 10                	mov    (%eax),%dl
  800935:	84 d2                	test   %dl,%dl
  800937:	75 f5                	jne    80092e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
  80093e:	eb 05                	jmp    800945 <strchr+0x2c>
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800950:	8a 10                	mov    (%eax),%dl
  800952:	84 d2                	test   %dl,%dl
  800954:	74 11                	je     800967 <strfind+0x20>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	75 06                	jne    800960 <strfind+0x19>
  80095a:	eb 0b                	jmp    800967 <strfind+0x20>
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 07                	je     800967 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800960:	40                   	inc    %eax
  800961:	8a 10                	mov    (%eax),%dl
  800963:	84 d2                	test   %dl,%dl
  800965:	75 f5                	jne    80095c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800978:	85 c9                	test   %ecx,%ecx
  80097a:	74 30                	je     8009ac <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800982:	75 25                	jne    8009a9 <memset+0x40>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 20                	jne    8009a9 <memset+0x40>
		c &= 0xFF;
  800989:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098c:	89 d3                	mov    %edx,%ebx
  80098e:	c1 e3 08             	shl    $0x8,%ebx
  800991:	89 d6                	mov    %edx,%esi
  800993:	c1 e6 18             	shl    $0x18,%esi
  800996:	89 d0                	mov    %edx,%eax
  800998:	c1 e0 10             	shl    $0x10,%eax
  80099b:	09 f0                	or     %esi,%eax
  80099d:	09 d0                	or     %edx,%eax
  80099f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a4:	fc                   	cld    
  8009a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a7:	eb 03                	jmp    8009ac <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a9:	fc                   	cld    
  8009aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ac:	89 f8                	mov    %edi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c1:	39 c6                	cmp    %eax,%esi
  8009c3:	73 34                	jae    8009f9 <memmove+0x46>
  8009c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c8:	39 d0                	cmp    %edx,%eax
  8009ca:	73 2d                	jae    8009f9 <memmove+0x46>
		s += n;
		d += n;
  8009cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 1b                	jne    8009ef <memmove+0x3c>
  8009d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009da:	75 13                	jne    8009ef <memmove+0x3c>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 07                	jmp    8009f6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ef:	4f                   	dec    %edi
  8009f0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f3:	fd                   	std    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f6:	fc                   	cld    
  8009f7:	eb 20                	jmp    800a19 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ff:	75 13                	jne    800a14 <memmove+0x61>
  800a01:	a8 03                	test   $0x3,%al
  800a03:	75 0f                	jne    800a14 <memmove+0x61>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 0a                	jne    800a14 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0d:	89 c7                	mov    %eax,%edi
  800a0f:	fc                   	cld    
  800a10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a12:	eb 05                	jmp    800a19 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a20:	ff 75 10             	pushl  0x10(%ebp)
  800a23:	ff 75 0c             	pushl  0xc(%ebp)
  800a26:	ff 75 08             	pushl  0x8(%ebp)
  800a29:	e8 85 ff ff ff       	call   8009b3 <memmove>
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	85 ff                	test   %edi,%edi
  800a41:	74 32                	je     800a75 <memcmp+0x45>
		if (*s1 != *s2)
  800a43:	8a 03                	mov    (%ebx),%al
  800a45:	8a 0e                	mov    (%esi),%cl
  800a47:	38 c8                	cmp    %cl,%al
  800a49:	74 19                	je     800a64 <memcmp+0x34>
  800a4b:	eb 0d                	jmp    800a5a <memcmp+0x2a>
  800a4d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a51:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a55:	42                   	inc    %edx
  800a56:	38 c8                	cmp    %cl,%al
  800a58:	74 10                	je     800a6a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a5a:	0f b6 c0             	movzbl %al,%eax
  800a5d:	0f b6 c9             	movzbl %cl,%ecx
  800a60:	29 c8                	sub    %ecx,%eax
  800a62:	eb 16                	jmp    800a7a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a64:	4f                   	dec    %edi
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	39 fa                	cmp    %edi,%edx
  800a6c:	75 df                	jne    800a4d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 05                	jmp    800a7a <memcmp+0x4a>
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8a:	39 d0                	cmp    %edx,%eax
  800a8c:	73 12                	jae    800aa0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a91:	38 08                	cmp    %cl,(%eax)
  800a93:	75 06                	jne    800a9b <memfind+0x1c>
  800a95:	eb 09                	jmp    800aa0 <memfind+0x21>
  800a97:	38 08                	cmp    %cl,(%eax)
  800a99:	74 05                	je     800aa0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9b:	40                   	inc    %eax
  800a9c:	39 c2                	cmp    %eax,%edx
  800a9e:	77 f7                	ja     800a97 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	eb 01                	jmp    800ab1 <strtol+0xf>
		s++;
  800ab0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	8a 02                	mov    (%edx),%al
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f9                	je     800ab0 <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f5                	je     800ab0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 08                	jne    800ac7 <strtol+0x25>
		s++;
  800abf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb 13                	jmp    800ada <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	75 0a                	jne    800ad5 <strtol+0x33>
		s++, neg = 1;
  800acb:	8d 52 01             	lea    0x1(%edx),%edx
  800ace:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad3:	eb 05                	jmp    800ada <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	74 05                	je     800ae3 <strtol+0x41>
  800ade:	83 fb 10             	cmp    $0x10,%ebx
  800ae1:	75 28                	jne    800b0b <strtol+0x69>
  800ae3:	8a 02                	mov    (%edx),%al
  800ae5:	3c 30                	cmp    $0x30,%al
  800ae7:	75 10                	jne    800af9 <strtol+0x57>
  800ae9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aed:	75 0a                	jne    800af9 <strtol+0x57>
		s += 2, base = 16;
  800aef:	83 c2 02             	add    $0x2,%edx
  800af2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af7:	eb 12                	jmp    800b0b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af9:	85 db                	test   %ebx,%ebx
  800afb:	75 0e                	jne    800b0b <strtol+0x69>
  800afd:	3c 30                	cmp    $0x30,%al
  800aff:	75 05                	jne    800b06 <strtol+0x64>
		s++, base = 8;
  800b01:	42                   	inc    %edx
  800b02:	b3 08                	mov    $0x8,%bl
  800b04:	eb 05                	jmp    800b0b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b06:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b12:	8a 0a                	mov    (%edx),%cl
  800b14:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b17:	80 fb 09             	cmp    $0x9,%bl
  800b1a:	77 08                	ja     800b24 <strtol+0x82>
			dig = *s - '0';
  800b1c:	0f be c9             	movsbl %cl,%ecx
  800b1f:	83 e9 30             	sub    $0x30,%ecx
  800b22:	eb 1e                	jmp    800b42 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b24:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 08                	ja     800b34 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b2c:	0f be c9             	movsbl %cl,%ecx
  800b2f:	83 e9 57             	sub    $0x57,%ecx
  800b32:	eb 0e                	jmp    800b42 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b34:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 13                	ja     800b4f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b3c:	0f be c9             	movsbl %cl,%ecx
  800b3f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b42:	39 f1                	cmp    %esi,%ecx
  800b44:	7d 0d                	jge    800b53 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b46:	42                   	inc    %edx
  800b47:	0f af c6             	imul   %esi,%eax
  800b4a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b4d:	eb c3                	jmp    800b12 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4f:	89 c1                	mov    %eax,%ecx
  800b51:	eb 02                	jmp    800b55 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b53:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b59:	74 05                	je     800b60 <strtol+0xbe>
		*endptr = (char *) s;
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b60:	85 ff                	test   %edi,%edi
  800b62:	74 04                	je     800b68 <strtol+0xc6>
  800b64:	89 c8                	mov    %ecx,%eax
  800b66:	f7 d8                	neg    %eax
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    
  800b6d:	00 00                	add    %al,(%eax)
	...

00800b70 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 1c             	sub    $0x1c,%esp
  800b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b7c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b7f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	8b 75 14             	mov    0x14(%ebp),%esi
  800b84:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8d:	cd 30                	int    $0x30
  800b8f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b95:	74 1c                	je     800bb3 <syscall+0x43>
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 18                	jle    800bb3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba2:	68 3f 22 80 00       	push   $0x80223f
  800ba7:	6a 42                	push   $0x42
  800ba9:	68 5c 22 80 00       	push   $0x80225c
  800bae:	e8 b1 f5 ff ff       	call   800164 <_panic>

	return ret;
}
  800bb3:	89 d0                	mov    %edx,%eax
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	e8 92 ff ff ff       	call   800b70 <syscall>
  800bde:	83 c4 10             	add    $0x10,%esp
	return;
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	e8 6b ff ff ff       	call   800b70 <syscall>
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c18:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c22:	e8 49 ff ff ff       	call   800b70 <syscall>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 02 00 00 00       	mov    $0x2,%eax
  800c46:	e8 25 ff ff ff       	call   800b70 <syscall>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <sys_yield>:

void
sys_yield(void)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	e8 01 ff ff ff       	call   800b70 <syscall>
  800c6f:	83 c4 10             	add    $0x10,%esp
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c91:	e8 da fe ff ff       	call   800b70 <syscall>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c9e:	ff 75 18             	pushl  0x18(%ebp)
  800ca1:	ff 75 14             	pushl  0x14(%ebp)
  800ca4:	ff 75 10             	pushl  0x10(%ebp)
  800ca7:	ff 75 0c             	pushl  0xc(%ebp)
  800caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cad:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	e8 b4 fe ff ff       	call   800b70 <syscall>
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cc4:	6a 00                	push   $0x0
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	ff 75 0c             	pushl  0xc(%ebp)
  800ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cda:	e8 91 fe ff ff       	call   800b70 <syscall>
}
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    

00800ce1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfd:	e8 6e fe ff ff       	call   800b70 <syscall>
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	6a 00                	push   $0x0
  800d10:	ff 75 0c             	pushl  0xc(%ebp)
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d20:	e8 4b fe ff ff       	call   800b70 <syscall>
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	6a 00                	push   $0x0
  800d33:	ff 75 0c             	pushl  0xc(%ebp)
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d43:	e8 28 fe ff ff       	call   800b70 <syscall>
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d50:	6a 00                	push   $0x0
  800d52:	ff 75 14             	pushl  0x14(%ebp)
  800d55:	ff 75 10             	pushl  0x10(%ebp)
  800d58:	ff 75 0c             	pushl  0xc(%ebp)
  800d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d68:	e8 03 fe ff ff       	call   800b70 <syscall>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	ba 01 00 00 00       	mov    $0x1,%edx
  800d85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8a:	e8 e1 fd ff ff       	call   800b70 <syscall>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d97:	6a 00                	push   $0x0
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dad:	e8 be fd ff ff       	call   800b70 <syscall>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dba:	6a 00                	push   $0x0
  800dbc:	ff 75 14             	pushl  0x14(%ebp)
  800dbf:	ff 75 10             	pushl  0x10(%ebp)
  800dc2:	ff 75 0c             	pushl  0xc(%ebp)
  800dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd2:	e8 99 fd ff ff       	call   800b70 <syscall>
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    
  800dd9:	00 00                	add    %al,(%eax)
	...

00800ddc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	05 00 00 00 30       	add    $0x30000000,%eax
  800de7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800def:	ff 75 08             	pushl  0x8(%ebp)
  800df2:	e8 e5 ff ff ff       	call   800ddc <fd2num>
  800df7:	83 c4 04             	add    $0x4,%esp
  800dfa:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dff:	c1 e0 0c             	shl    $0xc,%eax
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	53                   	push   %ebx
  800e08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e10:	a8 01                	test   $0x1,%al
  800e12:	74 34                	je     800e48 <fd_alloc+0x44>
  800e14:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e19:	a8 01                	test   $0x1,%al
  800e1b:	74 32                	je     800e4f <fd_alloc+0x4b>
  800e1d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 16             	shr    $0x16,%edx
  800e29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 1f                	je     800e54 <fd_alloc+0x50>
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 0c             	shr    $0xc,%edx
  800e3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	75 17                	jne    800e5d <fd_alloc+0x59>
  800e46:	eb 0c                	jmp    800e54 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e48:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e4d:	eb 05                	jmp    800e54 <fd_alloc+0x50>
  800e4f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e54:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	eb 17                	jmp    800e74 <fd_alloc+0x70>
  800e5d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e62:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e67:	75 b9                	jne    800e22 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e6f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e74:	5b                   	pop    %ebx
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7d:	83 f8 1f             	cmp    $0x1f,%eax
  800e80:	77 36                	ja     800eb8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e82:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e87:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	c1 ea 16             	shr    $0x16,%edx
  800e8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	74 24                	je     800ebf <fd_lookup+0x48>
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	c1 ea 0c             	shr    $0xc,%edx
  800ea0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea7:	f6 c2 01             	test   $0x1,%dl
  800eaa:	74 1a                	je     800ec6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaf:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	eb 13                	jmp    800ecb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebd:	eb 0c                	jmp    800ecb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec4:	eb 05                	jmp    800ecb <fd_lookup+0x54>
  800ec6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eda:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800ee0:	74 0d                	je     800eef <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	eb 14                	jmp    800efd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800ee9:	39 0a                	cmp    %ecx,(%edx)
  800eeb:	75 10                	jne    800efd <dev_lookup+0x30>
  800eed:	eb 05                	jmp    800ef4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eef:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ef4:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	eb 31                	jmp    800f2e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efd:	40                   	inc    %eax
  800efe:	8b 14 85 ec 22 80 00 	mov    0x8022ec(,%eax,4),%edx
  800f05:	85 d2                	test   %edx,%edx
  800f07:	75 e0                	jne    800ee9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f09:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f0e:	8b 40 48             	mov    0x48(%eax),%eax
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	51                   	push   %ecx
  800f15:	50                   	push   %eax
  800f16:	68 6c 22 80 00       	push   $0x80226c
  800f1b:	e8 1c f3 ff ff       	call   80023c <cprintf>
	*dev = 0;
  800f20:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 20             	sub    $0x20,%esp
  800f3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3e:	8a 45 0c             	mov    0xc(%ebp),%al
  800f41:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f44:	56                   	push   %esi
  800f45:	e8 92 fe ff ff       	call   800ddc <fd2num>
  800f4a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f4d:	89 14 24             	mov    %edx,(%esp)
  800f50:	50                   	push   %eax
  800f51:	e8 21 ff ff ff       	call   800e77 <fd_lookup>
  800f56:	89 c3                	mov    %eax,%ebx
  800f58:	83 c4 08             	add    $0x8,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 05                	js     800f64 <fd_close+0x31>
	    || fd != fd2)
  800f5f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f62:	74 0d                	je     800f71 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f64:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f68:	75 48                	jne    800fb2 <fd_close+0x7f>
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6f:	eb 41                	jmp    800fb2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	ff 36                	pushl  (%esi)
  800f7a:	e8 4e ff ff ff       	call   800ecd <dev_lookup>
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	78 1c                	js     800fa4 <fd_close+0x71>
		if (dev->dev_close)
  800f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f8b:	8b 40 10             	mov    0x10(%eax),%eax
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	74 0d                	je     800f9f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	56                   	push   %esi
  800f96:	ff d0                	call   *%eax
  800f98:	89 c3                	mov    %eax,%ebx
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	eb 05                	jmp    800fa4 <fd_close+0x71>
		else
			r = 0;
  800f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	56                   	push   %esi
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 0f fd ff ff       	call   800cbe <sys_page_unmap>
	return r;
  800faf:	83 c4 10             	add    $0x10,%esp
}
  800fb2:	89 d8                	mov    %ebx,%eax
  800fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 75 08             	pushl  0x8(%ebp)
  800fc8:	e8 aa fe ff ff       	call   800e77 <fd_lookup>
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 10                	js     800fe4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	6a 01                	push   $0x1
  800fd9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdc:	e8 52 ff ff ff       	call   800f33 <fd_close>
  800fe1:	83 c4 10             	add    $0x10,%esp
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <close_all>:

void
close_all(void)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	53                   	push   %ebx
  800fea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	53                   	push   %ebx
  800ff6:	e8 c0 ff ff ff       	call   800fbb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ffb:	43                   	inc    %ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	83 fb 20             	cmp    $0x20,%ebx
  801002:	75 ee                	jne    800ff2 <close_all+0xc>
		close(i);
}
  801004:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	83 ec 2c             	sub    $0x2c,%esp
  801012:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801015:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	ff 75 08             	pushl  0x8(%ebp)
  80101c:	e8 56 fe ff ff       	call   800e77 <fd_lookup>
  801021:	89 c3                	mov    %eax,%ebx
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	0f 88 c0 00 00 00    	js     8010ee <dup+0xe5>
		return r;
	close(newfdnum);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	57                   	push   %edi
  801032:	e8 84 ff ff ff       	call   800fbb <close>

	newfd = INDEX2FD(newfdnum);
  801037:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80103d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801040:	83 c4 04             	add    $0x4,%esp
  801043:	ff 75 e4             	pushl  -0x1c(%ebp)
  801046:	e8 a1 fd ff ff       	call   800dec <fd2data>
  80104b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80104d:	89 34 24             	mov    %esi,(%esp)
  801050:	e8 97 fd ff ff       	call   800dec <fd2data>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	c1 e8 16             	shr    $0x16,%eax
  801060:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801067:	a8 01                	test   $0x1,%al
  801069:	74 37                	je     8010a2 <dup+0x99>
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	c1 e8 0c             	shr    $0xc,%eax
  801070:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801077:	f6 c2 01             	test   $0x1,%dl
  80107a:	74 26                	je     8010a2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	25 07 0e 00 00       	and    $0xe07,%eax
  80108b:	50                   	push   %eax
  80108c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80108f:	6a 00                	push   $0x0
  801091:	53                   	push   %ebx
  801092:	6a 00                	push   $0x0
  801094:	e8 ff fb ff ff       	call   800c98 <sys_page_map>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	83 c4 20             	add    $0x20,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 2d                	js     8010cf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a5:	89 c2                	mov    %eax,%edx
  8010a7:	c1 ea 0c             	shr    $0xc,%edx
  8010aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010ba:	52                   	push   %edx
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	50                   	push   %eax
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 d2 fb ff ff       	call   800c98 <sys_page_map>
  8010c6:	89 c3                	mov    %eax,%ebx
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 1d                	jns    8010ec <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 e4 fb ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010da:	83 c4 08             	add    $0x8,%esp
  8010dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 d7 fb ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	eb 02                	jmp    8010ee <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010ec:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010ee:	89 d8                	mov    %ebx,%eax
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 14             	sub    $0x14,%esp
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801102:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	53                   	push   %ebx
  801107:	e8 6b fd ff ff       	call   800e77 <fd_lookup>
  80110c:	83 c4 08             	add    $0x8,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 67                	js     80117a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801113:	83 ec 08             	sub    $0x8,%esp
  801116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111d:	ff 30                	pushl  (%eax)
  80111f:	e8 a9 fd ff ff       	call   800ecd <dev_lookup>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 4f                	js     80117a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80112b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112e:	8b 50 08             	mov    0x8(%eax),%edx
  801131:	83 e2 03             	and    $0x3,%edx
  801134:	83 fa 01             	cmp    $0x1,%edx
  801137:	75 21                	jne    80115a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801139:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80113e:	8b 40 48             	mov    0x48(%eax),%eax
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	53                   	push   %ebx
  801145:	50                   	push   %eax
  801146:	68 b0 22 80 00       	push   $0x8022b0
  80114b:	e8 ec f0 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801158:	eb 20                	jmp    80117a <read+0x82>
	}
	if (!dev->dev_read)
  80115a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80115d:	8b 52 08             	mov    0x8(%edx),%edx
  801160:	85 d2                	test   %edx,%edx
  801162:	74 11                	je     801175 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	ff 75 10             	pushl  0x10(%ebp)
  80116a:	ff 75 0c             	pushl  0xc(%ebp)
  80116d:	50                   	push   %eax
  80116e:	ff d2                	call   *%edx
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	eb 05                	jmp    80117a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801175:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80117a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118e:	85 f6                	test   %esi,%esi
  801190:	74 31                	je     8011c3 <readn+0x44>
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80119c:	83 ec 04             	sub    $0x4,%esp
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	29 c2                	sub    %eax,%edx
  8011a3:	52                   	push   %edx
  8011a4:	03 45 0c             	add    0xc(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	57                   	push   %edi
  8011a9:	e8 4a ff ff ff       	call   8010f8 <read>
		if (m < 0)
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 17                	js     8011cc <readn+0x4d>
			return m;
		if (m == 0)
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	74 11                	je     8011ca <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b9:	01 c3                	add    %eax,%ebx
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	39 f3                	cmp    %esi,%ebx
  8011bf:	72 db                	jb     80119c <readn+0x1d>
  8011c1:	eb 09                	jmp    8011cc <readn+0x4d>
  8011c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c8:	eb 02                	jmp    8011cc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011ca:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 14             	sub    $0x14,%esp
  8011db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	53                   	push   %ebx
  8011e3:	e8 8f fc ff ff       	call   800e77 <fd_lookup>
  8011e8:	83 c4 08             	add    $0x8,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 62                	js     801251 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ef:	83 ec 08             	sub    $0x8,%esp
  8011f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f9:	ff 30                	pushl  (%eax)
  8011fb:	e8 cd fc ff ff       	call   800ecd <dev_lookup>
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 4a                	js     801251 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120e:	75 21                	jne    801231 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801210:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801215:	8b 40 48             	mov    0x48(%eax),%eax
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	53                   	push   %ebx
  80121c:	50                   	push   %eax
  80121d:	68 cc 22 80 00       	push   $0x8022cc
  801222:	e8 15 f0 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122f:	eb 20                	jmp    801251 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801231:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801234:	8b 52 0c             	mov    0xc(%edx),%edx
  801237:	85 d2                	test   %edx,%edx
  801239:	74 11                	je     80124c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	ff 75 10             	pushl  0x10(%ebp)
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	50                   	push   %eax
  801245:	ff d2                	call   *%edx
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	eb 05                	jmp    801251 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80124c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <seek>:

int
seek(int fdnum, off_t offset)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	ff 75 08             	pushl  0x8(%ebp)
  801263:	e8 0f fc ff ff       	call   800e77 <fd_lookup>
  801268:	83 c4 08             	add    $0x8,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 0e                	js     80127d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80126f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801272:	8b 55 0c             	mov    0xc(%ebp),%edx
  801275:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 14             	sub    $0x14,%esp
  801286:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801289:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	53                   	push   %ebx
  80128e:	e8 e4 fb ff ff       	call   800e77 <fd_lookup>
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 5f                	js     8012f9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	ff 30                	pushl  (%eax)
  8012a6:	e8 22 fc ff ff       	call   800ecd <dev_lookup>
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 47                	js     8012f9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b9:	75 21                	jne    8012dc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012bb:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c0:	8b 40 48             	mov    0x48(%eax),%eax
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	53                   	push   %ebx
  8012c7:	50                   	push   %eax
  8012c8:	68 8c 22 80 00       	push   $0x80228c
  8012cd:	e8 6a ef ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012da:	eb 1d                	jmp    8012f9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012df:	8b 52 18             	mov    0x18(%edx),%edx
  8012e2:	85 d2                	test   %edx,%edx
  8012e4:	74 0e                	je     8012f4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ec:	50                   	push   %eax
  8012ed:	ff d2                	call   *%edx
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	eb 05                	jmp    8012f9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 63 fb ff ff       	call   800e77 <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 52                	js     80136d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	ff 30                	pushl  (%eax)
  801327:	e8 a1 fb ff ff       	call   800ecd <dev_lookup>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 3a                	js     80136d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80133a:	74 2c                	je     801368 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80133c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801346:	00 00 00 
	stat->st_isdir = 0;
  801349:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801350:	00 00 00 
	stat->st_dev = dev;
  801353:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	53                   	push   %ebx
  80135d:	ff 75 f0             	pushl  -0x10(%ebp)
  801360:	ff 50 14             	call   *0x14(%eax)
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	eb 05                	jmp    80136d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801368:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	6a 00                	push   $0x0
  80137c:	ff 75 08             	pushl  0x8(%ebp)
  80137f:	e8 78 01 00 00       	call   8014fc <open>
  801384:	89 c3                	mov    %eax,%ebx
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 1b                	js     8013a8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	ff 75 0c             	pushl  0xc(%ebp)
  801393:	50                   	push   %eax
  801394:	e8 65 ff ff ff       	call   8012fe <fstat>
  801399:	89 c6                	mov    %eax,%esi
	close(fd);
  80139b:	89 1c 24             	mov    %ebx,(%esp)
  80139e:	e8 18 fc ff ff       	call   800fbb <close>
	return r;
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	89 f3                	mov    %esi,%ebx
}
  8013a8:	89 d8                	mov    %ebx,%eax
  8013aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    
  8013b1:	00 00                	add    %al,(%eax)
	...

008013b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013bd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c4:	75 12                	jne    8013d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	e8 8a 07 00 00       	call   801b5a <ipc_find_env>
  8013d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d8:	6a 07                	push   $0x7
  8013da:	68 00 50 c0 00       	push   $0xc05000
  8013df:	53                   	push   %ebx
  8013e0:	ff 35 00 40 80 00    	pushl  0x804000
  8013e6:	e8 1a 07 00 00       	call   801b05 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013eb:	83 c4 0c             	add    $0xc,%esp
  8013ee:	6a 00                	push   $0x0
  8013f0:	56                   	push   %esi
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 98 06 00 00       	call   801a90 <ipc_recv>
}
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	53                   	push   %ebx
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	8b 40 0c             	mov    0xc(%eax),%eax
  80140f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801414:	ba 00 00 00 00       	mov    $0x0,%edx
  801419:	b8 05 00 00 00       	mov    $0x5,%eax
  80141e:	e8 91 ff ff ff       	call   8013b4 <fsipc>
  801423:	85 c0                	test   %eax,%eax
  801425:	78 2c                	js     801453 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	68 00 50 c0 00       	push   $0xc05000
  80142f:	53                   	push   %ebx
  801430:	e8 bd f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801435:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80143a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801440:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801445:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801453:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
  801461:	8b 40 0c             	mov    0xc(%eax),%eax
  801464:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 06 00 00 00       	mov    $0x6,%eax
  801473:	e8 3c ff ff ff       	call   8013b4 <fsipc>
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	8b 40 0c             	mov    0xc(%eax),%eax
  801488:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80148d:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	b8 03 00 00 00       	mov    $0x3,%eax
  80149d:	e8 12 ff ff ff       	call   8013b4 <fsipc>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 4b                	js     8014f3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014a8:	39 c6                	cmp    %eax,%esi
  8014aa:	73 16                	jae    8014c2 <devfile_read+0x48>
  8014ac:	68 fc 22 80 00       	push   $0x8022fc
  8014b1:	68 03 23 80 00       	push   $0x802303
  8014b6:	6a 7d                	push   $0x7d
  8014b8:	68 18 23 80 00       	push   $0x802318
  8014bd:	e8 a2 ec ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  8014c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c7:	7e 16                	jle    8014df <devfile_read+0x65>
  8014c9:	68 23 23 80 00       	push   $0x802323
  8014ce:	68 03 23 80 00       	push   $0x802303
  8014d3:	6a 7e                	push   $0x7e
  8014d5:	68 18 23 80 00       	push   $0x802318
  8014da:	e8 85 ec ff ff       	call   800164 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	50                   	push   %eax
  8014e3:	68 00 50 c0 00       	push   $0xc05000
  8014e8:	ff 75 0c             	pushl  0xc(%ebp)
  8014eb:	e8 c3 f4 ff ff       	call   8009b3 <memmove>
	return r;
  8014f0:	83 c4 10             	add    $0x10,%esp
}
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 1c             	sub    $0x1c,%esp
  801504:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801507:	56                   	push   %esi
  801508:	e8 93 f2 ff ff       	call   8007a0 <strlen>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801515:	7f 65                	jg     80157c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	e8 e1 f8 ff ff       	call   800e04 <fd_alloc>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 55                	js     801581 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	56                   	push   %esi
  801530:	68 00 50 c0 00       	push   $0xc05000
  801535:	e8 b8 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80153a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153d:	a3 00 54 c0 00       	mov    %eax,0xc05400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801545:	b8 01 00 00 00       	mov    $0x1,%eax
  80154a:	e8 65 fe ff ff       	call   8013b4 <fsipc>
  80154f:	89 c3                	mov    %eax,%ebx
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	79 12                	jns    80156a <open+0x6e>
		fd_close(fd, 0);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	6a 00                	push   $0x0
  80155d:	ff 75 f4             	pushl  -0xc(%ebp)
  801560:	e8 ce f9 ff ff       	call   800f33 <fd_close>
		return r;
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	eb 17                	jmp    801581 <open+0x85>
	}

	return fd2num(fd);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	ff 75 f4             	pushl  -0xc(%ebp)
  801570:	e8 67 f8 ff ff       	call   800ddc <fd2num>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb 05                	jmp    801581 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80157c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801581:	89 d8                	mov    %ebx,%eax
  801583:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	c9                   	leave  
  801589:	c3                   	ret    
	...

0080158c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	ff 75 08             	pushl  0x8(%ebp)
  80159a:	e8 4d f8 ff ff       	call   800dec <fd2data>
  80159f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	68 2f 23 80 00       	push   $0x80232f
  8015a9:	56                   	push   %esi
  8015aa:	e8 43 f2 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015af:	8b 43 04             	mov    0x4(%ebx),%eax
  8015b2:	2b 03                	sub    (%ebx),%eax
  8015b4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015ba:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8015c1:	00 00 00 
	stat->st_dev = &devpipe;
  8015c4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015cb:	30 80 00 
	return 0;
}
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015e4:	53                   	push   %ebx
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 d2 f6 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015ec:	89 1c 24             	mov    %ebx,(%esp)
  8015ef:	e8 f8 f7 ff ff       	call   800dec <fd2data>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	50                   	push   %eax
  8015f8:	6a 00                	push   $0x0
  8015fa:	e8 bf f6 ff ff       	call   800cbe <sys_page_unmap>
}
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 1c             	sub    $0x1c,%esp
  80160d:	89 c7                	mov    %eax,%edi
  80160f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801612:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801617:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	57                   	push   %edi
  80161e:	e8 95 05 00 00       	call   801bb8 <pageref>
  801623:	89 c6                	mov    %eax,%esi
  801625:	83 c4 04             	add    $0x4,%esp
  801628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162b:	e8 88 05 00 00       	call   801bb8 <pageref>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	39 c6                	cmp    %eax,%esi
  801635:	0f 94 c0             	sete   %al
  801638:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80163b:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801641:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801644:	39 cb                	cmp    %ecx,%ebx
  801646:	75 08                	jne    801650 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801650:	83 f8 01             	cmp    $0x1,%eax
  801653:	75 bd                	jne    801612 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801655:	8b 42 58             	mov    0x58(%edx),%eax
  801658:	6a 01                	push   $0x1
  80165a:	50                   	push   %eax
  80165b:	53                   	push   %ebx
  80165c:	68 36 23 80 00       	push   $0x802336
  801661:	e8 d6 eb ff ff       	call   80023c <cprintf>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb a7                	jmp    801612 <_pipeisclosed+0xe>

0080166b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	57                   	push   %edi
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	83 ec 28             	sub    $0x28,%esp
  801674:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801677:	56                   	push   %esi
  801678:	e8 6f f7 ff ff       	call   800dec <fd2data>
  80167d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801686:	75 4a                	jne    8016d2 <devpipe_write+0x67>
  801688:	bf 00 00 00 00       	mov    $0x0,%edi
  80168d:	eb 56                	jmp    8016e5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80168f:	89 da                	mov    %ebx,%edx
  801691:	89 f0                	mov    %esi,%eax
  801693:	e8 6c ff ff ff       	call   801604 <_pipeisclosed>
  801698:	85 c0                	test   %eax,%eax
  80169a:	75 4d                	jne    8016e9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80169c:	e8 ac f5 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8016a4:	8b 13                	mov    (%ebx),%edx
  8016a6:	83 c2 20             	add    $0x20,%edx
  8016a9:	39 d0                	cmp    %edx,%eax
  8016ab:	73 e2                	jae    80168f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016b5:	79 05                	jns    8016bc <devpipe_write+0x51>
  8016b7:	4a                   	dec    %edx
  8016b8:	83 ca e0             	or     $0xffffffe0,%edx
  8016bb:	42                   	inc    %edx
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bf:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8016c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016c6:	40                   	inc    %eax
  8016c7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ca:	47                   	inc    %edi
  8016cb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016ce:	77 07                	ja     8016d7 <devpipe_write+0x6c>
  8016d0:	eb 13                	jmp    8016e5 <devpipe_write+0x7a>
  8016d2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016d7:	8b 43 04             	mov    0x4(%ebx),%eax
  8016da:	8b 13                	mov    (%ebx),%edx
  8016dc:	83 c2 20             	add    $0x20,%edx
  8016df:	39 d0                	cmp    %edx,%eax
  8016e1:	73 ac                	jae    80168f <devpipe_write+0x24>
  8016e3:	eb c8                	jmp    8016ad <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016e5:	89 f8                	mov    %edi,%eax
  8016e7:	eb 05                	jmp    8016ee <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 18             	sub    $0x18,%esp
  8016ff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801702:	57                   	push   %edi
  801703:	e8 e4 f6 ff ff       	call   800dec <fd2data>
  801708:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801711:	75 44                	jne    801757 <devpipe_read+0x61>
  801713:	be 00 00 00 00       	mov    $0x0,%esi
  801718:	eb 4f                	jmp    801769 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80171a:	89 f0                	mov    %esi,%eax
  80171c:	eb 54                	jmp    801772 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80171e:	89 da                	mov    %ebx,%edx
  801720:	89 f8                	mov    %edi,%eax
  801722:	e8 dd fe ff ff       	call   801604 <_pipeisclosed>
  801727:	85 c0                	test   %eax,%eax
  801729:	75 42                	jne    80176d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80172b:	e8 1d f5 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801730:	8b 03                	mov    (%ebx),%eax
  801732:	3b 43 04             	cmp    0x4(%ebx),%eax
  801735:	74 e7                	je     80171e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801737:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80173c:	79 05                	jns    801743 <devpipe_read+0x4d>
  80173e:	48                   	dec    %eax
  80173f:	83 c8 e0             	or     $0xffffffe0,%eax
  801742:	40                   	inc    %eax
  801743:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80174d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174f:	46                   	inc    %esi
  801750:	39 75 10             	cmp    %esi,0x10(%ebp)
  801753:	77 07                	ja     80175c <devpipe_read+0x66>
  801755:	eb 12                	jmp    801769 <devpipe_read+0x73>
  801757:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80175c:	8b 03                	mov    (%ebx),%eax
  80175e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801761:	75 d4                	jne    801737 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801763:	85 f6                	test   %esi,%esi
  801765:	75 b3                	jne    80171a <devpipe_read+0x24>
  801767:	eb b5                	jmp    80171e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801769:	89 f0                	mov    %esi,%eax
  80176b:	eb 05                	jmp    801772 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	83 ec 28             	sub    $0x28,%esp
  801783:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801786:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	e8 75 f6 ff ff       	call   800e04 <fd_alloc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	0f 88 24 01 00 00    	js     8018c0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	68 07 04 00 00       	push   $0x407
  8017a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 c6 f4 ff ff       	call   800c74 <sys_page_alloc>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	0f 88 05 01 00 00    	js     8018c0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	e8 3d f6 ff ff       	call   800e04 <fd_alloc>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	0f 88 dc 00 00 00    	js     8018b0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	68 07 04 00 00       	push   $0x407
  8017dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8017df:	6a 00                	push   $0x0
  8017e1:	e8 8e f4 ff ff       	call   800c74 <sys_page_alloc>
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	0f 88 bd 00 00 00    	js     8018b0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017f9:	e8 ee f5 ff ff       	call   800dec <fd2data>
  8017fe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801800:	83 c4 0c             	add    $0xc,%esp
  801803:	68 07 04 00 00       	push   $0x407
  801808:	50                   	push   %eax
  801809:	6a 00                	push   $0x0
  80180b:	e8 64 f4 ff ff       	call   800c74 <sys_page_alloc>
  801810:	89 c3                	mov    %eax,%ebx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	85 c0                	test   %eax,%eax
  801817:	0f 88 83 00 00 00    	js     8018a0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	ff 75 e0             	pushl  -0x20(%ebp)
  801823:	e8 c4 f5 ff ff       	call   800dec <fd2data>
  801828:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80182f:	50                   	push   %eax
  801830:	6a 00                	push   $0x0
  801832:	56                   	push   %esi
  801833:	6a 00                	push   $0x0
  801835:	e8 5e f4 ff ff       	call   800c98 <sys_page_map>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 20             	add    $0x20,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 4f                	js     801892 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801843:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80184c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80184e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801851:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801858:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80185e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801861:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801863:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801866:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	ff 75 e4             	pushl  -0x1c(%ebp)
  801873:	e8 64 f5 ff ff       	call   800ddc <fd2num>
  801878:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80187a:	83 c4 04             	add    $0x4,%esp
  80187d:	ff 75 e0             	pushl  -0x20(%ebp)
  801880:	e8 57 f5 ff ff       	call   800ddc <fd2num>
  801885:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801890:	eb 2e                	jmp    8018c0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	56                   	push   %esi
  801896:	6a 00                	push   $0x0
  801898:	e8 21 f4 ff ff       	call   800cbe <sys_page_unmap>
  80189d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 11 f4 ff ff       	call   800cbe <sys_page_unmap>
  8018ad:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 01 f4 ff ff       	call   800cbe <sys_page_unmap>
  8018bd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5f                   	pop    %edi
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	ff 75 08             	pushl  0x8(%ebp)
  8018d7:	e8 9b f5 ff ff       	call   800e77 <fd_lookup>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 18                	js     8018fb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e9:	e8 fe f4 ff ff       	call   800dec <fd2data>
	return _pipeisclosed(fd, p);
  8018ee:	89 c2                	mov    %eax,%edx
  8018f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f3:	e8 0c fd ff ff       	call   801604 <_pipeisclosed>
  8018f8:	83 c4 10             	add    $0x10,%esp
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    
  8018fd:	00 00                	add    %al,(%eax)
	...

00801900 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801910:	68 4e 23 80 00       	push   $0x80234e
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	e8 d5 ee ff ff       	call   8007f2 <strcpy>
	return 0;
}
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	57                   	push   %edi
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801930:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801934:	74 45                	je     80197b <devcons_write+0x57>
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
  80193b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801940:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801946:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801949:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80194b:	83 fb 7f             	cmp    $0x7f,%ebx
  80194e:	76 05                	jbe    801955 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801950:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	53                   	push   %ebx
  801959:	03 45 0c             	add    0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	57                   	push   %edi
  80195e:	e8 50 f0 ff ff       	call   8009b3 <memmove>
		sys_cputs(buf, m);
  801963:	83 c4 08             	add    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	57                   	push   %edi
  801968:	e8 50 f2 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196d:	01 de                	add    %ebx,%esi
  80196f:	89 f0                	mov    %esi,%eax
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	3b 75 10             	cmp    0x10(%ebp),%esi
  801977:	72 cd                	jb     801946 <devcons_write+0x22>
  801979:	eb 05                	jmp    801980 <devcons_write+0x5c>
  80197b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801980:	89 f0                	mov    %esi,%eax
  801982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5f                   	pop    %edi
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801990:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801994:	75 07                	jne    80199d <devcons_read+0x13>
  801996:	eb 25                	jmp    8019bd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801998:	e8 b0 f2 ff ff       	call   800c4d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80199d:	e8 41 f2 ff ff       	call   800be3 <sys_cgetc>
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	74 f2                	je     801998 <devcons_read+0xe>
  8019a6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 1d                	js     8019c9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019ac:	83 f8 04             	cmp    $0x4,%eax
  8019af:	74 13                	je     8019c4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	88 10                	mov    %dl,(%eax)
	return 1;
  8019b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bb:	eb 0c                	jmp    8019c9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	eb 05                	jmp    8019c9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019d7:	6a 01                	push   $0x1
  8019d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019dc:	50                   	push   %eax
  8019dd:	e8 db f1 ff ff       	call   800bbd <sys_cputs>
  8019e2:	83 c4 10             	add    $0x10,%esp
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <getchar>:

int
getchar(void)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019ed:	6a 01                	push   $0x1
  8019ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 fe f6 ff ff       	call   8010f8 <read>
	if (r < 0)
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 0f                	js     801a10 <getchar+0x29>
		return r;
	if (r < 1)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	7e 06                	jle    801a0b <getchar+0x24>
		return -E_EOF;
	return c;
  801a05:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a09:	eb 05                	jmp    801a10 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a0b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	e8 53 f4 ff ff       	call   800e77 <fd_lookup>
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 11                	js     801a3c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a34:	39 10                	cmp    %edx,(%eax)
  801a36:	0f 94 c0             	sete   %al
  801a39:	0f b6 c0             	movzbl %al,%eax
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <opencons>:

int
opencons(void)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a47:	50                   	push   %eax
  801a48:	e8 b7 f3 ff ff       	call   800e04 <fd_alloc>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 3a                	js     801a8e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a54:	83 ec 04             	sub    $0x4,%esp
  801a57:	68 07 04 00 00       	push   $0x407
  801a5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 0e f2 ff ff       	call   800c74 <sys_page_alloc>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 21                	js     801a8e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	50                   	push   %eax
  801a86:	e8 51 f3 ff ff       	call   800ddc <fd2num>
  801a8b:	83 c4 10             	add    $0x10,%esp
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	8b 75 08             	mov    0x8(%ebp),%esi
  801a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	74 0e                	je     801ab0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	50                   	push   %eax
  801aa6:	e8 c4 f2 ff ff       	call   800d6f <sys_ipc_recv>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	eb 10                	jmp    801ac0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	68 00 00 c0 ee       	push   $0xeec00000
  801ab8:	e8 b2 f2 ff ff       	call   800d6f <sys_ipc_recv>
  801abd:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	75 26                	jne    801aea <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ac4:	85 f6                	test   %esi,%esi
  801ac6:	74 0a                	je     801ad2 <ipc_recv+0x42>
  801ac8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801acd:	8b 40 74             	mov    0x74(%eax),%eax
  801ad0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ad2:	85 db                	test   %ebx,%ebx
  801ad4:	74 0a                	je     801ae0 <ipc_recv+0x50>
  801ad6:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801adb:	8b 40 78             	mov    0x78(%eax),%eax
  801ade:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801ae0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ae5:	8b 40 70             	mov    0x70(%eax),%eax
  801ae8:	eb 14                	jmp    801afe <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801aea:	85 f6                	test   %esi,%esi
  801aec:	74 06                	je     801af4 <ipc_recv+0x64>
  801aee:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801af4:	85 db                	test   %ebx,%ebx
  801af6:	74 06                	je     801afe <ipc_recv+0x6e>
  801af8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801afe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	57                   	push   %edi
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b14:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b17:	85 db                	test   %ebx,%ebx
  801b19:	75 25                	jne    801b40 <ipc_send+0x3b>
  801b1b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b20:	eb 1e                	jmp    801b40 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b25:	75 07                	jne    801b2e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b27:	e8 21 f1 ff ff       	call   800c4d <sys_yield>
  801b2c:	eb 12                	jmp    801b40 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b2e:	50                   	push   %eax
  801b2f:	68 5a 23 80 00       	push   $0x80235a
  801b34:	6a 43                	push   $0x43
  801b36:	68 6d 23 80 00       	push   $0x80236d
  801b3b:	e8 24 e6 ff ff       	call   800164 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	57                   	push   %edi
  801b43:	ff 75 08             	pushl  0x8(%ebp)
  801b46:	e8 ff f1 ff ff       	call   800d4a <sys_ipc_try_send>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	75 d0                	jne    801b22 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	53                   	push   %ebx
  801b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b61:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b67:	74 22                	je     801b8b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b69:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b6e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	c1 e2 07             	shl    $0x7,%edx
  801b7a:	29 ca                	sub    %ecx,%edx
  801b7c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b82:	8b 52 50             	mov    0x50(%edx),%edx
  801b85:	39 da                	cmp    %ebx,%edx
  801b87:	75 1d                	jne    801ba6 <ipc_find_env+0x4c>
  801b89:	eb 05                	jmp    801b90 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b97:	c1 e0 07             	shl    $0x7,%eax
  801b9a:	29 d0                	sub    %edx,%eax
  801b9c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ba1:	8b 40 40             	mov    0x40(%eax),%eax
  801ba4:	eb 0c                	jmp    801bb2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba6:	40                   	inc    %eax
  801ba7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bac:	75 c0                	jne    801b6e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bae:	66 b8 00 00          	mov    $0x0,%ax
}
  801bb2:	5b                   	pop    %ebx
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    
  801bb5:	00 00                	add    %al,(%eax)
	...

00801bb8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	c1 ea 16             	shr    $0x16,%edx
  801bc3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bca:	f6 c2 01             	test   $0x1,%dl
  801bcd:	74 1e                	je     801bed <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bcf:	c1 e8 0c             	shr    $0xc,%eax
  801bd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bd9:	a8 01                	test   $0x1,%al
  801bdb:	74 17                	je     801bf4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bdd:	c1 e8 0c             	shr    $0xc,%eax
  801be0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801be7:	ef 
  801be8:	0f b7 c0             	movzwl %ax,%eax
  801beb:	eb 0c                	jmp    801bf9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf2:	eb 05                	jmp    801bf9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    
	...

00801bfc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	83 ec 10             	sub    $0x10,%esp
  801c04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c0a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c10:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c13:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c16:	85 c0                	test   %eax,%eax
  801c18:	75 2e                	jne    801c48 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c1a:	39 f1                	cmp    %esi,%ecx
  801c1c:	77 5a                	ja     801c78 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c1e:	85 c9                	test   %ecx,%ecx
  801c20:	75 0b                	jne    801c2d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	31 d2                	xor    %edx,%edx
  801c29:	f7 f1                	div    %ecx
  801c2b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c2d:	31 d2                	xor    %edx,%edx
  801c2f:	89 f0                	mov    %esi,%eax
  801c31:	f7 f1                	div    %ecx
  801c33:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c35:	89 f8                	mov    %edi,%eax
  801c37:	f7 f1                	div    %ecx
  801c39:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c3b:	89 f8                	mov    %edi,%eax
  801c3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    
  801c46:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c48:	39 f0                	cmp    %esi,%eax
  801c4a:	77 1c                	ja     801c68 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c4c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c4f:	83 f7 1f             	xor    $0x1f,%edi
  801c52:	75 3c                	jne    801c90 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c54:	39 f0                	cmp    %esi,%eax
  801c56:	0f 82 90 00 00 00    	jb     801cec <__udivdi3+0xf0>
  801c5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c62:	0f 86 84 00 00 00    	jbe    801cec <__udivdi3+0xf0>
  801c68:	31 f6                	xor    %esi,%esi
  801c6a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6c:	89 f8                	mov    %edi,%eax
  801c6e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	5e                   	pop    %esi
  801c74:	5f                   	pop    %edi
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    
  801c77:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c78:	89 f2                	mov    %esi,%edx
  801c7a:	89 f8                	mov    %edi,%eax
  801c7c:	f7 f1                	div    %ecx
  801c7e:	89 c7                	mov    %eax,%edi
  801c80:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c82:	89 f8                	mov    %edi,%eax
  801c84:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	5e                   	pop    %esi
  801c8a:	5f                   	pop    %edi
  801c8b:	c9                   	leave  
  801c8c:	c3                   	ret    
  801c8d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c90:	89 f9                	mov    %edi,%ecx
  801c92:	d3 e0                	shl    %cl,%eax
  801c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c97:	b8 20 00 00 00       	mov    $0x20,%eax
  801c9c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca1:	88 c1                	mov    %al,%cl
  801ca3:	d3 ea                	shr    %cl,%edx
  801ca5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ca8:	09 ca                	or     %ecx,%edx
  801caa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cb0:	89 f9                	mov    %edi,%ecx
  801cb2:	d3 e2                	shl    %cl,%edx
  801cb4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cb7:	89 f2                	mov    %esi,%edx
  801cb9:	88 c1                	mov    %al,%cl
  801cbb:	d3 ea                	shr    %cl,%edx
  801cbd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	89 f9                	mov    %edi,%ecx
  801cc4:	d3 e2                	shl    %cl,%edx
  801cc6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801cc9:	88 c1                	mov    %al,%cl
  801ccb:	d3 ee                	shr    %cl,%esi
  801ccd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ccf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cd2:	89 f0                	mov    %esi,%eax
  801cd4:	89 ca                	mov    %ecx,%edx
  801cd6:	f7 75 ec             	divl   -0x14(%ebp)
  801cd9:	89 d1                	mov    %edx,%ecx
  801cdb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cdd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ce0:	39 d1                	cmp    %edx,%ecx
  801ce2:	72 28                	jb     801d0c <__udivdi3+0x110>
  801ce4:	74 1a                	je     801d00 <__udivdi3+0x104>
  801ce6:	89 f7                	mov    %esi,%edi
  801ce8:	31 f6                	xor    %esi,%esi
  801cea:	eb 80                	jmp    801c6c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cec:	31 f6                	xor    %esi,%esi
  801cee:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cf3:	89 f8                	mov    %edi,%eax
  801cf5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    
  801cfe:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d03:	89 f9                	mov    %edi,%ecx
  801d05:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d07:	39 c2                	cmp    %eax,%edx
  801d09:	73 db                	jae    801ce6 <__udivdi3+0xea>
  801d0b:	90                   	nop
		{
		  q0--;
  801d0c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d0f:	31 f6                	xor    %esi,%esi
  801d11:	e9 56 ff ff ff       	jmp    801c6c <__udivdi3+0x70>
	...

00801d18 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	83 ec 20             	sub    $0x20,%esp
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d26:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d35:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d37:	85 ff                	test   %edi,%edi
  801d39:	75 15                	jne    801d50 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d3b:	39 f1                	cmp    %esi,%ecx
  801d3d:	0f 86 99 00 00 00    	jbe    801ddc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d43:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d49:	83 c4 20             	add    $0x20,%esp
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	c9                   	leave  
  801d4f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d50:	39 f7                	cmp    %esi,%edi
  801d52:	0f 87 a4 00 00 00    	ja     801dfc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d58:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d5b:	83 f0 1f             	xor    $0x1f,%eax
  801d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d61:	0f 84 a1 00 00 00    	je     801e08 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d67:	89 f8                	mov    %edi,%eax
  801d69:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d6c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d6e:	bf 20 00 00 00       	mov    $0x20,%edi
  801d73:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d79:	89 f9                	mov    %edi,%ecx
  801d7b:	d3 ea                	shr    %cl,%edx
  801d7d:	09 c2                	or     %eax,%edx
  801d7f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d88:	d3 e0                	shl    %cl,%eax
  801d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d94:	d3 e0                	shl    %cl,%eax
  801d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d9c:	89 f9                	mov    %edi,%ecx
  801d9e:	d3 e8                	shr    %cl,%eax
  801da0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801da2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801da4:	89 f2                	mov    %esi,%edx
  801da6:	f7 75 f0             	divl   -0x10(%ebp)
  801da9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dab:	f7 65 f4             	mull   -0xc(%ebp)
  801dae:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801db1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db3:	39 d6                	cmp    %edx,%esi
  801db5:	72 71                	jb     801e28 <__umoddi3+0x110>
  801db7:	74 7f                	je     801e38 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dbc:	29 c8                	sub    %ecx,%eax
  801dbe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dc0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dc3:	d3 e8                	shr    %cl,%eax
  801dc5:	89 f2                	mov    %esi,%edx
  801dc7:	89 f9                	mov    %edi,%ecx
  801dc9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dcb:	09 d0                	or     %edx,%eax
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dd2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd4:	83 c4 20             	add    $0x20,%esp
  801dd7:	5e                   	pop    %esi
  801dd8:	5f                   	pop    %edi
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    
  801ddb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ddc:	85 c9                	test   %ecx,%ecx
  801dde:	75 0b                	jne    801deb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801de0:	b8 01 00 00 00       	mov    $0x1,%eax
  801de5:	31 d2                	xor    %edx,%edx
  801de7:	f7 f1                	div    %ecx
  801de9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	31 d2                	xor    %edx,%edx
  801def:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df4:	f7 f1                	div    %ecx
  801df6:	e9 4a ff ff ff       	jmp    801d45 <__umoddi3+0x2d>
  801dfb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dfc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dfe:	83 c4 20             	add    $0x20,%esp
  801e01:	5e                   	pop    %esi
  801e02:	5f                   	pop    %edi
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    
  801e05:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e08:	39 f7                	cmp    %esi,%edi
  801e0a:	72 05                	jb     801e11 <__umoddi3+0xf9>
  801e0c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e0f:	77 0c                	ja     801e1d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e11:	89 f2                	mov    %esi,%edx
  801e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e16:	29 c8                	sub    %ecx,%eax
  801e18:	19 fa                	sbb    %edi,%edx
  801e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e20:	83 c4 20             	add    $0x20,%esp
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    
  801e27:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e28:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e2b:	89 c1                	mov    %eax,%ecx
  801e2d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e30:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e33:	eb 84                	jmp    801db9 <__umoddi3+0xa1>
  801e35:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e38:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e3b:	72 eb                	jb     801e28 <__umoddi3+0x110>
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	e9 75 ff ff ff       	jmp    801db9 <__umoddi3+0xa1>
