
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
  800045:	e8 de 00 00 00       	call   800128 <sys_cputs>
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
  80005b:	e8 34 01 00 00       	call   800194 <sys_getenvid>
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
  8000a4:	e8 c9 00 00 00       	call   800172 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
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
	assert(a5 == 0);
  8000c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000c5:	74 16                	je     8000dd <my_sysenter+0x2d>
  8000c7:	68 24 0e 80 00       	push   $0x800e24
  8000cc:	68 2c 0e 80 00       	push   $0x800e2c
  8000d1:	6a 0b                	push   $0xb
  8000d3:	68 41 0e 80 00       	push   $0x800e41
  8000d8:	e8 db 00 00 00       	call   8001b8 <_panic>
	int32_t ret;

	asm volatile(
  8000dd:	be 00 00 00 00       	mov    $0x0,%esi
  8000e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ee:	55                   	push   %ebp
  8000ef:	54                   	push   %esp
  8000f0:	5d                   	pop    %ebp
  8000f1:	8d 35 f9 00 80 00    	lea    0x8000f9,%esi
  8000f7:	0f 34                	sysenter 

008000f9 <after_sysenter_label>:
  8000f9:	5d                   	pop    %ebp
  8000fa:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800100:	74 1c                	je     80011e <after_sysenter_label+0x25>
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 18                	jle    80011e <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80010d:	68 50 0e 80 00       	push   $0x800e50
  800112:	6a 20                	push   $0x20
  800114:	68 41 0e 80 00       	push   $0x800e41
  800119:	e8 9a 00 00 00       	call   8001b8 <_panic>

	return ret;
}
  80011e:	89 d0                	mov    %edx,%eax
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80012e:	6a 00                	push   $0x0
  800130:	6a 00                	push   $0x0
  800132:	6a 00                	push   $0x0
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	e8 67 ff ff ff       	call   8000b0 <my_sysenter>
  800149:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <sys_cgetc>:

