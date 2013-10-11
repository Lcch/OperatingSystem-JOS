
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
    // cprintf("hello from A\n");
    // cprintf("hello from B\n");
 	// cprintf("hello from C\n");   

 	// my test for singal stepping
 	asm volatile("movl $0x1, %eax");
  800038:	b8 01 00 00 00       	mov    $0x1,%eax
 	asm volatile("movl $0x2, %eax");
  80003d:	b8 02 00 00 00       	mov    $0x2,%eax
}
  800042:	c9                   	leave  
  800043:	c3                   	ret    

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004f:	e8 ce 00 00 00       	call   800122 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005c:	c1 e0 05             	shl    $0x5,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x30>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	53                   	push   %ebx
  800078:	56                   	push   %esi
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0d 00 00 00       	call   800090 <exit>
  800083:	83 c4 10             	add    $0x10,%esp
}
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	c9                   	leave  
  80008c:	c3                   	ret    
  80008d:	00 00                	add    %al,(%eax)
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 44 00 00 00       	call   8000e1 <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 17                	jle    80011a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	6a 03                	push   $0x3
  800109:	68 a2 0d 80 00       	push   $0x800da2
  80010e:	6a 23                	push   $0x23
  800110:	68 bf 0d 80 00       	push   $0x800dbf
  800115:	e8 2a 00 00 00       	call   800144 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 02 00 00 00       	mov    $0x2,%eax
  800132:	89 d1                	mov    %edx,%ecx
  800134:	89 d3                	mov    %edx,%ebx
  800136:	89 d7                	mov    %edx,%edi
  800138:	89 d6                	mov    %edx,%esi
  80013a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5f                   	pop    %edi
  80013f:	c9                   	leave  
  800140:	c3                   	ret    
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800152:	e8 cb ff ff ff       	call   800122 <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	53                   	push   %ebx
  800161:	50                   	push   %eax
  800162:	68 d0 0d 80 00       	push   $0x800dd0
  800167:	e8 b0 00 00 00       	call   80021c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	56                   	push   %esi
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 53 00 00 00       	call   8001cb <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 f4 0d 80 00 	movl   $0x800df4,(%esp)
  80017f:	e8 98 00 00 00       	call   80021c <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x43>
	...

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80019f:	40                   	inc    %eax
  8001a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	75 1a                	jne    8001c3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	68 ff 00 00 00       	push   $0xff
  8001b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 ea fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8001ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c3:	ff 43 04             	incl   0x4(%ebx)
}
  8001c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001db:	00 00 00 
	b.cnt = 0;
  8001de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e8:	ff 75 0c             	pushl  0xc(%ebp)
  8001eb:	ff 75 08             	pushl  0x8(%ebp)
  8001ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f4:	50                   	push   %eax
  8001f5:	68 8c 01 80 00       	push   $0x80018c
  8001fa:	e8 82 01 00 00       	call   800381 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ff:	83 c4 08             	add    $0x8,%esp
  800202:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800208:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 90 fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800214:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800222:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800225:	50                   	push   %eax
  800226:	ff 75 08             	pushl  0x8(%ebp)
  800229:	e8 9d ff ff ff       	call   8001cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800247:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800256:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80025d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800260:	72 0c                	jb     80026e <printnum+0x3e>
  800262:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800265:	76 07                	jbe    80026e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800267:	4b                   	dec    %ebx
  800268:	85 db                	test   %ebx,%ebx
  80026a:	7f 31                	jg     80029d <printnum+0x6d>
  80026c:	eb 3f                	jmp    8002ad <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	57                   	push   %edi
  800272:	4b                   	dec    %ebx
  800273:	53                   	push   %ebx
  800274:	50                   	push   %eax
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027b:	ff 75 d0             	pushl  -0x30(%ebp)
  80027e:	ff 75 dc             	pushl  -0x24(%ebp)
  800281:	ff 75 d8             	pushl  -0x28(%ebp)
  800284:	e8 c7 08 00 00       	call   800b50 <__udivdi3>
  800289:	83 c4 18             	add    $0x18,%esp
  80028c:	52                   	push   %edx
  80028d:	50                   	push   %eax
  80028e:	89 f2                	mov    %esi,%edx
  800290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800293:	e8 98 ff ff ff       	call   800230 <printnum>
  800298:	83 c4 20             	add    $0x20,%esp
  80029b:	eb 10                	jmp    8002ad <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	57                   	push   %edi
  8002a2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	4b                   	dec    %ebx
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f f0                	jg     80029d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 a7 09 00 00       	call   800c6c <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 f6 0d 80 00 	movsbl 0x800df6(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002d3:	83 c4 10             	add    $0x10,%esp
}
  8002d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e1:	83 fa 01             	cmp    $0x1,%edx
  8002e4:	7e 0e                	jle    8002f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	8b 52 04             	mov    0x4(%edx),%edx
  8002f2:	eb 22                	jmp    800316 <getuint+0x38>
	else if (lflag)
  8002f4:	85 d2                	test   %edx,%edx
  8002f6:	74 10                	je     800308 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
  800306:	eb 0e                	jmp    800316 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800308:	8b 10                	mov    (%eax),%edx
  80030a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 02                	mov    (%edx),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031b:	83 fa 01             	cmp    $0x1,%edx
  80031e:	7e 0e                	jle    80032e <getint+0x16>
		return va_arg(*ap, long long);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 08             	lea    0x8(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	8b 52 04             	mov    0x4(%edx),%edx
  80032c:	eb 1a                	jmp    800348 <getint+0x30>
	else if (lflag)
  80032e:	85 d2                	test   %edx,%edx
  800330:	74 0c                	je     80033e <getint+0x26>
		return va_arg(*ap, long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	99                   	cltd   
  80033c:	eb 0a                	jmp    800348 <getint+0x30>
	else
		return va_arg(*ap, int);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 04             	lea    0x4(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	99                   	cltd   
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 08                	jae    800362 <sprintputch+0x18>
		*b->buf++ = ch;
  80035a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035d:	88 0a                	mov    %cl,(%edx)
  80035f:	42                   	inc    %edx
  800360:	89 10                	mov    %edx,(%eax)
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036d:	50                   	push   %eax
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	e8 05 00 00 00       	call   800381 <vprintfmt>
	va_end(ap);
  80037c:	83 c4 10             	add    $0x10,%esp
}
  80037f:	c9                   	leave  
  800380:	c3                   	ret    

00800381 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	57                   	push   %edi
  800385:	56                   	push   %esi
  800386:	53                   	push   %ebx
  800387:	83 ec 2c             	sub    $0x2c,%esp
  80038a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038d:	8b 75 10             	mov    0x10(%ebp),%esi
  800390:	eb 13                	jmp    8003a5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800392:	85 c0                	test   %eax,%eax
  800394:	0f 84 6d 03 00 00    	je     800707 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	57                   	push   %edi
  80039e:	50                   	push   %eax
  80039f:	ff 55 08             	call   *0x8(%ebp)
  8003a2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	0f b6 06             	movzbl (%esi),%eax
  8003a8:	46                   	inc    %esi
  8003a9:	83 f8 25             	cmp    $0x25,%eax
  8003ac:	75 e4                	jne    800392 <vprintfmt+0x11>
  8003ae:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003c0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cc:	eb 28                	jmp    8003f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003d4:	eb 20                	jmp    8003f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003dc:	eb 18                	jmp    8003f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003e7:	eb 0d                	jmp    8003f6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ef:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8a 06                	mov    (%esi),%al
  8003f8:	0f b6 d0             	movzbl %al,%edx
  8003fb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003fe:	83 e8 23             	sub    $0x23,%eax
  800401:	3c 55                	cmp    $0x55,%al
  800403:	0f 87 e0 02 00 00    	ja     8006e9 <vprintfmt+0x368>
  800409:	0f b6 c0             	movzbl %al,%eax
  80040c:	ff 24 85 84 0e 80 00 	jmp    *0x800e84(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800413:	83 ea 30             	sub    $0x30,%edx
  800416:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800419:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80041c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80041f:	83 fa 09             	cmp    $0x9,%edx
  800422:	77 44                	ja     800468 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 de                	mov    %ebx,%esi
  800426:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80042a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80042d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800431:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800434:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800437:	83 fb 09             	cmp    $0x9,%ebx
  80043a:	76 ed                	jbe    800429 <vprintfmt+0xa8>
  80043c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80043f:	eb 29                	jmp    80046a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800451:	eb 17                	jmp    80046a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800453:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800457:	78 85                	js     8003de <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	89 de                	mov    %ebx,%esi
  80045b:	eb 99                	jmp    8003f6 <vprintfmt+0x75>
  80045d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800466:	eb 8e                	jmp    8003f6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80046a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046e:	79 86                	jns    8003f6 <vprintfmt+0x75>
  800470:	e9 74 ff ff ff       	jmp    8003e9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800475:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 de                	mov    %ebx,%esi
  800478:	e9 79 ff ff ff       	jmp    8003f6 <vprintfmt+0x75>
  80047d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	57                   	push   %edi
  80048d:	ff 30                	pushl  (%eax)
  80048f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800498:	e9 08 ff ff ff       	jmp    8003a5 <vprintfmt+0x24>
  80049d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	79 02                	jns    8004b1 <vprintfmt+0x130>
  8004af:	f7 d8                	neg    %eax
  8004b1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b3:	83 f8 06             	cmp    $0x6,%eax
  8004b6:	7f 0b                	jg     8004c3 <vprintfmt+0x142>
  8004b8:	8b 04 85 dc 0f 80 00 	mov    0x800fdc(,%eax,4),%eax
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	75 1a                	jne    8004dd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004c3:	52                   	push   %edx
  8004c4:	68 0e 0e 80 00       	push   $0x800e0e
  8004c9:	57                   	push   %edi
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 92 fe ff ff       	call   800364 <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d8:	e9 c8 fe ff ff       	jmp    8003a5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004dd:	50                   	push   %eax
  8004de:	68 17 0e 80 00       	push   $0x800e17
  8004e3:	57                   	push   %edi
  8004e4:	ff 75 08             	pushl  0x8(%ebp)
  8004e7:	e8 78 fe ff ff       	call   800364 <printfmt>
  8004ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004f2:	e9 ae fe ff ff       	jmp    8003a5 <vprintfmt+0x24>
  8004f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004fa:	89 de                	mov    %ebx,%esi
  8004fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 50 04             	lea    0x4(%eax),%edx
  800508:	89 55 14             	mov    %edx,0x14(%ebp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800510:	85 c0                	test   %eax,%eax
  800512:	75 07                	jne    80051b <vprintfmt+0x19a>
				p = "(null)";
  800514:	c7 45 d0 07 0e 80 00 	movl   $0x800e07,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80051b:	85 db                	test   %ebx,%ebx
  80051d:	7e 42                	jle    800561 <vprintfmt+0x1e0>
  80051f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800523:	74 3c                	je     800561 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	51                   	push   %ecx
  800529:	ff 75 d0             	pushl  -0x30(%ebp)
  80052c:	e8 6f 02 00 00       	call   8007a0 <strnlen>
  800531:	29 c3                	sub    %eax,%ebx
  800533:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 db                	test   %ebx,%ebx
  80053b:	7e 24                	jle    800561 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80053d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800541:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800544:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	57                   	push   %edi
  80054b:	53                   	push   %ebx
  80054c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	4e                   	dec    %esi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	85 f6                	test   %esi,%esi
  800555:	7f f0                	jg     800547 <vprintfmt+0x1c6>
  800557:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80055a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800564:	0f be 02             	movsbl (%edx),%eax
  800567:	85 c0                	test   %eax,%eax
  800569:	75 47                	jne    8005b2 <vprintfmt+0x231>
  80056b:	eb 37                	jmp    8005a4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80056d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800571:	74 16                	je     800589 <vprintfmt+0x208>
  800573:	8d 50 e0             	lea    -0x20(%eax),%edx
  800576:	83 fa 5e             	cmp    $0x5e,%edx
  800579:	76 0e                	jbe    800589 <vprintfmt+0x208>
					putch('?', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	6a 3f                	push   $0x3f
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	eb 0b                	jmp    800594 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	57                   	push   %edi
  80058d:	50                   	push   %eax
  80058e:	ff 55 08             	call   *0x8(%ebp)
  800591:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800594:	ff 4d e4             	decl   -0x1c(%ebp)
  800597:	0f be 03             	movsbl (%ebx),%eax
  80059a:	85 c0                	test   %eax,%eax
  80059c:	74 03                	je     8005a1 <vprintfmt+0x220>
  80059e:	43                   	inc    %ebx
  80059f:	eb 1b                	jmp    8005bc <vprintfmt+0x23b>
  8005a1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a8:	7f 1e                	jg     8005c8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ad:	e9 f3 fd ff ff       	jmp    8003a5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b5:	43                   	inc    %ebx
  8005b6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005bc:	85 f6                	test   %esi,%esi
  8005be:	78 ad                	js     80056d <vprintfmt+0x1ec>
  8005c0:	4e                   	dec    %esi
  8005c1:	79 aa                	jns    80056d <vprintfmt+0x1ec>
  8005c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c6:	eb dc                	jmp    8005a4 <vprintfmt+0x223>
  8005c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	57                   	push   %edi
  8005cf:	6a 20                	push   $0x20
  8005d1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d4:	4b                   	dec    %ebx
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f ef                	jg     8005cb <vprintfmt+0x24a>
  8005dc:	e9 c4 fd ff ff       	jmp    8003a5 <vprintfmt+0x24>
  8005e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 2a fd ff ff       	call   800318 <getint>
  8005ee:	89 c3                	mov    %eax,%ebx
  8005f0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005f2:	85 d2                	test   %edx,%edx
  8005f4:	78 0a                	js     800600 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fb:	e9 b0 00 00 00       	jmp    8006b0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	57                   	push   %edi
  800604:	6a 2d                	push   $0x2d
  800606:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800609:	f7 db                	neg    %ebx
  80060b:	83 d6 00             	adc    $0x0,%esi
  80060e:	f7 de                	neg    %esi
  800610:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 93 00 00 00       	jmp    8006b0 <vprintfmt+0x32f>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 b4 fc ff ff       	call   8002de <getuint>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	89 d6                	mov    %edx,%esi
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800633:	eb 7b                	jmp    8006b0 <vprintfmt+0x32f>
  800635:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 d6 fc ff ff       	call   800318 <getint>
  800642:	89 c3                	mov    %eax,%ebx
  800644:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800646:	85 d2                	test   %edx,%edx
  800648:	78 07                	js     800651 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
  80064f:	eb 5f                	jmp    8006b0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	57                   	push   %edi
  800655:	6a 2d                	push   $0x2d
  800657:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80065a:	f7 db                	neg    %ebx
  80065c:	83 d6 00             	adc    $0x0,%esi
  80065f:	f7 de                	neg    %esi
  800661:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800664:	b8 08 00 00 00       	mov    $0x8,%eax
  800669:	eb 45                	jmp    8006b0 <vprintfmt+0x32f>
  80066b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	57                   	push   %edi
  800672:	6a 30                	push   $0x30
  800674:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	57                   	push   %edi
  80067b:	6a 78                	push   $0x78
  80067d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800689:	8b 18                	mov    (%eax),%ebx
  80068b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800690:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800698:	eb 16                	jmp    8006b0 <vprintfmt+0x32f>
  80069a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 37 fc ff ff       	call   8002de <getuint>
  8006a7:	89 c3                	mov    %eax,%ebx
  8006a9:	89 d6                	mov    %edx,%esi
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006b7:	52                   	push   %edx
  8006b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006bb:	50                   	push   %eax
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	89 fa                	mov    %edi,%edx
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	e8 68 fb ff ff       	call   800230 <printnum>
			break;
  8006c8:	83 c4 20             	add    $0x20,%esp
  8006cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ce:	e9 d2 fc ff ff       	jmp    8003a5 <vprintfmt+0x24>
  8006d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	57                   	push   %edi
  8006da:	52                   	push   %edx
  8006db:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e4:	e9 bc fc ff ff       	jmp    8003a5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	57                   	push   %edi
  8006ed:	6a 25                	push   $0x25
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb 02                	jmp    8006f9 <vprintfmt+0x378>
  8006f7:	89 c6                	mov    %eax,%esi
  8006f9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006fc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800700:	75 f5                	jne    8006f7 <vprintfmt+0x376>
  800702:	e9 9e fc ff ff       	jmp    8003a5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070a:	5b                   	pop    %ebx
  80070b:	5e                   	pop    %esi
  80070c:	5f                   	pop    %edi
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 18             	sub    $0x18,%esp
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800722:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 26                	je     800756 <vsnprintf+0x47>
  800730:	85 d2                	test   %edx,%edx
  800732:	7e 29                	jle    80075d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800734:	ff 75 14             	pushl  0x14(%ebp)
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	68 4a 03 80 00       	push   $0x80034a
  800743:	e8 39 fc ff ff       	call   800381 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	eb 0c                	jmp    800762 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb 05                	jmp    800762 <vsnprintf+0x53>
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 93 ff ff ff       	call   80070f <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    
	...

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	80 3a 00             	cmpb   $0x0,(%edx)
  800789:	74 0e                	je     800799 <strlen+0x19>
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800790:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800795:	75 f9                	jne    800790 <strlen+0x10>
  800797:	eb 05                	jmp    80079e <strlen+0x1e>
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 17                	je     8007c4 <strnlen+0x24>
  8007ad:	80 39 00             	cmpb   $0x0,(%ecx)
  8007b0:	74 19                	je     8007cb <strnlen+0x2b>
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b8:	39 d0                	cmp    %edx,%eax
  8007ba:	74 14                	je     8007d0 <strnlen+0x30>
  8007bc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c0:	75 f5                	jne    8007b7 <strnlen+0x17>
  8007c2:	eb 0c                	jmp    8007d0 <strnlen+0x30>
  8007c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c9:	eb 05                	jmp    8007d0 <strnlen+0x30>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007e7:	42                   	inc    %edx
  8007e8:	84 c9                	test   %cl,%cl
  8007ea:	75 f5                	jne    8007e1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f6:	53                   	push   %ebx
  8007f7:	e8 84 ff ff ff       	call   800780 <strlen>
  8007fc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800805:	50                   	push   %eax
  800806:	e8 c7 ff ff ff       	call   8007d2 <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	85 f6                	test   %esi,%esi
  800822:	74 15                	je     800839 <strncpy+0x27>
  800824:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800829:	8a 1a                	mov    (%edx),%bl
  80082b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082e:	80 3a 01             	cmpb   $0x1,(%edx)
  800831:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	41                   	inc    %ecx
  800835:	39 ce                	cmp    %ecx,%esi
  800837:	77 f0                	ja     800829 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800849:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 f6                	test   %esi,%esi
  80084e:	74 32                	je     800882 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800850:	83 fe 01             	cmp    $0x1,%esi
  800853:	74 22                	je     800877 <strlcpy+0x3a>
  800855:	8a 0b                	mov    (%ebx),%cl
  800857:	84 c9                	test   %cl,%cl
  800859:	74 20                	je     80087b <strlcpy+0x3e>
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800862:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800865:	88 08                	mov    %cl,(%eax)
  800867:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800868:	39 f2                	cmp    %esi,%edx
  80086a:	74 11                	je     80087d <strlcpy+0x40>
  80086c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800870:	42                   	inc    %edx
  800871:	84 c9                	test   %cl,%cl
  800873:	75 f0                	jne    800865 <strlcpy+0x28>
  800875:	eb 06                	jmp    80087d <strlcpy+0x40>
  800877:	89 f8                	mov    %edi,%eax
  800879:	eb 02                	jmp    80087d <strlcpy+0x40>
  80087b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
  800880:	eb 02                	jmp    800884 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800882:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800884:	29 f8                	sub    %edi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5f                   	pop    %edi
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	8a 01                	mov    (%ecx),%al
  800896:	84 c0                	test   %al,%al
  800898:	74 10                	je     8008aa <strcmp+0x1f>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	75 0c                	jne    8008aa <strcmp+0x1f>
		p++, q++;
  80089e:	41                   	inc    %ecx
  80089f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a0:	8a 01                	mov    (%ecx),%al
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x1f>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 f4                	je     80089e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008be:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	74 1b                	je     8008e0 <strncmp+0x2c>
  8008c5:	8a 1a                	mov    (%edx),%bl
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	74 24                	je     8008ef <strncmp+0x3b>
  8008cb:	3a 19                	cmp    (%ecx),%bl
  8008cd:	75 20                	jne    8008ef <strncmp+0x3b>
  8008cf:	48                   	dec    %eax
  8008d0:	74 15                	je     8008e7 <strncmp+0x33>
		n--, p++, q++;
  8008d2:	42                   	inc    %edx
  8008d3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d4:	8a 1a                	mov    (%edx),%bl
  8008d6:	84 db                	test   %bl,%bl
  8008d8:	74 15                	je     8008ef <strncmp+0x3b>
  8008da:	3a 19                	cmp    (%ecx),%bl
  8008dc:	74 f1                	je     8008cf <strncmp+0x1b>
  8008de:	eb 0f                	jmp    8008ef <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	eb 05                	jmp    8008ec <strncmp+0x38>
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ef:	0f b6 02             	movzbl (%edx),%eax
  8008f2:	0f b6 11             	movzbl (%ecx),%edx
  8008f5:	29 d0                	sub    %edx,%eax
  8008f7:	eb f3                	jmp    8008ec <strncmp+0x38>

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800902:	8a 10                	mov    (%eax),%dl
  800904:	84 d2                	test   %dl,%dl
  800906:	74 18                	je     800920 <strchr+0x27>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	75 06                	jne    800912 <strchr+0x19>
  80090c:	eb 17                	jmp    800925 <strchr+0x2c>
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 13                	je     800925 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	40                   	inc    %eax
  800913:	8a 10                	mov    (%eax),%dl
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f5                	jne    80090e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 05                	jmp    800925 <strchr+0x2c>
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800930:	8a 10                	mov    (%eax),%dl
  800932:	84 d2                	test   %dl,%dl
  800934:	74 11                	je     800947 <strfind+0x20>
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	75 06                	jne    800940 <strfind+0x19>
  80093a:	eb 0b                	jmp    800947 <strfind+0x20>
  80093c:	38 ca                	cmp    %cl,%dl
  80093e:	74 07                	je     800947 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800940:	40                   	inc    %eax
  800941:	8a 10                	mov    (%eax),%dl
  800943:	84 d2                	test   %dl,%dl
  800945:	75 f5                	jne    80093c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 30                	je     80098c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 25                	jne    800989 <memset+0x40>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 20                	jne    800989 <memset+0x40>
		c &= 0xFF;
  800969:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096c:	89 d3                	mov    %edx,%ebx
  80096e:	c1 e3 08             	shl    $0x8,%ebx
  800971:	89 d6                	mov    %edx,%esi
  800973:	c1 e6 18             	shl    $0x18,%esi
  800976:	89 d0                	mov    %edx,%eax
  800978:	c1 e0 10             	shl    $0x10,%eax
  80097b:	09 f0                	or     %esi,%eax
  80097d:	09 d0                	or     %edx,%eax
  80097f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800981:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800984:	fc                   	cld    
  800985:	f3 ab                	rep stos %eax,%es:(%edi)
  800987:	eb 03                	jmp    80098c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800989:	fc                   	cld    
  80098a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098c:	89 f8                	mov    %edi,%eax
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a1:	39 c6                	cmp    %eax,%esi
  8009a3:	73 34                	jae    8009d9 <memmove+0x46>
  8009a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a8:	39 d0                	cmp    %edx,%eax
  8009aa:	73 2d                	jae    8009d9 <memmove+0x46>
		s += n;
		d += n;
  8009ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	f6 c2 03             	test   $0x3,%dl
  8009b2:	75 1b                	jne    8009cf <memmove+0x3c>
  8009b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ba:	75 13                	jne    8009cf <memmove+0x3c>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 0e                	jne    8009cf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 07                	jmp    8009d6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cf:	4f                   	dec    %edi
  8009d0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d6:	fc                   	cld    
  8009d7:	eb 20                	jmp    8009f9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009df:	75 13                	jne    8009f4 <memmove+0x61>
  8009e1:	a8 03                	test   $0x3,%al
  8009e3:	75 0f                	jne    8009f4 <memmove+0x61>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 0a                	jne    8009f4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ea:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f2:	eb 05                	jmp    8009f9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f4:	89 c7                	mov    %eax,%edi
  8009f6:	fc                   	cld    
  8009f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f9:	5e                   	pop    %esi
  8009fa:	5f                   	pop    %edi
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a00:	ff 75 10             	pushl  0x10(%ebp)
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	ff 75 08             	pushl  0x8(%ebp)
  800a09:	e8 85 ff ff ff       	call   800993 <memmove>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	85 ff                	test   %edi,%edi
  800a21:	74 32                	je     800a55 <memcmp+0x45>
		if (*s1 != *s2)
  800a23:	8a 03                	mov    (%ebx),%al
  800a25:	8a 0e                	mov    (%esi),%cl
  800a27:	38 c8                	cmp    %cl,%al
  800a29:	74 19                	je     800a44 <memcmp+0x34>
  800a2b:	eb 0d                	jmp    800a3a <memcmp+0x2a>
  800a2d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a31:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a35:	42                   	inc    %edx
  800a36:	38 c8                	cmp    %cl,%al
  800a38:	74 10                	je     800a4a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c0             	movzbl %al,%eax
  800a3d:	0f b6 c9             	movzbl %cl,%ecx
  800a40:	29 c8                	sub    %ecx,%eax
  800a42:	eb 16                	jmp    800a5a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a44:	4f                   	dec    %edi
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	39 fa                	cmp    %edi,%edx
  800a4c:	75 df                	jne    800a2d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	eb 05                	jmp    800a5a <memcmp+0x4a>
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a65:	89 c2                	mov    %eax,%edx
  800a67:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6a:	39 d0                	cmp    %edx,%eax
  800a6c:	73 12                	jae    800a80 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a71:	38 08                	cmp    %cl,(%eax)
  800a73:	75 06                	jne    800a7b <memfind+0x1c>
  800a75:	eb 09                	jmp    800a80 <memfind+0x21>
  800a77:	38 08                	cmp    %cl,(%eax)
  800a79:	74 05                	je     800a80 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7b:	40                   	inc    %eax
  800a7c:	39 c2                	cmp    %eax,%edx
  800a7e:	77 f7                	ja     800a77 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8e:	eb 01                	jmp    800a91 <strtol+0xf>
		s++;
  800a90:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a91:	8a 02                	mov    (%edx),%al
  800a93:	3c 20                	cmp    $0x20,%al
  800a95:	74 f9                	je     800a90 <strtol+0xe>
  800a97:	3c 09                	cmp    $0x9,%al
  800a99:	74 f5                	je     800a90 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9b:	3c 2b                	cmp    $0x2b,%al
  800a9d:	75 08                	jne    800aa7 <strtol+0x25>
		s++;
  800a9f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa5:	eb 13                	jmp    800aba <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa7:	3c 2d                	cmp    $0x2d,%al
  800aa9:	75 0a                	jne    800ab5 <strtol+0x33>
		s++, neg = 1;
  800aab:	8d 52 01             	lea    0x1(%edx),%edx
  800aae:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab3:	eb 05                	jmp    800aba <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	85 db                	test   %ebx,%ebx
  800abc:	74 05                	je     800ac3 <strtol+0x41>
  800abe:	83 fb 10             	cmp    $0x10,%ebx
  800ac1:	75 28                	jne    800aeb <strtol+0x69>
  800ac3:	8a 02                	mov    (%edx),%al
  800ac5:	3c 30                	cmp    $0x30,%al
  800ac7:	75 10                	jne    800ad9 <strtol+0x57>
  800ac9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acd:	75 0a                	jne    800ad9 <strtol+0x57>
		s += 2, base = 16;
  800acf:	83 c2 02             	add    $0x2,%edx
  800ad2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad7:	eb 12                	jmp    800aeb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad9:	85 db                	test   %ebx,%ebx
  800adb:	75 0e                	jne    800aeb <strtol+0x69>
  800add:	3c 30                	cmp    $0x30,%al
  800adf:	75 05                	jne    800ae6 <strtol+0x64>
		s++, base = 8;
  800ae1:	42                   	inc    %edx
  800ae2:	b3 08                	mov    $0x8,%bl
  800ae4:	eb 05                	jmp    800aeb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800af0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af2:	8a 0a                	mov    (%edx),%cl
  800af4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af7:	80 fb 09             	cmp    $0x9,%bl
  800afa:	77 08                	ja     800b04 <strtol+0x82>
			dig = *s - '0';
  800afc:	0f be c9             	movsbl %cl,%ecx
  800aff:	83 e9 30             	sub    $0x30,%ecx
  800b02:	eb 1e                	jmp    800b22 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b04:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b0c:	0f be c9             	movsbl %cl,%ecx
  800b0f:	83 e9 57             	sub    $0x57,%ecx
  800b12:	eb 0e                	jmp    800b22 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b17:	80 fb 19             	cmp    $0x19,%bl
  800b1a:	77 13                	ja     800b2f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b1c:	0f be c9             	movsbl %cl,%ecx
  800b1f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b22:	39 f1                	cmp    %esi,%ecx
  800b24:	7d 0d                	jge    800b33 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b26:	42                   	inc    %edx
  800b27:	0f af c6             	imul   %esi,%eax
  800b2a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b2d:	eb c3                	jmp    800af2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b2f:	89 c1                	mov    %eax,%ecx
  800b31:	eb 02                	jmp    800b35 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b33:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b39:	74 05                	je     800b40 <strtol+0xbe>
		*endptr = (char *) s;
  800b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b40:	85 ff                	test   %edi,%edi
  800b42:	74 04                	je     800b48 <strtol+0xc6>
  800b44:	89 c8                	mov    %ecx,%eax
  800b46:	f7 d8                	neg    %eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    
  800b4d:	00 00                	add    %al,(%eax)
	...

00800b50 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	83 ec 10             	sub    $0x10,%esp
  800b58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b5e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b64:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b67:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	75 2e                	jne    800b9c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b6e:	39 f1                	cmp    %esi,%ecx
  800b70:	77 5a                	ja     800bcc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b72:	85 c9                	test   %ecx,%ecx
  800b74:	75 0b                	jne    800b81 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b76:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7b:	31 d2                	xor    %edx,%edx
  800b7d:	f7 f1                	div    %ecx
  800b7f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b81:	31 d2                	xor    %edx,%edx
  800b83:	89 f0                	mov    %esi,%eax
  800b85:	f7 f1                	div    %ecx
  800b87:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b89:	89 f8                	mov    %edi,%eax
  800b8b:	f7 f1                	div    %ecx
  800b8d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b8f:	89 f8                	mov    %edi,%eax
  800b91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    
  800b9a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b9c:	39 f0                	cmp    %esi,%eax
  800b9e:	77 1c                	ja     800bbc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ba0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800ba3:	83 f7 1f             	xor    $0x1f,%edi
  800ba6:	75 3c                	jne    800be4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	0f 82 90 00 00 00    	jb     800c40 <__udivdi3+0xf0>
  800bb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bb3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bb6:	0f 86 84 00 00 00    	jbe    800c40 <__udivdi3+0xf0>
  800bbc:	31 f6                	xor    %esi,%esi
  800bbe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc0:	89 f8                	mov    %edi,%eax
  800bc2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    
  800bcb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	89 f8                	mov    %edi,%eax
  800bd0:	f7 f1                	div    %ecx
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bda:	83 c4 10             	add    $0x10,%esp
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    
  800be1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800be4:	89 f9                	mov    %edi,%ecx
  800be6:	d3 e0                	shl    %cl,%eax
  800be8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800beb:	b8 20 00 00 00       	mov    $0x20,%eax
  800bf0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf5:	88 c1                	mov    %al,%cl
  800bf7:	d3 ea                	shr    %cl,%edx
  800bf9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bfc:	09 ca                	or     %ecx,%edx
  800bfe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c04:	89 f9                	mov    %edi,%ecx
  800c06:	d3 e2                	shl    %cl,%edx
  800c08:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c0b:	89 f2                	mov    %esi,%edx
  800c0d:	88 c1                	mov    %al,%cl
  800c0f:	d3 ea                	shr    %cl,%edx
  800c11:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c14:	89 f2                	mov    %esi,%edx
  800c16:	89 f9                	mov    %edi,%ecx
  800c18:	d3 e2                	shl    %cl,%edx
  800c1a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c1d:	88 c1                	mov    %al,%cl
  800c1f:	d3 ee                	shr    %cl,%esi
  800c21:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c23:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c26:	89 f0                	mov    %esi,%eax
  800c28:	89 ca                	mov    %ecx,%edx
  800c2a:	f7 75 ec             	divl   -0x14(%ebp)
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c31:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c34:	39 d1                	cmp    %edx,%ecx
  800c36:	72 28                	jb     800c60 <__udivdi3+0x110>
  800c38:	74 1a                	je     800c54 <__udivdi3+0x104>
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	31 f6                	xor    %esi,%esi
  800c3e:	eb 80                	jmp    800bc0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c40:	31 f6                	xor    %esi,%esi
  800c42:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c47:	89 f8                	mov    %edi,%eax
  800c49:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    
  800c52:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c57:	89 f9                	mov    %edi,%ecx
  800c59:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c5b:	39 c2                	cmp    %eax,%edx
  800c5d:	73 db                	jae    800c3a <__udivdi3+0xea>
  800c5f:	90                   	nop
		{
		  q0--;
  800c60:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c63:	31 f6                	xor    %esi,%esi
  800c65:	e9 56 ff ff ff       	jmp    800bc0 <__udivdi3+0x70>
	...

00800c6c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	83 ec 20             	sub    $0x20,%esp
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c83:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c89:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c8b:	85 ff                	test   %edi,%edi
  800c8d:	75 15                	jne    800ca4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c8f:	39 f1                	cmp    %esi,%ecx
  800c91:	0f 86 99 00 00 00    	jbe    800d30 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c97:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c99:	89 d0                	mov    %edx,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c9d:	83 c4 20             	add    $0x20,%esp
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ca4:	39 f7                	cmp    %esi,%edi
  800ca6:	0f 87 a4 00 00 00    	ja     800d50 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800caf:	83 f0 1f             	xor    $0x1f,%eax
  800cb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb5:	0f 84 a1 00 00 00    	je     800d5c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cc2:	bf 20 00 00 00       	mov    $0x20,%edi
  800cc7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ccd:	89 f9                	mov    %edi,%ecx
  800ccf:	d3 ea                	shr    %cl,%edx
  800cd1:	09 c2                	or     %eax,%edx
  800cd3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cdc:	d3 e0                	shl    %cl,%eax
  800cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ce1:	89 f2                	mov    %esi,%edx
  800ce3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ce5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce8:	d3 e0                	shl    %cl,%eax
  800cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf0:	89 f9                	mov    %edi,%ecx
  800cf2:	d3 e8                	shr    %cl,%eax
  800cf4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800cf6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cf8:	89 f2                	mov    %esi,%edx
  800cfa:	f7 75 f0             	divl   -0x10(%ebp)
  800cfd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cff:	f7 65 f4             	mull   -0xc(%ebp)
  800d02:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d05:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	72 71                	jb     800d7c <__umoddi3+0x110>
  800d0b:	74 7f                	je     800d8c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d10:	29 c8                	sub    %ecx,%eax
  800d12:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d14:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d17:	d3 e8                	shr    %cl,%eax
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d1f:	09 d0                	or     %edx,%eax
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d26:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d28:	83 c4 20             	add    $0x20,%esp
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    
  800d2f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d30:	85 c9                	test   %ecx,%ecx
  800d32:	75 0b                	jne    800d3f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d34:	b8 01 00 00 00       	mov    $0x1,%eax
  800d39:	31 d2                	xor    %edx,%edx
  800d3b:	f7 f1                	div    %ecx
  800d3d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d3f:	89 f0                	mov    %esi,%eax
  800d41:	31 d2                	xor    %edx,%edx
  800d43:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d48:	f7 f1                	div    %ecx
  800d4a:	e9 4a ff ff ff       	jmp    800c99 <__umoddi3+0x2d>
  800d4f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d52:	83 c4 20             	add    $0x20,%esp
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    
  800d59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d5c:	39 f7                	cmp    %esi,%edi
  800d5e:	72 05                	jb     800d65 <__umoddi3+0xf9>
  800d60:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d63:	77 0c                	ja     800d71 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6a:	29 c8                	sub    %ecx,%eax
  800d6c:	19 fa                	sbb    %edi,%edx
  800d6e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d74:	83 c4 20             	add    $0x20,%esp
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    
  800d7b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d7c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d7f:	89 c1                	mov    %eax,%ecx
  800d81:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d84:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d87:	eb 84                	jmp    800d0d <__umoddi3+0xa1>
  800d89:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d8f:	72 eb                	jb     800d7c <__umoddi3+0x110>
  800d91:	89 f2                	mov    %esi,%edx
  800d93:	e9 75 ff ff ff       	jmp    800d0d <__umoddi3+0xa1>
