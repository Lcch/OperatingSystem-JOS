
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 10 80 00    	pushl  0x801000
  800045:	e8 52 00 00 00       	call   80009c <sys_cputs>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 08             	sub    $0x8,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005c:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 04 10 80 00    	mov    %ecx,0x801004

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	52                   	push   %edx
  800076:	50                   	push   %eax
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 07 00 00 00       	call   800088 <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 44 00 00 00       	call   8000d9 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	89 c3                	mov    %eax,%ebx
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	89 c6                	mov    %eax,%esi
  8000b3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b5:	5b                   	pop    %ebx
  8000b6:	5e                   	pop    %esi
  8000b7:	5f                   	pop    %edi
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ca:	89 d1                	mov    %edx,%ecx
  8000cc:	89 d3                	mov    %edx,%ebx
  8000ce:	89 d7                	mov    %edx,%edi
  8000d0:	89 d6                	mov    %edx,%esi
  8000d2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d4:	5b                   	pop    %ebx
  8000d5:	5e                   	pop    %esi
  8000d6:	5f                   	pop    %edi
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	89 cb                	mov    %ecx,%ebx
  8000f1:	89 cf                	mov    %ecx,%edi
  8000f3:	89 ce                	mov    %ecx,%esi
  8000f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 17                	jle    800112 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	50                   	push   %eax
  8000ff:	6a 03                	push   $0x3
  800101:	68 a8 0d 80 00       	push   $0x800da8
  800106:	6a 23                	push   $0x23
  800108:	68 c5 0d 80 00       	push   $0x800dc5
  80010d:	e8 2a 00 00 00       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 02 00 00 00       	mov    $0x2,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	c9                   	leave  
  800138:	c3                   	ret    
  800139:	00 00                	add    %al,(%eax)
	...

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 1d 04 10 80 00    	mov    0x801004,%ebx
  80014a:	e8 cb ff ff ff       	call   80011a <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	53                   	push   %ebx
  800159:	50                   	push   %eax
  80015a:	68 d4 0d 80 00       	push   $0x800dd4
  80015f:	e8 b0 00 00 00       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	56                   	push   %esi
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 53 00 00 00       	call   8001c3 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 9c 0d 80 00 	movl   $0x800d9c,(%esp)
  800177:	e8 98 00 00 00       	call   800214 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>
	...

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800197:	40                   	inc    %eax
  800198:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 ea fe ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	ff 43 04             	incl   0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 84 01 80 00       	push   $0x800184
  8001f2:	e8 82 01 00 00       	call   800379 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 90 fe ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
  800231:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800242:	8b 45 10             	mov    0x10(%ebp),%eax
  800245:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800248:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80024e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800255:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800258:	72 0c                	jb     800266 <printnum+0x3e>
  80025a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025d:	76 07                	jbe    800266 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f 31                	jg     800295 <printnum+0x6d>
  800264:	eb 3f                	jmp    8002a5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	57                   	push   %edi
  80026a:	4b                   	dec    %ebx
  80026b:	53                   	push   %ebx
  80026c:	50                   	push   %eax
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 d4             	pushl  -0x2c(%ebp)
  800273:	ff 75 d0             	pushl  -0x30(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 c7 08 00 00       	call   800b48 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028b:	e8 98 ff ff ff       	call   800228 <printnum>
  800290:	83 c4 20             	add    $0x20,%esp
  800293:	eb 10                	jmp    8002a5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	57                   	push   %edi
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	4b                   	dec    %ebx
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	7f f0                	jg     800295 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	83 ec 04             	sub    $0x4,%esp
  8002ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002af:	ff 75 d0             	pushl  -0x30(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 a7 09 00 00       	call   800c64 <__umoddi3>
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	0f be 80 f8 0d 80 00 	movsbl 0x800df8(%eax),%eax
  8002c7:	50                   	push   %eax
  8002c8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002cb:	83 c4 10             	add    $0x10,%esp
}
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ea:	eb 22                	jmp    80030e <getuint+0x38>
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	74 10                	je     800300 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 0e                	jmp    80030e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800313:	83 fa 01             	cmp    $0x1,%edx
  800316:	7e 0e                	jle    800326 <getint+0x16>
		return va_arg(*ap, long long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	8b 52 04             	mov    0x4(%edx),%edx
  800324:	eb 1a                	jmp    800340 <getint+0x30>
	else if (lflag)
  800326:	85 d2                	test   %edx,%edx
  800328:	74 0c                	je     800336 <getint+0x26>
		return va_arg(*ap, long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	99                   	cltd   
  800334:	eb 0a                	jmp    800340 <getint+0x30>
	else
		return va_arg(*ap, int);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80034b:	8b 10                	mov    (%eax),%edx
  80034d:	3b 50 04             	cmp    0x4(%eax),%edx
  800350:	73 08                	jae    80035a <sprintputch+0x18>
		*b->buf++ = ch;
  800352:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800355:	88 0a                	mov    %cl,(%edx)
  800357:	42                   	inc    %edx
  800358:	89 10                	mov    %edx,(%eax)
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	50                   	push   %eax
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	ff 75 0c             	pushl  0xc(%ebp)
  80036c:	ff 75 08             	pushl  0x8(%ebp)
  80036f:	e8 05 00 00 00       	call   800379 <vprintfmt>
	va_end(ap);
  800374:	83 c4 10             	add    $0x10,%esp
}
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 2c             	sub    $0x2c,%esp
  800382:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800385:	8b 75 10             	mov    0x10(%ebp),%esi
  800388:	eb 13                	jmp    80039d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038a:	85 c0                	test   %eax,%eax
  80038c:	0f 84 6d 03 00 00    	je     8006ff <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	57                   	push   %edi
  800396:	50                   	push   %eax
  800397:	ff 55 08             	call   *0x8(%ebp)
  80039a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039d:	0f b6 06             	movzbl (%esi),%eax
  8003a0:	46                   	inc    %esi
  8003a1:	83 f8 25             	cmp    $0x25,%eax
  8003a4:	75 e4                	jne    80038a <vprintfmt+0x11>
  8003a6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	eb 28                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003cc:	eb 20                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d4:	eb 18                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003df:	eb 0d                	jmp    8003ee <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8a 06                	mov    (%esi),%al
  8003f0:	0f b6 d0             	movzbl %al,%edx
  8003f3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f6:	83 e8 23             	sub    $0x23,%eax
  8003f9:	3c 55                	cmp    $0x55,%al
  8003fb:	0f 87 e0 02 00 00    	ja     8006e1 <vprintfmt+0x368>
  800401:	0f b6 c0             	movzbl %al,%eax
  800404:	ff 24 85 88 0e 80 00 	jmp    *0x800e88(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040b:	83 ea 30             	sub    $0x30,%edx
  80040e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800411:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800414:	8d 50 d0             	lea    -0x30(%eax),%edx
  800417:	83 fa 09             	cmp    $0x9,%edx
  80041a:	77 44                	ja     800460 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi
  80041e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800422:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800425:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800429:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80042c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80042f:	83 fb 09             	cmp    $0x9,%ebx
  800432:	76 ed                	jbe    800421 <vprintfmt+0xa8>
  800434:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800437:	eb 29                	jmp    800462 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800449:	eb 17                	jmp    800462 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80044b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044f:	78 85                	js     8003d6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	89 de                	mov    %ebx,%esi
  800453:	eb 99                	jmp    8003ee <vprintfmt+0x75>
  800455:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800457:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80045e:	eb 8e                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800462:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800466:	79 86                	jns    8003ee <vprintfmt+0x75>
  800468:	e9 74 ff ff ff       	jmp    8003e1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	89 de                	mov    %ebx,%esi
  800470:	e9 79 ff ff ff       	jmp    8003ee <vprintfmt+0x75>
  800475:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	57                   	push   %edi
  800485:	ff 30                	pushl  (%eax)
  800487:	ff 55 08             	call   *0x8(%ebp)
			break;
  80048a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800490:	e9 08 ff ff ff       	jmp    80039d <vprintfmt+0x24>
  800495:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 02                	jns    8004a9 <vprintfmt+0x130>
  8004a7:	f7 d8                	neg    %eax
  8004a9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 06             	cmp    $0x6,%eax
  8004ae:	7f 0b                	jg     8004bb <vprintfmt+0x142>
  8004b0:	8b 04 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	75 1a                	jne    8004d5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	52                   	push   %edx
  8004bc:	68 10 0e 80 00       	push   $0x800e10
  8004c1:	57                   	push   %edi
  8004c2:	ff 75 08             	pushl  0x8(%ebp)
  8004c5:	e8 92 fe ff ff       	call   80035c <printfmt>
  8004ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d0:	e9 c8 fe ff ff       	jmp    80039d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004d5:	50                   	push   %eax
  8004d6:	68 19 0e 80 00       	push   $0x800e19
  8004db:	57                   	push   %edi
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 78 fe ff ff       	call   80035c <printfmt>
  8004e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ea:	e9 ae fe ff ff       	jmp    80039d <vprintfmt+0x24>
  8004ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004f2:	89 de                	mov    %ebx,%esi
  8004f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	85 c0                	test   %eax,%eax
  80050a:	75 07                	jne    800513 <vprintfmt+0x19a>
				p = "(null)";
  80050c:	c7 45 d0 09 0e 80 00 	movl   $0x800e09,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800513:	85 db                	test   %ebx,%ebx
  800515:	7e 42                	jle    800559 <vprintfmt+0x1e0>
  800517:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80051b:	74 3c                	je     800559 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	51                   	push   %ecx
  800521:	ff 75 d0             	pushl  -0x30(%ebp)
  800524:	e8 6f 02 00 00       	call   800798 <strnlen>
  800529:	29 c3                	sub    %eax,%ebx
  80052b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 db                	test   %ebx,%ebx
  800533:	7e 24                	jle    800559 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800535:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800539:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80053c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	57                   	push   %edi
  800543:	53                   	push   %ebx
  800544:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	4e                   	dec    %esi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	85 f6                	test   %esi,%esi
  80054d:	7f f0                	jg     80053f <vprintfmt+0x1c6>
  80054f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800552:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80055c:	0f be 02             	movsbl (%edx),%eax
  80055f:	85 c0                	test   %eax,%eax
  800561:	75 47                	jne    8005aa <vprintfmt+0x231>
  800563:	eb 37                	jmp    80059c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800565:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800569:	74 16                	je     800581 <vprintfmt+0x208>
  80056b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056e:	83 fa 5e             	cmp    $0x5e,%edx
  800571:	76 0e                	jbe    800581 <vprintfmt+0x208>
					putch('?', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	57                   	push   %edi
  800577:	6a 3f                	push   $0x3f
  800579:	ff 55 08             	call   *0x8(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	57                   	push   %edi
  800585:	50                   	push   %eax
  800586:	ff 55 08             	call   *0x8(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	ff 4d e4             	decl   -0x1c(%ebp)
  80058f:	0f be 03             	movsbl (%ebx),%eax
  800592:	85 c0                	test   %eax,%eax
  800594:	74 03                	je     800599 <vprintfmt+0x220>
  800596:	43                   	inc    %ebx
  800597:	eb 1b                	jmp    8005b4 <vprintfmt+0x23b>
  800599:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a0:	7f 1e                	jg     8005c0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a5:	e9 f3 fd ff ff       	jmp    80039d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ad:	43                   	inc    %ebx
  8005ae:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	78 ad                	js     800565 <vprintfmt+0x1ec>
  8005b8:	4e                   	dec    %esi
  8005b9:	79 aa                	jns    800565 <vprintfmt+0x1ec>
  8005bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005be:	eb dc                	jmp    80059c <vprintfmt+0x223>
  8005c0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 20                	push   $0x20
  8005c9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cc:	4b                   	dec    %ebx
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7f ef                	jg     8005c3 <vprintfmt+0x24a>
  8005d4:	e9 c4 fd ff ff       	jmp    80039d <vprintfmt+0x24>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 2a fd ff ff       	call   800310 <getint>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	78 0a                	js     8005f8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f3:	e9 b0 00 00 00       	jmp    8006a8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	57                   	push   %edi
  8005fc:	6a 2d                	push   $0x2d
  8005fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800601:	f7 db                	neg    %ebx
  800603:	83 d6 00             	adc    $0x0,%esi
  800606:	f7 de                	neg    %esi
  800608:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 93 00 00 00       	jmp    8006a8 <vprintfmt+0x32f>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 b4 fc ff ff       	call   8002d6 <getuint>
  800622:	89 c3                	mov    %eax,%ebx
  800624:	89 d6                	mov    %edx,%esi
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062b:	eb 7b                	jmp    8006a8 <vprintfmt+0x32f>
  80062d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 d6 fc ff ff       	call   800310 <getint>
  80063a:	89 c3                	mov    %eax,%ebx
  80063c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80063e:	85 d2                	test   %edx,%edx
  800640:	78 07                	js     800649 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800642:	b8 08 00 00 00       	mov    $0x8,%eax
  800647:	eb 5f                	jmp    8006a8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800652:	f7 db                	neg    %ebx
  800654:	83 d6 00             	adc    $0x0,%esi
  800657:	f7 de                	neg    %esi
  800659:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
  800661:	eb 45                	jmp    8006a8 <vprintfmt+0x32f>
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	57                   	push   %edi
  80066a:	6a 30                	push   $0x30
  80066c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	57                   	push   %edi
  800673:	6a 78                	push   $0x78
  800675:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800681:	8b 18                	mov    (%eax),%ebx
  800683:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800690:	eb 16                	jmp    8006a8 <vprintfmt+0x32f>
  800692:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 37 fc ff ff       	call   8002d6 <getuint>
  80069f:	89 c3                	mov    %eax,%ebx
  8006a1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006af:	52                   	push   %edx
  8006b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b3:	50                   	push   %eax
  8006b4:	56                   	push   %esi
  8006b5:	53                   	push   %ebx
  8006b6:	89 fa                	mov    %edi,%edx
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	e8 68 fb ff ff       	call   800228 <printnum>
			break;
  8006c0:	83 c4 20             	add    $0x20,%esp
  8006c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006c6:	e9 d2 fc ff ff       	jmp    80039d <vprintfmt+0x24>
  8006cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	57                   	push   %edi
  8006d2:	52                   	push   %edx
  8006d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dc:	e9 bc fc ff ff       	jmp    80039d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	57                   	push   %edi
  8006e5:	6a 25                	push   $0x25
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 02                	jmp    8006f1 <vprintfmt+0x378>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006f4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f8:	75 f5                	jne    8006ef <vprintfmt+0x376>
  8006fa:	e9 9e fc ff ff       	jmp    80039d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 29                	jle    800755 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 42 03 80 00       	push   $0x800342
  80073b:	e8 39 fc ff ff       	call   800379 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 0c                	jmp    80075a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb 05                	jmp    80075a <vsnprintf+0x53>
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800765:	50                   	push   %eax
  800766:	ff 75 10             	pushl  0x10(%ebp)
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 93 ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    
	...

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	80 3a 00             	cmpb   $0x0,(%edx)
  800781:	74 0e                	je     800791 <strlen+0x19>
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800788:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800789:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078d:	75 f9                	jne    800788 <strlen+0x10>
  80078f:	eb 05                	jmp    800796 <strlen+0x1e>
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 17                	je     8007bc <strnlen+0x24>
  8007a5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a8:	74 19                	je     8007c3 <strnlen+0x2b>
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007af:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 d0                	cmp    %edx,%eax
  8007b2:	74 14                	je     8007c8 <strnlen+0x30>
  8007b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b8:	75 f5                	jne    8007af <strnlen+0x17>
  8007ba:	eb 0c                	jmp    8007c8 <strnlen+0x30>
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 05                	jmp    8007c8 <strnlen+0x30>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007dc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007df:	42                   	inc    %edx
  8007e0:	84 c9                	test   %cl,%cl
  8007e2:	75 f5                	jne    8007d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ee:	53                   	push   %ebx
  8007ef:	e8 84 ff ff ff       	call   800778 <strlen>
  8007f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007fd:	50                   	push   %eax
  8007fe:	e8 c7 ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  800803:	89 d8                	mov    %ebx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	85 f6                	test   %esi,%esi
  80081a:	74 15                	je     800831 <strncpy+0x27>
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800821:	8a 1a                	mov    (%edx),%bl
  800823:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800826:	80 3a 01             	cmpb   $0x1,(%edx)
  800829:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	41                   	inc    %ecx
  80082d:	39 ce                	cmp    %ecx,%esi
  80082f:	77 f0                	ja     800821 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800841:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800844:	85 f6                	test   %esi,%esi
  800846:	74 32                	je     80087a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800848:	83 fe 01             	cmp    $0x1,%esi
  80084b:	74 22                	je     80086f <strlcpy+0x3a>
  80084d:	8a 0b                	mov    (%ebx),%cl
  80084f:	84 c9                	test   %cl,%cl
  800851:	74 20                	je     800873 <strlcpy+0x3e>
  800853:	89 f8                	mov    %edi,%eax
  800855:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80085a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085d:	88 08                	mov    %cl,(%eax)
  80085f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800860:	39 f2                	cmp    %esi,%edx
  800862:	74 11                	je     800875 <strlcpy+0x40>
  800864:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800868:	42                   	inc    %edx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 f0                	jne    80085d <strlcpy+0x28>
  80086d:	eb 06                	jmp    800875 <strlcpy+0x40>
  80086f:	89 f8                	mov    %edi,%eax
  800871:	eb 02                	jmp    800875 <strlcpy+0x40>
  800873:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
  800878:	eb 02                	jmp    80087c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80087c:	29 f8                	sub    %edi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5f                   	pop    %edi
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088c:	8a 01                	mov    (%ecx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 10                	je     8008a2 <strcmp+0x1f>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	75 0c                	jne    8008a2 <strcmp+0x1f>
		p++, q++;
  800896:	41                   	inc    %ecx
  800897:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	8a 01                	mov    (%ecx),%al
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1f>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 f4                	je     800896 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	74 1b                	je     8008d8 <strncmp+0x2c>
  8008bd:	8a 1a                	mov    (%edx),%bl
  8008bf:	84 db                	test   %bl,%bl
  8008c1:	74 24                	je     8008e7 <strncmp+0x3b>
  8008c3:	3a 19                	cmp    (%ecx),%bl
  8008c5:	75 20                	jne    8008e7 <strncmp+0x3b>
  8008c7:	48                   	dec    %eax
  8008c8:	74 15                	je     8008df <strncmp+0x33>
		n--, p++, q++;
  8008ca:	42                   	inc    %edx
  8008cb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	8a 1a                	mov    (%edx),%bl
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	74 15                	je     8008e7 <strncmp+0x3b>
  8008d2:	3a 19                	cmp    (%ecx),%bl
  8008d4:	74 f1                	je     8008c7 <strncmp+0x1b>
  8008d6:	eb 0f                	jmp    8008e7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dd:	eb 05                	jmp    8008e4 <strncmp+0x38>
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 02             	movzbl (%edx),%eax
  8008ea:	0f b6 11             	movzbl (%ecx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb f3                	jmp    8008e4 <strncmp+0x38>

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fa:	8a 10                	mov    (%eax),%dl
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	74 18                	je     800918 <strchr+0x27>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	75 06                	jne    80090a <strchr+0x19>
  800904:	eb 17                	jmp    80091d <strchr+0x2c>
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 13                	je     80091d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	40                   	inc    %eax
  80090b:	8a 10                	mov    (%eax),%dl
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f5                	jne    800906 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 05                	jmp    80091d <strchr+0x2c>
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800928:	8a 10                	mov    (%eax),%dl
  80092a:	84 d2                	test   %dl,%dl
  80092c:	74 11                	je     80093f <strfind+0x20>
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	75 06                	jne    800938 <strfind+0x19>
  800932:	eb 0b                	jmp    80093f <strfind+0x20>
  800934:	38 ca                	cmp    %cl,%dl
  800936:	74 07                	je     80093f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800938:	40                   	inc    %eax
  800939:	8a 10                	mov    (%eax),%dl
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f5                	jne    800934 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 30                	je     800984 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 25                	jne    800981 <memset+0x40>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 20                	jne    800981 <memset+0x40>
		c &= 0xFF;
  800961:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800964:	89 d3                	mov    %edx,%ebx
  800966:	c1 e3 08             	shl    $0x8,%ebx
  800969:	89 d6                	mov    %edx,%esi
  80096b:	c1 e6 18             	shl    $0x18,%esi
  80096e:	89 d0                	mov    %edx,%eax
  800970:	c1 e0 10             	shl    $0x10,%eax
  800973:	09 f0                	or     %esi,%eax
  800975:	09 d0                	or     %edx,%eax
  800977:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800979:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 03                	jmp    800984 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	fc                   	cld    
  800982:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800984:	89 f8                	mov    %edi,%eax
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 75 0c             	mov    0xc(%ebp),%esi
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800999:	39 c6                	cmp    %eax,%esi
  80099b:	73 34                	jae    8009d1 <memmove+0x46>
  80099d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a0:	39 d0                	cmp    %edx,%eax
  8009a2:	73 2d                	jae    8009d1 <memmove+0x46>
		s += n;
		d += n;
  8009a4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	f6 c2 03             	test   $0x3,%dl
  8009aa:	75 1b                	jne    8009c7 <memmove+0x3c>
  8009ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b2:	75 13                	jne    8009c7 <memmove+0x3c>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0e                	jne    8009c7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 07                	jmp    8009ce <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c7:	4f                   	dec    %edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 20                	jmp    8009f1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 13                	jne    8009ec <memmove+0x61>
  8009d9:	a8 03                	test   $0x3,%al
  8009db:	75 0f                	jne    8009ec <memmove+0x61>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0a                	jne    8009ec <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 05                	jmp    8009f1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f8:	ff 75 10             	pushl  0x10(%ebp)
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	ff 75 08             	pushl  0x8(%ebp)
  800a01:	e8 85 ff ff ff       	call   80098b <memmove>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a14:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	85 ff                	test   %edi,%edi
  800a19:	74 32                	je     800a4d <memcmp+0x45>
		if (*s1 != *s2)
  800a1b:	8a 03                	mov    (%ebx),%al
  800a1d:	8a 0e                	mov    (%esi),%cl
  800a1f:	38 c8                	cmp    %cl,%al
  800a21:	74 19                	je     800a3c <memcmp+0x34>
  800a23:	eb 0d                	jmp    800a32 <memcmp+0x2a>
  800a25:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a29:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a2d:	42                   	inc    %edx
  800a2e:	38 c8                	cmp    %cl,%al
  800a30:	74 10                	je     800a42 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a32:	0f b6 c0             	movzbl %al,%eax
  800a35:	0f b6 c9             	movzbl %cl,%ecx
  800a38:	29 c8                	sub    %ecx,%eax
  800a3a:	eb 16                	jmp    800a52 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3c:	4f                   	dec    %edi
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	39 fa                	cmp    %edi,%edx
  800a44:	75 df                	jne    800a25 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 05                	jmp    800a52 <memcmp+0x4a>
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5d:	89 c2                	mov    %eax,%edx
  800a5f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	73 12                	jae    800a78 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a66:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	75 06                	jne    800a73 <memfind+0x1c>
  800a6d:	eb 09                	jmp    800a78 <memfind+0x21>
  800a6f:	38 08                	cmp    %cl,(%eax)
  800a71:	74 05                	je     800a78 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a73:	40                   	inc    %eax
  800a74:	39 c2                	cmp    %eax,%edx
  800a76:	77 f7                	ja     800a6f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 01                	jmp    800a89 <strtol+0xf>
		s++;
  800a88:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 20                	cmp    $0x20,%al
  800a8d:	74 f9                	je     800a88 <strtol+0xe>
  800a8f:	3c 09                	cmp    $0x9,%al
  800a91:	74 f5                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a93:	3c 2b                	cmp    $0x2b,%al
  800a95:	75 08                	jne    800a9f <strtol+0x25>
		s++;
  800a97:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9d:	eb 13                	jmp    800ab2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 0a                	jne    800aad <strtol+0x33>
		s++, neg = 1;
  800aa3:	8d 52 01             	lea    0x1(%edx),%edx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi
  800aab:	eb 05                	jmp    800ab2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	74 05                	je     800abb <strtol+0x41>
  800ab6:	83 fb 10             	cmp    $0x10,%ebx
  800ab9:	75 28                	jne    800ae3 <strtol+0x69>
  800abb:	8a 02                	mov    (%edx),%al
  800abd:	3c 30                	cmp    $0x30,%al
  800abf:	75 10                	jne    800ad1 <strtol+0x57>
  800ac1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac5:	75 0a                	jne    800ad1 <strtol+0x57>
		s += 2, base = 16;
  800ac7:	83 c2 02             	add    $0x2,%edx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb 12                	jmp    800ae3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 0e                	jne    800ae3 <strtol+0x69>
  800ad5:	3c 30                	cmp    $0x30,%al
  800ad7:	75 05                	jne    800ade <strtol+0x64>
		s++, base = 8;
  800ad9:	42                   	inc    %edx
  800ada:	b3 08                	mov    $0x8,%bl
  800adc:	eb 05                	jmp    800ae3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ade:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aea:	8a 0a                	mov    (%edx),%cl
  800aec:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aef:	80 fb 09             	cmp    $0x9,%bl
  800af2:	77 08                	ja     800afc <strtol+0x82>
			dig = *s - '0';
  800af4:	0f be c9             	movsbl %cl,%ecx
  800af7:	83 e9 30             	sub    $0x30,%ecx
  800afa:	eb 1e                	jmp    800b1a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800afc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 08                	ja     800b0c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b04:	0f be c9             	movsbl %cl,%ecx
  800b07:	83 e9 57             	sub    $0x57,%ecx
  800b0a:	eb 0e                	jmp    800b1a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b0c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 13                	ja     800b27 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b14:	0f be c9             	movsbl %cl,%ecx
  800b17:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1a:	39 f1                	cmp    %esi,%ecx
  800b1c:	7d 0d                	jge    800b2b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b1e:	42                   	inc    %edx
  800b1f:	0f af c6             	imul   %esi,%eax
  800b22:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b25:	eb c3                	jmp    800aea <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b27:	89 c1                	mov    %eax,%ecx
  800b29:	eb 02                	jmp    800b2d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 05                	je     800b38 <strtol+0xbe>
		*endptr = (char *) s;
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b36:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b38:	85 ff                	test   %edi,%edi
  800b3a:	74 04                	je     800b40 <strtol+0xc6>
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	f7 d8                	neg    %eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    
  800b45:	00 00                	add    %al,(%eax)
	...

00800b48 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	83 ec 10             	sub    $0x10,%esp
  800b50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b53:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b56:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b59:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b5c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	75 2e                	jne    800b94 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b66:	39 f1                	cmp    %esi,%ecx
  800b68:	77 5a                	ja     800bc4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b6a:	85 c9                	test   %ecx,%ecx
  800b6c:	75 0b                	jne    800b79 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b73:	31 d2                	xor    %edx,%edx
  800b75:	f7 f1                	div    %ecx
  800b77:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b79:	31 d2                	xor    %edx,%edx
  800b7b:	89 f0                	mov    %esi,%eax
  800b7d:	f7 f1                	div    %ecx
  800b7f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	f7 f1                	div    %ecx
  800b85:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b87:	89 f8                	mov    %edi,%eax
  800b89:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    
  800b92:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b94:	39 f0                	cmp    %esi,%eax
  800b96:	77 1c                	ja     800bb4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b98:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b9b:	83 f7 1f             	xor    $0x1f,%edi
  800b9e:	75 3c                	jne    800bdc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ba0:	39 f0                	cmp    %esi,%eax
  800ba2:	0f 82 90 00 00 00    	jb     800c38 <__udivdi3+0xf0>
  800ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bab:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bae:	0f 86 84 00 00 00    	jbe    800c38 <__udivdi3+0xf0>
  800bb4:	31 f6                	xor    %esi,%esi
  800bb6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb8:	89 f8                	mov    %edi,%eax
  800bba:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    
  800bc3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc4:	89 f2                	mov    %esi,%edx
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	f7 f1                	div    %ecx
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bce:	89 f8                	mov    %edi,%eax
  800bd0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    
  800bd9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bdc:	89 f9                	mov    %edi,%ecx
  800bde:	d3 e0                	shl    %cl,%eax
  800be0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800be3:	b8 20 00 00 00       	mov    $0x20,%eax
  800be8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bed:	88 c1                	mov    %al,%cl
  800bef:	d3 ea                	shr    %cl,%edx
  800bf1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bf4:	09 ca                	or     %ecx,%edx
  800bf6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfc:	89 f9                	mov    %edi,%ecx
  800bfe:	d3 e2                	shl    %cl,%edx
  800c00:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c03:	89 f2                	mov    %esi,%edx
  800c05:	88 c1                	mov    %al,%cl
  800c07:	d3 ea                	shr    %cl,%edx
  800c09:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	89 f9                	mov    %edi,%ecx
  800c10:	d3 e2                	shl    %cl,%edx
  800c12:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ee                	shr    %cl,%esi
  800c19:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c1b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c1e:	89 f0                	mov    %esi,%eax
  800c20:	89 ca                	mov    %ecx,%edx
  800c22:	f7 75 ec             	divl   -0x14(%ebp)
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c29:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c2c:	39 d1                	cmp    %edx,%ecx
  800c2e:	72 28                	jb     800c58 <__udivdi3+0x110>
  800c30:	74 1a                	je     800c4c <__udivdi3+0x104>
  800c32:	89 f7                	mov    %esi,%edi
  800c34:	31 f6                	xor    %esi,%esi
  800c36:	eb 80                	jmp    800bb8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c38:	31 f6                	xor    %esi,%esi
  800c3a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c3f:	89 f8                	mov    %edi,%eax
  800c41:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    
  800c4a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c4f:	89 f9                	mov    %edi,%ecx
  800c51:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c53:	39 c2                	cmp    %eax,%edx
  800c55:	73 db                	jae    800c32 <__udivdi3+0xea>
  800c57:	90                   	nop
		{
		  q0--;
  800c58:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c5b:	31 f6                	xor    %esi,%esi
  800c5d:	e9 56 ff ff ff       	jmp    800bb8 <__udivdi3+0x70>
	...

00800c64 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	83 ec 20             	sub    $0x20,%esp
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c81:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c83:	85 ff                	test   %edi,%edi
  800c85:	75 15                	jne    800c9c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c87:	39 f1                	cmp    %esi,%ecx
  800c89:	0f 86 99 00 00 00    	jbe    800d28 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c8f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c91:	89 d0                	mov    %edx,%eax
  800c93:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c95:	83 c4 20             	add    $0x20,%esp
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c9c:	39 f7                	cmp    %esi,%edi
  800c9e:	0f 87 a4 00 00 00    	ja     800d48 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ca4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ca7:	83 f0 1f             	xor    $0x1f,%eax
  800caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cad:	0f 84 a1 00 00 00    	je     800d54 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cb3:	89 f8                	mov    %edi,%eax
  800cb5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cb8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cba:	bf 20 00 00 00       	mov    $0x20,%edi
  800cbf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc5:	89 f9                	mov    %edi,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	09 c2                	or     %eax,%edx
  800ccb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cd4:	d3 e0                	shl    %cl,%eax
  800cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd9:	89 f2                	mov    %esi,%edx
  800cdb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce0:	d3 e0                	shl    %cl,%eax
  800ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce8:	89 f9                	mov    %edi,%ecx
  800cea:	d3 e8                	shr    %cl,%eax
  800cec:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cee:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	f7 75 f0             	divl   -0x10(%ebp)
  800cf5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cf7:	f7 65 f4             	mull   -0xc(%ebp)
  800cfa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800cfd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cff:	39 d6                	cmp    %edx,%esi
  800d01:	72 71                	jb     800d74 <__umoddi3+0x110>
  800d03:	74 7f                	je     800d84 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d08:	29 c8                	sub    %ecx,%eax
  800d0a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d0c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d0f:	d3 e8                	shr    %cl,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	89 f9                	mov    %edi,%ecx
  800d15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d17:	09 d0                	or     %edx,%eax
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d20:	83 c4 20             	add    $0x20,%esp
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    
  800d27:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d28:	85 c9                	test   %ecx,%ecx
  800d2a:	75 0b                	jne    800d37 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
  800d35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d37:	89 f0                	mov    %esi,%eax
  800d39:	31 d2                	xor    %edx,%edx
  800d3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d40:	f7 f1                	div    %ecx
  800d42:	e9 4a ff ff ff       	jmp    800c91 <__umoddi3+0x2d>
  800d47:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d48:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d4a:	83 c4 20             	add    $0x20,%esp
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    
  800d51:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d54:	39 f7                	cmp    %esi,%edi
  800d56:	72 05                	jb     800d5d <__umoddi3+0xf9>
  800d58:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d5b:	77 0c                	ja     800d69 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d62:	29 c8                	sub    %ecx,%eax
  800d64:	19 fa                	sbb    %edi,%edx
  800d66:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d6c:	83 c4 20             	add    $0x20,%esp
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    
  800d73:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d74:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d77:	89 c1                	mov    %eax,%ecx
  800d79:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d7c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d7f:	eb 84                	jmp    800d05 <__umoddi3+0xa1>
  800d81:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d84:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d87:	72 eb                	jb     800d74 <__umoddi3+0x110>
  800d89:	89 f2                	mov    %esi,%edx
  800d8b:	e9 75 ff ff ff       	jmp    800d05 <__umoddi3+0xa1>
