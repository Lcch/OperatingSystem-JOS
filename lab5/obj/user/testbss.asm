
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
  80003a:	68 20 1e 80 00       	push   $0x801e20
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
  800067:	68 9b 1e 80 00       	push   $0x801e9b
  80006c:	6a 11                	push   $0x11
  80006e:	68 b8 1e 80 00       	push   $0x801eb8
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
  8000b3:	68 40 1e 80 00       	push   $0x801e40
  8000b8:	6a 16                	push   $0x16
  8000ba:	68 b8 1e 80 00       	push   $0x801eb8
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
  8000cf:	68 68 1e 80 00       	push   $0x801e68
  8000d4:	e8 63 01 00 00       	call   80023c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d9:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000e0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e3:	83 c4 0c             	add    $0xc,%esp
  8000e6:	68 c7 1e 80 00       	push   $0x801ec7
  8000eb:	6a 1a                	push   $0x1a
  8000ed:	68 b8 1e 80 00       	push   $0x801eb8
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
  80014e:	e8 6b 0e 00 00       	call   800fbe <close_all>
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
  800182:	68 e8 1e 80 00       	push   $0x801ee8
  800187:	e8 b0 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	83 c4 18             	add    $0x18,%esp
  80018f:	56                   	push   %esi
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	e8 53 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 b6 1e 80 00 	movl   $0x801eb6,(%esp)
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
  8002a4:	e8 2b 19 00 00       	call   801bd4 <__udivdi3>
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
  8002e0:	e8 0b 1a 00 00       	call   801cf0 <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 0b 1f 80 00 	movsbl 0x801f0b(%eax),%eax
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
  80042c:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
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
  8004d8:	8b 04 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 1a                	jne    8004fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004e3:	52                   	push   %edx
  8004e4:	68 23 1f 80 00       	push   $0x801f23
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
  8004fe:	68 d5 22 80 00       	push   $0x8022d5
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
  800534:	c7 45 d0 1c 1f 80 00 	movl   $0x801f1c,-0x30(%ebp)
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
  800ba2:	68 ff 21 80 00       	push   $0x8021ff
  800ba7:	6a 42                	push   $0x42
  800ba9:	68 1c 22 80 00       	push   $0x80221c
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

00800db4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbf:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc7:	ff 75 08             	pushl  0x8(%ebp)
  800dca:	e8 e5 ff ff ff       	call   800db4 <fd2num>
  800dcf:	83 c4 04             	add    $0x4,%esp
  800dd2:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dd7:	c1 e0 0c             	shl    $0xc,%eax
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800de8:	a8 01                	test   $0x1,%al
  800dea:	74 34                	je     800e20 <fd_alloc+0x44>
  800dec:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800df1:	a8 01                	test   $0x1,%al
  800df3:	74 32                	je     800e27 <fd_alloc+0x4b>
  800df5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800dfa:	89 c1                	mov    %eax,%ecx
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 1f                	je     800e2c <fd_alloc+0x50>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	75 17                	jne    800e35 <fd_alloc+0x59>
  800e1e:	eb 0c                	jmp    800e2c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e20:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e25:	eb 05                	jmp    800e2c <fd_alloc+0x50>
  800e27:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e2c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb 17                	jmp    800e4c <fd_alloc+0x70>
  800e35:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3f:	75 b9                	jne    800dfa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e47:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e55:	83 f8 1f             	cmp    $0x1f,%eax
  800e58:	77 36                	ja     800e90 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e5f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 16             	shr    $0x16,%edx
  800e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 24                	je     800e97 <fd_lookup+0x48>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	74 1a                	je     800e9e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e87:	89 02                	mov    %eax,(%edx)
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	eb 13                	jmp    800ea3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb 0c                	jmp    800ea3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9c:	eb 05                	jmp    800ea3 <fd_lookup+0x54>
  800e9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eb2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800eb8:	74 0d                	je     800ec7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 14                	jmp    800ed5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800ec1:	39 0a                	cmp    %ecx,(%edx)
  800ec3:	75 10                	jne    800ed5 <dev_lookup+0x30>
  800ec5:	eb 05                	jmp    800ecc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ecc:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	eb 31                	jmp    800f06 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	40                   	inc    %eax
  800ed6:	8b 14 85 ac 22 80 00 	mov    0x8022ac(,%eax,4),%edx
  800edd:	85 d2                	test   %edx,%edx
  800edf:	75 e0                	jne    800ec1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ee6:	8b 40 48             	mov    0x48(%eax),%eax
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	51                   	push   %ecx
  800eed:	50                   	push   %eax
  800eee:	68 2c 22 80 00       	push   $0x80222c
  800ef3:	e8 44 f3 ff ff       	call   80023c <cprintf>
	*dev = 0;
  800ef8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 20             	sub    $0x20,%esp
  800f13:	8b 75 08             	mov    0x8(%ebp),%esi
  800f16:	8a 45 0c             	mov    0xc(%ebp),%al
  800f19:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1c:	56                   	push   %esi
  800f1d:	e8 92 fe ff ff       	call   800db4 <fd2num>
  800f22:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f25:	89 14 24             	mov    %edx,(%esp)
  800f28:	50                   	push   %eax
  800f29:	e8 21 ff ff ff       	call   800e4f <fd_lookup>
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	83 c4 08             	add    $0x8,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	78 05                	js     800f3c <fd_close+0x31>
	    || fd != fd2)
  800f37:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3a:	74 0d                	je     800f49 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f3c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f40:	75 48                	jne    800f8a <fd_close+0x7f>
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f47:	eb 41                	jmp    800f8a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 36                	pushl  (%esi)
  800f52:	e8 4e ff ff ff       	call   800ea5 <dev_lookup>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 1c                	js     800f7c <fd_close+0x71>
		if (dev->dev_close)
  800f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f63:	8b 40 10             	mov    0x10(%eax),%eax
  800f66:	85 c0                	test   %eax,%eax
  800f68:	74 0d                	je     800f77 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	56                   	push   %esi
  800f6e:	ff d0                	call   *%eax
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	eb 05                	jmp    800f7c <fd_close+0x71>
		else
			r = 0;
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	e8 37 fd ff ff       	call   800cbe <sys_page_unmap>
	return r;
  800f87:	83 c4 10             	add    $0x10,%esp
}
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 08             	pushl  0x8(%ebp)
  800fa0:	e8 aa fe ff ff       	call   800e4f <fd_lookup>
  800fa5:	83 c4 08             	add    $0x8,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 10                	js     800fbc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	6a 01                	push   $0x1
  800fb1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb4:	e8 52 ff ff ff       	call   800f0b <fd_close>
  800fb9:	83 c4 10             	add    $0x10,%esp
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <close_all>:

