
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 65 00 00 00       	call   8000a8 <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800053:	e8 ce 00 00 00       	call   800126 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x30>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	53                   	push   %ebx
  80007c:	56                   	push   %esi
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 0d 00 00 00       	call   800094 <exit>
  800087:	83 c4 10             	add    $0x10,%esp
}
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	c9                   	leave  
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 44 00 00 00       	call   8000e5 <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 17                	jle    80011e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 a6 0d 80 00       	push   $0x800da6
  800112:	6a 23                	push   $0x23
  800114:	68 c3 0d 80 00       	push   $0x800dc3
  800119:	e8 2a 00 00 00       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5f                   	pop    %edi
  800124:	c9                   	leave  
  800125:	c3                   	ret    

00800126 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	57                   	push   %edi
  80012a:	56                   	push   %esi
  80012b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	ba 00 00 00 00       	mov    $0x0,%edx
  800131:	b8 02 00 00 00       	mov    $0x2,%eax
  800136:	89 d1                	mov    %edx,%ecx
  800138:	89 d3                	mov    %edx,%ebx
  80013a:	89 d7                	mov    %edx,%edi
  80013c:	89 d6                	mov    %edx,%esi
  80013e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5f                   	pop    %edi
  800143:	c9                   	leave  
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
	...

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800156:	e8 cb ff ff ff       	call   800126 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	53                   	push   %ebx
  800165:	50                   	push   %eax
  800166:	68 d4 0d 80 00       	push   $0x800dd4
  80016b:	e8 b0 00 00 00       	call   800220 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	56                   	push   %esi
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 53 00 00 00       	call   8001cf <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 f8 0d 80 00 	movl   $0x800df8,(%esp)
  800183:	e8 98 00 00 00       	call   800220 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>
	...

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 04             	sub    $0x4,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 03                	mov    (%ebx),%eax
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001a3:	40                   	inc    %eax
  8001a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	75 1a                	jne    8001c7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	68 ff 00 00 00       	push   $0xff
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	50                   	push   %eax
  8001b9:	e8 ea fe ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8001be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ec:	ff 75 0c             	pushl  0xc(%ebp)
  8001ef:	ff 75 08             	pushl  0x8(%ebp)
  8001f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	68 90 01 80 00       	push   $0x800190
  8001fe:	e8 82 01 00 00       	call   800385 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800203:	83 c4 08             	add    $0x8,%esp
  800206:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	e8 90 fe ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800218:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800226:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 08             	pushl  0x8(%ebp)
  80022d:	e8 9d ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 2c             	sub    $0x2c,%esp
  80023d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800240:	89 d6                	mov    %edx,%esi
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	8b 55 0c             	mov    0xc(%ebp),%edx
  800248:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800254:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800257:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80025a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800261:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800264:	72 0c                	jb     800272 <printnum+0x3e>
  800266:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800269:	76 07                	jbe    800272 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026b:	4b                   	dec    %ebx
  80026c:	85 db                	test   %ebx,%ebx
  80026e:	7f 31                	jg     8002a1 <printnum+0x6d>
  800270:	eb 3f                	jmp    8002b1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	57                   	push   %edi
  800276:	4b                   	dec    %ebx
  800277:	53                   	push   %ebx
  800278:	50                   	push   %eax
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027f:	ff 75 d0             	pushl  -0x30(%ebp)
  800282:	ff 75 dc             	pushl  -0x24(%ebp)
  800285:	ff 75 d8             	pushl  -0x28(%ebp)
  800288:	e8 c7 08 00 00       	call   800b54 <__udivdi3>
  80028d:	83 c4 18             	add    $0x18,%esp
  800290:	52                   	push   %edx
  800291:	50                   	push   %eax
  800292:	89 f2                	mov    %esi,%edx
  800294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800297:	e8 98 ff ff ff       	call   800234 <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 10                	jmp    8002b1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	57                   	push   %edi
  8002a6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a9:	4b                   	dec    %ebx
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f f0                	jg     8002a1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 a7 09 00 00       	call   800c70 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 fa 0d 80 00 	movsbl 0x800dfa(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff 55 e4             	call   *-0x1c(%ebp)
  8002d7:	83 c4 10             	add    $0x10,%esp
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031f:	83 fa 01             	cmp    $0x1,%edx
  800322:	7e 0e                	jle    800332 <getint+0x16>
		return va_arg(*ap, long long);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 08             	lea    0x8(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	8b 52 04             	mov    0x4(%edx),%edx
  800330:	eb 1a                	jmp    80034c <getint+0x30>
	else if (lflag)
  800332:	85 d2                	test   %edx,%edx
  800334:	74 0c                	je     800342 <getint+0x26>
		return va_arg(*ap, long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
  800340:	eb 0a                	jmp    80034c <getint+0x30>
	else
		return va_arg(*ap, int);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	99                   	cltd   
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800354:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800357:	8b 10                	mov    (%eax),%edx
  800359:	3b 50 04             	cmp    0x4(%eax),%edx
  80035c:	73 08                	jae    800366 <sprintputch+0x18>
		*b->buf++ = ch;
  80035e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800361:	88 0a                	mov    %cl,(%edx)
  800363:	42                   	inc    %edx
  800364:	89 10                	mov    %edx,(%eax)
}
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800371:	50                   	push   %eax
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	ff 75 0c             	pushl  0xc(%ebp)
  800378:	ff 75 08             	pushl  0x8(%ebp)
  80037b:	e8 05 00 00 00       	call   800385 <vprintfmt>
	va_end(ap);
  800380:	83 c4 10             	add    $0x10,%esp
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 2c             	sub    $0x2c,%esp
  80038e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800391:	8b 75 10             	mov    0x10(%ebp),%esi
  800394:	eb 13                	jmp    8003a9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800396:	85 c0                	test   %eax,%eax
  800398:	0f 84 6d 03 00 00    	je     80070b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80039e:	83 ec 08             	sub    $0x8,%esp
  8003a1:	57                   	push   %edi
  8003a2:	50                   	push   %eax
  8003a3:	ff 55 08             	call   *0x8(%ebp)
  8003a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	0f b6 06             	movzbl (%esi),%eax
  8003ac:	46                   	inc    %esi
  8003ad:	83 f8 25             	cmp    $0x25,%eax
  8003b0:	75 e4                	jne    800396 <vprintfmt+0x11>
  8003b2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003b6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003bd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003c4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d0:	eb 28                	jmp    8003fa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003d8:	eb 20                	jmp    8003fa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003dc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003e0:	eb 18                	jmp    8003fa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003eb:	eb 0d                	jmp    8003fa <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8a 06                	mov    (%esi),%al
  8003fc:	0f b6 d0             	movzbl %al,%edx
  8003ff:	8d 5e 01             	lea    0x1(%esi),%ebx
  800402:	83 e8 23             	sub    $0x23,%eax
  800405:	3c 55                	cmp    $0x55,%al
  800407:	0f 87 e0 02 00 00    	ja     8006ed <vprintfmt+0x368>
  80040d:	0f b6 c0             	movzbl %al,%eax
  800410:	ff 24 85 88 0e 80 00 	jmp    *0x800e88(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	83 ea 30             	sub    $0x30,%edx
  80041a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80041d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800420:	8d 50 d0             	lea    -0x30(%eax),%edx
  800423:	83 fa 09             	cmp    $0x9,%edx
  800426:	77 44                	ja     80046c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	89 de                	mov    %ebx,%esi
  80042a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80042e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800431:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800435:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800438:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80043b:	83 fb 09             	cmp    $0x9,%ebx
  80043e:	76 ed                	jbe    80042d <vprintfmt+0xa8>
  800440:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800443:	eb 29                	jmp    80046e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800455:	eb 17                	jmp    80046e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800457:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045b:	78 85                	js     8003e2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	89 de                	mov    %ebx,%esi
  80045f:	eb 99                	jmp    8003fa <vprintfmt+0x75>
  800461:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800463:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80046a:	eb 8e                	jmp    8003fa <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80046e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800472:	79 86                	jns    8003fa <vprintfmt+0x75>
  800474:	e9 74 ff ff ff       	jmp    8003ed <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800479:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 de                	mov    %ebx,%esi
  80047c:	e9 79 ff ff ff       	jmp    8003fa <vprintfmt+0x75>
  800481:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	57                   	push   %edi
  800491:	ff 30                	pushl  (%eax)
  800493:	ff 55 08             	call   *0x8(%ebp)
			break;
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049c:	e9 08 ff ff ff       	jmp    8003a9 <vprintfmt+0x24>
  8004a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 02                	jns    8004b5 <vprintfmt+0x130>
  8004b3:	f7 d8                	neg    %eax
  8004b5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b7:	83 f8 06             	cmp    $0x6,%eax
  8004ba:	7f 0b                	jg     8004c7 <vprintfmt+0x142>
  8004bc:	8b 04 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%eax
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	75 1a                	jne    8004e1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	52                   	push   %edx
  8004c8:	68 12 0e 80 00       	push   $0x800e12
  8004cd:	57                   	push   %edi
  8004ce:	ff 75 08             	pushl  0x8(%ebp)
  8004d1:	e8 92 fe ff ff       	call   800368 <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004dc:	e9 c8 fe ff ff       	jmp    8003a9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004e1:	50                   	push   %eax
  8004e2:	68 1b 0e 80 00       	push   $0x800e1b
  8004e7:	57                   	push   %edi
  8004e8:	ff 75 08             	pushl  0x8(%ebp)
  8004eb:	e8 78 fe ff ff       	call   800368 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004f6:	e9 ae fe ff ff       	jmp    8003a9 <vprintfmt+0x24>
  8004fb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004fe:	89 de                	mov    %ebx,%esi
  800500:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800503:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800514:	85 c0                	test   %eax,%eax
  800516:	75 07                	jne    80051f <vprintfmt+0x19a>
				p = "(null)";
  800518:	c7 45 d0 0b 0e 80 00 	movl   $0x800e0b,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80051f:	85 db                	test   %ebx,%ebx
  800521:	7e 42                	jle    800565 <vprintfmt+0x1e0>
  800523:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800527:	74 3c                	je     800565 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	51                   	push   %ecx
  80052d:	ff 75 d0             	pushl  -0x30(%ebp)
  800530:	e8 6f 02 00 00       	call   8007a4 <strnlen>
  800535:	29 c3                	sub    %eax,%ebx
  800537:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 db                	test   %ebx,%ebx
  80053f:	7e 24                	jle    800565 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800541:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800545:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800548:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	57                   	push   %edi
  80054f:	53                   	push   %ebx
  800550:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	4e                   	dec    %esi
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	85 f6                	test   %esi,%esi
  800559:	7f f0                	jg     80054b <vprintfmt+0x1c6>
  80055b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80055e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800565:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800568:	0f be 02             	movsbl (%edx),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 47                	jne    8005b6 <vprintfmt+0x231>
  80056f:	eb 37                	jmp    8005a8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800575:	74 16                	je     80058d <vprintfmt+0x208>
  800577:	8d 50 e0             	lea    -0x20(%eax),%edx
  80057a:	83 fa 5e             	cmp    $0x5e,%edx
  80057d:	76 0e                	jbe    80058d <vprintfmt+0x208>
					putch('?', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	6a 3f                	push   $0x3f
  800585:	ff 55 08             	call   *0x8(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb 0b                	jmp    800598 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	57                   	push   %edi
  800591:	50                   	push   %eax
  800592:	ff 55 08             	call   *0x8(%ebp)
  800595:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800598:	ff 4d e4             	decl   -0x1c(%ebp)
  80059b:	0f be 03             	movsbl (%ebx),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 03                	je     8005a5 <vprintfmt+0x220>
  8005a2:	43                   	inc    %ebx
  8005a3:	eb 1b                	jmp    8005c0 <vprintfmt+0x23b>
  8005a5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ac:	7f 1e                	jg     8005cc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005b1:	e9 f3 fd ff ff       	jmp    8003a9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b9:	43                   	inc    %ebx
  8005ba:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005c0:	85 f6                	test   %esi,%esi
  8005c2:	78 ad                	js     800571 <vprintfmt+0x1ec>
  8005c4:	4e                   	dec    %esi
  8005c5:	79 aa                	jns    800571 <vprintfmt+0x1ec>
  8005c7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ca:	eb dc                	jmp    8005a8 <vprintfmt+0x223>
  8005cc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	57                   	push   %edi
  8005d3:	6a 20                	push   $0x20
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d8:	4b                   	dec    %ebx
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	85 db                	test   %ebx,%ebx
  8005de:	7f ef                	jg     8005cf <vprintfmt+0x24a>
  8005e0:	e9 c4 fd ff ff       	jmp    8003a9 <vprintfmt+0x24>
  8005e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e8:	89 ca                	mov    %ecx,%edx
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	e8 2a fd ff ff       	call   80031c <getint>
  8005f2:	89 c3                	mov    %eax,%ebx
  8005f4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	78 0a                	js     800604 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	e9 b0 00 00 00       	jmp    8006b4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	57                   	push   %edi
  800608:	6a 2d                	push   $0x2d
  80060a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060d:	f7 db                	neg    %ebx
  80060f:	83 d6 00             	adc    $0x0,%esi
  800612:	f7 de                	neg    %esi
  800614:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061c:	e9 93 00 00 00       	jmp    8006b4 <vprintfmt+0x32f>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 b4 fc ff ff       	call   8002e2 <getuint>
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	89 d6                	mov    %edx,%esi
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800637:	eb 7b                	jmp    8006b4 <vprintfmt+0x32f>
  800639:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80063c:	89 ca                	mov    %ecx,%edx
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 d6 fc ff ff       	call   80031c <getint>
  800646:	89 c3                	mov    %eax,%ebx
  800648:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80064a:	85 d2                	test   %edx,%edx
  80064c:	78 07                	js     800655 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80064e:	b8 08 00 00 00       	mov    $0x8,%eax
  800653:	eb 5f                	jmp    8006b4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	57                   	push   %edi
  800659:	6a 2d                	push   $0x2d
  80065b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80065e:	f7 db                	neg    %ebx
  800660:	83 d6 00             	adc    $0x0,%esi
  800663:	f7 de                	neg    %esi
  800665:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800668:	b8 08 00 00 00       	mov    $0x8,%eax
  80066d:	eb 45                	jmp    8006b4 <vprintfmt+0x32f>
  80066f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	57                   	push   %edi
  800676:	6a 30                	push   $0x30
  800678:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067b:	83 c4 08             	add    $0x8,%esp
  80067e:	57                   	push   %edi
  80067f:	6a 78                	push   $0x78
  800681:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 18                	mov    (%eax),%ebx
  80068f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800694:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069c:	eb 16                	jmp    8006b4 <vprintfmt+0x32f>
  80069e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 37 fc ff ff       	call   8002e2 <getuint>
  8006ab:	89 c3                	mov    %eax,%ebx
  8006ad:	89 d6                	mov    %edx,%esi
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006bb:	52                   	push   %edx
  8006bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006bf:	50                   	push   %eax
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	89 fa                	mov    %edi,%edx
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	e8 68 fb ff ff       	call   800234 <printnum>
			break;
  8006cc:	83 c4 20             	add    $0x20,%esp
  8006cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006d2:	e9 d2 fc ff ff       	jmp    8003a9 <vprintfmt+0x24>
  8006d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	57                   	push   %edi
  8006de:	52                   	push   %edx
  8006df:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e8:	e9 bc fc ff ff       	jmp    8003a9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	57                   	push   %edi
  8006f1:	6a 25                	push   $0x25
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 02                	jmp    8006fd <vprintfmt+0x378>
  8006fb:	89 c6                	mov    %eax,%esi
  8006fd:	8d 46 ff             	lea    -0x1(%esi),%eax
  800700:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800704:	75 f5                	jne    8006fb <vprintfmt+0x376>
  800706:	e9 9e fc ff ff       	jmp    8003a9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80070b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070e:	5b                   	pop    %ebx
  80070f:	5e                   	pop    %esi
  800710:	5f                   	pop    %edi
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	83 ec 18             	sub    $0x18,%esp
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800722:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800726:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800730:	85 c0                	test   %eax,%eax
  800732:	74 26                	je     80075a <vsnprintf+0x47>
  800734:	85 d2                	test   %edx,%edx
  800736:	7e 29                	jle    800761 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800738:	ff 75 14             	pushl  0x14(%ebp)
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	68 4e 03 80 00       	push   $0x80034e
  800747:	e8 39 fc ff ff       	call   800385 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 0c                	jmp    800766 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075f:	eb 05                	jmp    800766 <vsnprintf+0x53>
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	50                   	push   %eax
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	e8 93 ff ff ff       	call   800713 <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    
	...

00800784 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3a 00             	cmpb   $0x0,(%edx)
  80078d:	74 0e                	je     80079d <strlen+0x19>
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800794:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f9                	jne    800794 <strlen+0x10>
  80079b:	eb 05                	jmp    8007a2 <strlen+0x1e>
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 17                	je     8007c8 <strnlen+0x24>
  8007b1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b4:	74 19                	je     8007cf <strnlen+0x2b>
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007bb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	39 d0                	cmp    %edx,%eax
  8007be:	74 14                	je     8007d4 <strnlen+0x30>
  8007c0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c4:	75 f5                	jne    8007bb <strnlen+0x17>
  8007c6:	eb 0c                	jmp    8007d4 <strnlen+0x30>
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	eb 05                	jmp    8007d4 <strnlen+0x30>
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007e8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007eb:	42                   	inc    %edx
  8007ec:	84 c9                	test   %cl,%cl
  8007ee:	75 f5                	jne    8007e5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	53                   	push   %ebx
  8007fb:	e8 84 ff ff ff       	call   800784 <strlen>
  800800:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800809:	50                   	push   %eax
  80080a:	e8 c7 ff ff ff       	call   8007d6 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	85 f6                	test   %esi,%esi
  800826:	74 15                	je     80083d <strncpy+0x27>
  800828:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80082d:	8a 1a                	mov    (%edx),%bl
  80082f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800832:	80 3a 01             	cmpb   $0x1,(%edx)
  800835:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	41                   	inc    %ecx
  800839:	39 ce                	cmp    %ecx,%esi
  80083b:	77 f0                	ja     80082d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800850:	85 f6                	test   %esi,%esi
  800852:	74 32                	je     800886 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800854:	83 fe 01             	cmp    $0x1,%esi
  800857:	74 22                	je     80087b <strlcpy+0x3a>
  800859:	8a 0b                	mov    (%ebx),%cl
  80085b:	84 c9                	test   %cl,%cl
  80085d:	74 20                	je     80087f <strlcpy+0x3e>
  80085f:	89 f8                	mov    %edi,%eax
  800861:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800866:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800869:	88 08                	mov    %cl,(%eax)
  80086b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	39 f2                	cmp    %esi,%edx
  80086e:	74 11                	je     800881 <strlcpy+0x40>
  800870:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800874:	42                   	inc    %edx
  800875:	84 c9                	test   %cl,%cl
  800877:	75 f0                	jne    800869 <strlcpy+0x28>
  800879:	eb 06                	jmp    800881 <strlcpy+0x40>
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	eb 02                	jmp    800881 <strlcpy+0x40>
  80087f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 00 00             	movb   $0x0,(%eax)
  800884:	eb 02                	jmp    800888 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800888:	29 f8                	sub    %edi,%eax
}
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5f                   	pop    %edi
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800898:	8a 01                	mov    (%ecx),%al
  80089a:	84 c0                	test   %al,%al
  80089c:	74 10                	je     8008ae <strcmp+0x1f>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	75 0c                	jne    8008ae <strcmp+0x1f>
		p++, q++;
  8008a2:	41                   	inc    %ecx
  8008a3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a4:	8a 01                	mov    (%ecx),%al
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 04                	je     8008ae <strcmp+0x1f>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	74 f4                	je     8008a2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 c0             	movzbl %al,%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 1b                	je     8008e4 <strncmp+0x2c>
  8008c9:	8a 1a                	mov    (%edx),%bl
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	74 24                	je     8008f3 <strncmp+0x3b>
  8008cf:	3a 19                	cmp    (%ecx),%bl
  8008d1:	75 20                	jne    8008f3 <strncmp+0x3b>
  8008d3:	48                   	dec    %eax
  8008d4:	74 15                	je     8008eb <strncmp+0x33>
		n--, p++, q++;
  8008d6:	42                   	inc    %edx
  8008d7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	8a 1a                	mov    (%edx),%bl
  8008da:	84 db                	test   %bl,%bl
  8008dc:	74 15                	je     8008f3 <strncmp+0x3b>
  8008de:	3a 19                	cmp    (%ecx),%bl
  8008e0:	74 f1                	je     8008d3 <strncmp+0x1b>
  8008e2:	eb 0f                	jmp    8008f3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	eb 05                	jmp    8008f0 <strncmp+0x38>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 02             	movzbl (%edx),%eax
  8008f6:	0f b6 11             	movzbl (%ecx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
  8008fb:	eb f3                	jmp    8008f0 <strncmp+0x38>

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800906:	8a 10                	mov    (%eax),%dl
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 18                	je     800924 <strchr+0x27>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	75 06                	jne    800916 <strchr+0x19>
  800910:	eb 17                	jmp    800929 <strchr+0x2c>
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 13                	je     800929 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800916:	40                   	inc    %eax
  800917:	8a 10                	mov    (%eax),%dl
  800919:	84 d2                	test   %dl,%dl
  80091b:	75 f5                	jne    800912 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb 05                	jmp    800929 <strchr+0x2c>
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800934:	8a 10                	mov    (%eax),%dl
  800936:	84 d2                	test   %dl,%dl
  800938:	74 11                	je     80094b <strfind+0x20>
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	75 06                	jne    800944 <strfind+0x19>
  80093e:	eb 0b                	jmp    80094b <strfind+0x20>
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 07                	je     80094b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800944:	40                   	inc    %eax
  800945:	8a 10                	mov    (%eax),%dl
  800947:	84 d2                	test   %dl,%dl
  800949:	75 f5                	jne    800940 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 7d 08             	mov    0x8(%ebp),%edi
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	74 30                	je     800990 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800960:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800966:	75 25                	jne    80098d <memset+0x40>
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	75 20                	jne    80098d <memset+0x40>
		c &= 0xFF;
  80096d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800970:	89 d3                	mov    %edx,%ebx
  800972:	c1 e3 08             	shl    $0x8,%ebx
  800975:	89 d6                	mov    %edx,%esi
  800977:	c1 e6 18             	shl    $0x18,%esi
  80097a:	89 d0                	mov    %edx,%eax
  80097c:	c1 e0 10             	shl    $0x10,%eax
  80097f:	09 f0                	or     %esi,%eax
  800981:	09 d0                	or     %edx,%eax
  800983:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800985:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800988:	fc                   	cld    
  800989:	f3 ab                	rep stos %eax,%es:(%edi)
  80098b:	eb 03                	jmp    800990 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098d:	fc                   	cld    
  80098e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800990:	89 f8                	mov    %edi,%eax
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a5:	39 c6                	cmp    %eax,%esi
  8009a7:	73 34                	jae    8009dd <memmove+0x46>
  8009a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ac:	39 d0                	cmp    %edx,%eax
  8009ae:	73 2d                	jae    8009dd <memmove+0x46>
		s += n;
		d += n;
  8009b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	f6 c2 03             	test   $0x3,%dl
  8009b6:	75 1b                	jne    8009d3 <memmove+0x3c>
  8009b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009be:	75 13                	jne    8009d3 <memmove+0x3c>
  8009c0:	f6 c1 03             	test   $0x3,%cl
  8009c3:	75 0e                	jne    8009d3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c5:	83 ef 04             	sub    $0x4,%edi
  8009c8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ce:	fd                   	std    
  8009cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d1:	eb 07                	jmp    8009da <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d3:	4f                   	dec    %edi
  8009d4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009da:	fc                   	cld    
  8009db:	eb 20                	jmp    8009fd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e3:	75 13                	jne    8009f8 <memmove+0x61>
  8009e5:	a8 03                	test   $0x3,%al
  8009e7:	75 0f                	jne    8009f8 <memmove+0x61>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	ff 75 08             	pushl  0x8(%ebp)
  800a0d:	e8 85 ff ff ff       	call   800997 <memmove>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a20:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	85 ff                	test   %edi,%edi
  800a25:	74 32                	je     800a59 <memcmp+0x45>
		if (*s1 != *s2)
  800a27:	8a 03                	mov    (%ebx),%al
  800a29:	8a 0e                	mov    (%esi),%cl
  800a2b:	38 c8                	cmp    %cl,%al
  800a2d:	74 19                	je     800a48 <memcmp+0x34>
  800a2f:	eb 0d                	jmp    800a3e <memcmp+0x2a>
  800a31:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a35:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a39:	42                   	inc    %edx
  800a3a:	38 c8                	cmp    %cl,%al
  800a3c:	74 10                	je     800a4e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c0             	movzbl %al,%eax
  800a41:	0f b6 c9             	movzbl %cl,%ecx
  800a44:	29 c8                	sub    %ecx,%eax
  800a46:	eb 16                	jmp    800a5e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a48:	4f                   	dec    %edi
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	39 fa                	cmp    %edi,%edx
  800a50:	75 df                	jne    800a31 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	eb 05                	jmp    800a5e <memcmp+0x4a>
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	73 12                	jae    800a84 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a72:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a75:	38 08                	cmp    %cl,(%eax)
  800a77:	75 06                	jne    800a7f <memfind+0x1c>
  800a79:	eb 09                	jmp    800a84 <memfind+0x21>
  800a7b:	38 08                	cmp    %cl,(%eax)
  800a7d:	74 05                	je     800a84 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7f:	40                   	inc    %eax
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	77 f7                	ja     800a7b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a92:	eb 01                	jmp    800a95 <strtol+0xf>
		s++;
  800a94:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 20                	cmp    $0x20,%al
  800a99:	74 f9                	je     800a94 <strtol+0xe>
  800a9b:	3c 09                	cmp    $0x9,%al
  800a9d:	74 f5                	je     800a94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9f:	3c 2b                	cmp    $0x2b,%al
  800aa1:	75 08                	jne    800aab <strtol+0x25>
		s++;
  800aa3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa9:	eb 13                	jmp    800abe <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aab:	3c 2d                	cmp    $0x2d,%al
  800aad:	75 0a                	jne    800ab9 <strtol+0x33>
		s++, neg = 1;
  800aaf:	8d 52 01             	lea    0x1(%edx),%edx
  800ab2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab7:	eb 05                	jmp    800abe <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	74 05                	je     800ac7 <strtol+0x41>
  800ac2:	83 fb 10             	cmp    $0x10,%ebx
  800ac5:	75 28                	jne    800aef <strtol+0x69>
  800ac7:	8a 02                	mov    (%edx),%al
  800ac9:	3c 30                	cmp    $0x30,%al
  800acb:	75 10                	jne    800add <strtol+0x57>
  800acd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad1:	75 0a                	jne    800add <strtol+0x57>
		s += 2, base = 16;
  800ad3:	83 c2 02             	add    $0x2,%edx
  800ad6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adb:	eb 12                	jmp    800aef <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800add:	85 db                	test   %ebx,%ebx
  800adf:	75 0e                	jne    800aef <strtol+0x69>
  800ae1:	3c 30                	cmp    $0x30,%al
  800ae3:	75 05                	jne    800aea <strtol+0x64>
		s++, base = 8;
  800ae5:	42                   	inc    %edx
  800ae6:	b3 08                	mov    $0x8,%bl
  800ae8:	eb 05                	jmp    800aef <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aea:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af6:	8a 0a                	mov    (%edx),%cl
  800af8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800afb:	80 fb 09             	cmp    $0x9,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x82>
			dig = *s - '0';
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 30             	sub    $0x30,%ecx
  800b06:	eb 1e                	jmp    800b26 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b08:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 57             	sub    $0x57,%ecx
  800b16:	eb 0e                	jmp    800b26 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 13                	ja     800b33 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b20:	0f be c9             	movsbl %cl,%ecx
  800b23:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b26:	39 f1                	cmp    %esi,%ecx
  800b28:	7d 0d                	jge    800b37 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b2a:	42                   	inc    %edx
  800b2b:	0f af c6             	imul   %esi,%eax
  800b2e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b31:	eb c3                	jmp    800af6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b33:	89 c1                	mov    %eax,%ecx
  800b35:	eb 02                	jmp    800b39 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b37:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3d:	74 05                	je     800b44 <strtol+0xbe>
		*endptr = (char *) s;
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b42:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b44:	85 ff                	test   %edi,%edi
  800b46:	74 04                	je     800b4c <strtol+0xc6>
  800b48:	89 c8                	mov    %ecx,%eax
  800b4a:	f7 d8                	neg    %eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    
  800b51:	00 00                	add    %al,(%eax)
	...

00800b54 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	83 ec 10             	sub    $0x10,%esp
  800b5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b62:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	75 2e                	jne    800ba0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b72:	39 f1                	cmp    %esi,%ecx
  800b74:	77 5a                	ja     800bd0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b76:	85 c9                	test   %ecx,%ecx
  800b78:	75 0b                	jne    800b85 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7f:	31 d2                	xor    %edx,%edx
  800b81:	f7 f1                	div    %ecx
  800b83:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b85:	31 d2                	xor    %edx,%edx
  800b87:	89 f0                	mov    %esi,%eax
  800b89:	f7 f1                	div    %ecx
  800b8b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b8d:	89 f8                	mov    %edi,%eax
  800b8f:	f7 f1                	div    %ecx
  800b91:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b93:	89 f8                	mov    %edi,%eax
  800b95:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    
  800b9e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ba0:	39 f0                	cmp    %esi,%eax
  800ba2:	77 1c                	ja     800bc0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ba4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800ba7:	83 f7 1f             	xor    $0x1f,%edi
  800baa:	75 3c                	jne    800be8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bac:	39 f0                	cmp    %esi,%eax
  800bae:	0f 82 90 00 00 00    	jb     800c44 <__udivdi3+0xf0>
  800bb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bb7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bba:	0f 86 84 00 00 00    	jbe    800c44 <__udivdi3+0xf0>
  800bc0:	31 f6                	xor    %esi,%esi
  800bc2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc4:	89 f8                	mov    %edi,%eax
  800bc6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    
  800bcf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	89 f8                	mov    %edi,%eax
  800bd4:	f7 f1                	div    %ecx
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bda:	89 f8                	mov    %edi,%eax
  800bdc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800be8:	89 f9                	mov    %edi,%ecx
  800bea:	d3 e0                	shl    %cl,%eax
  800bec:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bef:	b8 20 00 00 00       	mov    $0x20,%eax
  800bf4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf9:	88 c1                	mov    %al,%cl
  800bfb:	d3 ea                	shr    %cl,%edx
  800bfd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c00:	09 ca                	or     %ecx,%edx
  800c02:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c08:	89 f9                	mov    %edi,%ecx
  800c0a:	d3 e2                	shl    %cl,%edx
  800c0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c0f:	89 f2                	mov    %esi,%edx
  800c11:	88 c1                	mov    %al,%cl
  800c13:	d3 ea                	shr    %cl,%edx
  800c15:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c18:	89 f2                	mov    %esi,%edx
  800c1a:	89 f9                	mov    %edi,%ecx
  800c1c:	d3 e2                	shl    %cl,%edx
  800c1e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c21:	88 c1                	mov    %al,%cl
  800c23:	d3 ee                	shr    %cl,%esi
  800c25:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c27:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	89 ca                	mov    %ecx,%edx
  800c2e:	f7 75 ec             	divl   -0x14(%ebp)
  800c31:	89 d1                	mov    %edx,%ecx
  800c33:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c35:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c38:	39 d1                	cmp    %edx,%ecx
  800c3a:	72 28                	jb     800c64 <__udivdi3+0x110>
  800c3c:	74 1a                	je     800c58 <__udivdi3+0x104>
  800c3e:	89 f7                	mov    %esi,%edi
  800c40:	31 f6                	xor    %esi,%esi
  800c42:	eb 80                	jmp    800bc4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c44:	31 f6                	xor    %esi,%esi
  800c46:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c4b:	89 f8                	mov    %edi,%eax
  800c4d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    
  800c56:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5b:	89 f9                	mov    %edi,%ecx
  800c5d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c5f:	39 c2                	cmp    %eax,%edx
  800c61:	73 db                	jae    800c3e <__udivdi3+0xea>
  800c63:	90                   	nop
		{
		  q0--;
  800c64:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c67:	31 f6                	xor    %esi,%esi
  800c69:	e9 56 ff ff ff       	jmp    800bc4 <__udivdi3+0x70>
	...

00800c70 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	83 ec 20             	sub    $0x20,%esp
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c8d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c8f:	85 ff                	test   %edi,%edi
  800c91:	75 15                	jne    800ca8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c93:	39 f1                	cmp    %esi,%ecx
  800c95:	0f 86 99 00 00 00    	jbe    800d34 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c9b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c9d:	89 d0                	mov    %edx,%eax
  800c9f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ca1:	83 c4 20             	add    $0x20,%esp
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ca8:	39 f7                	cmp    %esi,%edi
  800caa:	0f 87 a4 00 00 00    	ja     800d54 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cb3:	83 f0 1f             	xor    $0x1f,%eax
  800cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb9:	0f 84 a1 00 00 00    	je     800d60 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cc6:	bf 20 00 00 00       	mov    $0x20,%edi
  800ccb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 ea                	shr    %cl,%edx
  800cd5:	09 c2                	or     %eax,%edx
  800cd7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ce0:	d3 e0                	shl    %cl,%eax
  800ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cec:	d3 e0                	shl    %cl,%eax
  800cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf4:	89 f9                	mov    %edi,%ecx
  800cf6:	d3 e8                	shr    %cl,%eax
  800cf8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cfa:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cfc:	89 f2                	mov    %esi,%edx
  800cfe:	f7 75 f0             	divl   -0x10(%ebp)
  800d01:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d03:	f7 65 f4             	mull   -0xc(%ebp)
  800d06:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d09:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d0b:	39 d6                	cmp    %edx,%esi
  800d0d:	72 71                	jb     800d80 <__umoddi3+0x110>
  800d0f:	74 7f                	je     800d90 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d14:	29 c8                	sub    %ecx,%eax
  800d16:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d18:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1b:	d3 e8                	shr    %cl,%eax
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d23:	09 d0                	or     %edx,%eax
  800d25:	89 f2                	mov    %esi,%edx
  800d27:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d2a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d2c:	83 c4 20             	add    $0x20,%esp
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    
  800d33:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d34:	85 c9                	test   %ecx,%ecx
  800d36:	75 0b                	jne    800d43 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d38:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3d:	31 d2                	xor    %edx,%edx
  800d3f:	f7 f1                	div    %ecx
  800d41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d43:	89 f0                	mov    %esi,%eax
  800d45:	31 d2                	xor    %edx,%edx
  800d47:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d4c:	f7 f1                	div    %ecx
  800d4e:	e9 4a ff ff ff       	jmp    800c9d <__umoddi3+0x2d>
  800d53:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d54:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d56:	83 c4 20             	add    $0x20,%esp
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d60:	39 f7                	cmp    %esi,%edi
  800d62:	72 05                	jb     800d69 <__umoddi3+0xf9>
  800d64:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d67:	77 0c                	ja     800d75 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d69:	89 f2                	mov    %esi,%edx
  800d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6e:	29 c8                	sub    %ecx,%eax
  800d70:	19 fa                	sbb    %edi,%edx
  800d72:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    
  800d7f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d80:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d83:	89 c1                	mov    %eax,%ecx
  800d85:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d88:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d8b:	eb 84                	jmp    800d11 <__umoddi3+0xa1>
  800d8d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d93:	72 eb                	jb     800d80 <__umoddi3+0x110>
  800d95:	89 f2                	mov    %esi,%edx
  800d97:	e9 75 ff ff ff       	jmp    800d11 <__umoddi3+0xa1>
