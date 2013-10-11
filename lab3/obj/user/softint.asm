
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
  800047:	e8 34 01 00 00       	call   800180 <sys_getenvid>
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
  800090:	e8 c9 00 00 00       	call   80015e <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    
	...

0080009c <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
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
	assert(a5 == 0);
  8000ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000b1:	74 16                	je     8000c9 <my_sysenter+0x2d>
  8000b3:	68 02 0e 80 00       	push   $0x800e02
  8000b8:	68 0a 0e 80 00       	push   $0x800e0a
  8000bd:	6a 0b                	push   $0xb
  8000bf:	68 1f 0e 80 00       	push   $0x800e1f
  8000c4:	e8 db 00 00 00       	call   8001a4 <_panic>
	int32_t ret;

	asm volatile(
  8000c9:	be 00 00 00 00       	mov    $0x0,%esi
  8000ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000da:	55                   	push   %ebp
  8000db:	54                   	push   %esp
  8000dc:	5d                   	pop    %ebp
  8000dd:	8d 35 e5 00 80 00    	lea    0x8000e5,%esi
  8000e3:	0f 34                	sysenter 

008000e5 <after_sysenter_label>:
  8000e5:	5d                   	pop    %ebp
  8000e6:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000ec:	74 1c                	je     80010a <after_sysenter_label+0x25>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	7e 18                	jle    80010a <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f9:	68 30 0e 80 00       	push   $0x800e30
  8000fe:	6a 20                	push   $0x20
  800100:	68 1f 0e 80 00       	push   $0x800e1f
  800105:	e8 9a 00 00 00       	call   8001a4 <_panic>

	return ret;
}
  80010a:	89 d0                	mov    %edx,%eax
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80011a:	6a 00                	push   $0x0
  80011c:	6a 00                	push   $0x0
  80011e:	6a 00                	push   $0x0
  800120:	ff 75 0c             	pushl  0xc(%ebp)
  800123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 00 00 00 00       	mov    $0x0,%eax
  800130:	e8 67 ff ff ff       	call   80009c <my_sysenter>
  800135:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    

0080013a <sys_cgetc>:

int
sys_cgetc(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800140:	6a 00                	push   $0x0
  800142:	6a 00                	push   $0x0
  800144:	6a 00                	push   $0x0
  800146:	6a 00                	push   $0x0
  800148:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 01 00 00 00       	mov    $0x1,%eax
  800157:	e8 40 ff ff ff       	call   80009c <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800164:	6a 00                	push   $0x0
  800166:	6a 00                	push   $0x0
  800168:	6a 00                	push   $0x0
  80016a:	6a 00                	push   $0x0
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	ba 01 00 00 00       	mov    $0x1,%edx
  800174:	b8 03 00 00 00       	mov    $0x3,%eax
  800179:	e8 1e ff ff ff       	call   80009c <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800186:	6a 00                	push   $0x0
  800188:	6a 00                	push   $0x0
  80018a:	6a 00                	push   $0x0
  80018c:	6a 00                	push   $0x0
  80018e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800193:	ba 00 00 00 00       	mov    $0x0,%edx
  800198:	b8 02 00 00 00       	mov    $0x2,%eax
  80019d:	e8 fa fe ff ff       	call   80009c <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001b2:	e8 c9 ff ff ff       	call   800180 <sys_getenvid>
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	53                   	push   %ebx
  8001c1:	50                   	push   %eax
  8001c2:	68 54 0e 80 00       	push   $0x800e54
  8001c7:	e8 b0 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 53 00 00 00       	call   80022b <vcprintf>
	cprintf("\n");
  8001d8:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  8001df:	e8 98 00 00 00       	call   80027c <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x43>
	...

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 04             	sub    $0x4,%esp
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f6:	8b 03                	mov    (%ebx),%eax
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ff:	40                   	inc    %eax
  800200:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800202:	3d ff 00 00 00       	cmp    $0xff,%eax
  800207:	75 1a                	jne    800223 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	68 ff 00 00 00       	push   $0xff
  800211:	8d 43 08             	lea    0x8(%ebx),%eax
  800214:	50                   	push   %eax
  800215:	e8 fa fe ff ff       	call   800114 <sys_cputs>
		b->idx = 0;
  80021a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800220:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800223:	ff 43 04             	incl   0x4(%ebx)
}
  800226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800234:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023b:	00 00 00 
	b.cnt = 0;
  80023e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800245:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	ff 75 08             	pushl  0x8(%ebp)
  80024e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	68 ec 01 80 00       	push   $0x8001ec
  80025a:	e8 82 01 00 00       	call   8003e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025f:	83 c4 08             	add    $0x8,%esp
  800262:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800268:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026e:	50                   	push   %eax
  80026f:	e8 a0 fe ff ff       	call   800114 <sys_cputs>

	return b.cnt;
}
  800274:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 9d ff ff ff       	call   80022b <vcprintf>
	va_end(ap);

	return cnt;
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002bd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c0:	72 0c                	jb     8002ce <printnum+0x3e>
  8002c2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002c5:	76 07                	jbe    8002ce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c7:	4b                   	dec    %ebx
  8002c8:	85 db                	test   %ebx,%ebx
  8002ca:	7f 31                	jg     8002fd <printnum+0x6d>
  8002cc:	eb 3f                	jmp    80030d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	57                   	push   %edi
  8002d2:	4b                   	dec    %ebx
  8002d3:	53                   	push   %ebx
  8002d4:	50                   	push   %eax
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002db:	ff 75 d0             	pushl  -0x30(%ebp)
  8002de:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e4:	e8 c7 08 00 00       	call   800bb0 <__udivdi3>
  8002e9:	83 c4 18             	add    $0x18,%esp
  8002ec:	52                   	push   %edx
  8002ed:	50                   	push   %eax
  8002ee:	89 f2                	mov    %esi,%edx
  8002f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f3:	e8 98 ff ff ff       	call   800290 <printnum>
  8002f8:	83 c4 20             	add    $0x20,%esp
  8002fb:	eb 10                	jmp    80030d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	56                   	push   %esi
  800301:	57                   	push   %edi
  800302:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800305:	4b                   	dec    %ebx
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	85 db                	test   %ebx,%ebx
  80030b:	7f f0                	jg     8002fd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	ff 75 d4             	pushl  -0x2c(%ebp)
  800317:	ff 75 d0             	pushl  -0x30(%ebp)
  80031a:	ff 75 dc             	pushl  -0x24(%ebp)
  80031d:	ff 75 d8             	pushl  -0x28(%ebp)
  800320:	e8 a7 09 00 00       	call   800ccc <__umoddi3>
  800325:	83 c4 14             	add    $0x14,%esp
  800328:	0f be 80 7a 0e 80 00 	movsbl 0x800e7a(%eax),%eax
  80032f:	50                   	push   %eax
  800330:	ff 55 e4             	call   *-0x1c(%ebp)
  800333:	83 c4 10             	add    $0x10,%esp
}
  800336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getint+0x16>
		return va_arg(*ap, long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 1a                	jmp    8003a8 <getint+0x30>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 0c                	je     80039e <getint+0x26>
		return va_arg(*ap, long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	99                   	cltd   
  80039c:	eb 0a                	jmp    8003a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 08                	jae    8003c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bd:	88 0a                	mov    %cl,(%edx)
  8003bf:	42                   	inc    %edx
  8003c0:	89 10                	mov    %edx,(%eax)
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cd:	50                   	push   %eax
  8003ce:	ff 75 10             	pushl  0x10(%ebp)
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	e8 05 00 00 00       	call   8003e1 <vprintfmt>
	va_end(ap);
  8003dc:	83 c4 10             	add    $0x10,%esp
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	57                   	push   %edi
  8003e5:	56                   	push   %esi
  8003e6:	53                   	push   %ebx
  8003e7:	83 ec 2c             	sub    $0x2c,%esp
  8003ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f0:	eb 13                	jmp    800405 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	0f 84 6d 03 00 00    	je     800767 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	57                   	push   %edi
  8003fe:	50                   	push   %eax
  8003ff:	ff 55 08             	call   *0x8(%ebp)
  800402:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800405:	0f b6 06             	movzbl (%esi),%eax
  800408:	46                   	inc    %esi
  800409:	83 f8 25             	cmp    $0x25,%eax
  80040c:	75 e4                	jne    8003f2 <vprintfmt+0x11>
  80040e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800412:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800419:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800420:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800427:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042c:	eb 28                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800430:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800434:	eb 20                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80043c:	eb 18                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800440:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800447:	eb 0d                	jmp    800456 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8a 06                	mov    (%esi),%al
  800458:	0f b6 d0             	movzbl %al,%edx
  80045b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80045e:	83 e8 23             	sub    $0x23,%eax
  800461:	3c 55                	cmp    $0x55,%al
  800463:	0f 87 e0 02 00 00    	ja     800749 <vprintfmt+0x368>
  800469:	0f b6 c0             	movzbl %al,%eax
  80046c:	ff 24 85 04 0f 80 00 	jmp    *0x800f04(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800473:	83 ea 30             	sub    $0x30,%edx
  800476:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800479:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80047c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80047f:	83 fa 09             	cmp    $0x9,%edx
  800482:	77 44                	ja     8004c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	89 de                	mov    %ebx,%esi
  800486:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80048a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80048d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800491:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800494:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800497:	83 fb 09             	cmp    $0x9,%ebx
  80049a:	76 ed                	jbe    800489 <vprintfmt+0xa8>
  80049c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80049f:	eb 29                	jmp    8004ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b1:	eb 17                	jmp    8004ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b7:	78 85                	js     80043e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	89 de                	mov    %ebx,%esi
  8004bb:	eb 99                	jmp    800456 <vprintfmt+0x75>
  8004bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c6:	eb 8e                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	79 86                	jns    800456 <vprintfmt+0x75>
  8004d0:	e9 74 ff ff ff       	jmp    800449 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	89 de                	mov    %ebx,%esi
  8004d8:	e9 79 ff ff ff       	jmp    800456 <vprintfmt+0x75>
  8004dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	57                   	push   %edi
  8004ed:	ff 30                	pushl  (%eax)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f8:	e9 08 ff ff ff       	jmp    800405 <vprintfmt+0x24>
  8004fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 02                	jns    800511 <vprintfmt+0x130>
  80050f:	f7 d8                	neg    %eax
  800511:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 f8 06             	cmp    $0x6,%eax
  800516:	7f 0b                	jg     800523 <vprintfmt+0x142>
  800518:	8b 04 85 5c 10 80 00 	mov    0x80105c(,%eax,4),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 1a                	jne    80053d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800523:	52                   	push   %edx
  800524:	68 92 0e 80 00       	push   $0x800e92
  800529:	57                   	push   %edi
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 92 fe ff ff       	call   8003c4 <printfmt>
  800532:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800538:	e9 c8 fe ff ff       	jmp    800405 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80053d:	50                   	push   %eax
  80053e:	68 1c 0e 80 00       	push   $0x800e1c
  800543:	57                   	push   %edi
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 78 fe ff ff       	call   8003c4 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800552:	e9 ae fe ff ff       	jmp    800405 <vprintfmt+0x24>
  800557:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80055a:	89 de                	mov    %ebx,%esi
  80055c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	85 c0                	test   %eax,%eax
  800572:	75 07                	jne    80057b <vprintfmt+0x19a>
				p = "(null)";
  800574:	c7 45 d0 8b 0e 80 00 	movl   $0x800e8b,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80057b:	85 db                	test   %ebx,%ebx
  80057d:	7e 42                	jle    8005c1 <vprintfmt+0x1e0>
  80057f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800583:	74 3c                	je     8005c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	51                   	push   %ecx
  800589:	ff 75 d0             	pushl  -0x30(%ebp)
  80058c:	e8 6f 02 00 00       	call   800800 <strnlen>
  800591:	29 c3                	sub    %eax,%ebx
  800593:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 db                	test   %ebx,%ebx
  80059b:	7e 24                	jle    8005c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80059d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	53                   	push   %ebx
  8005ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	4e                   	dec    %esi
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	7f f0                	jg     8005a7 <vprintfmt+0x1c6>
  8005b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c4:	0f be 02             	movsbl (%edx),%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	75 47                	jne    800612 <vprintfmt+0x231>
  8005cb:	eb 37                	jmp    800604 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	74 16                	je     8005e9 <vprintfmt+0x208>
  8005d3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d6:	83 fa 5e             	cmp    $0x5e,%edx
  8005d9:	76 0e                	jbe    8005e9 <vprintfmt+0x208>
					putch('?', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb 0b                	jmp    8005f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	50                   	push   %eax
  8005ee:	ff 55 08             	call   *0x8(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005f7:	0f be 03             	movsbl (%ebx),%eax
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	74 03                	je     800601 <vprintfmt+0x220>
  8005fe:	43                   	inc    %ebx
  8005ff:	eb 1b                	jmp    80061c <vprintfmt+0x23b>
  800601:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800604:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800608:	7f 1e                	jg     800628 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060d:	e9 f3 fd ff ff       	jmp    800405 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800612:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800615:	43                   	inc    %ebx
  800616:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800619:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80061c:	85 f6                	test   %esi,%esi
  80061e:	78 ad                	js     8005cd <vprintfmt+0x1ec>
  800620:	4e                   	dec    %esi
  800621:	79 aa                	jns    8005cd <vprintfmt+0x1ec>
  800623:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800626:	eb dc                	jmp    800604 <vprintfmt+0x223>
  800628:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 20                	push   $0x20
  800631:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800634:	4b                   	dec    %ebx
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	85 db                	test   %ebx,%ebx
  80063a:	7f ef                	jg     80062b <vprintfmt+0x24a>
  80063c:	e9 c4 fd ff ff       	jmp    800405 <vprintfmt+0x24>
  800641:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800644:	89 ca                	mov    %ecx,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 2a fd ff ff       	call   800378 <getint>
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800652:	85 d2                	test   %edx,%edx
  800654:	78 0a                	js     800660 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 b0 00 00 00       	jmp    800710 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	57                   	push   %edi
  800664:	6a 2d                	push   $0x2d
  800666:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800669:	f7 db                	neg    %ebx
  80066b:	83 d6 00             	adc    $0x0,%esi
  80066e:	f7 de                	neg    %esi
  800670:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
  800678:	e9 93 00 00 00       	jmp    800710 <vprintfmt+0x32f>
  80067d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 b4 fc ff ff       	call   80033e <getuint>
  80068a:	89 c3                	mov    %eax,%ebx
  80068c:	89 d6                	mov    %edx,%esi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 7b                	jmp    800710 <vprintfmt+0x32f>
  800695:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800698:	89 ca                	mov    %ecx,%edx
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	e8 d6 fc ff ff       	call   800378 <getint>
  8006a2:	89 c3                	mov    %eax,%ebx
  8006a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	78 07                	js     8006b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8006af:	eb 5f                	jmp    800710 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	57                   	push   %edi
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006ba:	f7 db                	neg    %ebx
  8006bc:	83 d6 00             	adc    $0x0,%esi
  8006bf:	f7 de                	neg    %esi
  8006c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c9:	eb 45                	jmp    800710 <vprintfmt+0x32f>
  8006cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	57                   	push   %edi
  8006d2:	6a 30                	push   $0x30
  8006d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d7:	83 c4 08             	add    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 78                	push   $0x78
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e9:	8b 18                	mov    (%eax),%ebx
  8006eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f8:	eb 16                	jmp    800710 <vprintfmt+0x32f>
  8006fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fd:	89 ca                	mov    %ecx,%edx
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 37 fc ff ff       	call   80033e <getuint>
  800707:	89 c3                	mov    %eax,%ebx
  800709:	89 d6                	mov    %edx,%esi
			base = 16;
  80070b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800717:	52                   	push   %edx
  800718:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071b:	50                   	push   %eax
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	89 fa                	mov    %edi,%edx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	e8 68 fb ff ff       	call   800290 <printnum>
			break;
  800728:	83 c4 20             	add    $0x20,%esp
  80072b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80072e:	e9 d2 fc ff ff       	jmp    800405 <vprintfmt+0x24>
  800733:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	57                   	push   %edi
  80073a:	52                   	push   %edx
  80073b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800744:	e9 bc fc ff ff       	jmp    800405 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	57                   	push   %edi
  80074d:	6a 25                	push   $0x25
  80074f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	eb 02                	jmp    800759 <vprintfmt+0x378>
  800757:	89 c6                	mov    %eax,%esi
  800759:	8d 46 ff             	lea    -0x1(%esi),%eax
  80075c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800760:	75 f5                	jne    800757 <vprintfmt+0x376>
  800762:	e9 9e fc ff ff       	jmp    800405 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 18             	sub    $0x18,%esp
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800782:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078c:	85 c0                	test   %eax,%eax
  80078e:	74 26                	je     8007b6 <vsnprintf+0x47>
  800790:	85 d2                	test   %edx,%edx
  800792:	7e 29                	jle    8007bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800794:	ff 75 14             	pushl  0x14(%ebp)
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	68 aa 03 80 00       	push   $0x8003aa
  8007a3:	e8 39 fc ff ff       	call   8003e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 0c                	jmp    8007c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bb:	eb 05                	jmp    8007c2 <vsnprintf+0x53>
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cd:	50                   	push   %eax
  8007ce:	ff 75 10             	pushl  0x10(%ebp)
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	ff 75 08             	pushl  0x8(%ebp)
  8007d7:	e8 93 ff ff ff       	call   80076f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e9:	74 0e                	je     8007f9 <strlen+0x19>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f5:	75 f9                	jne    8007f0 <strlen+0x10>
  8007f7:	eb 05                	jmp    8007fe <strlen+0x1e>
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 17                	je     800824 <strnlen+0x24>
  80080d:	80 39 00             	cmpb   $0x0,(%ecx)
  800810:	74 19                	je     80082b <strnlen+0x2b>
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800817:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	39 d0                	cmp    %edx,%eax
  80081a:	74 14                	je     800830 <strnlen+0x30>
  80081c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800820:	75 f5                	jne    800817 <strnlen+0x17>
  800822:	eb 0c                	jmp    800830 <strnlen+0x30>
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	eb 05                	jmp    800830 <strnlen+0x30>
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083c:	ba 00 00 00 00       	mov    $0x0,%edx
  800841:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800844:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800847:	42                   	inc    %edx
  800848:	84 c9                	test   %cl,%cl
  80084a:	75 f5                	jne    800841 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80084c:	5b                   	pop    %ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	53                   	push   %ebx
  800857:	e8 84 ff ff ff       	call   8007e0 <strlen>
  80085c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800865:	50                   	push   %eax
  800866:	e8 c7 ff ff ff       	call   800832 <strcpy>
	return dst;
}
  80086b:	89 d8                	mov    %ebx,%eax
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	85 f6                	test   %esi,%esi
  800882:	74 15                	je     800899 <strncpy+0x27>
  800884:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800889:	8a 1a                	mov    (%edx),%bl
  80088b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088e:	80 3a 01             	cmpb   $0x1,(%edx)
  800891:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	41                   	inc    %ecx
  800895:	39 ce                	cmp    %ecx,%esi
  800897:	77 f0                	ja     800889 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ac:	85 f6                	test   %esi,%esi
  8008ae:	74 32                	je     8008e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b0:	83 fe 01             	cmp    $0x1,%esi
  8008b3:	74 22                	je     8008d7 <strlcpy+0x3a>
  8008b5:	8a 0b                	mov    (%ebx),%cl
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	74 20                	je     8008db <strlcpy+0x3e>
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c5:	88 08                	mov    %cl,(%eax)
  8008c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c8:	39 f2                	cmp    %esi,%edx
  8008ca:	74 11                	je     8008dd <strlcpy+0x40>
  8008cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d0:	42                   	inc    %edx
  8008d1:	84 c9                	test   %cl,%cl
  8008d3:	75 f0                	jne    8008c5 <strlcpy+0x28>
  8008d5:	eb 06                	jmp    8008dd <strlcpy+0x40>
  8008d7:	89 f8                	mov    %edi,%eax
  8008d9:	eb 02                	jmp    8008dd <strlcpy+0x40>
  8008db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008dd:	c6 00 00             	movb   $0x0,(%eax)
  8008e0:	eb 02                	jmp    8008e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008e4:	29 f8                	sub    %edi,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f4:	8a 01                	mov    (%ecx),%al
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 10                	je     80090a <strcmp+0x1f>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	75 0c                	jne    80090a <strcmp+0x1f>
		p++, q++;
  8008fe:	41                   	inc    %ecx
  8008ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800900:	8a 01                	mov    (%ecx),%al
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strcmp+0x1f>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	74 f4                	je     8008fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 55 08             	mov    0x8(%ebp),%edx
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 1b                	je     800940 <strncmp+0x2c>
  800925:	8a 1a                	mov    (%edx),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	74 24                	je     80094f <strncmp+0x3b>
  80092b:	3a 19                	cmp    (%ecx),%bl
  80092d:	75 20                	jne    80094f <strncmp+0x3b>
  80092f:	48                   	dec    %eax
  800930:	74 15                	je     800947 <strncmp+0x33>
		n--, p++, q++;
  800932:	42                   	inc    %edx
  800933:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800934:	8a 1a                	mov    (%edx),%bl
  800936:	84 db                	test   %bl,%bl
  800938:	74 15                	je     80094f <strncmp+0x3b>
  80093a:	3a 19                	cmp    (%ecx),%bl
  80093c:	74 f1                	je     80092f <strncmp+0x1b>
  80093e:	eb 0f                	jmp    80094f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb 05                	jmp    80094c <strncmp+0x38>
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094c:	5b                   	pop    %ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 02             	movzbl (%edx),%eax
  800952:	0f b6 11             	movzbl (%ecx),%edx
  800955:	29 d0                	sub    %edx,%eax
  800957:	eb f3                	jmp    80094c <strncmp+0x38>

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800962:	8a 10                	mov    (%eax),%dl
  800964:	84 d2                	test   %dl,%dl
  800966:	74 18                	je     800980 <strchr+0x27>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	75 06                	jne    800972 <strchr+0x19>
  80096c:	eb 17                	jmp    800985 <strchr+0x2c>
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 13                	je     800985 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	40                   	inc    %eax
  800973:	8a 10                	mov    (%eax),%dl
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f5                	jne    80096e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 05                	jmp    800985 <strchr+0x2c>
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800990:	8a 10                	mov    (%eax),%dl
  800992:	84 d2                	test   %dl,%dl
  800994:	74 11                	je     8009a7 <strfind+0x20>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	75 06                	jne    8009a0 <strfind+0x19>
  80099a:	eb 0b                	jmp    8009a7 <strfind+0x20>
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 07                	je     8009a7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a0:	40                   	inc    %eax
  8009a1:	8a 10                	mov    (%eax),%dl
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	75 f5                	jne    80099c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 30                	je     8009ec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c2:	75 25                	jne    8009e9 <memset+0x40>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 20                	jne    8009e9 <memset+0x40>
		c &= 0xFF;
  8009c9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cc:	89 d3                	mov    %edx,%ebx
  8009ce:	c1 e3 08             	shl    $0x8,%ebx
  8009d1:	89 d6                	mov    %edx,%esi
  8009d3:	c1 e6 18             	shl    $0x18,%esi
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	c1 e0 10             	shl    $0x10,%eax
  8009db:	09 f0                	or     %esi,%eax
  8009dd:	09 d0                	or     %edx,%eax
  8009df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e4:	fc                   	cld    
  8009e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e7:	eb 03                	jmp    8009ec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e9:	fc                   	cld    
  8009ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ec:	89 f8                	mov    %edi,%eax
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a01:	39 c6                	cmp    %eax,%esi
  800a03:	73 34                	jae    800a39 <memmove+0x46>
  800a05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	73 2d                	jae    800a39 <memmove+0x46>
		s += n;
		d += n;
  800a0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 1b                	jne    800a2f <memmove+0x3c>
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 13                	jne    800a2f <memmove+0x3c>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 07                	jmp    800a36 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	4f                   	dec    %edi
  800a30:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a33:	fd                   	std    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a36:	fc                   	cld    
  800a37:	eb 20                	jmp    800a59 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3f:	75 13                	jne    800a54 <memmove+0x61>
  800a41:	a8 03                	test   $0x3,%al
  800a43:	75 0f                	jne    800a54 <memmove+0x61>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 0a                	jne    800a54 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 05                	jmp    800a59 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	fc                   	cld    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a60:	ff 75 10             	pushl  0x10(%ebp)
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	ff 75 08             	pushl  0x8(%ebp)
  800a69:	e8 85 ff ff ff       	call   8009f3 <memmove>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	74 32                	je     800ab5 <memcmp+0x45>
		if (*s1 != *s2)
  800a83:	8a 03                	mov    (%ebx),%al
  800a85:	8a 0e                	mov    (%esi),%cl
  800a87:	38 c8                	cmp    %cl,%al
  800a89:	74 19                	je     800aa4 <memcmp+0x34>
  800a8b:	eb 0d                	jmp    800a9a <memcmp+0x2a>
  800a8d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a91:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a95:	42                   	inc    %edx
  800a96:	38 c8                	cmp    %cl,%al
  800a98:	74 10                	je     800aaa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a9a:	0f b6 c0             	movzbl %al,%eax
  800a9d:	0f b6 c9             	movzbl %cl,%ecx
  800aa0:	29 c8                	sub    %ecx,%eax
  800aa2:	eb 16                	jmp    800aba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa4:	4f                   	dec    %edi
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	39 fa                	cmp    %edi,%edx
  800aac:	75 df                	jne    800a8d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	eb 05                	jmp    800aba <memcmp+0x4a>
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac5:	89 c2                	mov    %eax,%edx
  800ac7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	73 12                	jae    800ae0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad1:	38 08                	cmp    %cl,(%eax)
  800ad3:	75 06                	jne    800adb <memfind+0x1c>
  800ad5:	eb 09                	jmp    800ae0 <memfind+0x21>
  800ad7:	38 08                	cmp    %cl,(%eax)
  800ad9:	74 05                	je     800ae0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adb:	40                   	inc    %eax
  800adc:	39 c2                	cmp    %eax,%edx
  800ade:	77 f7                	ja     800ad7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aee:	eb 01                	jmp    800af1 <strtol+0xf>
		s++;
  800af0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af1:	8a 02                	mov    (%edx),%al
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f9                	je     800af0 <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f5                	je     800af0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 08                	jne    800b07 <strtol+0x25>
		s++;
  800aff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
  800b05:	eb 13                	jmp    800b1a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b07:	3c 2d                	cmp    $0x2d,%al
  800b09:	75 0a                	jne    800b15 <strtol+0x33>
		s++, neg = 1;
  800b0b:	8d 52 01             	lea    0x1(%edx),%edx
  800b0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b13:	eb 05                	jmp    800b1a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	74 05                	je     800b23 <strtol+0x41>
  800b1e:	83 fb 10             	cmp    $0x10,%ebx
  800b21:	75 28                	jne    800b4b <strtol+0x69>
  800b23:	8a 02                	mov    (%edx),%al
  800b25:	3c 30                	cmp    $0x30,%al
  800b27:	75 10                	jne    800b39 <strtol+0x57>
  800b29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b2d:	75 0a                	jne    800b39 <strtol+0x57>
		s += 2, base = 16;
  800b2f:	83 c2 02             	add    $0x2,%edx
  800b32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b37:	eb 12                	jmp    800b4b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b39:	85 db                	test   %ebx,%ebx
  800b3b:	75 0e                	jne    800b4b <strtol+0x69>
  800b3d:	3c 30                	cmp    $0x30,%al
  800b3f:	75 05                	jne    800b46 <strtol+0x64>
		s++, base = 8;
  800b41:	42                   	inc    %edx
  800b42:	b3 08                	mov    $0x8,%bl
  800b44:	eb 05                	jmp    800b4b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b46:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b52:	8a 0a                	mov    (%edx),%cl
  800b54:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 08                	ja     800b64 <strtol+0x82>
			dig = *s - '0';
  800b5c:	0f be c9             	movsbl %cl,%ecx
  800b5f:	83 e9 30             	sub    $0x30,%ecx
  800b62:	eb 1e                	jmp    800b82 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b64:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b67:	80 fb 19             	cmp    $0x19,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b6c:	0f be c9             	movsbl %cl,%ecx
  800b6f:	83 e9 57             	sub    $0x57,%ecx
  800b72:	eb 0e                	jmp    800b82 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b74:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b77:	80 fb 19             	cmp    $0x19,%bl
  800b7a:	77 13                	ja     800b8f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b7c:	0f be c9             	movsbl %cl,%ecx
  800b7f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b82:	39 f1                	cmp    %esi,%ecx
  800b84:	7d 0d                	jge    800b93 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b86:	42                   	inc    %edx
  800b87:	0f af c6             	imul   %esi,%eax
  800b8a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b8d:	eb c3                	jmp    800b52 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b8f:	89 c1                	mov    %eax,%ecx
  800b91:	eb 02                	jmp    800b95 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b93:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b99:	74 05                	je     800ba0 <strtol+0xbe>
		*endptr = (char *) s;
  800b9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba0:	85 ff                	test   %edi,%edi
  800ba2:	74 04                	je     800ba8 <strtol+0xc6>
  800ba4:	89 c8                	mov    %ecx,%eax
  800ba6:	f7 d8                	neg    %eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    
  800bad:	00 00                	add    %al,(%eax)
	...

00800bb0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	83 ec 10             	sub    $0x10,%esp
  800bb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bbe:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bc4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	75 2e                	jne    800bfc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bce:	39 f1                	cmp    %esi,%ecx
  800bd0:	77 5a                	ja     800c2c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bd2:	85 c9                	test   %ecx,%ecx
  800bd4:	75 0b                	jne    800be1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdb:	31 d2                	xor    %edx,%edx
  800bdd:	f7 f1                	div    %ecx
  800bdf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800be1:	31 d2                	xor    %edx,%edx
  800be3:	89 f0                	mov    %esi,%eax
  800be5:	f7 f1                	div    %ecx
  800be7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800be9:	89 f8                	mov    %edi,%eax
  800beb:	f7 f1                	div    %ecx
  800bed:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bf3:	83 c4 10             	add    $0x10,%esp
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    
  800bfa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bfc:	39 f0                	cmp    %esi,%eax
  800bfe:	77 1c                	ja     800c1c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c00:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c03:	83 f7 1f             	xor    $0x1f,%edi
  800c06:	75 3c                	jne    800c44 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c08:	39 f0                	cmp    %esi,%eax
  800c0a:	0f 82 90 00 00 00    	jb     800ca0 <__udivdi3+0xf0>
  800c10:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c13:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c16:	0f 86 84 00 00 00    	jbe    800ca0 <__udivdi3+0xf0>
  800c1c:	31 f6                	xor    %esi,%esi
  800c1e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c20:	89 f8                	mov    %edi,%eax
  800c22:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    
  800c2b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c2c:	89 f2                	mov    %esi,%edx
  800c2e:	89 f8                	mov    %edi,%eax
  800c30:	f7 f1                	div    %ecx
  800c32:	89 c7                	mov    %eax,%edi
  800c34:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c36:	89 f8                	mov    %edi,%eax
  800c38:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    
  800c41:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c44:	89 f9                	mov    %edi,%ecx
  800c46:	d3 e0                	shl    %cl,%eax
  800c48:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c4b:	b8 20 00 00 00       	mov    $0x20,%eax
  800c50:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c55:	88 c1                	mov    %al,%cl
  800c57:	d3 ea                	shr    %cl,%edx
  800c59:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c5c:	09 ca                	or     %ecx,%edx
  800c5e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c64:	89 f9                	mov    %edi,%ecx
  800c66:	d3 e2                	shl    %cl,%edx
  800c68:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c6b:	89 f2                	mov    %esi,%edx
  800c6d:	88 c1                	mov    %al,%cl
  800c6f:	d3 ea                	shr    %cl,%edx
  800c71:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c74:	89 f2                	mov    %esi,%edx
  800c76:	89 f9                	mov    %edi,%ecx
  800c78:	d3 e2                	shl    %cl,%edx
  800c7a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c7d:	88 c1                	mov    %al,%cl
  800c7f:	d3 ee                	shr    %cl,%esi
  800c81:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c83:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c86:	89 f0                	mov    %esi,%eax
  800c88:	89 ca                	mov    %ecx,%edx
  800c8a:	f7 75 ec             	divl   -0x14(%ebp)
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c91:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c94:	39 d1                	cmp    %edx,%ecx
  800c96:	72 28                	jb     800cc0 <__udivdi3+0x110>
  800c98:	74 1a                	je     800cb4 <__udivdi3+0x104>
  800c9a:	89 f7                	mov    %esi,%edi
  800c9c:	31 f6                	xor    %esi,%esi
  800c9e:	eb 80                	jmp    800c20 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ca0:	31 f6                	xor    %esi,%esi
  800ca2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ca7:	89 f8                	mov    %edi,%eax
  800ca9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    
  800cb2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cb7:	89 f9                	mov    %edi,%ecx
  800cb9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cbb:	39 c2                	cmp    %eax,%edx
  800cbd:	73 db                	jae    800c9a <__udivdi3+0xea>
  800cbf:	90                   	nop
		{
		  q0--;
  800cc0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cc3:	31 f6                	xor    %esi,%esi
  800cc5:	e9 56 ff ff ff       	jmp    800c20 <__udivdi3+0x70>
	...

00800ccc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	83 ec 20             	sub    $0x20,%esp
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cda:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ce3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ce6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ce9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	75 15                	jne    800d04 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cef:	39 f1                	cmp    %esi,%ecx
  800cf1:	0f 86 99 00 00 00    	jbe    800d90 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cf7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cf9:	89 d0                	mov    %edx,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800cfd:	83 c4 20             	add    $0x20,%esp
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d04:	39 f7                	cmp    %esi,%edi
  800d06:	0f 87 a4 00 00 00    	ja     800db0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d0c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d0f:	83 f0 1f             	xor    $0x1f,%eax
  800d12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d15:	0f 84 a1 00 00 00    	je     800dbc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d20:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d22:	bf 20 00 00 00       	mov    $0x20,%edi
  800d27:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d2d:	89 f9                	mov    %edi,%ecx
  800d2f:	d3 ea                	shr    %cl,%edx
  800d31:	09 c2                	or     %eax,%edx
  800d33:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d39:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d3c:	d3 e0                	shl    %cl,%eax
  800d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d41:	89 f2                	mov    %esi,%edx
  800d43:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d48:	d3 e0                	shl    %cl,%eax
  800d4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d50:	89 f9                	mov    %edi,%ecx
  800d52:	d3 e8                	shr    %cl,%eax
  800d54:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d56:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d58:	89 f2                	mov    %esi,%edx
  800d5a:	f7 75 f0             	divl   -0x10(%ebp)
  800d5d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d5f:	f7 65 f4             	mull   -0xc(%ebp)
  800d62:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d65:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d67:	39 d6                	cmp    %edx,%esi
  800d69:	72 71                	jb     800ddc <__umoddi3+0x110>
  800d6b:	74 7f                	je     800dec <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d70:	29 c8                	sub    %ecx,%eax
  800d72:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d74:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	89 f2                	mov    %esi,%edx
  800d7b:	89 f9                	mov    %edi,%ecx
  800d7d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d7f:	09 d0                	or     %edx,%eax
  800d81:	89 f2                	mov    %esi,%edx
  800d83:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d86:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    
  800d8f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d90:	85 c9                	test   %ecx,%ecx
  800d92:	75 0b                	jne    800d9f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d94:	b8 01 00 00 00       	mov    $0x1,%eax
  800d99:	31 d2                	xor    %edx,%edx
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d9f:	89 f0                	mov    %esi,%eax
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da8:	f7 f1                	div    %ecx
  800daa:	e9 4a ff ff ff       	jmp    800cf9 <__umoddi3+0x2d>
  800daf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800db0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800db2:	83 c4 20             	add    $0x20,%esp
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    
  800db9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dbc:	39 f7                	cmp    %esi,%edi
  800dbe:	72 05                	jb     800dc5 <__umoddi3+0xf9>
  800dc0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dc3:	77 0c                	ja     800dd1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc5:	89 f2                	mov    %esi,%edx
  800dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dca:	29 c8                	sub    %ecx,%eax
  800dcc:	19 fa                	sbb    %edi,%edx
  800dce:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd4:	83 c4 20             	add    $0x20,%esp
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    
  800ddb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ddc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800de4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800de7:	eb 84                	jmp    800d6d <__umoddi3+0xa1>
  800de9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800def:	72 eb                	jb     800ddc <__umoddi3+0x110>
  800df1:	89 f2                	mov    %esi,%edx
  800df3:	e9 75 ff ff ff       	jmp    800d6d <__umoddi3+0xa1>
