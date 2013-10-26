
obj/user/testbss:     file format elf32-i386


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
  80003a:	68 e0 0f 80 00       	push   $0x800fe0
  80003f:	e8 e8 01 00 00       	call   80022c <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800044:	83 c4 10             	add    $0x10,%esp
  800047:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004e:	75 11                	jne    800061 <umain+0x2d>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800050:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800055:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
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
  800067:	68 5b 10 80 00       	push   $0x80105b
  80006c:	6a 11                	push   $0x11
  80006e:	68 78 10 80 00       	push   $0x801078
  800073:	e8 dc 00 00 00       	call   800154 <_panic>
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
  800085:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

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
  800094:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80009b:	75 10                	jne    8000ad <umain+0x79>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  80009d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000a2:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000a9:	74 19                	je     8000c4 <umain+0x90>
  8000ab:	eb 05                	jmp    8000b2 <umain+0x7e>
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000b2:	50                   	push   %eax
  8000b3:	68 00 10 80 00       	push   $0x801000
  8000b8:	6a 16                	push   $0x16
  8000ba:	68 78 10 80 00       	push   $0x801078
  8000bf:	e8 90 00 00 00       	call   800154 <_panic>
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
  8000cf:	68 28 10 80 00       	push   $0x801028
  8000d4:	e8 53 01 00 00       	call   80022c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000e0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e3:	83 c4 0c             	add    $0xc,%esp
  8000e6:	68 87 10 80 00       	push   $0x801087
  8000eb:	6a 1a                	push   $0x1a
  8000ed:	68 78 10 80 00       	push   $0x801078
  8000f2:	e8 5d 00 00 00       	call   800154 <_panic>
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
  800103:	e8 11 0b 00 00       	call   800c19 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	c1 e0 07             	shl    $0x7,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 f6                	test   %esi,%esi
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 03                	mov    (%ebx),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	53                   	push   %ebx
  800129:	56                   	push   %esi
  80012a:	e8 05 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0c 00 00 00       	call   800140 <exit>
  800134:	83 c4 10             	add    $0x10,%esp
}
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    
	...

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800146:	6a 00                	push   $0x0
  800148:	e8 aa 0a 00 00       	call   800bf7 <sys_env_destroy>
  80014d:	83 c4 10             	add    $0x10,%esp
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800162:	e8 b2 0a 00 00       	call   800c19 <sys_getenvid>
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	ff 75 0c             	pushl  0xc(%ebp)
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	53                   	push   %ebx
  800171:	50                   	push   %eax
  800172:	68 a8 10 80 00       	push   $0x8010a8
  800177:	e8 b0 00 00 00       	call   80022c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	56                   	push   %esi
  800180:	ff 75 10             	pushl  0x10(%ebp)
  800183:	e8 53 00 00 00       	call   8001db <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 76 10 80 00 	movl   $0x801076,(%esp)
  80018f:	e8 98 00 00 00       	call   80022c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800197:	cc                   	int3   
  800198:	eb fd                	jmp    800197 <_panic+0x43>
	...

