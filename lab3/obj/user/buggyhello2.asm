
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
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
  800045:	e8 b3 00 00 00       	call   8000fd <sys_cputs>
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
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005b:	e8 09 01 00 00       	call   800169 <sys_getenvid>
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800068:	c1 e0 05             	shl    $0x5,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x30>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004
	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	53                   	push   %ebx
  800084:	56                   	push   %esi
  800085:	e8 aa ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0d 00 00 00       	call   80009c <exit>
  80008f:	83 c4 10             	add    $0x10,%esp
}
  800092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 9e 00 00 00       	call   800147 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 1c             	sub    $0x1c,%esp
  8000b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	cd 30                	int    $0x30
  8000cf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d5:	74 1c                	je     8000f3 <syscall+0x43>
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	7e 18                	jle    8000f3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e2:	68 fc 0d 80 00       	push   $0x800dfc
  8000e7:	6a 42                	push   $0x42
  8000e9:	68 19 0e 80 00       	push   $0x800e19
  8000ee:	e8 9d 00 00 00       	call   800190 <_panic>

	return ret;
}
  8000f3:	89 d0                	mov    %edx,%eax
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800103:	6a 00                	push   $0x0
  800105:	6a 00                	push   $0x0
  800107:	6a 00                	push   $0x0
  800109:	ff 75 0c             	pushl  0xc(%ebp)
  80010c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010f:	ba 00 00 00 00       	mov    $0x0,%edx
  800114:	b8 00 00 00 00       	mov    $0x0,%eax
  800119:	e8 92 ff ff ff       	call   8000b0 <syscall>
  80011e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <sys_cgetc>:

int
sys_cgetc(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	b9 00 00 00 00       	mov    $0x0,%ecx
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	b8 01 00 00 00       	mov    $0x1,%eax
  800140:	e8 6b ff ff ff       	call   8000b0 <syscall>
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800158:	ba 01 00 00 00       	mov    $0x1,%edx
  80015d:	b8 03 00 00 00       	mov    $0x3,%eax
  800162:	e8 49 ff ff ff       	call   8000b0 <syscall>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017c:	ba 00 00 00 00       	mov    $0x0,%edx
  800181:	b8 02 00 00 00       	mov    $0x2,%eax
  800186:	e8 25 ff ff ff       	call   8000b0 <syscall>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800195:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800198:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80019e:	e8 c6 ff ff ff       	call   800169 <sys_getenvid>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 0c             	pushl  0xc(%ebp)
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	53                   	push   %ebx
  8001ad:	50                   	push   %eax
  8001ae:	68 28 0e 80 00       	push   $0x800e28
  8001b3:	e8 b0 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	56                   	push   %esi
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	e8 53 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001c4:	c7 04 24 f0 0d 80 00 	movl   $0x800df0,(%esp)
  8001cb:	e8 98 00 00 00       	call   800268 <cprintf>
  8001d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d3:	cc                   	int3   
  8001d4:	eb fd                	jmp    8001d3 <_panic+0x43>
	...

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e2:	8b 03                	mov    (%ebx),%eax
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001eb:	40                   	inc    %eax
  8001ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	75 1a                	jne    80020f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	68 ff 00 00 00       	push   $0xff
  8001fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800200:	50                   	push   %eax
  800201:	e8 f7 fe ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  800206:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020f:	ff 43 04             	incl   0x4(%ebx)
}
  800212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800220:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800227:	00 00 00 
	b.cnt = 0;
  80022a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800231:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800234:	ff 75 0c             	pushl  0xc(%ebp)
  800237:	ff 75 08             	pushl  0x8(%ebp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	50                   	push   %eax
  800241:	68 d8 01 80 00       	push   $0x8001d8
  800246:	e8 82 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 9d fe ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 08             	pushl  0x8(%ebp)
  800275:	e8 9d ff ff ff       	call   800217 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 2c             	sub    $0x2c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d6                	mov    %edx,%esi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800290:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800293:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800296:	8b 45 10             	mov    0x10(%ebp),%eax
  800299:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002ac:	72 0c                	jb     8002ba <printnum+0x3e>
  8002ae:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002b1:	76 07                	jbe    8002ba <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b3:	4b                   	dec    %ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f 31                	jg     8002e9 <printnum+0x6d>
  8002b8:	eb 3f                	jmp    8002f9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	57                   	push   %edi
  8002be:	4b                   	dec    %ebx
  8002bf:	53                   	push   %ebx
  8002c0:	50                   	push   %eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 c7 08 00 00       	call   800b9c <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002df:	e8 98 ff ff ff       	call   80027c <printnum>
  8002e4:	83 c4 20             	add    $0x20,%esp
  8002e7:	eb 10                	jmp    8002f9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	56                   	push   %esi
  8002ed:	57                   	push   %edi
  8002ee:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f1:	4b                   	dec    %ebx
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	85 db                	test   %ebx,%ebx
  8002f7:	7f f0                	jg     8002e9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	56                   	push   %esi
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	ff 75 d4             	pushl  -0x2c(%ebp)
  800303:	ff 75 d0             	pushl  -0x30(%ebp)
  800306:	ff 75 dc             	pushl  -0x24(%ebp)
  800309:	ff 75 d8             	pushl  -0x28(%ebp)
  80030c:	e8 a7 09 00 00       	call   800cb8 <__umoddi3>
  800311:	83 c4 14             	add    $0x14,%esp
  800314:	0f be 80 4c 0e 80 00 	movsbl 0x800e4c(%eax),%eax
  80031b:	50                   	push   %eax
  80031c:	ff 55 e4             	call   *-0x1c(%ebp)
  80031f:	83 c4 10             	add    $0x10,%esp
}
  800322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800367:	83 fa 01             	cmp    $0x1,%edx
  80036a:	7e 0e                	jle    80037a <getint+0x16>
		return va_arg(*ap, long long);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	8b 52 04             	mov    0x4(%edx),%edx
  800378:	eb 1a                	jmp    800394 <getint+0x30>
	else if (lflag)
  80037a:	85 d2                	test   %edx,%edx
  80037c:	74 0c                	je     80038a <getint+0x26>
		return va_arg(*ap, long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 04             	lea    0x4(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	99                   	cltd   
  800388:	eb 0a                	jmp    800394 <getint+0x30>
	else
		return va_arg(*ap, int);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	99                   	cltd   
}
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a4:	73 08                	jae    8003ae <sprintputch+0x18>
		*b->buf++ = ch;
  8003a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a9:	88 0a                	mov    %cl,(%edx)
  8003ab:	42                   	inc    %edx
  8003ac:	89 10                	mov    %edx,(%eax)
}
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b9:	50                   	push   %eax
  8003ba:	ff 75 10             	pushl  0x10(%ebp)
  8003bd:	ff 75 0c             	pushl  0xc(%ebp)
  8003c0:	ff 75 08             	pushl  0x8(%ebp)
  8003c3:	e8 05 00 00 00       	call   8003cd <vprintfmt>
	va_end(ap);
  8003c8:	83 c4 10             	add    $0x10,%esp
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 2c             	sub    $0x2c,%esp
  8003d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003dc:	eb 13                	jmp    8003f1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	0f 84 6d 03 00 00    	je     800753 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	57                   	push   %edi
  8003ea:	50                   	push   %eax
  8003eb:	ff 55 08             	call   *0x8(%ebp)
  8003ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f1:	0f b6 06             	movzbl (%esi),%eax
  8003f4:	46                   	inc    %esi
  8003f5:	83 f8 25             	cmp    $0x25,%eax
  8003f8:	75 e4                	jne    8003de <vprintfmt+0x11>
  8003fa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003fe:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800405:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80040c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800413:	b9 00 00 00 00       	mov    $0x0,%ecx
  800418:	eb 28                	jmp    800442 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800420:	eb 20                	jmp    800442 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800424:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800428:	eb 18                	jmp    800442 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80042c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800433:	eb 0d                	jmp    800442 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800435:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8a 06                	mov    (%esi),%al
  800444:	0f b6 d0             	movzbl %al,%edx
  800447:	8d 5e 01             	lea    0x1(%esi),%ebx
  80044a:	83 e8 23             	sub    $0x23,%eax
  80044d:	3c 55                	cmp    $0x55,%al
  80044f:	0f 87 e0 02 00 00    	ja     800735 <vprintfmt+0x368>
  800455:	0f b6 c0             	movzbl %al,%eax
  800458:	ff 24 85 dc 0e 80 00 	jmp    *0x800edc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045f:	83 ea 30             	sub    $0x30,%edx
  800462:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800465:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800468:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046b:	83 fa 09             	cmp    $0x9,%edx
  80046e:	77 44                	ja     8004b4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	89 de                	mov    %ebx,%esi
  800472:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800476:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800479:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80047d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800480:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800483:	83 fb 09             	cmp    $0x9,%ebx
  800486:	76 ed                	jbe    800475 <vprintfmt+0xa8>
  800488:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80048b:	eb 29                	jmp    8004b6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049d:	eb 17                	jmp    8004b6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	78 85                	js     80042a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	89 de                	mov    %ebx,%esi
  8004a7:	eb 99                	jmp    800442 <vprintfmt+0x75>
  8004a9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004b2:	eb 8e                	jmp    800442 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ba:	79 86                	jns    800442 <vprintfmt+0x75>
  8004bc:	e9 74 ff ff ff       	jmp    800435 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	89 de                	mov    %ebx,%esi
  8004c4:	e9 79 ff ff ff       	jmp    800442 <vprintfmt+0x75>
  8004c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	57                   	push   %edi
  8004d9:	ff 30                	pushl  (%eax)
  8004db:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e4:	e9 08 ff ff ff       	jmp    8003f1 <vprintfmt+0x24>
  8004e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 02                	jns    8004fd <vprintfmt+0x130>
  8004fb:	f7 d8                	neg    %eax
  8004fd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ff:	83 f8 06             	cmp    $0x6,%eax
  800502:	7f 0b                	jg     80050f <vprintfmt+0x142>
  800504:	8b 04 85 34 10 80 00 	mov    0x801034(,%eax,4),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	75 1a                	jne    800529 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80050f:	52                   	push   %edx
  800510:	68 64 0e 80 00       	push   $0x800e64
  800515:	57                   	push   %edi
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 92 fe ff ff       	call   8003b0 <printfmt>
  80051e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800524:	e9 c8 fe ff ff       	jmp    8003f1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800529:	50                   	push   %eax
  80052a:	68 6d 0e 80 00       	push   $0x800e6d
  80052f:	57                   	push   %edi
  800530:	ff 75 08             	pushl  0x8(%ebp)
  800533:	e8 78 fe ff ff       	call   8003b0 <printfmt>
  800538:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80053e:	e9 ae fe ff ff       	jmp    8003f1 <vprintfmt+0x24>
  800543:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800546:	89 de                	mov    %ebx,%esi
  800548:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80054b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80055c:	85 c0                	test   %eax,%eax
  80055e:	75 07                	jne    800567 <vprintfmt+0x19a>
				p = "(null)";
  800560:	c7 45 d0 5d 0e 80 00 	movl   $0x800e5d,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800567:	85 db                	test   %ebx,%ebx
  800569:	7e 42                	jle    8005ad <vprintfmt+0x1e0>
  80056b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80056f:	74 3c                	je     8005ad <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	51                   	push   %ecx
  800575:	ff 75 d0             	pushl  -0x30(%ebp)
  800578:	e8 6f 02 00 00       	call   8007ec <strnlen>
  80057d:	29 c3                	sub    %eax,%ebx
  80057f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	85 db                	test   %ebx,%ebx
  800587:	7e 24                	jle    8005ad <vprintfmt+0x1e0>
					putch(padc, putdat);
  800589:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80058d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800590:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	57                   	push   %edi
  800597:	53                   	push   %ebx
  800598:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	4e                   	dec    %esi
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	85 f6                	test   %esi,%esi
  8005a1:	7f f0                	jg     800593 <vprintfmt+0x1c6>
  8005a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b0:	0f be 02             	movsbl (%edx),%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	75 47                	jne    8005fe <vprintfmt+0x231>
  8005b7:	eb 37                	jmp    8005f0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bd:	74 16                	je     8005d5 <vprintfmt+0x208>
  8005bf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c2:	83 fa 5e             	cmp    $0x5e,%edx
  8005c5:	76 0e                	jbe    8005d5 <vprintfmt+0x208>
					putch('?', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	57                   	push   %edi
  8005cb:	6a 3f                	push   $0x3f
  8005cd:	ff 55 08             	call   *0x8(%ebp)
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	eb 0b                	jmp    8005e0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	57                   	push   %edi
  8005d9:	50                   	push   %eax
  8005da:	ff 55 08             	call   *0x8(%ebp)
  8005dd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e3:	0f be 03             	movsbl (%ebx),%eax
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	74 03                	je     8005ed <vprintfmt+0x220>
  8005ea:	43                   	inc    %ebx
  8005eb:	eb 1b                	jmp    800608 <vprintfmt+0x23b>
  8005ed:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f4:	7f 1e                	jg     800614 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f9:	e9 f3 fd ff ff       	jmp    8003f1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800601:	43                   	inc    %ebx
  800602:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800605:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 ad                	js     8005b9 <vprintfmt+0x1ec>
  80060c:	4e                   	dec    %esi
  80060d:	79 aa                	jns    8005b9 <vprintfmt+0x1ec>
  80060f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800612:	eb dc                	jmp    8005f0 <vprintfmt+0x223>
  800614:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	57                   	push   %edi
  80061b:	6a 20                	push   $0x20
  80061d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800620:	4b                   	dec    %ebx
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f ef                	jg     800617 <vprintfmt+0x24a>
  800628:	e9 c4 fd ff ff       	jmp    8003f1 <vprintfmt+0x24>
  80062d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 2a fd ff ff       	call   800364 <getint>
  80063a:	89 c3                	mov    %eax,%ebx
  80063c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80063e:	85 d2                	test   %edx,%edx
  800640:	78 0a                	js     80064c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 b0 00 00 00       	jmp    8006fc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	57                   	push   %edi
  800650:	6a 2d                	push   $0x2d
  800652:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800655:	f7 db                	neg    %ebx
  800657:	83 d6 00             	adc    $0x0,%esi
  80065a:	f7 de                	neg    %esi
  80065c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800664:	e9 93 00 00 00       	jmp    8006fc <vprintfmt+0x32f>
  800669:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	89 ca                	mov    %ecx,%edx
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 b4 fc ff ff       	call   80032a <getuint>
  800676:	89 c3                	mov    %eax,%ebx
  800678:	89 d6                	mov    %edx,%esi
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067f:	eb 7b                	jmp    8006fc <vprintfmt+0x32f>
  800681:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 d6 fc ff ff       	call   800364 <getint>
  80068e:	89 c3                	mov    %eax,%ebx
  800690:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800692:	85 d2                	test   %edx,%edx
  800694:	78 07                	js     80069d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800696:	b8 08 00 00 00       	mov    $0x8,%eax
  80069b:	eb 5f                	jmp    8006fc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	57                   	push   %edi
  8006a1:	6a 2d                	push   $0x2d
  8006a3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006a6:	f7 db                	neg    %ebx
  8006a8:	83 d6 00             	adc    $0x0,%esi
  8006ab:	f7 de                	neg    %esi
  8006ad:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b5:	eb 45                	jmp    8006fc <vprintfmt+0x32f>
  8006b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	57                   	push   %edi
  8006be:	6a 30                	push   $0x30
  8006c0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	57                   	push   %edi
  8006c7:	6a 78                	push   $0x78
  8006c9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d5:	8b 18                	mov    (%eax),%ebx
  8006d7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006dc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e4:	eb 16                	jmp    8006fc <vprintfmt+0x32f>
  8006e6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 37 fc ff ff       	call   80032a <getuint>
  8006f3:	89 c3                	mov    %eax,%ebx
  8006f5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	83 ec 0c             	sub    $0xc,%esp
  8006ff:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800703:	52                   	push   %edx
  800704:	ff 75 e4             	pushl  -0x1c(%ebp)
  800707:	50                   	push   %eax
  800708:	56                   	push   %esi
  800709:	53                   	push   %ebx
  80070a:	89 fa                	mov    %edi,%edx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	e8 68 fb ff ff       	call   80027c <printnum>
			break;
  800714:	83 c4 20             	add    $0x20,%esp
  800717:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80071a:	e9 d2 fc ff ff       	jmp    8003f1 <vprintfmt+0x24>
  80071f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	57                   	push   %edi
  800726:	52                   	push   %edx
  800727:	ff 55 08             	call   *0x8(%ebp)
			break;
  80072a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800730:	e9 bc fc ff ff       	jmp    8003f1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	57                   	push   %edi
  800739:	6a 25                	push   $0x25
  80073b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 02                	jmp    800745 <vprintfmt+0x378>
  800743:	89 c6                	mov    %eax,%esi
  800745:	8d 46 ff             	lea    -0x1(%esi),%eax
  800748:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074c:	75 f5                	jne    800743 <vprintfmt+0x376>
  80074e:	e9 9e fc ff ff       	jmp    8003f1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800753:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5f                   	pop    %edi
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 18             	sub    $0x18,%esp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 26                	je     8007a2 <vsnprintf+0x47>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 29                	jle    8007a9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800780:	ff 75 14             	pushl  0x14(%ebp)
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	68 96 03 80 00       	push   $0x800396
  80078f:	e8 39 fc ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 0c                	jmp    8007ae <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb 05                	jmp    8007ae <vsnprintf+0x53>
  8007a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 93 ff ff ff       	call   80075b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    
	...

008007cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d5:	74 0e                	je     8007e5 <strlen+0x19>
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007dc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e1:	75 f9                	jne    8007dc <strlen+0x10>
  8007e3:	eb 05                	jmp    8007ea <strlen+0x1e>
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 17                	je     800810 <strnlen+0x24>
  8007f9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007fc:	74 19                	je     800817 <strnlen+0x2b>
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800803:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	39 d0                	cmp    %edx,%eax
  800806:	74 14                	je     80081c <strnlen+0x30>
  800808:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080c:	75 f5                	jne    800803 <strnlen+0x17>
  80080e:	eb 0c                	jmp    80081c <strnlen+0x30>
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 05                	jmp    80081c <strnlen+0x30>
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
  80082d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800830:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800833:	42                   	inc    %edx
  800834:	84 c9                	test   %cl,%cl
  800836:	75 f5                	jne    80082d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800838:	5b                   	pop    %ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	53                   	push   %ebx
  800843:	e8 84 ff ff ff       	call   8007cc <strlen>
  800848:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800851:	50                   	push   %eax
  800852:	e8 c7 ff ff ff       	call   80081e <strcpy>
	return dst;
}
  800857:	89 d8                	mov    %ebx,%eax
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	85 f6                	test   %esi,%esi
  80086e:	74 15                	je     800885 <strncpy+0x27>
  800870:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800875:	8a 1a                	mov    (%edx),%bl
  800877:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087a:	80 3a 01             	cmpb   $0x1,(%edx)
  80087d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	41                   	inc    %ecx
  800881:	39 ce                	cmp    %ecx,%esi
  800883:	77 f0                	ja     800875 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	57                   	push   %edi
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800895:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	85 f6                	test   %esi,%esi
  80089a:	74 32                	je     8008ce <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80089c:	83 fe 01             	cmp    $0x1,%esi
  80089f:	74 22                	je     8008c3 <strlcpy+0x3a>
  8008a1:	8a 0b                	mov    (%ebx),%cl
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 20                	je     8008c7 <strlcpy+0x3e>
  8008a7:	89 f8                	mov    %edi,%eax
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008ae:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b1:	88 08                	mov    %cl,(%eax)
  8008b3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b4:	39 f2                	cmp    %esi,%edx
  8008b6:	74 11                	je     8008c9 <strlcpy+0x40>
  8008b8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008bc:	42                   	inc    %edx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	75 f0                	jne    8008b1 <strlcpy+0x28>
  8008c1:	eb 06                	jmp    8008c9 <strlcpy+0x40>
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	eb 02                	jmp    8008c9 <strlcpy+0x40>
  8008c7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c9:	c6 00 00             	movb   $0x0,(%eax)
  8008cc:	eb 02                	jmp    8008d0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ce:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008d0:	29 f8                	sub    %edi,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e0:	8a 01                	mov    (%ecx),%al
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 10                	je     8008f6 <strcmp+0x1f>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	75 0c                	jne    8008f6 <strcmp+0x1f>
		p++, q++;
  8008ea:	41                   	inc    %ecx
  8008eb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ec:	8a 01                	mov    (%ecx),%al
  8008ee:	84 c0                	test   %al,%al
  8008f0:	74 04                	je     8008f6 <strcmp+0x1f>
  8008f2:	3a 02                	cmp    (%edx),%al
  8008f4:	74 f4                	je     8008ea <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 c0             	movzbl %al,%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	8b 55 08             	mov    0x8(%ebp),%edx
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	74 1b                	je     80092c <strncmp+0x2c>
  800911:	8a 1a                	mov    (%edx),%bl
  800913:	84 db                	test   %bl,%bl
  800915:	74 24                	je     80093b <strncmp+0x3b>
  800917:	3a 19                	cmp    (%ecx),%bl
  800919:	75 20                	jne    80093b <strncmp+0x3b>
  80091b:	48                   	dec    %eax
  80091c:	74 15                	je     800933 <strncmp+0x33>
		n--, p++, q++;
  80091e:	42                   	inc    %edx
  80091f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800920:	8a 1a                	mov    (%edx),%bl
  800922:	84 db                	test   %bl,%bl
  800924:	74 15                	je     80093b <strncmp+0x3b>
  800926:	3a 19                	cmp    (%ecx),%bl
  800928:	74 f1                	je     80091b <strncmp+0x1b>
  80092a:	eb 0f                	jmp    80093b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strncmp+0x38>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800938:	5b                   	pop    %ebx
  800939:	c9                   	leave  
  80093a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 02             	movzbl (%edx),%eax
  80093e:	0f b6 11             	movzbl (%ecx),%edx
  800941:	29 d0                	sub    %edx,%eax
  800943:	eb f3                	jmp    800938 <strncmp+0x38>

