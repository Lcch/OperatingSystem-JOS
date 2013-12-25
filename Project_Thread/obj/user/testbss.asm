
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
  80003a:	68 80 1e 80 00       	push   $0x801e80
  80003f:	e8 f4 01 00 00       	call   800238 <cprintf>
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
  800067:	68 fb 1e 80 00       	push   $0x801efb
  80006c:	6a 11                	push   $0x11
  80006e:	68 18 1f 80 00       	push   $0x801f18
  800073:	e8 e8 00 00 00       	call   800160 <_panic>
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
  8000b3:	68 a0 1e 80 00       	push   $0x801ea0
  8000b8:	6a 16                	push   $0x16
  8000ba:	68 18 1f 80 00       	push   $0x801f18
  8000bf:	e8 9c 00 00 00       	call   800160 <_panic>
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
  8000cf:	68 c8 1e 80 00       	push   $0x801ec8
  8000d4:	e8 5f 01 00 00       	call   800238 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d9:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000e0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e3:	83 c4 0c             	add    $0xc,%esp
  8000e6:	68 27 1f 80 00       	push   $0x801f27
  8000eb:	6a 1a                	push   $0x1a
  8000ed:	68 18 1f 80 00       	push   $0x801f18
  8000f2:	e8 69 00 00 00       	call   800160 <_panic>
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
  800103:	e8 1d 0b 00 00       	call   800c25 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 07             	shl    $0x7,%edx
  800112:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800119:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 f6                	test   %esi,%esi
  800120:	7e 07                	jle    800129 <libmain+0x31>
		binaryname = argv[0];
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	53                   	push   %ebx
  80012d:	56                   	push   %esi
  80012e:	e8 01 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800133:	e8 0c 00 00 00       	call   800144 <exit>
  800138:	83 c4 10             	add    $0x10,%esp
}
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 d7 0e 00 00       	call   801026 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 aa 0a 00 00       	call   800c03 <sys_env_destroy>
  800159:	83 c4 10             	add    $0x10,%esp
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    
	...

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800165:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800168:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80016e:	e8 b2 0a 00 00       	call   800c25 <sys_getenvid>
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	53                   	push   %ebx
  80017d:	50                   	push   %eax
  80017e:	68 48 1f 80 00       	push   $0x801f48
  800183:	e8 b0 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	83 c4 18             	add    $0x18,%esp
  80018b:	56                   	push   %esi
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	e8 53 00 00 00       	call   8001e7 <vcprintf>
	cprintf("\n");
  800194:	c7 04 24 16 1f 80 00 	movl   $0x801f16,(%esp)
  80019b:	e8 98 00 00 00       	call   800238 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x43>
	...

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	40                   	inc    %eax
  8001bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 1a                	jne    8001df <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 e3 09 00 00       	call   800bb9 <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001df:	ff 43 04             	incl   0x4(%ebx)
}
  8001e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	ff 75 0c             	pushl  0xc(%ebp)
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	68 a8 01 80 00       	push   $0x8001a8
  800216:	e8 82 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021b:	83 c4 08             	add    $0x8,%esp
  80021e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 89 09 00 00       	call   800bb9 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 9d ff ff ff       	call   8001e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 2c             	sub    $0x2c,%esp
  800255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800258:	89 d6                	mov    %edx,%esi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800266:	8b 45 10             	mov    0x10(%ebp),%eax
  800269:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800272:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800279:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80027c:	72 0c                	jb     80028a <printnum+0x3e>
  80027e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800281:	76 07                	jbe    80028a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800283:	4b                   	dec    %ebx
  800284:	85 db                	test   %ebx,%ebx
  800286:	7f 31                	jg     8002b9 <printnum+0x6d>
  800288:	eb 3f                	jmp    8002c9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	57                   	push   %edi
  80028e:	4b                   	dec    %ebx
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 d4             	pushl  -0x2c(%ebp)
  800297:	ff 75 d0             	pushl  -0x30(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 87 19 00 00       	call   801c2c <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002af:	e8 98 ff ff ff       	call   80024c <printnum>
  8002b4:	83 c4 20             	add    $0x20,%esp
  8002b7:	eb 10                	jmp    8002c9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	57                   	push   %edi
  8002be:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c1:	4b                   	dec    %ebx
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f f0                	jg     8002b9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 67 1a 00 00       	call   801d48 <__umoddi3>
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	0f be 80 6b 1f 80 00 	movsbl 0x801f6b(%eax),%eax
  8002eb:	50                   	push   %eax
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
  8002ef:	83 c4 10             	add    $0x10,%esp
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fd:	83 fa 01             	cmp    $0x1,%edx
  800300:	7e 0e                	jle    800310 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 08             	lea    0x8(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	8b 52 04             	mov    0x4(%edx),%edx
  80030e:	eb 22                	jmp    800332 <getuint+0x38>
	else if (lflag)
  800310:	85 d2                	test   %edx,%edx
  800312:	74 10                	je     800324 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	eb 0e                	jmp    800332 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 04             	lea    0x4(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800337:	83 fa 01             	cmp    $0x1,%edx
  80033a:	7e 0e                	jle    80034a <getint+0x16>
		return va_arg(*ap, long long);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	8b 52 04             	mov    0x4(%edx),%edx
  800348:	eb 1a                	jmp    800364 <getint+0x30>
	else if (lflag)
  80034a:	85 d2                	test   %edx,%edx
  80034c:	74 0c                	je     80035a <getint+0x26>
		return va_arg(*ap, long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 04             	lea    0x4(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	99                   	cltd   
  800358:	eb 0a                	jmp    800364 <getint+0x30>
	else
		return va_arg(*ap, int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	99                   	cltd   
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	3b 50 04             	cmp    0x4(%eax),%edx
  800374:	73 08                	jae    80037e <sprintputch+0x18>
		*b->buf++ = ch;
  800376:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800379:	88 0a                	mov    %cl,(%edx)
  80037b:	42                   	inc    %edx
  80037c:	89 10                	mov    %edx,(%eax)
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800386:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	ff 75 0c             	pushl  0xc(%ebp)
  800390:	ff 75 08             	pushl  0x8(%ebp)
  800393:	e8 05 00 00 00       	call   80039d <vprintfmt>
	va_end(ap);
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
  8003a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ac:	eb 13                	jmp    8003c1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 84 6d 03 00 00    	je     800723 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	57                   	push   %edi
  8003ba:	50                   	push   %eax
  8003bb:	ff 55 08             	call   *0x8(%ebp)
  8003be:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	0f b6 06             	movzbl (%esi),%eax
  8003c4:	46                   	inc    %esi
  8003c5:	83 f8 25             	cmp    $0x25,%eax
  8003c8:	75 e4                	jne    8003ae <vprintfmt+0x11>
  8003ca:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ce:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003dc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	eb 28                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ec:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003f0:	eb 20                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003f8:	eb 18                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800403:	eb 0d                	jmp    800412 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800405:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8a 06                	mov    (%esi),%al
  800414:	0f b6 d0             	movzbl %al,%edx
  800417:	8d 5e 01             	lea    0x1(%esi),%ebx
  80041a:	83 e8 23             	sub    $0x23,%eax
  80041d:	3c 55                	cmp    $0x55,%al
  80041f:	0f 87 e0 02 00 00    	ja     800705 <vprintfmt+0x368>
  800425:	0f b6 c0             	movzbl %al,%eax
  800428:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042f:	83 ea 30             	sub    $0x30,%edx
  800432:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800435:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800438:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043b:	83 fa 09             	cmp    $0x9,%edx
  80043e:	77 44                	ja     800484 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	89 de                	mov    %ebx,%esi
  800442:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800445:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800446:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800449:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80044d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800450:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800453:	83 fb 09             	cmp    $0x9,%ebx
  800456:	76 ed                	jbe    800445 <vprintfmt+0xa8>
  800458:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80045b:	eb 29                	jmp    800486 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 00                	mov    (%eax),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046d:	eb 17                	jmp    800486 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80046f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800473:	78 85                	js     8003fa <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
  800477:	eb 99                	jmp    800412 <vprintfmt+0x75>
  800479:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800482:	eb 8e                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800486:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048a:	79 86                	jns    800412 <vprintfmt+0x75>
  80048c:	e9 74 ff ff ff       	jmp    800405 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800491:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	89 de                	mov    %ebx,%esi
  800494:	e9 79 ff ff ff       	jmp    800412 <vprintfmt+0x75>
  800499:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	57                   	push   %edi
  8004a9:	ff 30                	pushl  (%eax)
  8004ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b4:	e9 08 ff ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8004b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	79 02                	jns    8004cd <vprintfmt+0x130>
  8004cb:	f7 d8                	neg    %eax
  8004cd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cf:	83 f8 0f             	cmp    $0xf,%eax
  8004d2:	7f 0b                	jg     8004df <vprintfmt+0x142>
  8004d4:	8b 04 85 00 22 80 00 	mov    0x802200(,%eax,4),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	75 1a                	jne    8004f9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004df:	52                   	push   %edx
  8004e0:	68 83 1f 80 00       	push   $0x801f83
  8004e5:	57                   	push   %edi
  8004e6:	ff 75 08             	pushl  0x8(%ebp)
  8004e9:	e8 92 fe ff ff       	call   800380 <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f4:	e9 c8 fe ff ff       	jmp    8003c1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	50                   	push   %eax
  8004fa:	68 35 23 80 00       	push   $0x802335
  8004ff:	57                   	push   %edi
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 78 fe ff ff       	call   800380 <printfmt>
  800508:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050e:	e9 ae fe ff ff       	jmp    8003c1 <vprintfmt+0x24>
  800513:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800516:	89 de                	mov    %ebx,%esi
  800518:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052c:	85 c0                	test   %eax,%eax
  80052e:	75 07                	jne    800537 <vprintfmt+0x19a>
				p = "(null)";
  800530:	c7 45 d0 7c 1f 80 00 	movl   $0x801f7c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800537:	85 db                	test   %ebx,%ebx
  800539:	7e 42                	jle    80057d <vprintfmt+0x1e0>
  80053b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80053f:	74 3c                	je     80057d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	51                   	push   %ecx
  800545:	ff 75 d0             	pushl  -0x30(%ebp)
  800548:	e8 6f 02 00 00       	call   8007bc <strnlen>
  80054d:	29 c3                	sub    %eax,%ebx
  80054f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 db                	test   %ebx,%ebx
  800557:	7e 24                	jle    80057d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800559:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80055d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800560:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	53                   	push   %ebx
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4e                   	dec    %esi
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	85 f6                	test   %esi,%esi
  800571:	7f f0                	jg     800563 <vprintfmt+0x1c6>
  800573:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800576:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800580:	0f be 02             	movsbl (%edx),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	75 47                	jne    8005ce <vprintfmt+0x231>
  800587:	eb 37                	jmp    8005c0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058d:	74 16                	je     8005a5 <vprintfmt+0x208>
  80058f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800592:	83 fa 5e             	cmp    $0x5e,%edx
  800595:	76 0e                	jbe    8005a5 <vprintfmt+0x208>
					putch('?', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	57                   	push   %edi
  80059b:	6a 3f                	push   $0x3f
  80059d:	ff 55 08             	call   *0x8(%ebp)
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	eb 0b                	jmp    8005b0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	57                   	push   %edi
  8005a9:	50                   	push   %eax
  8005aa:	ff 55 08             	call   *0x8(%ebp)
  8005ad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b3:	0f be 03             	movsbl (%ebx),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	74 03                	je     8005bd <vprintfmt+0x220>
  8005ba:	43                   	inc    %ebx
  8005bb:	eb 1b                	jmp    8005d8 <vprintfmt+0x23b>
  8005bd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c4:	7f 1e                	jg     8005e4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005c9:	e9 f3 fd ff ff       	jmp    8003c1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d1:	43                   	inc    %ebx
  8005d2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d8:	85 f6                	test   %esi,%esi
  8005da:	78 ad                	js     800589 <vprintfmt+0x1ec>
  8005dc:	4e                   	dec    %esi
  8005dd:	79 aa                	jns    800589 <vprintfmt+0x1ec>
  8005df:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005e2:	eb dc                	jmp    8005c0 <vprintfmt+0x223>
  8005e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 20                	push   $0x20
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f0:	4b                   	dec    %ebx
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f ef                	jg     8005e7 <vprintfmt+0x24a>
  8005f8:	e9 c4 fd ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800600:	89 ca                	mov    %ecx,%edx
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 2a fd ff ff       	call   800334 <getint>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80060e:	85 d2                	test   %edx,%edx
  800610:	78 0a                	js     80061c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
  800617:	e9 b0 00 00 00       	jmp    8006cc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	57                   	push   %edi
  800620:	6a 2d                	push   $0x2d
  800622:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800625:	f7 db                	neg    %ebx
  800627:	83 d6 00             	adc    $0x0,%esi
  80062a:	f7 de                	neg    %esi
  80062c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 93 00 00 00       	jmp    8006cc <vprintfmt+0x32f>
  800639:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	89 ca                	mov    %ecx,%edx
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 b4 fc ff ff       	call   8002fa <getuint>
  800646:	89 c3                	mov    %eax,%ebx
  800648:	89 d6                	mov    %edx,%esi
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064f:	eb 7b                	jmp    8006cc <vprintfmt+0x32f>
  800651:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 d6 fc ff ff       	call   800334 <getint>
  80065e:	89 c3                	mov    %eax,%ebx
  800660:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800662:	85 d2                	test   %edx,%edx
  800664:	78 07                	js     80066d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800666:	b8 08 00 00 00       	mov    $0x8,%eax
  80066b:	eb 5f                	jmp    8006cc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	6a 2d                	push   $0x2d
  800673:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800676:	f7 db                	neg    %ebx
  800678:	83 d6 00             	adc    $0x0,%esi
  80067b:	f7 de                	neg    %esi
  80067d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800680:	b8 08 00 00 00       	mov    $0x8,%eax
  800685:	eb 45                	jmp    8006cc <vprintfmt+0x32f>
  800687:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	57                   	push   %edi
  80068e:	6a 30                	push   $0x30
  800690:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	57                   	push   %edi
  800697:	6a 78                	push   $0x78
  800699:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a5:	8b 18                	mov    (%eax),%ebx
  8006a7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b4:	eb 16                	jmp    8006cc <vprintfmt+0x32f>
  8006b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 37 fc ff ff       	call   8002fa <getuint>
  8006c3:	89 c3                	mov    %eax,%ebx
  8006c5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006d3:	52                   	push   %edx
  8006d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d7:	50                   	push   %eax
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	89 fa                	mov    %edi,%edx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	e8 68 fb ff ff       	call   80024c <printnum>
			break;
  8006e4:	83 c4 20             	add    $0x20,%esp
  8006e7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ea:	e9 d2 fc ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8006ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	57                   	push   %edi
  8006f6:	52                   	push   %edx
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800700:	e9 bc fc ff ff       	jmp    8003c1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	57                   	push   %edi
  800709:	6a 25                	push   $0x25
  80070b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 02                	jmp    800715 <vprintfmt+0x378>
  800713:	89 c6                	mov    %eax,%esi
  800715:	8d 46 ff             	lea    -0x1(%esi),%eax
  800718:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071c:	75 f5                	jne    800713 <vprintfmt+0x376>
  80071e:	e9 9e fc ff ff       	jmp    8003c1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 18             	sub    $0x18,%esp
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800748:	85 c0                	test   %eax,%eax
  80074a:	74 26                	je     800772 <vsnprintf+0x47>
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e 29                	jle    800779 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800750:	ff 75 14             	pushl  0x14(%ebp)
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	68 66 03 80 00       	push   $0x800366
  80075f:	e8 39 fc ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb 0c                	jmp    80077e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb 05                	jmp    80077e <vsnprintf+0x53>
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 93 ff ff ff       	call   80072b <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    
	...

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a5:	74 0e                	je     8007b5 <strlen+0x19>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ac:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f9                	jne    8007ac <strlen+0x10>
  8007b3:	eb 05                	jmp    8007ba <strlen+0x1e>
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 17                	je     8007e0 <strnlen+0x24>
  8007c9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007cc:	74 19                	je     8007e7 <strnlen+0x2b>
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d4:	39 d0                	cmp    %edx,%eax
  8007d6:	74 14                	je     8007ec <strnlen+0x30>
  8007d8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007dc:	75 f5                	jne    8007d3 <strnlen+0x17>
  8007de:	eb 0c                	jmp    8007ec <strnlen+0x30>
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 05                	jmp    8007ec <strnlen+0x30>
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800800:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800803:	42                   	inc    %edx
  800804:	84 c9                	test   %cl,%cl
  800806:	75 f5                	jne    8007fd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800812:	53                   	push   %ebx
  800813:	e8 84 ff ff ff       	call   80079c <strlen>
  800818:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800821:	50                   	push   %eax
  800822:	e8 c7 ff ff ff       	call   8007ee <strcpy>
	return dst;
}
  800827:	89 d8                	mov    %ebx,%eax
  800829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	85 f6                	test   %esi,%esi
  80083e:	74 15                	je     800855 <strncpy+0x27>
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800845:	8a 1a                	mov    (%edx),%bl
  800847:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084a:	80 3a 01             	cmpb   $0x1,(%edx)
  80084d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800850:	41                   	inc    %ecx
  800851:	39 ce                	cmp    %ecx,%esi
  800853:	77 f0                	ja     800845 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	57                   	push   %edi
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 f6                	test   %esi,%esi
  80086a:	74 32                	je     80089e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80086c:	83 fe 01             	cmp    $0x1,%esi
  80086f:	74 22                	je     800893 <strlcpy+0x3a>
  800871:	8a 0b                	mov    (%ebx),%cl
  800873:	84 c9                	test   %cl,%cl
  800875:	74 20                	je     800897 <strlcpy+0x3e>
  800877:	89 f8                	mov    %edi,%eax
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80087e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800881:	88 08                	mov    %cl,(%eax)
  800883:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800884:	39 f2                	cmp    %esi,%edx
  800886:	74 11                	je     800899 <strlcpy+0x40>
  800888:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80088c:	42                   	inc    %edx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	75 f0                	jne    800881 <strlcpy+0x28>
  800891:	eb 06                	jmp    800899 <strlcpy+0x40>
  800893:	89 f8                	mov    %edi,%eax
  800895:	eb 02                	jmp    800899 <strlcpy+0x40>
  800897:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 00 00             	movb   $0x0,(%eax)
  80089c:	eb 02                	jmp    8008a0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008a0:	29 f8                	sub    %edi,%eax
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b0:	8a 01                	mov    (%ecx),%al
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 10                	je     8008c6 <strcmp+0x1f>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	75 0c                	jne    8008c6 <strcmp+0x1f>
		p++, q++;
  8008ba:	41                   	inc    %ecx
  8008bb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bc:	8a 01                	mov    (%ecx),%al
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x1f>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 f4                	je     8008ba <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008da:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	74 1b                	je     8008fc <strncmp+0x2c>
  8008e1:	8a 1a                	mov    (%edx),%bl
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 24                	je     80090b <strncmp+0x3b>
  8008e7:	3a 19                	cmp    (%ecx),%bl
  8008e9:	75 20                	jne    80090b <strncmp+0x3b>
  8008eb:	48                   	dec    %eax
  8008ec:	74 15                	je     800903 <strncmp+0x33>
		n--, p++, q++;
  8008ee:	42                   	inc    %edx
  8008ef:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f0:	8a 1a                	mov    (%edx),%bl
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	74 15                	je     80090b <strncmp+0x3b>
  8008f6:	3a 19                	cmp    (%ecx),%bl
  8008f8:	74 f1                	je     8008eb <strncmp+0x1b>
  8008fa:	eb 0f                	jmp    80090b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strncmp+0x38>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800908:	5b                   	pop    %ebx
  800909:	c9                   	leave  
  80090a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 02             	movzbl (%edx),%eax
  80090e:	0f b6 11             	movzbl (%ecx),%edx
  800911:	29 d0                	sub    %edx,%eax
  800913:	eb f3                	jmp    800908 <strncmp+0x38>

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	8a 10                	mov    (%eax),%dl
  800920:	84 d2                	test   %dl,%dl
  800922:	74 18                	je     80093c <strchr+0x27>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	75 06                	jne    80092e <strchr+0x19>
  800928:	eb 17                	jmp    800941 <strchr+0x2c>
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	74 13                	je     800941 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092e:	40                   	inc    %eax
  80092f:	8a 10                	mov    (%eax),%dl
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f5                	jne    80092a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	eb 05                	jmp    800941 <strchr+0x2c>
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094c:	8a 10                	mov    (%eax),%dl
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 11                	je     800963 <strfind+0x20>
		if (*s == c)
  800952:	38 ca                	cmp    %cl,%dl
  800954:	75 06                	jne    80095c <strfind+0x19>
  800956:	eb 0b                	jmp    800963 <strfind+0x20>
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 07                	je     800963 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095c:	40                   	inc    %eax
  80095d:	8a 10                	mov    (%eax),%dl
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f5                	jne    800958 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800974:	85 c9                	test   %ecx,%ecx
  800976:	74 30                	je     8009a8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800978:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097e:	75 25                	jne    8009a5 <memset+0x40>
  800980:	f6 c1 03             	test   $0x3,%cl
  800983:	75 20                	jne    8009a5 <memset+0x40>
		c &= 0xFF;
  800985:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 d0                	or     %edx,%eax
  80099b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb 03                	jmp    8009a8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a5:	fc                   	cld    
  8009a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a8:	89 f8                	mov    %edi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 34                	jae    8009f5 <memmove+0x46>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 2d                	jae    8009f5 <memmove+0x46>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	f6 c2 03             	test   $0x3,%dl
  8009ce:	75 1b                	jne    8009eb <memmove+0x3c>
  8009d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d6:	75 13                	jne    8009eb <memmove+0x3c>
  8009d8:	f6 c1 03             	test   $0x3,%cl
  8009db:	75 0e                	jne    8009eb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009dd:	83 ef 04             	sub    $0x4,%edi
  8009e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e6:	fd                   	std    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 07                	jmp    8009f2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009eb:	4f                   	dec    %edi
  8009ec:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ef:	fd                   	std    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f2:	fc                   	cld    
  8009f3:	eb 20                	jmp    800a15 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x61>
  8009fd:	a8 03                	test   $0x3,%al
  8009ff:	75 0f                	jne    800a10 <memmove+0x61>
  800a01:	f6 c1 03             	test   $0x3,%cl
  800a04:	75 0a                	jne    800a10 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a06:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a09:	89 c7                	mov    %eax,%edi
  800a0b:	fc                   	cld    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 05                	jmp    800a15 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a10:	89 c7                	mov    %eax,%edi
  800a12:	fc                   	cld    
  800a13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1c:	ff 75 10             	pushl  0x10(%ebp)
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	ff 75 08             	pushl  0x8(%ebp)
  800a25:	e8 85 ff ff ff       	call   8009af <memmove>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	85 ff                	test   %edi,%edi
  800a3d:	74 32                	je     800a71 <memcmp+0x45>
		if (*s1 != *s2)
  800a3f:	8a 03                	mov    (%ebx),%al
  800a41:	8a 0e                	mov    (%esi),%cl
  800a43:	38 c8                	cmp    %cl,%al
  800a45:	74 19                	je     800a60 <memcmp+0x34>
  800a47:	eb 0d                	jmp    800a56 <memcmp+0x2a>
  800a49:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a4d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a51:	42                   	inc    %edx
  800a52:	38 c8                	cmp    %cl,%al
  800a54:	74 10                	je     800a66 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a56:	0f b6 c0             	movzbl %al,%eax
  800a59:	0f b6 c9             	movzbl %cl,%ecx
  800a5c:	29 c8                	sub    %ecx,%eax
  800a5e:	eb 16                	jmp    800a76 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	4f                   	dec    %edi
  800a61:	ba 00 00 00 00       	mov    $0x0,%edx
  800a66:	39 fa                	cmp    %edi,%edx
  800a68:	75 df                	jne    800a49 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	eb 05                	jmp    800a76 <memcmp+0x4a>
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a81:	89 c2                	mov    %eax,%edx
  800a83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a86:	39 d0                	cmp    %edx,%eax
  800a88:	73 12                	jae    800a9c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a8d:	38 08                	cmp    %cl,(%eax)
  800a8f:	75 06                	jne    800a97 <memfind+0x1c>
  800a91:	eb 09                	jmp    800a9c <memfind+0x21>
  800a93:	38 08                	cmp    %cl,(%eax)
  800a95:	74 05                	je     800a9c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a97:	40                   	inc    %eax
  800a98:	39 c2                	cmp    %eax,%edx
  800a9a:	77 f7                	ja     800a93 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	eb 01                	jmp    800aad <strtol+0xf>
		s++;
  800aac:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 20                	cmp    $0x20,%al
  800ab1:	74 f9                	je     800aac <strtol+0xe>
  800ab3:	3c 09                	cmp    $0x9,%al
  800ab5:	74 f5                	je     800aac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab7:	3c 2b                	cmp    $0x2b,%al
  800ab9:	75 08                	jne    800ac3 <strtol+0x25>
		s++;
  800abb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac1:	eb 13                	jmp    800ad6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac3:	3c 2d                	cmp    $0x2d,%al
  800ac5:	75 0a                	jne    800ad1 <strtol+0x33>
		s++, neg = 1;
  800ac7:	8d 52 01             	lea    0x1(%edx),%edx
  800aca:	bf 01 00 00 00       	mov    $0x1,%edi
  800acf:	eb 05                	jmp    800ad6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	74 05                	je     800adf <strtol+0x41>
  800ada:	83 fb 10             	cmp    $0x10,%ebx
  800add:	75 28                	jne    800b07 <strtol+0x69>
  800adf:	8a 02                	mov    (%edx),%al
  800ae1:	3c 30                	cmp    $0x30,%al
  800ae3:	75 10                	jne    800af5 <strtol+0x57>
  800ae5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae9:	75 0a                	jne    800af5 <strtol+0x57>
		s += 2, base = 16;
  800aeb:	83 c2 02             	add    $0x2,%edx
  800aee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af3:	eb 12                	jmp    800b07 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 0e                	jne    800b07 <strtol+0x69>
  800af9:	3c 30                	cmp    $0x30,%al
  800afb:	75 05                	jne    800b02 <strtol+0x64>
		s++, base = 8;
  800afd:	42                   	inc    %edx
  800afe:	b3 08                	mov    $0x8,%bl
  800b00:	eb 05                	jmp    800b07 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b02:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0e:	8a 0a                	mov    (%edx),%cl
  800b10:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b13:	80 fb 09             	cmp    $0x9,%bl
  800b16:	77 08                	ja     800b20 <strtol+0x82>
			dig = *s - '0';
  800b18:	0f be c9             	movsbl %cl,%ecx
  800b1b:	83 e9 30             	sub    $0x30,%ecx
  800b1e:	eb 1e                	jmp    800b3e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b20:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b28:	0f be c9             	movsbl %cl,%ecx
  800b2b:	83 e9 57             	sub    $0x57,%ecx
  800b2e:	eb 0e                	jmp    800b3e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 13                	ja     800b4b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b38:	0f be c9             	movsbl %cl,%ecx
  800b3b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3e:	39 f1                	cmp    %esi,%ecx
  800b40:	7d 0d                	jge    800b4f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b42:	42                   	inc    %edx
  800b43:	0f af c6             	imul   %esi,%eax
  800b46:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b49:	eb c3                	jmp    800b0e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4b:	89 c1                	mov    %eax,%ecx
  800b4d:	eb 02                	jmp    800b51 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b55:	74 05                	je     800b5c <strtol+0xbe>
		*endptr = (char *) s;
  800b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	74 04                	je     800b64 <strtol+0xc6>
  800b60:	89 c8                	mov    %ecx,%eax
  800b62:	f7 d8                	neg    %eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    
  800b69:	00 00                	add    %al,(%eax)
	...

00800b6c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 1c             	sub    $0x1c,%esp
  800b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b78:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b7b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b89:	cd 30                	int    $0x30
  800b8b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b91:	74 1c                	je     800baf <syscall+0x43>
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 18                	jle    800baf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b9e:	68 5f 22 80 00       	push   $0x80225f
  800ba3:	6a 42                	push   $0x42
  800ba5:	68 7c 22 80 00       	push   $0x80227c
  800baa:	e8 b1 f5 ff ff       	call   800160 <_panic>

	return ret;
}
  800baf:	89 d0                	mov    %edx,%eax
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	e8 92 ff ff ff       	call   800b6c <syscall>
  800bda:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfc:	e8 6b ff ff ff       	call   800b6c <syscall>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c14:	ba 01 00 00 00       	mov    $0x1,%edx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	e8 49 ff ff ff       	call   800b6c <syscall>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c42:	e8 25 ff ff ff       	call   800b6c <syscall>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <sys_yield>:

void
sys_yield(void)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c66:	e8 01 ff ff ff       	call   800b6c <syscall>
  800c6b:	83 c4 10             	add    $0x10,%esp
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	ff 75 10             	pushl  0x10(%ebp)
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
  800c88:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8d:	e8 da fe ff ff       	call   800b6c <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c9a:	ff 75 18             	pushl  0x18(%ebp)
  800c9d:	ff 75 14             	pushl  0x14(%ebp)
  800ca0:	ff 75 10             	pushl  0x10(%ebp)
  800ca3:	ff 75 0c             	pushl  0xc(%ebp)
  800ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cae:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb3:	e8 b4 fe ff ff       	call   800b6c <syscall>
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cc0:	6a 00                	push   $0x0
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	ff 75 0c             	pushl  0xc(%ebp)
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd6:	e8 91 fe ff ff       	call   800b6c <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ce3:	6a 00                	push   $0x0
  800ce5:	6a 00                	push   $0x0
  800ce7:	6a 00                	push   $0x0
  800ce9:	ff 75 0c             	pushl  0xc(%ebp)
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf9:	e8 6e fe ff ff       	call   800b6c <syscall>
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	6a 00                	push   $0x0
  800d0c:	ff 75 0c             	pushl  0xc(%ebp)
  800d0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d12:	ba 01 00 00 00       	mov    $0x1,%edx
  800d17:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1c:	e8 4b fe ff ff       	call   800b6c <syscall>
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	ff 75 0c             	pushl  0xc(%ebp)
  800d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d35:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3f:	e8 28 fe ff ff       	call   800b6c <syscall>
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d4c:	6a 00                	push   $0x0
  800d4e:	ff 75 14             	pushl  0x14(%ebp)
  800d51:	ff 75 10             	pushl  0x10(%ebp)
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d64:	e8 03 fe ff ff       	call   800b6c <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	e8 e1 fd ff ff       	call   800b6c <syscall>
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800da4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da9:	e8 be fd ff ff       	call   800b6c <syscall>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800db6:	6a 00                	push   $0x0
  800db8:	ff 75 14             	pushl  0x14(%ebp)
  800dbb:	ff 75 10             	pushl  0x10(%ebp)
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dce:	e8 99 fd ff ff       	call   800b6c <syscall>
} 
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	6a 00                	push   $0x0
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	b8 11 00 00 00       	mov    $0x11,%eax
  800df0:	e8 77 fd ff ff       	call   800b6c <syscall>
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dfd:	6a 00                	push   $0x0
  800dff:	6a 00                	push   $0x0
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e14:	e8 53 fd ff ff       	call   800b6c <syscall>
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    
	...

00800e1c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	05 00 00 00 30       	add    $0x30000000,%eax
  800e27:	c1 e8 0c             	shr    $0xc,%eax
}
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e2f:	ff 75 08             	pushl  0x8(%ebp)
  800e32:	e8 e5 ff ff ff       	call   800e1c <fd2num>
  800e37:	83 c4 04             	add    $0x4,%esp
  800e3a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e3f:	c1 e0 0c             	shl    $0xc,%eax
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e4b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e50:	a8 01                	test   $0x1,%al
  800e52:	74 34                	je     800e88 <fd_alloc+0x44>
  800e54:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e59:	a8 01                	test   $0x1,%al
  800e5b:	74 32                	je     800e8f <fd_alloc+0x4b>
  800e5d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e62:	89 c1                	mov    %eax,%ecx
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 16             	shr    $0x16,%edx
  800e69:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 1f                	je     800e94 <fd_alloc+0x50>
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	c1 ea 0c             	shr    $0xc,%edx
  800e7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e81:	f6 c2 01             	test   $0x1,%dl
  800e84:	75 17                	jne    800e9d <fd_alloc+0x59>
  800e86:	eb 0c                	jmp    800e94 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e88:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e8d:	eb 05                	jmp    800e94 <fd_alloc+0x50>
  800e8f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e94:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 17                	jmp    800eb4 <fd_alloc+0x70>
  800e9d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea7:	75 b9                	jne    800e62 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eaf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebd:	83 f8 1f             	cmp    $0x1f,%eax
  800ec0:	77 36                	ja     800ef8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ec7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 16             	shr    $0x16,%edx
  800ecf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 24                	je     800eff <fd_lookup+0x48>
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	c1 ea 0c             	shr    $0xc,%edx
  800ee0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	74 1a                	je     800f06 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eef:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	eb 13                	jmp    800f0b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efd:	eb 0c                	jmp    800f0b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f04:	eb 05                	jmp    800f0b <fd_lookup+0x54>
  800f06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	53                   	push   %ebx
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f1a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f20:	74 0d                	je     800f2f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 14                	jmp    800f3d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f29:	39 0a                	cmp    %ecx,(%edx)
  800f2b:	75 10                	jne    800f3d <dev_lookup+0x30>
  800f2d:	eb 05                	jmp    800f34 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f34:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 31                	jmp    800f6e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f3d:	40                   	inc    %eax
  800f3e:	8b 14 85 0c 23 80 00 	mov    0x80230c(,%eax,4),%edx
  800f45:	85 d2                	test   %edx,%edx
  800f47:	75 e0                	jne    800f29 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f49:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f4e:	8b 40 48             	mov    0x48(%eax),%eax
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	51                   	push   %ecx
  800f55:	50                   	push   %eax
  800f56:	68 8c 22 80 00       	push   $0x80228c
  800f5b:	e8 d8 f2 ff ff       	call   800238 <cprintf>
	*dev = 0;
  800f60:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 20             	sub    $0x20,%esp
  800f7b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7e:	8a 45 0c             	mov    0xc(%ebp),%al
  800f81:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f84:	56                   	push   %esi
  800f85:	e8 92 fe ff ff       	call   800e1c <fd2num>
  800f8a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f8d:	89 14 24             	mov    %edx,(%esp)
  800f90:	50                   	push   %eax
  800f91:	e8 21 ff ff ff       	call   800eb7 <fd_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 08             	add    $0x8,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 05                	js     800fa4 <fd_close+0x31>
	    || fd != fd2)
  800f9f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa2:	74 0d                	je     800fb1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fa4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fa8:	75 48                	jne    800ff2 <fd_close+0x7f>
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faf:	eb 41                	jmp    800ff2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 36                	pushl  (%esi)
  800fba:	e8 4e ff ff ff       	call   800f0d <dev_lookup>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 1c                	js     800fe4 <fd_close+0x71>
		if (dev->dev_close)
  800fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcb:	8b 40 10             	mov    0x10(%eax),%eax
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	74 0d                	je     800fdf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	56                   	push   %esi
  800fd6:	ff d0                	call   *%eax
  800fd8:	89 c3                	mov    %eax,%ebx
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	eb 05                	jmp    800fe4 <fd_close+0x71>
		else
			r = 0;
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 cb fc ff ff       	call   800cba <sys_page_unmap>
	return r;
  800fef:	83 c4 10             	add    $0x10,%esp
}
  800ff2:	89 d8                	mov    %ebx,%eax
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 aa fe ff ff       	call   800eb7 <fd_lookup>
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 10                	js     801024 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	6a 01                	push   $0x1
  801019:	ff 75 f4             	pushl  -0xc(%ebp)
  80101c:	e8 52 ff ff ff       	call   800f73 <fd_close>
  801021:	83 c4 10             	add    $0x10,%esp
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <close_all>:

void
close_all(void)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	53                   	push   %ebx
  801036:	e8 c0 ff ff ff       	call   800ffb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80103b:	43                   	inc    %ebx
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	83 fb 20             	cmp    $0x20,%ebx
  801042:	75 ee                	jne    801032 <close_all+0xc>
		close(i);
}
  801044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 2c             	sub    $0x2c,%esp
  801052:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801055:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 56 fe ff ff       	call   800eb7 <fd_lookup>
  801061:	89 c3                	mov    %eax,%ebx
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	0f 88 c0 00 00 00    	js     80112e <dup+0xe5>
		return r;
	close(newfdnum);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	57                   	push   %edi
  801072:	e8 84 ff ff ff       	call   800ffb <close>

	newfd = INDEX2FD(newfdnum);
  801077:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80107d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801080:	83 c4 04             	add    $0x4,%esp
  801083:	ff 75 e4             	pushl  -0x1c(%ebp)
  801086:	e8 a1 fd ff ff       	call   800e2c <fd2data>
  80108b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80108d:	89 34 24             	mov    %esi,(%esp)
  801090:	e8 97 fd ff ff       	call   800e2c <fd2data>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	c1 e8 16             	shr    $0x16,%eax
  8010a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a7:	a8 01                	test   $0x1,%al
  8010a9:	74 37                	je     8010e2 <dup+0x99>
  8010ab:	89 d8                	mov    %ebx,%eax
  8010ad:	c1 e8 0c             	shr    $0xc,%eax
  8010b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 26                	je     8010e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cf:	6a 00                	push   $0x0
  8010d1:	53                   	push   %ebx
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 bb fb ff ff       	call   800c94 <sys_page_map>
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	83 c4 20             	add    $0x20,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 2d                	js     80110f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	c1 ea 0c             	shr    $0xc,%edx
  8010ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010fa:	52                   	push   %edx
  8010fb:	56                   	push   %esi
  8010fc:	6a 00                	push   $0x0
  8010fe:	50                   	push   %eax
  8010ff:	6a 00                	push   $0x0
  801101:	e8 8e fb ff ff       	call   800c94 <sys_page_map>
  801106:	89 c3                	mov    %eax,%ebx
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 1d                	jns    80112c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	56                   	push   %esi
  801113:	6a 00                	push   $0x0
  801115:	e8 a0 fb ff ff       	call   800cba <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801120:	6a 00                	push   $0x0
  801122:	e8 93 fb ff ff       	call   800cba <sys_page_unmap>
	return r;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	eb 02                	jmp    80112e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80112c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80112e:	89 d8                	mov    %ebx,%eax
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	53                   	push   %ebx
  80113c:	83 ec 14             	sub    $0x14,%esp
  80113f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	53                   	push   %ebx
  801147:	e8 6b fd ff ff       	call   800eb7 <fd_lookup>
  80114c:	83 c4 08             	add    $0x8,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 67                	js     8011ba <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115d:	ff 30                	pushl  (%eax)
  80115f:	e8 a9 fd ff ff       	call   800f0d <dev_lookup>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 4f                	js     8011ba <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	8b 50 08             	mov    0x8(%eax),%edx
  801171:	83 e2 03             	and    $0x3,%edx
  801174:	83 fa 01             	cmp    $0x1,%edx
  801177:	75 21                	jne    80119a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801179:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80117e:	8b 40 48             	mov    0x48(%eax),%eax
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	53                   	push   %ebx
  801185:	50                   	push   %eax
  801186:	68 d0 22 80 00       	push   $0x8022d0
  80118b:	e8 a8 f0 ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801198:	eb 20                	jmp    8011ba <read+0x82>
	}
	if (!dev->dev_read)
  80119a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119d:	8b 52 08             	mov    0x8(%edx),%edx
  8011a0:	85 d2                	test   %edx,%edx
  8011a2:	74 11                	je     8011b5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	50                   	push   %eax
  8011ae:	ff d2                	call   *%edx
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	eb 05                	jmp    8011ba <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bd:	c9                   	leave  
  8011be:	c3                   	ret    