void
close_all(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	53                   	push   %ebx
  800fce:	e8 c0 ff ff ff       	call   800f93 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd3:	43                   	inc    %ebx
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	83 fb 20             	cmp    $0x20,%ebx
  800fda:	75 ee                	jne    800fca <close_all+0xc>
		close(i);
}
  800fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 2c             	sub    $0x2c,%esp
  800fea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 75 08             	pushl  0x8(%ebp)
  800ff4:	e8 56 fe ff ff       	call   800e4f <fd_lookup>
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	0f 88 c0 00 00 00    	js     8010c6 <dup+0xe5>
		return r;
	close(newfdnum);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	57                   	push   %edi
  80100a:	e8 84 ff ff ff       	call   800f93 <close>

	newfd = INDEX2FD(newfdnum);
  80100f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801015:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801018:	83 c4 04             	add    $0x4,%esp
  80101b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101e:	e8 a1 fd ff ff       	call   800dc4 <fd2data>
  801023:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801025:	89 34 24             	mov    %esi,(%esp)
  801028:	e8 97 fd ff ff       	call   800dc4 <fd2data>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801033:	89 d8                	mov    %ebx,%eax
  801035:	c1 e8 16             	shr    $0x16,%eax
  801038:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	74 37                	je     80107a <dup+0x99>
  801043:	89 d8                	mov    %ebx,%eax
  801045:	c1 e8 0c             	shr    $0xc,%eax
  801048:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 26                	je     80107a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801054:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	25 07 0e 00 00       	and    $0xe07,%eax
  801063:	50                   	push   %eax
  801064:	ff 75 d4             	pushl  -0x2c(%ebp)
  801067:	6a 00                	push   $0x0
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 27 fc ff ff       	call   800c98 <sys_page_map>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 2d                	js     8010a7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	c1 ea 0c             	shr    $0xc,%edx
  801082:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801092:	52                   	push   %edx
  801093:	56                   	push   %esi
  801094:	6a 00                	push   $0x0
  801096:	50                   	push   %eax
  801097:	6a 00                	push   $0x0
  801099:	e8 fa fb ff ff       	call   800c98 <sys_page_map>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	83 c4 20             	add    $0x20,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	79 1d                	jns    8010c4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a7:	83 ec 08             	sub    $0x8,%esp
  8010aa:	56                   	push   %esi
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 0c fc ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 ff fb ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	eb 02                	jmp    8010c6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 14             	sub    $0x14,%esp
  8010d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	53                   	push   %ebx
  8010df:	e8 6b fd ff ff       	call   800e4f <fd_lookup>
  8010e4:	83 c4 08             	add    $0x8,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 67                	js     801152 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f5:	ff 30                	pushl  (%eax)
  8010f7:	e8 a9 fd ff ff       	call   800ea5 <dev_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 4f                	js     801152 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801106:	8b 50 08             	mov    0x8(%eax),%edx
  801109:	83 e2 03             	and    $0x3,%edx
  80110c:	83 fa 01             	cmp    $0x1,%edx
  80110f:	75 21                	jne    801132 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801111:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	53                   	push   %ebx
  80111d:	50                   	push   %eax
  80111e:	68 70 22 80 00       	push   $0x802270
  801123:	e8 14 f1 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801130:	eb 20                	jmp    801152 <read+0x82>
	}
	if (!dev->dev_read)
  801132:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801135:	8b 52 08             	mov    0x8(%edx),%edx
  801138:	85 d2                	test   %edx,%edx
  80113a:	74 11                	je     80114d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	50                   	push   %eax
  801146:	ff d2                	call   *%edx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	eb 05                	jmp    801152 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80114d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 7d 08             	mov    0x8(%ebp),%edi
  801163:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801166:	85 f6                	test   %esi,%esi
  801168:	74 31                	je     80119b <readn+0x44>
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	89 f2                	mov    %esi,%edx
  801179:	29 c2                	sub    %eax,%edx
  80117b:	52                   	push   %edx
  80117c:	03 45 0c             	add    0xc(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	57                   	push   %edi
  801181:	e8 4a ff ff ff       	call   8010d0 <read>
		if (m < 0)
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 17                	js     8011a4 <readn+0x4d>
			return m;
		if (m == 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	74 11                	je     8011a2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801191:	01 c3                	add    %eax,%ebx
  801193:	89 d8                	mov    %ebx,%eax
  801195:	39 f3                	cmp    %esi,%ebx
  801197:	72 db                	jb     801174 <readn+0x1d>
  801199:	eb 09                	jmp    8011a4 <readn+0x4d>
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	eb 02                	jmp    8011a4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011a2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 14             	sub    $0x14,%esp
  8011b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	53                   	push   %ebx
  8011bb:	e8 8f fc ff ff       	call   800e4f <fd_lookup>
  8011c0:	83 c4 08             	add    $0x8,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 62                	js     801229 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d1:	ff 30                	pushl  (%eax)
  8011d3:	e8 cd fc ff ff       	call   800ea5 <dev_lookup>
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 4a                	js     801229 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e6:	75 21                	jne    801209 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011ed:	8b 40 48             	mov    0x48(%eax),%eax
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	53                   	push   %ebx
  8011f4:	50                   	push   %eax
  8011f5:	68 8c 22 80 00       	push   $0x80228c
  8011fa:	e8 3d f0 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801207:	eb 20                	jmp    801229 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801209:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120c:	8b 52 0c             	mov    0xc(%edx),%edx
  80120f:	85 d2                	test   %edx,%edx
  801211:	74 11                	je     801224 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	ff 75 10             	pushl  0x10(%ebp)
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	50                   	push   %eax
  80121d:	ff d2                	call   *%edx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	eb 05                	jmp    801229 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801224:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <seek>:

int
seek(int fdnum, off_t offset)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801234:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 0f fc ff ff       	call   800e4f <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 0e                	js     801255 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801247:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 14             	sub    $0x14,%esp
  80125e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801261:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	53                   	push   %ebx
  801266:	e8 e4 fb ff ff       	call   800e4f <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 5f                	js     8012d1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	ff 30                	pushl  (%eax)
  80127e:	e8 22 fc ff ff       	call   800ea5 <dev_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 47                	js     8012d1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801291:	75 21                	jne    8012b4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801293:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	68 4c 22 80 00       	push   $0x80224c
  8012a5:	e8 92 ef ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b2:	eb 1d                	jmp    8012d1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b7:	8b 52 18             	mov    0x18(%edx),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	74 0e                	je     8012cc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	ff 75 0c             	pushl  0xc(%ebp)
  8012c4:	50                   	push   %eax
  8012c5:	ff d2                	call   *%edx
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	eb 05                	jmp    8012d1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 14             	sub    $0x14,%esp
  8012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 63 fb ff ff       	call   800e4f <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 52                	js     801345 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 a1 fb ff ff       	call   800ea5 <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 3a                	js     801345 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801312:	74 2c                	je     801340 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801314:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801317:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131e:	00 00 00 
	stat->st_isdir = 0;
  801321:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801328:	00 00 00 
	stat->st_dev = dev;
  80132b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 75 f0             	pushl  -0x10(%ebp)
  801338:	ff 50 14             	call   *0x14(%eax)
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	eb 05                	jmp    801345 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 00                	push   $0x0
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 78 01 00 00       	call   8014d4 <open>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1b                	js     801380 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 0c             	pushl  0xc(%ebp)
  80136b:	50                   	push   %eax
  80136c:	e8 65 ff ff ff       	call   8012d6 <fstat>
  801371:	89 c6                	mov    %eax,%esi
	close(fd);
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 18 fc ff ff       	call   800f93 <close>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 f3                	mov    %esi,%ebx
}
  801380:	89 d8                	mov    %ebx,%eax
  801382:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	c9                   	leave  
  801388:	c3                   	ret    
  801389:	00 00                	add    %al,(%eax)
	...

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	89 c3                	mov    %eax,%ebx
  801393:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801395:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139c:	75 12                	jne    8013b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 01                	push   $0x1
  8013a3:	e8 8a 07 00 00       	call   801b32 <ipc_find_env>
  8013a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b0:	6a 07                	push   $0x7
  8013b2:	68 00 50 c0 00       	push   $0xc05000
  8013b7:	53                   	push   %ebx
  8013b8:	ff 35 00 40 80 00    	pushl  0x804000
  8013be:	e8 1a 07 00 00       	call   801add <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	56                   	push   %esi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 98 06 00 00       	call   801a68 <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e7:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f6:	e8 91 ff ff ff       	call   80138c <fsipc>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 2c                	js     80142b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	68 00 50 c0 00       	push   $0xc05000
  801407:	53                   	push   %ebx
  801408:	e8 e5 f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80140d:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801412:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801418:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80141d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 06 00 00 00       	mov    $0x6,%eax
  80144b:	e8 3c ff ff ff       	call   80138c <fsipc>
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801465:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 03 00 00 00       	mov    $0x3,%eax
  801475:	e8 12 ff ff ff       	call   80138c <fsipc>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 4b                	js     8014cb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801480:	39 c6                	cmp    %eax,%esi
  801482:	73 16                	jae    80149a <devfile_read+0x48>
  801484:	68 bc 22 80 00       	push   $0x8022bc
  801489:	68 c3 22 80 00       	push   $0x8022c3
  80148e:	6a 7d                	push   $0x7d
  801490:	68 d8 22 80 00       	push   $0x8022d8
  801495:	e8 ca ec ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  80149a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80149f:	7e 16                	jle    8014b7 <devfile_read+0x65>
  8014a1:	68 e3 22 80 00       	push   $0x8022e3
  8014a6:	68 c3 22 80 00       	push   $0x8022c3
  8014ab:	6a 7e                	push   $0x7e
  8014ad:	68 d8 22 80 00       	push   $0x8022d8
  8014b2:	e8 ad ec ff ff       	call   800164 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	50                   	push   %eax
  8014bb:	68 00 50 c0 00       	push   $0xc05000
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	e8 eb f4 ff ff       	call   8009b3 <memmove>
	return r;
  8014c8:	83 c4 10             	add    $0x10,%esp
}
  8014cb:	89 d8                	mov    %ebx,%eax
  8014cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d0:	5b                   	pop    %ebx
  8014d1:	5e                   	pop    %esi
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 1c             	sub    $0x1c,%esp
  8014dc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014df:	56                   	push   %esi
  8014e0:	e8 bb f2 ff ff       	call   8007a0 <strlen>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ed:	7f 65                	jg     801554 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	e8 e1 f8 ff ff       	call   800ddc <fd_alloc>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 55                	js     801559 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	56                   	push   %esi
  801508:	68 00 50 c0 00       	push   $0xc05000
  80150d:	e8 e0 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801512:	8b 45 0c             	mov    0xc(%ebp),%eax
  801515:	a3 00 54 c0 00       	mov    %eax,0xc05400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151d:	b8 01 00 00 00       	mov    $0x1,%eax
  801522:	e8 65 fe ff ff       	call   80138c <fsipc>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	79 12                	jns    801542 <open+0x6e>
		fd_close(fd, 0);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	6a 00                	push   $0x0
  801535:	ff 75 f4             	pushl  -0xc(%ebp)
  801538:	e8 ce f9 ff ff       	call   800f0b <fd_close>
		return r;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb 17                	jmp    801559 <open+0x85>
	}

	return fd2num(fd);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	ff 75 f4             	pushl  -0xc(%ebp)
  801548:	e8 67 f8 ff ff       	call   800db4 <fd2num>
  80154d:	89 c3                	mov    %eax,%ebx
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 05                	jmp    801559 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801554:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	c9                   	leave  
  801561:	c3                   	ret    
	...