int
sys_cgetc(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	6a 00                	push   $0x0
  80015c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 01 00 00 00       	mov    $0x1,%eax
  80016b:	e8 40 ff ff ff       	call   8000b0 <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800178:	6a 00                	push   $0x0
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800183:	ba 01 00 00 00       	mov    $0x1,%edx
  800188:	b8 03 00 00 00       	mov    $0x3,%eax
  80018d:	e8 1e ff ff ff       	call   8000b0 <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80019a:	6a 00                	push   $0x0
  80019c:	6a 00                	push   $0x0
  80019e:	6a 00                	push   $0x0
  8001a0:	6a 00                	push   $0x0
  8001a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b1:	e8 fa fe ff ff       	call   8000b0 <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001bd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c0:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8001c6:	e8 c9 ff ff ff       	call   800194 <sys_getenvid>
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	ff 75 0c             	pushl  0xc(%ebp)
  8001d1:	ff 75 08             	pushl  0x8(%ebp)
  8001d4:	53                   	push   %ebx
  8001d5:	50                   	push   %eax
  8001d6:	68 74 0e 80 00       	push   $0x800e74
  8001db:	e8 b0 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e0:	83 c4 18             	add    $0x18,%esp
  8001e3:	56                   	push   %esi
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	e8 53 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001ec:	c7 04 24 18 0e 80 00 	movl   $0x800e18,(%esp)
  8001f3:	e8 98 00 00 00       	call   800290 <cprintf>
  8001f8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fb:	cc                   	int3   
  8001fc:	eb fd                	jmp    8001fb <_panic+0x43>
	...

00800200 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	53                   	push   %ebx
  800204:	83 ec 04             	sub    $0x4,%esp
  800207:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020a:	8b 03                	mov    (%ebx),%eax
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800213:	40                   	inc    %eax
  800214:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800216:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021b:	75 1a                	jne    800237 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	68 ff 00 00 00       	push   $0xff
  800225:	8d 43 08             	lea    0x8(%ebx),%eax
  800228:	50                   	push   %eax
  800229:	e8 fa fe ff ff       	call   800128 <sys_cputs>
		b->idx = 0;
  80022e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800234:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800237:	ff 43 04             	incl   0x4(%ebx)
}
  80023a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800248:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024f:	00 00 00 
	b.cnt = 0;
  800252:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800259:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	68 00 02 80 00       	push   $0x800200
  80026e:	e8 82 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 a0 fe ff ff       	call   800128 <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 9d ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 2c             	sub    $0x2c,%esp
  8002ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002be:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002d1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002d4:	72 0c                	jb     8002e2 <printnum+0x3e>
  8002d6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002d9:	76 07                	jbe    8002e2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002db:	4b                   	dec    %ebx
  8002dc:	85 db                	test   %ebx,%ebx
  8002de:	7f 31                	jg     800311 <printnum+0x6d>
  8002e0:	eb 3f                	jmp    800321 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	57                   	push   %edi
  8002e6:	4b                   	dec    %ebx
  8002e7:	53                   	push   %ebx
  8002e8:	50                   	push   %eax
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f8:	e8 c7 08 00 00       	call   800bc4 <__udivdi3>
  8002fd:	83 c4 18             	add    $0x18,%esp
  800300:	52                   	push   %edx
  800301:	50                   	push   %eax
  800302:	89 f2                	mov    %esi,%edx
  800304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800307:	e8 98 ff ff ff       	call   8002a4 <printnum>
  80030c:	83 c4 20             	add    $0x20,%esp
  80030f:	eb 10                	jmp    800321 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	57                   	push   %edi
  800316:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800319:	4b                   	dec    %ebx
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	7f f0                	jg     800311 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	56                   	push   %esi
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 d4             	pushl  -0x2c(%ebp)
  80032b:	ff 75 d0             	pushl  -0x30(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 a7 09 00 00       	call   800ce0 <__umoddi3>
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	0f be 80 98 0e 80 00 	movsbl 0x800e98(%eax),%eax
  800343:	50                   	push   %eax
  800344:	ff 55 e4             	call   *-0x1c(%ebp)
  800347:	83 c4 10             	add    $0x10,%esp
}
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800355:	83 fa 01             	cmp    $0x1,%edx
  800358:	7e 0e                	jle    800368 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	eb 22                	jmp    80038a <getuint+0x38>
	else if (lflag)
  800368:	85 d2                	test   %edx,%edx
  80036a:	74 10                	je     80037c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
  80037a:	eb 0e                	jmp    80038a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038f:	83 fa 01             	cmp    $0x1,%edx
  800392:	7e 0e                	jle    8003a2 <getint+0x16>
		return va_arg(*ap, long long);
  800394:	8b 10                	mov    (%eax),%edx
  800396:	8d 4a 08             	lea    0x8(%edx),%ecx
  800399:	89 08                	mov    %ecx,(%eax)
  80039b:	8b 02                	mov    (%edx),%eax
  80039d:	8b 52 04             	mov    0x4(%edx),%edx
  8003a0:	eb 1a                	jmp    8003bc <getint+0x30>
	else if (lflag)
  8003a2:	85 d2                	test   %edx,%edx
  8003a4:	74 0c                	je     8003b2 <getint+0x26>
		return va_arg(*ap, long);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	99                   	cltd   
  8003b0:	eb 0a                	jmp    8003bc <getint+0x30>
	else
		return va_arg(*ap, int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	99                   	cltd   
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c7:	8b 10                	mov    (%eax),%edx
  8003c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003cc:	73 08                	jae    8003d6 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d1:	88 0a                	mov    %cl,(%edx)
  8003d3:	42                   	inc    %edx
  8003d4:	89 10                	mov    %edx,(%eax)
}
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
  8003f0:	83 c4 10             	add    $0x10,%esp
}
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800401:	8b 75 10             	mov    0x10(%ebp),%esi
  800404:	eb 13                	jmp    800419 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800406:	85 c0                	test   %eax,%eax
  800408:	0f 84 6d 03 00 00    	je     80077b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	57                   	push   %edi
  800412:	50                   	push   %eax
  800413:	ff 55 08             	call   *0x8(%ebp)
  800416:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	0f b6 06             	movzbl (%esi),%eax
  80041c:	46                   	inc    %esi
  80041d:	83 f8 25             	cmp    $0x25,%eax
  800420:	75 e4                	jne    800406 <vprintfmt+0x11>
  800422:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800426:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80042d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800434:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80043b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800440:	eb 28                	jmp    80046a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800444:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800448:	eb 20                	jmp    80046a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800450:	eb 18                	jmp    80046a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800454:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80045b:	eb 0d                	jmp    80046a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80045d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8a 06                	mov    (%esi),%al
  80046c:	0f b6 d0             	movzbl %al,%edx
  80046f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800472:	83 e8 23             	sub    $0x23,%eax
  800475:	3c 55                	cmp    $0x55,%al
  800477:	0f 87 e0 02 00 00    	ja     80075d <vprintfmt+0x368>
  80047d:	0f b6 c0             	movzbl %al,%eax
  800480:	ff 24 85 24 0f 80 00 	jmp    *0x800f24(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800487:	83 ea 30             	sub    $0x30,%edx
  80048a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80048d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800490:	8d 50 d0             	lea    -0x30(%eax),%edx
  800493:	83 fa 09             	cmp    $0x9,%edx
  800496:	77 44                	ja     8004dc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	89 de                	mov    %ebx,%esi
  80049a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80049e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004a1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004a5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ab:	83 fb 09             	cmp    $0x9,%ebx
  8004ae:	76 ed                	jbe    80049d <vprintfmt+0xa8>
  8004b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004b3:	eb 29                	jmp    8004de <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c5:	eb 17                	jmp    8004de <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cb:	78 85                	js     800452 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	89 de                	mov    %ebx,%esi
  8004cf:	eb 99                	jmp    80046a <vprintfmt+0x75>
  8004d1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004da:	eb 8e                	jmp    80046a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e2:	79 86                	jns    80046a <vprintfmt+0x75>
  8004e4:	e9 74 ff ff ff       	jmp    80045d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	89 de                	mov    %ebx,%esi
  8004ec:	e9 79 ff ff ff       	jmp    80046a <vprintfmt+0x75>
  8004f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	57                   	push   %edi
  800501:	ff 30                	pushl  (%eax)
  800503:	ff 55 08             	call   *0x8(%ebp)
			break;
  800506:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050c:	e9 08 ff ff ff       	jmp    800419 <vprintfmt+0x24>
  800511:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	79 02                	jns    800525 <vprintfmt+0x130>
  800523:	f7 d8                	neg    %eax
  800525:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 06             	cmp    $0x6,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x142>
  80052c:	8b 04 85 7c 10 80 00 	mov    0x80107c(,%eax,4),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	75 1a                	jne    800551 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800537:	52                   	push   %edx
  800538:	68 b0 0e 80 00       	push   $0x800eb0
  80053d:	57                   	push   %edi
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 92 fe ff ff       	call   8003d8 <printfmt>
  800546:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054c:	e9 c8 fe ff ff       	jmp    800419 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800551:	50                   	push   %eax
  800552:	68 3e 0e 80 00       	push   $0x800e3e
  800557:	57                   	push   %edi
  800558:	ff 75 08             	pushl  0x8(%ebp)
  80055b:	e8 78 fe ff ff       	call   8003d8 <printfmt>
  800560:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800566:	e9 ae fe ff ff       	jmp    800419 <vprintfmt+0x24>
  80056b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80056e:	89 de                	mov    %ebx,%esi
  800570:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800573:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800584:	85 c0                	test   %eax,%eax
  800586:	75 07                	jne    80058f <vprintfmt+0x19a>
				p = "(null)";
  800588:	c7 45 d0 a9 0e 80 00 	movl   $0x800ea9,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80058f:	85 db                	test   %ebx,%ebx
  800591:	7e 42                	jle    8005d5 <vprintfmt+0x1e0>
  800593:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800597:	74 3c                	je     8005d5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	51                   	push   %ecx
  80059d:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a0:	e8 6f 02 00 00       	call   800814 <strnlen>
  8005a5:	29 c3                	sub    %eax,%ebx
  8005a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	85 db                	test   %ebx,%ebx
  8005af:	7e 24                	jle    8005d5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005b1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005b5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	53                   	push   %ebx
  8005c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	4e                   	dec    %esi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	85 f6                	test   %esi,%esi
  8005c9:	7f f0                	jg     8005bb <vprintfmt+0x1c6>
  8005cb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d8:	0f be 02             	movsbl (%edx),%eax
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	75 47                	jne    800626 <vprintfmt+0x231>
  8005df:	eb 37                	jmp    800618 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e5:	74 16                	je     8005fd <vprintfmt+0x208>
  8005e7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ea:	83 fa 5e             	cmp    $0x5e,%edx
  8005ed:	76 0e                	jbe    8005fd <vprintfmt+0x208>
					putch('?', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 3f                	push   $0x3f
  8005f5:	ff 55 08             	call   *0x8(%ebp)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb 0b                	jmp    800608 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	57                   	push   %edi
  800601:	50                   	push   %eax
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	ff 4d e4             	decl   -0x1c(%ebp)
  80060b:	0f be 03             	movsbl (%ebx),%eax
  80060e:	85 c0                	test   %eax,%eax
  800610:	74 03                	je     800615 <vprintfmt+0x220>
  800612:	43                   	inc    %ebx
  800613:	eb 1b                	jmp    800630 <vprintfmt+0x23b>
  800615:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800618:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061c:	7f 1e                	jg     80063c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800621:	e9 f3 fd ff ff       	jmp    800419 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800626:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800629:	43                   	inc    %ebx
  80062a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80062d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800630:	85 f6                	test   %esi,%esi
  800632:	78 ad                	js     8005e1 <vprintfmt+0x1ec>
  800634:	4e                   	dec    %esi
  800635:	79 aa                	jns    8005e1 <vprintfmt+0x1ec>
  800637:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80063a:	eb dc                	jmp    800618 <vprintfmt+0x223>
  80063c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 20                	push   $0x20
  800645:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800648:	4b                   	dec    %ebx
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f ef                	jg     80063f <vprintfmt+0x24a>
  800650:	e9 c4 fd ff ff       	jmp    800419 <vprintfmt+0x24>
  800655:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 2a fd ff ff       	call   80038c <getint>
  800662:	89 c3                	mov    %eax,%ebx
  800664:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800666:	85 d2                	test   %edx,%edx
  800668:	78 0a                	js     800674 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 b0 00 00 00       	jmp    800724 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	57                   	push   %edi
  800678:	6a 2d                	push   $0x2d
  80067a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067d:	f7 db                	neg    %ebx
  80067f:	83 d6 00             	adc    $0x0,%esi
  800682:	f7 de                	neg    %esi
  800684:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068c:	e9 93 00 00 00       	jmp    800724 <vprintfmt+0x32f>
  800691:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800694:	89 ca                	mov    %ecx,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 b4 fc ff ff       	call   800352 <getuint>
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	89 d6                	mov    %edx,%esi
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006a7:	eb 7b                	jmp    800724 <vprintfmt+0x32f>
  8006a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006ac:	89 ca                	mov    %ecx,%edx
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 d6 fc ff ff       	call   80038c <getint>
  8006b6:	89 c3                	mov    %eax,%ebx
  8006b8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	78 07                	js     8006c5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006be:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c3:	eb 5f                	jmp    800724 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	57                   	push   %edi
  8006c9:	6a 2d                	push   $0x2d
  8006cb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006ce:	f7 db                	neg    %ebx
  8006d0:	83 d6 00             	adc    $0x0,%esi
  8006d3:	f7 de                	neg    %esi
  8006d5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006dd:	eb 45                	jmp    800724 <vprintfmt+0x32f>
  8006df:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	57                   	push   %edi
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006eb:	83 c4 08             	add    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	6a 78                	push   $0x78
  8006f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fd:	8b 18                	mov    (%eax),%ebx
  8006ff:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800704:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80070c:	eb 16                	jmp    800724 <vprintfmt+0x32f>
  80070e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800711:	89 ca                	mov    %ecx,%edx
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	e8 37 fc ff ff       	call   800352 <getuint>
  80071b:	89 c3                	mov    %eax,%ebx
  80071d:	89 d6                	mov    %edx,%esi
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80072b:	52                   	push   %edx
  80072c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072f:	50                   	push   %eax
  800730:	56                   	push   %esi
  800731:	53                   	push   %ebx
  800732:	89 fa                	mov    %edi,%edx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	e8 68 fb ff ff       	call   8002a4 <printnum>
			break;
  80073c:	83 c4 20             	add    $0x20,%esp
  80073f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800742:	e9 d2 fc ff ff       	jmp    800419 <vprintfmt+0x24>
  800747:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	57                   	push   %edi
  80074e:	52                   	push   %edx
  80074f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800752:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800758:	e9 bc fc ff ff       	jmp    800419 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	57                   	push   %edi
  800761:	6a 25                	push   $0x25
  800763:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 02                	jmp    80076d <vprintfmt+0x378>
  80076b:	89 c6                	mov    %eax,%esi
  80076d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800770:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800774:	75 f5                	jne    80076b <vprintfmt+0x376>
  800776:	e9 9e fc ff ff       	jmp    800419 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80077b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5f                   	pop    %edi
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 18             	sub    $0x18,%esp
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800792:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800796:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800799:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	74 26                	je     8007ca <vsnprintf+0x47>
  8007a4:	85 d2                	test   %edx,%edx
  8007a6:	7e 29                	jle    8007d1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a8:	ff 75 14             	pushl  0x14(%ebp)
  8007ab:	ff 75 10             	pushl  0x10(%ebp)
  8007ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	68 be 03 80 00       	push   $0x8003be
  8007b7:	e8 39 fc ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	eb 0c                	jmp    8007d6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cf:	eb 05                	jmp    8007d6 <vsnprintf+0x53>
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e1:	50                   	push   %eax
  8007e2:	ff 75 10             	pushl  0x10(%ebp)
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	e8 93 ff ff ff       	call   800783 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    
	...

008007f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fd:	74 0e                	je     80080d <strlen+0x19>
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800804:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800809:	75 f9                	jne    800804 <strlen+0x10>
  80080b:	eb 05                	jmp    800812 <strlen+0x1e>
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081d:	85 d2                	test   %edx,%edx
  80081f:	74 17                	je     800838 <strnlen+0x24>
  800821:	80 39 00             	cmpb   $0x0,(%ecx)
  800824:	74 19                	je     80083f <strnlen+0x2b>
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80082b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	39 d0                	cmp    %edx,%eax
  80082e:	74 14                	je     800844 <strnlen+0x30>
  800830:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800834:	75 f5                	jne    80082b <strnlen+0x17>
  800836:	eb 0c                	jmp    800844 <strnlen+0x30>
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
  80083d:	eb 05                	jmp    800844 <strnlen+0x30>
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800850:	ba 00 00 00 00       	mov    $0x0,%edx
  800855:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800858:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80085b:	42                   	inc    %edx
  80085c:	84 c9                	test   %cl,%cl
  80085e:	75 f5                	jne    800855 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086a:	53                   	push   %ebx
  80086b:	e8 84 ff ff ff       	call   8007f4 <strlen>
  800870:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800879:	50                   	push   %eax
  80087a:	e8 c7 ff ff ff       	call   800846 <strcpy>
	return dst;
}
  80087f:	89 d8                	mov    %ebx,%eax
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	85 f6                	test   %esi,%esi
  800896:	74 15                	je     8008ad <strncpy+0x27>
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80089d:	8a 1a                	mov    (%edx),%bl
  80089f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a2:	80 3a 01             	cmpb   $0x1,(%edx)
  8008a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	41                   	inc    %ecx
  8008a9:	39 ce                	cmp    %ecx,%esi
  8008ab:	77 f0                	ja     80089d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008bd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c0:	85 f6                	test   %esi,%esi
  8008c2:	74 32                	je     8008f6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008c4:	83 fe 01             	cmp    $0x1,%esi
  8008c7:	74 22                	je     8008eb <strlcpy+0x3a>
  8008c9:	8a 0b                	mov    (%ebx),%cl
  8008cb:	84 c9                	test   %cl,%cl
  8008cd:	74 20                	je     8008ef <strlcpy+0x3e>
  8008cf:	89 f8                	mov    %edi,%eax
  8008d1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008d6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d9:	88 08                	mov    %cl,(%eax)
  8008db:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008dc:	39 f2                	cmp    %esi,%edx
  8008de:	74 11                	je     8008f1 <strlcpy+0x40>
  8008e0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008e4:	42                   	inc    %edx
  8008e5:	84 c9                	test   %cl,%cl
  8008e7:	75 f0                	jne    8008d9 <strlcpy+0x28>
  8008e9:	eb 06                	jmp    8008f1 <strlcpy+0x40>
  8008eb:	89 f8                	mov    %edi,%eax
  8008ed:	eb 02                	jmp    8008f1 <strlcpy+0x40>
  8008ef:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f1:	c6 00 00             	movb   $0x0,(%eax)
  8008f4:	eb 02                	jmp    8008f8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008f8:	29 f8                	sub    %edi,%eax
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800908:	8a 01                	mov    (%ecx),%al
  80090a:	84 c0                	test   %al,%al
  80090c:	74 10                	je     80091e <strcmp+0x1f>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	75 0c                	jne    80091e <strcmp+0x1f>
		p++, q++;
  800912:	41                   	inc    %ecx
  800913:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800914:	8a 01                	mov    (%ecx),%al
  800916:	84 c0                	test   %al,%al
  800918:	74 04                	je     80091e <strcmp+0x1f>
  80091a:	3a 02                	cmp    (%edx),%al
  80091c:	74 f4                	je     800912 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091e:	0f b6 c0             	movzbl %al,%eax
  800921:	0f b6 12             	movzbl (%edx),%edx
  800924:	29 d0                	sub    %edx,%eax
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	53                   	push   %ebx
  80092c:	8b 55 08             	mov    0x8(%ebp),%edx
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800932:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800935:	85 c0                	test   %eax,%eax
  800937:	74 1b                	je     800954 <strncmp+0x2c>
  800939:	8a 1a                	mov    (%edx),%bl
  80093b:	84 db                	test   %bl,%bl
  80093d:	74 24                	je     800963 <strncmp+0x3b>
  80093f:	3a 19                	cmp    (%ecx),%bl
  800941:	75 20                	jne    800963 <strncmp+0x3b>
  800943:	48                   	dec    %eax
  800944:	74 15                	je     80095b <strncmp+0x33>
		n--, p++, q++;
  800946:	42                   	inc    %edx
  800947:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800948:	8a 1a                	mov    (%edx),%bl
  80094a:	84 db                	test   %bl,%bl
  80094c:	74 15                	je     800963 <strncmp+0x3b>
  80094e:	3a 19                	cmp    (%ecx),%bl
  800950:	74 f1                	je     800943 <strncmp+0x1b>
  800952:	eb 0f                	jmp    800963 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
  800959:	eb 05                	jmp    800960 <strncmp+0x38>
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800960:	5b                   	pop    %ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800963:	0f b6 02             	movzbl (%edx),%eax
  800966:	0f b6 11             	movzbl (%ecx),%edx
  800969:	29 d0                	sub    %edx,%eax
  80096b:	eb f3                	jmp    800960 <strncmp+0x38>

0080096d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800976:	8a 10                	mov    (%eax),%dl
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strchr+0x27>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 06                	jne    800986 <strchr+0x19>
  800980:	eb 17                	jmp    800999 <strchr+0x2c>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 13                	je     800999 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800986:	40                   	inc    %eax
  800987:	8a 10                	mov    (%eax),%dl
  800989:	84 d2                	test   %dl,%dl
  80098b:	75 f5                	jne    800982 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
  800992:	eb 05                	jmp    800999 <strchr+0x2c>
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009a4:	8a 10                	mov    (%eax),%dl
  8009a6:	84 d2                	test   %dl,%dl
  8009a8:	74 11                	je     8009bb <strfind+0x20>
		if (*s == c)
  8009aa:	38 ca                	cmp    %cl,%dl
  8009ac:	75 06                	jne    8009b4 <strfind+0x19>
  8009ae:	eb 0b                	jmp    8009bb <strfind+0x20>
  8009b0:	38 ca                	cmp    %cl,%dl
  8009b2:	74 07                	je     8009bb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b4:	40                   	inc    %eax
  8009b5:	8a 10                	mov    (%eax),%dl
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f5                	jne    8009b0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	74 30                	je     800a00 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d6:	75 25                	jne    8009fd <memset+0x40>
  8009d8:	f6 c1 03             	test   $0x3,%cl
  8009db:	75 20                	jne    8009fd <memset+0x40>
		c &= 0xFF;
  8009dd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e0:	89 d3                	mov    %edx,%ebx
  8009e2:	c1 e3 08             	shl    $0x8,%ebx
  8009e5:	89 d6                	mov    %edx,%esi
  8009e7:	c1 e6 18             	shl    $0x18,%esi
  8009ea:	89 d0                	mov    %edx,%eax
  8009ec:	c1 e0 10             	shl    $0x10,%eax
  8009ef:	09 f0                	or     %esi,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f8:	fc                   	cld    
  8009f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009fb:	eb 03                	jmp    800a00 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fd:	fc                   	cld    
  8009fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a00:	89 f8                	mov    %edi,%eax
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a15:	39 c6                	cmp    %eax,%esi
  800a17:	73 34                	jae    800a4d <memmove+0x46>
  800a19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	73 2d                	jae    800a4d <memmove+0x46>
		s += n;
		d += n;
  800a20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a23:	f6 c2 03             	test   $0x3,%dl
  800a26:	75 1b                	jne    800a43 <memmove+0x3c>
  800a28:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2e:	75 13                	jne    800a43 <memmove+0x3c>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 07                	jmp    800a4a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a43:	4f                   	dec    %edi
  800a44:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a47:	fd                   	std    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4a:	fc                   	cld    
  800a4b:	eb 20                	jmp    800a6d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a53:	75 13                	jne    800a68 <memmove+0x61>
  800a55:	a8 03                	test   $0x3,%al
  800a57:	75 0f                	jne    800a68 <memmove+0x61>
  800a59:	f6 c1 03             	test   $0x3,%cl
  800a5c:	75 0a                	jne    800a68 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	fc                   	cld    
  800a64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a66:	eb 05                	jmp    800a6d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a68:	89 c7                	mov    %eax,%edi
  800a6a:	fc                   	cld    
  800a6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a74:	ff 75 10             	pushl  0x10(%ebp)
  800a77:	ff 75 0c             	pushl  0xc(%ebp)
  800a7a:	ff 75 08             	pushl  0x8(%ebp)
  800a7d:	e8 85 ff ff ff       	call   800a07 <memmove>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	85 ff                	test   %edi,%edi
  800a95:	74 32                	je     800ac9 <memcmp+0x45>
		if (*s1 != *s2)
  800a97:	8a 03                	mov    (%ebx),%al
  800a99:	8a 0e                	mov    (%esi),%cl
  800a9b:	38 c8                	cmp    %cl,%al
  800a9d:	74 19                	je     800ab8 <memcmp+0x34>
  800a9f:	eb 0d                	jmp    800aae <memcmp+0x2a>
  800aa1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800aa5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800aa9:	42                   	inc    %edx
  800aaa:	38 c8                	cmp    %cl,%al
  800aac:	74 10                	je     800abe <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aae:	0f b6 c0             	movzbl %al,%eax
  800ab1:	0f b6 c9             	movzbl %cl,%ecx
  800ab4:	29 c8                	sub    %ecx,%eax
  800ab6:	eb 16                	jmp    800ace <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab8:	4f                   	dec    %edi
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	39 fa                	cmp    %edi,%edx
  800ac0:	75 df                	jne    800aa1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	eb 05                	jmp    800ace <memcmp+0x4a>
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad9:	89 c2                	mov    %eax,%edx
  800adb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ade:	39 d0                	cmp    %edx,%eax
  800ae0:	73 12                	jae    800af4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ae5:	38 08                	cmp    %cl,(%eax)
  800ae7:	75 06                	jne    800aef <memfind+0x1c>
  800ae9:	eb 09                	jmp    800af4 <memfind+0x21>
  800aeb:	38 08                	cmp    %cl,(%eax)
  800aed:	74 05                	je     800af4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	40                   	inc    %eax
  800af0:	39 c2                	cmp    %eax,%edx
  800af2:	77 f7                	ja     800aeb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 01                	jmp    800b05 <strtol+0xf>
		s++;
  800b04:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	8a 02                	mov    (%edx),%al
  800b07:	3c 20                	cmp    $0x20,%al
  800b09:	74 f9                	je     800b04 <strtol+0xe>
  800b0b:	3c 09                	cmp    $0x9,%al
  800b0d:	74 f5                	je     800b04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 08                	jne    800b1b <strtol+0x25>
		s++;
  800b13:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b14:	bf 00 00 00 00       	mov    $0x0,%edi
  800b19:	eb 13                	jmp    800b2e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1b:	3c 2d                	cmp    $0x2d,%al
  800b1d:	75 0a                	jne    800b29 <strtol+0x33>
		s++, neg = 1;
  800b1f:	8d 52 01             	lea    0x1(%edx),%edx
  800b22:	bf 01 00 00 00       	mov    $0x1,%edi
  800b27:	eb 05                	jmp    800b2e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	74 05                	je     800b37 <strtol+0x41>
  800b32:	83 fb 10             	cmp    $0x10,%ebx
  800b35:	75 28                	jne    800b5f <strtol+0x69>
  800b37:	8a 02                	mov    (%edx),%al
  800b39:	3c 30                	cmp    $0x30,%al
  800b3b:	75 10                	jne    800b4d <strtol+0x57>
  800b3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b41:	75 0a                	jne    800b4d <strtol+0x57>
		s += 2, base = 16;
  800b43:	83 c2 02             	add    $0x2,%edx
  800b46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4b:	eb 12                	jmp    800b5f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b4d:	85 db                	test   %ebx,%ebx
  800b4f:	75 0e                	jne    800b5f <strtol+0x69>
  800b51:	3c 30                	cmp    $0x30,%al
  800b53:	75 05                	jne    800b5a <strtol+0x64>
		s++, base = 8;
  800b55:	42                   	inc    %edx
  800b56:	b3 08                	mov    $0x8,%bl
  800b58:	eb 05                	jmp    800b5f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b66:	8a 0a                	mov    (%edx),%cl
  800b68:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b6b:	80 fb 09             	cmp    $0x9,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0x82>
			dig = *s - '0';
  800b70:	0f be c9             	movsbl %cl,%ecx
  800b73:	83 e9 30             	sub    $0x30,%ecx
  800b76:	eb 1e                	jmp    800b96 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b78:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b80:	0f be c9             	movsbl %cl,%ecx
  800b83:	83 e9 57             	sub    $0x57,%ecx
  800b86:	eb 0e                	jmp    800b96 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b88:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 13                	ja     800ba3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b90:	0f be c9             	movsbl %cl,%ecx
  800b93:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b96:	39 f1                	cmp    %esi,%ecx
  800b98:	7d 0d                	jge    800ba7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b9a:	42                   	inc    %edx
  800b9b:	0f af c6             	imul   %esi,%eax
  800b9e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ba1:	eb c3                	jmp    800b66 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ba3:	89 c1                	mov    %eax,%ecx
  800ba5:	eb 02                	jmp    800ba9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bad:	74 05                	je     800bb4 <strtol+0xbe>
		*endptr = (char *) s;
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb4:	85 ff                	test   %edi,%edi
  800bb6:	74 04                	je     800bbc <strtol+0xc6>
  800bb8:	89 c8                	mov    %ecx,%eax
  800bba:	f7 d8                	neg    %eax
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    
  800bc1:	00 00                	add    %al,(%eax)
	...

00800bc4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	83 ec 10             	sub    $0x10,%esp
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bd2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	75 2e                	jne    800c10 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800be2:	39 f1                	cmp    %esi,%ecx
  800be4:	77 5a                	ja     800c40 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800be6:	85 c9                	test   %ecx,%ecx
  800be8:	75 0b                	jne    800bf5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bea:	b8 01 00 00 00       	mov    $0x1,%eax
  800bef:	31 d2                	xor    %edx,%edx
  800bf1:	f7 f1                	div    %ecx
  800bf3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bf5:	31 d2                	xor    %edx,%edx
  800bf7:	89 f0                	mov    %esi,%eax
  800bf9:	f7 f1                	div    %ecx
  800bfb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	f7 f1                	div    %ecx
  800c01:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c03:	89 f8                	mov    %edi,%eax
  800c05:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    
  800c0e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	77 1c                	ja     800c30 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c14:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c17:	83 f7 1f             	xor    $0x1f,%edi
  800c1a:	75 3c                	jne    800c58 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c1c:	39 f0                	cmp    %esi,%eax
  800c1e:	0f 82 90 00 00 00    	jb     800cb4 <__udivdi3+0xf0>
  800c24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c27:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c2a:	0f 86 84 00 00 00    	jbe    800cb4 <__udivdi3+0xf0>
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    
  800c3f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	89 f8                	mov    %edi,%eax
  800c44:	f7 f1                	div    %ecx
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c4a:	89 f8                	mov    %edi,%eax
  800c4c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    
  800c55:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c58:	89 f9                	mov    %edi,%ecx
  800c5a:	d3 e0                	shl    %cl,%eax
  800c5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c5f:	b8 20 00 00 00       	mov    $0x20,%eax
  800c64:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c69:	88 c1                	mov    %al,%cl
  800c6b:	d3 ea                	shr    %cl,%edx
  800c6d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c70:	09 ca                	or     %ecx,%edx
  800c72:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c78:	89 f9                	mov    %edi,%ecx
  800c7a:	d3 e2                	shl    %cl,%edx
  800c7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c7f:	89 f2                	mov    %esi,%edx
  800c81:	88 c1                	mov    %al,%cl
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c88:	89 f2                	mov    %esi,%edx
  800c8a:	89 f9                	mov    %edi,%ecx
  800c8c:	d3 e2                	shl    %cl,%edx
  800c8e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c91:	88 c1                	mov    %al,%cl
  800c93:	d3 ee                	shr    %cl,%esi
  800c95:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c97:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c9a:	89 f0                	mov    %esi,%eax
  800c9c:	89 ca                	mov    %ecx,%edx
  800c9e:	f7 75 ec             	divl   -0x14(%ebp)
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ca5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca8:	39 d1                	cmp    %edx,%ecx
  800caa:	72 28                	jb     800cd4 <__udivdi3+0x110>
  800cac:	74 1a                	je     800cc8 <__udivdi3+0x104>
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	31 f6                	xor    %esi,%esi
  800cb2:	eb 80                	jmp    800c34 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cb4:	31 f6                	xor    %esi,%esi
  800cb6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    
  800cc6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ccf:	39 c2                	cmp    %eax,%edx
  800cd1:	73 db                	jae    800cae <__udivdi3+0xea>
  800cd3:	90                   	nop
		{
		  q0--;
  800cd4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cd7:	31 f6                	xor    %esi,%esi
  800cd9:	e9 56 ff ff ff       	jmp    800c34 <__udivdi3+0x70>
	...

00800ce0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	83 ec 20             	sub    $0x20,%esp
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cf4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cfd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cff:	85 ff                	test   %edi,%edi
  800d01:	75 15                	jne    800d18 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800d03:	39 f1                	cmp    %esi,%ecx
  800d05:	0f 86 99 00 00 00    	jbe    800da4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d0d:	89 d0                	mov    %edx,%eax
  800d0f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d11:	83 c4 20             	add    $0x20,%esp
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d18:	39 f7                	cmp    %esi,%edi
  800d1a:	0f 87 a4 00 00 00    	ja     800dc4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d20:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d23:	83 f0 1f             	xor    $0x1f,%eax
  800d26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d29:	0f 84 a1 00 00 00    	je     800dd0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d34:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d36:	bf 20 00 00 00       	mov    $0x20,%edi
  800d3b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	09 c2                	or     %eax,%edx
  800d47:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d50:	d3 e0                	shl    %cl,%eax
  800d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d55:	89 f2                	mov    %esi,%edx
  800d57:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d5c:	d3 e0                	shl    %cl,%eax
  800d5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d64:	89 f9                	mov    %edi,%ecx
  800d66:	d3 e8                	shr    %cl,%eax
  800d68:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d6a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d6c:	89 f2                	mov    %esi,%edx
  800d6e:	f7 75 f0             	divl   -0x10(%ebp)
  800d71:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d73:	f7 65 f4             	mull   -0xc(%ebp)
  800d76:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d79:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7b:	39 d6                	cmp    %edx,%esi
  800d7d:	72 71                	jb     800df0 <__umoddi3+0x110>
  800d7f:	74 7f                	je     800e00 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d84:	29 c8                	sub    %ecx,%eax
  800d86:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d88:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	89 f9                	mov    %edi,%ecx
  800d91:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d93:	09 d0                	or     %edx,%eax
  800d95:	89 f2                	mov    %esi,%edx
  800d97:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d9a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d9c:	83 c4 20             	add    $0x20,%esp
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    
  800da3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800da4:	85 c9                	test   %ecx,%ecx
  800da6:	75 0b                	jne    800db3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbc:	f7 f1                	div    %ecx
  800dbe:	e9 4a ff ff ff       	jmp    800d0d <__umoddi3+0x2d>
  800dc3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dc4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dc6:	83 c4 20             	add    $0x20,%esp
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd0:	39 f7                	cmp    %esi,%edi
  800dd2:	72 05                	jb     800dd9 <__umoddi3+0xf9>
  800dd4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dd7:	77 0c                	ja     800de5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd9:	89 f2                	mov    %esi,%edx
  800ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dde:	29 c8                	sub    %ecx,%eax
  800de0:	19 fa                	sbb    %edi,%edx
  800de2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de8:	83 c4 20             	add    $0x20,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    
  800def:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800df0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800df8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dfb:	eb 84                	jmp    800d81 <__umoddi3+0xa1>
  800dfd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e00:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800e03:	72 eb                	jb     800df0 <__umoddi3+0x110>
  800e05:	89 f2                	mov    %esi,%edx
  800e07:	e9 75 ff ff ff       	jmp    800d81 <__umoddi3+0xa1>
