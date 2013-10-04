
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c9                   	leave  
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 08             	sub    $0x8,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
  800049:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004c:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800053:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	7e 08                	jle    800062 <libmain+0x22>
		binaryname = argv[0];
  80005a:	8b 0a                	mov    (%edx),%ecx
  80005c:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800062:	83 ec 08             	sub    $0x8,%esp
  800065:	52                   	push   %edx
  800066:	50                   	push   %eax
  800067:	e8 c8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006c:	e8 07 00 00 00       	call   800078 <exit>
  800071:	83 c4 10             	add    $0x10,%esp
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007e:	6a 00                	push   $0x0
  800080:	e8 44 00 00 00       	call   8000c9 <sys_env_destroy>
  800085:	83 c4 10             	add    $0x10,%esp
}
  800088:	c9                   	leave  
  800089:	c3                   	ret    
	...

0080008c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	57                   	push   %edi
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800092:	b8 00 00 00 00       	mov    $0x0,%eax
  800097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009a:	8b 55 08             	mov    0x8(%ebp),%edx
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5f                   	pop    %edi
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ba:	89 d1                	mov    %edx,%ecx
  8000bc:	89 d3                	mov    %edx,%ebx
  8000be:	89 d7                	mov    %edx,%edi
  8000c0:	89 d6                	mov    %edx,%esi
  8000c2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 cb                	mov    %ecx,%ebx
  8000e1:	89 cf                	mov    %ecx,%edi
  8000e3:	89 ce                	mov    %ecx,%esi
  8000e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	7e 17                	jle    800102 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	50                   	push   %eax
  8000ef:	6a 03                	push   $0x3
  8000f1:	68 8a 0d 80 00       	push   $0x800d8a
  8000f6:	6a 23                	push   $0x23
  8000f8:	68 a7 0d 80 00       	push   $0x800da7
  8000fd:	e8 2a 00 00 00       	call   80012c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800102:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800105:	5b                   	pop    %ebx
  800106:	5e                   	pop    %esi
  800107:	5f                   	pop    %edi
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	57                   	push   %edi
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800110:	ba 00 00 00 00       	mov    $0x0,%edx
  800115:	b8 02 00 00 00       	mov    $0x2,%eax
  80011a:	89 d1                	mov    %edx,%ecx
  80011c:	89 d3                	mov    %edx,%ebx
  80011e:	89 d7                	mov    %edx,%edi
  800120:	89 d6                	mov    %edx,%esi
  800122:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	c9                   	leave  
  800128:	c3                   	ret    
  800129:	00 00                	add    %al,(%eax)
	...

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80013a:	e8 cb ff ff ff       	call   80010a <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	53                   	push   %ebx
  800149:	50                   	push   %eax
  80014a:	68 b8 0d 80 00       	push   $0x800db8
  80014f:	e8 b0 00 00 00       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	56                   	push   %esi
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 53 00 00 00       	call   8001b3 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 dc 0d 80 00 	movl   $0x800ddc,(%esp)
  800167:	e8 98 00 00 00       	call   800204 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>
	...

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 03                	mov    (%ebx),%eax
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800187:	40                   	inc    %eax
  800188:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	75 1a                	jne    8001ab <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800191:	83 ec 08             	sub    $0x8,%esp
  800194:	68 ff 00 00 00       	push   $0xff
  800199:	8d 43 08             	lea    0x8(%ebx),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 ea fe ff ff       	call   80008c <sys_cputs>
		b->idx = 0;
  8001a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ab:	ff 43 04             	incl   0x4(%ebx)
}
  8001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	ff 75 08             	pushl  0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 74 01 80 00       	push   $0x800174
  8001e2:	e8 82 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 90 fe ff ff       	call   80008c <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020d:	50                   	push   %eax
  80020e:	ff 75 08             	pushl  0x8(%ebp)
  800211:	e8 9d ff ff ff       	call   8001b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 2c             	sub    $0x2c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800238:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80023e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800245:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800248:	72 0c                	jb     800256 <printnum+0x3e>
  80024a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024d:	76 07                	jbe    800256 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024f:	4b                   	dec    %ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f 31                	jg     800285 <printnum+0x6d>
  800254:	eb 3f                	jmp    800295 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	57                   	push   %edi
  80025a:	4b                   	dec    %ebx
  80025b:	53                   	push   %ebx
  80025c:	50                   	push   %eax
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	ff 75 d4             	pushl  -0x2c(%ebp)
  800263:	ff 75 d0             	pushl  -0x30(%ebp)
  800266:	ff 75 dc             	pushl  -0x24(%ebp)
  800269:	ff 75 d8             	pushl  -0x28(%ebp)
  80026c:	e8 c7 08 00 00       	call   800b38 <__udivdi3>
  800271:	83 c4 18             	add    $0x18,%esp
  800274:	52                   	push   %edx
  800275:	50                   	push   %eax
  800276:	89 f2                	mov    %esi,%edx
  800278:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027b:	e8 98 ff ff ff       	call   800218 <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 10                	jmp    800295 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	57                   	push   %edi
  80028a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028d:	4b                   	dec    %ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f f0                	jg     800285 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029f:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 a7 09 00 00       	call   800c54 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 de 0d 80 00 	movsbl 0x800dde(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002bb:	83 c4 10             	add    $0x10,%esp
}
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800303:	83 fa 01             	cmp    $0x1,%edx
  800306:	7e 0e                	jle    800316 <getint+0x16>
		return va_arg(*ap, long long);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	8b 52 04             	mov    0x4(%edx),%edx
  800314:	eb 1a                	jmp    800330 <getint+0x30>
	else if (lflag)
  800316:	85 d2                	test   %edx,%edx
  800318:	74 0c                	je     800326 <getint+0x26>
		return va_arg(*ap, long);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	99                   	cltd   
  800324:	eb 0a                	jmp    800330 <getint+0x30>
	else
		return va_arg(*ap, int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800338:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	3b 50 04             	cmp    0x4(%eax),%edx
  800340:	73 08                	jae    80034a <sprintputch+0x18>
		*b->buf++ = ch;
  800342:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800345:	88 0a                	mov    %cl,(%edx)
  800347:	42                   	inc    %edx
  800348:	89 10                	mov    %edx,(%eax)
}
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
  800364:	83 c4 10             	add    $0x10,%esp
}
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800375:	8b 75 10             	mov    0x10(%ebp),%esi
  800378:	eb 13                	jmp    80038d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037a:	85 c0                	test   %eax,%eax
  80037c:	0f 84 6d 03 00 00    	je     8006ef <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	57                   	push   %edi
  800386:	50                   	push   %eax
  800387:	ff 55 08             	call   *0x8(%ebp)
  80038a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	0f b6 06             	movzbl (%esi),%eax
  800390:	46                   	inc    %esi
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e4                	jne    80037a <vprintfmt+0x11>
  800396:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80039a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003a8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	eb 28                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003bc:	eb 20                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c4:	eb 18                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cf:	eb 0d                	jmp    8003de <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8a 06                	mov    (%esi),%al
  8003e0:	0f b6 d0             	movzbl %al,%edx
  8003e3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003e6:	83 e8 23             	sub    $0x23,%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 e0 02 00 00    	ja     8006d1 <vprintfmt+0x368>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	ff 24 85 6c 0e 80 00 	jmp    *0x800e6c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	83 ea 30             	sub    $0x30,%edx
  8003fe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800401:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800404:	8d 50 d0             	lea    -0x30(%eax),%edx
  800407:	83 fa 09             	cmp    $0x9,%edx
  80040a:	77 44                	ja     800450 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	89 de                	mov    %ebx,%esi
  80040e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800411:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800412:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800415:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800419:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80041c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80041f:	83 fb 09             	cmp    $0x9,%ebx
  800422:	76 ed                	jbe    800411 <vprintfmt+0xa8>
  800424:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800427:	eb 29                	jmp    800452 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	8b 00                	mov    (%eax),%eax
  800434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800439:	eb 17                	jmp    800452 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	78 85                	js     8003c6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 de                	mov    %ebx,%esi
  800443:	eb 99                	jmp    8003de <vprintfmt+0x75>
  800445:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800447:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80044e:	eb 8e                	jmp    8003de <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800452:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800456:	79 86                	jns    8003de <vprintfmt+0x75>
  800458:	e9 74 ff ff ff       	jmp    8003d1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	89 de                	mov    %ebx,%esi
  800460:	e9 79 ff ff ff       	jmp    8003de <vprintfmt+0x75>
  800465:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	57                   	push   %edi
  800475:	ff 30                	pushl  (%eax)
  800477:	ff 55 08             	call   *0x8(%ebp)
			break;
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800480:	e9 08 ff ff ff       	jmp    80038d <vprintfmt+0x24>
  800485:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 50 04             	lea    0x4(%eax),%edx
  80048e:	89 55 14             	mov    %edx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	79 02                	jns    800499 <vprintfmt+0x130>
  800497:	f7 d8                	neg    %eax
  800499:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 06             	cmp    $0x6,%eax
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x142>
  8004a0:	8b 04 85 c4 0f 80 00 	mov    0x800fc4(,%eax,4),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	75 1a                	jne    8004c5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	52                   	push   %edx
  8004ac:	68 f6 0d 80 00       	push   $0x800df6
  8004b1:	57                   	push   %edi
  8004b2:	ff 75 08             	pushl  0x8(%ebp)
  8004b5:	e8 92 fe ff ff       	call   80034c <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c0:	e9 c8 fe ff ff       	jmp    80038d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004c5:	50                   	push   %eax
  8004c6:	68 ff 0d 80 00       	push   $0x800dff
  8004cb:	57                   	push   %edi
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 78 fe ff ff       	call   80034c <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004da:	e9 ae fe ff ff       	jmp    80038d <vprintfmt+0x24>
  8004df:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e2:	89 de                	mov    %ebx,%esi
  8004e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	75 07                	jne    800503 <vprintfmt+0x19a>
				p = "(null)";
  8004fc:	c7 45 d0 ef 0d 80 00 	movl   $0x800def,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800503:	85 db                	test   %ebx,%ebx
  800505:	7e 42                	jle    800549 <vprintfmt+0x1e0>
  800507:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80050b:	74 3c                	je     800549 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	51                   	push   %ecx
  800511:	ff 75 d0             	pushl  -0x30(%ebp)
  800514:	e8 6f 02 00 00       	call   800788 <strnlen>
  800519:	29 c3                	sub    %eax,%ebx
  80051b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 db                	test   %ebx,%ebx
  800523:	7e 24                	jle    800549 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800525:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800529:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80052c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	53                   	push   %ebx
  800534:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	4e                   	dec    %esi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 f6                	test   %esi,%esi
  80053d:	7f f0                	jg     80052f <vprintfmt+0x1c6>
  80053f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800542:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80054c:	0f be 02             	movsbl (%edx),%eax
  80054f:	85 c0                	test   %eax,%eax
  800551:	75 47                	jne    80059a <vprintfmt+0x231>
  800553:	eb 37                	jmp    80058c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	74 16                	je     800571 <vprintfmt+0x208>
  80055b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055e:	83 fa 5e             	cmp    $0x5e,%edx
  800561:	76 0e                	jbe    800571 <vprintfmt+0x208>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0b                	jmp    80057c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	57                   	push   %edi
  800575:	50                   	push   %eax
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	ff 4d e4             	decl   -0x1c(%ebp)
  80057f:	0f be 03             	movsbl (%ebx),%eax
  800582:	85 c0                	test   %eax,%eax
  800584:	74 03                	je     800589 <vprintfmt+0x220>
  800586:	43                   	inc    %ebx
  800587:	eb 1b                	jmp    8005a4 <vprintfmt+0x23b>
  800589:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800590:	7f 1e                	jg     8005b0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800595:	e9 f3 fd ff ff       	jmp    80038d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80059d:	43                   	inc    %ebx
  80059e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a4:	85 f6                	test   %esi,%esi
  8005a6:	78 ad                	js     800555 <vprintfmt+0x1ec>
  8005a8:	4e                   	dec    %esi
  8005a9:	79 aa                	jns    800555 <vprintfmt+0x1ec>
  8005ab:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ae:	eb dc                	jmp    80058c <vprintfmt+0x223>
  8005b0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	6a 20                	push   $0x20
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	4b                   	dec    %ebx
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 db                	test   %ebx,%ebx
  8005c2:	7f ef                	jg     8005b3 <vprintfmt+0x24a>
  8005c4:	e9 c4 fd ff ff       	jmp    80038d <vprintfmt+0x24>
  8005c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 2a fd ff ff       	call   800300 <getint>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005da:	85 d2                	test   %edx,%edx
  8005dc:	78 0a                	js     8005e8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 b0 00 00 00       	jmp    800698 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	57                   	push   %edi
  8005ec:	6a 2d                	push   $0x2d
  8005ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f1:	f7 db                	neg    %ebx
  8005f3:	83 d6 00             	adc    $0x0,%esi
  8005f6:	f7 de                	neg    %esi
  8005f8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 93 00 00 00       	jmp    800698 <vprintfmt+0x32f>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800608:	89 ca                	mov    %ecx,%edx
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 b4 fc ff ff       	call   8002c6 <getuint>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	89 d6                	mov    %edx,%esi
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061b:	eb 7b                	jmp    800698 <vprintfmt+0x32f>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 d6 fc ff ff       	call   800300 <getint>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80062e:	85 d2                	test   %edx,%edx
  800630:	78 07                	js     800639 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
  800637:	eb 5f                	jmp    800698 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	57                   	push   %edi
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800642:	f7 db                	neg    %ebx
  800644:	83 d6 00             	adc    $0x0,%esi
  800647:	f7 de                	neg    %esi
  800649:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80064c:	b8 08 00 00 00       	mov    $0x8,%eax
  800651:	eb 45                	jmp    800698 <vprintfmt+0x32f>
  800653:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	57                   	push   %edi
  80065a:	6a 30                	push   $0x30
  80065c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	6a 78                	push   $0x78
  800665:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800671:	8b 18                	mov    (%eax),%ebx
  800673:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800678:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800680:	eb 16                	jmp    800698 <vprintfmt+0x32f>
  800682:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800685:	89 ca                	mov    %ecx,%edx
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 37 fc ff ff       	call   8002c6 <getuint>
  80068f:	89 c3                	mov    %eax,%ebx
  800691:	89 d6                	mov    %edx,%esi
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80069f:	52                   	push   %edx
  8006a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a3:	50                   	push   %eax
  8006a4:	56                   	push   %esi
  8006a5:	53                   	push   %ebx
  8006a6:	89 fa                	mov    %edi,%edx
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	e8 68 fb ff ff       	call   800218 <printnum>
			break;
  8006b0:	83 c4 20             	add    $0x20,%esp
  8006b3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006b6:	e9 d2 fc ff ff       	jmp    80038d <vprintfmt+0x24>
  8006bb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	57                   	push   %edi
  8006c2:	52                   	push   %edx
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cc:	e9 bc fc ff ff       	jmp    80038d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	57                   	push   %edi
  8006d5:	6a 25                	push   $0x25
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 02                	jmp    8006e1 <vprintfmt+0x378>
  8006df:	89 c6                	mov    %eax,%esi
  8006e1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006e4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e8:	75 f5                	jne    8006df <vprintfmt+0x376>
  8006ea:	e9 9e fc ff ff       	jmp    80038d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 29                	jle    800745 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 32 03 80 00       	push   $0x800332
  80072b:	e8 39 fc ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 0c                	jmp    80074a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800743:	eb 05                	jmp    80074a <vsnprintf+0x53>
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800755:	50                   	push   %eax
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 93 ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
	...

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3a 00             	cmpb   $0x0,(%edx)
  800771:	74 0e                	je     800781 <strlen+0x19>
  800773:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800778:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077d:	75 f9                	jne    800778 <strlen+0x10>
  80077f:	eb 05                	jmp    800786 <strlen+0x1e>
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	85 d2                	test   %edx,%edx
  800793:	74 17                	je     8007ac <strnlen+0x24>
  800795:	80 39 00             	cmpb   $0x0,(%ecx)
  800798:	74 19                	je     8007b3 <strnlen+0x2b>
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80079f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	39 d0                	cmp    %edx,%eax
  8007a2:	74 14                	je     8007b8 <strnlen+0x30>
  8007a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a8:	75 f5                	jne    80079f <strnlen+0x17>
  8007aa:	eb 0c                	jmp    8007b8 <strnlen+0x30>
  8007ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b1:	eb 05                	jmp    8007b8 <strnlen+0x30>
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007cc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007cf:	42                   	inc    %edx
  8007d0:	84 c9                	test   %cl,%cl
  8007d2:	75 f5                	jne    8007c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 84 ff ff ff       	call   800768 <strlen>
  8007e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c7 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	85 f6                	test   %esi,%esi
  80080a:	74 15                	je     800821 <strncpy+0x27>
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800811:	8a 1a                	mov    (%edx),%bl
  800813:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 3a 01             	cmpb   $0x1,(%edx)
  800819:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	41                   	inc    %ecx
  80081d:	39 ce                	cmp    %ecx,%esi
  80081f:	77 f0                	ja     800811 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	57                   	push   %edi
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800831:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 f6                	test   %esi,%esi
  800836:	74 32                	je     80086a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800838:	83 fe 01             	cmp    $0x1,%esi
  80083b:	74 22                	je     80085f <strlcpy+0x3a>
  80083d:	8a 0b                	mov    (%ebx),%cl
  80083f:	84 c9                	test   %cl,%cl
  800841:	74 20                	je     800863 <strlcpy+0x3e>
  800843:	89 f8                	mov    %edi,%eax
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80084a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084d:	88 08                	mov    %cl,(%eax)
  80084f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800850:	39 f2                	cmp    %esi,%edx
  800852:	74 11                	je     800865 <strlcpy+0x40>
  800854:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800858:	42                   	inc    %edx
  800859:	84 c9                	test   %cl,%cl
  80085b:	75 f0                	jne    80084d <strlcpy+0x28>
  80085d:	eb 06                	jmp    800865 <strlcpy+0x40>
  80085f:	89 f8                	mov    %edi,%eax
  800861:	eb 02                	jmp    800865 <strlcpy+0x40>
  800863:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
  800868:	eb 02                	jmp    80086c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80086c:	29 f8                	sub    %edi,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	8a 01                	mov    (%ecx),%al
  80087e:	84 c0                	test   %al,%al
  800880:	74 10                	je     800892 <strcmp+0x1f>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	75 0c                	jne    800892 <strcmp+0x1f>
		p++, q++;
  800886:	41                   	inc    %ecx
  800887:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800888:	8a 01                	mov    (%ecx),%al
  80088a:	84 c0                	test   %al,%al
  80088c:	74 04                	je     800892 <strcmp+0x1f>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	74 f4                	je     800886 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	74 1b                	je     8008c8 <strncmp+0x2c>
  8008ad:	8a 1a                	mov    (%edx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	74 24                	je     8008d7 <strncmp+0x3b>
  8008b3:	3a 19                	cmp    (%ecx),%bl
  8008b5:	75 20                	jne    8008d7 <strncmp+0x3b>
  8008b7:	48                   	dec    %eax
  8008b8:	74 15                	je     8008cf <strncmp+0x33>
		n--, p++, q++;
  8008ba:	42                   	inc    %edx
  8008bb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bc:	8a 1a                	mov    (%edx),%bl
  8008be:	84 db                	test   %bl,%bl
  8008c0:	74 15                	je     8008d7 <strncmp+0x3b>
  8008c2:	3a 19                	cmp    (%ecx),%bl
  8008c4:	74 f1                	je     8008b7 <strncmp+0x1b>
  8008c6:	eb 0f                	jmp    8008d7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 05                	jmp    8008d4 <strncmp+0x38>
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 02             	movzbl (%edx),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb f3                	jmp    8008d4 <strncmp+0x38>

008008e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ea:	8a 10                	mov    (%eax),%dl
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 18                	je     800908 <strchr+0x27>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	75 06                	jne    8008fa <strchr+0x19>
  8008f4:	eb 17                	jmp    80090d <strchr+0x2c>
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 13                	je     80090d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	40                   	inc    %eax
  8008fb:	8a 10                	mov    (%eax),%dl
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f5                	jne    8008f6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	eb 05                	jmp    80090d <strchr+0x2c>
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800918:	8a 10                	mov    (%eax),%dl
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 11                	je     80092f <strfind+0x20>
		if (*s == c)
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	75 06                	jne    800928 <strfind+0x19>
  800922:	eb 0b                	jmp    80092f <strfind+0x20>
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 07                	je     80092f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800928:	40                   	inc    %eax
  800929:	8a 10                	mov    (%eax),%dl
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f5                	jne    800924 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	74 30                	je     800974 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800944:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094a:	75 25                	jne    800971 <memset+0x40>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 20                	jne    800971 <memset+0x40>
		c &= 0xFF;
  800951:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800954:	89 d3                	mov    %edx,%ebx
  800956:	c1 e3 08             	shl    $0x8,%ebx
  800959:	89 d6                	mov    %edx,%esi
  80095b:	c1 e6 18             	shl    $0x18,%esi
  80095e:	89 d0                	mov    %edx,%eax
  800960:	c1 e0 10             	shl    $0x10,%eax
  800963:	09 f0                	or     %esi,%eax
  800965:	09 d0                	or     %edx,%eax
  800967:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800969:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096c:	fc                   	cld    
  80096d:	f3 ab                	rep stos %eax,%es:(%edi)
  80096f:	eb 03                	jmp    800974 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800989:	39 c6                	cmp    %eax,%esi
  80098b:	73 34                	jae    8009c1 <memmove+0x46>
  80098d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800990:	39 d0                	cmp    %edx,%eax
  800992:	73 2d                	jae    8009c1 <memmove+0x46>
		s += n;
		d += n;
  800994:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 1b                	jne    8009b7 <memmove+0x3c>
  80099c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a2:	75 13                	jne    8009b7 <memmove+0x3c>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0e                	jne    8009b7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 07                	jmp    8009be <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b7:	4f                   	dec    %edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
  8009bf:	eb 20                	jmp    8009e1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x61>
  8009c9:	a8 03                	test   $0x3,%al
  8009cb:	75 0f                	jne    8009dc <memmove+0x61>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0a                	jne    8009dc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 05                	jmp    8009e1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 85 ff ff ff       	call   80097b <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	85 ff                	test   %edi,%edi
  800a09:	74 32                	je     800a3d <memcmp+0x45>
		if (*s1 != *s2)
  800a0b:	8a 03                	mov    (%ebx),%al
  800a0d:	8a 0e                	mov    (%esi),%cl
  800a0f:	38 c8                	cmp    %cl,%al
  800a11:	74 19                	je     800a2c <memcmp+0x34>
  800a13:	eb 0d                	jmp    800a22 <memcmp+0x2a>
  800a15:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a19:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a1d:	42                   	inc    %edx
  800a1e:	38 c8                	cmp    %cl,%al
  800a20:	74 10                	je     800a32 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a22:	0f b6 c0             	movzbl %al,%eax
  800a25:	0f b6 c9             	movzbl %cl,%ecx
  800a28:	29 c8                	sub    %ecx,%eax
  800a2a:	eb 16                	jmp    800a42 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	4f                   	dec    %edi
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	39 fa                	cmp    %edi,%edx
  800a34:	75 df                	jne    800a15 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 05                	jmp    800a42 <memcmp+0x4a>
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	73 12                	jae    800a68 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	75 06                	jne    800a63 <memfind+0x1c>
  800a5d:	eb 09                	jmp    800a68 <memfind+0x21>
  800a5f:	38 08                	cmp    %cl,(%eax)
  800a61:	74 05                	je     800a68 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a63:	40                   	inc    %eax
  800a64:	39 c2                	cmp    %eax,%edx
  800a66:	77 f7                	ja     800a5f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a76:	eb 01                	jmp    800a79 <strtol+0xf>
		s++;
  800a78:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	8a 02                	mov    (%edx),%al
  800a7b:	3c 20                	cmp    $0x20,%al
  800a7d:	74 f9                	je     800a78 <strtol+0xe>
  800a7f:	3c 09                	cmp    $0x9,%al
  800a81:	74 f5                	je     800a78 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a83:	3c 2b                	cmp    $0x2b,%al
  800a85:	75 08                	jne    800a8f <strtol+0x25>
		s++;
  800a87:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	eb 13                	jmp    800aa2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8f:	3c 2d                	cmp    $0x2d,%al
  800a91:	75 0a                	jne    800a9d <strtol+0x33>
		s++, neg = 1;
  800a93:	8d 52 01             	lea    0x1(%edx),%edx
  800a96:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9b:	eb 05                	jmp    800aa2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 05                	je     800aab <strtol+0x41>
  800aa6:	83 fb 10             	cmp    $0x10,%ebx
  800aa9:	75 28                	jne    800ad3 <strtol+0x69>
  800aab:	8a 02                	mov    (%edx),%al
  800aad:	3c 30                	cmp    $0x30,%al
  800aaf:	75 10                	jne    800ac1 <strtol+0x57>
  800ab1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab5:	75 0a                	jne    800ac1 <strtol+0x57>
		s += 2, base = 16;
  800ab7:	83 c2 02             	add    $0x2,%edx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb 12                	jmp    800ad3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	75 0e                	jne    800ad3 <strtol+0x69>
  800ac5:	3c 30                	cmp    $0x30,%al
  800ac7:	75 05                	jne    800ace <strtol+0x64>
		s++, base = 8;
  800ac9:	42                   	inc    %edx
  800aca:	b3 08                	mov    $0x8,%bl
  800acc:	eb 05                	jmp    800ad3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ace:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ada:	8a 0a                	mov    (%edx),%cl
  800adc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	77 08                	ja     800aec <strtol+0x82>
			dig = *s - '0';
  800ae4:	0f be c9             	movsbl %cl,%ecx
  800ae7:	83 e9 30             	sub    $0x30,%ecx
  800aea:	eb 1e                	jmp    800b0a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 08                	ja     800afc <strtol+0x92>
			dig = *s - 'a' + 10;
  800af4:	0f be c9             	movsbl %cl,%ecx
  800af7:	83 e9 57             	sub    $0x57,%ecx
  800afa:	eb 0e                	jmp    800b0a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 13                	ja     800b17 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b04:	0f be c9             	movsbl %cl,%ecx
  800b07:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0a:	39 f1                	cmp    %esi,%ecx
  800b0c:	7d 0d                	jge    800b1b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b0e:	42                   	inc    %edx
  800b0f:	0f af c6             	imul   %esi,%eax
  800b12:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b15:	eb c3                	jmp    800ada <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	89 c1                	mov    %eax,%ecx
  800b19:	eb 02                	jmp    800b1d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b21:	74 05                	je     800b28 <strtol+0xbe>
		*endptr = (char *) s;
  800b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b26:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b28:	85 ff                	test   %edi,%edi
  800b2a:	74 04                	je     800b30 <strtol+0xc6>
  800b2c:	89 c8                	mov    %ecx,%eax
  800b2e:	f7 d8                	neg    %eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    
  800b35:	00 00                	add    %al,(%eax)
	...

00800b38 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	83 ec 10             	sub    $0x10,%esp
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b46:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b4c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b4f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b52:	85 c0                	test   %eax,%eax
  800b54:	75 2e                	jne    800b84 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b56:	39 f1                	cmp    %esi,%ecx
  800b58:	77 5a                	ja     800bb4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b5a:	85 c9                	test   %ecx,%ecx
  800b5c:	75 0b                	jne    800b69 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b63:	31 d2                	xor    %edx,%edx
  800b65:	f7 f1                	div    %ecx
  800b67:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b69:	31 d2                	xor    %edx,%edx
  800b6b:	89 f0                	mov    %esi,%eax
  800b6d:	f7 f1                	div    %ecx
  800b6f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b71:	89 f8                	mov    %edi,%eax
  800b73:	f7 f1                	div    %ecx
  800b75:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b77:	89 f8                	mov    %edi,%eax
  800b79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    
  800b82:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b84:	39 f0                	cmp    %esi,%eax
  800b86:	77 1c                	ja     800ba4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b88:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b8b:	83 f7 1f             	xor    $0x1f,%edi
  800b8e:	75 3c                	jne    800bcc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b90:	39 f0                	cmp    %esi,%eax
  800b92:	0f 82 90 00 00 00    	jb     800c28 <__udivdi3+0xf0>
  800b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b9b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800b9e:	0f 86 84 00 00 00    	jbe    800c28 <__udivdi3+0xf0>
  800ba4:	31 f6                	xor    %esi,%esi
  800ba6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ba8:	89 f8                	mov    %edi,%eax
  800baa:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    
  800bb3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bb4:	89 f2                	mov    %esi,%edx
  800bb6:	89 f8                	mov    %edi,%eax
  800bb8:	f7 f1                	div    %ecx
  800bba:	89 c7                	mov    %eax,%edi
  800bbc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bbe:	89 f8                	mov    %edi,%eax
  800bc0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    
  800bc9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bcc:	89 f9                	mov    %edi,%ecx
  800bce:	d3 e0                	shl    %cl,%eax
  800bd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bd3:	b8 20 00 00 00       	mov    $0x20,%eax
  800bd8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdd:	88 c1                	mov    %al,%cl
  800bdf:	d3 ea                	shr    %cl,%edx
  800be1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800be4:	09 ca                	or     %ecx,%edx
  800be6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800be9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bec:	89 f9                	mov    %edi,%ecx
  800bee:	d3 e2                	shl    %cl,%edx
  800bf0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800bf3:	89 f2                	mov    %esi,%edx
  800bf5:	88 c1                	mov    %al,%cl
  800bf7:	d3 ea                	shr    %cl,%edx
  800bf9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800bfc:	89 f2                	mov    %esi,%edx
  800bfe:	89 f9                	mov    %edi,%ecx
  800c00:	d3 e2                	shl    %cl,%edx
  800c02:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ee                	shr    %cl,%esi
  800c09:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c0b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	89 ca                	mov    %ecx,%edx
  800c12:	f7 75 ec             	divl   -0x14(%ebp)
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c19:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c1c:	39 d1                	cmp    %edx,%ecx
  800c1e:	72 28                	jb     800c48 <__udivdi3+0x110>
  800c20:	74 1a                	je     800c3c <__udivdi3+0x104>
  800c22:	89 f7                	mov    %esi,%edi
  800c24:	31 f6                	xor    %esi,%esi
  800c26:	eb 80                	jmp    800ba8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c28:	31 f6                	xor    %esi,%esi
  800c2a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c2f:	89 f8                	mov    %edi,%eax
  800c31:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    
  800c3a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c3f:	89 f9                	mov    %edi,%ecx
  800c41:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c43:	39 c2                	cmp    %eax,%edx
  800c45:	73 db                	jae    800c22 <__udivdi3+0xea>
  800c47:	90                   	nop
		{
		  q0--;
  800c48:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c4b:	31 f6                	xor    %esi,%esi
  800c4d:	e9 56 ff ff ff       	jmp    800ba8 <__udivdi3+0x70>
	...

00800c54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	83 ec 20             	sub    $0x20,%esp
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c62:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c65:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c71:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c73:	85 ff                	test   %edi,%edi
  800c75:	75 15                	jne    800c8c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c77:	39 f1                	cmp    %esi,%ecx
  800c79:	0f 86 99 00 00 00    	jbe    800d18 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c7f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c81:	89 d0                	mov    %edx,%eax
  800c83:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c85:	83 c4 20             	add    $0x20,%esp
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c8c:	39 f7                	cmp    %esi,%edi
  800c8e:	0f 87 a4 00 00 00    	ja     800d38 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c94:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800c97:	83 f0 1f             	xor    $0x1f,%eax
  800c9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9d:	0f 84 a1 00 00 00    	je     800d44 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ca8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800caa:	bf 20 00 00 00       	mov    $0x20,%edi
  800caf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb5:	89 f9                	mov    %edi,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	09 c2                	or     %eax,%edx
  800cbb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc4:	d3 e0                	shl    %cl,%eax
  800cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cc9:	89 f2                	mov    %esi,%edx
  800ccb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ccd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cd0:	d3 e0                	shl    %cl,%eax
  800cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cd8:	89 f9                	mov    %edi,%ecx
  800cda:	d3 e8                	shr    %cl,%eax
  800cdc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cde:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ce0:	89 f2                	mov    %esi,%edx
  800ce2:	f7 75 f0             	divl   -0x10(%ebp)
  800ce5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ce7:	f7 65 f4             	mull   -0xc(%ebp)
  800cea:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ced:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cef:	39 d6                	cmp    %edx,%esi
  800cf1:	72 71                	jb     800d64 <__umoddi3+0x110>
  800cf3:	74 7f                	je     800d74 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800cf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf8:	29 c8                	sub    %ecx,%eax
  800cfa:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800cfc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cff:	d3 e8                	shr    %cl,%eax
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	89 f9                	mov    %edi,%ecx
  800d05:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d07:	09 d0                	or     %edx,%eax
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d0e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d10:	83 c4 20             	add    $0x20,%esp
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    
  800d17:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d18:	85 c9                	test   %ecx,%ecx
  800d1a:	75 0b                	jne    800d27 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	f7 f1                	div    %ecx
  800d25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d27:	89 f0                	mov    %esi,%eax
  800d29:	31 d2                	xor    %edx,%edx
  800d2b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d30:	f7 f1                	div    %ecx
  800d32:	e9 4a ff ff ff       	jmp    800c81 <__umoddi3+0x2d>
  800d37:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d38:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d3a:	83 c4 20             	add    $0x20,%esp
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    
  800d41:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d44:	39 f7                	cmp    %esi,%edi
  800d46:	72 05                	jb     800d4d <__umoddi3+0xf9>
  800d48:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d4b:	77 0c                	ja     800d59 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d52:	29 c8                	sub    %ecx,%eax
  800d54:	19 fa                	sbb    %edi,%edx
  800d56:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d5c:	83 c4 20             	add    $0x20,%esp
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    
  800d63:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d64:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d67:	89 c1                	mov    %eax,%ecx
  800d69:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d6c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d6f:	eb 84                	jmp    800cf5 <__umoddi3+0xa1>
  800d71:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d74:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d77:	72 eb                	jb     800d64 <__umoddi3+0x110>
  800d79:	89 f2                	mov    %esi,%edx
  800d7b:	e9 75 ff ff ff       	jmp    800cf5 <__umoddi3+0xa1>