00801564 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 4d f8 ff ff       	call   800dc4 <fd2data>
  801577:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	68 ef 22 80 00       	push   $0x8022ef
  801581:	56                   	push   %esi
  801582:	e8 6b f2 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801587:	8b 43 04             	mov    0x4(%ebx),%eax
  80158a:	2b 03                	sub    (%ebx),%eax
  80158c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801592:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801599:	00 00 00 
	stat->st_dev = &devpipe;
  80159c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015a3:	30 80 00 
	return 0;
}
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015bc:	53                   	push   %ebx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 fa f6 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 f8 f7 ff ff       	call   800dc4 <fd2data>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	50                   	push   %eax
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 e7 f6 ff ff       	call   800cbe <sys_page_unmap>
}
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	89 c7                	mov    %eax,%edi
  8015e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015ea:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8015ef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	57                   	push   %edi
  8015f6:	e8 95 05 00 00       	call   801b90 <pageref>
  8015fb:	89 c6                	mov    %eax,%esi
  8015fd:	83 c4 04             	add    $0x4,%esp
  801600:	ff 75 e4             	pushl  -0x1c(%ebp)
  801603:	e8 88 05 00 00       	call   801b90 <pageref>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	39 c6                	cmp    %eax,%esi
  80160d:	0f 94 c0             	sete   %al
  801610:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801613:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801619:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80161c:	39 cb                	cmp    %ecx,%ebx
  80161e:	75 08                	jne    801628 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	c9                   	leave  
  801627:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801628:	83 f8 01             	cmp    $0x1,%eax
  80162b:	75 bd                	jne    8015ea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80162d:	8b 42 58             	mov    0x58(%edx),%eax
  801630:	6a 01                	push   $0x1
  801632:	50                   	push   %eax
  801633:	53                   	push   %ebx
  801634:	68 f6 22 80 00       	push   $0x8022f6
  801639:	e8 fe eb ff ff       	call   80023c <cprintf>
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	eb a7                	jmp    8015ea <_pipeisclosed+0xe>

