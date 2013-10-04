
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
  800041:	e8 52 00 00 00       	call   800098 <sys_cputs>
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
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	8b 45 08             	mov    0x8(%ebp),%eax
  800055:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800058:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80005f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	7e 08                	jle    80006e <libmain+0x22>
		binaryname = argv[0];
  800066:	8b 0a                	mov    (%edx),%ecx
  800068:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	52                   	push   %edx
  800072:	50                   	push   %eax
  800073:	e8 bc ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800078:	e8 07 00 00 00       	call   800084 <exit>
  80007d:	83 c4 10             	add    $0x10,%esp
}
  800080:	c9                   	leave  
  800081:	c3                   	ret    
	...

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 44 00 00 00       	call   8000d5 <sys_env_destroy>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    
	...

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	89 c3                	mov    %eax,%ebx
  8000ab:	89 c7                	mov    %eax,%edi
  8000ad:	89 c6                	mov    %eax,%esi
  8000af:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5f                   	pop    %edi
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c6:	89 d1                	mov    %edx,%ecx
  8000c8:	89 d3                	mov    %edx,%ebx
  8000ca:	89 d7                	mov    %edx,%edi
  8000cc:	89 d6                	mov    %edx,%esi
  8000ce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 cb                	mov    %ecx,%ebx
  8000ed:	89 cf                	mov    %ecx,%edi
  8000ef:	89 ce                	mov    %ecx,%esi
  8000f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7e 17                	jle    80010e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	50                   	push   %eax
  8000fb:	6a 03                	push   $0x3
  8000fd:	68 96 0d 80 00       	push   $0x800d96
  800102:	6a 23                	push   $0x23
  800104:	68 b3 0d 80 00       	push   $0x800db3
  800109:	e8 2a 00 00 00       	call   800138 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011c:	ba 00 00 00 00       	mov    $0x0,%edx
  800121:	b8 02 00 00 00       	mov    $0x2,%eax
  800126:	89 d1                	mov    %edx,%ecx
  800128:	89 d3                	mov    %edx,%ebx
  80012a:	89 d7                	mov    %edx,%edi
  80012c:	89 d6                	mov    %edx,%esi
  80012e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800140:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800146:	e8 cb ff ff ff       	call   800116 <sys_getenvid>
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 75 0c             	pushl  0xc(%ebp)
  800151:	ff 75 08             	pushl  0x8(%ebp)
  800154:	53                   	push   %ebx
  800155:	50                   	push   %eax
  800156:	68 c4 0d 80 00       	push   $0x800dc4
  80015b:	e8 b0 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	56                   	push   %esi
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 53 00 00 00       	call   8001bf <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 e8 0d 80 00 	movl   $0x800de8,(%esp)
  800173:	e8 98 00 00 00       	call   800210 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x43>
	...

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 03                	mov    (%ebx),%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800193:	40                   	inc    %eax
  800194:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 ea fe ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 80 01 80 00       	push   $0x800180
  8001ee:	e8 82 01 00 00       	call   800375 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 90 fe ff ff       	call   800098 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d6                	mov    %edx,%esi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	8b 55 0c             	mov    0xc(%ebp),%edx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800244:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800247:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80024a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800251:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800254:	72 0c                	jb     800262 <printnum+0x3e>
  800256:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800259:	76 07                	jbe    800262 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	4b                   	dec    %ebx
  80025c:	85 db                	test   %ebx,%ebx
  80025e:	7f 31                	jg     800291 <printnum+0x6d>
  800260:	eb 3f                	jmp    8002a1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	57                   	push   %edi
  800266:	4b                   	dec    %ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026f:	ff 75 d0             	pushl  -0x30(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 c7 08 00 00       	call   800b44 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800287:	e8 98 ff ff ff       	call   800224 <printnum>
  80028c:	83 c4 20             	add    $0x20,%esp
  80028f:	eb 10                	jmp    8002a1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	57                   	push   %edi
  800296:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	4b                   	dec    %ebx
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f f0                	jg     800291 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ab:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 a7 09 00 00       	call   800c60 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 ea 0d 80 00 	movsbl 0x800dea(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff 55 e4             	call   *-0x1c(%ebp)
  8002c7:	83 c4 10             	add    $0x10,%esp
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d5:	83 fa 01             	cmp    $0x1,%edx
  8002d8:	7e 0e                	jle    8002e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	8b 52 04             	mov    0x4(%edx),%edx
  8002e6:	eb 22                	jmp    80030a <getuint+0x38>
	else if (lflag)
  8002e8:	85 d2                	test   %edx,%edx
  8002ea:	74 10                	je     8002fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 0e                	jmp    80030a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030f:	83 fa 01             	cmp    $0x1,%edx
  800312:	7e 0e                	jle    800322 <getint+0x16>
		return va_arg(*ap, long long);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 08             	lea    0x8(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	8b 52 04             	mov    0x4(%edx),%edx
  800320:	eb 1a                	jmp    80033c <getint+0x30>
	else if (lflag)
  800322:	85 d2                	test   %edx,%edx
  800324:	74 0c                	je     800332 <getint+0x26>
		return va_arg(*ap, long);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
  800330:	eb 0a                	jmp    80033c <getint+0x30>
	else
		return va_arg(*ap, int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	99                   	cltd   
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800344:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800347:	8b 10                	mov    (%eax),%edx
  800349:	3b 50 04             	cmp    0x4(%eax),%edx
  80034c:	73 08                	jae    800356 <sprintputch+0x18>
		*b->buf++ = ch;
  80034e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800351:	88 0a                	mov    %cl,(%edx)
  800353:	42                   	inc    %edx
  800354:	89 10                	mov    %edx,(%eax)
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	ff 75 0c             	pushl  0xc(%ebp)
  800368:	ff 75 08             	pushl  0x8(%ebp)
  80036b:	e8 05 00 00 00       	call   800375 <vprintfmt>
	va_end(ap);
  800370:	83 c4 10             	add    $0x10,%esp
}
  800373:	c9                   	leave  
  800374:	c3                   	ret    

00800375 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 2c             	sub    $0x2c,%esp
  80037e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800381:	8b 75 10             	mov    0x10(%ebp),%esi
  800384:	eb 13                	jmp    800399 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800386:	85 c0                	test   %eax,%eax
  800388:	0f 84 6d 03 00 00    	je     8006fb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	57                   	push   %edi
  800392:	50                   	push   %eax
  800393:	ff 55 08             	call   *0x8(%ebp)
  800396:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 06             	movzbl (%esi),%eax
  80039c:	46                   	inc    %esi
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e4                	jne    800386 <vprintfmt+0x11>
  8003a2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003ad:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	eb 28                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c8:	eb 20                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d0:	eb 18                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003db:	eb 0d                	jmp    8003ea <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8a 06                	mov    (%esi),%al
  8003ec:	0f b6 d0             	movzbl %al,%edx
  8003ef:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f2:	83 e8 23             	sub    $0x23,%eax
  8003f5:	3c 55                	cmp    $0x55,%al
  8003f7:	0f 87 e0 02 00 00    	ja     8006dd <vprintfmt+0x368>
  8003fd:	0f b6 c0             	movzbl %al,%eax
  800400:	ff 24 85 78 0e 80 00 	jmp    *0x800e78(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800407:	83 ea 30             	sub    $0x30,%edx
  80040a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80040d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800410:	8d 50 d0             	lea    -0x30(%eax),%edx
  800413:	83 fa 09             	cmp    $0x9,%edx
  800416:	77 44                	ja     80045c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	89 de                	mov    %ebx,%esi
  80041a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80041e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800421:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800425:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800428:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80042b:	83 fb 09             	cmp    $0x9,%ebx
  80042e:	76 ed                	jbe    80041d <vprintfmt+0xa8>
  800430:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800433:	eb 29                	jmp    80045e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800445:	eb 17                	jmp    80045e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	78 85                	js     8003d2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	89 de                	mov    %ebx,%esi
  80044f:	eb 99                	jmp    8003ea <vprintfmt+0x75>
  800451:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800453:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80045a:	eb 8e                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80045e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800462:	79 86                	jns    8003ea <vprintfmt+0x75>
  800464:	e9 74 ff ff ff       	jmp    8003dd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800469:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	89 de                	mov    %ebx,%esi
  80046c:	e9 79 ff ff ff       	jmp    8003ea <vprintfmt+0x75>
  800471:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	57                   	push   %edi
  800481:	ff 30                	pushl  (%eax)
  800483:	ff 55 08             	call   *0x8(%ebp)
			break;
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 08 ff ff ff       	jmp    800399 <vprintfmt+0x24>
  800491:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 02                	jns    8004a5 <vprintfmt+0x130>
  8004a3:	f7 d8                	neg    %eax
  8004a5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a7:	83 f8 06             	cmp    $0x6,%eax
  8004aa:	7f 0b                	jg     8004b7 <vprintfmt+0x142>
  8004ac:	8b 04 85 d0 0f 80 00 	mov    0x800fd0(,%eax,4),%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	75 1a                	jne    8004d1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004b7:	52                   	push   %edx
  8004b8:	68 02 0e 80 00       	push   $0x800e02
  8004bd:	57                   	push   %edi
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 92 fe ff ff       	call   800358 <printfmt>
  8004c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cc:	e9 c8 fe ff ff       	jmp    800399 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004d1:	50                   	push   %eax
  8004d2:	68 0b 0e 80 00       	push   $0x800e0b
  8004d7:	57                   	push   %edi
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 78 fe ff ff       	call   800358 <printfmt>
  8004e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e6:	e9 ae fe ff ff       	jmp    800399 <vprintfmt+0x24>
  8004eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ee:	89 de                	mov    %ebx,%esi
  8004f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800504:	85 c0                	test   %eax,%eax
  800506:	75 07                	jne    80050f <vprintfmt+0x19a>
				p = "(null)";
  800508:	c7 45 d0 fb 0d 80 00 	movl   $0x800dfb,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80050f:	85 db                	test   %ebx,%ebx
  800511:	7e 42                	jle    800555 <vprintfmt+0x1e0>
  800513:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800517:	74 3c                	je     800555 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	51                   	push   %ecx
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	e8 6f 02 00 00       	call   800794 <strnlen>
  800525:	29 c3                	sub    %eax,%ebx
  800527:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 db                	test   %ebx,%ebx
  80052f:	7e 24                	jle    800555 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800531:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800535:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800538:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	57                   	push   %edi
  80053f:	53                   	push   %ebx
  800540:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	4e                   	dec    %esi
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	85 f6                	test   %esi,%esi
  800549:	7f f0                	jg     80053b <vprintfmt+0x1c6>
  80054b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800555:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800558:	0f be 02             	movsbl (%edx),%eax
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 47                	jne    8005a6 <vprintfmt+0x231>
  80055f:	eb 37                	jmp    800598 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800565:	74 16                	je     80057d <vprintfmt+0x208>
  800567:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056a:	83 fa 5e             	cmp    $0x5e,%edx
  80056d:	76 0e                	jbe    80057d <vprintfmt+0x208>
					putch('?', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	57                   	push   %edi
  800573:	6a 3f                	push   $0x3f
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	50                   	push   %eax
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	ff 4d e4             	decl   -0x1c(%ebp)
  80058b:	0f be 03             	movsbl (%ebx),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 03                	je     800595 <vprintfmt+0x220>
  800592:	43                   	inc    %ebx
  800593:	eb 1b                	jmp    8005b0 <vprintfmt+0x23b>
  800595:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800598:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059c:	7f 1e                	jg     8005bc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a1:	e9 f3 fd ff ff       	jmp    800399 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a9:	43                   	inc    %ebx
  8005aa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	78 ad                	js     800561 <vprintfmt+0x1ec>
  8005b4:	4e                   	dec    %esi
  8005b5:	79 aa                	jns    800561 <vprintfmt+0x1ec>
  8005b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ba:	eb dc                	jmp    800598 <vprintfmt+0x223>
  8005bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 20                	push   $0x20
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	4b                   	dec    %ebx
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	85 db                	test   %ebx,%ebx
  8005ce:	7f ef                	jg     8005bf <vprintfmt+0x24a>
  8005d0:	e9 c4 fd ff ff       	jmp    800399 <vprintfmt+0x24>
  8005d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d8:	89 ca                	mov    %ecx,%edx
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 2a fd ff ff       	call   80030c <getint>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	78 0a                	js     8005f4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 b0 00 00 00       	jmp    8006a4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	57                   	push   %edi
  8005f8:	6a 2d                	push   $0x2d
  8005fa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fd:	f7 db                	neg    %ebx
  8005ff:	83 d6 00             	adc    $0x0,%esi
  800602:	f7 de                	neg    %esi
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 93 00 00 00       	jmp    8006a4 <vprintfmt+0x32f>
  800611:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 b4 fc ff ff       	call   8002d2 <getuint>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	89 d6                	mov    %edx,%esi
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800627:	eb 7b                	jmp    8006a4 <vprintfmt+0x32f>
  800629:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 d6 fc ff ff       	call   80030c <getint>
  800636:	89 c3                	mov    %eax,%ebx
  800638:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80063a:	85 d2                	test   %edx,%edx
  80063c:	78 07                	js     800645 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80063e:	b8 08 00 00 00       	mov    $0x8,%eax
  800643:	eb 5f                	jmp    8006a4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	57                   	push   %edi
  800649:	6a 2d                	push   $0x2d
  80064b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80064e:	f7 db                	neg    %ebx
  800650:	83 d6 00             	adc    $0x0,%esi
  800653:	f7 de                	neg    %esi
  800655:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800658:	b8 08 00 00 00       	mov    $0x8,%eax
  80065d:	eb 45                	jmp    8006a4 <vprintfmt+0x32f>
  80065f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	57                   	push   %edi
  800666:	6a 30                	push   $0x30
  800668:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	57                   	push   %edi
  80066f:	6a 78                	push   $0x78
  800671:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 18                	mov    (%eax),%ebx
  80067f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068c:	eb 16                	jmp    8006a4 <vprintfmt+0x32f>
  80068e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 37 fc ff ff       	call   8002d2 <getuint>
  80069b:	89 c3                	mov    %eax,%ebx
  80069d:	89 d6                	mov    %edx,%esi
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ab:	52                   	push   %edx
  8006ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006af:	50                   	push   %eax
  8006b0:	56                   	push   %esi
  8006b1:	53                   	push   %ebx
  8006b2:	89 fa                	mov    %edi,%edx
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	e8 68 fb ff ff       	call   800224 <printnum>
			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
  8006bf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006c2:	e9 d2 fc ff ff       	jmp    800399 <vprintfmt+0x24>
  8006c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	57                   	push   %edi
  8006ce:	52                   	push   %edx
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d8:	e9 bc fc ff ff       	jmp    800399 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	57                   	push   %edi
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 02                	jmp    8006ed <vprintfmt+0x378>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006f0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f4:	75 f5                	jne    8006eb <vprintfmt+0x376>
  8006f6:	e9 9e fc ff ff       	jmp    800399 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5f                   	pop    %edi
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800712:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800716:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800719:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800720:	85 c0                	test   %eax,%eax
  800722:	74 26                	je     80074a <vsnprintf+0x47>
  800724:	85 d2                	test   %edx,%edx
  800726:	7e 29                	jle    800751 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800728:	ff 75 14             	pushl  0x14(%ebp)
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	68 3e 03 80 00       	push   $0x80033e
  800737:	e8 39 fc ff ff       	call   800375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 0c                	jmp    800756 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x53>
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 93 ff ff ff       	call   800703 <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    
	...

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3a 00             	cmpb   $0x0,(%edx)
  80077d:	74 0e                	je     80078d <strlen+0x19>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800784:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800789:	75 f9                	jne    800784 <strlen+0x10>
  80078b:	eb 05                	jmp    800792 <strlen+0x1e>
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	85 d2                	test   %edx,%edx
  80079f:	74 17                	je     8007b8 <strnlen+0x24>
  8007a1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a4:	74 19                	je     8007bf <strnlen+0x2b>
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ab:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	39 d0                	cmp    %edx,%eax
  8007ae:	74 14                	je     8007c4 <strnlen+0x30>
  8007b0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b4:	75 f5                	jne    8007ab <strnlen+0x17>
  8007b6:	eb 0c                	jmp    8007c4 <strnlen+0x30>
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	eb 05                	jmp    8007c4 <strnlen+0x30>
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007db:	42                   	inc    %edx
  8007dc:	84 c9                	test   %cl,%cl
  8007de:	75 f5                	jne    8007d5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ea:	53                   	push   %ebx
  8007eb:	e8 84 ff ff ff       	call   800774 <strlen>
  8007f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f9:	50                   	push   %eax
  8007fa:	e8 c7 ff ff ff       	call   8007c6 <strcpy>
	return dst;
}
  8007ff:	89 d8                	mov    %ebx,%eax
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800814:	85 f6                	test   %esi,%esi
  800816:	74 15                	je     80082d <strncpy+0x27>
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80081d:	8a 1a                	mov    (%edx),%bl
  80081f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800822:	80 3a 01             	cmpb   $0x1,(%edx)
  800825:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	41                   	inc    %ecx
  800829:	39 ce                	cmp    %ecx,%esi
  80082b:	77 f0                	ja     80081d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	57                   	push   %edi
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	85 f6                	test   %esi,%esi
  800842:	74 32                	je     800876 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800844:	83 fe 01             	cmp    $0x1,%esi
  800847:	74 22                	je     80086b <strlcpy+0x3a>
  800849:	8a 0b                	mov    (%ebx),%cl
  80084b:	84 c9                	test   %cl,%cl
  80084d:	74 20                	je     80086f <strlcpy+0x3e>
  80084f:	89 f8                	mov    %edi,%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800856:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	88 08                	mov    %cl,(%eax)
  80085b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085c:	39 f2                	cmp    %esi,%edx
  80085e:	74 11                	je     800871 <strlcpy+0x40>
  800860:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800864:	42                   	inc    %edx
  800865:	84 c9                	test   %cl,%cl
  800867:	75 f0                	jne    800859 <strlcpy+0x28>
  800869:	eb 06                	jmp    800871 <strlcpy+0x40>
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	eb 02                	jmp    800871 <strlcpy+0x40>
  80086f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
  800874:	eb 02                	jmp    800878 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800878:	29 f8                	sub    %edi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800888:	8a 01                	mov    (%ecx),%al
  80088a:	84 c0                	test   %al,%al
  80088c:	74 10                	je     80089e <strcmp+0x1f>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	75 0c                	jne    80089e <strcmp+0x1f>
		p++, q++;
  800892:	41                   	inc    %ecx
  800893:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800894:	8a 01                	mov    (%ecx),%al
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1f>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 f4                	je     800892 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	74 1b                	je     8008d4 <strncmp+0x2c>
  8008b9:	8a 1a                	mov    (%edx),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 24                	je     8008e3 <strncmp+0x3b>
  8008bf:	3a 19                	cmp    (%ecx),%bl
  8008c1:	75 20                	jne    8008e3 <strncmp+0x3b>
  8008c3:	48                   	dec    %eax
  8008c4:	74 15                	je     8008db <strncmp+0x33>
		n--, p++, q++;
  8008c6:	42                   	inc    %edx
  8008c7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c8:	8a 1a                	mov    (%edx),%bl
  8008ca:	84 db                	test   %bl,%bl
  8008cc:	74 15                	je     8008e3 <strncmp+0x3b>
  8008ce:	3a 19                	cmp    (%ecx),%bl
  8008d0:	74 f1                	je     8008c3 <strncmp+0x1b>
  8008d2:	eb 0f                	jmp    8008e3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb 05                	jmp    8008e0 <strncmp+0x38>
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 02             	movzbl (%edx),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb f3                	jmp    8008e0 <strncmp+0x38>

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f6:	8a 10                	mov    (%eax),%dl
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	74 18                	je     800914 <strchr+0x27>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	75 06                	jne    800906 <strchr+0x19>
  800900:	eb 17                	jmp    800919 <strchr+0x2c>
  800902:	38 ca                	cmp    %cl,%dl
  800904:	74 13                	je     800919 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800906:	40                   	inc    %eax
  800907:	8a 10                	mov    (%eax),%dl
  800909:	84 d2                	test   %dl,%dl
  80090b:	75 f5                	jne    800902 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb 05                	jmp    800919 <strchr+0x2c>
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800924:	8a 10                	mov    (%eax),%dl
  800926:	84 d2                	test   %dl,%dl
  800928:	74 11                	je     80093b <strfind+0x20>
		if (*s == c)
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	75 06                	jne    800934 <strfind+0x19>
  80092e:	eb 0b                	jmp    80093b <strfind+0x20>
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 07                	je     80093b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800934:	40                   	inc    %eax
  800935:	8a 10                	mov    (%eax),%dl
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f5                	jne    800930 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 7d 08             	mov    0x8(%ebp),%edi
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094c:	85 c9                	test   %ecx,%ecx
  80094e:	74 30                	je     800980 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800950:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800956:	75 25                	jne    80097d <memset+0x40>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 20                	jne    80097d <memset+0x40>
		c &= 0xFF;
  80095d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800960:	89 d3                	mov    %edx,%ebx
  800962:	c1 e3 08             	shl    $0x8,%ebx
  800965:	89 d6                	mov    %edx,%esi
  800967:	c1 e6 18             	shl    $0x18,%esi
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	c1 e0 10             	shl    $0x10,%eax
  80096f:	09 f0                	or     %esi,%eax
  800971:	09 d0                	or     %edx,%eax
  800973:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800975:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 03                	jmp    800980 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 34                	jae    8009cd <memmove+0x46>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2d                	jae    8009cd <memmove+0x46>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	75 1b                	jne    8009c3 <memmove+0x3c>
  8009a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ae:	75 13                	jne    8009c3 <memmove+0x3c>
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 0e                	jne    8009c3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b5:	83 ef 04             	sub    $0x4,%edi
  8009b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009be:	fd                   	std    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 07                	jmp    8009ca <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c3:	4f                   	dec    %edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 20                	jmp    8009ed <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d3:	75 13                	jne    8009e8 <memmove+0x61>
  8009d5:	a8 03                	test   $0x3,%al
  8009d7:	75 0f                	jne    8009e8 <memmove+0x61>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 0a                	jne    8009e8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009de:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 05                	jmp    8009ed <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f4:	ff 75 10             	pushl  0x10(%ebp)
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	ff 75 08             	pushl  0x8(%ebp)
  8009fd:	e8 85 ff ff ff       	call   800987 <memmove>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a10:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	85 ff                	test   %edi,%edi
  800a15:	74 32                	je     800a49 <memcmp+0x45>
		if (*s1 != *s2)
  800a17:	8a 03                	mov    (%ebx),%al
  800a19:	8a 0e                	mov    (%esi),%cl
  800a1b:	38 c8                	cmp    %cl,%al
  800a1d:	74 19                	je     800a38 <memcmp+0x34>
  800a1f:	eb 0d                	jmp    800a2e <memcmp+0x2a>
  800a21:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a25:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a29:	42                   	inc    %edx
  800a2a:	38 c8                	cmp    %cl,%al
  800a2c:	74 10                	je     800a3e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a2e:	0f b6 c0             	movzbl %al,%eax
  800a31:	0f b6 c9             	movzbl %cl,%ecx
  800a34:	29 c8                	sub    %ecx,%eax
  800a36:	eb 16                	jmp    800a4e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a38:	4f                   	dec    %edi
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	39 fa                	cmp    %edi,%edx
  800a40:	75 df                	jne    800a21 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 05                	jmp    800a4e <memcmp+0x4a>
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 12                	jae    800a74 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a62:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	75 06                	jne    800a6f <memfind+0x1c>
  800a69:	eb 09                	jmp    800a74 <memfind+0x21>
  800a6b:	38 08                	cmp    %cl,(%eax)
  800a6d:	74 05                	je     800a74 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6f:	40                   	inc    %eax
  800a70:	39 c2                	cmp    %eax,%edx
  800a72:	77 f7                	ja     800a6b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	eb 01                	jmp    800a85 <strtol+0xf>
		s++;
  800a84:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a85:	8a 02                	mov    (%edx),%al
  800a87:	3c 20                	cmp    $0x20,%al
  800a89:	74 f9                	je     800a84 <strtol+0xe>
  800a8b:	3c 09                	cmp    $0x9,%al
  800a8d:	74 f5                	je     800a84 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8f:	3c 2b                	cmp    $0x2b,%al
  800a91:	75 08                	jne    800a9b <strtol+0x25>
		s++;
  800a93:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb 13                	jmp    800aae <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9b:	3c 2d                	cmp    $0x2d,%al
  800a9d:	75 0a                	jne    800aa9 <strtol+0x33>
		s++, neg = 1;
  800a9f:	8d 52 01             	lea    0x1(%edx),%edx
  800aa2:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa7:	eb 05                	jmp    800aae <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	74 05                	je     800ab7 <strtol+0x41>
  800ab2:	83 fb 10             	cmp    $0x10,%ebx
  800ab5:	75 28                	jne    800adf <strtol+0x69>
  800ab7:	8a 02                	mov    (%edx),%al
  800ab9:	3c 30                	cmp    $0x30,%al
  800abb:	75 10                	jne    800acd <strtol+0x57>
  800abd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac1:	75 0a                	jne    800acd <strtol+0x57>
		s += 2, base = 16;
  800ac3:	83 c2 02             	add    $0x2,%edx
  800ac6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acb:	eb 12                	jmp    800adf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	75 0e                	jne    800adf <strtol+0x69>
  800ad1:	3c 30                	cmp    $0x30,%al
  800ad3:	75 05                	jne    800ada <strtol+0x64>
		s++, base = 8;
  800ad5:	42                   	inc    %edx
  800ad6:	b3 08                	mov    $0x8,%bl
  800ad8:	eb 05                	jmp    800adf <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	8a 0a                	mov    (%edx),%cl
  800ae8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aeb:	80 fb 09             	cmp    $0x9,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x82>
			dig = *s - '0';
  800af0:	0f be c9             	movsbl %cl,%ecx
  800af3:	83 e9 30             	sub    $0x30,%ecx
  800af6:	eb 1e                	jmp    800b16 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 57             	sub    $0x57,%ecx
  800b06:	eb 0e                	jmp    800b16 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 13                	ja     800b23 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b16:	39 f1                	cmp    %esi,%ecx
  800b18:	7d 0d                	jge    800b27 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b1a:	42                   	inc    %edx
  800b1b:	0f af c6             	imul   %esi,%eax
  800b1e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b21:	eb c3                	jmp    800ae6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	eb 02                	jmp    800b29 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b27:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2d:	74 05                	je     800b34 <strtol+0xbe>
		*endptr = (char *) s;
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b32:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b34:	85 ff                	test   %edi,%edi
  800b36:	74 04                	je     800b3c <strtol+0xc6>
  800b38:	89 c8                	mov    %ecx,%eax
  800b3a:	f7 d8                	neg    %eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    
  800b41:	00 00                	add    %al,(%eax)
	...

00800b44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	83 ec 10             	sub    $0x10,%esp
  800b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b52:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	75 2e                	jne    800b90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b62:	39 f1                	cmp    %esi,%ecx
  800b64:	77 5a                	ja     800bc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b66:	85 c9                	test   %ecx,%ecx
  800b68:	75 0b                	jne    800b75 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	31 d2                	xor    %edx,%edx
  800b71:	f7 f1                	div    %ecx
  800b73:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b75:	31 d2                	xor    %edx,%edx
  800b77:	89 f0                	mov    %esi,%eax
  800b79:	f7 f1                	div    %ecx
  800b7b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	f7 f1                	div    %ecx
  800b81:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b83:	89 f8                	mov    %edi,%eax
  800b85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b87:	83 c4 10             	add    $0x10,%esp
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    
  800b8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b90:	39 f0                	cmp    %esi,%eax
  800b92:	77 1c                	ja     800bb0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b94:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b97:	83 f7 1f             	xor    $0x1f,%edi
  800b9a:	75 3c                	jne    800bd8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b9c:	39 f0                	cmp    %esi,%eax
  800b9e:	0f 82 90 00 00 00    	jb     800c34 <__udivdi3+0xf0>
  800ba4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800baa:	0f 86 84 00 00 00    	jbe    800c34 <__udivdi3+0xf0>
  800bb0:	31 f6                	xor    %esi,%esi
  800bb2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb4:	89 f8                	mov    %edi,%eax
  800bb6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bb8:	83 c4 10             	add    $0x10,%esp
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    
  800bbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc0:	89 f2                	mov    %esi,%edx
  800bc2:	89 f8                	mov    %edi,%eax
  800bc4:	f7 f1                	div    %ecx
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bca:	89 f8                	mov    %edi,%eax
  800bcc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bd8:	89 f9                	mov    %edi,%ecx
  800bda:	d3 e0                	shl    %cl,%eax
  800bdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bdf:	b8 20 00 00 00       	mov    $0x20,%eax
  800be4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be9:	88 c1                	mov    %al,%cl
  800beb:	d3 ea                	shr    %cl,%edx
  800bed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bf0:	09 ca                	or     %ecx,%edx
  800bf2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf8:	89 f9                	mov    %edi,%ecx
  800bfa:	d3 e2                	shl    %cl,%edx
  800bfc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800bff:	89 f2                	mov    %esi,%edx
  800c01:	88 c1                	mov    %al,%cl
  800c03:	d3 ea                	shr    %cl,%edx
  800c05:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c08:	89 f2                	mov    %esi,%edx
  800c0a:	89 f9                	mov    %edi,%ecx
  800c0c:	d3 e2                	shl    %cl,%edx
  800c0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c11:	88 c1                	mov    %al,%cl
  800c13:	d3 ee                	shr    %cl,%esi
  800c15:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c1a:	89 f0                	mov    %esi,%eax
  800c1c:	89 ca                	mov    %ecx,%edx
  800c1e:	f7 75 ec             	divl   -0x14(%ebp)
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c25:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c28:	39 d1                	cmp    %edx,%ecx
  800c2a:	72 28                	jb     800c54 <__udivdi3+0x110>
  800c2c:	74 1a                	je     800c48 <__udivdi3+0x104>
  800c2e:	89 f7                	mov    %esi,%edi
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	eb 80                	jmp    800bb4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c34:	31 f6                	xor    %esi,%esi
  800c36:	bf 01 00 00 00       	mov    $0x1,%edi
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

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c4b:	89 f9                	mov    %edi,%ecx
  800c4d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c4f:	39 c2                	cmp    %eax,%edx
  800c51:	73 db                	jae    800c2e <__udivdi3+0xea>
  800c53:	90                   	nop
		{
		  q0--;
  800c54:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c57:	31 f6                	xor    %esi,%esi
  800c59:	e9 56 ff ff ff       	jmp    800bb4 <__udivdi3+0x70>
	...

00800c60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	83 ec 20             	sub    $0x20,%esp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c7d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c7f:	85 ff                	test   %edi,%edi
  800c81:	75 15                	jne    800c98 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c83:	39 f1                	cmp    %esi,%ecx
  800c85:	0f 86 99 00 00 00    	jbe    800d24 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c8b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c8d:	89 d0                	mov    %edx,%eax
  800c8f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c91:	83 c4 20             	add    $0x20,%esp
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c98:	39 f7                	cmp    %esi,%edi
  800c9a:	0f 87 a4 00 00 00    	ja     800d44 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ca0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ca3:	83 f0 1f             	xor    $0x1f,%eax
  800ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca9:	0f 84 a1 00 00 00    	je     800d50 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800caf:	89 f8                	mov    %edi,%eax
  800cb1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cb4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cb6:	bf 20 00 00 00       	mov    $0x20,%edi
  800cbb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 ea                	shr    %cl,%edx
  800cc5:	09 c2                	or     %eax,%edx
  800cc7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cd0:	d3 e0                	shl    %cl,%eax
  800cd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd5:	89 f2                	mov    %esi,%edx
  800cd7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cdc:	d3 e0                	shl    %cl,%eax
  800cde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce4:	89 f9                	mov    %edi,%ecx
  800ce6:	d3 e8                	shr    %cl,%eax
  800ce8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cec:	89 f2                	mov    %esi,%edx
  800cee:	f7 75 f0             	divl   -0x10(%ebp)
  800cf1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cf3:	f7 65 f4             	mull   -0xc(%ebp)
  800cf6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800cf9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cfb:	39 d6                	cmp    %edx,%esi
  800cfd:	72 71                	jb     800d70 <__umoddi3+0x110>
  800cff:	74 7f                	je     800d80 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d04:	29 c8                	sub    %ecx,%eax
  800d06:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d08:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d0b:	d3 e8                	shr    %cl,%eax
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	89 f9                	mov    %edi,%ecx
  800d11:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d13:	09 d0                	or     %edx,%eax
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d1c:	83 c4 20             	add    $0x20,%esp
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    
  800d23:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d24:	85 c9                	test   %ecx,%ecx
  800d26:	75 0b                	jne    800d33 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d28:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2d:	31 d2                	xor    %edx,%edx
  800d2f:	f7 f1                	div    %ecx
  800d31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d33:	89 f0                	mov    %esi,%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3c:	f7 f1                	div    %ecx
  800d3e:	e9 4a ff ff ff       	jmp    800c8d <__umoddi3+0x2d>
  800d43:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d46:	83 c4 20             	add    $0x20,%esp
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    
  800d4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d50:	39 f7                	cmp    %esi,%edi
  800d52:	72 05                	jb     800d59 <__umoddi3+0xf9>
  800d54:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d57:	77 0c                	ja     800d65 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d59:	89 f2                	mov    %esi,%edx
  800d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5e:	29 c8                	sub    %ecx,%eax
  800d60:	19 fa                	sbb    %edi,%edx
  800d62:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d68:	83 c4 20             	add    $0x20,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d70:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d73:	89 c1                	mov    %eax,%ecx
  800d75:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d78:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d7b:	eb 84                	jmp    800d01 <__umoddi3+0xa1>
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d83:	72 eb                	jb     800d70 <__umoddi3+0x110>
  800d85:	89 f2                	mov    %esi,%edx
  800d87:	e9 75 ff ff ff       	jmp    800d01 <__umoddi3+0xa1>
