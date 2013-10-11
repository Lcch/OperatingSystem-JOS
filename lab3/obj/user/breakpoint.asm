
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
  80004f:	e8 34 01 00 00       	call   800188 <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005c:	c1 e0 05             	shl    $0x5,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x30>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000
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
  800098:	e8 c9 00 00 00       	call   800166 <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 1c             	sub    $0x1c,%esp
  8000ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b3:	89 ca                	mov    %ecx,%edx
	assert(a5 == 0);
  8000b5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000b9:	74 16                	je     8000d1 <my_sysenter+0x2d>
  8000bb:	68 0a 0e 80 00       	push   $0x800e0a
  8000c0:	68 12 0e 80 00       	push   $0x800e12
  8000c5:	6a 0b                	push   $0xb
  8000c7:	68 27 0e 80 00       	push   $0x800e27
  8000cc:	e8 db 00 00 00       	call   8001ac <_panic>
	int32_t ret;

	asm volatile(
  8000d1:	be 00 00 00 00       	mov    $0x0,%esi
  8000d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e2:	55                   	push   %ebp
  8000e3:	54                   	push   %esp
  8000e4:	5d                   	pop    %ebp
  8000e5:	8d 35 ed 00 80 00    	lea    0x8000ed,%esi
  8000eb:	0f 34                	sysenter 

008000ed <after_sysenter_label>:
  8000ed:	5d                   	pop    %ebp
  8000ee:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000f4:	74 1c                	je     800112 <after_sysenter_label+0x25>
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	7e 18                	jle    800112 <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  8000fa:	83 ec 0c             	sub    $0xc,%esp
  8000fd:	50                   	push   %eax
  8000fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800101:	68 38 0e 80 00       	push   $0x800e38
  800106:	6a 20                	push   $0x20
  800108:	68 27 0e 80 00       	push   $0x800e27
  80010d:	e8 9a 00 00 00       	call   8001ac <_panic>

	return ret;
}
  800112:	89 d0                	mov    %edx,%eax
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	6a 00                	push   $0x0
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 00 00 00 00       	mov    $0x0,%eax
  800138:	e8 67 ff ff ff       	call   8000a4 <my_sysenter>
  80013d:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <sys_cgetc>:

int
sys_cgetc(void)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800148:	6a 00                	push   $0x0
  80014a:	6a 00                	push   $0x0
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	b9 00 00 00 00       	mov    $0x0,%ecx
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 01 00 00 00       	mov    $0x1,%eax
  80015f:	e8 40 ff ff ff       	call   8000a4 <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80016c:	6a 00                	push   $0x0
  80016e:	6a 00                	push   $0x0
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800177:	ba 01 00 00 00       	mov    $0x1,%edx
  80017c:	b8 03 00 00 00       	mov    $0x3,%eax
  800181:	e8 1e ff ff ff       	call   8000a4 <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80018e:	6a 00                	push   $0x0
  800190:	6a 00                	push   $0x0
  800192:	6a 00                	push   $0x0
  800194:	6a 00                	push   $0x0
  800196:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019b:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a5:	e8 fa fe ff ff       	call   8000a4 <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001b1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001ba:	e8 c9 ff ff ff       	call   800188 <sys_getenvid>
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	ff 75 0c             	pushl  0xc(%ebp)
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	53                   	push   %ebx
  8001c9:	50                   	push   %eax
  8001ca:	68 5c 0e 80 00       	push   $0x800e5c
  8001cf:	e8 b0 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	56                   	push   %esi
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	e8 53 00 00 00       	call   800233 <vcprintf>
	cprintf("\n");
  8001e0:	c7 04 24 80 0e 80 00 	movl   $0x800e80,(%esp)
  8001e7:	e8 98 00 00 00       	call   800284 <cprintf>
  8001ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ef:	cc                   	int3   
  8001f0:	eb fd                	jmp    8001ef <_panic+0x43>
	...

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	40                   	inc    %eax
  800208:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	75 1a                	jne    80022b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	68 ff 00 00 00       	push   $0xff
  800219:	8d 43 08             	lea    0x8(%ebx),%eax
  80021c:	50                   	push   %eax
  80021d:	e8 fa fe ff ff       	call   80011c <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800228:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022b:	ff 43 04             	incl   0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f4 01 80 00       	push   $0x8001f4
  800262:	e8 82 01 00 00       	call   8003e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 a0 fe ff ff       	call   80011c <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 2c             	sub    $0x2c,%esp
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	89 d6                	mov    %edx,%esi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c8:	72 0c                	jb     8002d6 <printnum+0x3e>
  8002ca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002cd:	76 07                	jbe    8002d6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cf:	4b                   	dec    %ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f 31                	jg     800305 <printnum+0x6d>
  8002d4:	eb 3f                	jmp    800315 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	57                   	push   %edi
  8002da:	4b                   	dec    %ebx
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	e8 c7 08 00 00       	call   800bb8 <__udivdi3>
  8002f1:	83 c4 18             	add    $0x18,%esp
  8002f4:	52                   	push   %edx
  8002f5:	50                   	push   %eax
  8002f6:	89 f2                	mov    %esi,%edx
  8002f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fb:	e8 98 ff ff ff       	call   800298 <printnum>
  800300:	83 c4 20             	add    $0x20,%esp
  800303:	eb 10                	jmp    800315 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	56                   	push   %esi
  800309:	57                   	push   %edi
  80030a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030d:	4b                   	dec    %ebx
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	85 db                	test   %ebx,%ebx
  800313:	7f f0                	jg     800305 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	83 ec 04             	sub    $0x4,%esp
  80031c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031f:	ff 75 d0             	pushl  -0x30(%ebp)
  800322:	ff 75 dc             	pushl  -0x24(%ebp)
  800325:	ff 75 d8             	pushl  -0x28(%ebp)
  800328:	e8 a7 09 00 00       	call   800cd4 <__umoddi3>
  80032d:	83 c4 14             	add    $0x14,%esp
  800330:	0f be 80 82 0e 80 00 	movsbl 0x800e82(%eax),%eax
  800337:	50                   	push   %eax
  800338:	ff 55 e4             	call   *-0x1c(%ebp)
  80033b:	83 c4 10             	add    $0x10,%esp
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800383:	83 fa 01             	cmp    $0x1,%edx
  800386:	7e 0e                	jle    800396 <getint+0x16>
		return va_arg(*ap, long long);
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 02                	mov    (%edx),%eax
  800391:	8b 52 04             	mov    0x4(%edx),%edx
  800394:	eb 1a                	jmp    8003b0 <getint+0x30>
	else if (lflag)
  800396:	85 d2                	test   %edx,%edx
  800398:	74 0c                	je     8003a6 <getint+0x26>
		return va_arg(*ap, long);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	99                   	cltd   
  8003a4:	eb 0a                	jmp    8003b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	99                   	cltd   
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c0:	73 08                	jae    8003ca <sprintputch+0x18>
		*b->buf++ = ch;
  8003c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c5:	88 0a                	mov    %cl,(%edx)
  8003c7:	42                   	inc    %edx
  8003c8:	89 10                	mov    %edx,(%eax)
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d5:	50                   	push   %eax
  8003d6:	ff 75 10             	pushl  0x10(%ebp)
  8003d9:	ff 75 0c             	pushl  0xc(%ebp)
  8003dc:	ff 75 08             	pushl  0x8(%ebp)
  8003df:	e8 05 00 00 00       	call   8003e9 <vprintfmt>
	va_end(ap);
  8003e4:	83 c4 10             	add    $0x10,%esp
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 2c             	sub    $0x2c,%esp
  8003f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f8:	eb 13                	jmp    80040d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	0f 84 6d 03 00 00    	je     80076f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	57                   	push   %edi
  800406:	50                   	push   %eax
  800407:	ff 55 08             	call   *0x8(%ebp)
  80040a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	0f b6 06             	movzbl (%esi),%eax
  800410:	46                   	inc    %esi
  800411:	83 f8 25             	cmp    $0x25,%eax
  800414:	75 e4                	jne    8003fa <vprintfmt+0x11>
  800416:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80041a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800421:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800428:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	eb 28                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800438:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80043c:	eb 20                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800444:	eb 18                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800448:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044f:	eb 0d                	jmp    80045e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800451:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800457:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8a 06                	mov    (%esi),%al
  800460:	0f b6 d0             	movzbl %al,%edx
  800463:	8d 5e 01             	lea    0x1(%esi),%ebx
  800466:	83 e8 23             	sub    $0x23,%eax
  800469:	3c 55                	cmp    $0x55,%al
  80046b:	0f 87 e0 02 00 00    	ja     800751 <vprintfmt+0x368>
  800471:	0f b6 c0             	movzbl %al,%eax
  800474:	ff 24 85 0c 0f 80 00 	jmp    *0x800f0c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047b:	83 ea 30             	sub    $0x30,%edx
  80047e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800481:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800484:	8d 50 d0             	lea    -0x30(%eax),%edx
  800487:	83 fa 09             	cmp    $0x9,%edx
  80048a:	77 44                	ja     8004d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	89 de                	mov    %ebx,%esi
  80048e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800491:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800492:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800495:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800499:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80049c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049f:	83 fb 09             	cmp    $0x9,%ebx
  8004a2:	76 ed                	jbe    800491 <vprintfmt+0xa8>
  8004a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a7:	eb 29                	jmp    8004d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b9:	eb 17                	jmp    8004d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bf:	78 85                	js     800446 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	89 de                	mov    %ebx,%esi
  8004c3:	eb 99                	jmp    80045e <vprintfmt+0x75>
  8004c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ce:	eb 8e                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d6:	79 86                	jns    80045e <vprintfmt+0x75>
  8004d8:	e9 74 ff ff ff       	jmp    800451 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	89 de                	mov    %ebx,%esi
  8004e0:	e9 79 ff ff ff       	jmp    80045e <vprintfmt+0x75>
  8004e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	57                   	push   %edi
  8004f5:	ff 30                	pushl  (%eax)
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800500:	e9 08 ff ff ff       	jmp    80040d <vprintfmt+0x24>
  800505:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	85 c0                	test   %eax,%eax
  800515:	79 02                	jns    800519 <vprintfmt+0x130>
  800517:	f7 d8                	neg    %eax
  800519:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051b:	83 f8 06             	cmp    $0x6,%eax
  80051e:	7f 0b                	jg     80052b <vprintfmt+0x142>
  800520:	8b 04 85 64 10 80 00 	mov    0x801064(,%eax,4),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 1a                	jne    800545 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80052b:	52                   	push   %edx
  80052c:	68 9a 0e 80 00       	push   $0x800e9a
  800531:	57                   	push   %edi
  800532:	ff 75 08             	pushl  0x8(%ebp)
  800535:	e8 92 fe ff ff       	call   8003cc <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800540:	e9 c8 fe ff ff       	jmp    80040d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800545:	50                   	push   %eax
  800546:	68 24 0e 80 00       	push   $0x800e24
  80054b:	57                   	push   %edi
  80054c:	ff 75 08             	pushl  0x8(%ebp)
  80054f:	e8 78 fe ff ff       	call   8003cc <printfmt>
  800554:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055a:	e9 ae fe ff ff       	jmp    80040d <vprintfmt+0x24>
  80055f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800562:	89 de                	mov    %ebx,%esi
  800564:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800567:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800578:	85 c0                	test   %eax,%eax
  80057a:	75 07                	jne    800583 <vprintfmt+0x19a>
				p = "(null)";
  80057c:	c7 45 d0 93 0e 80 00 	movl   $0x800e93,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800583:	85 db                	test   %ebx,%ebx
  800585:	7e 42                	jle    8005c9 <vprintfmt+0x1e0>
  800587:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80058b:	74 3c                	je     8005c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	51                   	push   %ecx
  800591:	ff 75 d0             	pushl  -0x30(%ebp)
  800594:	e8 6f 02 00 00       	call   800808 <strnlen>
  800599:	29 c3                	sub    %eax,%ebx
  80059b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	85 db                	test   %ebx,%ebx
  8005a3:	7e 24                	jle    8005c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	53                   	push   %ebx
  8005b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	4e                   	dec    %esi
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	85 f6                	test   %esi,%esi
  8005bd:	7f f0                	jg     8005af <vprintfmt+0x1c6>
  8005bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cc:	0f be 02             	movsbl (%edx),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	75 47                	jne    80061a <vprintfmt+0x231>
  8005d3:	eb 37                	jmp    80060c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	74 16                	je     8005f1 <vprintfmt+0x208>
  8005db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005de:	83 fa 5e             	cmp    $0x5e,%edx
  8005e1:	76 0e                	jbe    8005f1 <vprintfmt+0x208>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	57                   	push   %edi
  8005e7:	6a 3f                	push   $0x3f
  8005e9:	ff 55 08             	call   *0x8(%ebp)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb 0b                	jmp    8005fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	50                   	push   %eax
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ff:	0f be 03             	movsbl (%ebx),%eax
  800602:	85 c0                	test   %eax,%eax
  800604:	74 03                	je     800609 <vprintfmt+0x220>
  800606:	43                   	inc    %ebx
  800607:	eb 1b                	jmp    800624 <vprintfmt+0x23b>
  800609:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800610:	7f 1e                	jg     800630 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800615:	e9 f3 fd ff ff       	jmp    80040d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061d:	43                   	inc    %ebx
  80061e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800621:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800624:	85 f6                	test   %esi,%esi
  800626:	78 ad                	js     8005d5 <vprintfmt+0x1ec>
  800628:	4e                   	dec    %esi
  800629:	79 aa                	jns    8005d5 <vprintfmt+0x1ec>
  80062b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80062e:	eb dc                	jmp    80060c <vprintfmt+0x223>
  800630:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	57                   	push   %edi
  800637:	6a 20                	push   $0x20
  800639:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063c:	4b                   	dec    %ebx
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	85 db                	test   %ebx,%ebx
  800642:	7f ef                	jg     800633 <vprintfmt+0x24a>
  800644:	e9 c4 fd ff ff       	jmp    80040d <vprintfmt+0x24>
  800649:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 2a fd ff ff       	call   800380 <getint>
  800656:	89 c3                	mov    %eax,%ebx
  800658:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80065a:	85 d2                	test   %edx,%edx
  80065c:	78 0a                	js     800668 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 b0 00 00 00       	jmp    800718 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	57                   	push   %edi
  80066c:	6a 2d                	push   $0x2d
  80066e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800671:	f7 db                	neg    %ebx
  800673:	83 d6 00             	adc    $0x0,%esi
  800676:	f7 de                	neg    %esi
  800678:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800680:	e9 93 00 00 00       	jmp    800718 <vprintfmt+0x32f>
  800685:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800688:	89 ca                	mov    %ecx,%edx
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 b4 fc ff ff       	call   800346 <getuint>
  800692:	89 c3                	mov    %eax,%ebx
  800694:	89 d6                	mov    %edx,%esi
			base = 10;
  800696:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069b:	eb 7b                	jmp    800718 <vprintfmt+0x32f>
  80069d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006a0:	89 ca                	mov    %ecx,%edx
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	e8 d6 fc ff ff       	call   800380 <getint>
  8006aa:	89 c3                	mov    %eax,%ebx
  8006ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	78 07                	js     8006b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b7:	eb 5f                	jmp    800718 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	57                   	push   %edi
  8006bd:	6a 2d                	push   $0x2d
  8006bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006c2:	f7 db                	neg    %ebx
  8006c4:	83 d6 00             	adc    $0x0,%esi
  8006c7:	f7 de                	neg    %esi
  8006c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d1:	eb 45                	jmp    800718 <vprintfmt+0x32f>
  8006d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	57                   	push   %edi
  8006da:	6a 30                	push   $0x30
  8006dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 78                	push   $0x78
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f1:	8b 18                	mov    (%eax),%ebx
  8006f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800700:	eb 16                	jmp    800718 <vprintfmt+0x32f>
  800702:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800705:	89 ca                	mov    %ecx,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 37 fc ff ff       	call   800346 <getuint>
  80070f:	89 c3                	mov    %eax,%ebx
  800711:	89 d6                	mov    %edx,%esi
			base = 16;
  800713:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071f:	52                   	push   %edx
  800720:	ff 75 e4             	pushl  -0x1c(%ebp)
  800723:	50                   	push   %eax
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	89 fa                	mov    %edi,%edx
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	e8 68 fb ff ff       	call   800298 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800736:	e9 d2 fc ff ff       	jmp    80040d <vprintfmt+0x24>
  80073b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	57                   	push   %edi
  800742:	52                   	push   %edx
  800743:	ff 55 08             	call   *0x8(%ebp)
			break;
  800746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074c:	e9 bc fc ff ff       	jmp    80040d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	57                   	push   %edi
  800755:	6a 25                	push   $0x25
  800757:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 02                	jmp    800761 <vprintfmt+0x378>
  80075f:	89 c6                	mov    %eax,%esi
  800761:	8d 46 ff             	lea    -0x1(%esi),%eax
  800764:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800768:	75 f5                	jne    80075f <vprintfmt+0x376>
  80076a:	e9 9e fc ff ff       	jmp    80040d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80076f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800772:	5b                   	pop    %ebx
  800773:	5e                   	pop    %esi
  800774:	5f                   	pop    %edi
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 18             	sub    $0x18,%esp
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800786:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800794:	85 c0                	test   %eax,%eax
  800796:	74 26                	je     8007be <vsnprintf+0x47>
  800798:	85 d2                	test   %edx,%edx
  80079a:	7e 29                	jle    8007c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079c:	ff 75 14             	pushl  0x14(%ebp)
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	68 b2 03 80 00       	push   $0x8003b2
  8007ab:	e8 39 fc ff ff       	call   8003e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 0c                	jmp    8007ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c3:	eb 05                	jmp    8007ca <vsnprintf+0x53>
  8007c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d5:	50                   	push   %eax
  8007d6:	ff 75 10             	pushl  0x10(%ebp)
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 93 ff ff ff       	call   800777 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f1:	74 0e                	je     800801 <strlen+0x19>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fd:	75 f9                	jne    8007f8 <strlen+0x10>
  8007ff:	eb 05                	jmp    800806 <strlen+0x1e>
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	85 d2                	test   %edx,%edx
  800813:	74 17                	je     80082c <strnlen+0x24>
  800815:	80 39 00             	cmpb   $0x0,(%ecx)
  800818:	74 19                	je     800833 <strnlen+0x2b>
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80081f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	39 d0                	cmp    %edx,%eax
  800822:	74 14                	je     800838 <strnlen+0x30>
  800824:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800828:	75 f5                	jne    80081f <strnlen+0x17>
  80082a:	eb 0c                	jmp    800838 <strnlen+0x30>
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 05                	jmp    800838 <strnlen+0x30>
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
  800849:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80084c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80084f:	42                   	inc    %edx
  800850:	84 c9                	test   %cl,%cl
  800852:	75 f5                	jne    800849 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085e:	53                   	push   %ebx
  80085f:	e8 84 ff ff ff       	call   8007e8 <strlen>
  800864:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80086d:	50                   	push   %eax
  80086e:	e8 c7 ff ff ff       	call   80083a <strcpy>
	return dst;
}
  800873:	89 d8                	mov    %ebx,%eax
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	85 f6                	test   %esi,%esi
  80088a:	74 15                	je     8008a1 <strncpy+0x27>
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800891:	8a 1a                	mov    (%edx),%bl
  800893:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800896:	80 3a 01             	cmpb   $0x1,(%edx)
  800899:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089c:	41                   	inc    %ecx
  80089d:	39 ce                	cmp    %ecx,%esi
  80089f:	77 f0                	ja     800891 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	85 f6                	test   %esi,%esi
  8008b6:	74 32                	je     8008ea <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b8:	83 fe 01             	cmp    $0x1,%esi
  8008bb:	74 22                	je     8008df <strlcpy+0x3a>
  8008bd:	8a 0b                	mov    (%ebx),%cl
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 20                	je     8008e3 <strlcpy+0x3e>
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008ca:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cd:	88 08                	mov    %cl,(%eax)
  8008cf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d0:	39 f2                	cmp    %esi,%edx
  8008d2:	74 11                	je     8008e5 <strlcpy+0x40>
  8008d4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d8:	42                   	inc    %edx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	75 f0                	jne    8008cd <strlcpy+0x28>
  8008dd:	eb 06                	jmp    8008e5 <strlcpy+0x40>
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	eb 02                	jmp    8008e5 <strlcpy+0x40>
  8008e3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e5:	c6 00 00             	movb   $0x0,(%eax)
  8008e8:	eb 02                	jmp    8008ec <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ea:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008ec:	29 f8                	sub    %edi,%eax
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fc:	8a 01                	mov    (%ecx),%al
  8008fe:	84 c0                	test   %al,%al
  800900:	74 10                	je     800912 <strcmp+0x1f>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	75 0c                	jne    800912 <strcmp+0x1f>
		p++, q++;
  800906:	41                   	inc    %ecx
  800907:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800908:	8a 01                	mov    (%ecx),%al
  80090a:	84 c0                	test   %al,%al
  80090c:	74 04                	je     800912 <strcmp+0x1f>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	74 f4                	je     800906 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 c0             	movzbl %al,%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 55 08             	mov    0x8(%ebp),%edx
  800923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800926:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800929:	85 c0                	test   %eax,%eax
  80092b:	74 1b                	je     800948 <strncmp+0x2c>
  80092d:	8a 1a                	mov    (%edx),%bl
  80092f:	84 db                	test   %bl,%bl
  800931:	74 24                	je     800957 <strncmp+0x3b>
  800933:	3a 19                	cmp    (%ecx),%bl
  800935:	75 20                	jne    800957 <strncmp+0x3b>
  800937:	48                   	dec    %eax
  800938:	74 15                	je     80094f <strncmp+0x33>
		n--, p++, q++;
  80093a:	42                   	inc    %edx
  80093b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093c:	8a 1a                	mov    (%edx),%bl
  80093e:	84 db                	test   %bl,%bl
  800940:	74 15                	je     800957 <strncmp+0x3b>
  800942:	3a 19                	cmp    (%ecx),%bl
  800944:	74 f1                	je     800937 <strncmp+0x1b>
  800946:	eb 0f                	jmp    800957 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
  80094d:	eb 05                	jmp    800954 <strncmp+0x38>
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800954:	5b                   	pop    %ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 02             	movzbl (%edx),%eax
  80095a:	0f b6 11             	movzbl (%ecx),%edx
  80095d:	29 d0                	sub    %edx,%eax
  80095f:	eb f3                	jmp    800954 <strncmp+0x38>

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096a:	8a 10                	mov    (%eax),%dl
  80096c:	84 d2                	test   %dl,%dl
  80096e:	74 18                	je     800988 <strchr+0x27>
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	75 06                	jne    80097a <strchr+0x19>
  800974:	eb 17                	jmp    80098d <strchr+0x2c>
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 13                	je     80098d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	40                   	inc    %eax
  80097b:	8a 10                	mov    (%eax),%dl
  80097d:	84 d2                	test   %dl,%dl
  80097f:	75 f5                	jne    800976 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 05                	jmp    80098d <strchr+0x2c>
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800998:	8a 10                	mov    (%eax),%dl
  80099a:	84 d2                	test   %dl,%dl
  80099c:	74 11                	je     8009af <strfind+0x20>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	75 06                	jne    8009a8 <strfind+0x19>
  8009a2:	eb 0b                	jmp    8009af <strfind+0x20>
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 07                	je     8009af <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	40                   	inc    %eax
  8009a9:	8a 10                	mov    (%eax),%dl
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	75 f5                	jne    8009a4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	74 30                	je     8009f4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ca:	75 25                	jne    8009f1 <memset+0x40>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 20                	jne    8009f1 <memset+0x40>
		c &= 0xFF;
  8009d1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d4:	89 d3                	mov    %edx,%ebx
  8009d6:	c1 e3 08             	shl    $0x8,%ebx
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	c1 e6 18             	shl    $0x18,%esi
  8009de:	89 d0                	mov    %edx,%eax
  8009e0:	c1 e0 10             	shl    $0x10,%eax
  8009e3:	09 f0                	or     %esi,%eax
  8009e5:	09 d0                	or     %edx,%eax
  8009e7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009ec:	fc                   	cld    
  8009ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ef:	eb 03                	jmp    8009f4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a09:	39 c6                	cmp    %eax,%esi
  800a0b:	73 34                	jae    800a41 <memmove+0x46>
  800a0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a10:	39 d0                	cmp    %edx,%eax
  800a12:	73 2d                	jae    800a41 <memmove+0x46>
		s += n;
		d += n;
  800a14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	f6 c2 03             	test   $0x3,%dl
  800a1a:	75 1b                	jne    800a37 <memmove+0x3c>
  800a1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a22:	75 13                	jne    800a37 <memmove+0x3c>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	75 0e                	jne    800a37 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a29:	83 ef 04             	sub    $0x4,%edi
  800a2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a32:	fd                   	std    
  800a33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a35:	eb 07                	jmp    800a3e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a37:	4f                   	dec    %edi
  800a38:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3b:	fd                   	std    
  800a3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3e:	fc                   	cld    
  800a3f:	eb 20                	jmp    800a61 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a41:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a47:	75 13                	jne    800a5c <memmove+0x61>
  800a49:	a8 03                	test   $0x3,%al
  800a4b:	75 0f                	jne    800a5c <memmove+0x61>
  800a4d:	f6 c1 03             	test   $0x3,%cl
  800a50:	75 0a                	jne    800a5c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a52:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5a:	eb 05                	jmp    800a61 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a68:	ff 75 10             	pushl  0x10(%ebp)
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	ff 75 08             	pushl  0x8(%ebp)
  800a71:	e8 85 ff ff ff       	call   8009fb <memmove>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a84:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a87:	85 ff                	test   %edi,%edi
  800a89:	74 32                	je     800abd <memcmp+0x45>
		if (*s1 != *s2)
  800a8b:	8a 03                	mov    (%ebx),%al
  800a8d:	8a 0e                	mov    (%esi),%cl
  800a8f:	38 c8                	cmp    %cl,%al
  800a91:	74 19                	je     800aac <memcmp+0x34>
  800a93:	eb 0d                	jmp    800aa2 <memcmp+0x2a>
  800a95:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a99:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a9d:	42                   	inc    %edx
  800a9e:	38 c8                	cmp    %cl,%al
  800aa0:	74 10                	je     800ab2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aa2:	0f b6 c0             	movzbl %al,%eax
  800aa5:	0f b6 c9             	movzbl %cl,%ecx
  800aa8:	29 c8                	sub    %ecx,%eax
  800aaa:	eb 16                	jmp    800ac2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aac:	4f                   	dec    %edi
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	39 fa                	cmp    %edi,%edx
  800ab4:	75 df                	jne    800a95 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 05                	jmp    800ac2 <memcmp+0x4a>
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad2:	39 d0                	cmp    %edx,%eax
  800ad4:	73 12                	jae    800ae8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad9:	38 08                	cmp    %cl,(%eax)
  800adb:	75 06                	jne    800ae3 <memfind+0x1c>
  800add:	eb 09                	jmp    800ae8 <memfind+0x21>
  800adf:	38 08                	cmp    %cl,(%eax)
  800ae1:	74 05                	je     800ae8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae3:	40                   	inc    %eax
  800ae4:	39 c2                	cmp    %eax,%edx
  800ae6:	77 f7                	ja     800adf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af6:	eb 01                	jmp    800af9 <strtol+0xf>
		s++;
  800af8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af9:	8a 02                	mov    (%edx),%al
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 f9                	je     800af8 <strtol+0xe>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	74 f5                	je     800af8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b03:	3c 2b                	cmp    $0x2b,%al
  800b05:	75 08                	jne    800b0f <strtol+0x25>
		s++;
  800b07:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b08:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0d:	eb 13                	jmp    800b22 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0f:	3c 2d                	cmp    $0x2d,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x33>
		s++, neg = 1;
  800b13:	8d 52 01             	lea    0x1(%edx),%edx
  800b16:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1b:	eb 05                	jmp    800b22 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	85 db                	test   %ebx,%ebx
  800b24:	74 05                	je     800b2b <strtol+0x41>
  800b26:	83 fb 10             	cmp    $0x10,%ebx
  800b29:	75 28                	jne    800b53 <strtol+0x69>
  800b2b:	8a 02                	mov    (%edx),%al
  800b2d:	3c 30                	cmp    $0x30,%al
  800b2f:	75 10                	jne    800b41 <strtol+0x57>
  800b31:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b35:	75 0a                	jne    800b41 <strtol+0x57>
		s += 2, base = 16;
  800b37:	83 c2 02             	add    $0x2,%edx
  800b3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3f:	eb 12                	jmp    800b53 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 0e                	jne    800b53 <strtol+0x69>
  800b45:	3c 30                	cmp    $0x30,%al
  800b47:	75 05                	jne    800b4e <strtol+0x64>
		s++, base = 8;
  800b49:	42                   	inc    %edx
  800b4a:	b3 08                	mov    $0x8,%bl
  800b4c:	eb 05                	jmp    800b53 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5a:	8a 0a                	mov    (%edx),%cl
  800b5c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5f:	80 fb 09             	cmp    $0x9,%bl
  800b62:	77 08                	ja     800b6c <strtol+0x82>
			dig = *s - '0';
  800b64:	0f be c9             	movsbl %cl,%ecx
  800b67:	83 e9 30             	sub    $0x30,%ecx
  800b6a:	eb 1e                	jmp    800b8a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b74:	0f be c9             	movsbl %cl,%ecx
  800b77:	83 e9 57             	sub    $0x57,%ecx
  800b7a:	eb 0e                	jmp    800b8a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7f:	80 fb 19             	cmp    $0x19,%bl
  800b82:	77 13                	ja     800b97 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b84:	0f be c9             	movsbl %cl,%ecx
  800b87:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8a:	39 f1                	cmp    %esi,%ecx
  800b8c:	7d 0d                	jge    800b9b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b8e:	42                   	inc    %edx
  800b8f:	0f af c6             	imul   %esi,%eax
  800b92:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b95:	eb c3                	jmp    800b5a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b97:	89 c1                	mov    %eax,%ecx
  800b99:	eb 02                	jmp    800b9d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba1:	74 05                	je     800ba8 <strtol+0xbe>
		*endptr = (char *) s;
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba8:	85 ff                	test   %edi,%edi
  800baa:	74 04                	je     800bb0 <strtol+0xc6>
  800bac:	89 c8                	mov    %ecx,%eax
  800bae:	f7 d8                	neg    %eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    
  800bb5:	00 00                	add    %al,(%eax)
	...