00801643 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	57                   	push   %edi
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
  801649:	83 ec 28             	sub    $0x28,%esp
  80164c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164f:	56                   	push   %esi
  801650:	e8 6f f7 ff ff       	call   800dc4 <fd2data>
  801655:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80165e:	75 4a                	jne    8016aa <devpipe_write+0x67>
  801660:	bf 00 00 00 00       	mov    $0x0,%edi
  801665:	eb 56                	jmp    8016bd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801667:	89 da                	mov    %ebx,%edx
  801669:	89 f0                	mov    %esi,%eax
  80166b:	e8 6c ff ff ff       	call   8015dc <_pipeisclosed>
  801670:	85 c0                	test   %eax,%eax
  801672:	75 4d                	jne    8016c1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801674:	e8 d4 f5 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801679:	8b 43 04             	mov    0x4(%ebx),%eax
  80167c:	8b 13                	mov    (%ebx),%edx
  80167e:	83 c2 20             	add    $0x20,%edx
  801681:	39 d0                	cmp    %edx,%eax
  801683:	73 e2                	jae    801667 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801685:	89 c2                	mov    %eax,%edx
  801687:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80168d:	79 05                	jns    801694 <devpipe_write+0x51>
  80168f:	4a                   	dec    %edx
  801690:	83 ca e0             	or     $0xffffffe0,%edx
  801693:	42                   	inc    %edx
  801694:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801697:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80169a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169e:	40                   	inc    %eax
  80169f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a2:	47                   	inc    %edi
  8016a3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016a6:	77 07                	ja     8016af <devpipe_write+0x6c>
  8016a8:	eb 13                	jmp    8016bd <devpipe_write+0x7a>
  8016aa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016af:	8b 43 04             	mov    0x4(%ebx),%eax
  8016b2:	8b 13                	mov    (%ebx),%edx
  8016b4:	83 c2 20             	add    $0x20,%edx
  8016b7:	39 d0                	cmp    %edx,%eax
  8016b9:	73 ac                	jae    801667 <devpipe_write+0x24>
  8016bb:	eb c8                	jmp    801685 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016bd:	89 f8                	mov    %edi,%eax
  8016bf:	eb 05                	jmp    8016c6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	57                   	push   %edi
  8016d2:	56                   	push   %esi
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 18             	sub    $0x18,%esp
  8016d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016da:	57                   	push   %edi
  8016db:	e8 e4 f6 ff ff       	call   800dc4 <fd2data>
  8016e0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016e9:	75 44                	jne    80172f <devpipe_read+0x61>
  8016eb:	be 00 00 00 00       	mov    $0x0,%esi
  8016f0:	eb 4f                	jmp    801741 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016f2:	89 f0                	mov    %esi,%eax
  8016f4:	eb 54                	jmp    80174a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016f6:	89 da                	mov    %ebx,%edx
  8016f8:	89 f8                	mov    %edi,%eax
  8016fa:	e8 dd fe ff ff       	call   8015dc <_pipeisclosed>
  8016ff:	85 c0                	test   %eax,%eax
  801701:	75 42                	jne    801745 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801703:	e8 45 f5 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801708:	8b 03                	mov    (%ebx),%eax
  80170a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80170d:	74 e7                	je     8016f6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80170f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801714:	79 05                	jns    80171b <devpipe_read+0x4d>
  801716:	48                   	dec    %eax
  801717:	83 c8 e0             	or     $0xffffffe0,%eax
  80171a:	40                   	inc    %eax
  80171b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80171f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801722:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801725:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801727:	46                   	inc    %esi
  801728:	39 75 10             	cmp    %esi,0x10(%ebp)
  80172b:	77 07                	ja     801734 <devpipe_read+0x66>
  80172d:	eb 12                	jmp    801741 <devpipe_read+0x73>
  80172f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801734:	8b 03                	mov    (%ebx),%eax
  801736:	3b 43 04             	cmp    0x4(%ebx),%eax
  801739:	75 d4                	jne    80170f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80173b:	85 f6                	test   %esi,%esi
  80173d:	75 b3                	jne    8016f2 <devpipe_read+0x24>
  80173f:	eb b5                	jmp    8016f6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801741:	89 f0                	mov    %esi,%eax
  801743:	eb 05                	jmp    80174a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80174a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5f                   	pop    %edi
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	57                   	push   %edi
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	83 ec 28             	sub    $0x28,%esp
  80175b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80175e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	e8 75 f6 ff ff       	call   800ddc <fd_alloc>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	0f 88 24 01 00 00    	js     801898 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	68 07 04 00 00       	push   $0x407
  80177c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177f:	6a 00                	push   $0x0
  801781:	e8 ee f4 ff ff       	call   800c74 <sys_page_alloc>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	0f 88 05 01 00 00    	js     801898 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	e8 3d f6 ff ff       	call   800ddc <fd_alloc>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	0f 88 dc 00 00 00    	js     801888 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	68 07 04 00 00       	push   $0x407
  8017b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 b6 f4 ff ff       	call   800c74 <sys_page_alloc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	0f 88 bd 00 00 00    	js     801888 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017d1:	e8 ee f5 ff ff       	call   800dc4 <fd2data>
  8017d6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d8:	83 c4 0c             	add    $0xc,%esp
  8017db:	68 07 04 00 00       	push   $0x407
  8017e0:	50                   	push   %eax
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 8c f4 ff ff       	call   800c74 <sys_page_alloc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 83 00 00 00    	js     801878 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8017fb:	e8 c4 f5 ff ff       	call   800dc4 <fd2data>
  801800:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801807:	50                   	push   %eax
  801808:	6a 00                	push   $0x0
  80180a:	56                   	push   %esi
  80180b:	6a 00                	push   $0x0
  80180d:	e8 86 f4 ff ff       	call   800c98 <sys_page_map>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	83 c4 20             	add    $0x20,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 4f                	js     80186a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80181b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801824:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801826:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801829:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801830:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801836:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801839:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80183b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80183e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184b:	e8 64 f5 ff ff       	call   800db4 <fd2num>
  801850:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801852:	83 c4 04             	add    $0x4,%esp
  801855:	ff 75 e0             	pushl  -0x20(%ebp)
  801858:	e8 57 f5 ff ff       	call   800db4 <fd2num>
  80185d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	bb 00 00 00 00       	mov    $0x0,%ebx
  801868:	eb 2e                	jmp    801898 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	56                   	push   %esi
  80186e:	6a 00                	push   $0x0
  801870:	e8 49 f4 ff ff       	call   800cbe <sys_page_unmap>
  801875:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	ff 75 e0             	pushl  -0x20(%ebp)
  80187e:	6a 00                	push   $0x0
  801880:	e8 39 f4 ff ff       	call   800cbe <sys_page_unmap>
  801885:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80188e:	6a 00                	push   $0x0
  801890:	e8 29 f4 ff ff       	call   800cbe <sys_page_unmap>
  801895:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801898:	89 d8                	mov    %ebx,%eax
  80189a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	ff 75 08             	pushl  0x8(%ebp)
  8018af:	e8 9b f5 ff ff       	call   800e4f <fd_lookup>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 18                	js     8018d3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c1:	e8 fe f4 ff ff       	call   800dc4 <fd2data>
	return _pipeisclosed(fd, p);
  8018c6:	89 c2                	mov    %eax,%edx
  8018c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cb:	e8 0c fd ff ff       	call   8015dc <_pipeisclosed>
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    
  8018d5:	00 00                	add    %al,(%eax)
	...