008011bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ce:	85 f6                	test   %esi,%esi
  8011d0:	74 31                	je     801203 <readn+0x44>
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	89 f2                	mov    %esi,%edx
  8011e1:	29 c2                	sub    %eax,%edx
  8011e3:	52                   	push   %edx
  8011e4:	03 45 0c             	add    0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	57                   	push   %edi
  8011e9:	e8 4a ff ff ff       	call   801138 <read>
		if (m < 0)
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 17                	js     80120c <readn+0x4d>
			return m;
		if (m == 0)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	74 11                	je     80120a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f9:	01 c3                	add    %eax,%ebx
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	39 f3                	cmp    %esi,%ebx
  8011ff:	72 db                	jb     8011dc <readn+0x1d>
  801201:	eb 09                	jmp    80120c <readn+0x4d>
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	eb 02                	jmp    80120c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80120a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 14             	sub    $0x14,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	53                   	push   %ebx
  801223:	e8 8f fc ff ff       	call   800eb7 <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 62                	js     801291 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801239:	ff 30                	pushl  (%eax)
  80123b:	e8 cd fc ff ff       	call   800f0d <dev_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 4a                	js     801291 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124e:	75 21                	jne    801271 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801250:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	68 ec 22 80 00       	push   $0x8022ec
  801262:	e8 d1 ef ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126f:	eb 20                	jmp    801291 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801271:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801274:	8b 52 0c             	mov    0xc(%edx),%edx
  801277:	85 d2                	test   %edx,%edx
  801279:	74 11                	je     80128c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	ff 75 10             	pushl  0x10(%ebp)
  801281:	ff 75 0c             	pushl  0xc(%ebp)
  801284:	50                   	push   %eax
  801285:	ff d2                	call   *%edx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	eb 05                	jmp    801291 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <seek>:

int
seek(int fdnum, off_t offset)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 0f fc ff ff       	call   800eb7 <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 0e                	js     8012bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	53                   	push   %ebx
  8012ce:	e8 e4 fb ff ff       	call   800eb7 <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 5f                	js     801339 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	ff 30                	pushl  (%eax)
  8012e6:	e8 22 fc ff ff       	call   800f0d <dev_lookup>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 47                	js     801339 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f9:	75 21                	jne    80131c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fb:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801300:	8b 40 48             	mov    0x48(%eax),%eax
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	53                   	push   %ebx
  801307:	50                   	push   %eax
  801308:	68 ac 22 80 00       	push   $0x8022ac
  80130d:	e8 26 ef ff ff       	call   800238 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131a:	eb 1d                	jmp    801339 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80131c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131f:	8b 52 18             	mov    0x18(%edx),%edx
  801322:	85 d2                	test   %edx,%edx
  801324:	74 0e                	je     801334 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	ff 75 0c             	pushl  0xc(%ebp)
  80132c:	50                   	push   %eax
  80132d:	ff d2                	call   *%edx
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	eb 05                	jmp    801339 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801334:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 14             	sub    $0x14,%esp
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801348:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 63 fb ff ff       	call   800eb7 <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 52                	js     8013ad <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	ff 30                	pushl  (%eax)
  801367:	e8 a1 fb ff ff       	call   800f0d <dev_lookup>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 3a                	js     8013ad <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80137a:	74 2c                	je     8013a8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80137c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801386:	00 00 00 
	stat->st_isdir = 0;
  801389:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801390:	00 00 00 
	stat->st_dev = dev;
  801393:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a0:	ff 50 14             	call   *0x14(%eax)
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	eb 05                	jmp    8013ad <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	6a 00                	push   $0x0
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 78 01 00 00       	call   80153c <open>
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 1b                	js     8013e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	50                   	push   %eax
  8013d4:	e8 65 ff ff ff       	call   80133e <fstat>
  8013d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013db:	89 1c 24             	mov    %ebx,(%esp)
  8013de:	e8 18 fc ff ff       	call   800ffb <close>
	return r;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	89 f3                	mov    %esi,%ebx
}
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    
  8013f1:	00 00                	add    %al,(%eax)
	...