00800bb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	83 ec 10             	sub    $0x10,%esp
  800bc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bc6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bcc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bcf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	75 2e                	jne    800c04 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bd6:	39 f1                	cmp    %esi,%ecx
  800bd8:	77 5a                	ja     800c34 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bda:	85 c9                	test   %ecx,%ecx
  800bdc:	75 0b                	jne    800be9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bde:	b8 01 00 00 00       	mov    $0x1,%eax
  800be3:	31 d2                	xor    %edx,%edx
  800be5:	f7 f1                	div    %ecx
  800be7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800be9:	31 d2                	xor    %edx,%edx
  800beb:	89 f0                	mov    %esi,%eax
  800bed:	f7 f1                	div    %ecx
  800bef:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bf1:	89 f8                	mov    %edi,%eax
  800bf3:	f7 f1                	div    %ecx
  800bf5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bf7:	89 f8                	mov    %edi,%eax
  800bf9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    
  800c02:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c04:	39 f0                	cmp    %esi,%eax
  800c06:	77 1c                	ja     800c24 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c08:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c0b:	83 f7 1f             	xor    $0x1f,%edi
  800c0e:	75 3c                	jne    800c4c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	0f 82 90 00 00 00    	jb     800ca8 <__udivdi3+0xf0>
  800c18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c1b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c1e:	0f 86 84 00 00 00    	jbe    800ca8 <__udivdi3+0xf0>
  800c24:	31 f6                	xor    %esi,%esi
  800c26:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    
  800c33:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c34:	89 f2                	mov    %esi,%edx
  800c36:	89 f8                	mov    %edi,%eax
  800c38:	f7 f1                	div    %ecx
  800c3a:	89 c7                	mov    %eax,%edi
  800c3c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c3e:	89 f8                	mov    %edi,%eax
  800c40:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    
  800c49:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c4c:	89 f9                	mov    %edi,%ecx
  800c4e:	d3 e0                	shl    %cl,%eax
  800c50:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c53:	b8 20 00 00 00       	mov    $0x20,%eax
  800c58:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c5d:	88 c1                	mov    %al,%cl
  800c5f:	d3 ea                	shr    %cl,%edx
  800c61:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c64:	09 ca                	or     %ecx,%edx
  800c66:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c6c:	89 f9                	mov    %edi,%ecx
  800c6e:	d3 e2                	shl    %cl,%edx
  800c70:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c73:	89 f2                	mov    %esi,%edx
  800c75:	88 c1                	mov    %al,%cl
  800c77:	d3 ea                	shr    %cl,%edx
  800c79:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c7c:	89 f2                	mov    %esi,%edx
  800c7e:	89 f9                	mov    %edi,%ecx
  800c80:	d3 e2                	shl    %cl,%edx
  800c82:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c85:	88 c1                	mov    %al,%cl
  800c87:	d3 ee                	shr    %cl,%esi
  800c89:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c8b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c8e:	89 f0                	mov    %esi,%eax
  800c90:	89 ca                	mov    %ecx,%edx
  800c92:	f7 75 ec             	divl   -0x14(%ebp)
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c99:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c9c:	39 d1                	cmp    %edx,%ecx
  800c9e:	72 28                	jb     800cc8 <__udivdi3+0x110>
  800ca0:	74 1a                	je     800cbc <__udivdi3+0x104>
  800ca2:	89 f7                	mov    %esi,%edi
  800ca4:	31 f6                	xor    %esi,%esi
  800ca6:	eb 80                	jmp    800c28 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ca8:	31 f6                	xor    %esi,%esi
  800caa:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800caf:	89 f8                	mov    %edi,%eax
  800cb1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb3:	83 c4 10             	add    $0x10,%esp
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    
  800cba:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cbf:	89 f9                	mov    %edi,%ecx
  800cc1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cc3:	39 c2                	cmp    %eax,%edx
  800cc5:	73 db                	jae    800ca2 <__udivdi3+0xea>
  800cc7:	90                   	nop
		{
		  q0--;
  800cc8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ccb:	31 f6                	xor    %esi,%esi
  800ccd:	e9 56 ff ff ff       	jmp    800c28 <__udivdi3+0x70>
	...

00800cd4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	83 ec 20             	sub    $0x20,%esp
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ceb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cf1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf3:	85 ff                	test   %edi,%edi
  800cf5:	75 15                	jne    800d0c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cf7:	39 f1                	cmp    %esi,%ecx
  800cf9:	0f 86 99 00 00 00    	jbe    800d98 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cff:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d01:	89 d0                	mov    %edx,%eax
  800d03:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d05:	83 c4 20             	add    $0x20,%esp
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d0c:	39 f7                	cmp    %esi,%edi
  800d0e:	0f 87 a4 00 00 00    	ja     800db8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d14:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d17:	83 f0 1f             	xor    $0x1f,%eax
  800d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d1d:	0f 84 a1 00 00 00    	je     800dc4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d23:	89 f8                	mov    %edi,%eax
  800d25:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d28:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d2a:	bf 20 00 00 00       	mov    $0x20,%edi
  800d2f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d35:	89 f9                	mov    %edi,%ecx
  800d37:	d3 ea                	shr    %cl,%edx
  800d39:	09 c2                	or     %eax,%edx
  800d3b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d41:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d44:	d3 e0                	shl    %cl,%eax
  800d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d49:	89 f2                	mov    %esi,%edx
  800d4b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d50:	d3 e0                	shl    %cl,%eax
  800d52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d58:	89 f9                	mov    %edi,%ecx
  800d5a:	d3 e8                	shr    %cl,%eax
  800d5c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d5e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d60:	89 f2                	mov    %esi,%edx
  800d62:	f7 75 f0             	divl   -0x10(%ebp)
  800d65:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d67:	f7 65 f4             	mull   -0xc(%ebp)
  800d6a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d6d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d6f:	39 d6                	cmp    %edx,%esi
  800d71:	72 71                	jb     800de4 <__umoddi3+0x110>
  800d73:	74 7f                	je     800df4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d78:	29 c8                	sub    %ecx,%eax
  800d7a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d7c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d7f:	d3 e8                	shr    %cl,%eax
  800d81:	89 f2                	mov    %esi,%edx
  800d83:	89 f9                	mov    %edi,%ecx
  800d85:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d87:	09 d0                	or     %edx,%eax
  800d89:	89 f2                	mov    %esi,%edx
  800d8b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d8e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d90:	83 c4 20             	add    $0x20,%esp
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    
  800d97:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d98:	85 c9                	test   %ecx,%ecx
  800d9a:	75 0b                	jne    800da7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	f7 f1                	div    %ecx
  800da5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	31 d2                	xor    %edx,%edx
  800dab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db0:	f7 f1                	div    %ecx
  800db2:	e9 4a ff ff ff       	jmp    800d01 <__umoddi3+0x2d>
  800db7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800db8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dba:	83 c4 20             	add    $0x20,%esp
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    
  800dc1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc4:	39 f7                	cmp    %esi,%edi
  800dc6:	72 05                	jb     800dcd <__umoddi3+0xf9>
  800dc8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dcb:	77 0c                	ja     800dd9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd2:	29 c8                	sub    %ecx,%eax
  800dd4:	19 fa                	sbb    %edi,%edx
  800dd6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ddc:	83 c4 20             	add    $0x20,%esp
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    
  800de3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800de7:	89 c1                	mov    %eax,%ecx
  800de9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dec:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800def:	eb 84                	jmp    800d75 <__umoddi3+0xa1>
  800df1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800df4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800df7:	72 eb                	jb     800de4 <__umoddi3+0x110>
  800df9:	89 f2                	mov    %esi,%edx
  800dfb:	e9 75 ff ff ff       	jmp    800d75 <__umoddi3+0xa1>