008018d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018e8:	68 0e 23 80 00       	push   $0x80230e
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	e8 fd ee ff ff       	call   8007f2 <strcpy>
	return 0;
}
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	57                   	push   %edi
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801908:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80190c:	74 45                	je     801953 <devcons_write+0x57>
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
  801913:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801918:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80191e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801921:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801923:	83 fb 7f             	cmp    $0x7f,%ebx
  801926:	76 05                	jbe    80192d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801928:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80192d:	83 ec 04             	sub    $0x4,%esp
  801930:	53                   	push   %ebx
  801931:	03 45 0c             	add    0xc(%ebp),%eax
  801934:	50                   	push   %eax
  801935:	57                   	push   %edi
  801936:	e8 78 f0 ff ff       	call   8009b3 <memmove>
		sys_cputs(buf, m);
  80193b:	83 c4 08             	add    $0x8,%esp
  80193e:	53                   	push   %ebx
  80193f:	57                   	push   %edi
  801940:	e8 78 f2 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801945:	01 de                	add    %ebx,%esi
  801947:	89 f0                	mov    %esi,%eax
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80194f:	72 cd                	jb     80191e <devcons_write+0x22>
  801951:	eb 05                	jmp    801958 <devcons_write+0x5c>
  801953:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801958:	89 f0                	mov    %esi,%eax
  80195a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5f                   	pop    %edi
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801968:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80196c:	75 07                	jne    801975 <devcons_read+0x13>
  80196e:	eb 25                	jmp    801995 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801970:	e8 d8 f2 ff ff       	call   800c4d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801975:	e8 69 f2 ff ff       	call   800be3 <sys_cgetc>
  80197a:	85 c0                	test   %eax,%eax
  80197c:	74 f2                	je     801970 <devcons_read+0xe>
  80197e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801980:	85 c0                	test   %eax,%eax
  801982:	78 1d                	js     8019a1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801984:	83 f8 04             	cmp    $0x4,%eax
  801987:	74 13                	je     80199c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198c:	88 10                	mov    %dl,(%eax)
	return 1;
  80198e:	b8 01 00 00 00       	mov    $0x1,%eax
  801993:	eb 0c                	jmp    8019a1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	eb 05                	jmp    8019a1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80199c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019af:	6a 01                	push   $0x1
  8019b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	e8 03 f2 ff ff       	call   800bbd <sys_cputs>
  8019ba:	83 c4 10             	add    $0x10,%esp
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <getchar>:

int
getchar(void)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019c5:	6a 01                	push   $0x1
  8019c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ca:	50                   	push   %eax
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 fe f6 ff ff       	call   8010d0 <read>
	if (r < 0)
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 0f                	js     8019e8 <getchar+0x29>
		return r;
	if (r < 1)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	7e 06                	jle    8019e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8019dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019e1:	eb 05                	jmp    8019e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 08             	pushl  0x8(%ebp)
  8019f7:	e8 53 f4 ff ff       	call   800e4f <fd_lookup>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 11                	js     801a14 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0c:	39 10                	cmp    %edx,(%eax)
  801a0e:	0f 94 c0             	sete   %al
  801a11:	0f b6 c0             	movzbl %al,%eax
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <opencons>:

int
opencons(void)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 b7 f3 ff ff       	call   800ddc <fd_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 3a                	js     801a66 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	68 07 04 00 00       	push   $0x407
  801a34:	ff 75 f4             	pushl  -0xc(%ebp)
  801a37:	6a 00                	push   $0x0
  801a39:	e8 36 f2 ff ff       	call   800c74 <sys_page_alloc>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 21                	js     801a66 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a45:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a53:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	50                   	push   %eax
  801a5e:	e8 51 f3 ff ff       	call   800db4 <fd2num>
  801a63:	83 c4 10             	add    $0x10,%esp
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a76:	85 c0                	test   %eax,%eax
  801a78:	74 0e                	je     801a88 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	50                   	push   %eax
  801a7e:	e8 ec f2 ff ff       	call   800d6f <sys_ipc_recv>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	eb 10                	jmp    801a98 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	68 00 00 c0 ee       	push   $0xeec00000
  801a90:	e8 da f2 ff ff       	call   800d6f <sys_ipc_recv>
  801a95:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	75 26                	jne    801ac2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a9c:	85 f6                	test   %esi,%esi
  801a9e:	74 0a                	je     801aaa <ipc_recv+0x42>
  801aa0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801aa5:	8b 40 74             	mov    0x74(%eax),%eax
  801aa8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 0a                	je     801ab8 <ipc_recv+0x50>
  801aae:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ab3:	8b 40 78             	mov    0x78(%eax),%eax
  801ab6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801ab8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801abd:	8b 40 70             	mov    0x70(%eax),%eax
  801ac0:	eb 14                	jmp    801ad6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ac2:	85 f6                	test   %esi,%esi
  801ac4:	74 06                	je     801acc <ipc_recv+0x64>
  801ac6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	74 06                	je     801ad6 <ipc_recv+0x6e>
  801ad0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ae9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aec:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	75 25                	jne    801b18 <ipc_send+0x3b>
  801af3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801af8:	eb 1e                	jmp    801b18 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801afa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afd:	75 07                	jne    801b06 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aff:	e8 49 f1 ff ff       	call   800c4d <sys_yield>
  801b04:	eb 12                	jmp    801b18 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b06:	50                   	push   %eax
  801b07:	68 1a 23 80 00       	push   $0x80231a
  801b0c:	6a 43                	push   $0x43
  801b0e:	68 2d 23 80 00       	push   $0x80232d
  801b13:	e8 4c e6 ff ff       	call   800164 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	57                   	push   %edi
  801b1b:	ff 75 08             	pushl  0x8(%ebp)
  801b1e:	e8 27 f2 ff ff       	call   800d4a <sys_ipc_try_send>
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	75 d0                	jne    801afa <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	53                   	push   %ebx
  801b36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b39:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801b3f:	74 22                	je     801b63 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b41:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b46:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801b4d:	89 c2                	mov    %eax,%edx
  801b4f:	c1 e2 07             	shl    $0x7,%edx
  801b52:	29 ca                	sub    %ecx,%edx
  801b54:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b5a:	8b 52 50             	mov    0x50(%edx),%edx
  801b5d:	39 da                	cmp    %ebx,%edx
  801b5f:	75 1d                	jne    801b7e <ipc_find_env+0x4c>
  801b61:	eb 05                	jmp    801b68 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b6f:	c1 e0 07             	shl    $0x7,%eax
  801b72:	29 d0                	sub    %edx,%eax
  801b74:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b79:	8b 40 40             	mov    0x40(%eax),%eax
  801b7c:	eb 0c                	jmp    801b8a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7e:	40                   	inc    %eax
  801b7f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b84:	75 c0                	jne    801b46 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b86:	66 b8 00 00          	mov    $0x0,%ax
}
  801b8a:	5b                   	pop    %ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    
  801b8d:	00 00                	add    %al,(%eax)
	...