008013f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801404:	75 12                	jne    801418 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	6a 01                	push   $0x1
  80140b:	e8 8a 07 00 00       	call   801b9a <ipc_find_env>
  801410:	a3 00 40 80 00       	mov    %eax,0x804000
  801415:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801418:	6a 07                	push   $0x7
  80141a:	68 00 50 c0 00       	push   $0xc05000
  80141f:	53                   	push   %ebx
  801420:	ff 35 00 40 80 00    	pushl  0x804000
  801426:	e8 1a 07 00 00       	call   801b45 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80142b:	83 c4 0c             	add    $0xc,%esp
  80142e:	6a 00                	push   $0x0
  801430:	56                   	push   %esi
  801431:	6a 00                	push   $0x0
  801433:	e8 98 06 00 00       	call   801ad0 <ipc_recv>
}
  801438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	8b 40 0c             	mov    0xc(%eax),%eax
  80144f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801454:	ba 00 00 00 00       	mov    $0x0,%edx
  801459:	b8 05 00 00 00       	mov    $0x5,%eax
  80145e:	e8 91 ff ff ff       	call   8013f4 <fsipc>
  801463:	85 c0                	test   %eax,%eax
  801465:	78 2c                	js     801493 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	68 00 50 c0 00       	push   $0xc05000
  80146f:	53                   	push   %ebx
  801470:	e8 79 f3 ff ff       	call   8007ee <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801475:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80147a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801480:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801485:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b3:	e8 3c ff ff ff       	call   8013f4 <fsipc>
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c8:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014cd:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014dd:	e8 12 ff ff ff       	call   8013f4 <fsipc>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 4b                	js     801533 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e8:	39 c6                	cmp    %eax,%esi
  8014ea:	73 16                	jae    801502 <devfile_read+0x48>
  8014ec:	68 1c 23 80 00       	push   $0x80231c
  8014f1:	68 23 23 80 00       	push   $0x802323
  8014f6:	6a 7d                	push   $0x7d
  8014f8:	68 38 23 80 00       	push   $0x802338
  8014fd:	e8 5e ec ff ff       	call   800160 <_panic>
	assert(r <= PGSIZE);
  801502:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801507:	7e 16                	jle    80151f <devfile_read+0x65>
  801509:	68 43 23 80 00       	push   $0x802343
  80150e:	68 23 23 80 00       	push   $0x802323
  801513:	6a 7e                	push   $0x7e
  801515:	68 38 23 80 00       	push   $0x802338
  80151a:	e8 41 ec ff ff       	call   800160 <_panic>
	memmove(buf, &fsipcbuf, r);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	50                   	push   %eax
  801523:	68 00 50 c0 00       	push   $0xc05000
  801528:	ff 75 0c             	pushl  0xc(%ebp)
  80152b:	e8 7f f4 ff ff       	call   8009af <memmove>
	return r;
  801530:	83 c4 10             	add    $0x10,%esp
}
  801533:	89 d8                	mov    %ebx,%eax
  801535:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801538:	5b                   	pop    %ebx
  801539:	5e                   	pop    %esi
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
  801541:	83 ec 1c             	sub    $0x1c,%esp
  801544:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801547:	56                   	push   %esi
  801548:	e8 4f f2 ff ff       	call   80079c <strlen>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801555:	7f 65                	jg     8015bc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 e1 f8 ff ff       	call   800e44 <fd_alloc>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 55                	js     8015c1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	56                   	push   %esi
  801570:	68 00 50 c0 00       	push   $0xc05000
  801575:	e8 74 f2 ff ff       	call   8007ee <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157d:	a3 00 54 c0 00       	mov    %eax,0xc05400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	b8 01 00 00 00       	mov    $0x1,%eax
  80158a:	e8 65 fe ff ff       	call   8013f4 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	79 12                	jns    8015aa <open+0x6e>
		fd_close(fd, 0);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 ce f9 ff ff       	call   800f73 <fd_close>
		return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 17                	jmp    8015c1 <open+0x85>
	}

	return fd2num(fd);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b0:	e8 67 f8 ff ff       	call   800e1c <fd2num>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 05                	jmp    8015c1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015bc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    
	...

