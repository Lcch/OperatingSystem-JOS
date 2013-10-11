
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
  80004b:	e8 34 01 00 00       	call   800184 <sys_getenvid>
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800058:	c1 e0 05             	shl    $0x5,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x30>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000
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
  800094:	e8 c9 00 00 00       	call   800162 <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 1c             	sub    $0x1c,%esp
  8000a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000af:	89 ca                	mov    %ecx,%edx
	assert(a5 == 0);
  8000b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000b5:	74 16                	je     8000cd <my_sysenter+0x2d>
  8000b7:	68 06 0e 80 00       	push   $0x800e06
  8000bc:	68 0e 0e 80 00       	push   $0x800e0e
  8000c1:	6a 0b                	push   $0xb
  8000c3:	68 23 0e 80 00       	push   $0x800e23
  8000c8:	e8 db 00 00 00       	call   8001a8 <_panic>
	int32_t ret;

	asm volatile(
  8000cd:	be 00 00 00 00       	mov    $0x0,%esi
  8000d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000de:	55                   	push   %ebp
  8000df:	54                   	push   %esp
  8000e0:	5d                   	pop    %ebp
  8000e1:	8d 35 e9 00 80 00    	lea    0x8000e9,%esi
  8000e7:	0f 34                	sysenter 

008000e9 <after_sysenter_label>:
  8000e9:	5d                   	pop    %ebp
  8000ea:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000f0:	74 1c                	je     80010e <after_sysenter_label+0x25>
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	7e 18                	jle    80010e <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  8000f6:	83 ec 0c             	sub    $0xc,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fd:	68 34 0e 80 00       	push   $0x800e34
  800102:	6a 20                	push   $0x20
  800104:	68 23 0e 80 00       	push   $0x800e23
  800109:	e8 9a 00 00 00       	call   8001a8 <_panic>

	return ret;
}
  80010e:	89 d0                	mov    %edx,%eax
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80011e:	6a 00                	push   $0x0
  800120:	6a 00                	push   $0x0
  800122:	6a 00                	push   $0x0
  800124:	ff 75 0c             	pushl  0xc(%ebp)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 00 00 00 00       	mov    $0x0,%eax
  800134:	e8 67 ff ff ff       	call   8000a0 <my_sysenter>
  800139:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <sys_cgetc>:

int
sys_cgetc(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800144:	6a 00                	push   $0x0
  800146:	6a 00                	push   $0x0
  800148:	6a 00                	push   $0x0
  80014a:	6a 00                	push   $0x0
  80014c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 01 00 00 00       	mov    $0x1,%eax
  80015b:	e8 40 ff ff ff       	call   8000a0 <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800168:	6a 00                	push   $0x0
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 00                	push   $0x0
  800170:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800173:	ba 01 00 00 00       	mov    $0x1,%edx
  800178:	b8 03 00 00 00       	mov    $0x3,%eax
  80017d:	e8 1e ff ff ff       	call   8000a0 <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80018a:	6a 00                	push   $0x0
  80018c:	6a 00                	push   $0x0
  80018e:	6a 00                	push   $0x0
  800190:	6a 00                	push   $0x0
  800192:	b9 00 00 00 00       	mov    $0x0,%ecx
  800197:	ba 00 00 00 00       	mov    $0x0,%edx
  80019c:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a1:	e8 fa fe ff ff       	call   8000a0 <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001b6:	e8 c9 ff ff ff       	call   800184 <sys_getenvid>
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	53                   	push   %ebx
  8001c5:	50                   	push   %eax
  8001c6:	68 58 0e 80 00       	push   $0x800e58
  8001cb:	e8 b0 00 00 00       	call   800280 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 53 00 00 00       	call   80022f <vcprintf>
	cprintf("\n");
  8001dc:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  8001e3:	e8 98 00 00 00       	call   800280 <cprintf>
  8001e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x43>
	...

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 04             	sub    $0x4,%esp
  8001f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fa:	8b 03                	mov    (%ebx),%eax
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800203:	40                   	inc    %eax
  800204:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020b:	75 1a                	jne    800227 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	68 ff 00 00 00       	push   $0xff
  800215:	8d 43 08             	lea    0x8(%ebx),%eax
  800218:	50                   	push   %eax
  800219:	e8 fa fe ff ff       	call   800118 <sys_cputs>
		b->idx = 0;
  80021e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800224:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800227:	ff 43 04             	incl   0x4(%ebx)
}
  80022a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023f:	00 00 00 
	b.cnt = 0;
  800242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	68 f0 01 80 00       	push   $0x8001f0
  80025e:	e8 82 01 00 00       	call   8003e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 a0 fe ff ff       	call   800118 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800286:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800289:	50                   	push   %eax
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 9d ff ff ff       	call   80022f <vcprintf>
	va_end(ap);

	return cnt;
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 2c             	sub    $0x2c,%esp
  80029d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a0:	89 d6                	mov    %edx,%esi
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c4:	72 0c                	jb     8002d2 <printnum+0x3e>
  8002c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002c9:	76 07                	jbe    8002d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cb:	4b                   	dec    %ebx
  8002cc:	85 db                	test   %ebx,%ebx
  8002ce:	7f 31                	jg     800301 <printnum+0x6d>
  8002d0:	eb 3f                	jmp    800311 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	57                   	push   %edi
  8002d6:	4b                   	dec    %ebx
  8002d7:	53                   	push   %ebx
  8002d8:	50                   	push   %eax
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002df:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e8:	e8 c7 08 00 00       	call   800bb4 <__udivdi3>
  8002ed:	83 c4 18             	add    $0x18,%esp
  8002f0:	52                   	push   %edx
  8002f1:	50                   	push   %eax
  8002f2:	89 f2                	mov    %esi,%edx
  8002f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f7:	e8 98 ff ff ff       	call   800294 <printnum>
  8002fc:	83 c4 20             	add    $0x20,%esp
  8002ff:	eb 10                	jmp    800311 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	83 ec 08             	sub    $0x8,%esp
  800304:	56                   	push   %esi
  800305:	57                   	push   %edi
  800306:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800309:	4b                   	dec    %ebx
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 db                	test   %ebx,%ebx
  80030f:	7f f0                	jg     800301 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	83 ec 04             	sub    $0x4,%esp
  800318:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031b:	ff 75 d0             	pushl  -0x30(%ebp)
  80031e:	ff 75 dc             	pushl  -0x24(%ebp)
  800321:	ff 75 d8             	pushl  -0x28(%ebp)
  800324:	e8 a7 09 00 00       	call   800cd0 <__umoddi3>
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	0f be 80 7e 0e 80 00 	movsbl 0x800e7e(%eax),%eax
  800333:	50                   	push   %eax
  800334:	ff 55 e4             	call   *-0x1c(%ebp)
  800337:	83 c4 10             	add    $0x10,%esp
}
  80033a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037f:	83 fa 01             	cmp    $0x1,%edx
  800382:	7e 0e                	jle    800392 <getint+0x16>
		return va_arg(*ap, long long);
  800384:	8b 10                	mov    (%eax),%edx
  800386:	8d 4a 08             	lea    0x8(%edx),%ecx
  800389:	89 08                	mov    %ecx,(%eax)
  80038b:	8b 02                	mov    (%edx),%eax
  80038d:	8b 52 04             	mov    0x4(%edx),%edx
  800390:	eb 1a                	jmp    8003ac <getint+0x30>
	else if (lflag)
  800392:	85 d2                	test   %edx,%edx
  800394:	74 0c                	je     8003a2 <getint+0x26>
		return va_arg(*ap, long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	99                   	cltd   
  8003a0:	eb 0a                	jmp    8003ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	99                   	cltd   
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 08                	jae    8003c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8003be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c1:	88 0a                	mov    %cl,(%edx)
  8003c3:	42                   	inc    %edx
  8003c4:	89 10                	mov    %edx,(%eax)
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d1:	50                   	push   %eax
  8003d2:	ff 75 10             	pushl  0x10(%ebp)
  8003d5:	ff 75 0c             	pushl  0xc(%ebp)
  8003d8:	ff 75 08             	pushl  0x8(%ebp)
  8003db:	e8 05 00 00 00       	call   8003e5 <vprintfmt>
	va_end(ap);
  8003e0:	83 c4 10             	add    $0x10,%esp
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 2c             	sub    $0x2c,%esp
  8003ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f4:	eb 13                	jmp    800409 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	0f 84 6d 03 00 00    	je     80076b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	57                   	push   %edi
  800402:	50                   	push   %eax
  800403:	ff 55 08             	call   *0x8(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	0f b6 06             	movzbl (%esi),%eax
  80040c:	46                   	inc    %esi
  80040d:	83 f8 25             	cmp    $0x25,%eax
  800410:	75 e4                	jne    8003f6 <vprintfmt+0x11>
  800412:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800416:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80041d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800424:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800430:	eb 28                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800434:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800438:	eb 20                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800440:	eb 18                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800444:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044b:	eb 0d                	jmp    80045a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80044d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800453:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8a 06                	mov    (%esi),%al
  80045c:	0f b6 d0             	movzbl %al,%edx
  80045f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800462:	83 e8 23             	sub    $0x23,%eax
  800465:	3c 55                	cmp    $0x55,%al
  800467:	0f 87 e0 02 00 00    	ja     80074d <vprintfmt+0x368>
  80046d:	0f b6 c0             	movzbl %al,%eax
  800470:	ff 24 85 08 0f 80 00 	jmp    *0x800f08(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800477:	83 ea 30             	sub    $0x30,%edx
  80047a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80047d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800480:	8d 50 d0             	lea    -0x30(%eax),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 44                	ja     8004cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	89 de                	mov    %ebx,%esi
  80048a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80048e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800491:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800495:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049b:	83 fb 09             	cmp    $0x9,%ebx
  80049e:	76 ed                	jbe    80048d <vprintfmt+0xa8>
  8004a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a3:	eb 29                	jmp    8004ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b5:	eb 17                	jmp    8004ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bb:	78 85                	js     800442 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	89 de                	mov    %ebx,%esi
  8004bf:	eb 99                	jmp    80045a <vprintfmt+0x75>
  8004c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ca:	eb 8e                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d2:	79 86                	jns    80045a <vprintfmt+0x75>
  8004d4:	e9 74 ff ff ff       	jmp    80044d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	e9 79 ff ff ff       	jmp    80045a <vprintfmt+0x75>
  8004e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	57                   	push   %edi
  8004f1:	ff 30                	pushl  (%eax)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004fc:	e9 08 ff ff ff       	jmp    800409 <vprintfmt+0x24>
  800501:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 02                	jns    800515 <vprintfmt+0x130>
  800513:	f7 d8                	neg    %eax
  800515:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 06             	cmp    $0x6,%eax
  80051a:	7f 0b                	jg     800527 <vprintfmt+0x142>
  80051c:	8b 04 85 60 10 80 00 	mov    0x801060(,%eax,4),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	75 1a                	jne    800541 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800527:	52                   	push   %edx
  800528:	68 96 0e 80 00       	push   $0x800e96
  80052d:	57                   	push   %edi
  80052e:	ff 75 08             	pushl  0x8(%ebp)
  800531:	e8 92 fe ff ff       	call   8003c8 <printfmt>
  800536:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053c:	e9 c8 fe ff ff       	jmp    800409 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800541:	50                   	push   %eax
  800542:	68 20 0e 80 00       	push   $0x800e20
  800547:	57                   	push   %edi
  800548:	ff 75 08             	pushl  0x8(%ebp)
  80054b:	e8 78 fe ff ff       	call   8003c8 <printfmt>
  800550:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800556:	e9 ae fe ff ff       	jmp    800409 <vprintfmt+0x24>
  80055b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80055e:	89 de                	mov    %ebx,%esi
  800560:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800574:	85 c0                	test   %eax,%eax
  800576:	75 07                	jne    80057f <vprintfmt+0x19a>
				p = "(null)";
  800578:	c7 45 d0 8f 0e 80 00 	movl   $0x800e8f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80057f:	85 db                	test   %ebx,%ebx
  800581:	7e 42                	jle    8005c5 <vprintfmt+0x1e0>
  800583:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800587:	74 3c                	je     8005c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	51                   	push   %ecx
  80058d:	ff 75 d0             	pushl  -0x30(%ebp)
  800590:	e8 6f 02 00 00       	call   800804 <strnlen>
  800595:	29 c3                	sub    %eax,%ebx
  800597:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7e 24                	jle    8005c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	53                   	push   %ebx
  8005b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	4e                   	dec    %esi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	7f f0                	jg     8005ab <vprintfmt+0x1c6>
  8005bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c8:	0f be 02             	movsbl (%edx),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 47                	jne    800616 <vprintfmt+0x231>
  8005cf:	eb 37                	jmp    800608 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d5:	74 16                	je     8005ed <vprintfmt+0x208>
  8005d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005da:	83 fa 5e             	cmp    $0x5e,%edx
  8005dd:	76 0e                	jbe    8005ed <vprintfmt+0x208>
					putch('?', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	57                   	push   %edi
  8005e3:	6a 3f                	push   $0x3f
  8005e5:	ff 55 08             	call   *0x8(%ebp)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 0b                	jmp    8005f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	50                   	push   %eax
  8005f2:	ff 55 08             	call   *0x8(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005fb:	0f be 03             	movsbl (%ebx),%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	74 03                	je     800605 <vprintfmt+0x220>
  800602:	43                   	inc    %ebx
  800603:	eb 1b                	jmp    800620 <vprintfmt+0x23b>
  800605:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800608:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060c:	7f 1e                	jg     80062c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800611:	e9 f3 fd ff ff       	jmp    800409 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800619:	43                   	inc    %ebx
  80061a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80061d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800620:	85 f6                	test   %esi,%esi
  800622:	78 ad                	js     8005d1 <vprintfmt+0x1ec>
  800624:	4e                   	dec    %esi
  800625:	79 aa                	jns    8005d1 <vprintfmt+0x1ec>
  800627:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80062a:	eb dc                	jmp    800608 <vprintfmt+0x223>
  80062c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	57                   	push   %edi
  800633:	6a 20                	push   $0x20
  800635:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800638:	4b                   	dec    %ebx
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	85 db                	test   %ebx,%ebx
  80063e:	7f ef                	jg     80062f <vprintfmt+0x24a>
  800640:	e9 c4 fd ff ff       	jmp    800409 <vprintfmt+0x24>
  800645:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800648:	89 ca                	mov    %ecx,%edx
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 2a fd ff ff       	call   80037c <getint>
  800652:	89 c3                	mov    %eax,%ebx
  800654:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800656:	85 d2                	test   %edx,%edx
  800658:	78 0a                	js     800664 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 b0 00 00 00       	jmp    800714 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	57                   	push   %edi
  800668:	6a 2d                	push   $0x2d
  80066a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066d:	f7 db                	neg    %ebx
  80066f:	83 d6 00             	adc    $0x0,%esi
  800672:	f7 de                	neg    %esi
  800674:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 93 00 00 00       	jmp    800714 <vprintfmt+0x32f>
  800681:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 b4 fc ff ff       	call   800342 <getuint>
  80068e:	89 c3                	mov    %eax,%ebx
  800690:	89 d6                	mov    %edx,%esi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 7b                	jmp    800714 <vprintfmt+0x32f>
  800699:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80069c:	89 ca                	mov    %ecx,%edx
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 d6 fc ff ff       	call   80037c <getint>
  8006a6:	89 c3                	mov    %eax,%ebx
  8006a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	78 07                	js     8006b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b3:	eb 5f                	jmp    800714 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	57                   	push   %edi
  8006b9:	6a 2d                	push   $0x2d
  8006bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006be:	f7 db                	neg    %ebx
  8006c0:	83 d6 00             	adc    $0x0,%esi
  8006c3:	f7 de                	neg    %esi
  8006c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006cd:	eb 45                	jmp    800714 <vprintfmt+0x32f>
  8006cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	57                   	push   %edi
  8006d6:	6a 30                	push   $0x30
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006db:	83 c4 08             	add    $0x8,%esp
  8006de:	57                   	push   %edi
  8006df:	6a 78                	push   $0x78
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ed:	8b 18                	mov    (%eax),%ebx
  8006ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006fc:	eb 16                	jmp    800714 <vprintfmt+0x32f>
  8006fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800701:	89 ca                	mov    %ecx,%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 37 fc ff ff       	call   800342 <getuint>
  80070b:	89 c3                	mov    %eax,%ebx
  80070d:	89 d6                	mov    %edx,%esi
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071b:	52                   	push   %edx
  80071c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071f:	50                   	push   %eax
  800720:	56                   	push   %esi
  800721:	53                   	push   %ebx
  800722:	89 fa                	mov    %edi,%edx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	e8 68 fb ff ff       	call   800294 <printnum>
			break;
  80072c:	83 c4 20             	add    $0x20,%esp
  80072f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800732:	e9 d2 fc ff ff       	jmp    800409 <vprintfmt+0x24>
  800737:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	57                   	push   %edi
  80073e:	52                   	push   %edx
  80073f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 bc fc ff ff       	jmp    800409 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	57                   	push   %edi
  800751:	6a 25                	push   $0x25
  800753:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 02                	jmp    80075d <vprintfmt+0x378>
  80075b:	89 c6                	mov    %eax,%esi
  80075d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800760:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800764:	75 f5                	jne    80075b <vprintfmt+0x376>
  800766:	e9 9e fc ff ff       	jmp    800409 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	83 ec 18             	sub    $0x18,%esp
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800782:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800786:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800789:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800790:	85 c0                	test   %eax,%eax
  800792:	74 26                	je     8007ba <vsnprintf+0x47>
  800794:	85 d2                	test   %edx,%edx
  800796:	7e 29                	jle    8007c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800798:	ff 75 14             	pushl  0x14(%ebp)
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	68 ae 03 80 00       	push   $0x8003ae
  8007a7:	e8 39 fc ff ff       	call   8003e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 0c                	jmp    8007c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bf:	eb 05                	jmp    8007c6 <vsnprintf+0x53>
  8007c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 93 ff ff ff       	call   800773 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    
	...

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ed:	74 0e                	je     8007fd <strlen+0x19>
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f9:	75 f9                	jne    8007f4 <strlen+0x10>
  8007fb:	eb 05                	jmp    800802 <strlen+0x1e>
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 17                	je     800828 <strnlen+0x24>
  800811:	80 39 00             	cmpb   $0x0,(%ecx)
  800814:	74 19                	je     80082f <strnlen+0x2b>
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80081b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 d0                	cmp    %edx,%eax
  80081e:	74 14                	je     800834 <strnlen+0x30>
  800820:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800824:	75 f5                	jne    80081b <strnlen+0x17>
  800826:	eb 0c                	jmp    800834 <strnlen+0x30>
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	eb 05                	jmp    800834 <strnlen+0x30>
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	ba 00 00 00 00       	mov    $0x0,%edx
  800845:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800848:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80084b:	42                   	inc    %edx
  80084c:	84 c9                	test   %cl,%cl
  80084e:	75 f5                	jne    800845 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800850:	5b                   	pop    %ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085a:	53                   	push   %ebx
  80085b:	e8 84 ff ff ff       	call   8007e4 <strlen>
  800860:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800863:	ff 75 0c             	pushl  0xc(%ebp)
  800866:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800869:	50                   	push   %eax
  80086a:	e8 c7 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800884:	85 f6                	test   %esi,%esi
  800886:	74 15                	je     80089d <strncpy+0x27>
  800888:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80088d:	8a 1a                	mov    (%edx),%bl
  80088f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800892:	80 3a 01             	cmpb   $0x1,(%edx)
  800895:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800898:	41                   	inc    %ecx
  800899:	39 ce                	cmp    %ecx,%esi
  80089b:	77 f0                	ja     80088d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b0:	85 f6                	test   %esi,%esi
  8008b2:	74 32                	je     8008e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b4:	83 fe 01             	cmp    $0x1,%esi
  8008b7:	74 22                	je     8008db <strlcpy+0x3a>
  8008b9:	8a 0b                	mov    (%ebx),%cl
  8008bb:	84 c9                	test   %cl,%cl
  8008bd:	74 20                	je     8008df <strlcpy+0x3e>
  8008bf:	89 f8                	mov    %edi,%eax
  8008c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c9:	88 08                	mov    %cl,(%eax)
  8008cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cc:	39 f2                	cmp    %esi,%edx
  8008ce:	74 11                	je     8008e1 <strlcpy+0x40>
  8008d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d4:	42                   	inc    %edx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	75 f0                	jne    8008c9 <strlcpy+0x28>
  8008d9:	eb 06                	jmp    8008e1 <strlcpy+0x40>
  8008db:	89 f8                	mov    %edi,%eax
  8008dd:	eb 02                	jmp    8008e1 <strlcpy+0x40>
  8008df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e1:	c6 00 00             	movb   $0x0,(%eax)
  8008e4:	eb 02                	jmp    8008e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008e8:	29 f8                	sub    %edi,%eax
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f8:	8a 01                	mov    (%ecx),%al
  8008fa:	84 c0                	test   %al,%al
  8008fc:	74 10                	je     80090e <strcmp+0x1f>
  8008fe:	3a 02                	cmp    (%edx),%al
  800900:	75 0c                	jne    80090e <strcmp+0x1f>
		p++, q++;
  800902:	41                   	inc    %ecx
  800903:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800904:	8a 01                	mov    (%ecx),%al
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strcmp+0x1f>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	74 f4                	je     800902 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	0f b6 c0             	movzbl %al,%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 55 08             	mov    0x8(%ebp),%edx
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800922:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 1b                	je     800944 <strncmp+0x2c>
  800929:	8a 1a                	mov    (%edx),%bl
  80092b:	84 db                	test   %bl,%bl
  80092d:	74 24                	je     800953 <strncmp+0x3b>
  80092f:	3a 19                	cmp    (%ecx),%bl
  800931:	75 20                	jne    800953 <strncmp+0x3b>
  800933:	48                   	dec    %eax
  800934:	74 15                	je     80094b <strncmp+0x33>
		n--, p++, q++;
  800936:	42                   	inc    %edx
  800937:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800938:	8a 1a                	mov    (%edx),%bl
  80093a:	84 db                	test   %bl,%bl
  80093c:	74 15                	je     800953 <strncmp+0x3b>
  80093e:	3a 19                	cmp    (%ecx),%bl
  800940:	74 f1                	je     800933 <strncmp+0x1b>
  800942:	eb 0f                	jmp    800953 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	eb 05                	jmp    800950 <strncmp+0x38>
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800950:	5b                   	pop    %ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 02             	movzbl (%edx),%eax
  800956:	0f b6 11             	movzbl (%ecx),%edx
  800959:	29 d0                	sub    %edx,%eax
  80095b:	eb f3                	jmp    800950 <strncmp+0x38>

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800966:	8a 10                	mov    (%eax),%dl
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strchr+0x27>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 06                	jne    800976 <strchr+0x19>
  800970:	eb 17                	jmp    800989 <strchr+0x2c>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 13                	je     800989 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800976:	40                   	inc    %eax
  800977:	8a 10                	mov    (%eax),%dl
  800979:	84 d2                	test   %dl,%dl
  80097b:	75 f5                	jne    800972 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb 05                	jmp    800989 <strchr+0x2c>
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800994:	8a 10                	mov    (%eax),%dl
  800996:	84 d2                	test   %dl,%dl
  800998:	74 11                	je     8009ab <strfind+0x20>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	75 06                	jne    8009a4 <strfind+0x19>
  80099e:	eb 0b                	jmp    8009ab <strfind+0x20>
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 07                	je     8009ab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	40                   	inc    %eax
  8009a5:	8a 10                	mov    (%eax),%dl
  8009a7:	84 d2                	test   %dl,%dl
  8009a9:	75 f5                	jne    8009a0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 30                	je     8009f0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c6:	75 25                	jne    8009ed <memset+0x40>
  8009c8:	f6 c1 03             	test   $0x3,%cl
  8009cb:	75 20                	jne    8009ed <memset+0x40>
		c &= 0xFF;
  8009cd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d0:	89 d3                	mov    %edx,%ebx
  8009d2:	c1 e3 08             	shl    $0x8,%ebx
  8009d5:	89 d6                	mov    %edx,%esi
  8009d7:	c1 e6 18             	shl    $0x18,%esi
  8009da:	89 d0                	mov    %edx,%eax
  8009dc:	c1 e0 10             	shl    $0x10,%eax
  8009df:	09 f0                	or     %esi,%eax
  8009e1:	09 d0                	or     %edx,%eax
  8009e3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e8:	fc                   	cld    
  8009e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009eb:	eb 03                	jmp    8009f0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ed:	fc                   	cld    
  8009ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f0:	89 f8                	mov    %edi,%eax
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a05:	39 c6                	cmp    %eax,%esi
  800a07:	73 34                	jae    800a3d <memmove+0x46>
  800a09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0c:	39 d0                	cmp    %edx,%eax
  800a0e:	73 2d                	jae    800a3d <memmove+0x46>
		s += n;
		d += n;
  800a10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 1b                	jne    800a33 <memmove+0x3c>
  800a18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1e:	75 13                	jne    800a33 <memmove+0x3c>
  800a20:	f6 c1 03             	test   $0x3,%cl
  800a23:	75 0e                	jne    800a33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a25:	83 ef 04             	sub    $0x4,%edi
  800a28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2e:	fd                   	std    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 07                	jmp    800a3a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a33:	4f                   	dec    %edi
  800a34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a37:	fd                   	std    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3a:	fc                   	cld    
  800a3b:	eb 20                	jmp    800a5d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 13                	jne    800a58 <memmove+0x61>
  800a45:	a8 03                	test   $0x3,%al
  800a47:	75 0f                	jne    800a58 <memmove+0x61>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 0a                	jne    800a58 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 05                	jmp    800a5d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	ff 75 08             	pushl  0x8(%ebp)
  800a6d:	e8 85 ff ff ff       	call   8009f7 <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a80:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a83:	85 ff                	test   %edi,%edi
  800a85:	74 32                	je     800ab9 <memcmp+0x45>
		if (*s1 != *s2)
  800a87:	8a 03                	mov    (%ebx),%al
  800a89:	8a 0e                	mov    (%esi),%cl
  800a8b:	38 c8                	cmp    %cl,%al
  800a8d:	74 19                	je     800aa8 <memcmp+0x34>
  800a8f:	eb 0d                	jmp    800a9e <memcmp+0x2a>
  800a91:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a95:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a99:	42                   	inc    %edx
  800a9a:	38 c8                	cmp    %cl,%al
  800a9c:	74 10                	je     800aae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c0             	movzbl %al,%eax
  800aa1:	0f b6 c9             	movzbl %cl,%ecx
  800aa4:	29 c8                	sub    %ecx,%eax
  800aa6:	eb 16                	jmp    800abe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	4f                   	dec    %edi
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	39 fa                	cmp    %edi,%edx
  800ab0:	75 df                	jne    800a91 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	eb 05                	jmp    800abe <memcmp+0x4a>
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	73 12                	jae    800ae4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad5:	38 08                	cmp    %cl,(%eax)
  800ad7:	75 06                	jne    800adf <memfind+0x1c>
  800ad9:	eb 09                	jmp    800ae4 <memfind+0x21>
  800adb:	38 08                	cmp    %cl,(%eax)
  800add:	74 05                	je     800ae4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adf:	40                   	inc    %eax
  800ae0:	39 c2                	cmp    %eax,%edx
  800ae2:	77 f7                	ja     800adb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af2:	eb 01                	jmp    800af5 <strtol+0xf>
		s++;
  800af4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	3c 20                	cmp    $0x20,%al
  800af9:	74 f9                	je     800af4 <strtol+0xe>
  800afb:	3c 09                	cmp    $0x9,%al
  800afd:	74 f5                	je     800af4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aff:	3c 2b                	cmp    $0x2b,%al
  800b01:	75 08                	jne    800b0b <strtol+0x25>
		s++;
  800b03:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	eb 13                	jmp    800b1e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0b:	3c 2d                	cmp    $0x2d,%al
  800b0d:	75 0a                	jne    800b19 <strtol+0x33>
		s++, neg = 1;
  800b0f:	8d 52 01             	lea    0x1(%edx),%edx
  800b12:	bf 01 00 00 00       	mov    $0x1,%edi
  800b17:	eb 05                	jmp    800b1e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	74 05                	je     800b27 <strtol+0x41>
  800b22:	83 fb 10             	cmp    $0x10,%ebx
  800b25:	75 28                	jne    800b4f <strtol+0x69>
  800b27:	8a 02                	mov    (%edx),%al
  800b29:	3c 30                	cmp    $0x30,%al
  800b2b:	75 10                	jne    800b3d <strtol+0x57>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x57>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3b:	eb 12                	jmp    800b4f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	75 0e                	jne    800b4f <strtol+0x69>
  800b41:	3c 30                	cmp    $0x30,%al
  800b43:	75 05                	jne    800b4a <strtol+0x64>
		s++, base = 8;
  800b45:	42                   	inc    %edx
  800b46:	b3 08                	mov    $0x8,%bl
  800b48:	eb 05                	jmp    800b4f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b56:	8a 0a                	mov    (%edx),%cl
  800b58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5b:	80 fb 09             	cmp    $0x9,%bl
  800b5e:	77 08                	ja     800b68 <strtol+0x82>
			dig = *s - '0';
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 30             	sub    $0x30,%ecx
  800b66:	eb 1e                	jmp    800b86 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b70:	0f be c9             	movsbl %cl,%ecx
  800b73:	83 e9 57             	sub    $0x57,%ecx
  800b76:	eb 0e                	jmp    800b86 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 13                	ja     800b93 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b80:	0f be c9             	movsbl %cl,%ecx
  800b83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b86:	39 f1                	cmp    %esi,%ecx
  800b88:	7d 0d                	jge    800b97 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b8a:	42                   	inc    %edx
  800b8b:	0f af c6             	imul   %esi,%eax
  800b8e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b91:	eb c3                	jmp    800b56 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b93:	89 c1                	mov    %eax,%ecx
  800b95:	eb 02                	jmp    800b99 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b97:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9d:	74 05                	je     800ba4 <strtol+0xbe>
		*endptr = (char *) s;
  800b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba4:	85 ff                	test   %edi,%edi
  800ba6:	74 04                	je     800bac <strtol+0xc6>
  800ba8:	89 c8                	mov    %ecx,%eax
  800baa:	f7 d8                	neg    %eax
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    
  800bb1:	00 00                	add    %al,(%eax)
	...

00800bb4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	83 ec 10             	sub    $0x10,%esp
  800bbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bc2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bcb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	75 2e                	jne    800c00 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bd2:	39 f1                	cmp    %esi,%ecx
  800bd4:	77 5a                	ja     800c30 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bd6:	85 c9                	test   %ecx,%ecx
  800bd8:	75 0b                	jne    800be5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bda:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdf:	31 d2                	xor    %edx,%edx
  800be1:	f7 f1                	div    %ecx
  800be3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800be5:	31 d2                	xor    %edx,%edx
  800be7:	89 f0                	mov    %esi,%eax
  800be9:	f7 f1                	div    %ecx
  800beb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	f7 f1                	div    %ecx
  800bf1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bf3:	89 f8                	mov    %edi,%eax
  800bf5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bf7:	83 c4 10             	add    $0x10,%esp
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    
  800bfe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c00:	39 f0                	cmp    %esi,%eax
  800c02:	77 1c                	ja     800c20 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c04:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c07:	83 f7 1f             	xor    $0x1f,%edi
  800c0a:	75 3c                	jne    800c48 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c0c:	39 f0                	cmp    %esi,%eax
  800c0e:	0f 82 90 00 00 00    	jb     800ca4 <__udivdi3+0xf0>
  800c14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c17:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c1a:	0f 86 84 00 00 00    	jbe    800ca4 <__udivdi3+0xf0>
  800c20:	31 f6                	xor    %esi,%esi
  800c22:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    
  800c2f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c30:	89 f2                	mov    %esi,%edx
  800c32:	89 f8                	mov    %edi,%eax
  800c34:	f7 f1                	div    %ecx
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c3a:	89 f8                	mov    %edi,%eax
  800c3c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c48:	89 f9                	mov    %edi,%ecx
  800c4a:	d3 e0                	shl    %cl,%eax
  800c4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c4f:	b8 20 00 00 00       	mov    $0x20,%eax
  800c54:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c59:	88 c1                	mov    %al,%cl
  800c5b:	d3 ea                	shr    %cl,%edx
  800c5d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c60:	09 ca                	or     %ecx,%edx
  800c62:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c68:	89 f9                	mov    %edi,%ecx
  800c6a:	d3 e2                	shl    %cl,%edx
  800c6c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c6f:	89 f2                	mov    %esi,%edx
  800c71:	88 c1                	mov    %al,%cl
  800c73:	d3 ea                	shr    %cl,%edx
  800c75:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c78:	89 f2                	mov    %esi,%edx
  800c7a:	89 f9                	mov    %edi,%ecx
  800c7c:	d3 e2                	shl    %cl,%edx
  800c7e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c81:	88 c1                	mov    %al,%cl
  800c83:	d3 ee                	shr    %cl,%esi
  800c85:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c87:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	89 ca                	mov    %ecx,%edx
  800c8e:	f7 75 ec             	divl   -0x14(%ebp)
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c95:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c98:	39 d1                	cmp    %edx,%ecx
  800c9a:	72 28                	jb     800cc4 <__udivdi3+0x110>
  800c9c:	74 1a                	je     800cb8 <__udivdi3+0x104>
  800c9e:	89 f7                	mov    %esi,%edi
  800ca0:	31 f6                	xor    %esi,%esi
  800ca2:	eb 80                	jmp    800c24 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ca4:	31 f6                	xor    %esi,%esi
  800ca6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cab:	89 f8                	mov    %edi,%eax
  800cad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800caf:	83 c4 10             	add    $0x10,%esp
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    
  800cb6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cbf:	39 c2                	cmp    %eax,%edx
  800cc1:	73 db                	jae    800c9e <__udivdi3+0xea>
  800cc3:	90                   	nop
		{
		  q0--;
  800cc4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cc7:	31 f6                	xor    %esi,%esi
  800cc9:	e9 56 ff ff ff       	jmp    800c24 <__udivdi3+0x70>
	...

00800cd0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	83 ec 20             	sub    $0x20,%esp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cde:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ce1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ce4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ced:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cef:	85 ff                	test   %edi,%edi
  800cf1:	75 15                	jne    800d08 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cf3:	39 f1                	cmp    %esi,%ecx
  800cf5:	0f 86 99 00 00 00    	jbe    800d94 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cfb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cfd:	89 d0                	mov    %edx,%eax
  800cff:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d01:	83 c4 20             	add    $0x20,%esp
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d08:	39 f7                	cmp    %esi,%edi
  800d0a:	0f 87 a4 00 00 00    	ja     800db4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d10:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d13:	83 f0 1f             	xor    $0x1f,%eax
  800d16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d19:	0f 84 a1 00 00 00    	je     800dc0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d24:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d26:	bf 20 00 00 00       	mov    $0x20,%edi
  800d2b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	d3 ea                	shr    %cl,%edx
  800d35:	09 c2                	or     %eax,%edx
  800d37:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d40:	d3 e0                	shl    %cl,%eax
  800d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d45:	89 f2                	mov    %esi,%edx
  800d47:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d4c:	d3 e0                	shl    %cl,%eax
  800d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d51:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d54:	89 f9                	mov    %edi,%ecx
  800d56:	d3 e8                	shr    %cl,%eax
  800d58:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d5a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d5c:	89 f2                	mov    %esi,%edx
  800d5e:	f7 75 f0             	divl   -0x10(%ebp)
  800d61:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d63:	f7 65 f4             	mull   -0xc(%ebp)
  800d66:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d69:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d6b:	39 d6                	cmp    %edx,%esi
  800d6d:	72 71                	jb     800de0 <__umoddi3+0x110>
  800d6f:	74 7f                	je     800df0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d74:	29 c8                	sub    %ecx,%eax
  800d76:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d78:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d7b:	d3 e8                	shr    %cl,%eax
  800d7d:	89 f2                	mov    %esi,%edx
  800d7f:	89 f9                	mov    %edi,%ecx
  800d81:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d83:	09 d0                	or     %edx,%eax
  800d85:	89 f2                	mov    %esi,%edx
  800d87:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d8a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d8c:	83 c4 20             	add    $0x20,%esp
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    
  800d93:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d94:	85 c9                	test   %ecx,%ecx
  800d96:	75 0b                	jne    800da3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d98:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	f7 f1                	div    %ecx
  800da1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dac:	f7 f1                	div    %ecx
  800dae:	e9 4a ff ff ff       	jmp    800cfd <__umoddi3+0x2d>
  800db3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800db4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800db6:	83 c4 20             	add    $0x20,%esp
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	c9                   	leave  
  800dbc:	c3                   	ret    
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc0:	39 f7                	cmp    %esi,%edi
  800dc2:	72 05                	jb     800dc9 <__umoddi3+0xf9>
  800dc4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dc7:	77 0c                	ja     800dd5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc9:	89 f2                	mov    %esi,%edx
  800dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dce:	29 c8                	sub    %ecx,%eax
  800dd0:	19 fa                	sbb    %edi,%edx
  800dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dd8:	83 c4 20             	add    $0x20,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	c9                   	leave  
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800de8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800deb:	eb 84                	jmp    800d71 <__umoddi3+0xa1>
  800ded:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800df0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800df3:	72 eb                	jb     800de0 <__umoddi3+0x110>
  800df5:	89 f2                	mov    %esi,%edx
  800df7:	e9 75 ff ff ff       	jmp    800d71 <__umoddi3+0xa1>