00801b90 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	c1 ea 16             	shr    $0x16,%edx
  801b9b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ba2:	f6 c2 01             	test   $0x1,%dl
  801ba5:	74 1e                	je     801bc5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba7:	c1 e8 0c             	shr    $0xc,%eax
  801baa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bb1:	a8 01                	test   $0x1,%al
  801bb3:	74 17                	je     801bcc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb5:	c1 e8 0c             	shr    $0xc,%eax
  801bb8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bbf:	ef 
  801bc0:	0f b7 c0             	movzwl %ax,%eax
  801bc3:	eb 0c                	jmp    801bd1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bca:	eb 05                	jmp    801bd1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    
	...

00801bd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	57                   	push   %edi
  801bd8:	56                   	push   %esi
  801bd9:	83 ec 10             	sub    $0x10,%esp
  801bdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801be2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801be8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801beb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	75 2e                	jne    801c20 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bf2:	39 f1                	cmp    %esi,%ecx
  801bf4:	77 5a                	ja     801c50 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bf6:	85 c9                	test   %ecx,%ecx
  801bf8:	75 0b                	jne    801c05 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bfa:	b8 01 00 00 00       	mov    $0x1,%eax
  801bff:	31 d2                	xor    %edx,%edx
  801c01:	f7 f1                	div    %ecx
  801c03:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c05:	31 d2                	xor    %edx,%edx
  801c07:	89 f0                	mov    %esi,%eax
  801c09:	f7 f1                	div    %ecx
  801c0b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c0d:	89 f8                	mov    %edi,%eax
  801c0f:	f7 f1                	div    %ecx
  801c11:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c13:	89 f8                	mov    %edi,%eax
  801c15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    
  801c1e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c20:	39 f0                	cmp    %esi,%eax
  801c22:	77 1c                	ja     801c40 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c24:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	75 3c                	jne    801c68 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c2c:	39 f0                	cmp    %esi,%eax
  801c2e:	0f 82 90 00 00 00    	jb     801cc4 <__udivdi3+0xf0>
  801c34:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c37:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c3a:	0f 86 84 00 00 00    	jbe    801cc4 <__udivdi3+0xf0>
  801c40:	31 f6                	xor    %esi,%esi
  801c42:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c44:	89 f8                	mov    %edi,%eax
  801c46:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    
  801c4f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c50:	89 f2                	mov    %esi,%edx
  801c52:	89 f8                	mov    %edi,%eax
  801c54:	f7 f1                	div    %ecx
  801c56:	89 c7                	mov    %eax,%edi
  801c58:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5a:	89 f8                	mov    %edi,%eax
  801c5c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c68:	89 f9                	mov    %edi,%ecx
  801c6a:	d3 e0                	shl    %cl,%eax
  801c6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c6f:	b8 20 00 00 00       	mov    $0x20,%eax
  801c74:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c79:	88 c1                	mov    %al,%cl
  801c7b:	d3 ea                	shr    %cl,%edx
  801c7d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c80:	09 ca                	or     %ecx,%edx
  801c82:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c88:	89 f9                	mov    %edi,%ecx
  801c8a:	d3 e2                	shl    %cl,%edx
  801c8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c8f:	89 f2                	mov    %esi,%edx
  801c91:	88 c1                	mov    %al,%cl
  801c93:	d3 ea                	shr    %cl,%edx
  801c95:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	89 f9                	mov    %edi,%ecx
  801c9c:	d3 e2                	shl    %cl,%edx
  801c9e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ca1:	88 c1                	mov    %al,%cl
  801ca3:	d3 ee                	shr    %cl,%esi
  801ca5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801caa:	89 f0                	mov    %esi,%eax
  801cac:	89 ca                	mov    %ecx,%edx
  801cae:	f7 75 ec             	divl   -0x14(%ebp)
  801cb1:	89 d1                	mov    %edx,%ecx
  801cb3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cb5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cb8:	39 d1                	cmp    %edx,%ecx
  801cba:	72 28                	jb     801ce4 <__udivdi3+0x110>
  801cbc:	74 1a                	je     801cd8 <__udivdi3+0x104>
  801cbe:	89 f7                	mov    %esi,%edi
  801cc0:	31 f6                	xor    %esi,%esi
  801cc2:	eb 80                	jmp    801c44 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cc4:	31 f6                	xor    %esi,%esi
  801cc6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ccb:	89 f8                	mov    %edi,%eax
  801ccd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	5e                   	pop    %esi
  801cd3:	5f                   	pop    %edi
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    
  801cd6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cdb:	89 f9                	mov    %edi,%ecx
  801cdd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cdf:	39 c2                	cmp    %eax,%edx
  801ce1:	73 db                	jae    801cbe <__udivdi3+0xea>
  801ce3:	90                   	nop
		{
		  q0--;
  801ce4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ce7:	31 f6                	xor    %esi,%esi
  801ce9:	e9 56 ff ff ff       	jmp    801c44 <__udivdi3+0x70>
	...

00801cf0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	57                   	push   %edi
  801cf4:	56                   	push   %esi
  801cf5:	83 ec 20             	sub    $0x20,%esp
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d01:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d04:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d07:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d0d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d0f:	85 ff                	test   %edi,%edi
  801d11:	75 15                	jne    801d28 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d13:	39 f1                	cmp    %esi,%ecx
  801d15:	0f 86 99 00 00 00    	jbe    801db4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d1b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d1d:	89 d0                	mov    %edx,%eax
  801d1f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d21:	83 c4 20             	add    $0x20,%esp
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d28:	39 f7                	cmp    %esi,%edi
  801d2a:	0f 87 a4 00 00 00    	ja     801dd4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d30:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d33:	83 f0 1f             	xor    $0x1f,%eax
  801d36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d39:	0f 84 a1 00 00 00    	je     801de0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d44:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d46:	bf 20 00 00 00       	mov    $0x20,%edi
  801d4b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	09 c2                	or     %eax,%edx
  801d57:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d60:	d3 e0                	shl    %cl,%eax
  801d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d65:	89 f2                	mov    %esi,%edx
  801d67:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d71:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d74:	89 f9                	mov    %edi,%ecx
  801d76:	d3 e8                	shr    %cl,%eax
  801d78:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d7a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d7c:	89 f2                	mov    %esi,%edx
  801d7e:	f7 75 f0             	divl   -0x10(%ebp)
  801d81:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d83:	f7 65 f4             	mull   -0xc(%ebp)
  801d86:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d89:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8b:	39 d6                	cmp    %edx,%esi
  801d8d:	72 71                	jb     801e00 <__umoddi3+0x110>
  801d8f:	74 7f                	je     801e10 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d94:	29 c8                	sub    %ecx,%eax
  801d96:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d98:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	89 f9                	mov    %edi,%ecx
  801da1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801da3:	09 d0                	or     %edx,%eax
  801da5:	89 f2                	mov    %esi,%edx
  801da7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801daa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dac:	83 c4 20             	add    $0x20,%esp
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    
  801db3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db4:	85 c9                	test   %ecx,%ecx
  801db6:	75 0b                	jne    801dc3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801db8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbd:	31 d2                	xor    %edx,%edx
  801dbf:	f7 f1                	div    %ecx
  801dc1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	31 d2                	xor    %edx,%edx
  801dc7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dcc:	f7 f1                	div    %ecx
  801dce:	e9 4a ff ff ff       	jmp    801d1d <__umoddi3+0x2d>
  801dd3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dd4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd6:	83 c4 20             	add    $0x20,%esp
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	c9                   	leave  
  801ddc:	c3                   	ret    
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de0:	39 f7                	cmp    %esi,%edi
  801de2:	72 05                	jb     801de9 <__umoddi3+0xf9>
  801de4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801de7:	77 0c                	ja     801df5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801de9:	89 f2                	mov    %esi,%edx
  801deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dee:	29 c8                	sub    %ecx,%eax
  801df0:	19 fa                	sbb    %edi,%edx
  801df2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df8:	83 c4 20             	add    $0x20,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e00:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e03:	89 c1                	mov    %eax,%ecx
  801e05:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e08:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e0b:	eb 84                	jmp    801d91 <__umoddi3+0xa1>
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e10:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e13:	72 eb                	jb     801e00 <__umoddi3+0x110>
  801e15:	89 f2                	mov    %esi,%edx
  801e17:	e9 75 ff ff ff       	jmp    801d91 <__umoddi3+0xa1>