008015cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 4d f8 ff ff       	call   800e2c <fd2data>
  8015df:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	68 4f 23 80 00       	push   $0x80234f
  8015e9:	56                   	push   %esi
  8015ea:	e8 ff f1 ff ff       	call   8007ee <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f2:	2b 03                	sub    (%ebx),%eax
  8015f4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015fa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801601:	00 00 00 
	stat->st_dev = &devpipe;
  801604:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80160b:	30 80 00 
	return 0;
}
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801624:	53                   	push   %ebx
  801625:	6a 00                	push   $0x0
  801627:	e8 8e f6 ff ff       	call   800cba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80162c:	89 1c 24             	mov    %ebx,(%esp)
  80162f:	e8 f8 f7 ff ff       	call   800e2c <fd2data>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	50                   	push   %eax
  801638:	6a 00                	push   $0x0
  80163a:	e8 7b f6 ff ff       	call   800cba <sys_page_unmap>
}
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	57                   	push   %edi
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 1c             	sub    $0x1c,%esp
  80164d:	89 c7                	mov    %eax,%edi
  80164f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801652:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801657:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	57                   	push   %edi
  80165e:	e8 85 05 00 00       	call   801be8 <pageref>
  801663:	89 c6                	mov    %eax,%esi
  801665:	83 c4 04             	add    $0x4,%esp
  801668:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166b:	e8 78 05 00 00       	call   801be8 <pageref>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	39 c6                	cmp    %eax,%esi
  801675:	0f 94 c0             	sete   %al
  801678:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80167b:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801681:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801684:	39 cb                	cmp    %ecx,%ebx
  801686:	75 08                	jne    801690 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801690:	83 f8 01             	cmp    $0x1,%eax
  801693:	75 bd                	jne    801652 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801695:	8b 42 58             	mov    0x58(%edx),%eax
  801698:	6a 01                	push   $0x1
  80169a:	50                   	push   %eax
  80169b:	53                   	push   %ebx
  80169c:	68 56 23 80 00       	push   $0x802356
  8016a1:	e8 92 eb ff ff       	call   800238 <cprintf>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	eb a7                	jmp    801652 <_pipeisclosed+0xe>