0080019c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a6:	8b 03                	mov    (%ebx),%eax
  8001a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001af:	40                   	inc    %eax
  8001b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	75 1a                	jne    8001d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	68 ff 00 00 00       	push   $0xff
  8001c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c4:	50                   	push   %eax
  8001c5:	e8 e3 09 00 00       	call   800bad <sys_cputs>
		b->idx = 0;
  8001ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d3:	ff 43 04             	incl   0x4(%ebx)
}
  8001d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001eb:	00 00 00 
	b.cnt = 0;
  8001ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f8:	ff 75 0c             	pushl  0xc(%ebp)
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	68 9c 01 80 00       	push   $0x80019c
  80020a:	e8 82 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020f:	83 c4 08             	add    $0x8,%esp
  800212:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800218:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021e:	50                   	push   %eax
  80021f:	e8 89 09 00 00       	call   800bad <sys_cputs>

	return b.cnt;
}
  800224:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800232:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800235:	50                   	push   %eax
  800236:	ff 75 08             	pushl  0x8(%ebp)
  800239:	e8 9d ff ff ff       	call   8001db <vcprintf>
	va_end(ap);

	return cnt;
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 2c             	sub    $0x2c,%esp
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80024c:	89 d6                	mov    %edx,%esi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	8b 55 0c             	mov    0xc(%ebp),%edx
  800254:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800257:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800260:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800263:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800266:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80026d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800270:	72 0c                	jb     80027e <printnum+0x3e>
  800272:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800275:	76 07                	jbe    80027e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800277:	4b                   	dec    %ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f 31                	jg     8002ad <printnum+0x6d>
  80027c:	eb 3f                	jmp    8002bd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	57                   	push   %edi
  800282:	4b                   	dec    %ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 d4             	pushl  -0x2c(%ebp)
  80028b:	ff 75 d0             	pushl  -0x30(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 eb 0a 00 00       	call   800d84 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a3:	e8 98 ff ff ff       	call   800240 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 10                	jmp    8002bd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	57                   	push   %edi
  8002b2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	4b                   	dec    %ebx
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	85 db                	test   %ebx,%ebx
  8002bb:	7f f0                	jg     8002ad <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	83 ec 04             	sub    $0x4,%esp
  8002c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 cb 0b 00 00       	call   800ea0 <__umoddi3>
  8002d5:	83 c4 14             	add    $0x14,%esp
  8002d8:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  8002df:	50                   	push   %eax
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002e3:	83 c4 10             	add    $0x10,%esp
}
  8002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 fa 01             	cmp    $0x1,%edx
  8002f4:	7e 0e                	jle    800304 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	8b 52 04             	mov    0x4(%edx),%edx
  800302:	eb 22                	jmp    800326 <getuint+0x38>
	else if (lflag)
  800304:	85 d2                	test   %edx,%edx
  800306:	74 10                	je     800318 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 0e                	jmp    800326 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032b:	83 fa 01             	cmp    $0x1,%edx
  80032e:	7e 0e                	jle    80033e <getint+0x16>
		return va_arg(*ap, long long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 08             	lea    0x8(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	8b 52 04             	mov    0x4(%edx),%edx
  80033c:	eb 1a                	jmp    800358 <getint+0x30>
	else if (lflag)
  80033e:	85 d2                	test   %edx,%edx
  800340:	74 0c                	je     80034e <getint+0x26>
		return va_arg(*ap, long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	99                   	cltd   
  80034c:	eb 0a                	jmp    800358 <getint+0x30>
	else
		return va_arg(*ap, int);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 04             	lea    0x4(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	99                   	cltd   
}
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800360:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800363:	8b 10                	mov    (%eax),%edx
  800365:	3b 50 04             	cmp    0x4(%eax),%edx
  800368:	73 08                	jae    800372 <sprintputch+0x18>
		*b->buf++ = ch;
  80036a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036d:	88 0a                	mov    %cl,(%edx)
  80036f:	42                   	inc    %edx
  800370:	89 10                	mov    %edx,(%eax)
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80037a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	e8 05 00 00 00       	call   800391 <vprintfmt>
	va_end(ap);
  80038c:	83 c4 10             	add    $0x10,%esp
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 2c             	sub    $0x2c,%esp
  80039a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80039d:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a0:	eb 13                	jmp    8003b5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a2:	85 c0                	test   %eax,%eax
  8003a4:	0f 84 6d 03 00 00    	je     800717 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	57                   	push   %edi
  8003ae:	50                   	push   %eax
  8003af:	ff 55 08             	call   *0x8(%ebp)
  8003b2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b5:	0f b6 06             	movzbl (%esi),%eax
  8003b8:	46                   	inc    %esi
  8003b9:	83 f8 25             	cmp    $0x25,%eax
  8003bc:	75 e4                	jne    8003a2 <vprintfmt+0x11>
  8003be:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003d0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dc:	eb 28                	jmp    800406 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003e4:	eb 20                	jmp    800406 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003ec:	eb 18                	jmp    800406 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f7:	eb 0d                	jmp    800406 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ff:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8a 06                	mov    (%esi),%al
  800408:	0f b6 d0             	movzbl %al,%edx
  80040b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80040e:	83 e8 23             	sub    $0x23,%eax
  800411:	3c 55                	cmp    $0x55,%al
  800413:	0f 87 e0 02 00 00    	ja     8006f9 <vprintfmt+0x368>
  800419:	0f b6 c0             	movzbl %al,%eax
  80041c:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800423:	83 ea 30             	sub    $0x30,%edx
  800426:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800429:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80042c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80042f:	83 fa 09             	cmp    $0x9,%edx
  800432:	77 44                	ja     800478 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	89 de                	mov    %ebx,%esi
  800436:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800439:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80043a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80043d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800441:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800444:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800447:	83 fb 09             	cmp    $0x9,%ebx
  80044a:	76 ed                	jbe    800439 <vprintfmt+0xa8>
  80044c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80044f:	eb 29                	jmp    80047a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800461:	eb 17                	jmp    80047a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800463:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800467:	78 85                	js     8003ee <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	89 de                	mov    %ebx,%esi
  80046b:	eb 99                	jmp    800406 <vprintfmt+0x75>
  80046d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800476:	eb 8e                	jmp    800406 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047e:	79 86                	jns    800406 <vprintfmt+0x75>
  800480:	e9 74 ff ff ff       	jmp    8003f9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800485:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
  800488:	e9 79 ff ff ff       	jmp    800406 <vprintfmt+0x75>
  80048d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	57                   	push   %edi
  80049d:	ff 30                	pushl  (%eax)
  80049f:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a8:	e9 08 ff ff ff       	jmp    8003b5 <vprintfmt+0x24>
  8004ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	79 02                	jns    8004c1 <vprintfmt+0x130>
  8004bf:	f7 d8                	neg    %eax
  8004c1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c3:	83 f8 08             	cmp    $0x8,%eax
  8004c6:	7f 0b                	jg     8004d3 <vprintfmt+0x142>
  8004c8:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	75 1a                	jne    8004ed <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004d3:	52                   	push   %edx
  8004d4:	68 e4 10 80 00       	push   $0x8010e4
  8004d9:	57                   	push   %edi
  8004da:	ff 75 08             	pushl  0x8(%ebp)
  8004dd:	e8 92 fe ff ff       	call   800374 <printfmt>
  8004e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e8:	e9 c8 fe ff ff       	jmp    8003b5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004ed:	50                   	push   %eax
  8004ee:	68 ed 10 80 00       	push   $0x8010ed
  8004f3:	57                   	push   %edi
  8004f4:	ff 75 08             	pushl  0x8(%ebp)
  8004f7:	e8 78 fe ff ff       	call   800374 <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800502:	e9 ae fe ff ff       	jmp    8003b5 <vprintfmt+0x24>
  800507:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80050a:	89 de                	mov    %ebx,%esi
  80050c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80050f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800520:	85 c0                	test   %eax,%eax
  800522:	75 07                	jne    80052b <vprintfmt+0x19a>
				p = "(null)";
  800524:	c7 45 d0 dd 10 80 00 	movl   $0x8010dd,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80052b:	85 db                	test   %ebx,%ebx
  80052d:	7e 42                	jle    800571 <vprintfmt+0x1e0>
  80052f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800533:	74 3c                	je     800571 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	51                   	push   %ecx
  800539:	ff 75 d0             	pushl  -0x30(%ebp)
  80053c:	e8 6f 02 00 00       	call   8007b0 <strnlen>
  800541:	29 c3                	sub    %eax,%ebx
  800543:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 db                	test   %ebx,%ebx
  80054b:	7e 24                	jle    800571 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80054d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800551:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800554:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	57                   	push   %edi
  80055b:	53                   	push   %ebx
  80055c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	4e                   	dec    %esi
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	85 f6                	test   %esi,%esi
  800565:	7f f0                	jg     800557 <vprintfmt+0x1c6>
  800567:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80056a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800571:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800574:	0f be 02             	movsbl (%edx),%eax
  800577:	85 c0                	test   %eax,%eax
  800579:	75 47                	jne    8005c2 <vprintfmt+0x231>
  80057b:	eb 37                	jmp    8005b4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80057d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800581:	74 16                	je     800599 <vprintfmt+0x208>
  800583:	8d 50 e0             	lea    -0x20(%eax),%edx
  800586:	83 fa 5e             	cmp    $0x5e,%edx
  800589:	76 0e                	jbe    800599 <vprintfmt+0x208>
					putch('?', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	57                   	push   %edi
  80058f:	6a 3f                	push   $0x3f
  800591:	ff 55 08             	call   *0x8(%ebp)
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	eb 0b                	jmp    8005a4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	57                   	push   %edi
  80059d:	50                   	push   %eax
  80059e:	ff 55 08             	call   *0x8(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a7:	0f be 03             	movsbl (%ebx),%eax
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	74 03                	je     8005b1 <vprintfmt+0x220>
  8005ae:	43                   	inc    %ebx
  8005af:	eb 1b                	jmp    8005cc <vprintfmt+0x23b>
  8005b1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b8:	7f 1e                	jg     8005d8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005bd:	e9 f3 fd ff ff       	jmp    8003b5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c5:	43                   	inc    %ebx
  8005c6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005cc:	85 f6                	test   %esi,%esi
  8005ce:	78 ad                	js     80057d <vprintfmt+0x1ec>
  8005d0:	4e                   	dec    %esi
  8005d1:	79 aa                	jns    80057d <vprintfmt+0x1ec>
  8005d3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005d6:	eb dc                	jmp    8005b4 <vprintfmt+0x223>
  8005d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 20                	push   $0x20
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e4:	4b                   	dec    %ebx
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	85 db                	test   %ebx,%ebx
  8005ea:	7f ef                	jg     8005db <vprintfmt+0x24a>
  8005ec:	e9 c4 fd ff ff       	jmp    8003b5 <vprintfmt+0x24>
  8005f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f4:	89 ca                	mov    %ecx,%edx
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 2a fd ff ff       	call   800328 <getint>
  8005fe:	89 c3                	mov    %eax,%ebx
  800600:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800602:	85 d2                	test   %edx,%edx
  800604:	78 0a                	js     800610 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060b:	e9 b0 00 00 00       	jmp    8006c0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	57                   	push   %edi
  800614:	6a 2d                	push   $0x2d
  800616:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800619:	f7 db                	neg    %ebx
  80061b:	83 d6 00             	adc    $0x0,%esi
  80061e:	f7 de                	neg    %esi
  800620:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800623:	b8 0a 00 00 00       	mov    $0xa,%eax
  800628:	e9 93 00 00 00       	jmp    8006c0 <vprintfmt+0x32f>
  80062d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 b4 fc ff ff       	call   8002ee <getuint>
  80063a:	89 c3                	mov    %eax,%ebx
  80063c:	89 d6                	mov    %edx,%esi
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800643:	eb 7b                	jmp    8006c0 <vprintfmt+0x32f>
  800645:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800648:	89 ca                	mov    %ecx,%edx
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 d6 fc ff ff       	call   800328 <getint>
  800652:	89 c3                	mov    %eax,%ebx
  800654:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800656:	85 d2                	test   %edx,%edx
  800658:	78 07                	js     800661 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80065a:	b8 08 00 00 00       	mov    $0x8,%eax
  80065f:	eb 5f                	jmp    8006c0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	57                   	push   %edi
  800665:	6a 2d                	push   $0x2d
  800667:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80066a:	f7 db                	neg    %ebx
  80066c:	83 d6 00             	adc    $0x0,%esi
  80066f:	f7 de                	neg    %esi
  800671:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800674:	b8 08 00 00 00       	mov    $0x8,%eax
  800679:	eb 45                	jmp    8006c0 <vprintfmt+0x32f>
  80067b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	57                   	push   %edi
  800682:	6a 30                	push   $0x30
  800684:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	57                   	push   %edi
  80068b:	6a 78                	push   $0x78
  80068d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800699:	8b 18                	mov    (%eax),%ebx
  80069b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a8:	eb 16                	jmp    8006c0 <vprintfmt+0x32f>
  8006aa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ad:	89 ca                	mov    %ecx,%edx
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 37 fc ff ff       	call   8002ee <getuint>
  8006b7:	89 c3                	mov    %eax,%ebx
  8006b9:	89 d6                	mov    %edx,%esi
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006c7:	52                   	push   %edx
  8006c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cb:	50                   	push   %eax
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	89 fa                	mov    %edi,%edx
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	e8 68 fb ff ff       	call   800240 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006de:	e9 d2 fc ff ff       	jmp    8003b5 <vprintfmt+0x24>
  8006e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	57                   	push   %edi
  8006ea:	52                   	push   %edx
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f4:	e9 bc fc ff ff       	jmp    8003b5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	6a 25                	push   $0x25
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 02                	jmp    800709 <vprintfmt+0x378>
  800707:	89 c6                	mov    %eax,%esi
  800709:	8d 46 ff             	lea    -0x1(%esi),%eax
  80070c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800710:	75 f5                	jne    800707 <vprintfmt+0x376>
  800712:	e9 9e fc ff ff       	jmp    8003b5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 29                	jle    80076d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 5a 03 80 00       	push   $0x80035a
  800753:	e8 39 fc ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 0c                	jmp    800772 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb 05                	jmp    800772 <vsnprintf+0x53>
  80076d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077d:	50                   	push   %eax
  80077e:	ff 75 10             	pushl  0x10(%ebp)
  800781:	ff 75 0c             	pushl  0xc(%ebp)
  800784:	ff 75 08             	pushl  0x8(%ebp)
  800787:	e8 93 ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    
	...

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	80 3a 00             	cmpb   $0x0,(%edx)
  800799:	74 0e                	je     8007a9 <strlen+0x19>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a5:	75 f9                	jne    8007a0 <strlen+0x10>
  8007a7:	eb 05                	jmp    8007ae <strlen+0x1e>
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 17                	je     8007d4 <strnlen+0x24>
  8007bd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c0:	74 19                	je     8007db <strnlen+0x2b>
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007c7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	39 d0                	cmp    %edx,%eax
  8007ca:	74 14                	je     8007e0 <strnlen+0x30>
  8007cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d0:	75 f5                	jne    8007c7 <strnlen+0x17>
  8007d2:	eb 0c                	jmp    8007e0 <strnlen+0x30>
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 05                	jmp    8007e0 <strnlen+0x30>
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f7:	42                   	inc    %edx
  8007f8:	84 c9                	test   %cl,%cl
  8007fa:	75 f5                	jne    8007f1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800806:	53                   	push   %ebx
  800807:	e8 84 ff ff ff       	call   800790 <strlen>
  80080c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800815:	50                   	push   %eax
  800816:	e8 c7 ff ff ff       	call   8007e2 <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	85 f6                	test   %esi,%esi
  800832:	74 15                	je     800849 <strncpy+0x27>
  800834:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800839:	8a 1a                	mov    (%edx),%bl
  80083b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083e:	80 3a 01             	cmpb   $0x1,(%edx)
  800841:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	41                   	inc    %ecx
  800845:	39 ce                	cmp    %ecx,%esi
  800847:	77 f0                	ja     800839 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	57                   	push   %edi
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 7d 08             	mov    0x8(%ebp),%edi
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800859:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	85 f6                	test   %esi,%esi
  80085e:	74 32                	je     800892 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800860:	83 fe 01             	cmp    $0x1,%esi
  800863:	74 22                	je     800887 <strlcpy+0x3a>
  800865:	8a 0b                	mov    (%ebx),%cl
  800867:	84 c9                	test   %cl,%cl
  800869:	74 20                	je     80088b <strlcpy+0x3e>
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800872:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800875:	88 08                	mov    %cl,(%eax)
  800877:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800878:	39 f2                	cmp    %esi,%edx
  80087a:	74 11                	je     80088d <strlcpy+0x40>
  80087c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800880:	42                   	inc    %edx
  800881:	84 c9                	test   %cl,%cl
  800883:	75 f0                	jne    800875 <strlcpy+0x28>
  800885:	eb 06                	jmp    80088d <strlcpy+0x40>
  800887:	89 f8                	mov    %edi,%eax
  800889:	eb 02                	jmp    80088d <strlcpy+0x40>
  80088b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 00 00             	movb   $0x0,(%eax)
  800890:	eb 02                	jmp    800894 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800894:	29 f8                	sub    %edi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5f                   	pop    %edi
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	8a 01                	mov    (%ecx),%al
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 10                	je     8008ba <strcmp+0x1f>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	75 0c                	jne    8008ba <strcmp+0x1f>
		p++, q++;
  8008ae:	41                   	inc    %ecx
  8008af:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	8a 01                	mov    (%ecx),%al
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 04                	je     8008ba <strcmp+0x1f>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	74 f4                	je     8008ae <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 c0             	movzbl %al,%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
}
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	74 1b                	je     8008f0 <strncmp+0x2c>
  8008d5:	8a 1a                	mov    (%edx),%bl
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	74 24                	je     8008ff <strncmp+0x3b>
  8008db:	3a 19                	cmp    (%ecx),%bl
  8008dd:	75 20                	jne    8008ff <strncmp+0x3b>
  8008df:	48                   	dec    %eax
  8008e0:	74 15                	je     8008f7 <strncmp+0x33>
		n--, p++, q++;
  8008e2:	42                   	inc    %edx
  8008e3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e4:	8a 1a                	mov    (%edx),%bl
  8008e6:	84 db                	test   %bl,%bl
  8008e8:	74 15                	je     8008ff <strncmp+0x3b>
  8008ea:	3a 19                	cmp    (%ecx),%bl
  8008ec:	74 f1                	je     8008df <strncmp+0x1b>
  8008ee:	eb 0f                	jmp    8008ff <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f5:	eb 05                	jmp    8008fc <strncmp+0x38>
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fc:	5b                   	pop    %ebx
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ff:	0f b6 02             	movzbl (%edx),%eax
  800902:	0f b6 11             	movzbl (%ecx),%edx
  800905:	29 d0                	sub    %edx,%eax
  800907:	eb f3                	jmp    8008fc <strncmp+0x38>

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800912:	8a 10                	mov    (%eax),%dl
  800914:	84 d2                	test   %dl,%dl
  800916:	74 18                	je     800930 <strchr+0x27>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	75 06                	jne    800922 <strchr+0x19>
  80091c:	eb 17                	jmp    800935 <strchr+0x2c>
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	74 13                	je     800935 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800922:	40                   	inc    %eax
  800923:	8a 10                	mov    (%eax),%dl
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f5                	jne    80091e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 05                	jmp    800935 <strchr+0x2c>
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800940:	8a 10                	mov    (%eax),%dl
  800942:	84 d2                	test   %dl,%dl
  800944:	74 11                	je     800957 <strfind+0x20>
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	75 06                	jne    800950 <strfind+0x19>
  80094a:	eb 0b                	jmp    800957 <strfind+0x20>
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 07                	je     800957 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800950:	40                   	inc    %eax
  800951:	8a 10                	mov    (%eax),%dl
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f5                	jne    80094c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 30                	je     80099c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800972:	75 25                	jne    800999 <memset+0x40>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 20                	jne    800999 <memset+0x40>
		c &= 0xFF;
  800979:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097c:	89 d3                	mov    %edx,%ebx
  80097e:	c1 e3 08             	shl    $0x8,%ebx
  800981:	89 d6                	mov    %edx,%esi
  800983:	c1 e6 18             	shl    $0x18,%esi
  800986:	89 d0                	mov    %edx,%eax
  800988:	c1 e0 10             	shl    $0x10,%eax
  80098b:	09 f0                	or     %esi,%eax
  80098d:	09 d0                	or     %edx,%eax
  80098f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800991:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800994:	fc                   	cld    
  800995:	f3 ab                	rep stos %eax,%es:(%edi)
  800997:	eb 03                	jmp    80099c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 34                	jae    8009e9 <memmove+0x46>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2d                	jae    8009e9 <memmove+0x46>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	f6 c2 03             	test   $0x3,%dl
  8009c2:	75 1b                	jne    8009df <memmove+0x3c>
  8009c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ca:	75 13                	jne    8009df <memmove+0x3c>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0e                	jne    8009df <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d1:	83 ef 04             	sub    $0x4,%edi
  8009d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009da:	fd                   	std    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb 07                	jmp    8009e6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009df:	4f                   	dec    %edi
  8009e0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e3:	fd                   	std    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e6:	fc                   	cld    
  8009e7:	eb 20                	jmp    800a09 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ef:	75 13                	jne    800a04 <memmove+0x61>
  8009f1:	a8 03                	test   $0x3,%al
  8009f3:	75 0f                	jne    800a04 <memmove+0x61>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0a                	jne    800a04 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	fc                   	cld    
  800a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a02:	eb 05                	jmp    800a09 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a04:	89 c7                	mov    %eax,%edi
  800a06:	fc                   	cld    
  800a07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a10:	ff 75 10             	pushl  0x10(%ebp)
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	ff 75 08             	pushl  0x8(%ebp)
  800a19:	e8 85 ff ff ff       	call   8009a3 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	85 ff                	test   %edi,%edi
  800a31:	74 32                	je     800a65 <memcmp+0x45>
		if (*s1 != *s2)
  800a33:	8a 03                	mov    (%ebx),%al
  800a35:	8a 0e                	mov    (%esi),%cl
  800a37:	38 c8                	cmp    %cl,%al
  800a39:	74 19                	je     800a54 <memcmp+0x34>
  800a3b:	eb 0d                	jmp    800a4a <memcmp+0x2a>
  800a3d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a41:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a45:	42                   	inc    %edx
  800a46:	38 c8                	cmp    %cl,%al
  800a48:	74 10                	je     800a5a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a4a:	0f b6 c0             	movzbl %al,%eax
  800a4d:	0f b6 c9             	movzbl %cl,%ecx
  800a50:	29 c8                	sub    %ecx,%eax
  800a52:	eb 16                	jmp    800a6a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	4f                   	dec    %edi
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	39 fa                	cmp    %edi,%edx
  800a5c:	75 df                	jne    800a3d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	eb 05                	jmp    800a6a <memcmp+0x4a>
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	73 12                	jae    800a90 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a81:	38 08                	cmp    %cl,(%eax)
  800a83:	75 06                	jne    800a8b <memfind+0x1c>
  800a85:	eb 09                	jmp    800a90 <memfind+0x21>
  800a87:	38 08                	cmp    %cl,(%eax)
  800a89:	74 05                	je     800a90 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8b:	40                   	inc    %eax
  800a8c:	39 c2                	cmp    %eax,%edx
  800a8e:	77 f7                	ja     800a87 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9e:	eb 01                	jmp    800aa1 <strtol+0xf>
		s++;
  800aa0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa1:	8a 02                	mov    (%edx),%al
  800aa3:	3c 20                	cmp    $0x20,%al
  800aa5:	74 f9                	je     800aa0 <strtol+0xe>
  800aa7:	3c 09                	cmp    $0x9,%al
  800aa9:	74 f5                	je     800aa0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aab:	3c 2b                	cmp    $0x2b,%al
  800aad:	75 08                	jne    800ab7 <strtol+0x25>
		s++;
  800aaf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab5:	eb 13                	jmp    800aca <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab7:	3c 2d                	cmp    $0x2d,%al
  800ab9:	75 0a                	jne    800ac5 <strtol+0x33>
		s++, neg = 1;
  800abb:	8d 52 01             	lea    0x1(%edx),%edx
  800abe:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac3:	eb 05                	jmp    800aca <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 05                	je     800ad3 <strtol+0x41>
  800ace:	83 fb 10             	cmp    $0x10,%ebx
  800ad1:	75 28                	jne    800afb <strtol+0x69>
  800ad3:	8a 02                	mov    (%edx),%al
  800ad5:	3c 30                	cmp    $0x30,%al
  800ad7:	75 10                	jne    800ae9 <strtol+0x57>
  800ad9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800add:	75 0a                	jne    800ae9 <strtol+0x57>
		s += 2, base = 16;
  800adf:	83 c2 02             	add    $0x2,%edx
  800ae2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae7:	eb 12                	jmp    800afb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	75 0e                	jne    800afb <strtol+0x69>
  800aed:	3c 30                	cmp    $0x30,%al
  800aef:	75 05                	jne    800af6 <strtol+0x64>
		s++, base = 8;
  800af1:	42                   	inc    %edx
  800af2:	b3 08                	mov    $0x8,%bl
  800af4:	eb 05                	jmp    800afb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800af6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b02:	8a 0a                	mov    (%edx),%cl
  800b04:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b07:	80 fb 09             	cmp    $0x9,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0x82>
			dig = *s - '0';
  800b0c:	0f be c9             	movsbl %cl,%ecx
  800b0f:	83 e9 30             	sub    $0x30,%ecx
  800b12:	eb 1e                	jmp    800b32 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b14:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b17:	80 fb 19             	cmp    $0x19,%bl
  800b1a:	77 08                	ja     800b24 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b1c:	0f be c9             	movsbl %cl,%ecx
  800b1f:	83 e9 57             	sub    $0x57,%ecx
  800b22:	eb 0e                	jmp    800b32 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b24:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 13                	ja     800b3f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b2c:	0f be c9             	movsbl %cl,%ecx
  800b2f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b32:	39 f1                	cmp    %esi,%ecx
  800b34:	7d 0d                	jge    800b43 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b36:	42                   	inc    %edx
  800b37:	0f af c6             	imul   %esi,%eax
  800b3a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b3d:	eb c3                	jmp    800b02 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b3f:	89 c1                	mov    %eax,%ecx
  800b41:	eb 02                	jmp    800b45 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b43:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b49:	74 05                	je     800b50 <strtol+0xbe>
		*endptr = (char *) s;
  800b4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b50:	85 ff                	test   %edi,%edi
  800b52:	74 04                	je     800b58 <strtol+0xc6>
  800b54:	89 c8                	mov    %ecx,%eax
  800b56:	f7 d8                	neg    %eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    
  800b5d:	00 00                	add    %al,(%eax)
	...

00800b60 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 1c             	sub    $0x1c,%esp
  800b69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b6c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b6f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	8b 75 14             	mov    0x14(%ebp),%esi
  800b74:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	cd 30                	int    $0x30
  800b7f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b85:	74 1c                	je     800ba3 <syscall+0x43>
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 18                	jle    800ba3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b92:	68 24 13 80 00       	push   $0x801324
  800b97:	6a 42                	push   $0x42
  800b99:	68 41 13 80 00       	push   $0x801341
  800b9e:	e8 b1 f5 ff ff       	call   800154 <_panic>

	return ret;
}
  800ba3:	89 d0                	mov    %edx,%eax
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	ff 75 0c             	pushl  0xc(%ebp)
  800bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	e8 92 ff ff ff       	call   800b60 <syscall>
  800bce:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bd9:	6a 00                	push   $0x0
  800bdb:	6a 00                	push   $0x0
  800bdd:	6a 00                	push   $0x0
  800bdf:	6a 00                	push   $0x0
  800be1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf0:	e8 6b ff ff ff       	call   800b60 <syscall>
}
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bfd:	6a 00                	push   $0x0
  800bff:	6a 00                	push   $0x0
  800c01:	6a 00                	push   $0x0
  800c03:	6a 00                	push   $0x0
  800c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c08:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c12:	e8 49 ff ff ff       	call   800b60 <syscall>
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c1f:	6a 00                	push   $0x0
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 02 00 00 00       	mov    $0x2,%eax
  800c36:	e8 25 ff ff ff       	call   800b60 <syscall>
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <sys_yield>:

void
sys_yield(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c43:	6a 00                	push   $0x0
  800c45:	6a 00                	push   $0x0
  800c47:	6a 00                	push   $0x0
  800c49:	6a 00                	push   $0x0
  800c4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5a:	e8 01 ff ff ff       	call   800b60 <syscall>
  800c5f:	83 c4 10             	add    $0x10,%esp
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	ff 75 10             	pushl  0x10(%ebp)
  800c71:	ff 75 0c             	pushl  0xc(%ebp)
  800c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c77:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c81:	e8 da fe ff ff       	call   800b60 <syscall>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c8e:	ff 75 18             	pushl  0x18(%ebp)
  800c91:	ff 75 14             	pushl  0x14(%ebp)
  800c94:	ff 75 10             	pushl  0x10(%ebp)
  800c97:	ff 75 0c             	pushl  0xc(%ebp)
  800c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	e8 b4 fe ff ff       	call   800b60 <syscall>
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cb4:	6a 00                	push   $0x0
  800cb6:	6a 00                	push   $0x0
  800cb8:	6a 00                	push   $0x0
  800cba:	ff 75 0c             	pushl  0xc(%ebp)
  800cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cca:	e8 91 fe ff ff       	call   800b60 <syscall>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	ff 75 0c             	pushl  0xc(%ebp)
  800ce0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ced:	e8 6e fe ff ff       	call   800b60 <syscall>
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cfa:	6a 00                	push   $0x0
  800cfc:	6a 00                	push   $0x0
  800cfe:	6a 00                	push   $0x0
  800d00:	ff 75 0c             	pushl  0xc(%ebp)
  800d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d06:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	e8 4b fe ff ff       	call   800b60 <syscall>
}
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d1d:	6a 00                	push   $0x0
  800d1f:	ff 75 14             	pushl  0x14(%ebp)
  800d22:	ff 75 10             	pushl  0x10(%ebp)
  800d25:	ff 75 0c             	pushl  0xc(%ebp)
  800d28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d35:	e8 26 fe ff ff       	call   800b60 <syscall>
}
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d42:	6a 00                	push   $0x0
  800d44:	6a 00                	push   $0x0
  800d46:	6a 00                	push   $0x0
  800d48:	6a 00                	push   $0x0
  800d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d57:	e8 04 fe ff ff       	call   800b60 <syscall>
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d64:	6a 00                	push   $0x0
  800d66:	6a 00                	push   $0x0
  800d68:	6a 00                	push   $0x0
  800d6a:	ff 75 0c             	pushl  0xc(%ebp)
  800d6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7a:	e8 e1 fd ff ff       	call   800b60 <syscall>
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    
  800d81:	00 00                	add    %al,(%eax)
	...

00800d84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	83 ec 10             	sub    $0x10,%esp
  800d8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d92:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d95:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d9b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	75 2e                	jne    800dd0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800da2:	39 f1                	cmp    %esi,%ecx
  800da4:	77 5a                	ja     800e00 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800da6:	85 c9                	test   %ecx,%ecx
  800da8:	75 0b                	jne    800db5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800daa:	b8 01 00 00 00       	mov    $0x1,%eax
  800daf:	31 d2                	xor    %edx,%edx
  800db1:	f7 f1                	div    %ecx
  800db3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	f7 f1                	div    %ecx
  800dbb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dbd:	89 f8                	mov    %edi,%eax
  800dbf:	f7 f1                	div    %ecx
  800dc1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc3:	89 f8                	mov    %edi,%eax
  800dc5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    
  800dce:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dd0:	39 f0                	cmp    %esi,%eax
  800dd2:	77 1c                	ja     800df0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dd4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800dd7:	83 f7 1f             	xor    $0x1f,%edi
  800dda:	75 3c                	jne    800e18 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ddc:	39 f0                	cmp    %esi,%eax
  800dde:	0f 82 90 00 00 00    	jb     800e74 <__udivdi3+0xf0>
  800de4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dea:	0f 86 84 00 00 00    	jbe    800e74 <__udivdi3+0xf0>
  800df0:	31 f6                	xor    %esi,%esi
  800df2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df4:	89 f8                	mov    %edi,%eax
  800df6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	c9                   	leave  
  800dfe:	c3                   	ret    
  800dff:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e00:	89 f2                	mov    %esi,%edx
  800e02:	89 f8                	mov    %edi,%eax
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c7                	mov    %eax,%edi
  800e08:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0a:	89 f8                	mov    %edi,%eax
  800e0c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e18:	89 f9                	mov    %edi,%ecx
  800e1a:	d3 e0                	shl    %cl,%eax
  800e1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e1f:	b8 20 00 00 00       	mov    $0x20,%eax
  800e24:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e29:	88 c1                	mov    %al,%cl
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e30:	09 ca                	or     %ecx,%edx
  800e32:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e38:	89 f9                	mov    %edi,%ecx
  800e3a:	d3 e2                	shl    %cl,%edx
  800e3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e3f:	89 f2                	mov    %esi,%edx
  800e41:	88 c1                	mov    %al,%cl
  800e43:	d3 ea                	shr    %cl,%edx
  800e45:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e48:	89 f2                	mov    %esi,%edx
  800e4a:	89 f9                	mov    %edi,%ecx
  800e4c:	d3 e2                	shl    %cl,%edx
  800e4e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e51:	88 c1                	mov    %al,%cl
  800e53:	d3 ee                	shr    %cl,%esi
  800e55:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e57:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e5a:	89 f0                	mov    %esi,%eax
  800e5c:	89 ca                	mov    %ecx,%edx
  800e5e:	f7 75 ec             	divl   -0x14(%ebp)
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e65:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e68:	39 d1                	cmp    %edx,%ecx
  800e6a:	72 28                	jb     800e94 <__udivdi3+0x110>
  800e6c:	74 1a                	je     800e88 <__udivdi3+0x104>
  800e6e:	89 f7                	mov    %esi,%edi
  800e70:	31 f6                	xor    %esi,%esi
  800e72:	eb 80                	jmp    800df4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e74:	31 f6                	xor    %esi,%esi
  800e76:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e7b:	89 f8                	mov    %edi,%eax
  800e7d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    
  800e86:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8f:	39 c2                	cmp    %eax,%edx
  800e91:	73 db                	jae    800e6e <__udivdi3+0xea>
  800e93:	90                   	nop
		{
		  q0--;
  800e94:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e97:	31 f6                	xor    %esi,%esi
  800e99:	e9 56 ff ff ff       	jmp    800df4 <__udivdi3+0x70>
	...

00800ea0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	83 ec 20             	sub    $0x20,%esp
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800eb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800eb4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800eb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ebd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ebf:	85 ff                	test   %edi,%edi
  800ec1:	75 15                	jne    800ed8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800ec3:	39 f1                	cmp    %esi,%ecx
  800ec5:	0f 86 99 00 00 00    	jbe    800f64 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ecd:	89 d0                	mov    %edx,%eax
  800ecf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed1:	83 c4 20             	add    $0x20,%esp
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed8:	39 f7                	cmp    %esi,%edi
  800eda:	0f 87 a4 00 00 00    	ja     800f84 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ee0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ee3:	83 f0 1f             	xor    $0x1f,%eax
  800ee6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ee9:	0f 84 a1 00 00 00    	je     800f90 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eef:	89 f8                	mov    %edi,%eax
  800ef1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ef4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ef6:	bf 20 00 00 00       	mov    $0x20,%edi
  800efb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 ea                	shr    %cl,%edx
  800f05:	09 c2                	or     %eax,%edx
  800f07:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f10:	d3 e0                	shl    %cl,%eax
  800f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f15:	89 f2                	mov    %esi,%edx
  800f17:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f1c:	d3 e0                	shl    %cl,%eax
  800f1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f24:	89 f9                	mov    %edi,%ecx
  800f26:	d3 e8                	shr    %cl,%eax
  800f28:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f2a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f2c:	89 f2                	mov    %esi,%edx
  800f2e:	f7 75 f0             	divl   -0x10(%ebp)
  800f31:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f33:	f7 65 f4             	mull   -0xc(%ebp)
  800f36:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f39:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f3b:	39 d6                	cmp    %edx,%esi
  800f3d:	72 71                	jb     800fb0 <__umoddi3+0x110>
  800f3f:	74 7f                	je     800fc0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f44:	29 c8                	sub    %ecx,%eax
  800f46:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f48:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 f2                	mov    %esi,%edx
  800f4f:	89 f9                	mov    %edi,%ecx
  800f51:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f53:	09 d0                	or     %edx,%eax
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f5a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    
  800f63:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f64:	85 c9                	test   %ecx,%ecx
  800f66:	75 0b                	jne    800f73 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f68:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	f7 f1                	div    %ecx
  800f71:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f73:	89 f0                	mov    %esi,%eax
  800f75:	31 d2                	xor    %edx,%edx
  800f77:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7c:	f7 f1                	div    %ecx
  800f7e:	e9 4a ff ff ff       	jmp    800ecd <__umoddi3+0x2d>
  800f83:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f84:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f90:	39 f7                	cmp    %esi,%edi
  800f92:	72 05                	jb     800f99 <__umoddi3+0xf9>
  800f94:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f97:	77 0c                	ja     800fa5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9e:	29 c8                	sub    %ecx,%eax
  800fa0:	19 fa                	sbb    %edi,%edx
  800fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    
  800faf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fb0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800fb8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800fbb:	eb 84                	jmp    800f41 <__umoddi3+0xa1>
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fc3:	72 eb                	jb     800fb0 <__umoddi3+0x110>
  800fc5:	89 f2                	mov    %esi,%edx
  800fc7:	e9 75 ff ff ff       	jmp    800f41 <__umoddi3+0xa1>
