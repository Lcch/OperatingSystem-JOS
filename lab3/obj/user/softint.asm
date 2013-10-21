
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c9                   	leave  
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 75 08             	mov    0x8(%ebp),%esi
  800044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800047:	e8 09 01 00 00       	call   800155 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800054:	c1 e0 05             	shl    $0x5,%eax
  800057:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800061:	85 f6                	test   %esi,%esi
  800063:	7e 07                	jle    80006c <libmain+0x30>
		binaryname = argv[0];
  800065:	8b 03                	mov    (%ebx),%eax
  800067:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 be ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800076:	e8 0d 00 00 00       	call   800088 <exit>
  80007b:	83 c4 10             	add    $0x10,%esp
}
  80007e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800081:	5b                   	pop    %ebx
  800082:	5e                   	pop    %esi
  800083:	c9                   	leave  
  800084:	c3                   	ret    
  800085:	00 00                	add    %al,(%eax)
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
  800090:	e8 9e 00 00 00       	call   800133 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	83 ec 1c             	sub    $0x1c,%esp
  8000a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000ab:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b9:	cd 30                	int    $0x30
  8000bb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c1:	74 1c                	je     8000df <syscall+0x43>
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7e 18                	jle    8000df <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	50                   	push   %eax
  8000cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ce:	68 da 0d 80 00       	push   $0x800dda
  8000d3:	6a 42                	push   $0x42
  8000d5:	68 f7 0d 80 00       	push   $0x800df7
  8000da:	e8 9d 00 00 00       	call   80017c <_panic>

	return ret;
}
  8000df:	89 d0                	mov    %edx,%eax
  8000e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800100:	b8 00 00 00 00       	mov    $0x0,%eax
  800105:	e8 92 ff ff ff       	call   80009c <syscall>
  80010a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <sys_cgetc>:

int
sys_cgetc(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800115:	6a 00                	push   $0x0
  800117:	6a 00                	push   $0x0
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 01 00 00 00       	mov    $0x1,%eax
  80012c:	e8 6b ff ff ff       	call   80009c <syscall>
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800144:	ba 01 00 00 00       	mov    $0x1,%edx
  800149:	b8 03 00 00 00       	mov    $0x3,%eax
  80014e:	e8 49 ff ff ff       	call   80009c <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80015b:	6a 00                	push   $0x0
  80015d:	6a 00                	push   $0x0
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	b9 00 00 00 00       	mov    $0x0,%ecx
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 02 00 00 00       	mov    $0x2,%eax
  800172:	e8 25 ff ff ff       	call   80009c <syscall>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    
  800179:	00 00                	add    %al,(%eax)
	...

0080017c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800181:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800184:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80018a:	e8 c6 ff ff ff       	call   800155 <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 0c             	pushl  0xc(%ebp)
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	53                   	push   %ebx
  800199:	50                   	push   %eax
  80019a:	68 08 0e 80 00       	push   $0x800e08
  80019f:	e8 b0 00 00 00       	call   800254 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	56                   	push   %esi
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	e8 53 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  8001b7:	e8 98 00 00 00       	call   800254 <cprintf>
  8001bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x43>
	...

008001c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 04             	sub    $0x4,%esp
  8001cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ce:	8b 03                	mov    (%ebx),%eax
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d7:	40                   	inc    %eax
  8001d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 1a                	jne    8001fb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	68 ff 00 00 00       	push   $0xff
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	50                   	push   %eax
  8001ed:	e8 f7 fe ff ff       	call   8000e9 <sys_cputs>
		b->idx = 0;
  8001f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001fb:	ff 43 04             	incl   0x4(%ebx)
}
  8001fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	ff 75 0c             	pushl  0xc(%ebp)
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	68 c4 01 80 00       	push   $0x8001c4
  800232:	e8 82 01 00 00       	call   8003b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800237:	83 c4 08             	add    $0x8,%esp
  80023a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800240:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	e8 9d fe ff ff       	call   8000e9 <sys_cputs>

	return b.cnt;
}
  80024c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025d:	50                   	push   %eax
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	e8 9d ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 2c             	sub    $0x2c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d6                	mov    %edx,%esi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800282:	8b 45 10             	mov    0x10(%ebp),%eax
  800285:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800288:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80028e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800295:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800298:	72 0c                	jb     8002a6 <printnum+0x3e>
  80029a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80029d:	76 07                	jbe    8002a6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029f:	4b                   	dec    %ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f 31                	jg     8002d5 <printnum+0x6d>
  8002a4:	eb 3f                	jmp    8002e5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	57                   	push   %edi
  8002aa:	4b                   	dec    %ebx
  8002ab:	53                   	push   %ebx
  8002ac:	50                   	push   %eax
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bc:	e8 c7 08 00 00       	call   800b88 <__udivdi3>
  8002c1:	83 c4 18             	add    $0x18,%esp
  8002c4:	52                   	push   %edx
  8002c5:	50                   	push   %eax
  8002c6:	89 f2                	mov    %esi,%edx
  8002c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cb:	e8 98 ff ff ff       	call   800268 <printnum>
  8002d0:	83 c4 20             	add    $0x20,%esp
  8002d3:	eb 10                	jmp    8002e5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	56                   	push   %esi
  8002d9:	57                   	push   %edi
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002dd:	4b                   	dec    %ebx
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 db                	test   %ebx,%ebx
  8002e3:	7f f0                	jg     8002d5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	83 ec 04             	sub    $0x4,%esp
  8002ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f8:	e8 a7 09 00 00       	call   800ca4 <__umoddi3>
  8002fd:	83 c4 14             	add    $0x14,%esp
  800300:	0f be 80 2e 0e 80 00 	movsbl 0x800e2e(%eax),%eax
  800307:	50                   	push   %eax
  800308:	ff 55 e4             	call   *-0x1c(%ebp)
  80030b:	83 c4 10             	add    $0x10,%esp
}
  80030e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0e                	jle    80032c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 08             	lea    0x8(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	8b 52 04             	mov    0x4(%edx),%edx
  80032a:	eb 22                	jmp    80034e <getuint+0x38>
	else if (lflag)
  80032c:	85 d2                	test   %edx,%edx
  80032e:	74 10                	je     800340 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 04             	lea    0x4(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 0e                	jmp    80034e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800353:	83 fa 01             	cmp    $0x1,%edx
  800356:	7e 0e                	jle    800366 <getint+0x16>
		return va_arg(*ap, long long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	8b 52 04             	mov    0x4(%edx),%edx
  800364:	eb 1a                	jmp    800380 <getint+0x30>
	else if (lflag)
  800366:	85 d2                	test   %edx,%edx
  800368:	74 0c                	je     800376 <getint+0x26>
		return va_arg(*ap, long);
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 02                	mov    (%edx),%eax
  800373:	99                   	cltd   
  800374:	eb 0a                	jmp    800380 <getint+0x30>
	else
		return va_arg(*ap, int);
  800376:	8b 10                	mov    (%eax),%edx
  800378:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037b:	89 08                	mov    %ecx,(%eax)
  80037d:	8b 02                	mov    (%edx),%eax
  80037f:	99                   	cltd   
}
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800388:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 08                	jae    80039a <sprintputch+0x18>
		*b->buf++ = ch;
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 0a                	mov    %cl,(%edx)
  800397:	42                   	inc    %edx
  800398:	89 10                	mov    %edx,(%eax)
}
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	50                   	push   %eax
  8003a6:	ff 75 10             	pushl  0x10(%ebp)
  8003a9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ac:	ff 75 08             	pushl  0x8(%ebp)
  8003af:	e8 05 00 00 00       	call   8003b9 <vprintfmt>
	va_end(ap);
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
  8003c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003c5:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c8:	eb 13                	jmp    8003dd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	0f 84 6d 03 00 00    	je     80073f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	57                   	push   %edi
  8003d6:	50                   	push   %eax
  8003d7:	ff 55 08             	call   *0x8(%ebp)
  8003da:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	0f b6 06             	movzbl (%esi),%eax
  8003e0:	46                   	inc    %esi
  8003e1:	83 f8 25             	cmp    $0x25,%eax
  8003e4:	75 e4                	jne    8003ca <vprintfmt+0x11>
  8003e6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003f8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800404:	eb 28                	jmp    80042e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800408:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80040c:	eb 20                	jmp    80042e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800410:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800414:	eb 18                	jmp    80042e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800418:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041f:	eb 0d                	jmp    80042e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800427:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8a 06                	mov    (%esi),%al
  800430:	0f b6 d0             	movzbl %al,%edx
  800433:	8d 5e 01             	lea    0x1(%esi),%ebx
  800436:	83 e8 23             	sub    $0x23,%eax
  800439:	3c 55                	cmp    $0x55,%al
  80043b:	0f 87 e0 02 00 00    	ja     800721 <vprintfmt+0x368>
  800441:	0f b6 c0             	movzbl %al,%eax
  800444:	ff 24 85 bc 0e 80 00 	jmp    *0x800ebc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	83 ea 30             	sub    $0x30,%edx
  80044e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800451:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800454:	8d 50 d0             	lea    -0x30(%eax),%edx
  800457:	83 fa 09             	cmp    $0x9,%edx
  80045a:	77 44                	ja     8004a0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	89 de                	mov    %ebx,%esi
  80045e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800461:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800462:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800465:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800469:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80046f:	83 fb 09             	cmp    $0x9,%ebx
  800472:	76 ed                	jbe    800461 <vprintfmt+0xa8>
  800474:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800477:	eb 29                	jmp    8004a2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800489:	eb 17                	jmp    8004a2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80048b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048f:	78 85                	js     800416 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	89 de                	mov    %ebx,%esi
  800493:	eb 99                	jmp    80042e <vprintfmt+0x75>
  800495:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800497:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80049e:	eb 8e                	jmp    80042e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a6:	79 86                	jns    80042e <vprintfmt+0x75>
  8004a8:	e9 74 ff ff ff       	jmp    800421 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ad:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	89 de                	mov    %ebx,%esi
  8004b0:	e9 79 ff ff ff       	jmp    80042e <vprintfmt+0x75>
  8004b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	57                   	push   %edi
  8004c5:	ff 30                	pushl  (%eax)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d0:	e9 08 ff ff ff       	jmp    8003dd <vprintfmt+0x24>
  8004d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 02                	jns    8004e9 <vprintfmt+0x130>
  8004e7:	f7 d8                	neg    %eax
  8004e9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004eb:	83 f8 06             	cmp    $0x6,%eax
  8004ee:	7f 0b                	jg     8004fb <vprintfmt+0x142>
  8004f0:	8b 04 85 14 10 80 00 	mov    0x801014(,%eax,4),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 1a                	jne    800515 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004fb:	52                   	push   %edx
  8004fc:	68 46 0e 80 00       	push   $0x800e46
  800501:	57                   	push   %edi
  800502:	ff 75 08             	pushl  0x8(%ebp)
  800505:	e8 92 fe ff ff       	call   80039c <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800510:	e9 c8 fe ff ff       	jmp    8003dd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800515:	50                   	push   %eax
  800516:	68 4f 0e 80 00       	push   $0x800e4f
  80051b:	57                   	push   %edi
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 78 fe ff ff       	call   80039c <printfmt>
  800524:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052a:	e9 ae fe ff ff       	jmp    8003dd <vprintfmt+0x24>
  80052f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800532:	89 de                	mov    %ebx,%esi
  800534:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800537:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800548:	85 c0                	test   %eax,%eax
  80054a:	75 07                	jne    800553 <vprintfmt+0x19a>
				p = "(null)";
  80054c:	c7 45 d0 3f 0e 80 00 	movl   $0x800e3f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800553:	85 db                	test   %ebx,%ebx
  800555:	7e 42                	jle    800599 <vprintfmt+0x1e0>
  800557:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80055b:	74 3c                	je     800599 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	51                   	push   %ecx
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	e8 6f 02 00 00       	call   8007d8 <strnlen>
  800569:	29 c3                	sub    %eax,%ebx
  80056b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	85 db                	test   %ebx,%ebx
  800573:	7e 24                	jle    800599 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800575:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800579:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80057c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	53                   	push   %ebx
  800584:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	4e                   	dec    %esi
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	85 f6                	test   %esi,%esi
  80058d:	7f f0                	jg     80057f <vprintfmt+0x1c6>
  80058f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800592:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80059c:	0f be 02             	movsbl (%edx),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	75 47                	jne    8005ea <vprintfmt+0x231>
  8005a3:	eb 37                	jmp    8005dc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a9:	74 16                	je     8005c1 <vprintfmt+0x208>
  8005ab:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ae:	83 fa 5e             	cmp    $0x5e,%edx
  8005b1:	76 0e                	jbe    8005c1 <vprintfmt+0x208>
					putch('?', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	6a 3f                	push   $0x3f
  8005b9:	ff 55 08             	call   *0x8(%ebp)
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb 0b                	jmp    8005cc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	57                   	push   %edi
  8005c5:	50                   	push   %eax
  8005c6:	ff 55 08             	call   *0x8(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cc:	ff 4d e4             	decl   -0x1c(%ebp)
  8005cf:	0f be 03             	movsbl (%ebx),%eax
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	74 03                	je     8005d9 <vprintfmt+0x220>
  8005d6:	43                   	inc    %ebx
  8005d7:	eb 1b                	jmp    8005f4 <vprintfmt+0x23b>
  8005d9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e0:	7f 1e                	jg     800600 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005e5:	e9 f3 fd ff ff       	jmp    8003dd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ed:	43                   	inc    %ebx
  8005ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005f4:	85 f6                	test   %esi,%esi
  8005f6:	78 ad                	js     8005a5 <vprintfmt+0x1ec>
  8005f8:	4e                   	dec    %esi
  8005f9:	79 aa                	jns    8005a5 <vprintfmt+0x1ec>
  8005fb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005fe:	eb dc                	jmp    8005dc <vprintfmt+0x223>
  800600:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	57                   	push   %edi
  800607:	6a 20                	push   $0x20
  800609:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	4b                   	dec    %ebx
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f ef                	jg     800603 <vprintfmt+0x24a>
  800614:	e9 c4 fd ff ff       	jmp    8003dd <vprintfmt+0x24>
  800619:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	89 ca                	mov    %ecx,%edx
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 2a fd ff ff       	call   800350 <getint>
  800626:	89 c3                	mov    %eax,%ebx
  800628:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80062a:	85 d2                	test   %edx,%edx
  80062c:	78 0a                	js     800638 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	e9 b0 00 00 00       	jmp    8006e8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	57                   	push   %edi
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800641:	f7 db                	neg    %ebx
  800643:	83 d6 00             	adc    $0x0,%esi
  800646:	f7 de                	neg    %esi
  800648:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800650:	e9 93 00 00 00       	jmp    8006e8 <vprintfmt+0x32f>
  800655:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 b4 fc ff ff       	call   800316 <getuint>
  800662:	89 c3                	mov    %eax,%ebx
  800664:	89 d6                	mov    %edx,%esi
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066b:	eb 7b                	jmp    8006e8 <vprintfmt+0x32f>
  80066d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800670:	89 ca                	mov    %ecx,%edx
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 d6 fc ff ff       	call   800350 <getint>
  80067a:	89 c3                	mov    %eax,%ebx
  80067c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80067e:	85 d2                	test   %edx,%edx
  800680:	78 07                	js     800689 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800682:	b8 08 00 00 00       	mov    $0x8,%eax
  800687:	eb 5f                	jmp    8006e8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	57                   	push   %edi
  80068d:	6a 2d                	push   $0x2d
  80068f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800692:	f7 db                	neg    %ebx
  800694:	83 d6 00             	adc    $0x0,%esi
  800697:	f7 de                	neg    %esi
  800699:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80069c:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a1:	eb 45                	jmp    8006e8 <vprintfmt+0x32f>
  8006a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	57                   	push   %edi
  8006aa:	6a 30                	push   $0x30
  8006ac:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	57                   	push   %edi
  8006b3:	6a 78                	push   $0x78
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c1:	8b 18                	mov    (%eax),%ebx
  8006c3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d0:	eb 16                	jmp    8006e8 <vprintfmt+0x32f>
  8006d2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d5:	89 ca                	mov    %ecx,%edx
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 37 fc ff ff       	call   800316 <getuint>
  8006df:	89 c3                	mov    %eax,%ebx
  8006e1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ef:	52                   	push   %edx
  8006f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f3:	50                   	push   %eax
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	89 fa                	mov    %edi,%edx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	e8 68 fb ff ff       	call   800268 <printnum>
			break;
  800700:	83 c4 20             	add    $0x20,%esp
  800703:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800706:	e9 d2 fc ff ff       	jmp    8003dd <vprintfmt+0x24>
  80070b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	57                   	push   %edi
  800712:	52                   	push   %edx
  800713:	ff 55 08             	call   *0x8(%ebp)
			break;
  800716:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800719:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071c:	e9 bc fc ff ff       	jmp    8003dd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	57                   	push   %edi
  800725:	6a 25                	push   $0x25
  800727:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	eb 02                	jmp    800731 <vprintfmt+0x378>
  80072f:	89 c6                	mov    %eax,%esi
  800731:	8d 46 ff             	lea    -0x1(%esi),%eax
  800734:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800738:	75 f5                	jne    80072f <vprintfmt+0x376>
  80073a:	e9 9e fc ff ff       	jmp    8003dd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 18             	sub    $0x18,%esp
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800756:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800764:	85 c0                	test   %eax,%eax
  800766:	74 26                	je     80078e <vsnprintf+0x47>
  800768:	85 d2                	test   %edx,%edx
  80076a:	7e 29                	jle    800795 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076c:	ff 75 14             	pushl  0x14(%ebp)
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	68 82 03 80 00       	push   $0x800382
  80077b:	e8 39 fc ff ff       	call   8003b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	eb 0c                	jmp    80079a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800793:	eb 05                	jmp    80079a <vsnprintf+0x53>
  800795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a5:	50                   	push   %eax
  8007a6:	ff 75 10             	pushl  0x10(%ebp)
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	ff 75 08             	pushl  0x8(%ebp)
  8007af:	e8 93 ff ff ff       	call   800747 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    
	...

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c1:	74 0e                	je     8007d1 <strlen+0x19>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007c8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f9                	jne    8007c8 <strlen+0x10>
  8007cf:	eb 05                	jmp    8007d6 <strlen+0x1e>
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	74 17                	je     8007fc <strnlen+0x24>
  8007e5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007e8:	74 19                	je     800803 <strnlen+0x2b>
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ef:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f0:	39 d0                	cmp    %edx,%eax
  8007f2:	74 14                	je     800808 <strnlen+0x30>
  8007f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f8:	75 f5                	jne    8007ef <strnlen+0x17>
  8007fa:	eb 0c                	jmp    800808 <strnlen+0x30>
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 05                	jmp    800808 <strnlen+0x30>
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
  800819:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80081c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80081f:	42                   	inc    %edx
  800820:	84 c9                	test   %cl,%cl
  800822:	75 f5                	jne    800819 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 84 ff ff ff       	call   8007b8 <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80083d:	50                   	push   %eax
  80083e:	e8 c7 ff ff ff       	call   80080a <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	85 f6                	test   %esi,%esi
  80085a:	74 15                	je     800871 <strncpy+0x27>
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800861:	8a 1a                	mov    (%edx),%bl
  800863:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 3a 01             	cmpb   $0x1,(%edx)
  800869:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	41                   	inc    %ecx
  80086d:	39 ce                	cmp    %ecx,%esi
  80086f:	77 f0                	ja     800861 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	57                   	push   %edi
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 f6                	test   %esi,%esi
  800886:	74 32                	je     8008ba <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800888:	83 fe 01             	cmp    $0x1,%esi
  80088b:	74 22                	je     8008af <strlcpy+0x3a>
  80088d:	8a 0b                	mov    (%ebx),%cl
  80088f:	84 c9                	test   %cl,%cl
  800891:	74 20                	je     8008b3 <strlcpy+0x3e>
  800893:	89 f8                	mov    %edi,%eax
  800895:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80089a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089d:	88 08                	mov    %cl,(%eax)
  80089f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a0:	39 f2                	cmp    %esi,%edx
  8008a2:	74 11                	je     8008b5 <strlcpy+0x40>
  8008a4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008a8:	42                   	inc    %edx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 f0                	jne    80089d <strlcpy+0x28>
  8008ad:	eb 06                	jmp    8008b5 <strlcpy+0x40>
  8008af:	89 f8                	mov    %edi,%eax
  8008b1:	eb 02                	jmp    8008b5 <strlcpy+0x40>
  8008b3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b5:	c6 00 00             	movb   $0x0,(%eax)
  8008b8:	eb 02                	jmp    8008bc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ba:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008bc:	29 f8                	sub    %edi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5f                   	pop    %edi
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cc:	8a 01                	mov    (%ecx),%al
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 10                	je     8008e2 <strcmp+0x1f>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	75 0c                	jne    8008e2 <strcmp+0x1f>
		p++, q++;
  8008d6:	41                   	inc    %ecx
  8008d7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d8:	8a 01                	mov    (%ecx),%al
  8008da:	84 c0                	test   %al,%al
  8008dc:	74 04                	je     8008e2 <strcmp+0x1f>
  8008de:	3a 02                	cmp    (%edx),%al
  8008e0:	74 f4                	je     8008d6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	0f b6 c0             	movzbl %al,%eax
  8008e5:	0f b6 12             	movzbl (%edx),%edx
  8008e8:	29 d0                	sub    %edx,%eax
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008f9:	85 c0                	test   %eax,%eax
  8008fb:	74 1b                	je     800918 <strncmp+0x2c>
  8008fd:	8a 1a                	mov    (%edx),%bl
  8008ff:	84 db                	test   %bl,%bl
  800901:	74 24                	je     800927 <strncmp+0x3b>
  800903:	3a 19                	cmp    (%ecx),%bl
  800905:	75 20                	jne    800927 <strncmp+0x3b>
  800907:	48                   	dec    %eax
  800908:	74 15                	je     80091f <strncmp+0x33>
		n--, p++, q++;
  80090a:	42                   	inc    %edx
  80090b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090c:	8a 1a                	mov    (%edx),%bl
  80090e:	84 db                	test   %bl,%bl
  800910:	74 15                	je     800927 <strncmp+0x3b>
  800912:	3a 19                	cmp    (%ecx),%bl
  800914:	74 f1                	je     800907 <strncmp+0x1b>
  800916:	eb 0f                	jmp    800927 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
  80091d:	eb 05                	jmp    800924 <strncmp+0x38>
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800924:	5b                   	pop    %ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800927:	0f b6 02             	movzbl (%edx),%eax
  80092a:	0f b6 11             	movzbl (%ecx),%edx
  80092d:	29 d0                	sub    %edx,%eax
  80092f:	eb f3                	jmp    800924 <strncmp+0x38>

00800931 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	74 18                	je     800958 <strchr+0x27>
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	75 06                	jne    80094a <strchr+0x19>
  800944:	eb 17                	jmp    80095d <strchr+0x2c>
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 13                	je     80095d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094a:	40                   	inc    %eax
  80094b:	8a 10                	mov    (%eax),%dl
  80094d:	84 d2                	test   %dl,%dl
  80094f:	75 f5                	jne    800946 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	eb 05                	jmp    80095d <strchr+0x2c>
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800968:	8a 10                	mov    (%eax),%dl
  80096a:	84 d2                	test   %dl,%dl
  80096c:	74 11                	je     80097f <strfind+0x20>
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	75 06                	jne    800978 <strfind+0x19>
  800972:	eb 0b                	jmp    80097f <strfind+0x20>
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 07                	je     80097f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800978:	40                   	inc    %eax
  800979:	8a 10                	mov    (%eax),%dl
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f5                	jne    800974 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800990:	85 c9                	test   %ecx,%ecx
  800992:	74 30                	je     8009c4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800994:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099a:	75 25                	jne    8009c1 <memset+0x40>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 20                	jne    8009c1 <memset+0x40>
		c &= 0xFF;
  8009a1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a4:	89 d3                	mov    %edx,%ebx
  8009a6:	c1 e3 08             	shl    $0x8,%ebx
  8009a9:	89 d6                	mov    %edx,%esi
  8009ab:	c1 e6 18             	shl    $0x18,%esi
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 10             	shl    $0x10,%eax
  8009b3:	09 f0                	or     %esi,%eax
  8009b5:	09 d0                	or     %edx,%eax
  8009b7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009bc:	fc                   	cld    
  8009bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bf:	eb 03                	jmp    8009c4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c1:	fc                   	cld    
  8009c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d9:	39 c6                	cmp    %eax,%esi
  8009db:	73 34                	jae    800a11 <memmove+0x46>
  8009dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	73 2d                	jae    800a11 <memmove+0x46>
		s += n;
		d += n;
  8009e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	f6 c2 03             	test   $0x3,%dl
  8009ea:	75 1b                	jne    800a07 <memmove+0x3c>
  8009ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f2:	75 13                	jne    800a07 <memmove+0x3c>
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 0e                	jne    800a07 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f9:	83 ef 04             	sub    $0x4,%edi
  8009fc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a02:	fd                   	std    
  800a03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a05:	eb 07                	jmp    800a0e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a07:	4f                   	dec    %edi
  800a08:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0e:	fc                   	cld    
  800a0f:	eb 20                	jmp    800a31 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a17:	75 13                	jne    800a2c <memmove+0x61>
  800a19:	a8 03                	test   $0x3,%al
  800a1b:	75 0f                	jne    800a2c <memmove+0x61>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0a                	jne    800a2c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a22:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	fc                   	cld    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb 05                	jmp    800a31 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a38:	ff 75 10             	pushl  0x10(%ebp)
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	ff 75 08             	pushl  0x8(%ebp)
  800a41:	e8 85 ff ff ff       	call   8009cb <memmove>
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	85 ff                	test   %edi,%edi
  800a59:	74 32                	je     800a8d <memcmp+0x45>
		if (*s1 != *s2)
  800a5b:	8a 03                	mov    (%ebx),%al
  800a5d:	8a 0e                	mov    (%esi),%cl
  800a5f:	38 c8                	cmp    %cl,%al
  800a61:	74 19                	je     800a7c <memcmp+0x34>
  800a63:	eb 0d                	jmp    800a72 <memcmp+0x2a>
  800a65:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a69:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a6d:	42                   	inc    %edx
  800a6e:	38 c8                	cmp    %cl,%al
  800a70:	74 10                	je     800a82 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a72:	0f b6 c0             	movzbl %al,%eax
  800a75:	0f b6 c9             	movzbl %cl,%ecx
  800a78:	29 c8                	sub    %ecx,%eax
  800a7a:	eb 16                	jmp    800a92 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7c:	4f                   	dec    %edi
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	39 fa                	cmp    %edi,%edx
  800a84:	75 df                	jne    800a65 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	eb 05                	jmp    800a92 <memcmp+0x4a>
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	73 12                	jae    800ab8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800aa9:	38 08                	cmp    %cl,(%eax)
  800aab:	75 06                	jne    800ab3 <memfind+0x1c>
  800aad:	eb 09                	jmp    800ab8 <memfind+0x21>
  800aaf:	38 08                	cmp    %cl,(%eax)
  800ab1:	74 05                	je     800ab8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab3:	40                   	inc    %eax
  800ab4:	39 c2                	cmp    %eax,%edx
  800ab6:	77 f7                	ja     800aaf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac6:	eb 01                	jmp    800ac9 <strtol+0xf>
		s++;
  800ac8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac9:	8a 02                	mov    (%edx),%al
  800acb:	3c 20                	cmp    $0x20,%al
  800acd:	74 f9                	je     800ac8 <strtol+0xe>
  800acf:	3c 09                	cmp    $0x9,%al
  800ad1:	74 f5                	je     800ac8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad3:	3c 2b                	cmp    $0x2b,%al
  800ad5:	75 08                	jne    800adf <strtol+0x25>
		s++;
  800ad7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad8:	bf 00 00 00 00       	mov    $0x0,%edi
  800add:	eb 13                	jmp    800af2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adf:	3c 2d                	cmp    $0x2d,%al
  800ae1:	75 0a                	jne    800aed <strtol+0x33>
		s++, neg = 1;
  800ae3:	8d 52 01             	lea    0x1(%edx),%edx
  800ae6:	bf 01 00 00 00       	mov    $0x1,%edi
  800aeb:	eb 05                	jmp    800af2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af2:	85 db                	test   %ebx,%ebx
  800af4:	74 05                	je     800afb <strtol+0x41>
  800af6:	83 fb 10             	cmp    $0x10,%ebx
  800af9:	75 28                	jne    800b23 <strtol+0x69>
  800afb:	8a 02                	mov    (%edx),%al
  800afd:	3c 30                	cmp    $0x30,%al
  800aff:	75 10                	jne    800b11 <strtol+0x57>
  800b01:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b05:	75 0a                	jne    800b11 <strtol+0x57>
		s += 2, base = 16;
  800b07:	83 c2 02             	add    $0x2,%edx
  800b0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0f:	eb 12                	jmp    800b23 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b11:	85 db                	test   %ebx,%ebx
  800b13:	75 0e                	jne    800b23 <strtol+0x69>
  800b15:	3c 30                	cmp    $0x30,%al
  800b17:	75 05                	jne    800b1e <strtol+0x64>
		s++, base = 8;
  800b19:	42                   	inc    %edx
  800b1a:	b3 08                	mov    $0x8,%bl
  800b1c:	eb 05                	jmp    800b23 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2a:	8a 0a                	mov    (%edx),%cl
  800b2c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b2f:	80 fb 09             	cmp    $0x9,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x82>
			dig = *s - '0';
  800b34:	0f be c9             	movsbl %cl,%ecx
  800b37:	83 e9 30             	sub    $0x30,%ecx
  800b3a:	eb 1e                	jmp    800b5a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b3c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b3f:	80 fb 19             	cmp    $0x19,%bl
  800b42:	77 08                	ja     800b4c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b44:	0f be c9             	movsbl %cl,%ecx
  800b47:	83 e9 57             	sub    $0x57,%ecx
  800b4a:	eb 0e                	jmp    800b5a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b4c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b4f:	80 fb 19             	cmp    $0x19,%bl
  800b52:	77 13                	ja     800b67 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b54:	0f be c9             	movsbl %cl,%ecx
  800b57:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5a:	39 f1                	cmp    %esi,%ecx
  800b5c:	7d 0d                	jge    800b6b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b5e:	42                   	inc    %edx
  800b5f:	0f af c6             	imul   %esi,%eax
  800b62:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b65:	eb c3                	jmp    800b2a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b67:	89 c1                	mov    %eax,%ecx
  800b69:	eb 02                	jmp    800b6d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b6b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b71:	74 05                	je     800b78 <strtol+0xbe>
		*endptr = (char *) s;
  800b73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b76:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b78:	85 ff                	test   %edi,%edi
  800b7a:	74 04                	je     800b80 <strtol+0xc6>
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	f7 d8                	neg    %eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    
  800b85:	00 00                	add    %al,(%eax)
	...

00800b88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	83 ec 10             	sub    $0x10,%esp
  800b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b93:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b96:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b9c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b9f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	75 2e                	jne    800bd4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ba6:	39 f1                	cmp    %esi,%ecx
  800ba8:	77 5a                	ja     800c04 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800baa:	85 c9                	test   %ecx,%ecx
  800bac:	75 0b                	jne    800bb9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bae:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb3:	31 d2                	xor    %edx,%edx
  800bb5:	f7 f1                	div    %ecx
  800bb7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bb9:	31 d2                	xor    %edx,%edx
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	f7 f1                	div    %ecx
  800bbf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc1:	89 f8                	mov    %edi,%eax
  800bc3:	f7 f1                	div    %ecx
  800bc5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc7:	89 f8                	mov    %edi,%eax
  800bc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bcb:	83 c4 10             	add    $0x10,%esp
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    
  800bd2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bd4:	39 f0                	cmp    %esi,%eax
  800bd6:	77 1c                	ja     800bf4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800bd8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800bdb:	83 f7 1f             	xor    $0x1f,%edi
  800bde:	75 3c                	jne    800c1c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800be0:	39 f0                	cmp    %esi,%eax
  800be2:	0f 82 90 00 00 00    	jb     800c78 <__udivdi3+0xf0>
  800be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800beb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bee:	0f 86 84 00 00 00    	jbe    800c78 <__udivdi3+0xf0>
  800bf4:	31 f6                	xor    %esi,%esi
  800bf6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bf8:	89 f8                	mov    %edi,%eax
  800bfa:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    
  800c03:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c04:	89 f2                	mov    %esi,%edx
  800c06:	89 f8                	mov    %edi,%eax
  800c08:	f7 f1                	div    %ecx
  800c0a:	89 c7                	mov    %eax,%edi
  800c0c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c0e:	89 f8                	mov    %edi,%eax
  800c10:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    
  800c19:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c1c:	89 f9                	mov    %edi,%ecx
  800c1e:	d3 e0                	shl    %cl,%eax
  800c20:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c23:	b8 20 00 00 00       	mov    $0x20,%eax
  800c28:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c2d:	88 c1                	mov    %al,%cl
  800c2f:	d3 ea                	shr    %cl,%edx
  800c31:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c34:	09 ca                	or     %ecx,%edx
  800c36:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c3c:	89 f9                	mov    %edi,%ecx
  800c3e:	d3 e2                	shl    %cl,%edx
  800c40:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c43:	89 f2                	mov    %esi,%edx
  800c45:	88 c1                	mov    %al,%cl
  800c47:	d3 ea                	shr    %cl,%edx
  800c49:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c4c:	89 f2                	mov    %esi,%edx
  800c4e:	89 f9                	mov    %edi,%ecx
  800c50:	d3 e2                	shl    %cl,%edx
  800c52:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c55:	88 c1                	mov    %al,%cl
  800c57:	d3 ee                	shr    %cl,%esi
  800c59:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c5b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c5e:	89 f0                	mov    %esi,%eax
  800c60:	89 ca                	mov    %ecx,%edx
  800c62:	f7 75 ec             	divl   -0x14(%ebp)
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c69:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c6c:	39 d1                	cmp    %edx,%ecx
  800c6e:	72 28                	jb     800c98 <__udivdi3+0x110>
  800c70:	74 1a                	je     800c8c <__udivdi3+0x104>
  800c72:	89 f7                	mov    %esi,%edi
  800c74:	31 f6                	xor    %esi,%esi
  800c76:	eb 80                	jmp    800bf8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c78:	31 f6                	xor    %esi,%esi
  800c7a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c7f:	89 f8                	mov    %edi,%eax
  800c81:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    
  800c8a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c8f:	89 f9                	mov    %edi,%ecx
  800c91:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c93:	39 c2                	cmp    %eax,%edx
  800c95:	73 db                	jae    800c72 <__udivdi3+0xea>
  800c97:	90                   	nop
		{
		  q0--;
  800c98:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c9b:	31 f6                	xor    %esi,%esi
  800c9d:	e9 56 ff ff ff       	jmp    800bf8 <__udivdi3+0x70>
	...

00800ca4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	83 ec 20             	sub    $0x20,%esp
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cc1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cc3:	85 ff                	test   %edi,%edi
  800cc5:	75 15                	jne    800cdc <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cc7:	39 f1                	cmp    %esi,%ecx
  800cc9:	0f 86 99 00 00 00    	jbe    800d68 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ccf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800cd5:	83 c4 20             	add    $0x20,%esp
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cdc:	39 f7                	cmp    %esi,%edi
  800cde:	0f 87 a4 00 00 00    	ja     800d88 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ce4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ce7:	83 f0 1f             	xor    $0x1f,%eax
  800cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ced:	0f 84 a1 00 00 00    	je     800d94 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cf3:	89 f8                	mov    %edi,%eax
  800cf5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cf8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cfa:	bf 20 00 00 00       	mov    $0x20,%edi
  800cff:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d05:	89 f9                	mov    %edi,%ecx
  800d07:	d3 ea                	shr    %cl,%edx
  800d09:	09 c2                	or     %eax,%edx
  800d0b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d11:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d14:	d3 e0                	shl    %cl,%eax
  800d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d19:	89 f2                	mov    %esi,%edx
  800d1b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d20:	d3 e0                	shl    %cl,%eax
  800d22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d28:	89 f9                	mov    %edi,%ecx
  800d2a:	d3 e8                	shr    %cl,%eax
  800d2c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d2e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	f7 75 f0             	divl   -0x10(%ebp)
  800d35:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d37:	f7 65 f4             	mull   -0xc(%ebp)
  800d3a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d3d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d3f:	39 d6                	cmp    %edx,%esi
  800d41:	72 71                	jb     800db4 <__umoddi3+0x110>
  800d43:	74 7f                	je     800dc4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d48:	29 c8                	sub    %ecx,%eax
  800d4a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d4c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d4f:	d3 e8                	shr    %cl,%eax
  800d51:	89 f2                	mov    %esi,%edx
  800d53:	89 f9                	mov    %edi,%ecx
  800d55:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d57:	09 d0                	or     %edx,%eax
  800d59:	89 f2                	mov    %esi,%edx
  800d5b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d5e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d60:	83 c4 20             	add    $0x20,%esp
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    
  800d67:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d68:	85 c9                	test   %ecx,%ecx
  800d6a:	75 0b                	jne    800d77 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d71:	31 d2                	xor    %edx,%edx
  800d73:	f7 f1                	div    %ecx
  800d75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	31 d2                	xor    %edx,%edx
  800d7b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d80:	f7 f1                	div    %ecx
  800d82:	e9 4a ff ff ff       	jmp    800cd1 <__umoddi3+0x2d>
  800d87:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d88:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d8a:	83 c4 20             	add    $0x20,%esp
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    
  800d91:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d94:	39 f7                	cmp    %esi,%edi
  800d96:	72 05                	jb     800d9d <__umoddi3+0xf9>
  800d98:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d9b:	77 0c                	ja     800da9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d9d:	89 f2                	mov    %esi,%edx
  800d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da2:	29 c8                	sub    %ecx,%eax
  800da4:	19 fa                	sbb    %edi,%edx
  800da6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dac:	83 c4 20             	add    $0x20,%esp
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    
  800db3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800db4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800db7:	89 c1                	mov    %eax,%ecx
  800db9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dbc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dbf:	eb 84                	jmp    800d45 <__umoddi3+0xa1>
  800dc1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dc4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dc7:	72 eb                	jb     800db4 <__umoddi3+0x110>
  800dc9:	89 f2                	mov    %esi,%edx
  800dcb:	e9 75 ff ff ff       	jmp    800d45 <__umoddi3+0xa1>