008016ab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 28             	sub    $0x28,%esp
  8016b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016b7:	56                   	push   %esi
  8016b8:	e8 6f f7 ff ff       	call   800e2c <fd2data>
  8016bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016c6:	75 4a                	jne    801712 <devpipe_write+0x67>
  8016c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8016cd:	eb 56                	jmp    801725 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016cf:	89 da                	mov    %ebx,%edx
  8016d1:	89 f0                	mov    %esi,%eax
  8016d3:	e8 6c ff ff ff       	call   801644 <_pipeisclosed>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	75 4d                	jne    801729 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016dc:	e8 68 f5 ff ff       	call   800c49 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e4:	8b 13                	mov    (%ebx),%edx
  8016e6:	83 c2 20             	add    $0x20,%edx
  8016e9:	39 d0                	cmp    %edx,%eax
  8016eb:	73 e2                	jae    8016cf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016f5:	79 05                	jns    8016fc <devpipe_write+0x51>
  8016f7:	4a                   	dec    %edx
  8016f8:	83 ca e0             	or     $0xffffffe0,%edx
  8016fb:	42                   	inc    %edx
  8016fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801702:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801706:	40                   	inc    %eax
  801707:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170a:	47                   	inc    %edi
  80170b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80170e:	77 07                	ja     801717 <devpipe_write+0x6c>
  801710:	eb 13                	jmp    801725 <devpipe_write+0x7a>
  801712:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801717:	8b 43 04             	mov    0x4(%ebx),%eax
  80171a:	8b 13                	mov    (%ebx),%edx
  80171c:	83 c2 20             	add    $0x20,%edx
  80171f:	39 d0                	cmp    %edx,%eax
  801721:	73 ac                	jae    8016cf <devpipe_write+0x24>
  801723:	eb c8                	jmp    8016ed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801725:	89 f8                	mov    %edi,%eax
  801727:	eb 05                	jmp    80172e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 18             	sub    $0x18,%esp
  80173f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801742:	57                   	push   %edi
  801743:	e8 e4 f6 ff ff       	call   800e2c <fd2data>
  801748:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801751:	75 44                	jne    801797 <devpipe_read+0x61>
  801753:	be 00 00 00 00       	mov    $0x0,%esi
  801758:	eb 4f                	jmp    8017a9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80175a:	89 f0                	mov    %esi,%eax
  80175c:	eb 54                	jmp    8017b2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80175e:	89 da                	mov    %ebx,%edx
  801760:	89 f8                	mov    %edi,%eax
  801762:	e8 dd fe ff ff       	call   801644 <_pipeisclosed>
  801767:	85 c0                	test   %eax,%eax
  801769:	75 42                	jne    8017ad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80176b:	e8 d9 f4 ff ff       	call   800c49 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801770:	8b 03                	mov    (%ebx),%eax
  801772:	3b 43 04             	cmp    0x4(%ebx),%eax
  801775:	74 e7                	je     80175e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801777:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80177c:	79 05                	jns    801783 <devpipe_read+0x4d>
  80177e:	48                   	dec    %eax
  80177f:	83 c8 e0             	or     $0xffffffe0,%eax
  801782:	40                   	inc    %eax
  801783:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80178d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178f:	46                   	inc    %esi
  801790:	39 75 10             	cmp    %esi,0x10(%ebp)
  801793:	77 07                	ja     80179c <devpipe_read+0x66>
  801795:	eb 12                	jmp    8017a9 <devpipe_read+0x73>
  801797:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80179c:	8b 03                	mov    (%ebx),%eax
  80179e:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017a1:	75 d4                	jne    801777 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017a3:	85 f6                	test   %esi,%esi
  8017a5:	75 b3                	jne    80175a <devpipe_read+0x24>
  8017a7:	eb b5                	jmp    80175e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a9:	89 f0                	mov    %esi,%eax
  8017ab:	eb 05                	jmp    8017b2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5f                   	pop    %edi
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	57                   	push   %edi
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 28             	sub    $0x28,%esp
  8017c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c9:	50                   	push   %eax
  8017ca:	e8 75 f6 ff ff       	call   800e44 <fd_alloc>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	0f 88 24 01 00 00    	js     801900 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	68 07 04 00 00       	push   $0x407
  8017e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 82 f4 ff ff       	call   800c70 <sys_page_alloc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 88 05 01 00 00    	js     801900 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	e8 3d f6 ff ff       	call   800e44 <fd_alloc>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	0f 88 dc 00 00 00    	js     8018f0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	68 07 04 00 00       	push   $0x407
  80181c:	ff 75 e0             	pushl  -0x20(%ebp)
  80181f:	6a 00                	push   $0x0
  801821:	e8 4a f4 ff ff       	call   800c70 <sys_page_alloc>
  801826:	89 c3                	mov    %eax,%ebx
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	0f 88 bd 00 00 00    	js     8018f0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 e4             	pushl  -0x1c(%ebp)
  801839:	e8 ee f5 ff ff       	call   800e2c <fd2data>
  80183e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801840:	83 c4 0c             	add    $0xc,%esp
  801843:	68 07 04 00 00       	push   $0x407
  801848:	50                   	push   %eax
  801849:	6a 00                	push   $0x0
  80184b:	e8 20 f4 ff ff       	call   800c70 <sys_page_alloc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 83 00 00 00    	js     8018e0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	ff 75 e0             	pushl  -0x20(%ebp)
  801863:	e8 c4 f5 ff ff       	call   800e2c <fd2data>
  801868:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80186f:	50                   	push   %eax
  801870:	6a 00                	push   $0x0
  801872:	56                   	push   %esi
  801873:	6a 00                	push   $0x0
  801875:	e8 1a f4 ff ff       	call   800c94 <sys_page_map>
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	83 c4 20             	add    $0x20,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 4f                	js     8018d2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801883:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801889:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80188e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801891:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801898:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b3:	e8 64 f5 ff ff       	call   800e1c <fd2num>
  8018b8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018ba:	83 c4 04             	add    $0x4,%esp
  8018bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c0:	e8 57 f5 ff ff       	call   800e1c <fd2num>
  8018c5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d0:	eb 2e                	jmp    801900 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	56                   	push   %esi
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 dd f3 ff ff       	call   800cba <sys_page_unmap>
  8018dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 cd f3 ff ff       	call   800cba <sys_page_unmap>
  8018ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 bd f3 ff ff       	call   800cba <sys_page_unmap>
  8018fd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801900:	89 d8                	mov    %ebx,%eax
  801902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 9b f5 ff ff       	call   800eb7 <fd_lookup>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 18                	js     80193b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 fe f4 ff ff       	call   800e2c <fd2data>
	return _pipeisclosed(fd, p);
  80192e:	89 c2                	mov    %eax,%edx
  801930:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801933:	e8 0c fd ff ff       	call   801644 <_pipeisclosed>
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    
  80193d:	00 00                	add    %al,(%eax)
	...