00800945 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094e:	8a 10                	mov    (%eax),%dl
  800950:	84 d2                	test   %dl,%dl
  800952:	74 18                	je     80096c <strchr+0x27>
		if (*s == c)
  800954:	38 ca                	cmp    %cl,%dl
  800956:	75 06                	jne    80095e <strchr+0x19>
  800958:	eb 17                	jmp    800971 <strchr+0x2c>
  80095a:	38 ca                	cmp    %cl,%dl
  80095c:	74 13                	je     800971 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095e:	40                   	inc    %eax
  80095f:	8a 10                	mov    (%eax),%dl
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f5                	jne    80095a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
  80096a:	eb 05                	jmp    800971 <strchr+0x2c>
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097c:	8a 10                	mov    (%eax),%dl
  80097e:	84 d2                	test   %dl,%dl
  800980:	74 11                	je     800993 <strfind+0x20>
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	75 06                	jne    80098c <strfind+0x19>
  800986:	eb 0b                	jmp    800993 <strfind+0x20>
  800988:	38 ca                	cmp    %cl,%dl
  80098a:	74 07                	je     800993 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098c:	40                   	inc    %eax
  80098d:	8a 10                	mov    (%eax),%dl
  80098f:	84 d2                	test   %dl,%dl
  800991:	75 f5                	jne    800988 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a4:	85 c9                	test   %ecx,%ecx
  8009a6:	74 30                	je     8009d8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ae:	75 25                	jne    8009d5 <memset+0x40>
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 20                	jne    8009d5 <memset+0x40>
		c &= 0xFF;
  8009b5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b8:	89 d3                	mov    %edx,%ebx
  8009ba:	c1 e3 08             	shl    $0x8,%ebx
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	c1 e6 18             	shl    $0x18,%esi
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	c1 e0 10             	shl    $0x10,%eax
  8009c7:	09 f0                	or     %esi,%eax
  8009c9:	09 d0                	or     %edx,%eax
  8009cb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009cd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d0:	fc                   	cld    
  8009d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d3:	eb 03                	jmp    8009d8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d5:	fc                   	cld    
  8009d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d8:	89 f8                	mov    %edi,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ed:	39 c6                	cmp    %eax,%esi
  8009ef:	73 34                	jae    800a25 <memmove+0x46>
  8009f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	73 2d                	jae    800a25 <memmove+0x46>
		s += n;
		d += n;
  8009f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	f6 c2 03             	test   $0x3,%dl
  8009fe:	75 1b                	jne    800a1b <memmove+0x3c>
  800a00:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a06:	75 13                	jne    800a1b <memmove+0x3c>
  800a08:	f6 c1 03             	test   $0x3,%cl
  800a0b:	75 0e                	jne    800a1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0d:	83 ef 04             	sub    $0x4,%edi
  800a10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a13:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a16:	fd                   	std    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 07                	jmp    800a22 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1b:	4f                   	dec    %edi
  800a1c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1f:	fd                   	std    
  800a20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a22:	fc                   	cld    
  800a23:	eb 20                	jmp    800a45 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2b:	75 13                	jne    800a40 <memmove+0x61>
  800a2d:	a8 03                	test   $0x3,%al
  800a2f:	75 0f                	jne    800a40 <memmove+0x61>
  800a31:	f6 c1 03             	test   $0x3,%cl
  800a34:	75 0a                	jne    800a40 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a36:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a39:	89 c7                	mov    %eax,%edi
  800a3b:	fc                   	cld    
  800a3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3e:	eb 05                	jmp    800a45 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	fc                   	cld    
  800a43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4c:	ff 75 10             	pushl  0x10(%ebp)
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	ff 75 08             	pushl  0x8(%ebp)
  800a55:	e8 85 ff ff ff       	call   8009df <memmove>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6b:	85 ff                	test   %edi,%edi
  800a6d:	74 32                	je     800aa1 <memcmp+0x45>
		if (*s1 != *s2)
  800a6f:	8a 03                	mov    (%ebx),%al
  800a71:	8a 0e                	mov    (%esi),%cl
  800a73:	38 c8                	cmp    %cl,%al
  800a75:	74 19                	je     800a90 <memcmp+0x34>
  800a77:	eb 0d                	jmp    800a86 <memcmp+0x2a>
  800a79:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a7d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a81:	42                   	inc    %edx
  800a82:	38 c8                	cmp    %cl,%al
  800a84:	74 10                	je     800a96 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 c9             	movzbl %cl,%ecx
  800a8c:	29 c8                	sub    %ecx,%eax
  800a8e:	eb 16                	jmp    800aa6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a90:	4f                   	dec    %edi
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	39 fa                	cmp    %edi,%edx
  800a98:	75 df                	jne    800a79 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	eb 05                	jmp    800aa6 <memcmp+0x4a>
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab6:	39 d0                	cmp    %edx,%eax
  800ab8:	73 12                	jae    800acc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aba:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	75 06                	jne    800ac7 <memfind+0x1c>
  800ac1:	eb 09                	jmp    800acc <memfind+0x21>
  800ac3:	38 08                	cmp    %cl,(%eax)
  800ac5:	74 05                	je     800acc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac7:	40                   	inc    %eax
  800ac8:	39 c2                	cmp    %eax,%edx
  800aca:	77 f7                	ja     800ac3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ada:	eb 01                	jmp    800add <strtol+0xf>
		s++;
  800adc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800add:	8a 02                	mov    (%edx),%al
  800adf:	3c 20                	cmp    $0x20,%al
  800ae1:	74 f9                	je     800adc <strtol+0xe>
  800ae3:	3c 09                	cmp    $0x9,%al
  800ae5:	74 f5                	je     800adc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae7:	3c 2b                	cmp    $0x2b,%al
  800ae9:	75 08                	jne    800af3 <strtol+0x25>
		s++;
  800aeb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
  800af1:	eb 13                	jmp    800b06 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af3:	3c 2d                	cmp    $0x2d,%al
  800af5:	75 0a                	jne    800b01 <strtol+0x33>
		s++, neg = 1;
  800af7:	8d 52 01             	lea    0x1(%edx),%edx
  800afa:	bf 01 00 00 00       	mov    $0x1,%edi
  800aff:	eb 05                	jmp    800b06 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b06:	85 db                	test   %ebx,%ebx
  800b08:	74 05                	je     800b0f <strtol+0x41>
  800b0a:	83 fb 10             	cmp    $0x10,%ebx
  800b0d:	75 28                	jne    800b37 <strtol+0x69>
  800b0f:	8a 02                	mov    (%edx),%al
  800b11:	3c 30                	cmp    $0x30,%al
  800b13:	75 10                	jne    800b25 <strtol+0x57>
  800b15:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b19:	75 0a                	jne    800b25 <strtol+0x57>
		s += 2, base = 16;
  800b1b:	83 c2 02             	add    $0x2,%edx
  800b1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b23:	eb 12                	jmp    800b37 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	75 0e                	jne    800b37 <strtol+0x69>
  800b29:	3c 30                	cmp    $0x30,%al
  800b2b:	75 05                	jne    800b32 <strtol+0x64>
		s++, base = 8;
  800b2d:	42                   	inc    %edx
  800b2e:	b3 08                	mov    $0x8,%bl
  800b30:	eb 05                	jmp    800b37 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3e:	8a 0a                	mov    (%edx),%cl
  800b40:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b43:	80 fb 09             	cmp    $0x9,%bl
  800b46:	77 08                	ja     800b50 <strtol+0x82>
			dig = *s - '0';
  800b48:	0f be c9             	movsbl %cl,%ecx
  800b4b:	83 e9 30             	sub    $0x30,%ecx
  800b4e:	eb 1e                	jmp    800b6e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b50:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 08                	ja     800b60 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b58:	0f be c9             	movsbl %cl,%ecx
  800b5b:	83 e9 57             	sub    $0x57,%ecx
  800b5e:	eb 0e                	jmp    800b6e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 13                	ja     800b7b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b68:	0f be c9             	movsbl %cl,%ecx
  800b6b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6e:	39 f1                	cmp    %esi,%ecx
  800b70:	7d 0d                	jge    800b7f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b72:	42                   	inc    %edx
  800b73:	0f af c6             	imul   %esi,%eax
  800b76:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b79:	eb c3                	jmp    800b3e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b7b:	89 c1                	mov    %eax,%ecx
  800b7d:	eb 02                	jmp    800b81 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b85:	74 05                	je     800b8c <strtol+0xbe>
		*endptr = (char *) s;
  800b87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b8c:	85 ff                	test   %edi,%edi
  800b8e:	74 04                	je     800b94 <strtol+0xc6>
  800b90:	89 c8                	mov    %ecx,%eax
  800b92:	f7 d8                	neg    %eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    
  800b99:	00 00                	add    %al,(%eax)
	...

