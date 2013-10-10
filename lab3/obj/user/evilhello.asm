
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 66 00 00 00       	call   8000ac <sys_cputs>
  800046:	83 c4 10             	add    $0x10,%esp
}
  800049:	c9                   	leave  
  80004a:	c3                   	ret    
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800057:	e8 ce 00 00 00       	call   80012a <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800064:	c1 e0 05             	shl    $0x5,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x30>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	56                   	push   %esi
  800081:	e8 ae ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800086:	e8 0d 00 00 00       	call   800098 <exit>
  80008b:	83 c4 10             	add    $0x10,%esp
}
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 44 00 00 00       	call   8000e9 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 aa 0d 80 00       	push   $0x800daa
  800116:	6a 23                	push   $0x23
  800118:	68 c7 0d 80 00       	push   $0x800dc7
  80011d:	e8 2a 00 00 00       	call   80014c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	c9                   	leave  
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80015a:	e8 cb ff ff ff       	call   80012a <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	53                   	push   %ebx
  800169:	50                   	push   %eax
  80016a:	68 d8 0d 80 00       	push   $0x800dd8
  80016f:	e8 b0 00 00 00       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	56                   	push   %esi
  800178:	ff 75 10             	pushl  0x10(%ebp)
  80017b:	e8 53 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  800187:	e8 98 00 00 00       	call   800224 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>
	...

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 04             	sub    $0x4,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 03                	mov    (%ebx),%eax
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001a7:	40                   	inc    %eax
  8001a8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	75 1a                	jne    8001cb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	68 ff 00 00 00       	push   $0xff
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 ea fe ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cb:	ff 43 04             	incl   0x4(%ebx)
}
  8001ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	68 94 01 80 00       	push   $0x800194
  800202:	e8 82 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	83 c4 08             	add    $0x8,%esp
  80020a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	50                   	push   %eax
  800217:	e8 90 fe ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80021c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022d:	50                   	push   %eax
  80022e:	ff 75 08             	pushl  0x8(%ebp)
  800231:	e8 9d ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
  800241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800244:	89 d6                	mov    %edx,%esi
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800252:	8b 45 10             	mov    0x10(%ebp),%eax
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800258:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80025e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800265:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800268:	72 0c                	jb     800276 <printnum+0x3e>
  80026a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80026d:	76 07                	jbe    800276 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026f:	4b                   	dec    %ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f 31                	jg     8002a5 <printnum+0x6d>
  800274:	eb 3f                	jmp    8002b5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	57                   	push   %edi
  80027a:	4b                   	dec    %ebx
  80027b:	53                   	push   %ebx
  80027c:	50                   	push   %eax
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 d4             	pushl  -0x2c(%ebp)
  800283:	ff 75 d0             	pushl  -0x30(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 c7 08 00 00       	call   800b58 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029b:	e8 98 ff ff ff       	call   800238 <printnum>
  8002a0:	83 c4 20             	add    $0x20,%esp
  8002a3:	eb 10                	jmp    8002b5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	57                   	push   %edi
  8002aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ad:	4b                   	dec    %ebx
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	85 db                	test   %ebx,%ebx
  8002b3:	7f f0                	jg     8002a5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	56                   	push   %esi
  8002b9:	83 ec 04             	sub    $0x4,%esp
  8002bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c8:	e8 a7 09 00 00       	call   800c74 <__umoddi3>
  8002cd:	83 c4 14             	add    $0x14,%esp
  8002d0:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002d7:	50                   	push   %eax
  8002d8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002db:	83 c4 10             	add    $0x10,%esp
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800323:	83 fa 01             	cmp    $0x1,%edx
  800326:	7e 0e                	jle    800336 <getint+0x16>
		return va_arg(*ap, long long);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	8b 52 04             	mov    0x4(%edx),%edx
  800334:	eb 1a                	jmp    800350 <getint+0x30>
	else if (lflag)
  800336:	85 d2                	test   %edx,%edx
  800338:	74 0c                	je     800346 <getint+0x26>
		return va_arg(*ap, long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	99                   	cltd   
  800344:	eb 0a                	jmp    800350 <getint+0x30>
	else
		return va_arg(*ap, int);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	99                   	cltd   
}
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800358:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	3b 50 04             	cmp    0x4(%eax),%edx
  800360:	73 08                	jae    80036a <sprintputch+0x18>
		*b->buf++ = ch;
  800362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800365:	88 0a                	mov    %cl,(%edx)
  800367:	42                   	inc    %edx
  800368:	89 10                	mov    %edx,(%eax)
}
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
  800384:	83 c4 10             	add    $0x10,%esp
}
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800395:	8b 75 10             	mov    0x10(%ebp),%esi
  800398:	eb 13                	jmp    8003ad <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039a:	85 c0                	test   %eax,%eax
  80039c:	0f 84 6d 03 00 00    	je     80070f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	57                   	push   %edi
  8003a6:	50                   	push   %eax
  8003a7:	ff 55 08             	call   *0x8(%ebp)
  8003aa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ad:	0f b6 06             	movzbl (%esi),%eax
  8003b0:	46                   	inc    %esi
  8003b1:	83 f8 25             	cmp    $0x25,%eax
  8003b4:	75 e4                	jne    80039a <vprintfmt+0x11>
  8003b6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ba:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003c1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d4:	eb 28                	jmp    8003fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003dc:	eb 20                	jmp    8003fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003e4:	eb 18                	jmp    8003fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ef:	eb 0d                	jmp    8003fe <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8a 06                	mov    (%esi),%al
  800400:	0f b6 d0             	movzbl %al,%edx
  800403:	8d 5e 01             	lea    0x1(%esi),%ebx
  800406:	83 e8 23             	sub    $0x23,%eax
  800409:	3c 55                	cmp    $0x55,%al
  80040b:	0f 87 e0 02 00 00    	ja     8006f1 <vprintfmt+0x368>
  800411:	0f b6 c0             	movzbl %al,%eax
  800414:	ff 24 85 8c 0e 80 00 	jmp    *0x800e8c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041b:	83 ea 30             	sub    $0x30,%edx
  80041e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800421:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800424:	8d 50 d0             	lea    -0x30(%eax),%edx
  800427:	83 fa 09             	cmp    $0x9,%edx
  80042a:	77 44                	ja     800470 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	89 de                	mov    %ebx,%esi
  80042e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800431:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800432:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800435:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800439:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80043c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80043f:	83 fb 09             	cmp    $0x9,%ebx
  800442:	76 ed                	jbe    800431 <vprintfmt+0xa8>
  800444:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800447:	eb 29                	jmp    800472 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 17                	jmp    800472 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80045b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045f:	78 85                	js     8003e6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	89 de                	mov    %ebx,%esi
  800463:	eb 99                	jmp    8003fe <vprintfmt+0x75>
  800465:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800467:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80046e:	eb 8e                	jmp    8003fe <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800472:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800476:	79 86                	jns    8003fe <vprintfmt+0x75>
  800478:	e9 74 ff ff ff       	jmp    8003f1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 de                	mov    %ebx,%esi
  800480:	e9 79 ff ff ff       	jmp    8003fe <vprintfmt+0x75>
  800485:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 50 04             	lea    0x4(%eax),%edx
  80048e:	89 55 14             	mov    %edx,0x14(%ebp)
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	57                   	push   %edi
  800495:	ff 30                	pushl  (%eax)
  800497:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a0:	e9 08 ff ff ff       	jmp    8003ad <vprintfmt+0x24>
  8004a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	79 02                	jns    8004b9 <vprintfmt+0x130>
  8004b7:	f7 d8                	neg    %eax
  8004b9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bb:	83 f8 06             	cmp    $0x6,%eax
  8004be:	7f 0b                	jg     8004cb <vprintfmt+0x142>
  8004c0:	8b 04 85 e4 0f 80 00 	mov    0x800fe4(,%eax,4),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	75 1a                	jne    8004e5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004cb:	52                   	push   %edx
  8004cc:	68 16 0e 80 00       	push   $0x800e16
  8004d1:	57                   	push   %edi
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 92 fe ff ff       	call   80036c <printfmt>
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e0:	e9 c8 fe ff ff       	jmp    8003ad <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004e5:	50                   	push   %eax
  8004e6:	68 1f 0e 80 00       	push   $0x800e1f
  8004eb:	57                   	push   %edi
  8004ec:	ff 75 08             	pushl  0x8(%ebp)
  8004ef:	e8 78 fe ff ff       	call   80036c <printfmt>
  8004f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004fa:	e9 ae fe ff ff       	jmp    8003ad <vprintfmt+0x24>
  8004ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800502:	89 de                	mov    %ebx,%esi
  800504:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800507:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800518:	85 c0                	test   %eax,%eax
  80051a:	75 07                	jne    800523 <vprintfmt+0x19a>
				p = "(null)";
  80051c:	c7 45 d0 0f 0e 80 00 	movl   $0x800e0f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800523:	85 db                	test   %ebx,%ebx
  800525:	7e 42                	jle    800569 <vprintfmt+0x1e0>
  800527:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80052b:	74 3c                	je     800569 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	51                   	push   %ecx
  800531:	ff 75 d0             	pushl  -0x30(%ebp)
  800534:	e8 6f 02 00 00       	call   8007a8 <strnlen>
  800539:	29 c3                	sub    %eax,%ebx
  80053b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 db                	test   %ebx,%ebx
  800543:	7e 24                	jle    800569 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800545:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800549:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80054c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	57                   	push   %edi
  800553:	53                   	push   %ebx
  800554:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	4e                   	dec    %esi
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	85 f6                	test   %esi,%esi
  80055d:	7f f0                	jg     80054f <vprintfmt+0x1c6>
  80055f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800562:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056c:	0f be 02             	movsbl (%edx),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	75 47                	jne    8005ba <vprintfmt+0x231>
  800573:	eb 37                	jmp    8005ac <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	74 16                	je     800591 <vprintfmt+0x208>
  80057b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80057e:	83 fa 5e             	cmp    $0x5e,%edx
  800581:	76 0e                	jbe    800591 <vprintfmt+0x208>
					putch('?', putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	57                   	push   %edi
  800587:	6a 3f                	push   $0x3f
  800589:	ff 55 08             	call   *0x8(%ebp)
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	eb 0b                	jmp    80059c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	57                   	push   %edi
  800595:	50                   	push   %eax
  800596:	ff 55 08             	call   *0x8(%ebp)
  800599:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059c:	ff 4d e4             	decl   -0x1c(%ebp)
  80059f:	0f be 03             	movsbl (%ebx),%eax
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	74 03                	je     8005a9 <vprintfmt+0x220>
  8005a6:	43                   	inc    %ebx
  8005a7:	eb 1b                	jmp    8005c4 <vprintfmt+0x23b>
  8005a9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b0:	7f 1e                	jg     8005d0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005b5:	e9 f3 fd ff ff       	jmp    8003ad <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005bd:	43                   	inc    %ebx
  8005be:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	78 ad                	js     800575 <vprintfmt+0x1ec>
  8005c8:	4e                   	dec    %esi
  8005c9:	79 aa                	jns    800575 <vprintfmt+0x1ec>
  8005cb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ce:	eb dc                	jmp    8005ac <vprintfmt+0x223>
  8005d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 20                	push   $0x20
  8005d9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dc:	4b                   	dec    %ebx
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	7f ef                	jg     8005d3 <vprintfmt+0x24a>
  8005e4:	e9 c4 fd ff ff       	jmp    8003ad <vprintfmt+0x24>
  8005e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	89 ca                	mov    %ecx,%edx
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 2a fd ff ff       	call   800320 <getint>
  8005f6:	89 c3                	mov    %eax,%ebx
  8005f8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	78 0a                	js     800608 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 b0 00 00 00       	jmp    8006b8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	57                   	push   %edi
  80060c:	6a 2d                	push   $0x2d
  80060e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800611:	f7 db                	neg    %ebx
  800613:	83 d6 00             	adc    $0x0,%esi
  800616:	f7 de                	neg    %esi
  800618:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 93 00 00 00       	jmp    8006b8 <vprintfmt+0x32f>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 b4 fc ff ff       	call   8002e6 <getuint>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	89 d6                	mov    %edx,%esi
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063b:	eb 7b                	jmp    8006b8 <vprintfmt+0x32f>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 d6 fc ff ff       	call   800320 <getint>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80064e:	85 d2                	test   %edx,%edx
  800650:	78 07                	js     800659 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800652:	b8 08 00 00 00       	mov    $0x8,%eax
  800657:	eb 5f                	jmp    8006b8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	57                   	push   %edi
  80065d:	6a 2d                	push   $0x2d
  80065f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800662:	f7 db                	neg    %ebx
  800664:	83 d6 00             	adc    $0x0,%esi
  800667:	f7 de                	neg    %esi
  800669:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80066c:	b8 08 00 00 00       	mov    $0x8,%eax
  800671:	eb 45                	jmp    8006b8 <vprintfmt+0x32f>
  800673:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	57                   	push   %edi
  80067a:	6a 30                	push   $0x30
  80067c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	57                   	push   %edi
  800683:	6a 78                	push   $0x78
  800685:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800691:	8b 18                	mov    (%eax),%ebx
  800693:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800698:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a0:	eb 16                	jmp    8006b8 <vprintfmt+0x32f>
  8006a2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a5:	89 ca                	mov    %ecx,%edx
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 37 fc ff ff       	call   8002e6 <getuint>
  8006af:	89 c3                	mov    %eax,%ebx
  8006b1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006bf:	52                   	push   %edx
  8006c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c3:	50                   	push   %eax
  8006c4:	56                   	push   %esi
  8006c5:	53                   	push   %ebx
  8006c6:	89 fa                	mov    %edi,%edx
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	e8 68 fb ff ff       	call   800238 <printnum>
			break;
  8006d0:	83 c4 20             	add    $0x20,%esp
  8006d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006d6:	e9 d2 fc ff ff       	jmp    8003ad <vprintfmt+0x24>
  8006db:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	57                   	push   %edi
  8006e2:	52                   	push   %edx
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ec:	e9 bc fc ff ff       	jmp    8003ad <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	57                   	push   %edi
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 02                	jmp    800701 <vprintfmt+0x378>
  8006ff:	89 c6                	mov    %eax,%esi
  800701:	8d 46 ff             	lea    -0x1(%esi),%eax
  800704:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800708:	75 f5                	jne    8006ff <vprintfmt+0x376>
  80070a:	e9 9e fc ff ff       	jmp    8003ad <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 29                	jle    800765 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 52 03 80 00       	push   $0x800352
  80074b:	e8 39 fc ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 0c                	jmp    80076a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800763:	eb 05                	jmp    80076a <vsnprintf+0x53>
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800775:	50                   	push   %eax
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	ff 75 08             	pushl  0x8(%ebp)
  80077f:	e8 93 ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    
	...

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3a 00             	cmpb   $0x0,(%edx)
  800791:	74 0e                	je     8007a1 <strlen+0x19>
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800798:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800799:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079d:	75 f9                	jne    800798 <strlen+0x10>
  80079f:	eb 05                	jmp    8007a6 <strlen+0x1e>
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	74 17                	je     8007cc <strnlen+0x24>
  8007b5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b8:	74 19                	je     8007d3 <strnlen+0x2b>
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007bf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	39 d0                	cmp    %edx,%eax
  8007c2:	74 14                	je     8007d8 <strnlen+0x30>
  8007c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c8:	75 f5                	jne    8007bf <strnlen+0x17>
  8007ca:	eb 0c                	jmp    8007d8 <strnlen+0x30>
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 05                	jmp    8007d8 <strnlen+0x30>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ef:	42                   	inc    %edx
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	75 f5                	jne    8007e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fe:	53                   	push   %ebx
  8007ff:	e8 84 ff ff ff       	call   800788 <strlen>
  800804:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80080d:	50                   	push   %eax
  80080e:	e8 c7 ff ff ff       	call   8007da <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	85 f6                	test   %esi,%esi
  80082a:	74 15                	je     800841 <strncpy+0x27>
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800831:	8a 1a                	mov    (%edx),%bl
  800833:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800836:	80 3a 01             	cmpb   $0x1,(%edx)
  800839:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	41                   	inc    %ecx
  80083d:	39 ce                	cmp    %ecx,%esi
  80083f:	77 f0                	ja     800831 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	57                   	push   %edi
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800851:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800854:	85 f6                	test   %esi,%esi
  800856:	74 32                	je     80088a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800858:	83 fe 01             	cmp    $0x1,%esi
  80085b:	74 22                	je     80087f <strlcpy+0x3a>
  80085d:	8a 0b                	mov    (%ebx),%cl
  80085f:	84 c9                	test   %cl,%cl
  800861:	74 20                	je     800883 <strlcpy+0x3e>
  800863:	89 f8                	mov    %edi,%eax
  800865:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80086a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086d:	88 08                	mov    %cl,(%eax)
  80086f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800870:	39 f2                	cmp    %esi,%edx
  800872:	74 11                	je     800885 <strlcpy+0x40>
  800874:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800878:	42                   	inc    %edx
  800879:	84 c9                	test   %cl,%cl
  80087b:	75 f0                	jne    80086d <strlcpy+0x28>
  80087d:	eb 06                	jmp    800885 <strlcpy+0x40>
  80087f:	89 f8                	mov    %edi,%eax
  800881:	eb 02                	jmp    800885 <strlcpy+0x40>
  800883:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800885:	c6 00 00             	movb   $0x0,(%eax)
  800888:	eb 02                	jmp    80088c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80088c:	29 f8                	sub    %edi,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5f                   	pop    %edi
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089c:	8a 01                	mov    (%ecx),%al
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 10                	je     8008b2 <strcmp+0x1f>
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	75 0c                	jne    8008b2 <strcmp+0x1f>
		p++, q++;
  8008a6:	41                   	inc    %ecx
  8008a7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a8:	8a 01                	mov    (%ecx),%al
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 04                	je     8008b2 <strcmp+0x1f>
  8008ae:	3a 02                	cmp    (%edx),%al
  8008b0:	74 f4                	je     8008a6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 c0             	movzbl %al,%eax
  8008b5:	0f b6 12             	movzbl (%edx),%edx
  8008b8:	29 d0                	sub    %edx,%eax
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	53                   	push   %ebx
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 1b                	je     8008e8 <strncmp+0x2c>
  8008cd:	8a 1a                	mov    (%edx),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	74 24                	je     8008f7 <strncmp+0x3b>
  8008d3:	3a 19                	cmp    (%ecx),%bl
  8008d5:	75 20                	jne    8008f7 <strncmp+0x3b>
  8008d7:	48                   	dec    %eax
  8008d8:	74 15                	je     8008ef <strncmp+0x33>
		n--, p++, q++;
  8008da:	42                   	inc    %edx
  8008db:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	8a 1a                	mov    (%edx),%bl
  8008de:	84 db                	test   %bl,%bl
  8008e0:	74 15                	je     8008f7 <strncmp+0x3b>
  8008e2:	3a 19                	cmp    (%ecx),%bl
  8008e4:	74 f1                	je     8008d7 <strncmp+0x1b>
  8008e6:	eb 0f                	jmp    8008f7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	eb 05                	jmp    8008f4 <strncmp+0x38>
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 02             	movzbl (%edx),%eax
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
  8008ff:	eb f3                	jmp    8008f4 <strncmp+0x38>

00800901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090a:	8a 10                	mov    (%eax),%dl
  80090c:	84 d2                	test   %dl,%dl
  80090e:	74 18                	je     800928 <strchr+0x27>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	75 06                	jne    80091a <strchr+0x19>
  800914:	eb 17                	jmp    80092d <strchr+0x2c>
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 13                	je     80092d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091a:	40                   	inc    %eax
  80091b:	8a 10                	mov    (%eax),%dl
  80091d:	84 d2                	test   %dl,%dl
  80091f:	75 f5                	jne    800916 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb 05                	jmp    80092d <strchr+0x2c>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800938:	8a 10                	mov    (%eax),%dl
  80093a:	84 d2                	test   %dl,%dl
  80093c:	74 11                	je     80094f <strfind+0x20>
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	75 06                	jne    800948 <strfind+0x19>
  800942:	eb 0b                	jmp    80094f <strfind+0x20>
  800944:	38 ca                	cmp    %cl,%dl
  800946:	74 07                	je     80094f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800948:	40                   	inc    %eax
  800949:	8a 10                	mov    (%eax),%dl
  80094b:	84 d2                	test   %dl,%dl
  80094d:	75 f5                	jne    800944 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800960:	85 c9                	test   %ecx,%ecx
  800962:	74 30                	je     800994 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800964:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096a:	75 25                	jne    800991 <memset+0x40>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 20                	jne    800991 <memset+0x40>
		c &= 0xFF;
  800971:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800974:	89 d3                	mov    %edx,%ebx
  800976:	c1 e3 08             	shl    $0x8,%ebx
  800979:	89 d6                	mov    %edx,%esi
  80097b:	c1 e6 18             	shl    $0x18,%esi
  80097e:	89 d0                	mov    %edx,%eax
  800980:	c1 e0 10             	shl    $0x10,%eax
  800983:	09 f0                	or     %esi,%eax
  800985:	09 d0                	or     %edx,%eax
  800987:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800989:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098c:	fc                   	cld    
  80098d:	f3 ab                	rep stos %eax,%es:(%edi)
  80098f:	eb 03                	jmp    800994 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800991:	fc                   	cld    
  800992:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800994:	89 f8                	mov    %edi,%eax
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a9:	39 c6                	cmp    %eax,%esi
  8009ab:	73 34                	jae    8009e1 <memmove+0x46>
  8009ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b0:	39 d0                	cmp    %edx,%eax
  8009b2:	73 2d                	jae    8009e1 <memmove+0x46>
		s += n;
		d += n;
  8009b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b7:	f6 c2 03             	test   $0x3,%dl
  8009ba:	75 1b                	jne    8009d7 <memmove+0x3c>
  8009bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c2:	75 13                	jne    8009d7 <memmove+0x3c>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 0e                	jne    8009d7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c9:	83 ef 04             	sub    $0x4,%edi
  8009cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d2:	fd                   	std    
  8009d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d5:	eb 07                	jmp    8009de <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d7:	4f                   	dec    %edi
  8009d8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009db:	fd                   	std    
  8009dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009de:	fc                   	cld    
  8009df:	eb 20                	jmp    800a01 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e7:	75 13                	jne    8009fc <memmove+0x61>
  8009e9:	a8 03                	test   $0x3,%al
  8009eb:	75 0f                	jne    8009fc <memmove+0x61>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 0a                	jne    8009fc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 05                	jmp    800a01 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a01:	5e                   	pop    %esi
  800a02:	5f                   	pop    %edi
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a08:	ff 75 10             	pushl  0x10(%ebp)
  800a0b:	ff 75 0c             	pushl  0xc(%ebp)
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 85 ff ff ff       	call   80099b <memmove>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a24:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	85 ff                	test   %edi,%edi
  800a29:	74 32                	je     800a5d <memcmp+0x45>
		if (*s1 != *s2)
  800a2b:	8a 03                	mov    (%ebx),%al
  800a2d:	8a 0e                	mov    (%esi),%cl
  800a2f:	38 c8                	cmp    %cl,%al
  800a31:	74 19                	je     800a4c <memcmp+0x34>
  800a33:	eb 0d                	jmp    800a42 <memcmp+0x2a>
  800a35:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a39:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a3d:	42                   	inc    %edx
  800a3e:	38 c8                	cmp    %cl,%al
  800a40:	74 10                	je     800a52 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a42:	0f b6 c0             	movzbl %al,%eax
  800a45:	0f b6 c9             	movzbl %cl,%ecx
  800a48:	29 c8                	sub    %ecx,%eax
  800a4a:	eb 16                	jmp    800a62 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	4f                   	dec    %edi
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	39 fa                	cmp    %edi,%edx
  800a54:	75 df                	jne    800a35 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb 05                	jmp    800a62 <memcmp+0x4a>
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6d:	89 c2                	mov    %eax,%edx
  800a6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a72:	39 d0                	cmp    %edx,%eax
  800a74:	73 12                	jae    800a88 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a76:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a79:	38 08                	cmp    %cl,(%eax)
  800a7b:	75 06                	jne    800a83 <memfind+0x1c>
  800a7d:	eb 09                	jmp    800a88 <memfind+0x21>
  800a7f:	38 08                	cmp    %cl,(%eax)
  800a81:	74 05                	je     800a88 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a83:	40                   	inc    %eax
  800a84:	39 c2                	cmp    %eax,%edx
  800a86:	77 f7                	ja     800a7f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a96:	eb 01                	jmp    800a99 <strtol+0xf>
		s++;
  800a98:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	8a 02                	mov    (%edx),%al
  800a9b:	3c 20                	cmp    $0x20,%al
  800a9d:	74 f9                	je     800a98 <strtol+0xe>
  800a9f:	3c 09                	cmp    $0x9,%al
  800aa1:	74 f5                	je     800a98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa3:	3c 2b                	cmp    $0x2b,%al
  800aa5:	75 08                	jne    800aaf <strtol+0x25>
		s++;
  800aa7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aad:	eb 13                	jmp    800ac2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aaf:	3c 2d                	cmp    $0x2d,%al
  800ab1:	75 0a                	jne    800abd <strtol+0x33>
		s++, neg = 1;
  800ab3:	8d 52 01             	lea    0x1(%edx),%edx
  800ab6:	bf 01 00 00 00       	mov    $0x1,%edi
  800abb:	eb 05                	jmp    800ac2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac2:	85 db                	test   %ebx,%ebx
  800ac4:	74 05                	je     800acb <strtol+0x41>
  800ac6:	83 fb 10             	cmp    $0x10,%ebx
  800ac9:	75 28                	jne    800af3 <strtol+0x69>
  800acb:	8a 02                	mov    (%edx),%al
  800acd:	3c 30                	cmp    $0x30,%al
  800acf:	75 10                	jne    800ae1 <strtol+0x57>
  800ad1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad5:	75 0a                	jne    800ae1 <strtol+0x57>
		s += 2, base = 16;
  800ad7:	83 c2 02             	add    $0x2,%edx
  800ada:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adf:	eb 12                	jmp    800af3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ae1:	85 db                	test   %ebx,%ebx
  800ae3:	75 0e                	jne    800af3 <strtol+0x69>
  800ae5:	3c 30                	cmp    $0x30,%al
  800ae7:	75 05                	jne    800aee <strtol+0x64>
		s++, base = 8;
  800ae9:	42                   	inc    %edx
  800aea:	b3 08                	mov    $0x8,%bl
  800aec:	eb 05                	jmp    800af3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aee:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afa:	8a 0a                	mov    (%edx),%cl
  800afc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aff:	80 fb 09             	cmp    $0x9,%bl
  800b02:	77 08                	ja     800b0c <strtol+0x82>
			dig = *s - '0';
  800b04:	0f be c9             	movsbl %cl,%ecx
  800b07:	83 e9 30             	sub    $0x30,%ecx
  800b0a:	eb 1e                	jmp    800b2a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b0c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b14:	0f be c9             	movsbl %cl,%ecx
  800b17:	83 e9 57             	sub    $0x57,%ecx
  800b1a:	eb 0e                	jmp    800b2a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b1c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b1f:	80 fb 19             	cmp    $0x19,%bl
  800b22:	77 13                	ja     800b37 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b24:	0f be c9             	movsbl %cl,%ecx
  800b27:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2a:	39 f1                	cmp    %esi,%ecx
  800b2c:	7d 0d                	jge    800b3b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b2e:	42                   	inc    %edx
  800b2f:	0f af c6             	imul   %esi,%eax
  800b32:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b35:	eb c3                	jmp    800afa <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b37:	89 c1                	mov    %eax,%ecx
  800b39:	eb 02                	jmp    800b3d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b41:	74 05                	je     800b48 <strtol+0xbe>
		*endptr = (char *) s;
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b48:	85 ff                	test   %edi,%edi
  800b4a:	74 04                	je     800b50 <strtol+0xc6>
  800b4c:	89 c8                	mov    %ecx,%eax
  800b4e:	f7 d8                	neg    %eax
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    
  800b55:	00 00                	add    %al,(%eax)
	...

00800b58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	83 ec 10             	sub    $0x10,%esp
  800b60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b72:	85 c0                	test   %eax,%eax
  800b74:	75 2e                	jne    800ba4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b76:	39 f1                	cmp    %esi,%ecx
  800b78:	77 5a                	ja     800bd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b7a:	85 c9                	test   %ecx,%ecx
  800b7c:	75 0b                	jne    800b89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b83:	31 d2                	xor    %edx,%edx
  800b85:	f7 f1                	div    %ecx
  800b87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b89:	31 d2                	xor    %edx,%edx
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	f7 f1                	div    %ecx
  800b8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	f7 f1                	div    %ecx
  800b95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b97:	89 f8                	mov    %edi,%eax
  800b99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    
  800ba2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ba4:	39 f0                	cmp    %esi,%eax
  800ba6:	77 1c                	ja     800bc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ba8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bab:	83 f7 1f             	xor    $0x1f,%edi
  800bae:	75 3c                	jne    800bec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bb0:	39 f0                	cmp    %esi,%eax
  800bb2:	0f 82 90 00 00 00    	jb     800c48 <__udivdi3+0xf0>
  800bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bbe:	0f 86 84 00 00 00    	jbe    800c48 <__udivdi3+0xf0>
  800bc4:	31 f6                	xor    %esi,%esi
  800bc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc8:	89 f8                	mov    %edi,%eax
  800bca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    
  800bd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	f7 f1                	div    %ecx
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bde:	89 f8                	mov    %edi,%eax
  800be0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    
  800be9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bec:	89 f9                	mov    %edi,%ecx
  800bee:	d3 e0                	shl    %cl,%eax
  800bf0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bf3:	b8 20 00 00 00       	mov    $0x20,%eax
  800bf8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfd:	88 c1                	mov    %al,%cl
  800bff:	d3 ea                	shr    %cl,%edx
  800c01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c04:	09 ca                	or     %ecx,%edx
  800c06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c0c:	89 f9                	mov    %edi,%ecx
  800c0e:	d3 e2                	shl    %cl,%edx
  800c10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c13:	89 f2                	mov    %esi,%edx
  800c15:	88 c1                	mov    %al,%cl
  800c17:	d3 ea                	shr    %cl,%edx
  800c19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c1c:	89 f2                	mov    %esi,%edx
  800c1e:	89 f9                	mov    %edi,%ecx
  800c20:	d3 e2                	shl    %cl,%edx
  800c22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c25:	88 c1                	mov    %al,%cl
  800c27:	d3 ee                	shr    %cl,%esi
  800c29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c2e:	89 f0                	mov    %esi,%eax
  800c30:	89 ca                	mov    %ecx,%edx
  800c32:	f7 75 ec             	divl   -0x14(%ebp)
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c3c:	39 d1                	cmp    %edx,%ecx
  800c3e:	72 28                	jb     800c68 <__udivdi3+0x110>
  800c40:	74 1a                	je     800c5c <__udivdi3+0x104>
  800c42:	89 f7                	mov    %esi,%edi
  800c44:	31 f6                	xor    %esi,%esi
  800c46:	eb 80                	jmp    800bc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c48:	31 f6                	xor    %esi,%esi
  800c4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c4f:	89 f8                	mov    %edi,%eax
  800c51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    
  800c5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5f:	89 f9                	mov    %edi,%ecx
  800c61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c63:	39 c2                	cmp    %eax,%edx
  800c65:	73 db                	jae    800c42 <__udivdi3+0xea>
  800c67:	90                   	nop
		{
		  q0--;
  800c68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c6b:	31 f6                	xor    %esi,%esi
  800c6d:	e9 56 ff ff ff       	jmp    800bc8 <__udivdi3+0x70>
	...

00800c74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	83 ec 20             	sub    $0x20,%esp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c93:	85 ff                	test   %edi,%edi
  800c95:	75 15                	jne    800cac <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c97:	39 f1                	cmp    %esi,%ecx
  800c99:	0f 86 99 00 00 00    	jbe    800d38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ca1:	89 d0                	mov    %edx,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ca5:	83 c4 20             	add    $0x20,%esp
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cac:	39 f7                	cmp    %esi,%edi
  800cae:	0f 87 a4 00 00 00    	ja     800d58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cb7:	83 f0 1f             	xor    $0x1f,%eax
  800cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbd:	0f 84 a1 00 00 00    	je     800d64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cc3:	89 f8                	mov    %edi,%eax
  800cc5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cca:	bf 20 00 00 00       	mov    $0x20,%edi
  800ccf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd5:	89 f9                	mov    %edi,%ecx
  800cd7:	d3 ea                	shr    %cl,%edx
  800cd9:	09 c2                	or     %eax,%edx
  800cdb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ce4:	d3 e0                	shl    %cl,%eax
  800ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf0:	d3 e0                	shl    %cl,%eax
  800cf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf8:	89 f9                	mov    %edi,%ecx
  800cfa:	d3 e8                	shr    %cl,%eax
  800cfc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cfe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	f7 75 f0             	divl   -0x10(%ebp)
  800d05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d07:	f7 65 f4             	mull   -0xc(%ebp)
  800d0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d0f:	39 d6                	cmp    %edx,%esi
  800d11:	72 71                	jb     800d84 <__umoddi3+0x110>
  800d13:	74 7f                	je     800d94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d18:	29 c8                	sub    %ecx,%eax
  800d1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1f:	d3 e8                	shr    %cl,%eax
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	89 f9                	mov    %edi,%ecx
  800d25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d27:	09 d0                	or     %edx,%eax
  800d29:	89 f2                	mov    %esi,%edx
  800d2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d30:	83 c4 20             	add    $0x20,%esp
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    
  800d37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d38:	85 c9                	test   %ecx,%ecx
  800d3a:	75 0b                	jne    800d47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d41:	31 d2                	xor    %edx,%edx
  800d43:	f7 f1                	div    %ecx
  800d45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	31 d2                	xor    %edx,%edx
  800d4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d50:	f7 f1                	div    %ecx
  800d52:	e9 4a ff ff ff       	jmp    800ca1 <__umoddi3+0x2d>
  800d57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d5a:	83 c4 20             	add    $0x20,%esp
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    
  800d61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d64:	39 f7                	cmp    %esi,%edi
  800d66:	72 05                	jb     800d6d <__umoddi3+0xf9>
  800d68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d6b:	77 0c                	ja     800d79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d72:	29 c8                	sub    %ecx,%eax
  800d74:	19 fa                	sbb    %edi,%edx
  800d76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    
  800d83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d87:	89 c1                	mov    %eax,%ecx
  800d89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d8f:	eb 84                	jmp    800d15 <__umoddi3+0xa1>
  800d91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d97:	72 eb                	jb     800d84 <__umoddi3+0x110>
  800d99:	89 f2                	mov    %esi,%edx
  800d9b:	e9 75 ff ff ff       	jmp    800d15 <__umoddi3+0xa1>