00801940 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801950:	68 6e 23 80 00       	push   $0x80236e
  801955:	ff 75 0c             	pushl  0xc(%ebp)
  801958:	e8 91 ee ff ff       	call   8007ee <strcpy>
	return 0;
}
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801970:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801974:	74 45                	je     8019bb <devcons_write+0x57>
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
  80197b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801980:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801986:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801989:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80198b:	83 fb 7f             	cmp    $0x7f,%ebx
  80198e:	76 05                	jbe    801995 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801990:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801995:	83 ec 04             	sub    $0x4,%esp
  801998:	53                   	push   %ebx
  801999:	03 45 0c             	add    0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	57                   	push   %edi
  80199e:	e8 0c f0 ff ff       	call   8009af <memmove>
		sys_cputs(buf, m);
  8019a3:	83 c4 08             	add    $0x8,%esp
  8019a6:	53                   	push   %ebx
  8019a7:	57                   	push   %edi
  8019a8:	e8 0c f2 ff ff       	call   800bb9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ad:	01 de                	add    %ebx,%esi
  8019af:	89 f0                	mov    %esi,%eax
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b7:	72 cd                	jb     801986 <devcons_write+0x22>
  8019b9:	eb 05                	jmp    8019c0 <devcons_write+0x5c>
  8019bb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019c0:	89 f0                	mov    %esi,%eax
  8019c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d4:	75 07                	jne    8019dd <devcons_read+0x13>
  8019d6:	eb 25                	jmp    8019fd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019d8:	e8 6c f2 ff ff       	call   800c49 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019dd:	e8 fd f1 ff ff       	call   800bdf <sys_cgetc>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	74 f2                	je     8019d8 <devcons_read+0xe>
  8019e6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 1d                	js     801a09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019ec:	83 f8 04             	cmp    $0x4,%eax
  8019ef:	74 13                	je     801a04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f4:	88 10                	mov    %dl,(%eax)
	return 1;
  8019f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fb:	eb 0c                	jmp    801a09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8019fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801a02:	eb 05                	jmp    801a09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a17:	6a 01                	push   $0x1
  801a19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1c:	50                   	push   %eax
  801a1d:	e8 97 f1 ff ff       	call   800bb9 <sys_cputs>
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <getchar>:

int
getchar(void)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a2d:	6a 01                	push   $0x1
  801a2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 fe f6 ff ff       	call   801138 <read>
	if (r < 0)
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 0f                	js     801a50 <getchar+0x29>
		return r;
	if (r < 1)
  801a41:	85 c0                	test   %eax,%eax
  801a43:	7e 06                	jle    801a4b <getchar+0x24>
		return -E_EOF;
	return c;
  801a45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a49:	eb 05                	jmp    801a50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5b:	50                   	push   %eax
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	e8 53 f4 ff ff       	call   800eb7 <fd_lookup>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 11                	js     801a7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a74:	39 10                	cmp    %edx,(%eax)
  801a76:	0f 94 c0             	sete   %al
  801a79:	0f b6 c0             	movzbl %al,%eax
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <opencons>:

int
opencons(void)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a87:	50                   	push   %eax
  801a88:	e8 b7 f3 ff ff       	call   800e44 <fd_alloc>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 3a                	js     801ace <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 ca f1 ff ff       	call   800c70 <sys_page_alloc>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 21                	js     801ace <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801aad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	50                   	push   %eax
  801ac6:	e8 51 f3 ff ff       	call   800e1c <fd2num>
  801acb:	83 c4 10             	add    $0x10,%esp
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	74 0e                	je     801af0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	50                   	push   %eax
  801ae6:	e8 80 f2 ff ff       	call   800d6b <sys_ipc_recv>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	eb 10                	jmp    801b00 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	68 00 00 c0 ee       	push   $0xeec00000
  801af8:	e8 6e f2 ff ff       	call   800d6b <sys_ipc_recv>
  801afd:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b00:	85 c0                	test   %eax,%eax
  801b02:	75 26                	jne    801b2a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b04:	85 f6                	test   %esi,%esi
  801b06:	74 0a                	je     801b12 <ipc_recv+0x42>
  801b08:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b0d:	8b 40 74             	mov    0x74(%eax),%eax
  801b10:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b12:	85 db                	test   %ebx,%ebx
  801b14:	74 0a                	je     801b20 <ipc_recv+0x50>
  801b16:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b1b:	8b 40 78             	mov    0x78(%eax),%eax
  801b1e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b20:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b25:	8b 40 70             	mov    0x70(%eax),%eax
  801b28:	eb 14                	jmp    801b3e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b2a:	85 f6                	test   %esi,%esi
  801b2c:	74 06                	je     801b34 <ipc_recv+0x64>
  801b2e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b34:	85 db                	test   %ebx,%ebx
  801b36:	74 06                	je     801b3e <ipc_recv+0x6e>
  801b38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	57                   	push   %edi
  801b49:	56                   	push   %esi
  801b4a:	53                   	push   %ebx
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b57:	85 db                	test   %ebx,%ebx
  801b59:	75 25                	jne    801b80 <ipc_send+0x3b>
  801b5b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b60:	eb 1e                	jmp    801b80 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b62:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b65:	75 07                	jne    801b6e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b67:	e8 dd f0 ff ff       	call   800c49 <sys_yield>
  801b6c:	eb 12                	jmp    801b80 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b6e:	50                   	push   %eax
  801b6f:	68 7a 23 80 00       	push   $0x80237a
  801b74:	6a 43                	push   $0x43
  801b76:	68 8d 23 80 00       	push   $0x80238d
  801b7b:	e8 e0 e5 ff ff       	call   800160 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	57                   	push   %edi
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	e8 bb f1 ff ff       	call   800d46 <sys_ipc_try_send>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 d0                	jne    801b62 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ba0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801ba6:	74 1a                	je     801bc2 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801bad:	89 c2                	mov    %eax,%edx
  801baf:	c1 e2 07             	shl    $0x7,%edx
  801bb2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801bb9:	8b 52 50             	mov    0x50(%edx),%edx
  801bbc:	39 ca                	cmp    %ecx,%edx
  801bbe:	75 18                	jne    801bd8 <ipc_find_env+0x3e>
  801bc0:	eb 05                	jmp    801bc7 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	c1 e2 07             	shl    $0x7,%edx
  801bcc:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801bd3:	8b 40 40             	mov    0x40(%eax),%eax
  801bd6:	eb 0c                	jmp    801be4 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bd8:	40                   	inc    %eax
  801bd9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bde:	75 cd                	jne    801bad <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801be0:	66 b8 00 00          	mov    $0x0,%ax
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    
	...

