
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
  80002c:	e8 d3 00 00 00       	call   800104 <libmain>
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
  80003a:	68 44 0e 80 00       	push   $0x800e44
  80003f:	e8 e4 01 00 00       	call   800228 <cprintf>
    cprintf("OK\n");
  800044:	c7 04 24 bf 0e 80 00 	movl   $0x800ebf,(%esp)
  80004b:	e8 d8 01 00 00       	call   800228 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80005a:	75 11                	jne    80006d <umain+0x39>
{
	int i;

	cprintf("Making sure bss works right...\n");
    cprintf("OK\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80005c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800061:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800068:	00 
  800069:	74 19                	je     800084 <umain+0x50>
  80006b:	eb 05                	jmp    800072 <umain+0x3e>
{
	int i;

	cprintf("Making sure bss works right...\n");
    cprintf("OK\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80006d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800072:	50                   	push   %eax
  800073:	68 c3 0e 80 00       	push   $0x800ec3
  800078:	6a 12                	push   $0x12
  80007a:	68 e0 0e 80 00       	push   $0x800ee0
  80007f:	e8 cc 00 00 00       	call   800150 <_panic>
{
	int i;

	cprintf("Making sure bss works right...\n");
    cprintf("OK\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800084:	40                   	inc    %eax
  800085:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008a:	75 d5                	jne    800061 <umain+0x2d>
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800091:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	cprintf("Making sure bss works right...\n");
    cprintf("OK\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800098:	40                   	inc    %eax
  800099:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009e:	75 f1                	jne    800091 <umain+0x5d>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a0:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000a7:	75 10                	jne    8000b9 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000ae:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000b5:	74 19                	je     8000d0 <umain+0x9c>
  8000b7:	eb 05                	jmp    8000be <umain+0x8a>
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000be:	50                   	push   %eax
  8000bf:	68 64 0e 80 00       	push   $0x800e64
  8000c4:	6a 17                	push   $0x17
  8000c6:	68 e0 0e 80 00       	push   $0x800ee0
  8000cb:	e8 80 00 00 00       	call   800150 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000d0:	40                   	inc    %eax
  8000d1:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000d6:	75 d6                	jne    8000ae <umain+0x7a>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000d8:	83 ec 0c             	sub    $0xc,%esp
  8000db:	68 8c 0e 80 00       	push   $0x800e8c
  8000e0:	e8 43 01 00 00       	call   800228 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000e5:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000ec:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000ef:	83 c4 0c             	add    $0xc,%esp
  8000f2:	68 ef 0e 80 00       	push   $0x800eef
  8000f7:	6a 1b                	push   $0x1b
  8000f9:	68 e0 0e 80 00       	push   $0x800ee0
  8000fe:	e8 4d 00 00 00       	call   800150 <_panic>
	...

00800104 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	8b 45 08             	mov    0x8(%ebp),%eax
  80010d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800110:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800117:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	7e 08                	jle    800126 <libmain+0x22>
		binaryname = argv[0];
  80011e:	8b 0a                	mov    (%edx),%ecx
  800120:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	52                   	push   %edx
  80012a:	50                   	push   %eax
  80012b:	e8 04 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
  800135:	83 c4 10             	add    $0x10,%esp
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    
	...

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800142:	6a 00                	push   $0x0
  800144:	e8 50 0a 00 00       	call   800b99 <sys_env_destroy>
  800149:	83 c4 10             	add    $0x10,%esp
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    
	...

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80015e:	e8 77 0a 00 00       	call   800bda <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	53                   	push   %ebx
  80016d:	50                   	push   %eax
  80016e:	68 10 0f 80 00       	push   $0x800f10
  800173:	e8 b0 00 00 00       	call   800228 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	56                   	push   %esi
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 53 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 de 0e 80 00 	movl   $0x800ede,(%esp)
  80018b:	e8 98 00 00 00       	call   800228 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>
	...

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 04             	sub    $0x4,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 03                	mov    (%ebx),%eax
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ab:	40                   	inc    %eax
  8001ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 96 09 00 00       	call   800b5c <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	ff 43 04             	incl   0x4(%ebx)
}
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	ff 75 08             	pushl  0x8(%ebp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	68 98 01 80 00       	push   $0x800198
  800206:	e8 82 01 00 00       	call   80038d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020b:	83 c4 08             	add    $0x8,%esp
  80020e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800214:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021a:	50                   	push   %eax
  80021b:	e8 3c 09 00 00       	call   800b5c <sys_cputs>

	return b.cnt;
}
  800220:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800231:	50                   	push   %eax
  800232:	ff 75 08             	pushl  0x8(%ebp)
  800235:	e8 9d ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 2c             	sub    $0x2c,%esp
  800245:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800256:	8b 45 10             	mov    0x10(%ebp),%eax
  800259:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80025c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800262:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800269:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80026c:	72 0c                	jb     80027a <printnum+0x3e>
  80026e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800271:	76 07                	jbe    80027a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800273:	4b                   	dec    %ebx
  800274:	85 db                	test   %ebx,%ebx
  800276:	7f 31                	jg     8002a9 <printnum+0x6d>
  800278:	eb 3f                	jmp    8002b9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	57                   	push   %edi
  80027e:	4b                   	dec    %ebx
  80027f:	53                   	push   %ebx
  800280:	50                   	push   %eax
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 d4             	pushl  -0x2c(%ebp)
  800287:	ff 75 d0             	pushl  -0x30(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 67 09 00 00       	call   800bfc <__udivdi3>
  800295:	83 c4 18             	add    $0x18,%esp
  800298:	52                   	push   %edx
  800299:	50                   	push   %eax
  80029a:	89 f2                	mov    %esi,%edx
  80029c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029f:	e8 98 ff ff ff       	call   80023c <printnum>
  8002a4:	83 c4 20             	add    $0x20,%esp
  8002a7:	eb 10                	jmp    8002b9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	57                   	push   %edi
  8002ae:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b1:	4b                   	dec    %ebx
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f f0                	jg     8002a9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 47 0a 00 00       	call   800d18 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 34 0f 80 00 	movsbl 0x800f34(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff 55 e4             	call   *-0x1c(%ebp)
  8002df:	83 c4 10             	add    $0x10,%esp
}
  8002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800327:	83 fa 01             	cmp    $0x1,%edx
  80032a:	7e 0e                	jle    80033a <getint+0x16>
		return va_arg(*ap, long long);
  80032c:	8b 10                	mov    (%eax),%edx
  80032e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800331:	89 08                	mov    %ecx,(%eax)
  800333:	8b 02                	mov    (%edx),%eax
  800335:	8b 52 04             	mov    0x4(%edx),%edx
  800338:	eb 1a                	jmp    800354 <getint+0x30>
	else if (lflag)
  80033a:	85 d2                	test   %edx,%edx
  80033c:	74 0c                	je     80034a <getint+0x26>
		return va_arg(*ap, long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 04             	lea    0x4(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	99                   	cltd   
  800348:	eb 0a                	jmp    800354 <getint+0x30>
	else
		return va_arg(*ap, int);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	99                   	cltd   
}
  800354:	c9                   	leave  
  800355:	c3                   	ret    

00800356 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	3b 50 04             	cmp    0x4(%eax),%edx
  800364:	73 08                	jae    80036e <sprintputch+0x18>
		*b->buf++ = ch;
  800366:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800369:	88 0a                	mov    %cl,(%edx)
  80036b:	42                   	inc    %edx
  80036c:	89 10                	mov    %edx,(%eax)
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800376:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 10             	pushl  0x10(%ebp)
  80037d:	ff 75 0c             	pushl  0xc(%ebp)
  800380:	ff 75 08             	pushl  0x8(%ebp)
  800383:	e8 05 00 00 00       	call   80038d <vprintfmt>
	va_end(ap);
  800388:	83 c4 10             	add    $0x10,%esp
}
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	57                   	push   %edi
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	83 ec 2c             	sub    $0x2c,%esp
  800396:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800399:	8b 75 10             	mov    0x10(%ebp),%esi
  80039c:	eb 13                	jmp    8003b1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	0f 84 6d 03 00 00    	je     800713 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	57                   	push   %edi
  8003aa:	50                   	push   %eax
  8003ab:	ff 55 08             	call   *0x8(%ebp)
  8003ae:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b1:	0f b6 06             	movzbl (%esi),%eax
  8003b4:	46                   	inc    %esi
  8003b5:	83 f8 25             	cmp    $0x25,%eax
  8003b8:	75 e4                	jne    80039e <vprintfmt+0x11>
  8003ba:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003be:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003cc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d8:	eb 28                	jmp    800402 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003dc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003e0:	eb 20                	jmp    800402 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003e8:	eb 18                	jmp    800402 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f3:	eb 0d                	jmp    800402 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8a 06                	mov    (%esi),%al
  800404:	0f b6 d0             	movzbl %al,%edx
  800407:	8d 5e 01             	lea    0x1(%esi),%ebx
  80040a:	83 e8 23             	sub    $0x23,%eax
  80040d:	3c 55                	cmp    $0x55,%al
  80040f:	0f 87 e0 02 00 00    	ja     8006f5 <vprintfmt+0x368>
  800415:	0f b6 c0             	movzbl %al,%eax
  800418:	ff 24 85 c4 0f 80 00 	jmp    *0x800fc4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041f:	83 ea 30             	sub    $0x30,%edx
  800422:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800425:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800428:	8d 50 d0             	lea    -0x30(%eax),%edx
  80042b:	83 fa 09             	cmp    $0x9,%edx
  80042e:	77 44                	ja     800474 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	89 de                	mov    %ebx,%esi
  800432:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800435:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800436:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800439:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80043d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800440:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800443:	83 fb 09             	cmp    $0x9,%ebx
  800446:	76 ed                	jbe    800435 <vprintfmt+0xa8>
  800448:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80044b:	eb 29                	jmp    800476 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045d:	eb 17                	jmp    800476 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80045f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800463:	78 85                	js     8003ea <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 de                	mov    %ebx,%esi
  800467:	eb 99                	jmp    800402 <vprintfmt+0x75>
  800469:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800472:	eb 8e                	jmp    800402 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800476:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047a:	79 86                	jns    800402 <vprintfmt+0x75>
  80047c:	e9 74 ff ff ff       	jmp    8003f5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800481:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	89 de                	mov    %ebx,%esi
  800484:	e9 79 ff ff ff       	jmp    800402 <vprintfmt+0x75>
  800489:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	57                   	push   %edi
  800499:	ff 30                	pushl  (%eax)
  80049b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a4:	e9 08 ff ff ff       	jmp    8003b1 <vprintfmt+0x24>
  8004a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	79 02                	jns    8004bd <vprintfmt+0x130>
  8004bb:	f7 d8                	neg    %eax
  8004bd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bf:	83 f8 06             	cmp    $0x6,%eax
  8004c2:	7f 0b                	jg     8004cf <vprintfmt+0x142>
  8004c4:	8b 04 85 1c 11 80 00 	mov    0x80111c(,%eax,4),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	75 1a                	jne    8004e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004cf:	52                   	push   %edx
  8004d0:	68 4c 0f 80 00       	push   $0x800f4c
  8004d5:	57                   	push   %edi
  8004d6:	ff 75 08             	pushl  0x8(%ebp)
  8004d9:	e8 92 fe ff ff       	call   800370 <printfmt>
  8004de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 c8 fe ff ff       	jmp    8003b1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	50                   	push   %eax
  8004ea:	68 55 0f 80 00       	push   $0x800f55
  8004ef:	57                   	push   %edi
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 78 fe ff ff       	call   800370 <printfmt>
  8004f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004fe:	e9 ae fe ff ff       	jmp    8003b1 <vprintfmt+0x24>
  800503:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800506:	89 de                	mov    %ebx,%esi
  800508:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80050b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051c:	85 c0                	test   %eax,%eax
  80051e:	75 07                	jne    800527 <vprintfmt+0x19a>
				p = "(null)";
  800520:	c7 45 d0 45 0f 80 00 	movl   $0x800f45,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800527:	85 db                	test   %ebx,%ebx
  800529:	7e 42                	jle    80056d <vprintfmt+0x1e0>
  80052b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80052f:	74 3c                	je     80056d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	51                   	push   %ecx
  800535:	ff 75 d0             	pushl  -0x30(%ebp)
  800538:	e8 6f 02 00 00       	call   8007ac <strnlen>
  80053d:	29 c3                	sub    %eax,%ebx
  80053f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 db                	test   %ebx,%ebx
  800547:	7e 24                	jle    80056d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800549:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80054d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800550:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	57                   	push   %edi
  800557:	53                   	push   %ebx
  800558:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	4e                   	dec    %esi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	85 f6                	test   %esi,%esi
  800561:	7f f0                	jg     800553 <vprintfmt+0x1c6>
  800563:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800566:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800570:	0f be 02             	movsbl (%edx),%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	75 47                	jne    8005be <vprintfmt+0x231>
  800577:	eb 37                	jmp    8005b0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057d:	74 16                	je     800595 <vprintfmt+0x208>
  80057f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800582:	83 fa 5e             	cmp    $0x5e,%edx
  800585:	76 0e                	jbe    800595 <vprintfmt+0x208>
					putch('?', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 3f                	push   $0x3f
  80058d:	ff 55 08             	call   *0x8(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 0b                	jmp    8005a0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	50                   	push   %eax
  80059a:	ff 55 08             	call   *0x8(%ebp)
  80059d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a3:	0f be 03             	movsbl (%ebx),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	74 03                	je     8005ad <vprintfmt+0x220>
  8005aa:	43                   	inc    %ebx
  8005ab:	eb 1b                	jmp    8005c8 <vprintfmt+0x23b>
  8005ad:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b4:	7f 1e                	jg     8005d4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005b9:	e9 f3 fd ff ff       	jmp    8003b1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c1:	43                   	inc    %ebx
  8005c2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005c8:	85 f6                	test   %esi,%esi
  8005ca:	78 ad                	js     800579 <vprintfmt+0x1ec>
  8005cc:	4e                   	dec    %esi
  8005cd:	79 aa                	jns    800579 <vprintfmt+0x1ec>
  8005cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005d2:	eb dc                	jmp    8005b0 <vprintfmt+0x223>
  8005d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	57                   	push   %edi
  8005db:	6a 20                	push   $0x20
  8005dd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e0:	4b                   	dec    %ebx
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f ef                	jg     8005d7 <vprintfmt+0x24a>
  8005e8:	e9 c4 fd ff ff       	jmp    8003b1 <vprintfmt+0x24>
  8005ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f0:	89 ca                	mov    %ecx,%edx
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 2a fd ff ff       	call   800324 <getint>
  8005fa:	89 c3                	mov    %eax,%ebx
  8005fc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005fe:	85 d2                	test   %edx,%edx
  800600:	78 0a                	js     80060c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 b0 00 00 00       	jmp    8006bc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	57                   	push   %edi
  800610:	6a 2d                	push   $0x2d
  800612:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800615:	f7 db                	neg    %ebx
  800617:	83 d6 00             	adc    $0x0,%esi
  80061a:	f7 de                	neg    %esi
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	e9 93 00 00 00       	jmp    8006bc <vprintfmt+0x32f>
  800629:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 b4 fc ff ff       	call   8002ea <getuint>
  800636:	89 c3                	mov    %eax,%ebx
  800638:	89 d6                	mov    %edx,%esi
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063f:	eb 7b                	jmp    8006bc <vprintfmt+0x32f>
  800641:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800644:	89 ca                	mov    %ecx,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 d6 fc ff ff       	call   800324 <getint>
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800652:	85 d2                	test   %edx,%edx
  800654:	78 07                	js     80065d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800656:	b8 08 00 00 00       	mov    $0x8,%eax
  80065b:	eb 5f                	jmp    8006bc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	57                   	push   %edi
  800661:	6a 2d                	push   $0x2d
  800663:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800666:	f7 db                	neg    %ebx
  800668:	83 d6 00             	adc    $0x0,%esi
  80066b:	f7 de                	neg    %esi
  80066d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800670:	b8 08 00 00 00       	mov    $0x8,%eax
  800675:	eb 45                	jmp    8006bc <vprintfmt+0x32f>
  800677:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	57                   	push   %edi
  80067e:	6a 30                	push   $0x30
  800680:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800683:	83 c4 08             	add    $0x8,%esp
  800686:	57                   	push   %edi
  800687:	6a 78                	push   $0x78
  800689:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 18                	mov    (%eax),%ebx
  800697:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a4:	eb 16                	jmp    8006bc <vprintfmt+0x32f>
  8006a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 37 fc ff ff       	call   8002ea <getuint>
  8006b3:	89 c3                	mov    %eax,%ebx
  8006b5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006c3:	52                   	push   %edx
  8006c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c7:	50                   	push   %eax
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	89 fa                	mov    %edi,%edx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	e8 68 fb ff ff       	call   80023c <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006da:	e9 d2 fc ff ff       	jmp    8003b1 <vprintfmt+0x24>
  8006df:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	57                   	push   %edi
  8006e6:	52                   	push   %edx
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 bc fc ff ff       	jmp    8003b1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	57                   	push   %edi
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 02                	jmp    800705 <vprintfmt+0x378>
  800703:	89 c6                	mov    %eax,%esi
  800705:	8d 46 ff             	lea    -0x1(%esi),%eax
  800708:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070c:	75 f5                	jne    800703 <vprintfmt+0x376>
  80070e:	e9 9e fc ff ff       	jmp    8003b1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 18             	sub    $0x18,%esp
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800727:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800738:	85 c0                	test   %eax,%eax
  80073a:	74 26                	je     800762 <vsnprintf+0x47>
  80073c:	85 d2                	test   %edx,%edx
  80073e:	7e 29                	jle    800769 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800740:	ff 75 14             	pushl  0x14(%ebp)
  800743:	ff 75 10             	pushl  0x10(%ebp)
  800746:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	68 56 03 80 00       	push   $0x800356
  80074f:	e8 39 fc ff ff       	call   80038d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	eb 0c                	jmp    80076e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb 05                	jmp    80076e <vsnprintf+0x53>
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800779:	50                   	push   %eax
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	ff 75 0c             	pushl  0xc(%ebp)
  800780:	ff 75 08             	pushl  0x8(%ebp)
  800783:	e8 93 ff ff ff       	call   80071b <vsnprintf>
	va_end(ap);

	return rc;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    
	...

0080078c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	80 3a 00             	cmpb   $0x0,(%edx)
  800795:	74 0e                	je     8007a5 <strlen+0x19>
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80079c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a1:	75 f9                	jne    80079c <strlen+0x10>
  8007a3:	eb 05                	jmp    8007aa <strlen+0x1e>
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 17                	je     8007d0 <strnlen+0x24>
  8007b9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007bc:	74 19                	je     8007d7 <strnlen+0x2b>
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007c3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c4:	39 d0                	cmp    %edx,%eax
  8007c6:	74 14                	je     8007dc <strnlen+0x30>
  8007c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cc:	75 f5                	jne    8007c3 <strnlen+0x17>
  8007ce:	eb 0c                	jmp    8007dc <strnlen+0x30>
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	eb 05                	jmp    8007dc <strnlen+0x30>
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ed:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f3:	42                   	inc    %edx
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	75 f5                	jne    8007ed <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 84 ff ff ff       	call   80078c <strlen>
  800808:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800811:	50                   	push   %eax
  800812:	e8 c7 ff ff ff       	call   8007de <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	85 f6                	test   %esi,%esi
  80082e:	74 15                	je     800845 <strncpy+0x27>
  800830:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800835:	8a 1a                	mov    (%edx),%bl
  800837:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 3a 01             	cmpb   $0x1,(%edx)
  80083d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	41                   	inc    %ecx
  800841:	39 ce                	cmp    %ecx,%esi
  800843:	77 f0                	ja     800835 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	57                   	push   %edi
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800855:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	85 f6                	test   %esi,%esi
  80085a:	74 32                	je     80088e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80085c:	83 fe 01             	cmp    $0x1,%esi
  80085f:	74 22                	je     800883 <strlcpy+0x3a>
  800861:	8a 0b                	mov    (%ebx),%cl
  800863:	84 c9                	test   %cl,%cl
  800865:	74 20                	je     800887 <strlcpy+0x3e>
  800867:	89 f8                	mov    %edi,%eax
  800869:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80086e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800871:	88 08                	mov    %cl,(%eax)
  800873:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800874:	39 f2                	cmp    %esi,%edx
  800876:	74 11                	je     800889 <strlcpy+0x40>
  800878:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80087c:	42                   	inc    %edx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	75 f0                	jne    800871 <strlcpy+0x28>
  800881:	eb 06                	jmp    800889 <strlcpy+0x40>
  800883:	89 f8                	mov    %edi,%eax
  800885:	eb 02                	jmp    800889 <strlcpy+0x40>
  800887:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800889:	c6 00 00             	movb   $0x0,(%eax)
  80088c:	eb 02                	jmp    800890 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800890:	29 f8                	sub    %edi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5f                   	pop    %edi
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a0:	8a 01                	mov    (%ecx),%al
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 10                	je     8008b6 <strcmp+0x1f>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	75 0c                	jne    8008b6 <strcmp+0x1f>
		p++, q++;
  8008aa:	41                   	inc    %ecx
  8008ab:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ac:	8a 01                	mov    (%ecx),%al
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 04                	je     8008b6 <strcmp+0x1f>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	74 f4                	je     8008aa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 c0             	movzbl %al,%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ca:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 1b                	je     8008ec <strncmp+0x2c>
  8008d1:	8a 1a                	mov    (%edx),%bl
  8008d3:	84 db                	test   %bl,%bl
  8008d5:	74 24                	je     8008fb <strncmp+0x3b>
  8008d7:	3a 19                	cmp    (%ecx),%bl
  8008d9:	75 20                	jne    8008fb <strncmp+0x3b>
  8008db:	48                   	dec    %eax
  8008dc:	74 15                	je     8008f3 <strncmp+0x33>
		n--, p++, q++;
  8008de:	42                   	inc    %edx
  8008df:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e0:	8a 1a                	mov    (%edx),%bl
  8008e2:	84 db                	test   %bl,%bl
  8008e4:	74 15                	je     8008fb <strncmp+0x3b>
  8008e6:	3a 19                	cmp    (%ecx),%bl
  8008e8:	74 f1                	je     8008db <strncmp+0x1b>
  8008ea:	eb 0f                	jmp    8008fb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb 05                	jmp    8008f8 <strncmp+0x38>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 02             	movzbl (%edx),%eax
  8008fe:	0f b6 11             	movzbl (%ecx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb f3                	jmp    8008f8 <strncmp+0x38>

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090e:	8a 10                	mov    (%eax),%dl
  800910:	84 d2                	test   %dl,%dl
  800912:	74 18                	je     80092c <strchr+0x27>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	75 06                	jne    80091e <strchr+0x19>
  800918:	eb 17                	jmp    800931 <strchr+0x2c>
  80091a:	38 ca                	cmp    %cl,%dl
  80091c:	74 13                	je     800931 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091e:	40                   	inc    %eax
  80091f:	8a 10                	mov    (%eax),%dl
  800921:	84 d2                	test   %dl,%dl
  800923:	75 f5                	jne    80091a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	eb 05                	jmp    800931 <strchr+0x2c>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093c:	8a 10                	mov    (%eax),%dl
  80093e:	84 d2                	test   %dl,%dl
  800940:	74 11                	je     800953 <strfind+0x20>
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	75 06                	jne    80094c <strfind+0x19>
  800946:	eb 0b                	jmp    800953 <strfind+0x20>
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	74 07                	je     800953 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094c:	40                   	inc    %eax
  80094d:	8a 10                	mov    (%eax),%dl
  80094f:	84 d2                	test   %dl,%dl
  800951:	75 f5                	jne    800948 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 30                	je     800998 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 25                	jne    800995 <memset+0x40>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 20                	jne    800995 <memset+0x40>
		c &= 0xFF;
  800975:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d3                	mov    %edx,%ebx
  80097a:	c1 e3 08             	shl    $0x8,%ebx
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 18             	shl    $0x18,%esi
  800982:	89 d0                	mov    %edx,%eax
  800984:	c1 e0 10             	shl    $0x10,%eax
  800987:	09 f0                	or     %esi,%eax
  800989:	09 d0                	or     %edx,%eax
  80098b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb 03                	jmp    800998 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800995:	fc                   	cld    
  800996:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800998:	89 f8                	mov    %edi,%eax
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ad:	39 c6                	cmp    %eax,%esi
  8009af:	73 34                	jae    8009e5 <memmove+0x46>
  8009b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b4:	39 d0                	cmp    %edx,%eax
  8009b6:	73 2d                	jae    8009e5 <memmove+0x46>
		s += n;
		d += n;
  8009b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	f6 c2 03             	test   $0x3,%dl
  8009be:	75 1b                	jne    8009db <memmove+0x3c>
  8009c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c6:	75 13                	jne    8009db <memmove+0x3c>
  8009c8:	f6 c1 03             	test   $0x3,%cl
  8009cb:	75 0e                	jne    8009db <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cd:	83 ef 04             	sub    $0x4,%edi
  8009d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d6:	fd                   	std    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb 07                	jmp    8009e2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009db:	4f                   	dec    %edi
  8009dc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009df:	fd                   	std    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e2:	fc                   	cld    
  8009e3:	eb 20                	jmp    800a05 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009eb:	75 13                	jne    800a00 <memmove+0x61>
  8009ed:	a8 03                	test   $0x3,%al
  8009ef:	75 0f                	jne    800a00 <memmove+0x61>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 0a                	jne    800a00 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fe:	eb 05                	jmp    800a05 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a05:	5e                   	pop    %esi
  800a06:	5f                   	pop    %edi
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0c:	ff 75 10             	pushl  0x10(%ebp)
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	ff 75 08             	pushl  0x8(%ebp)
  800a15:	e8 85 ff ff ff       	call   80099f <memmove>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	85 ff                	test   %edi,%edi
  800a2d:	74 32                	je     800a61 <memcmp+0x45>
		if (*s1 != *s2)
  800a2f:	8a 03                	mov    (%ebx),%al
  800a31:	8a 0e                	mov    (%esi),%cl
  800a33:	38 c8                	cmp    %cl,%al
  800a35:	74 19                	je     800a50 <memcmp+0x34>
  800a37:	eb 0d                	jmp    800a46 <memcmp+0x2a>
  800a39:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a3d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a41:	42                   	inc    %edx
  800a42:	38 c8                	cmp    %cl,%al
  800a44:	74 10                	je     800a56 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a46:	0f b6 c0             	movzbl %al,%eax
  800a49:	0f b6 c9             	movzbl %cl,%ecx
  800a4c:	29 c8                	sub    %ecx,%eax
  800a4e:	eb 16                	jmp    800a66 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a50:	4f                   	dec    %edi
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
  800a56:	39 fa                	cmp    %edi,%edx
  800a58:	75 df                	jne    800a39 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	eb 05                	jmp    800a66 <memcmp+0x4a>
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a76:	39 d0                	cmp    %edx,%eax
  800a78:	73 12                	jae    800a8c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a7d:	38 08                	cmp    %cl,(%eax)
  800a7f:	75 06                	jne    800a87 <memfind+0x1c>
  800a81:	eb 09                	jmp    800a8c <memfind+0x21>
  800a83:	38 08                	cmp    %cl,(%eax)
  800a85:	74 05                	je     800a8c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a87:	40                   	inc    %eax
  800a88:	39 c2                	cmp    %eax,%edx
  800a8a:	77 f7                	ja     800a83 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9a:	eb 01                	jmp    800a9d <strtol+0xf>
		s++;
  800a9c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9d:	8a 02                	mov    (%edx),%al
  800a9f:	3c 20                	cmp    $0x20,%al
  800aa1:	74 f9                	je     800a9c <strtol+0xe>
  800aa3:	3c 09                	cmp    $0x9,%al
  800aa5:	74 f5                	je     800a9c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa7:	3c 2b                	cmp    $0x2b,%al
  800aa9:	75 08                	jne    800ab3 <strtol+0x25>
		s++;
  800aab:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab1:	eb 13                	jmp    800ac6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab3:	3c 2d                	cmp    $0x2d,%al
  800ab5:	75 0a                	jne    800ac1 <strtol+0x33>
		s++, neg = 1;
  800ab7:	8d 52 01             	lea    0x1(%edx),%edx
  800aba:	bf 01 00 00 00       	mov    $0x1,%edi
  800abf:	eb 05                	jmp    800ac6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	74 05                	je     800acf <strtol+0x41>
  800aca:	83 fb 10             	cmp    $0x10,%ebx
  800acd:	75 28                	jne    800af7 <strtol+0x69>
  800acf:	8a 02                	mov    (%edx),%al
  800ad1:	3c 30                	cmp    $0x30,%al
  800ad3:	75 10                	jne    800ae5 <strtol+0x57>
  800ad5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad9:	75 0a                	jne    800ae5 <strtol+0x57>
		s += 2, base = 16;
  800adb:	83 c2 02             	add    $0x2,%edx
  800ade:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae3:	eb 12                	jmp    800af7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ae5:	85 db                	test   %ebx,%ebx
  800ae7:	75 0e                	jne    800af7 <strtol+0x69>
  800ae9:	3c 30                	cmp    $0x30,%al
  800aeb:	75 05                	jne    800af2 <strtol+0x64>
		s++, base = 8;
  800aed:	42                   	inc    %edx
  800aee:	b3 08                	mov    $0x8,%bl
  800af0:	eb 05                	jmp    800af7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800af2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afe:	8a 0a                	mov    (%edx),%cl
  800b00:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b03:	80 fb 09             	cmp    $0x9,%bl
  800b06:	77 08                	ja     800b10 <strtol+0x82>
			dig = *s - '0';
  800b08:	0f be c9             	movsbl %cl,%ecx
  800b0b:	83 e9 30             	sub    $0x30,%ecx
  800b0e:	eb 1e                	jmp    800b2e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b10:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 08                	ja     800b20 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b18:	0f be c9             	movsbl %cl,%ecx
  800b1b:	83 e9 57             	sub    $0x57,%ecx
  800b1e:	eb 0e                	jmp    800b2e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 13                	ja     800b3b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b28:	0f be c9             	movsbl %cl,%ecx
  800b2b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2e:	39 f1                	cmp    %esi,%ecx
  800b30:	7d 0d                	jge    800b3f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b32:	42                   	inc    %edx
  800b33:	0f af c6             	imul   %esi,%eax
  800b36:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b39:	eb c3                	jmp    800afe <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	89 c1                	mov    %eax,%ecx
  800b3d:	eb 02                	jmp    800b41 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b45:	74 05                	je     800b4c <strtol+0xbe>
		*endptr = (char *) s;
  800b47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	74 04                	je     800b54 <strtol+0xc6>
  800b50:	89 c8                	mov    %ecx,%eax
  800b52:	f7 d8                	neg    %eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    
  800b59:	00 00                	add    %al,(%eax)
	...

00800b5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	89 c7                	mov    %eax,%edi
  800b71:	89 c6                	mov    %eax,%esi
  800b73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	89 cb                	mov    %ecx,%ebx
  800bb1:	89 cf                	mov    %ecx,%edi
  800bb3:	89 ce                	mov    %ecx,%esi
  800bb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 03                	push   $0x3
  800bc1:	68 38 11 80 00       	push   $0x801138
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 55 11 80 00       	push   $0x801155
  800bcd:	e8 7e f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bea:	89 d1                	mov    %edx,%ecx
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	89 d7                	mov    %edx,%edi
  800bf0:	89 d6                	mov    %edx,%esi
  800bf2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    
  800bf9:	00 00                	add    %al,(%eax)
	...

00800bfc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	83 ec 10             	sub    $0x10,%esp
  800c04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c07:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c0a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c10:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c13:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	75 2e                	jne    800c48 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800c1a:	39 f1                	cmp    %esi,%ecx
  800c1c:	77 5a                	ja     800c78 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800c1e:	85 c9                	test   %ecx,%ecx
  800c20:	75 0b                	jne    800c2d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800c22:	b8 01 00 00 00       	mov    $0x1,%eax
  800c27:	31 d2                	xor    %edx,%edx
  800c29:	f7 f1                	div    %ecx
  800c2b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800c2d:	31 d2                	xor    %edx,%edx
  800c2f:	89 f0                	mov    %esi,%eax
  800c31:	f7 f1                	div    %ecx
  800c33:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c35:	89 f8                	mov    %edi,%eax
  800c37:	f7 f1                	div    %ecx
  800c39:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c3b:	89 f8                	mov    %edi,%eax
  800c3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    
  800c46:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	77 1c                	ja     800c68 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c4c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c4f:	83 f7 1f             	xor    $0x1f,%edi
  800c52:	75 3c                	jne    800c90 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c54:	39 f0                	cmp    %esi,%eax
  800c56:	0f 82 90 00 00 00    	jb     800cec <__udivdi3+0xf0>
  800c5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c62:	0f 86 84 00 00 00    	jbe    800cec <__udivdi3+0xf0>
  800c68:	31 f6                	xor    %esi,%esi
  800c6a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c6c:	89 f8                	mov    %edi,%eax
  800c6e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    
  800c77:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	89 f8                	mov    %edi,%eax
  800c7c:	f7 f1                	div    %ecx
  800c7e:	89 c7                	mov    %eax,%edi
  800c80:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c82:	89 f8                	mov    %edi,%eax
  800c84:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    
  800c8d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	d3 e0                	shl    %cl,%eax
  800c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c97:	b8 20 00 00 00       	mov    $0x20,%eax
  800c9c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ca1:	88 c1                	mov    %al,%cl
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800ca8:	09 ca                	or     %ecx,%edx
  800caa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	d3 e2                	shl    %cl,%edx
  800cb4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800cb7:	89 f2                	mov    %esi,%edx
  800cb9:	88 c1                	mov    %al,%cl
  800cbb:	d3 ea                	shr    %cl,%edx
  800cbd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800cc0:	89 f2                	mov    %esi,%edx
  800cc2:	89 f9                	mov    %edi,%ecx
  800cc4:	d3 e2                	shl    %cl,%edx
  800cc6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800cc9:	88 c1                	mov    %al,%cl
  800ccb:	d3 ee                	shr    %cl,%esi
  800ccd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ccf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800cd2:	89 f0                	mov    %esi,%eax
  800cd4:	89 ca                	mov    %ecx,%edx
  800cd6:	f7 75 ec             	divl   -0x14(%ebp)
  800cd9:	89 d1                	mov    %edx,%ecx
  800cdb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cdd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ce0:	39 d1                	cmp    %edx,%ecx
  800ce2:	72 28                	jb     800d0c <__udivdi3+0x110>
  800ce4:	74 1a                	je     800d00 <__udivdi3+0x104>
  800ce6:	89 f7                	mov    %esi,%edi
  800ce8:	31 f6                	xor    %esi,%esi
  800cea:	eb 80                	jmp    800c6c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cec:	31 f6                	xor    %esi,%esi
  800cee:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf3:	89 f8                	mov    %edi,%eax
  800cf5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d03:	89 f9                	mov    %edi,%ecx
  800d05:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d07:	39 c2                	cmp    %eax,%edx
  800d09:	73 db                	jae    800ce6 <__udivdi3+0xea>
  800d0b:	90                   	nop
		{
		  q0--;
  800d0c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d0f:	31 f6                	xor    %esi,%esi
  800d11:	e9 56 ff ff ff       	jmp    800c6c <__udivdi3+0x70>
	...

00800d18 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	83 ec 20             	sub    $0x20,%esp
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d26:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800d29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800d35:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d37:	85 ff                	test   %edi,%edi
  800d39:	75 15                	jne    800d50 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800d3b:	39 f1                	cmp    %esi,%ecx
  800d3d:	0f 86 99 00 00 00    	jbe    800ddc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d43:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d45:	89 d0                	mov    %edx,%eax
  800d47:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d49:	83 c4 20             	add    $0x20,%esp
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d50:	39 f7                	cmp    %esi,%edi
  800d52:	0f 87 a4 00 00 00    	ja     800dfc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d58:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d5b:	83 f0 1f             	xor    $0x1f,%eax
  800d5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d61:	0f 84 a1 00 00 00    	je     800e08 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d67:	89 f8                	mov    %edi,%eax
  800d69:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d6c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d6e:	bf 20 00 00 00       	mov    $0x20,%edi
  800d73:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d79:	89 f9                	mov    %edi,%ecx
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	09 c2                	or     %eax,%edx
  800d7f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d88:	d3 e0                	shl    %cl,%eax
  800d8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d94:	d3 e0                	shl    %cl,%eax
  800d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d9c:	89 f9                	mov    %edi,%ecx
  800d9e:	d3 e8                	shr    %cl,%eax
  800da0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800da2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da4:	89 f2                	mov    %esi,%edx
  800da6:	f7 75 f0             	divl   -0x10(%ebp)
  800da9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800dab:	f7 65 f4             	mull   -0xc(%ebp)
  800dae:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800db1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db3:	39 d6                	cmp    %edx,%esi
  800db5:	72 71                	jb     800e28 <__umoddi3+0x110>
  800db7:	74 7f                	je     800e38 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dbc:	29 c8                	sub    %ecx,%eax
  800dbe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800dc0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800dc3:	d3 e8                	shr    %cl,%eax
  800dc5:	89 f2                	mov    %esi,%edx
  800dc7:	89 f9                	mov    %edi,%ecx
  800dc9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dcb:	09 d0                	or     %edx,%eax
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800dd2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd4:	83 c4 20             	add    $0x20,%esp
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    
  800ddb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ddc:	85 c9                	test   %ecx,%ecx
  800dde:	75 0b                	jne    800deb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800de0:	b8 01 00 00 00       	mov    $0x1,%eax
  800de5:	31 d2                	xor    %edx,%edx
  800de7:	f7 f1                	div    %ecx
  800de9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	31 d2                	xor    %edx,%edx
  800def:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df4:	f7 f1                	div    %ecx
  800df6:	e9 4a ff ff ff       	jmp    800d45 <__umoddi3+0x2d>
  800dfb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dfc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dfe:	83 c4 20             	add    $0x20,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e08:	39 f7                	cmp    %esi,%edi
  800e0a:	72 05                	jb     800e11 <__umoddi3+0xf9>
  800e0c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e0f:	77 0c                	ja     800e1d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e11:	89 f2                	mov    %esi,%edx
  800e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e16:	29 c8                	sub    %ecx,%eax
  800e18:	19 fa                	sbb    %edi,%edx
  800e1a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    
  800e27:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e28:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e2b:	89 c1                	mov    %eax,%ecx
  800e2d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800e30:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800e33:	eb 84                	jmp    800db9 <__umoddi3+0xa1>
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e38:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800e3b:	72 eb                	jb     800e28 <__umoddi3+0x110>
  800e3d:	89 f2                	mov    %esi,%edx
  800e3f:	e9 75 ff ff ff       	jmp    800db9 <__umoddi3+0xa1>
