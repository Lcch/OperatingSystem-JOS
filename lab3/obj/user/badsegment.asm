
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
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004b:	e8 ce 00 00 00       	call   80011e <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800058:	c1 e0 05             	shl    $0x5,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x30>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	53                   	push   %ebx
  800074:	56                   	push   %esi
  800075:	e8 ba ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007a:	e8 0d 00 00 00       	call   80008c <exit>
  80007f:	83 c4 10             	add    $0x10,%esp
}
  800082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800085:	5b                   	pop    %ebx
  800086:	5e                   	pop    %esi
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 44 00 00 00       	call   8000dd <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	c9                   	leave  
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 17                	jle    800116 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	50                   	push   %eax
  800103:	6a 03                	push   $0x3
  800105:	68 9e 0d 80 00       	push   $0x800d9e
  80010a:	6a 23                	push   $0x23
  80010c:	68 bb 0d 80 00       	push   $0x800dbb
  800111:	e8 2a 00 00 00       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
  80013d:	00 00                	add    %al,(%eax)
	...

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80014e:	e8 cb ff ff ff       	call   80011e <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	53                   	push   %ebx
  80015d:	50                   	push   %eax
  80015e:	68 cc 0d 80 00       	push   $0x800dcc
  800163:	e8 b0 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	56                   	push   %esi
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 53 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 f0 0d 80 00 	movl   $0x800df0,(%esp)
  80017b:	e8 98 00 00 00       	call   800218 <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x43>
	...

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	53                   	push   %ebx
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800192:	8b 03                	mov    (%ebx),%eax
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80019b:	40                   	inc    %eax
  80019c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a3:	75 1a                	jne    8001bf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	68 ff 00 00 00       	push   $0xff
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ea fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bf:	ff 43 04             	incl   0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 88 01 80 00       	push   $0x800188
  8001f6:	e8 82 01 00 00       	call   80037d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 90 fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 2c             	sub    $0x2c,%esp
  800235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800238:	89 d6                	mov    %edx,%esi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800243:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800246:	8b 45 10             	mov    0x10(%ebp),%eax
  800249:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80024c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800252:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800259:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80025c:	72 0c                	jb     80026a <printnum+0x3e>
  80025e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800261:	76 07                	jbe    80026a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800263:	4b                   	dec    %ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f 31                	jg     800299 <printnum+0x6d>
  800268:	eb 3f                	jmp    8002a9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	57                   	push   %edi
  80026e:	4b                   	dec    %ebx
  80026f:	53                   	push   %ebx
  800270:	50                   	push   %eax
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	ff 75 d4             	pushl  -0x2c(%ebp)
  800277:	ff 75 d0             	pushl  -0x30(%ebp)
  80027a:	ff 75 dc             	pushl  -0x24(%ebp)
  80027d:	ff 75 d8             	pushl  -0x28(%ebp)
  800280:	e8 c7 08 00 00       	call   800b4c <__udivdi3>
  800285:	83 c4 18             	add    $0x18,%esp
  800288:	52                   	push   %edx
  800289:	50                   	push   %eax
  80028a:	89 f2                	mov    %esi,%edx
  80028c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028f:	e8 98 ff ff ff       	call   80022c <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 10                	jmp    8002a9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	57                   	push   %edi
  80029e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	4b                   	dec    %ebx
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f f0                	jg     800299 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bc:	e8 a7 09 00 00       	call   800c68 <__umoddi3>
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	0f be 80 f2 0d 80 00 	movsbl 0x800df2(%eax),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff 55 e4             	call   *-0x1c(%ebp)
  8002cf:	83 c4 10             	add    $0x10,%esp
}
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002dd:	83 fa 01             	cmp    $0x1,%edx
  8002e0:	7e 0e                	jle    8002f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ee:	eb 22                	jmp    800312 <getuint+0x38>
	else if (lflag)
  8002f0:	85 d2                	test   %edx,%edx
  8002f2:	74 10                	je     800304 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	eb 0e                	jmp    800312 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800317:	83 fa 01             	cmp    $0x1,%edx
  80031a:	7e 0e                	jle    80032a <getint+0x16>
		return va_arg(*ap, long long);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	8b 52 04             	mov    0x4(%edx),%edx
  800328:	eb 1a                	jmp    800344 <getint+0x30>
	else if (lflag)
  80032a:	85 d2                	test   %edx,%edx
  80032c:	74 0c                	je     80033a <getint+0x26>
		return va_arg(*ap, long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 04             	lea    0x4(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	99                   	cltd   
  800338:	eb 0a                	jmp    800344 <getint+0x30>
	else
		return va_arg(*ap, int);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	99                   	cltd   
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	3b 50 04             	cmp    0x4(%eax),%edx
  800354:	73 08                	jae    80035e <sprintputch+0x18>
		*b->buf++ = ch;
  800356:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800359:	88 0a                	mov    %cl,(%edx)
  80035b:	42                   	inc    %edx
  80035c:	89 10                	mov    %edx,(%eax)
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800366:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800369:	50                   	push   %eax
  80036a:	ff 75 10             	pushl  0x10(%ebp)
  80036d:	ff 75 0c             	pushl  0xc(%ebp)
  800370:	ff 75 08             	pushl  0x8(%ebp)
  800373:	e8 05 00 00 00       	call   80037d <vprintfmt>
	va_end(ap);
  800378:	83 c4 10             	add    $0x10,%esp
}
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    

0080037d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 2c             	sub    $0x2c,%esp
  800386:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800389:	8b 75 10             	mov    0x10(%ebp),%esi
  80038c:	eb 13                	jmp    8003a1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038e:	85 c0                	test   %eax,%eax
  800390:	0f 84 6d 03 00 00    	je     800703 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	57                   	push   %edi
  80039a:	50                   	push   %eax
  80039b:	ff 55 08             	call   *0x8(%ebp)
  80039e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a1:	0f b6 06             	movzbl (%esi),%eax
  8003a4:	46                   	inc    %esi
  8003a5:	83 f8 25             	cmp    $0x25,%eax
  8003a8:	75 e4                	jne    80038e <vprintfmt+0x11>
  8003aa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003bc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c8:	eb 28                	jmp    8003f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003cc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003d0:	eb 20                	jmp    8003f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d8:	eb 18                	jmp    8003f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003e3:	eb 0d                	jmp    8003f2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8a 06                	mov    (%esi),%al
  8003f4:	0f b6 d0             	movzbl %al,%edx
  8003f7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003fa:	83 e8 23             	sub    $0x23,%eax
  8003fd:	3c 55                	cmp    $0x55,%al
  8003ff:	0f 87 e0 02 00 00    	ja     8006e5 <vprintfmt+0x368>
  800405:	0f b6 c0             	movzbl %al,%eax
  800408:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040f:	83 ea 30             	sub    $0x30,%edx
  800412:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800415:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800418:	8d 50 d0             	lea    -0x30(%eax),%edx
  80041b:	83 fa 09             	cmp    $0x9,%edx
  80041e:	77 44                	ja     800464 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	89 de                	mov    %ebx,%esi
  800422:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800425:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800426:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800429:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80042d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800430:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800433:	83 fb 09             	cmp    $0x9,%ebx
  800436:	76 ed                	jbe    800425 <vprintfmt+0xa8>
  800438:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80043b:	eb 29                	jmp    800466 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 00                	mov    (%eax),%eax
  800448:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044d:	eb 17                	jmp    800466 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80044f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800453:	78 85                	js     8003da <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	89 de                	mov    %ebx,%esi
  800457:	eb 99                	jmp    8003f2 <vprintfmt+0x75>
  800459:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800462:	eb 8e                	jmp    8003f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800466:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046a:	79 86                	jns    8003f2 <vprintfmt+0x75>
  80046c:	e9 74 ff ff ff       	jmp    8003e5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800471:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	89 de                	mov    %ebx,%esi
  800474:	e9 79 ff ff ff       	jmp    8003f2 <vprintfmt+0x75>
  800479:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	57                   	push   %edi
  800489:	ff 30                	pushl  (%eax)
  80048b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800494:	e9 08 ff ff ff       	jmp    8003a1 <vprintfmt+0x24>
  800499:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	8b 00                	mov    (%eax),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	79 02                	jns    8004ad <vprintfmt+0x130>
  8004ab:	f7 d8                	neg    %eax
  8004ad:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004af:	83 f8 06             	cmp    $0x6,%eax
  8004b2:	7f 0b                	jg     8004bf <vprintfmt+0x142>
  8004b4:	8b 04 85 d8 0f 80 00 	mov    0x800fd8(,%eax,4),%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	75 1a                	jne    8004d9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004bf:	52                   	push   %edx
  8004c0:	68 0a 0e 80 00       	push   $0x800e0a
  8004c5:	57                   	push   %edi
  8004c6:	ff 75 08             	pushl  0x8(%ebp)
  8004c9:	e8 92 fe ff ff       	call   800360 <printfmt>
  8004ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d4:	e9 c8 fe ff ff       	jmp    8003a1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004d9:	50                   	push   %eax
  8004da:	68 13 0e 80 00       	push   $0x800e13
  8004df:	57                   	push   %edi
  8004e0:	ff 75 08             	pushl  0x8(%ebp)
  8004e3:	e8 78 fe ff ff       	call   800360 <printfmt>
  8004e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ee:	e9 ae fe ff ff       	jmp    8003a1 <vprintfmt+0x24>
  8004f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004f6:	89 de                	mov    %ebx,%esi
  8004f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80050c:	85 c0                	test   %eax,%eax
  80050e:	75 07                	jne    800517 <vprintfmt+0x19a>
				p = "(null)";
  800510:	c7 45 d0 03 0e 80 00 	movl   $0x800e03,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800517:	85 db                	test   %ebx,%ebx
  800519:	7e 42                	jle    80055d <vprintfmt+0x1e0>
  80051b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80051f:	74 3c                	je     80055d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	51                   	push   %ecx
  800525:	ff 75 d0             	pushl  -0x30(%ebp)
  800528:	e8 6f 02 00 00       	call   80079c <strnlen>
  80052d:	29 c3                	sub    %eax,%ebx
  80052f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 db                	test   %ebx,%ebx
  800537:	7e 24                	jle    80055d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800539:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80053d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800540:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	57                   	push   %edi
  800547:	53                   	push   %ebx
  800548:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	4e                   	dec    %esi
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 f6                	test   %esi,%esi
  800551:	7f f0                	jg     800543 <vprintfmt+0x1c6>
  800553:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800556:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800560:	0f be 02             	movsbl (%edx),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	75 47                	jne    8005ae <vprintfmt+0x231>
  800567:	eb 37                	jmp    8005a0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800569:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056d:	74 16                	je     800585 <vprintfmt+0x208>
  80056f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800572:	83 fa 5e             	cmp    $0x5e,%edx
  800575:	76 0e                	jbe    800585 <vprintfmt+0x208>
					putch('?', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	57                   	push   %edi
  80057b:	6a 3f                	push   $0x3f
  80057d:	ff 55 08             	call   *0x8(%ebp)
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	57                   	push   %edi
  800589:	50                   	push   %eax
  80058a:	ff 55 08             	call   *0x8(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	ff 4d e4             	decl   -0x1c(%ebp)
  800593:	0f be 03             	movsbl (%ebx),%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	74 03                	je     80059d <vprintfmt+0x220>
  80059a:	43                   	inc    %ebx
  80059b:	eb 1b                	jmp    8005b8 <vprintfmt+0x23b>
  80059d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a4:	7f 1e                	jg     8005c4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a9:	e9 f3 fd ff ff       	jmp    8003a1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b1:	43                   	inc    %ebx
  8005b2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 ad                	js     800569 <vprintfmt+0x1ec>
  8005bc:	4e                   	dec    %esi
  8005bd:	79 aa                	jns    800569 <vprintfmt+0x1ec>
  8005bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c2:	eb dc                	jmp    8005a0 <vprintfmt+0x223>
  8005c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	57                   	push   %edi
  8005cb:	6a 20                	push   $0x20
  8005cd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	4b                   	dec    %ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 db                	test   %ebx,%ebx
  8005d6:	7f ef                	jg     8005c7 <vprintfmt+0x24a>
  8005d8:	e9 c4 fd ff ff       	jmp    8003a1 <vprintfmt+0x24>
  8005dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e0:	89 ca                	mov    %ecx,%edx
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 2a fd ff ff       	call   800314 <getint>
  8005ea:	89 c3                	mov    %eax,%ebx
  8005ec:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 b0 00 00 00       	jmp    8006ac <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	57                   	push   %edi
  800600:	6a 2d                	push   $0x2d
  800602:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800605:	f7 db                	neg    %ebx
  800607:	83 d6 00             	adc    $0x0,%esi
  80060a:	f7 de                	neg    %esi
  80060c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800614:	e9 93 00 00 00       	jmp    8006ac <vprintfmt+0x32f>
  800619:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061c:	89 ca                	mov    %ecx,%edx
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 b4 fc ff ff       	call   8002da <getuint>
  800626:	89 c3                	mov    %eax,%ebx
  800628:	89 d6                	mov    %edx,%esi
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062f:	eb 7b                	jmp    8006ac <vprintfmt+0x32f>
  800631:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800634:	89 ca                	mov    %ecx,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 d6 fc ff ff       	call   800314 <getint>
  80063e:	89 c3                	mov    %eax,%ebx
  800640:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800642:	85 d2                	test   %edx,%edx
  800644:	78 07                	js     80064d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
  80064b:	eb 5f                	jmp    8006ac <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	57                   	push   %edi
  800651:	6a 2d                	push   $0x2d
  800653:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800656:	f7 db                	neg    %ebx
  800658:	83 d6 00             	adc    $0x0,%esi
  80065b:	f7 de                	neg    %esi
  80065d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800660:	b8 08 00 00 00       	mov    $0x8,%eax
  800665:	eb 45                	jmp    8006ac <vprintfmt+0x32f>
  800667:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	57                   	push   %edi
  80066e:	6a 30                	push   $0x30
  800670:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	57                   	push   %edi
  800677:	6a 78                	push   $0x78
  800679:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800685:	8b 18                	mov    (%eax),%ebx
  800687:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800694:	eb 16                	jmp    8006ac <vprintfmt+0x32f>
  800696:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 37 fc ff ff       	call   8002da <getuint>
  8006a3:	89 c3                	mov    %eax,%ebx
  8006a5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006b3:	52                   	push   %edx
  8006b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b7:	50                   	push   %eax
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	89 fa                	mov    %edi,%edx
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	e8 68 fb ff ff       	call   80022c <printnum>
			break;
  8006c4:	83 c4 20             	add    $0x20,%esp
  8006c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ca:	e9 d2 fc ff ff       	jmp    8003a1 <vprintfmt+0x24>
  8006cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	57                   	push   %edi
  8006d6:	52                   	push   %edx
  8006d7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e0:	e9 bc fc ff ff       	jmp    8003a1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	57                   	push   %edi
  8006e9:	6a 25                	push   $0x25
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	eb 02                	jmp    8006f5 <vprintfmt+0x378>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006f8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006fc:	75 f5                	jne    8006f3 <vprintfmt+0x376>
  8006fe:	e9 9e fc ff ff       	jmp    8003a1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 29                	jle    800759 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 46 03 80 00       	push   $0x800346
  80073f:	e8 39 fc ff ff       	call   80037d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 0c                	jmp    80075e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800757:	eb 05                	jmp    80075e <vsnprintf+0x53>
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 10             	pushl  0x10(%ebp)
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	ff 75 08             	pushl  0x8(%ebp)
  800773:	e8 93 ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    
	...

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3a 00             	cmpb   $0x0,(%edx)
  800785:	74 0e                	je     800795 <strlen+0x19>
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80078c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f9                	jne    80078c <strlen+0x10>
  800793:	eb 05                	jmp    80079a <strlen+0x1e>
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 17                	je     8007c0 <strnlen+0x24>
  8007a9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007ac:	74 19                	je     8007c7 <strnlen+0x2b>
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	39 d0                	cmp    %edx,%eax
  8007b6:	74 14                	je     8007cc <strnlen+0x30>
  8007b8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bc:	75 f5                	jne    8007b3 <strnlen+0x17>
  8007be:	eb 0c                	jmp    8007cc <strnlen+0x30>
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 05                	jmp    8007cc <strnlen+0x30>
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007dd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007e0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e3:	42                   	inc    %edx
  8007e4:	84 c9                	test   %cl,%cl
  8007e6:	75 f5                	jne    8007dd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f2:	53                   	push   %ebx
  8007f3:	e8 84 ff ff ff       	call   80077c <strlen>
  8007f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fb:	ff 75 0c             	pushl  0xc(%ebp)
  8007fe:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800801:	50                   	push   %eax
  800802:	e8 c7 ff ff ff       	call   8007ce <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	85 f6                	test   %esi,%esi
  80081e:	74 15                	je     800835 <strncpy+0x27>
  800820:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800825:	8a 1a                	mov    (%edx),%bl
  800827:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082a:	80 3a 01             	cmpb   $0x1,(%edx)
  80082d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800830:	41                   	inc    %ecx
  800831:	39 ce                	cmp    %ecx,%esi
  800833:	77 f0                	ja     800825 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	57                   	push   %edi
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800845:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 f6                	test   %esi,%esi
  80084a:	74 32                	je     80087e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80084c:	83 fe 01             	cmp    $0x1,%esi
  80084f:	74 22                	je     800873 <strlcpy+0x3a>
  800851:	8a 0b                	mov    (%ebx),%cl
  800853:	84 c9                	test   %cl,%cl
  800855:	74 20                	je     800877 <strlcpy+0x3e>
  800857:	89 f8                	mov    %edi,%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80085e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800861:	88 08                	mov    %cl,(%eax)
  800863:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800864:	39 f2                	cmp    %esi,%edx
  800866:	74 11                	je     800879 <strlcpy+0x40>
  800868:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80086c:	42                   	inc    %edx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	75 f0                	jne    800861 <strlcpy+0x28>
  800871:	eb 06                	jmp    800879 <strlcpy+0x40>
  800873:	89 f8                	mov    %edi,%eax
  800875:	eb 02                	jmp    800879 <strlcpy+0x40>
  800877:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
  80087c:	eb 02                	jmp    800880 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800880:	29 f8                	sub    %edi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	8a 01                	mov    (%ecx),%al
  800892:	84 c0                	test   %al,%al
  800894:	74 10                	je     8008a6 <strcmp+0x1f>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	75 0c                	jne    8008a6 <strcmp+0x1f>
		p++, q++;
  80089a:	41                   	inc    %ecx
  80089b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089c:	8a 01                	mov    (%ecx),%al
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 04                	je     8008a6 <strcmp+0x1f>
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	74 f4                	je     80089a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 c0             	movzbl %al,%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ba:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	74 1b                	je     8008dc <strncmp+0x2c>
  8008c1:	8a 1a                	mov    (%edx),%bl
  8008c3:	84 db                	test   %bl,%bl
  8008c5:	74 24                	je     8008eb <strncmp+0x3b>
  8008c7:	3a 19                	cmp    (%ecx),%bl
  8008c9:	75 20                	jne    8008eb <strncmp+0x3b>
  8008cb:	48                   	dec    %eax
  8008cc:	74 15                	je     8008e3 <strncmp+0x33>
		n--, p++, q++;
  8008ce:	42                   	inc    %edx
  8008cf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d0:	8a 1a                	mov    (%edx),%bl
  8008d2:	84 db                	test   %bl,%bl
  8008d4:	74 15                	je     8008eb <strncmp+0x3b>
  8008d6:	3a 19                	cmp    (%ecx),%bl
  8008d8:	74 f1                	je     8008cb <strncmp+0x1b>
  8008da:	eb 0f                	jmp    8008eb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb 05                	jmp    8008e8 <strncmp+0x38>
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 02             	movzbl (%edx),%eax
  8008ee:	0f b6 11             	movzbl (%ecx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb f3                	jmp    8008e8 <strncmp+0x38>

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	8a 10                	mov    (%eax),%dl
  800900:	84 d2                	test   %dl,%dl
  800902:	74 18                	je     80091c <strchr+0x27>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	75 06                	jne    80090e <strchr+0x19>
  800908:	eb 17                	jmp    800921 <strchr+0x2c>
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	74 13                	je     800921 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090e:	40                   	inc    %eax
  80090f:	8a 10                	mov    (%eax),%dl
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f5                	jne    80090a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb 05                	jmp    800921 <strchr+0x2c>
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092c:	8a 10                	mov    (%eax),%dl
  80092e:	84 d2                	test   %dl,%dl
  800930:	74 11                	je     800943 <strfind+0x20>
		if (*s == c)
  800932:	38 ca                	cmp    %cl,%dl
  800934:	75 06                	jne    80093c <strfind+0x19>
  800936:	eb 0b                	jmp    800943 <strfind+0x20>
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 07                	je     800943 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093c:	40                   	inc    %eax
  80093d:	8a 10                	mov    (%eax),%dl
  80093f:	84 d2                	test   %dl,%dl
  800941:	75 f5                	jne    800938 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 30                	je     800988 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095e:	75 25                	jne    800985 <memset+0x40>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 20                	jne    800985 <memset+0x40>
		c &= 0xFF;
  800965:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800968:	89 d3                	mov    %edx,%ebx
  80096a:	c1 e3 08             	shl    $0x8,%ebx
  80096d:	89 d6                	mov    %edx,%esi
  80096f:	c1 e6 18             	shl    $0x18,%esi
  800972:	89 d0                	mov    %edx,%eax
  800974:	c1 e0 10             	shl    $0x10,%eax
  800977:	09 f0                	or     %esi,%eax
  800979:	09 d0                	or     %edx,%eax
  80097b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb 03                	jmp    800988 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800985:	fc                   	cld    
  800986:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800988:	89 f8                	mov    %edi,%eax
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099d:	39 c6                	cmp    %eax,%esi
  80099f:	73 34                	jae    8009d5 <memmove+0x46>
  8009a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a4:	39 d0                	cmp    %edx,%eax
  8009a6:	73 2d                	jae    8009d5 <memmove+0x46>
		s += n;
		d += n;
  8009a8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ab:	f6 c2 03             	test   $0x3,%dl
  8009ae:	75 1b                	jne    8009cb <memmove+0x3c>
  8009b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b6:	75 13                	jne    8009cb <memmove+0x3c>
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 0e                	jne    8009cb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009bd:	83 ef 04             	sub    $0x4,%edi
  8009c0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c6:	fd                   	std    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb 07                	jmp    8009d2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cb:	4f                   	dec    %edi
  8009cc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cf:	fd                   	std    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d2:	fc                   	cld    
  8009d3:	eb 20                	jmp    8009f5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009db:	75 13                	jne    8009f0 <memmove+0x61>
  8009dd:	a8 03                	test   $0x3,%al
  8009df:	75 0f                	jne    8009f0 <memmove+0x61>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 0a                	jne    8009f0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 05                	jmp    8009f5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fc:	ff 75 10             	pushl  0x10(%ebp)
  8009ff:	ff 75 0c             	pushl  0xc(%ebp)
  800a02:	ff 75 08             	pushl  0x8(%ebp)
  800a05:	e8 85 ff ff ff       	call   80098f <memmove>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a18:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	85 ff                	test   %edi,%edi
  800a1d:	74 32                	je     800a51 <memcmp+0x45>
		if (*s1 != *s2)
  800a1f:	8a 03                	mov    (%ebx),%al
  800a21:	8a 0e                	mov    (%esi),%cl
  800a23:	38 c8                	cmp    %cl,%al
  800a25:	74 19                	je     800a40 <memcmp+0x34>
  800a27:	eb 0d                	jmp    800a36 <memcmp+0x2a>
  800a29:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a2d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a31:	42                   	inc    %edx
  800a32:	38 c8                	cmp    %cl,%al
  800a34:	74 10                	je     800a46 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 c9             	movzbl %cl,%ecx
  800a3c:	29 c8                	sub    %ecx,%eax
  800a3e:	eb 16                	jmp    800a56 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	4f                   	dec    %edi
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	39 fa                	cmp    %edi,%edx
  800a48:	75 df                	jne    800a29 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	eb 05                	jmp    800a56 <memcmp+0x4a>
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	73 12                	jae    800a7c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a6d:	38 08                	cmp    %cl,(%eax)
  800a6f:	75 06                	jne    800a77 <memfind+0x1c>
  800a71:	eb 09                	jmp    800a7c <memfind+0x21>
  800a73:	38 08                	cmp    %cl,(%eax)
  800a75:	74 05                	je     800a7c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a77:	40                   	inc    %eax
  800a78:	39 c2                	cmp    %eax,%edx
  800a7a:	77 f7                	ja     800a73 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	eb 01                	jmp    800a8d <strtol+0xf>
		s++;
  800a8c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8d:	8a 02                	mov    (%edx),%al
  800a8f:	3c 20                	cmp    $0x20,%al
  800a91:	74 f9                	je     800a8c <strtol+0xe>
  800a93:	3c 09                	cmp    $0x9,%al
  800a95:	74 f5                	je     800a8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a97:	3c 2b                	cmp    $0x2b,%al
  800a99:	75 08                	jne    800aa3 <strtol+0x25>
		s++;
  800a9b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa1:	eb 13                	jmp    800ab6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa3:	3c 2d                	cmp    $0x2d,%al
  800aa5:	75 0a                	jne    800ab1 <strtol+0x33>
		s++, neg = 1;
  800aa7:	8d 52 01             	lea    0x1(%edx),%edx
  800aaa:	bf 01 00 00 00       	mov    $0x1,%edi
  800aaf:	eb 05                	jmp    800ab6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	74 05                	je     800abf <strtol+0x41>
  800aba:	83 fb 10             	cmp    $0x10,%ebx
  800abd:	75 28                	jne    800ae7 <strtol+0x69>
  800abf:	8a 02                	mov    (%edx),%al
  800ac1:	3c 30                	cmp    $0x30,%al
  800ac3:	75 10                	jne    800ad5 <strtol+0x57>
  800ac5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac9:	75 0a                	jne    800ad5 <strtol+0x57>
		s += 2, base = 16;
  800acb:	83 c2 02             	add    $0x2,%edx
  800ace:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad3:	eb 12                	jmp    800ae7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad5:	85 db                	test   %ebx,%ebx
  800ad7:	75 0e                	jne    800ae7 <strtol+0x69>
  800ad9:	3c 30                	cmp    $0x30,%al
  800adb:	75 05                	jne    800ae2 <strtol+0x64>
		s++, base = 8;
  800add:	42                   	inc    %edx
  800ade:	b3 08                	mov    $0x8,%bl
  800ae0:	eb 05                	jmp    800ae7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aee:	8a 0a                	mov    (%edx),%cl
  800af0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af3:	80 fb 09             	cmp    $0x9,%bl
  800af6:	77 08                	ja     800b00 <strtol+0x82>
			dig = *s - '0';
  800af8:	0f be c9             	movsbl %cl,%ecx
  800afb:	83 e9 30             	sub    $0x30,%ecx
  800afe:	eb 1e                	jmp    800b1e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b00:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 08                	ja     800b10 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b08:	0f be c9             	movsbl %cl,%ecx
  800b0b:	83 e9 57             	sub    $0x57,%ecx
  800b0e:	eb 0e                	jmp    800b1e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b10:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 13                	ja     800b2b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b18:	0f be c9             	movsbl %cl,%ecx
  800b1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1e:	39 f1                	cmp    %esi,%ecx
  800b20:	7d 0d                	jge    800b2f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b22:	42                   	inc    %edx
  800b23:	0f af c6             	imul   %esi,%eax
  800b26:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b29:	eb c3                	jmp    800aee <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b2b:	89 c1                	mov    %eax,%ecx
  800b2d:	eb 02                	jmp    800b31 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b35:	74 05                	je     800b3c <strtol+0xbe>
		*endptr = (char *) s;
  800b37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	74 04                	je     800b44 <strtol+0xc6>
  800b40:	89 c8                	mov    %ecx,%eax
  800b42:	f7 d8                	neg    %eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    
  800b49:	00 00                	add    %al,(%eax)
	...

00800b4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	83 ec 10             	sub    $0x10,%esp
  800b54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b5a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b60:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b63:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b66:	85 c0                	test   %eax,%eax
  800b68:	75 2e                	jne    800b98 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b6a:	39 f1                	cmp    %esi,%ecx
  800b6c:	77 5a                	ja     800bc8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b6e:	85 c9                	test   %ecx,%ecx
  800b70:	75 0b                	jne    800b7d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b72:	b8 01 00 00 00       	mov    $0x1,%eax
  800b77:	31 d2                	xor    %edx,%edx
  800b79:	f7 f1                	div    %ecx
  800b7b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b7d:	31 d2                	xor    %edx,%edx
  800b7f:	89 f0                	mov    %esi,%eax
  800b81:	f7 f1                	div    %ecx
  800b83:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b85:	89 f8                	mov    %edi,%eax
  800b87:	f7 f1                	div    %ecx
  800b89:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b8b:	89 f8                	mov    %edi,%eax
  800b8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b8f:	83 c4 10             	add    $0x10,%esp
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    
  800b96:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b98:	39 f0                	cmp    %esi,%eax
  800b9a:	77 1c                	ja     800bb8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b9c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b9f:	83 f7 1f             	xor    $0x1f,%edi
  800ba2:	75 3c                	jne    800be0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ba4:	39 f0                	cmp    %esi,%eax
  800ba6:	0f 82 90 00 00 00    	jb     800c3c <__udivdi3+0xf0>
  800bac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800baf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bb2:	0f 86 84 00 00 00    	jbe    800c3c <__udivdi3+0xf0>
  800bb8:	31 f6                	xor    %esi,%esi
  800bba:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bbc:	89 f8                	mov    %edi,%eax
  800bbe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    
  800bc7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	89 f8                	mov    %edi,%eax
  800bcc:	f7 f1                	div    %ecx
  800bce:	89 c7                	mov    %eax,%edi
  800bd0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bd2:	89 f8                	mov    %edi,%eax
  800bd4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800be0:	89 f9                	mov    %edi,%ecx
  800be2:	d3 e0                	shl    %cl,%eax
  800be4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800be7:	b8 20 00 00 00       	mov    $0x20,%eax
  800bec:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf1:	88 c1                	mov    %al,%cl
  800bf3:	d3 ea                	shr    %cl,%edx
  800bf5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bf8:	09 ca                	or     %ecx,%edx
  800bfa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c00:	89 f9                	mov    %edi,%ecx
  800c02:	d3 e2                	shl    %cl,%edx
  800c04:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c07:	89 f2                	mov    %esi,%edx
  800c09:	88 c1                	mov    %al,%cl
  800c0b:	d3 ea                	shr    %cl,%edx
  800c0d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c10:	89 f2                	mov    %esi,%edx
  800c12:	89 f9                	mov    %edi,%ecx
  800c14:	d3 e2                	shl    %cl,%edx
  800c16:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c19:	88 c1                	mov    %al,%cl
  800c1b:	d3 ee                	shr    %cl,%esi
  800c1d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	89 ca                	mov    %ecx,%edx
  800c26:	f7 75 ec             	divl   -0x14(%ebp)
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c2d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c30:	39 d1                	cmp    %edx,%ecx
  800c32:	72 28                	jb     800c5c <__udivdi3+0x110>
  800c34:	74 1a                	je     800c50 <__udivdi3+0x104>
  800c36:	89 f7                	mov    %esi,%edi
  800c38:	31 f6                	xor    %esi,%esi
  800c3a:	eb 80                	jmp    800bbc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c3c:	31 f6                	xor    %esi,%esi
  800c3e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c43:	89 f8                	mov    %edi,%eax
  800c45:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    
  800c4e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c53:	89 f9                	mov    %edi,%ecx
  800c55:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c57:	39 c2                	cmp    %eax,%edx
  800c59:	73 db                	jae    800c36 <__udivdi3+0xea>
  800c5b:	90                   	nop
		{
		  q0--;
  800c5c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c5f:	31 f6                	xor    %esi,%esi
  800c61:	e9 56 ff ff ff       	jmp    800bbc <__udivdi3+0x70>
	...

00800c68 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	83 ec 20             	sub    $0x20,%esp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c79:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c7c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c85:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c87:	85 ff                	test   %edi,%edi
  800c89:	75 15                	jne    800ca0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c8b:	39 f1                	cmp    %esi,%ecx
  800c8d:	0f 86 99 00 00 00    	jbe    800d2c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c93:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c95:	89 d0                	mov    %edx,%eax
  800c97:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c99:	83 c4 20             	add    $0x20,%esp
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ca0:	39 f7                	cmp    %esi,%edi
  800ca2:	0f 87 a4 00 00 00    	ja     800d4c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ca8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cab:	83 f0 1f             	xor    $0x1f,%eax
  800cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb1:	0f 84 a1 00 00 00    	je     800d58 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cbc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cbe:	bf 20 00 00 00       	mov    $0x20,%edi
  800cc3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	d3 ea                	shr    %cl,%edx
  800ccd:	09 c2                	or     %eax,%edx
  800ccf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cd8:	d3 e0                	shl    %cl,%eax
  800cda:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cdd:	89 f2                	mov    %esi,%edx
  800cdf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce4:	d3 e0                	shl    %cl,%eax
  800ce6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cec:	89 f9                	mov    %edi,%ecx
  800cee:	d3 e8                	shr    %cl,%eax
  800cf0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cf2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cf4:	89 f2                	mov    %esi,%edx
  800cf6:	f7 75 f0             	divl   -0x10(%ebp)
  800cf9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cfb:	f7 65 f4             	mull   -0xc(%ebp)
  800cfe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d01:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d03:	39 d6                	cmp    %edx,%esi
  800d05:	72 71                	jb     800d78 <__umoddi3+0x110>
  800d07:	74 7f                	je     800d88 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d0c:	29 c8                	sub    %ecx,%eax
  800d0e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d10:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	89 f9                	mov    %edi,%ecx
  800d19:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d1b:	09 d0                	or     %edx,%eax
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d22:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d24:	83 c4 20             	add    $0x20,%esp
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    
  800d2b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	75 0b                	jne    800d3b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f1                	div    %ecx
  800d39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	31 d2                	xor    %edx,%edx
  800d3f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d44:	f7 f1                	div    %ecx
  800d46:	e9 4a ff ff ff       	jmp    800c95 <__umoddi3+0x2d>
  800d4b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d4c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d4e:	83 c4 20             	add    $0x20,%esp
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d58:	39 f7                	cmp    %esi,%edi
  800d5a:	72 05                	jb     800d61 <__umoddi3+0xf9>
  800d5c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d5f:	77 0c                	ja     800d6d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d61:	89 f2                	mov    %esi,%edx
  800d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d66:	29 c8                	sub    %ecx,%eax
  800d68:	19 fa                	sbb    %edi,%edx
  800d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d70:	83 c4 20             	add    $0x20,%esp
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    
  800d77:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d78:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d7b:	89 c1                	mov    %eax,%ecx
  800d7d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d80:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d83:	eb 84                	jmp    800d09 <__umoddi3+0xa1>
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d88:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d8b:	72 eb                	jb     800d78 <__umoddi3+0x110>
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	e9 75 ff ff ff       	jmp    800d09 <__umoddi3+0xa1>