00801be8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bee:	89 c2                	mov    %eax,%edx
  801bf0:	c1 ea 16             	shr    $0x16,%edx
  801bf3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bfa:	f6 c2 01             	test   $0x1,%dl
  801bfd:	74 1e                	je     801c1d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bff:	c1 e8 0c             	shr    $0xc,%eax
  801c02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c09:	a8 01                	test   $0x1,%al
  801c0b:	74 17                	je     801c24 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c0d:	c1 e8 0c             	shr    $0xc,%eax
  801c10:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c17:	ef 
  801c18:	0f b7 c0             	movzwl %ax,%eax
  801c1b:	eb 0c                	jmp    801c29 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	eb 05                	jmp    801c29 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    
	...

00801c2c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	83 ec 10             	sub    $0x10,%esp
  801c34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c3a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c40:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c43:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c46:	85 c0                	test   %eax,%eax
  801c48:	75 2e                	jne    801c78 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c4a:	39 f1                	cmp    %esi,%ecx
  801c4c:	77 5a                	ja     801ca8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c4e:	85 c9                	test   %ecx,%ecx
  801c50:	75 0b                	jne    801c5d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c52:	b8 01 00 00 00       	mov    $0x1,%eax
  801c57:	31 d2                	xor    %edx,%edx
  801c59:	f7 f1                	div    %ecx
  801c5b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c5d:	31 d2                	xor    %edx,%edx
  801c5f:	89 f0                	mov    %esi,%eax
  801c61:	f7 f1                	div    %ecx
  801c63:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c65:	89 f8                	mov    %edi,%eax
  801c67:	f7 f1                	div    %ecx
  801c69:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c78:	39 f0                	cmp    %esi,%eax
  801c7a:	77 1c                	ja     801c98 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c7c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c7f:	83 f7 1f             	xor    $0x1f,%edi
  801c82:	75 3c                	jne    801cc0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c84:	39 f0                	cmp    %esi,%eax
  801c86:	0f 82 90 00 00 00    	jb     801d1c <__udivdi3+0xf0>
  801c8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c92:	0f 86 84 00 00 00    	jbe    801d1c <__udivdi3+0xf0>
  801c98:	31 f6                	xor    %esi,%esi
  801c9a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c9c:	89 f8                	mov    %edi,%eax
  801c9e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    
  801ca7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	89 f8                	mov    %edi,%eax
  801cac:	f7 f1                	div    %ecx
  801cae:	89 c7                	mov    %eax,%edi
  801cb0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cb2:	89 f8                	mov    %edi,%eax
  801cb4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	5e                   	pop    %esi
  801cba:	5f                   	pop    %edi
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    
  801cbd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cc0:	89 f9                	mov    %edi,%ecx
  801cc2:	d3 e0                	shl    %cl,%eax
  801cc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cc7:	b8 20 00 00 00       	mov    $0x20,%eax
  801ccc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd1:	88 c1                	mov    %al,%cl
  801cd3:	d3 ea                	shr    %cl,%edx
  801cd5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cd8:	09 ca                	or     %ecx,%edx
  801cda:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801cdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	d3 e2                	shl    %cl,%edx
  801ce4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801ce7:	89 f2                	mov    %esi,%edx
  801ce9:	88 c1                	mov    %al,%cl
  801ceb:	d3 ea                	shr    %cl,%edx
  801ced:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801cf0:	89 f2                	mov    %esi,%edx
  801cf2:	89 f9                	mov    %edi,%ecx
  801cf4:	d3 e2                	shl    %cl,%edx
  801cf6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801cf9:	88 c1                	mov    %al,%cl
  801cfb:	d3 ee                	shr    %cl,%esi
  801cfd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d02:	89 f0                	mov    %esi,%eax
  801d04:	89 ca                	mov    %ecx,%edx
  801d06:	f7 75 ec             	divl   -0x14(%ebp)
  801d09:	89 d1                	mov    %edx,%ecx
  801d0b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d0d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d10:	39 d1                	cmp    %edx,%ecx
  801d12:	72 28                	jb     801d3c <__udivdi3+0x110>
  801d14:	74 1a                	je     801d30 <__udivdi3+0x104>
  801d16:	89 f7                	mov    %esi,%edi
  801d18:	31 f6                	xor    %esi,%esi
  801d1a:	eb 80                	jmp    801c9c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d1c:	31 f6                	xor    %esi,%esi
  801d1e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d23:	89 f8                	mov    %edi,%eax
  801d25:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    
  801d2e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d37:	39 c2                	cmp    %eax,%edx
  801d39:	73 db                	jae    801d16 <__udivdi3+0xea>
  801d3b:	90                   	nop
		{
		  q0--;
  801d3c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d3f:	31 f6                	xor    %esi,%esi
  801d41:	e9 56 ff ff ff       	jmp    801c9c <__udivdi3+0x70>
	...

00801d48 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	57                   	push   %edi
  801d4c:	56                   	push   %esi
  801d4d:	83 ec 20             	sub    $0x20,%esp
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d56:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d65:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d67:	85 ff                	test   %edi,%edi
  801d69:	75 15                	jne    801d80 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d6b:	39 f1                	cmp    %esi,%ecx
  801d6d:	0f 86 99 00 00 00    	jbe    801e0c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d73:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d79:	83 c4 20             	add    $0x20,%esp
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d80:	39 f7                	cmp    %esi,%edi
  801d82:	0f 87 a4 00 00 00    	ja     801e2c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d88:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d8b:	83 f0 1f             	xor    $0x1f,%eax
  801d8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d91:	0f 84 a1 00 00 00    	je     801e38 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d97:	89 f8                	mov    %edi,%eax
  801d99:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d9c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d9e:	bf 20 00 00 00       	mov    $0x20,%edi
  801da3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da9:	89 f9                	mov    %edi,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	09 c2                	or     %eax,%edx
  801daf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801db8:	d3 e0                	shl    %cl,%eax
  801dba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801dc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dc4:	d3 e0                	shl    %cl,%eax
  801dc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dcc:	89 f9                	mov    %edi,%ecx
  801dce:	d3 e8                	shr    %cl,%eax
  801dd0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801dd2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dd4:	89 f2                	mov    %esi,%edx
  801dd6:	f7 75 f0             	divl   -0x10(%ebp)
  801dd9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ddb:	f7 65 f4             	mull   -0xc(%ebp)
  801dde:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801de1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801de3:	39 d6                	cmp    %edx,%esi
  801de5:	72 71                	jb     801e58 <__umoddi3+0x110>
  801de7:	74 7f                	je     801e68 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801de9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dec:	29 c8                	sub    %ecx,%eax
  801dee:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801df0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801df3:	d3 e8                	shr    %cl,%eax
  801df5:	89 f2                	mov    %esi,%edx
  801df7:	89 f9                	mov    %edi,%ecx
  801df9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dfb:	09 d0                	or     %edx,%eax
  801dfd:	89 f2                	mov    %esi,%edx
  801dff:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e02:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e04:	83 c4 20             	add    $0x20,%esp
  801e07:	5e                   	pop    %esi
  801e08:	5f                   	pop    %edi
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    
  801e0b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e0c:	85 c9                	test   %ecx,%ecx
  801e0e:	75 0b                	jne    801e1b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e10:	b8 01 00 00 00       	mov    $0x1,%eax
  801e15:	31 d2                	xor    %edx,%edx
  801e17:	f7 f1                	div    %ecx
  801e19:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e1b:	89 f0                	mov    %esi,%eax
  801e1d:	31 d2                	xor    %edx,%edx
  801e1f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e24:	f7 f1                	div    %ecx
  801e26:	e9 4a ff ff ff       	jmp    801d75 <__umoddi3+0x2d>
  801e2b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e2c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e2e:	83 c4 20             	add    $0x20,%esp
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    
  801e35:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e38:	39 f7                	cmp    %esi,%edi
  801e3a:	72 05                	jb     801e41 <__umoddi3+0xf9>
  801e3c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e3f:	77 0c                	ja     801e4d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e41:	89 f2                	mov    %esi,%edx
  801e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e46:	29 c8                	sub    %ecx,%eax
  801e48:	19 fa                	sbb    %edi,%edx
  801e4a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e50:	83 c4 20             	add    $0x20,%esp
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    
  801e57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e58:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e5b:	89 c1                	mov    %eax,%ecx
  801e5d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e60:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e63:	eb 84                	jmp    801de9 <__umoddi3+0xa1>
  801e65:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e68:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e6b:	72 eb                	jb     801e58 <__umoddi3+0x110>
  801e6d:	89 f2                	mov    %esi,%edx
  801e6f:	e9 75 ff ff ff       	jmp    801de9 <__umoddi3+0xa1>
