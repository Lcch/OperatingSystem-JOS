
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
  80003a:	68 b4 0e 80 00       	push   $0x800eb4
  80003f:	e8 ec 01 00 00       	call   800230 <cprintf>
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
  800067:	68 2f 0f 80 00       	push   $0x800f2f
  80006c:	6a 11                	push   $0x11
  80006e:	68 4c 0f 80 00       	push   $0x800f4c
  800073:	e8 e0 00 00 00       	call   800158 <_panic>
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
  8000b3:	68 d4 0e 80 00       	push   $0x800ed4
  8000b8:	6a 16                	push   $0x16
  8000ba:	68 4c 0f 80 00       	push   $0x800f4c
  8000bf:	e8 94 00 00 00       	call   800158 <_panic>
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
  8000cf:	68 fc 0e 80 00       	push   $0x800efc
  8000d4:	e8 57 01 00 00       	call   800230 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000e0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e3:	83 c4 0c             	add    $0xc,%esp
  8000e6:	68 5b 0f 80 00       	push   $0x800f5b
  8000eb:	6a 1a                	push   $0x1a
  8000ed:	68 4c 0f 80 00       	push   $0x800f4c
  8000f2:	e8 61 00 00 00       	call   800158 <_panic>
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
  800103:	e8 40 0b 00 00       	call   800c48 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800110:	c1 e0 05             	shl    $0x5,%eax
  800113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800118:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011d:	85 f6                	test   %esi,%esi
  80011f:	7e 07                	jle    800128 <libmain+0x30>
		binaryname = argv[0];
  800121:	8b 03                	mov    (%ebx),%eax
  800123:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	53                   	push   %ebx
  80012c:	56                   	push   %esi
  80012d:	e8 02 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800132:	e8 0d 00 00 00       	call   800144 <exit>
  800137:	83 c4 10             	add    $0x10,%esp
}
  80013a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	c9                   	leave  
  800140:	c3                   	ret    
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 d5 0a 00 00       	call   800c26 <sys_env_destroy>
  800151:	83 c4 10             	add    $0x10,%esp
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    
	...

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800166:	e8 dd 0a 00 00       	call   800c48 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	53                   	push   %ebx
  800175:	50                   	push   %eax
  800176:	68 7c 0f 80 00       	push   $0x800f7c
  80017b:	e8 b0 00 00 00       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	56                   	push   %esi
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 53 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 4a 0f 80 00 	movl   $0x800f4a,(%esp)
  800193:	e8 98 00 00 00       	call   800230 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>
	...

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 03                	mov    (%ebx),%eax
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b3:	40                   	inc    %eax
  8001b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 0e 0a 00 00       	call   800bdc <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	ff 43 04             	incl   0x4(%ebx)
}
  8001da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	ff 75 0c             	pushl  0xc(%ebp)
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	68 a0 01 80 00       	push   $0x8001a0
  80020e:	e8 82 01 00 00       	call   800395 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800213:	83 c4 08             	add    $0x8,%esp
  800216:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800222:	50                   	push   %eax
  800223:	e8 b4 09 00 00       	call   800bdc <sys_cputs>

	return b.cnt;
}
  800228:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	50                   	push   %eax
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	e8 9d ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 2c             	sub    $0x2c,%esp
  80024d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80025e:	8b 45 10             	mov    0x10(%ebp),%eax
  800261:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800264:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800267:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80026a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800271:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800274:	72 0c                	jb     800282 <printnum+0x3e>
  800276:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800279:	76 07                	jbe    800282 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027b:	4b                   	dec    %ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f 31                	jg     8002b1 <printnum+0x6d>
  800280:	eb 3f                	jmp    8002c1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	57                   	push   %edi
  800286:	4b                   	dec    %ebx
  800287:	53                   	push   %ebx
  800288:	50                   	push   %eax
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80028f:	ff 75 d0             	pushl  -0x30(%ebp)
  800292:	ff 75 dc             	pushl  -0x24(%ebp)
  800295:	ff 75 d8             	pushl  -0x28(%ebp)
  800298:	e8 cf 09 00 00       	call   800c6c <__udivdi3>
  80029d:	83 c4 18             	add    $0x18,%esp
  8002a0:	52                   	push   %edx
  8002a1:	50                   	push   %eax
  8002a2:	89 f2                	mov    %esi,%edx
  8002a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a7:	e8 98 ff ff ff       	call   800244 <printnum>
  8002ac:	83 c4 20             	add    $0x20,%esp
  8002af:	eb 10                	jmp    8002c1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	57                   	push   %edi
  8002b6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b9:	4b                   	dec    %ebx
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f f0                	jg     8002b1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002cb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d4:	e8 af 0a 00 00       	call   800d88 <__umoddi3>
  8002d9:	83 c4 14             	add    $0x14,%esp
  8002dc:	0f be 80 9f 0f 80 00 	movsbl 0x800f9f(%eax),%eax
  8002e3:	50                   	push   %eax
  8002e4:	ff 55 e4             	call   *-0x1c(%ebp)
  8002e7:	83 c4 10             	add    $0x10,%esp
}
  8002ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7e 0e                	jle    800308 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	8b 52 04             	mov    0x4(%edx),%edx
  800306:	eb 22                	jmp    80032a <getuint+0x38>
	else if (lflag)
  800308:	85 d2                	test   %edx,%edx
  80030a:	74 10                	je     80031c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb 0e                	jmp    80032a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032f:	83 fa 01             	cmp    $0x1,%edx
  800332:	7e 0e                	jle    800342 <getint+0x16>
		return va_arg(*ap, long long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 08             	lea    0x8(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	8b 52 04             	mov    0x4(%edx),%edx
  800340:	eb 1a                	jmp    80035c <getint+0x30>
	else if (lflag)
  800342:	85 d2                	test   %edx,%edx
  800344:	74 0c                	je     800352 <getint+0x26>
		return va_arg(*ap, long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	99                   	cltd   
  800350:	eb 0a                	jmp    80035c <getint+0x30>
	else
		return va_arg(*ap, int);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	99                   	cltd   
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800364:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800367:	8b 10                	mov    (%eax),%edx
  800369:	3b 50 04             	cmp    0x4(%eax),%edx
  80036c:	73 08                	jae    800376 <sprintputch+0x18>
		*b->buf++ = ch;
  80036e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800371:	88 0a                	mov    %cl,(%edx)
  800373:	42                   	inc    %edx
  800374:	89 10                	mov    %edx,(%eax)
}
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80037e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 10             	pushl  0x10(%ebp)
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	e8 05 00 00 00       	call   800395 <vprintfmt>
	va_end(ap);
  800390:	83 c4 10             	add    $0x10,%esp
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	53                   	push   %ebx
  80039b:	83 ec 2c             	sub    $0x2c,%esp
  80039e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a4:	eb 13                	jmp    8003b9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	0f 84 6d 03 00 00    	je     80071b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	57                   	push   %edi
  8003b2:	50                   	push   %eax
  8003b3:	ff 55 08             	call   *0x8(%ebp)
  8003b6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b9:	0f b6 06             	movzbl (%esi),%eax
  8003bc:	46                   	inc    %esi
  8003bd:	83 f8 25             	cmp    $0x25,%eax
  8003c0:	75 e4                	jne    8003a6 <vprintfmt+0x11>
  8003c2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003c6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003cd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003d4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e0:	eb 28                	jmp    80040a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003e8:	eb 20                	jmp    80040a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ec:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003f0:	eb 18                	jmp    80040a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003fb:	eb 0d                	jmp    80040a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8a 06                	mov    (%esi),%al
  80040c:	0f b6 d0             	movzbl %al,%edx
  80040f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800412:	83 e8 23             	sub    $0x23,%eax
  800415:	3c 55                	cmp    $0x55,%al
  800417:	0f 87 e0 02 00 00    	ja     8006fd <vprintfmt+0x368>
  80041d:	0f b6 c0             	movzbl %al,%eax
  800420:	ff 24 85 2c 10 80 00 	jmp    *0x80102c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800427:	83 ea 30             	sub    $0x30,%edx
  80042a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80042d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800430:	8d 50 d0             	lea    -0x30(%eax),%edx
  800433:	83 fa 09             	cmp    $0x9,%edx
  800436:	77 44                	ja     80047c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	89 de                	mov    %ebx,%esi
  80043a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80043e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800441:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800445:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800448:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80044b:	83 fb 09             	cmp    $0x9,%ebx
  80044e:	76 ed                	jbe    80043d <vprintfmt+0xa8>
  800450:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800453:	eb 29                	jmp    80047e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800465:	eb 17                	jmp    80047e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800467:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046b:	78 85                	js     8003f2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	89 de                	mov    %ebx,%esi
  80046f:	eb 99                	jmp    80040a <vprintfmt+0x75>
  800471:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80047a:	eb 8e                	jmp    80040a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800482:	79 86                	jns    80040a <vprintfmt+0x75>
  800484:	e9 74 ff ff ff       	jmp    8003fd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800489:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	89 de                	mov    %ebx,%esi
  80048c:	e9 79 ff ff ff       	jmp    80040a <vprintfmt+0x75>
  800491:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	57                   	push   %edi
  8004a1:	ff 30                	pushl  (%eax)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ac:	e9 08 ff ff ff       	jmp    8003b9 <vprintfmt+0x24>
  8004b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	79 02                	jns    8004c5 <vprintfmt+0x130>
  8004c3:	f7 d8                	neg    %eax
  8004c5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c7:	83 f8 06             	cmp    $0x6,%eax
  8004ca:	7f 0b                	jg     8004d7 <vprintfmt+0x142>
  8004cc:	8b 04 85 84 11 80 00 	mov    0x801184(,%eax,4),%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	75 1a                	jne    8004f1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004d7:	52                   	push   %edx
  8004d8:	68 b7 0f 80 00       	push   $0x800fb7
  8004dd:	57                   	push   %edi
  8004de:	ff 75 08             	pushl  0x8(%ebp)
  8004e1:	e8 92 fe ff ff       	call   800378 <printfmt>
  8004e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ec:	e9 c8 fe ff ff       	jmp    8003b9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004f1:	50                   	push   %eax
  8004f2:	68 ba 11 80 00       	push   $0x8011ba
  8004f7:	57                   	push   %edi
  8004f8:	ff 75 08             	pushl  0x8(%ebp)
  8004fb:	e8 78 fe ff ff       	call   800378 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800506:	e9 ae fe ff ff       	jmp    8003b9 <vprintfmt+0x24>
  80050b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80050e:	89 de                	mov    %ebx,%esi
  800510:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800524:	85 c0                	test   %eax,%eax
  800526:	75 07                	jne    80052f <vprintfmt+0x19a>
				p = "(null)";
  800528:	c7 45 d0 b0 0f 80 00 	movl   $0x800fb0,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80052f:	85 db                	test   %ebx,%ebx
  800531:	7e 42                	jle    800575 <vprintfmt+0x1e0>
  800533:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800537:	74 3c                	je     800575 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	51                   	push   %ecx
  80053d:	ff 75 d0             	pushl  -0x30(%ebp)
  800540:	e8 6f 02 00 00       	call   8007b4 <strnlen>
  800545:	29 c3                	sub    %eax,%ebx
  800547:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 db                	test   %ebx,%ebx
  80054f:	7e 24                	jle    800575 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800551:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800555:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800558:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	57                   	push   %edi
  80055f:	53                   	push   %ebx
  800560:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	4e                   	dec    %esi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	85 f6                	test   %esi,%esi
  800569:	7f f0                	jg     80055b <vprintfmt+0x1c6>
  80056b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80056e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800578:	0f be 02             	movsbl (%edx),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	75 47                	jne    8005c6 <vprintfmt+0x231>
  80057f:	eb 37                	jmp    8005b8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	74 16                	je     80059d <vprintfmt+0x208>
  800587:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058a:	83 fa 5e             	cmp    $0x5e,%edx
  80058d:	76 0e                	jbe    80059d <vprintfmt+0x208>
					putch('?', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	57                   	push   %edi
  800593:	6a 3f                	push   $0x3f
  800595:	ff 55 08             	call   *0x8(%ebp)
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	eb 0b                	jmp    8005a8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	57                   	push   %edi
  8005a1:	50                   	push   %eax
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ab:	0f be 03             	movsbl (%ebx),%eax
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	74 03                	je     8005b5 <vprintfmt+0x220>
  8005b2:	43                   	inc    %ebx
  8005b3:	eb 1b                	jmp    8005d0 <vprintfmt+0x23b>
  8005b5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bc:	7f 1e                	jg     8005dc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005c1:	e9 f3 fd ff ff       	jmp    8003b9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c9:	43                   	inc    %ebx
  8005ca:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005cd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d0:	85 f6                	test   %esi,%esi
  8005d2:	78 ad                	js     800581 <vprintfmt+0x1ec>
  8005d4:	4e                   	dec    %esi
  8005d5:	79 aa                	jns    800581 <vprintfmt+0x1ec>
  8005d7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005da:	eb dc                	jmp    8005b8 <vprintfmt+0x223>
  8005dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	57                   	push   %edi
  8005e3:	6a 20                	push   $0x20
  8005e5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e8:	4b                   	dec    %ebx
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f ef                	jg     8005df <vprintfmt+0x24a>
  8005f0:	e9 c4 fd ff ff       	jmp    8003b9 <vprintfmt+0x24>
  8005f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 2a fd ff ff       	call   80032c <getint>
  800602:	89 c3                	mov    %eax,%ebx
  800604:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800606:	85 d2                	test   %edx,%edx
  800608:	78 0a                	js     800614 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060f:	e9 b0 00 00 00       	jmp    8006c4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	57                   	push   %edi
  800618:	6a 2d                	push   $0x2d
  80061a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80061d:	f7 db                	neg    %ebx
  80061f:	83 d6 00             	adc    $0x0,%esi
  800622:	f7 de                	neg    %esi
  800624:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062c:	e9 93 00 00 00       	jmp    8006c4 <vprintfmt+0x32f>
  800631:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	89 ca                	mov    %ecx,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 b4 fc ff ff       	call   8002f2 <getuint>
  80063e:	89 c3                	mov    %eax,%ebx
  800640:	89 d6                	mov    %edx,%esi
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800647:	eb 7b                	jmp    8006c4 <vprintfmt+0x32f>
  800649:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 d6 fc ff ff       	call   80032c <getint>
  800656:	89 c3                	mov    %eax,%ebx
  800658:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80065a:	85 d2                	test   %edx,%edx
  80065c:	78 07                	js     800665 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80065e:	b8 08 00 00 00       	mov    $0x8,%eax
  800663:	eb 5f                	jmp    8006c4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	57                   	push   %edi
  800669:	6a 2d                	push   $0x2d
  80066b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80066e:	f7 db                	neg    %ebx
  800670:	83 d6 00             	adc    $0x0,%esi
  800673:	f7 de                	neg    %esi
  800675:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
  80067d:	eb 45                	jmp    8006c4 <vprintfmt+0x32f>
  80067f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	57                   	push   %edi
  800686:	6a 30                	push   $0x30
  800688:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	57                   	push   %edi
  80068f:	6a 78                	push   $0x78
  800691:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069d:	8b 18                	mov    (%eax),%ebx
  80069f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ac:	eb 16                	jmp    8006c4 <vprintfmt+0x32f>
  8006ae:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	89 ca                	mov    %ecx,%edx
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 37 fc ff ff       	call   8002f2 <getuint>
  8006bb:	89 c3                	mov    %eax,%ebx
  8006bd:	89 d6                	mov    %edx,%esi
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	83 ec 0c             	sub    $0xc,%esp
  8006c7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006cb:	52                   	push   %edx
  8006cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cf:	50                   	push   %eax
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	89 fa                	mov    %edi,%edx
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	e8 68 fb ff ff       	call   800244 <printnum>
			break;
  8006dc:	83 c4 20             	add    $0x20,%esp
  8006df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006e2:	e9 d2 fc ff ff       	jmp    8003b9 <vprintfmt+0x24>
  8006e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	57                   	push   %edi
  8006ee:	52                   	push   %edx
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f8:	e9 bc fc ff ff       	jmp    8003b9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	57                   	push   %edi
  800701:	6a 25                	push   $0x25
  800703:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	eb 02                	jmp    80070d <vprintfmt+0x378>
  80070b:	89 c6                	mov    %eax,%esi
  80070d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800710:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800714:	75 f5                	jne    80070b <vprintfmt+0x376>
  800716:	e9 9e fc ff ff       	jmp    8003b9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80071b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	5f                   	pop    %edi
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 18             	sub    $0x18,%esp
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800732:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800736:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800739:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800740:	85 c0                	test   %eax,%eax
  800742:	74 26                	je     80076a <vsnprintf+0x47>
  800744:	85 d2                	test   %edx,%edx
  800746:	7e 29                	jle    800771 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800748:	ff 75 14             	pushl  0x14(%ebp)
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800751:	50                   	push   %eax
  800752:	68 5e 03 80 00       	push   $0x80035e
  800757:	e8 39 fc ff ff       	call   800395 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb 0c                	jmp    800776 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076f:	eb 05                	jmp    800776 <vsnprintf+0x53>
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 93 ff ff ff       	call   800723 <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    
	...

00800794 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	80 3a 00             	cmpb   $0x0,(%edx)
  80079d:	74 0e                	je     8007ad <strlen+0x19>
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a9:	75 f9                	jne    8007a4 <strlen+0x10>
  8007ab:	eb 05                	jmp    8007b2 <strlen+0x1e>
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	85 d2                	test   %edx,%edx
  8007bf:	74 17                	je     8007d8 <strnlen+0x24>
  8007c1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c4:	74 19                	je     8007df <strnlen+0x2b>
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007cb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 d0                	cmp    %edx,%eax
  8007ce:	74 14                	je     8007e4 <strnlen+0x30>
  8007d0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d4:	75 f5                	jne    8007cb <strnlen+0x17>
  8007d6:	eb 0c                	jmp    8007e4 <strnlen+0x30>
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	eb 05                	jmp    8007e4 <strnlen+0x30>
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007fb:	42                   	inc    %edx
  8007fc:	84 c9                	test   %cl,%cl
  8007fe:	75 f5                	jne    8007f5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800800:	5b                   	pop    %ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080a:	53                   	push   %ebx
  80080b:	e8 84 ff ff ff       	call   800794 <strlen>
  800810:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800819:	50                   	push   %eax
  80081a:	e8 c7 ff ff ff       	call   8007e6 <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	85 f6                	test   %esi,%esi
  800836:	74 15                	je     80084d <strncpy+0x27>
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80083d:	8a 1a                	mov    (%edx),%bl
  80083f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800842:	80 3a 01             	cmpb   $0x1,(%edx)
  800845:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800848:	41                   	inc    %ecx
  800849:	39 ce                	cmp    %ecx,%esi
  80084b:	77 f0                	ja     80083d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	57                   	push   %edi
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800860:	85 f6                	test   %esi,%esi
  800862:	74 32                	je     800896 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800864:	83 fe 01             	cmp    $0x1,%esi
  800867:	74 22                	je     80088b <strlcpy+0x3a>
  800869:	8a 0b                	mov    (%ebx),%cl
  80086b:	84 c9                	test   %cl,%cl
  80086d:	74 20                	je     80088f <strlcpy+0x3e>
  80086f:	89 f8                	mov    %edi,%eax
  800871:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800876:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	88 08                	mov    %cl,(%eax)
  80087b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087c:	39 f2                	cmp    %esi,%edx
  80087e:	74 11                	je     800891 <strlcpy+0x40>
  800880:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800884:	42                   	inc    %edx
  800885:	84 c9                	test   %cl,%cl
  800887:	75 f0                	jne    800879 <strlcpy+0x28>
  800889:	eb 06                	jmp    800891 <strlcpy+0x40>
  80088b:	89 f8                	mov    %edi,%eax
  80088d:	eb 02                	jmp    800891 <strlcpy+0x40>
  80088f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800891:	c6 00 00             	movb   $0x0,(%eax)
  800894:	eb 02                	jmp    800898 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800896:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800898:	29 f8                	sub    %edi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5f                   	pop    %edi
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	8a 01                	mov    (%ecx),%al
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 10                	je     8008be <strcmp+0x1f>
  8008ae:	3a 02                	cmp    (%edx),%al
  8008b0:	75 0c                	jne    8008be <strcmp+0x1f>
		p++, q++;
  8008b2:	41                   	inc    %ecx
  8008b3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b4:	8a 01                	mov    (%ecx),%al
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 04                	je     8008be <strcmp+0x1f>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	74 f4                	je     8008b2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 c0             	movzbl %al,%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	74 1b                	je     8008f4 <strncmp+0x2c>
  8008d9:	8a 1a                	mov    (%edx),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 24                	je     800903 <strncmp+0x3b>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	75 20                	jne    800903 <strncmp+0x3b>
  8008e3:	48                   	dec    %eax
  8008e4:	74 15                	je     8008fb <strncmp+0x33>
		n--, p++, q++;
  8008e6:	42                   	inc    %edx
  8008e7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e8:	8a 1a                	mov    (%edx),%bl
  8008ea:	84 db                	test   %bl,%bl
  8008ec:	74 15                	je     800903 <strncmp+0x3b>
  8008ee:	3a 19                	cmp    (%ecx),%bl
  8008f0:	74 f1                	je     8008e3 <strncmp+0x1b>
  8008f2:	eb 0f                	jmp    800903 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb 05                	jmp    800900 <strncmp+0x38>
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800900:	5b                   	pop    %ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800903:	0f b6 02             	movzbl (%edx),%eax
  800906:	0f b6 11             	movzbl (%ecx),%edx
  800909:	29 d0                	sub    %edx,%eax
  80090b:	eb f3                	jmp    800900 <strncmp+0x38>

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	74 18                	je     800934 <strchr+0x27>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	75 06                	jne    800926 <strchr+0x19>
  800920:	eb 17                	jmp    800939 <strchr+0x2c>
  800922:	38 ca                	cmp    %cl,%dl
  800924:	74 13                	je     800939 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800926:	40                   	inc    %eax
  800927:	8a 10                	mov    (%eax),%dl
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f5                	jne    800922 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
  800932:	eb 05                	jmp    800939 <strchr+0x2c>
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800944:	8a 10                	mov    (%eax),%dl
  800946:	84 d2                	test   %dl,%dl
  800948:	74 11                	je     80095b <strfind+0x20>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	75 06                	jne    800954 <strfind+0x19>
  80094e:	eb 0b                	jmp    80095b <strfind+0x20>
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 07                	je     80095b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800954:	40                   	inc    %eax
  800955:	8a 10                	mov    (%eax),%dl
  800957:	84 d2                	test   %dl,%dl
  800959:	75 f5                	jne    800950 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 7d 08             	mov    0x8(%ebp),%edi
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	74 30                	je     8009a0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800970:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800976:	75 25                	jne    80099d <memset+0x40>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 20                	jne    80099d <memset+0x40>
		c &= 0xFF;
  80097d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800980:	89 d3                	mov    %edx,%ebx
  800982:	c1 e3 08             	shl    $0x8,%ebx
  800985:	89 d6                	mov    %edx,%esi
  800987:	c1 e6 18             	shl    $0x18,%esi
  80098a:	89 d0                	mov    %edx,%eax
  80098c:	c1 e0 10             	shl    $0x10,%eax
  80098f:	09 f0                	or     %esi,%eax
  800991:	09 d0                	or     %edx,%eax
  800993:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800995:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800998:	fc                   	cld    
  800999:	f3 ab                	rep stos %eax,%es:(%edi)
  80099b:	eb 03                	jmp    8009a0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099d:	fc                   	cld    
  80099e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b5:	39 c6                	cmp    %eax,%esi
  8009b7:	73 34                	jae    8009ed <memmove+0x46>
  8009b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bc:	39 d0                	cmp    %edx,%eax
  8009be:	73 2d                	jae    8009ed <memmove+0x46>
		s += n;
		d += n;
  8009c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	f6 c2 03             	test   $0x3,%dl
  8009c6:	75 1b                	jne    8009e3 <memmove+0x3c>
  8009c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ce:	75 13                	jne    8009e3 <memmove+0x3c>
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 0e                	jne    8009e3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d5:	83 ef 04             	sub    $0x4,%edi
  8009d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009db:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009de:	fd                   	std    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 07                	jmp    8009ea <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e3:	4f                   	dec    %edi
  8009e4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e7:	fd                   	std    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ea:	fc                   	cld    
  8009eb:	eb 20                	jmp    800a0d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f3:	75 13                	jne    800a08 <memmove+0x61>
  8009f5:	a8 03                	test   $0x3,%al
  8009f7:	75 0f                	jne    800a08 <memmove+0x61>
  8009f9:	f6 c1 03             	test   $0x3,%cl
  8009fc:	75 0a                	jne    800a08 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 05                	jmp    800a0d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	fc                   	cld    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 85 ff ff ff       	call   8009a7 <memmove>
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a30:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	85 ff                	test   %edi,%edi
  800a35:	74 32                	je     800a69 <memcmp+0x45>
		if (*s1 != *s2)
  800a37:	8a 03                	mov    (%ebx),%al
  800a39:	8a 0e                	mov    (%esi),%cl
  800a3b:	38 c8                	cmp    %cl,%al
  800a3d:	74 19                	je     800a58 <memcmp+0x34>
  800a3f:	eb 0d                	jmp    800a4e <memcmp+0x2a>
  800a41:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a45:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a49:	42                   	inc    %edx
  800a4a:	38 c8                	cmp    %cl,%al
  800a4c:	74 10                	je     800a5e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a4e:	0f b6 c0             	movzbl %al,%eax
  800a51:	0f b6 c9             	movzbl %cl,%ecx
  800a54:	29 c8                	sub    %ecx,%eax
  800a56:	eb 16                	jmp    800a6e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a58:	4f                   	dec    %edi
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	39 fa                	cmp    %edi,%edx
  800a60:	75 df                	jne    800a41 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	eb 05                	jmp    800a6e <memcmp+0x4a>
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7e:	39 d0                	cmp    %edx,%eax
  800a80:	73 12                	jae    800a94 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a85:	38 08                	cmp    %cl,(%eax)
  800a87:	75 06                	jne    800a8f <memfind+0x1c>
  800a89:	eb 09                	jmp    800a94 <memfind+0x21>
  800a8b:	38 08                	cmp    %cl,(%eax)
  800a8d:	74 05                	je     800a94 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8f:	40                   	inc    %eax
  800a90:	39 c2                	cmp    %eax,%edx
  800a92:	77 f7                	ja     800a8b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa2:	eb 01                	jmp    800aa5 <strtol+0xf>
		s++;
  800aa4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa5:	8a 02                	mov    (%edx),%al
  800aa7:	3c 20                	cmp    $0x20,%al
  800aa9:	74 f9                	je     800aa4 <strtol+0xe>
  800aab:	3c 09                	cmp    $0x9,%al
  800aad:	74 f5                	je     800aa4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aaf:	3c 2b                	cmp    $0x2b,%al
  800ab1:	75 08                	jne    800abb <strtol+0x25>
		s++;
  800ab3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab9:	eb 13                	jmp    800ace <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800abb:	3c 2d                	cmp    $0x2d,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x33>
		s++, neg = 1;
  800abf:	8d 52 01             	lea    0x1(%edx),%edx
  800ac2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac7:	eb 05                	jmp    800ace <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	85 db                	test   %ebx,%ebx
  800ad0:	74 05                	je     800ad7 <strtol+0x41>
  800ad2:	83 fb 10             	cmp    $0x10,%ebx
  800ad5:	75 28                	jne    800aff <strtol+0x69>
  800ad7:	8a 02                	mov    (%edx),%al
  800ad9:	3c 30                	cmp    $0x30,%al
  800adb:	75 10                	jne    800aed <strtol+0x57>
  800add:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae1:	75 0a                	jne    800aed <strtol+0x57>
		s += 2, base = 16;
  800ae3:	83 c2 02             	add    $0x2,%edx
  800ae6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aeb:	eb 12                	jmp    800aff <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	75 0e                	jne    800aff <strtol+0x69>
  800af1:	3c 30                	cmp    $0x30,%al
  800af3:	75 05                	jne    800afa <strtol+0x64>
		s++, base = 8;
  800af5:	42                   	inc    %edx
  800af6:	b3 08                	mov    $0x8,%bl
  800af8:	eb 05                	jmp    800aff <strtol+0x69>
	else if (base == 0)
		base = 10;
  800afa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
  800b04:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b06:	8a 0a                	mov    (%edx),%cl
  800b08:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b0b:	80 fb 09             	cmp    $0x9,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0x82>
			dig = *s - '0';
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 30             	sub    $0x30,%ecx
  800b16:	eb 1e                	jmp    800b36 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b18:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b20:	0f be c9             	movsbl %cl,%ecx
  800b23:	83 e9 57             	sub    $0x57,%ecx
  800b26:	eb 0e                	jmp    800b36 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b28:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b2b:	80 fb 19             	cmp    $0x19,%bl
  800b2e:	77 13                	ja     800b43 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b30:	0f be c9             	movsbl %cl,%ecx
  800b33:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b36:	39 f1                	cmp    %esi,%ecx
  800b38:	7d 0d                	jge    800b47 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b3a:	42                   	inc    %edx
  800b3b:	0f af c6             	imul   %esi,%eax
  800b3e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b41:	eb c3                	jmp    800b06 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	eb 02                	jmp    800b49 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b47:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4d:	74 05                	je     800b54 <strtol+0xbe>
		*endptr = (char *) s;
  800b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b52:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b54:	85 ff                	test   %edi,%edi
  800b56:	74 04                	je     800b5c <strtol+0xc6>
  800b58:	89 c8                	mov    %ecx,%eax
  800b5a:	f7 d8                	neg    %eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    
  800b61:	00 00                	add    %al,(%eax)
	...

00800b64 <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 1c             	sub    $0x1c,%esp
  800b6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b70:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b73:	89 ca                	mov    %ecx,%edx
	assert(a5 == 0);
  800b75:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800b79:	74 16                	je     800b91 <my_sysenter+0x2d>
  800b7b:	68 a0 11 80 00       	push   $0x8011a0
  800b80:	68 a8 11 80 00       	push   $0x8011a8
  800b85:	6a 0b                	push   $0xb
  800b87:	68 bd 11 80 00       	push   $0x8011bd
  800b8c:	e8 c7 f5 ff ff       	call   800158 <_panic>
	int32_t ret;

	asm volatile(
  800b91:	be 00 00 00 00       	mov    $0x0,%esi
  800b96:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba2:	55                   	push   %ebp
  800ba3:	54                   	push   %esp
  800ba4:	5d                   	pop    %ebp
  800ba5:	8d 35 ad 0b 80 00    	lea    0x800bad,%esi
  800bab:	0f 34                	sysenter 

00800bad <after_sysenter_label>:
  800bad:	5d                   	pop    %ebp
  800bae:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800bb0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bb4:	74 1c                	je     800bd2 <after_sysenter_label+0x25>
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 18                	jle    800bd2 <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc1:	68 cc 11 80 00       	push   $0x8011cc
  800bc6:	6a 20                	push   $0x20
  800bc8:	68 bd 11 80 00       	push   $0x8011bd
  800bcd:	e8 86 f5 ff ff       	call   800158 <_panic>

	return ret;
}
  800bd2:	89 d0                	mov    %edx,%eax
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800be2:	6a 00                	push   $0x0
  800be4:	6a 00                	push   $0x0
  800be6:	6a 00                	push   $0x0
  800be8:	ff 75 0c             	pushl  0xc(%ebp)
  800beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf8:	e8 67 ff ff ff       	call   800b64 <my_sysenter>
  800bfd:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1f:	e8 40 ff ff ff       	call   800b64 <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c2c:	6a 00                	push   $0x0
  800c2e:	6a 00                	push   $0x0
  800c30:	6a 00                	push   $0x0
  800c32:	6a 00                	push   $0x0
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c41:	e8 1e ff ff ff       	call   800b64 <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c4e:	6a 00                	push   $0x0
  800c50:	6a 00                	push   $0x0
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	e8 fa fe ff ff       	call   800b64 <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	83 ec 10             	sub    $0x10,%esp
  800c74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c7a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800c7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c83:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 2e                	jne    800cb8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800c8a:	39 f1                	cmp    %esi,%ecx
  800c8c:	77 5a                	ja     800ce8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800c8e:	85 c9                	test   %ecx,%ecx
  800c90:	75 0b                	jne    800c9d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	31 d2                	xor    %edx,%edx
  800c99:	f7 f1                	div    %ecx
  800c9b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800c9d:	31 d2                	xor    %edx,%edx
  800c9f:	89 f0                	mov    %esi,%eax
  800ca1:	f7 f1                	div    %ecx
  800ca3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca5:	89 f8                	mov    %edi,%eax
  800ca7:	f7 f1                	div    %ecx
  800ca9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cab:	89 f8                	mov    %edi,%eax
  800cad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800caf:	83 c4 10             	add    $0x10,%esp
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    
  800cb6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cb8:	39 f0                	cmp    %esi,%eax
  800cba:	77 1c                	ja     800cd8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cbc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800cbf:	83 f7 1f             	xor    $0x1f,%edi
  800cc2:	75 3c                	jne    800d00 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cc4:	39 f0                	cmp    %esi,%eax
  800cc6:	0f 82 90 00 00 00    	jb     800d5c <__udivdi3+0xf0>
  800ccc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800cd2:	0f 86 84 00 00 00    	jbe    800d5c <__udivdi3+0xf0>
  800cd8:	31 f6                	xor    %esi,%esi
  800cda:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cdc:	89 f8                	mov    %edi,%eax
  800cde:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    
  800ce7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ce8:	89 f2                	mov    %esi,%edx
  800cea:	89 f8                	mov    %edi,%eax
  800cec:	f7 f1                	div    %ecx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cf6:	83 c4 10             	add    $0x10,%esp
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    
  800cfd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	d3 e0                	shl    %cl,%eax
  800d04:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d07:	b8 20 00 00 00       	mov    $0x20,%eax
  800d0c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d11:	88 c1                	mov    %al,%cl
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d18:	09 ca                	or     %ecx,%edx
  800d1a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d20:	89 f9                	mov    %edi,%ecx
  800d22:	d3 e2                	shl    %cl,%edx
  800d24:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800d27:	89 f2                	mov    %esi,%edx
  800d29:	88 c1                	mov    %al,%cl
  800d2b:	d3 ea                	shr    %cl,%edx
  800d2d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	89 f9                	mov    %edi,%ecx
  800d34:	d3 e2                	shl    %cl,%edx
  800d36:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800d39:	88 c1                	mov    %al,%cl
  800d3b:	d3 ee                	shr    %cl,%esi
  800d3d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d3f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d42:	89 f0                	mov    %esi,%eax
  800d44:	89 ca                	mov    %ecx,%edx
  800d46:	f7 75 ec             	divl   -0x14(%ebp)
  800d49:	89 d1                	mov    %edx,%ecx
  800d4b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d4d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d50:	39 d1                	cmp    %edx,%ecx
  800d52:	72 28                	jb     800d7c <__udivdi3+0x110>
  800d54:	74 1a                	je     800d70 <__udivdi3+0x104>
  800d56:	89 f7                	mov    %esi,%edi
  800d58:	31 f6                	xor    %esi,%esi
  800d5a:	eb 80                	jmp    800cdc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d5c:	31 f6                	xor    %esi,%esi
  800d5e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d63:	89 f8                	mov    %edi,%eax
  800d65:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    
  800d6e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800d70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d77:	39 c2                	cmp    %eax,%edx
  800d79:	73 db                	jae    800d56 <__udivdi3+0xea>
  800d7b:	90                   	nop
		{
		  q0--;
  800d7c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d7f:	31 f6                	xor    %esi,%esi
  800d81:	e9 56 ff ff ff       	jmp    800cdc <__udivdi3+0x70>
	...

00800d88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	83 ec 20             	sub    $0x20,%esp
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d96:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800d99:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d9c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800da2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800da5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da7:	85 ff                	test   %edi,%edi
  800da9:	75 15                	jne    800dc0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800dab:	39 f1                	cmp    %esi,%ecx
  800dad:	0f 86 99 00 00 00    	jbe    800e4c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800db5:	89 d0                	mov    %edx,%eax
  800db7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dc0:	39 f7                	cmp    %esi,%edi
  800dc2:	0f 87 a4 00 00 00    	ja     800e6c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dc8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800dcb:	83 f0 1f             	xor    $0x1f,%eax
  800dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd1:	0f 84 a1 00 00 00    	je     800e78 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dd7:	89 f8                	mov    %edi,%eax
  800dd9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ddc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800dde:	bf 20 00 00 00       	mov    $0x20,%edi
  800de3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800de6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	d3 ea                	shr    %cl,%edx
  800ded:	09 c2                	or     %eax,%edx
  800def:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800df8:	d3 e0                	shl    %cl,%eax
  800dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800dfd:	89 f2                	mov    %esi,%edx
  800dff:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800e01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e04:	d3 e0                	shl    %cl,%eax
  800e06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e09:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e0c:	89 f9                	mov    %edi,%ecx
  800e0e:	d3 e8                	shr    %cl,%eax
  800e10:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800e12:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e14:	89 f2                	mov    %esi,%edx
  800e16:	f7 75 f0             	divl   -0x10(%ebp)
  800e19:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e1b:	f7 65 f4             	mull   -0xc(%ebp)
  800e1e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800e21:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e23:	39 d6                	cmp    %edx,%esi
  800e25:	72 71                	jb     800e98 <__umoddi3+0x110>
  800e27:	74 7f                	je     800ea8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e2c:	29 c8                	sub    %ecx,%eax
  800e2e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e30:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e33:	d3 e8                	shr    %cl,%eax
  800e35:	89 f2                	mov    %esi,%edx
  800e37:	89 f9                	mov    %edi,%ecx
  800e39:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800e3b:	09 d0                	or     %edx,%eax
  800e3d:	89 f2                	mov    %esi,%edx
  800e3f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e42:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e44:	83 c4 20             	add    $0x20,%esp
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    
  800e4b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e4c:	85 c9                	test   %ecx,%ecx
  800e4e:	75 0b                	jne    800e5b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	31 d2                	xor    %edx,%edx
  800e57:	f7 f1                	div    %ecx
  800e59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	31 d2                	xor    %edx,%edx
  800e5f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e64:	f7 f1                	div    %ecx
  800e66:	e9 4a ff ff ff       	jmp    800db5 <__umoddi3+0x2d>
  800e6b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800e6c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e6e:	83 c4 20             	add    $0x20,%esp
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e78:	39 f7                	cmp    %esi,%edi
  800e7a:	72 05                	jb     800e81 <__umoddi3+0xf9>
  800e7c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800e7f:	77 0c                	ja     800e8d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e81:	89 f2                	mov    %esi,%edx
  800e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e86:	29 c8                	sub    %ecx,%eax
  800e88:	19 fa                	sbb    %edi,%edx
  800e8a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e90:	83 c4 20             	add    $0x20,%esp
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    
  800e97:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e98:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e9b:	89 c1                	mov    %eax,%ecx
  800e9d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800ea0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800ea3:	eb 84                	jmp    800e29 <__umoddi3+0xa1>
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800eab:	72 eb                	jb     800e98 <__umoddi3+0x110>
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	e9 75 ff ff ff       	jmp    800e29 <__umoddi3+0xa1>