00800b9c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	83 ec 10             	sub    $0x10,%esp
  800ba4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800baa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bb0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	75 2e                	jne    800be8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bba:	39 f1                	cmp    %esi,%ecx
  800bbc:	77 5a                	ja     800c18 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bbe:	85 c9                	test   %ecx,%ecx
  800bc0:	75 0b                	jne    800bcd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	31 d2                	xor    %edx,%edx
  800bc9:	f7 f1                	div    %ecx
  800bcb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bcd:	31 d2                	xor    %edx,%edx
  800bcf:	89 f0                	mov    %esi,%eax
  800bd1:	f7 f1                	div    %ecx
  800bd3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd5:	89 f8                	mov    %edi,%eax
  800bd7:	f7 f1                	div    %ecx
  800bd9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bdb:	89 f8                	mov    %edi,%eax
  800bdd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bdf:	83 c4 10             	add    $0x10,%esp
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    
  800be6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800be8:	39 f0                	cmp    %esi,%eax
  800bea:	77 1c                	ja     800c08 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800bec:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bef:	83 f7 1f             	xor    $0x1f,%edi
  800bf2:	75 3c                	jne    800c30 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bf4:	39 f0                	cmp    %esi,%eax
  800bf6:	0f 82 90 00 00 00    	jb     800c8c <__udivdi3+0xf0>
  800bfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bff:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c02:	0f 86 84 00 00 00    	jbe    800c8c <__udivdi3+0xf0>
  800c08:	31 f6                	xor    %esi,%esi
  800c0a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c0c:	89 f8                	mov    %edi,%eax
  800c0e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    
  800c17:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c18:	89 f2                	mov    %esi,%edx
  800c1a:	89 f8                	mov    %edi,%eax
  800c1c:	f7 f1                	div    %ecx
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c22:	89 f8                	mov    %edi,%eax
  800c24:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    
  800c2d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c30:	89 f9                	mov    %edi,%ecx
  800c32:	d3 e0                	shl    %cl,%eax
  800c34:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c37:	b8 20 00 00 00       	mov    $0x20,%eax
  800c3c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c41:	88 c1                	mov    %al,%cl
  800c43:	d3 ea                	shr    %cl,%edx
  800c45:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c48:	09 ca                	or     %ecx,%edx
  800c4a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c50:	89 f9                	mov    %edi,%ecx
  800c52:	d3 e2                	shl    %cl,%edx
  800c54:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c57:	89 f2                	mov    %esi,%edx
  800c59:	88 c1                	mov    %al,%cl
  800c5b:	d3 ea                	shr    %cl,%edx
  800c5d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c60:	89 f2                	mov    %esi,%edx
  800c62:	89 f9                	mov    %edi,%ecx
  800c64:	d3 e2                	shl    %cl,%edx
  800c66:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c69:	88 c1                	mov    %al,%cl
  800c6b:	d3 ee                	shr    %cl,%esi
  800c6d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c6f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	89 ca                	mov    %ecx,%edx
  800c76:	f7 75 ec             	divl   -0x14(%ebp)
  800c79:	89 d1                	mov    %edx,%ecx
  800c7b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c7d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c80:	39 d1                	cmp    %edx,%ecx
  800c82:	72 28                	jb     800cac <__udivdi3+0x110>
  800c84:	74 1a                	je     800ca0 <__udivdi3+0x104>
  800c86:	89 f7                	mov    %esi,%edi
  800c88:	31 f6                	xor    %esi,%esi
  800c8a:	eb 80                	jmp    800c0c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c8c:	31 f6                	xor    %esi,%esi
  800c8e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c93:	89 f8                	mov    %edi,%eax
  800c95:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    
  800c9e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ca0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ca3:	89 f9                	mov    %edi,%ecx
  800ca5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca7:	39 c2                	cmp    %eax,%edx
  800ca9:	73 db                	jae    800c86 <__udivdi3+0xea>
  800cab:	90                   	nop
		{
		  q0--;
  800cac:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800caf:	31 f6                	xor    %esi,%esi
  800cb1:	e9 56 ff ff ff       	jmp    800c0c <__udivdi3+0x70>
	...

00800cb8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	83 ec 20             	sub    $0x20,%esp
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ccc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ccf:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cd5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd7:	85 ff                	test   %edi,%edi
  800cd9:	75 15                	jne    800cf0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cdb:	39 f1                	cmp    %esi,%ecx
  800cdd:	0f 86 99 00 00 00    	jbe    800d7c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ce3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ce5:	89 d0                	mov    %edx,%eax
  800ce7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ce9:	83 c4 20             	add    $0x20,%esp
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cf0:	39 f7                	cmp    %esi,%edi
  800cf2:	0f 87 a4 00 00 00    	ja     800d9c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cfb:	83 f0 1f             	xor    $0x1f,%eax
  800cfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d01:	0f 84 a1 00 00 00    	je     800da8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d0c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d0e:	bf 20 00 00 00       	mov    $0x20,%edi
  800d13:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	d3 ea                	shr    %cl,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d25:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d28:	d3 e0                	shl    %cl,%eax
  800d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d2d:	89 f2                	mov    %esi,%edx
  800d2f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d34:	d3 e0                	shl    %cl,%eax
  800d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d3c:	89 f9                	mov    %edi,%ecx
  800d3e:	d3 e8                	shr    %cl,%eax
  800d40:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d42:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d44:	89 f2                	mov    %esi,%edx
  800d46:	f7 75 f0             	divl   -0x10(%ebp)
  800d49:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d4b:	f7 65 f4             	mull   -0xc(%ebp)
  800d4e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d51:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d53:	39 d6                	cmp    %edx,%esi
  800d55:	72 71                	jb     800dc8 <__umoddi3+0x110>
  800d57:	74 7f                	je     800dd8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d5c:	29 c8                	sub    %ecx,%eax
  800d5e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d60:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d63:	d3 e8                	shr    %cl,%eax
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	89 f9                	mov    %edi,%ecx
  800d69:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d6b:	09 d0                	or     %edx,%eax
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d72:	d3 ea                	shr    %cl,%edx
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
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d7c:	85 c9                	test   %ecx,%ecx
  800d7e:	75 0b                	jne    800d8b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 f1                	div    %ecx
  800d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d94:	f7 f1                	div    %ecx
  800d96:	e9 4a ff ff ff       	jmp    800ce5 <__umoddi3+0x2d>
  800d9b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d9c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d9e:	83 c4 20             	add    $0x20,%esp
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    
  800da5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800da8:	39 f7                	cmp    %esi,%edi
  800daa:	72 05                	jb     800db1 <__umoddi3+0xf9>
  800dac:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800daf:	77 0c                	ja     800dbd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800db1:	89 f2                	mov    %esi,%edx
  800db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db6:	29 c8                	sub    %ecx,%eax
  800db8:	19 fa                	sbb    %edi,%edx
  800dba:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dc0:	83 c4 20             	add    $0x20,%esp
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    
  800dc7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dd0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dd3:	eb 84                	jmp    800d59 <__umoddi3+0xa1>
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ddb:	72 eb                	jb     800dc8 <__umoddi3+0x110>
  800ddd:	89 f2                	mov    %esi,%edx
  800ddf:	e9 75 ff ff ff       	jmp    800d59 <__umoddi3+0xa1>
