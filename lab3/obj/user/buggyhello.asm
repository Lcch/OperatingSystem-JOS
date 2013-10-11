
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 dd 00 00 00       	call   800120 <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800053:	e8 34 01 00 00       	call   80018c <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x30>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	53                   	push   %ebx
  80007c:	56                   	push   %esi
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 0d 00 00 00       	call   800094 <exit>
  800087:	83 c4 10             	add    $0x10,%esp
}
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	c9                   	leave  
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 c9 00 00 00       	call   80016a <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 1c             	sub    $0x1c,%esp
  8000b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000b7:	89 ca                	mov    %ecx,%edx
	assert(a5 == 0);
  8000b9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000bd:	74 16                	je     8000d5 <my_sysenter+0x2d>
  8000bf:	68 0e 0e 80 00       	push   $0x800e0e
  8000c4:	68 16 0e 80 00       	push   $0x800e16
  8000c9:	6a 0b                	push   $0xb
  8000cb:	68 2b 0e 80 00       	push   $0x800e2b
  8000d0:	e8 db 00 00 00       	call   8001b0 <_panic>
	int32_t ret;

	asm volatile(
  8000d5:	be 00 00 00 00       	mov    $0x0,%esi
  8000da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e6:	55                   	push   %ebp
  8000e7:	54                   	push   %esp
  8000e8:	5d                   	pop    %ebp
  8000e9:	8d 35 f1 00 80 00    	lea    0x8000f1,%esi
  8000ef:	0f 34                	sysenter 

008000f1 <after_sysenter_label>:
  8000f1:	5d                   	pop    %ebp
  8000f2:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000f8:	74 1c                	je     800116 <after_sysenter_label+0x25>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 18                	jle    800116 <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	ff 75 e4             	pushl  -0x1c(%ebp)
  800105:	68 3c 0e 80 00       	push   $0x800e3c
  80010a:	6a 20                	push   $0x20
  80010c:	68 2b 0e 80 00       	push   $0x800e2b
  800111:	e8 9a 00 00 00       	call   8001b0 <_panic>

	return ret;
}
  800116:	89 d0                	mov    %edx,%eax
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800126:	6a 00                	push   $0x0
  800128:	6a 00                	push   $0x0
  80012a:	6a 00                	push   $0x0
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 00 00 00 00       	mov    $0x0,%eax
  80013c:	e8 67 ff ff ff       	call   8000a8 <my_sysenter>
  800141:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <sys_cgetc>:

int
sys_cgetc(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	6a 00                	push   $0x0
  800152:	6a 00                	push   $0x0
  800154:	b9 00 00 00 00       	mov    $0x0,%ecx
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 01 00 00 00       	mov    $0x1,%eax
  800163:	e8 40 ff ff ff       	call   8000a8 <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	6a 00                	push   $0x0
  800176:	6a 00                	push   $0x0
  800178:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017b:	ba 01 00 00 00       	mov    $0x1,%edx
  800180:	b8 03 00 00 00       	mov    $0x3,%eax
  800185:	e8 1e ff ff ff       	call   8000a8 <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800192:	6a 00                	push   $0x0
  800194:	6a 00                	push   $0x0
  800196:	6a 00                	push   $0x0
  800198:	6a 00                	push   $0x0
  80019a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a9:	e8 fa fe ff ff       	call   8000a8 <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001b5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001be:	e8 c9 ff ff ff       	call   80018c <sys_getenvid>
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	ff 75 0c             	pushl  0xc(%ebp)
  8001c9:	ff 75 08             	pushl  0x8(%ebp)
  8001cc:	53                   	push   %ebx
  8001cd:	50                   	push   %eax
  8001ce:	68 60 0e 80 00       	push   $0x800e60
  8001d3:	e8 b0 00 00 00       	call   800288 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d8:	83 c4 18             	add    $0x18,%esp
  8001db:	56                   	push   %esi
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	e8 53 00 00 00       	call   800237 <vcprintf>
	cprintf("\n");
  8001e4:	c7 04 24 84 0e 80 00 	movl   $0x800e84,(%esp)
  8001eb:	e8 98 00 00 00       	call   800288 <cprintf>
  8001f0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f3:	cc                   	int3   
  8001f4:	eb fd                	jmp    8001f3 <_panic+0x43>
	...

008001f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	53                   	push   %ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800202:	8b 03                	mov    (%ebx),%eax
  800204:	8b 55 08             	mov    0x8(%ebp),%edx
  800207:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80020b:	40                   	inc    %eax
  80020c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800213:	75 1a                	jne    80022f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	68 ff 00 00 00       	push   $0xff
  80021d:	8d 43 08             	lea    0x8(%ebx),%eax
  800220:	50                   	push   %eax
  800221:	e8 fa fe ff ff       	call   800120 <sys_cputs>
		b->idx = 0;
  800226:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022f:	ff 43 04             	incl   0x4(%ebx)
}
  800232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800240:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800247:	00 00 00 
	b.cnt = 0;
  80024a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800251:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	68 f8 01 80 00       	push   $0x8001f8
  800266:	e8 82 01 00 00       	call   8003ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026b:	83 c4 08             	add    $0x8,%esp
  80026e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800274:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027a:	50                   	push   %eax
  80027b:	e8 a0 fe ff ff       	call   800120 <sys_cputs>

	return b.cnt;
}
  800280:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 9d ff ff ff       	call   800237 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 2c             	sub    $0x2c,%esp
  8002a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a8:	89 d6                	mov    %edx,%esi
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002cc:	72 0c                	jb     8002da <printnum+0x3e>
  8002ce:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002d1:	76 07                	jbe    8002da <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d3:	4b                   	dec    %ebx
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7f 31                	jg     800309 <printnum+0x6d>
  8002d8:	eb 3f                	jmp    800319 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	57                   	push   %edi
  8002de:	4b                   	dec    %ebx
  8002df:	53                   	push   %ebx
  8002e0:	50                   	push   %eax
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f0:	e8 c7 08 00 00       	call   800bbc <__udivdi3>
  8002f5:	83 c4 18             	add    $0x18,%esp
  8002f8:	52                   	push   %edx
  8002f9:	50                   	push   %eax
  8002fa:	89 f2                	mov    %esi,%edx
  8002fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ff:	e8 98 ff ff ff       	call   80029c <printnum>
  800304:	83 c4 20             	add    $0x20,%esp
  800307:	eb 10                	jmp    800319 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	57                   	push   %edi
  80030e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800311:	4b                   	dec    %ebx
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	85 db                	test   %ebx,%ebx
  800317:	7f f0                	jg     800309 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	56                   	push   %esi
  80031d:	83 ec 04             	sub    $0x4,%esp
  800320:	ff 75 d4             	pushl  -0x2c(%ebp)
  800323:	ff 75 d0             	pushl  -0x30(%ebp)
  800326:	ff 75 dc             	pushl  -0x24(%ebp)
  800329:	ff 75 d8             	pushl  -0x28(%ebp)
  80032c:	e8 a7 09 00 00       	call   800cd8 <__umoddi3>
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	0f be 80 86 0e 80 00 	movsbl 0x800e86(%eax),%eax
  80033b:	50                   	push   %eax
  80033c:	ff 55 e4             	call   *-0x1c(%ebp)
  80033f:	83 c4 10             	add    $0x10,%esp
}
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 08             	lea    0x8(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x38>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800387:	83 fa 01             	cmp    $0x1,%edx
  80038a:	7e 0e                	jle    80039a <getint+0x16>
		return va_arg(*ap, long long);
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800391:	89 08                	mov    %ecx,(%eax)
  800393:	8b 02                	mov    (%edx),%eax
  800395:	8b 52 04             	mov    0x4(%edx),%edx
  800398:	eb 1a                	jmp    8003b4 <getint+0x30>
	else if (lflag)
  80039a:	85 d2                	test   %edx,%edx
  80039c:	74 0c                	je     8003aa <getint+0x26>
		return va_arg(*ap, long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
  8003a8:	eb 0a                	jmp    8003b4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003af:	89 08                	mov    %ecx,(%eax)
  8003b1:	8b 02                	mov    (%edx),%eax
  8003b3:	99                   	cltd   
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c4:	73 08                	jae    8003ce <sprintputch+0x18>
		*b->buf++ = ch;
  8003c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c9:	88 0a                	mov    %cl,(%edx)
  8003cb:	42                   	inc    %edx
  8003cc:	89 10                	mov    %edx,(%eax)
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d9:	50                   	push   %eax
  8003da:	ff 75 10             	pushl  0x10(%ebp)
  8003dd:	ff 75 0c             	pushl  0xc(%ebp)
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 05 00 00 00       	call   8003ed <vprintfmt>
	va_end(ap);
  8003e8:	83 c4 10             	add    $0x10,%esp
}
  8003eb:	c9                   	leave  
  8003ec:	c3                   	ret    

008003ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 2c             	sub    $0x2c,%esp
  8003f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003fc:	eb 13                	jmp    800411 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fe:	85 c0                	test   %eax,%eax
  800400:	0f 84 6d 03 00 00    	je     800773 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	57                   	push   %edi
  80040a:	50                   	push   %eax
  80040b:	ff 55 08             	call   *0x8(%ebp)
  80040e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800411:	0f b6 06             	movzbl (%esi),%eax
  800414:	46                   	inc    %esi
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e4                	jne    8003fe <vprintfmt+0x11>
  80041a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80041e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800425:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80042c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800433:	b9 00 00 00 00       	mov    $0x0,%ecx
  800438:	eb 28                	jmp    800462 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800440:	eb 20                	jmp    800462 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800444:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800448:	eb 18                	jmp    800462 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80044c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800453:	eb 0d                	jmp    800462 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800455:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800458:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8a 06                	mov    (%esi),%al
  800464:	0f b6 d0             	movzbl %al,%edx
  800467:	8d 5e 01             	lea    0x1(%esi),%ebx
  80046a:	83 e8 23             	sub    $0x23,%eax
  80046d:	3c 55                	cmp    $0x55,%al
  80046f:	0f 87 e0 02 00 00    	ja     800755 <vprintfmt+0x368>
  800475:	0f b6 c0             	movzbl %al,%eax
  800478:	ff 24 85 10 0f 80 00 	jmp    *0x800f10(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047f:	83 ea 30             	sub    $0x30,%edx
  800482:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800485:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800488:	8d 50 d0             	lea    -0x30(%eax),%edx
  80048b:	83 fa 09             	cmp    $0x9,%edx
  80048e:	77 44                	ja     8004d4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	89 de                	mov    %ebx,%esi
  800492:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800496:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800499:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80049d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004a3:	83 fb 09             	cmp    $0x9,%ebx
  8004a6:	76 ed                	jbe    800495 <vprintfmt+0xa8>
  8004a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ab:	eb 29                	jmp    8004d6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004bd:	eb 17                	jmp    8004d6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c3:	78 85                	js     80044a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	89 de                	mov    %ebx,%esi
  8004c7:	eb 99                	jmp    800462 <vprintfmt+0x75>
  8004c9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004d2:	eb 8e                	jmp    800462 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004da:	79 86                	jns    800462 <vprintfmt+0x75>
  8004dc:	e9 74 ff ff ff       	jmp    800455 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	89 de                	mov    %ebx,%esi
  8004e4:	e9 79 ff ff ff       	jmp    800462 <vprintfmt+0x75>
  8004e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	57                   	push   %edi
  8004f9:	ff 30                	pushl  (%eax)
  8004fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800504:	e9 08 ff ff ff       	jmp    800411 <vprintfmt+0x24>
  800509:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 04             	lea    0x4(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 00                	mov    (%eax),%eax
  800517:	85 c0                	test   %eax,%eax
  800519:	79 02                	jns    80051d <vprintfmt+0x130>
  80051b:	f7 d8                	neg    %eax
  80051d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051f:	83 f8 06             	cmp    $0x6,%eax
  800522:	7f 0b                	jg     80052f <vprintfmt+0x142>
  800524:	8b 04 85 68 10 80 00 	mov    0x801068(,%eax,4),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	75 1a                	jne    800549 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80052f:	52                   	push   %edx
  800530:	68 9e 0e 80 00       	push   $0x800e9e
  800535:	57                   	push   %edi
  800536:	ff 75 08             	pushl  0x8(%ebp)
  800539:	e8 92 fe ff ff       	call   8003d0 <printfmt>
  80053e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800544:	e9 c8 fe ff ff       	jmp    800411 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800549:	50                   	push   %eax
  80054a:	68 28 0e 80 00       	push   $0x800e28
  80054f:	57                   	push   %edi
  800550:	ff 75 08             	pushl  0x8(%ebp)
  800553:	e8 78 fe ff ff       	call   8003d0 <printfmt>
  800558:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055e:	e9 ae fe ff ff       	jmp    800411 <vprintfmt+0x24>
  800563:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800566:	89 de                	mov    %ebx,%esi
  800568:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80056b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057c:	85 c0                	test   %eax,%eax
  80057e:	75 07                	jne    800587 <vprintfmt+0x19a>
				p = "(null)";
  800580:	c7 45 d0 97 0e 80 00 	movl   $0x800e97,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800587:	85 db                	test   %ebx,%ebx
  800589:	7e 42                	jle    8005cd <vprintfmt+0x1e0>
  80058b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80058f:	74 3c                	je     8005cd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	51                   	push   %ecx
  800595:	ff 75 d0             	pushl  -0x30(%ebp)
  800598:	e8 6f 02 00 00       	call   80080c <strnlen>
  80059d:	29 c3                	sub    %eax,%ebx
  80059f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	85 db                	test   %ebx,%ebx
  8005a7:	7e 24                	jle    8005cd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005a9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005ad:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	53                   	push   %ebx
  8005b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	4e                   	dec    %esi
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	7f f0                	jg     8005b3 <vprintfmt+0x1c6>
  8005c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d0:	0f be 02             	movsbl (%edx),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	75 47                	jne    80061e <vprintfmt+0x231>
  8005d7:	eb 37                	jmp    800610 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dd:	74 16                	je     8005f5 <vprintfmt+0x208>
  8005df:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e2:	83 fa 5e             	cmp    $0x5e,%edx
  8005e5:	76 0e                	jbe    8005f5 <vprintfmt+0x208>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 3f                	push   $0x3f
  8005ed:	ff 55 08             	call   *0x8(%ebp)
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb 0b                	jmp    800600 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	57                   	push   %edi
  8005f9:	50                   	push   %eax
  8005fa:	ff 55 08             	call   *0x8(%ebp)
  8005fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800600:	ff 4d e4             	decl   -0x1c(%ebp)
  800603:	0f be 03             	movsbl (%ebx),%eax
  800606:	85 c0                	test   %eax,%eax
  800608:	74 03                	je     80060d <vprintfmt+0x220>
  80060a:	43                   	inc    %ebx
  80060b:	eb 1b                	jmp    800628 <vprintfmt+0x23b>
  80060d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800610:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800614:	7f 1e                	jg     800634 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800619:	e9 f3 fd ff ff       	jmp    800411 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800621:	43                   	inc    %ebx
  800622:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800625:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800628:	85 f6                	test   %esi,%esi
  80062a:	78 ad                	js     8005d9 <vprintfmt+0x1ec>
  80062c:	4e                   	dec    %esi
  80062d:	79 aa                	jns    8005d9 <vprintfmt+0x1ec>
  80062f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800632:	eb dc                	jmp    800610 <vprintfmt+0x223>
  800634:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 20                	push   $0x20
  80063d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800640:	4b                   	dec    %ebx
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f ef                	jg     800637 <vprintfmt+0x24a>
  800648:	e9 c4 fd ff ff       	jmp    800411 <vprintfmt+0x24>
  80064d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800650:	89 ca                	mov    %ecx,%edx
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 2a fd ff ff       	call   800384 <getint>
  80065a:	89 c3                	mov    %eax,%ebx
  80065c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80065e:	85 d2                	test   %edx,%edx
  800660:	78 0a                	js     80066c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800662:	b8 0a 00 00 00       	mov    $0xa,%eax
  800667:	e9 b0 00 00 00       	jmp    80071c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	57                   	push   %edi
  800670:	6a 2d                	push   $0x2d
  800672:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800675:	f7 db                	neg    %ebx
  800677:	83 d6 00             	adc    $0x0,%esi
  80067a:	f7 de                	neg    %esi
  80067c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800684:	e9 93 00 00 00       	jmp    80071c <vprintfmt+0x32f>
  800689:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 b4 fc ff ff       	call   80034a <getuint>
  800696:	89 c3                	mov    %eax,%ebx
  800698:	89 d6                	mov    %edx,%esi
			base = 10;
  80069a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069f:	eb 7b                	jmp    80071c <vprintfmt+0x32f>
  8006a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006a4:	89 ca                	mov    %ecx,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 d6 fc ff ff       	call   800384 <getint>
  8006ae:	89 c3                	mov    %eax,%ebx
  8006b0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	78 07                	js     8006bd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006bb:	eb 5f                	jmp    80071c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	57                   	push   %edi
  8006c1:	6a 2d                	push   $0x2d
  8006c3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006c6:	f7 db                	neg    %ebx
  8006c8:	83 d6 00             	adc    $0x0,%esi
  8006cb:	f7 de                	neg    %esi
  8006cd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d5:	eb 45                	jmp    80071c <vprintfmt+0x32f>
  8006d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	57                   	push   %edi
  8006de:	6a 30                	push   $0x30
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	57                   	push   %edi
  8006e7:	6a 78                	push   $0x78
  8006e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f5:	8b 18                	mov    (%eax),%ebx
  8006f7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800704:	eb 16                	jmp    80071c <vprintfmt+0x32f>
  800706:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800709:	89 ca                	mov    %ecx,%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 37 fc ff ff       	call   80034a <getuint>
  800713:	89 c3                	mov    %eax,%ebx
  800715:	89 d6                	mov    %edx,%esi
			base = 16;
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071c:	83 ec 0c             	sub    $0xc,%esp
  80071f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800723:	52                   	push   %edx
  800724:	ff 75 e4             	pushl  -0x1c(%ebp)
  800727:	50                   	push   %eax
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	89 fa                	mov    %edi,%edx
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	e8 68 fb ff ff       	call   80029c <printnum>
			break;
  800734:	83 c4 20             	add    $0x20,%esp
  800737:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80073a:	e9 d2 fc ff ff       	jmp    800411 <vprintfmt+0x24>
  80073f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	57                   	push   %edi
  800746:	52                   	push   %edx
  800747:	ff 55 08             	call   *0x8(%ebp)
			break;
  80074a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800750:	e9 bc fc ff ff       	jmp    800411 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	57                   	push   %edi
  800759:	6a 25                	push   $0x25
  80075b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 02                	jmp    800765 <vprintfmt+0x378>
  800763:	89 c6                	mov    %eax,%esi
  800765:	8d 46 ff             	lea    -0x1(%esi),%eax
  800768:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80076c:	75 f5                	jne    800763 <vprintfmt+0x376>
  80076e:	e9 9e fc ff ff       	jmp    800411 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800773:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5f                   	pop    %edi
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	83 ec 18             	sub    $0x18,%esp
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800787:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800791:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800798:	85 c0                	test   %eax,%eax
  80079a:	74 26                	je     8007c2 <vsnprintf+0x47>
  80079c:	85 d2                	test   %edx,%edx
  80079e:	7e 29                	jle    8007c9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a0:	ff 75 14             	pushl  0x14(%ebp)
  8007a3:	ff 75 10             	pushl  0x10(%ebp)
  8007a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	68 b6 03 80 00       	push   $0x8003b6
  8007af:	e8 39 fc ff ff       	call   8003ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	eb 0c                	jmp    8007ce <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c7:	eb 05                	jmp    8007ce <vsnprintf+0x53>
  8007c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d9:	50                   	push   %eax
  8007da:	ff 75 10             	pushl  0x10(%ebp)
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	ff 75 08             	pushl  0x8(%ebp)
  8007e3:	e8 93 ff ff ff       	call   80077b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
	...

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f5:	74 0e                	je     800805 <strlen+0x19>
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007fc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800801:	75 f9                	jne    8007fc <strlen+0x10>
  800803:	eb 05                	jmp    80080a <strlen+0x1e>
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 17                	je     800830 <strnlen+0x24>
  800819:	80 39 00             	cmpb   $0x0,(%ecx)
  80081c:	74 19                	je     800837 <strnlen+0x2b>
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800823:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800824:	39 d0                	cmp    %edx,%eax
  800826:	74 14                	je     80083c <strnlen+0x30>
  800828:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082c:	75 f5                	jne    800823 <strnlen+0x17>
  80082e:	eb 0c                	jmp    80083c <strnlen+0x30>
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	eb 05                	jmp    80083c <strnlen+0x30>
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800848:	ba 00 00 00 00       	mov    $0x0,%edx
  80084d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800850:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800853:	42                   	inc    %edx
  800854:	84 c9                	test   %cl,%cl
  800856:	75 f5                	jne    80084d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800858:	5b                   	pop    %ebx
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800862:	53                   	push   %ebx
  800863:	e8 84 ff ff ff       	call   8007ec <strlen>
  800868:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086b:	ff 75 0c             	pushl  0xc(%ebp)
  80086e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800871:	50                   	push   %eax
  800872:	e8 c7 ff ff ff       	call   80083e <strcpy>
	return dst;
}
  800877:	89 d8                	mov    %ebx,%eax
  800879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088c:	85 f6                	test   %esi,%esi
  80088e:	74 15                	je     8008a5 <strncpy+0x27>
  800890:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800895:	8a 1a                	mov    (%edx),%bl
  800897:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089a:	80 3a 01             	cmpb   $0x1,(%edx)
  80089d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a0:	41                   	inc    %ecx
  8008a1:	39 ce                	cmp    %ecx,%esi
  8008a3:	77 f0                	ja     800895 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b8:	85 f6                	test   %esi,%esi
  8008ba:	74 32                	je     8008ee <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008bc:	83 fe 01             	cmp    $0x1,%esi
  8008bf:	74 22                	je     8008e3 <strlcpy+0x3a>
  8008c1:	8a 0b                	mov    (%ebx),%cl
  8008c3:	84 c9                	test   %cl,%cl
  8008c5:	74 20                	je     8008e7 <strlcpy+0x3e>
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008ce:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d1:	88 08                	mov    %cl,(%eax)
  8008d3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d4:	39 f2                	cmp    %esi,%edx
  8008d6:	74 11                	je     8008e9 <strlcpy+0x40>
  8008d8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008dc:	42                   	inc    %edx
  8008dd:	84 c9                	test   %cl,%cl
  8008df:	75 f0                	jne    8008d1 <strlcpy+0x28>
  8008e1:	eb 06                	jmp    8008e9 <strlcpy+0x40>
  8008e3:	89 f8                	mov    %edi,%eax
  8008e5:	eb 02                	jmp    8008e9 <strlcpy+0x40>
  8008e7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e9:	c6 00 00             	movb   $0x0,(%eax)
  8008ec:	eb 02                	jmp    8008f0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ee:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008f0:	29 f8                	sub    %edi,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5f                   	pop    %edi
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	8a 01                	mov    (%ecx),%al
  800902:	84 c0                	test   %al,%al
  800904:	74 10                	je     800916 <strcmp+0x1f>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	75 0c                	jne    800916 <strcmp+0x1f>
		p++, q++;
  80090a:	41                   	inc    %ecx
  80090b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090c:	8a 01                	mov    (%ecx),%al
  80090e:	84 c0                	test   %al,%al
  800910:	74 04                	je     800916 <strcmp+0x1f>
  800912:	3a 02                	cmp    (%edx),%al
  800914:	74 f4                	je     80090a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 c0             	movzbl %al,%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	8b 55 08             	mov    0x8(%ebp),%edx
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	74 1b                	je     80094c <strncmp+0x2c>
  800931:	8a 1a                	mov    (%edx),%bl
  800933:	84 db                	test   %bl,%bl
  800935:	74 24                	je     80095b <strncmp+0x3b>
  800937:	3a 19                	cmp    (%ecx),%bl
  800939:	75 20                	jne    80095b <strncmp+0x3b>
  80093b:	48                   	dec    %eax
  80093c:	74 15                	je     800953 <strncmp+0x33>
		n--, p++, q++;
  80093e:	42                   	inc    %edx
  80093f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800940:	8a 1a                	mov    (%edx),%bl
  800942:	84 db                	test   %bl,%bl
  800944:	74 15                	je     80095b <strncmp+0x3b>
  800946:	3a 19                	cmp    (%ecx),%bl
  800948:	74 f1                	je     80093b <strncmp+0x1b>
  80094a:	eb 0f                	jmp    80095b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 05                	jmp    800958 <strncmp+0x38>
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800958:	5b                   	pop    %ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095b:	0f b6 02             	movzbl (%edx),%eax
  80095e:	0f b6 11             	movzbl (%ecx),%edx
  800961:	29 d0                	sub    %edx,%eax
  800963:	eb f3                	jmp    800958 <strncmp+0x38>

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096e:	8a 10                	mov    (%eax),%dl
  800970:	84 d2                	test   %dl,%dl
  800972:	74 18                	je     80098c <strchr+0x27>
		if (*s == c)
  800974:	38 ca                	cmp    %cl,%dl
  800976:	75 06                	jne    80097e <strchr+0x19>
  800978:	eb 17                	jmp    800991 <strchr+0x2c>
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 13                	je     800991 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097e:	40                   	inc    %eax
  80097f:	8a 10                	mov    (%eax),%dl
  800981:	84 d2                	test   %dl,%dl
  800983:	75 f5                	jne    80097a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	eb 05                	jmp    800991 <strchr+0x2c>
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099c:	8a 10                	mov    (%eax),%dl
  80099e:	84 d2                	test   %dl,%dl
  8009a0:	74 11                	je     8009b3 <strfind+0x20>
		if (*s == c)
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	75 06                	jne    8009ac <strfind+0x19>
  8009a6:	eb 0b                	jmp    8009b3 <strfind+0x20>
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 07                	je     8009b3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	40                   	inc    %eax
  8009ad:	8a 10                	mov    (%eax),%dl
  8009af:	84 d2                	test   %dl,%dl
  8009b1:	75 f5                	jne    8009a8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	57                   	push   %edi
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c4:	85 c9                	test   %ecx,%ecx
  8009c6:	74 30                	je     8009f8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ce:	75 25                	jne    8009f5 <memset+0x40>
  8009d0:	f6 c1 03             	test   $0x3,%cl
  8009d3:	75 20                	jne    8009f5 <memset+0x40>
		c &= 0xFF;
  8009d5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d8:	89 d3                	mov    %edx,%ebx
  8009da:	c1 e3 08             	shl    $0x8,%ebx
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	c1 e6 18             	shl    $0x18,%esi
  8009e2:	89 d0                	mov    %edx,%eax
  8009e4:	c1 e0 10             	shl    $0x10,%eax
  8009e7:	09 f0                	or     %esi,%eax
  8009e9:	09 d0                	or     %edx,%eax
  8009eb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ed:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f0:	fc                   	cld    
  8009f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f3:	eb 03                	jmp    8009f8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f5:	fc                   	cld    
  8009f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f8:	89 f8                	mov    %edi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0d:	39 c6                	cmp    %eax,%esi
  800a0f:	73 34                	jae    800a45 <memmove+0x46>
  800a11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a14:	39 d0                	cmp    %edx,%eax
  800a16:	73 2d                	jae    800a45 <memmove+0x46>
		s += n;
		d += n;
  800a18:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	75 1b                	jne    800a3b <memmove+0x3c>
  800a20:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a26:	75 13                	jne    800a3b <memmove+0x3c>
  800a28:	f6 c1 03             	test   $0x3,%cl
  800a2b:	75 0e                	jne    800a3b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2d:	83 ef 04             	sub    $0x4,%edi
  800a30:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a33:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a36:	fd                   	std    
  800a37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a39:	eb 07                	jmp    800a42 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3b:	4f                   	dec    %edi
  800a3c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3f:	fd                   	std    
  800a40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a42:	fc                   	cld    
  800a43:	eb 20                	jmp    800a65 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4b:	75 13                	jne    800a60 <memmove+0x61>
  800a4d:	a8 03                	test   $0x3,%al
  800a4f:	75 0f                	jne    800a60 <memmove+0x61>
  800a51:	f6 c1 03             	test   $0x3,%cl
  800a54:	75 0a                	jne    800a60 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a56:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a59:	89 c7                	mov    %eax,%edi
  800a5b:	fc                   	cld    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 05                	jmp    800a65 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a6c:	ff 75 10             	pushl  0x10(%ebp)
  800a6f:	ff 75 0c             	pushl  0xc(%ebp)
  800a72:	ff 75 08             	pushl  0x8(%ebp)
  800a75:	e8 85 ff ff ff       	call   8009ff <memmove>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	85 ff                	test   %edi,%edi
  800a8d:	74 32                	je     800ac1 <memcmp+0x45>
		if (*s1 != *s2)
  800a8f:	8a 03                	mov    (%ebx),%al
  800a91:	8a 0e                	mov    (%esi),%cl
  800a93:	38 c8                	cmp    %cl,%al
  800a95:	74 19                	je     800ab0 <memcmp+0x34>
  800a97:	eb 0d                	jmp    800aa6 <memcmp+0x2a>
  800a99:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a9d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800aa1:	42                   	inc    %edx
  800aa2:	38 c8                	cmp    %cl,%al
  800aa4:	74 10                	je     800ab6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aa6:	0f b6 c0             	movzbl %al,%eax
  800aa9:	0f b6 c9             	movzbl %cl,%ecx
  800aac:	29 c8                	sub    %ecx,%eax
  800aae:	eb 16                	jmp    800ac6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab0:	4f                   	dec    %edi
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	39 fa                	cmp    %edi,%edx
  800ab8:	75 df                	jne    800a99 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	eb 05                	jmp    800ac6 <memcmp+0x4a>
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad6:	39 d0                	cmp    %edx,%eax
  800ad8:	73 12                	jae    800aec <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ada:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800add:	38 08                	cmp    %cl,(%eax)
  800adf:	75 06                	jne    800ae7 <memfind+0x1c>
  800ae1:	eb 09                	jmp    800aec <memfind+0x21>
  800ae3:	38 08                	cmp    %cl,(%eax)
  800ae5:	74 05                	je     800aec <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae7:	40                   	inc    %eax
  800ae8:	39 c2                	cmp    %eax,%edx
  800aea:	77 f7                	ja     800ae3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	eb 01                	jmp    800afd <strtol+0xf>
		s++;
  800afc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afd:	8a 02                	mov    (%edx),%al
  800aff:	3c 20                	cmp    $0x20,%al
  800b01:	74 f9                	je     800afc <strtol+0xe>
  800b03:	3c 09                	cmp    $0x9,%al
  800b05:	74 f5                	je     800afc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b07:	3c 2b                	cmp    $0x2b,%al
  800b09:	75 08                	jne    800b13 <strtol+0x25>
		s++;
  800b0b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b11:	eb 13                	jmp    800b26 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b13:	3c 2d                	cmp    $0x2d,%al
  800b15:	75 0a                	jne    800b21 <strtol+0x33>
		s++, neg = 1;
  800b17:	8d 52 01             	lea    0x1(%edx),%edx
  800b1a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1f:	eb 05                	jmp    800b26 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b26:	85 db                	test   %ebx,%ebx
  800b28:	74 05                	je     800b2f <strtol+0x41>
  800b2a:	83 fb 10             	cmp    $0x10,%ebx
  800b2d:	75 28                	jne    800b57 <strtol+0x69>
  800b2f:	8a 02                	mov    (%edx),%al
  800b31:	3c 30                	cmp    $0x30,%al
  800b33:	75 10                	jne    800b45 <strtol+0x57>
  800b35:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b39:	75 0a                	jne    800b45 <strtol+0x57>
		s += 2, base = 16;
  800b3b:	83 c2 02             	add    $0x2,%edx
  800b3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b43:	eb 12                	jmp    800b57 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	75 0e                	jne    800b57 <strtol+0x69>
  800b49:	3c 30                	cmp    $0x30,%al
  800b4b:	75 05                	jne    800b52 <strtol+0x64>
		s++, base = 8;
  800b4d:	42                   	inc    %edx
  800b4e:	b3 08                	mov    $0x8,%bl
  800b50:	eb 05                	jmp    800b57 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5e:	8a 0a                	mov    (%edx),%cl
  800b60:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b63:	80 fb 09             	cmp    $0x9,%bl
  800b66:	77 08                	ja     800b70 <strtol+0x82>
			dig = *s - '0';
  800b68:	0f be c9             	movsbl %cl,%ecx
  800b6b:	83 e9 30             	sub    $0x30,%ecx
  800b6e:	eb 1e                	jmp    800b8e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b70:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b73:	80 fb 19             	cmp    $0x19,%bl
  800b76:	77 08                	ja     800b80 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b78:	0f be c9             	movsbl %cl,%ecx
  800b7b:	83 e9 57             	sub    $0x57,%ecx
  800b7e:	eb 0e                	jmp    800b8e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b80:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b83:	80 fb 19             	cmp    $0x19,%bl
  800b86:	77 13                	ja     800b9b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b88:	0f be c9             	movsbl %cl,%ecx
  800b8b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8e:	39 f1                	cmp    %esi,%ecx
  800b90:	7d 0d                	jge    800b9f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b92:	42                   	inc    %edx
  800b93:	0f af c6             	imul   %esi,%eax
  800b96:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b99:	eb c3                	jmp    800b5e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b9b:	89 c1                	mov    %eax,%ecx
  800b9d:	eb 02                	jmp    800ba1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba5:	74 05                	je     800bac <strtol+0xbe>
		*endptr = (char *) s;
  800ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800baa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bac:	85 ff                	test   %edi,%edi
  800bae:	74 04                	je     800bb4 <strtol+0xc6>
  800bb0:	89 c8                	mov    %ecx,%eax
  800bb2:	f7 d8                	neg    %eax
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    
  800bb9:	00 00                	add    %al,(%eax)
	...

00800bbc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	83 ec 10             	sub    $0x10,%esp
  800bc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bca:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bd0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bd3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	75 2e                	jne    800c08 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bda:	39 f1                	cmp    %esi,%ecx
  800bdc:	77 5a                	ja     800c38 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bde:	85 c9                	test   %ecx,%ecx
  800be0:	75 0b                	jne    800bed <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800be2:	b8 01 00 00 00       	mov    $0x1,%eax
  800be7:	31 d2                	xor    %edx,%edx
  800be9:	f7 f1                	div    %ecx
  800beb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bed:	31 d2                	xor    %edx,%edx
  800bef:	89 f0                	mov    %esi,%eax
  800bf1:	f7 f1                	div    %ecx
  800bf3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	f7 f1                	div    %ecx
  800bf9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bfb:	89 f8                	mov    %edi,%eax
  800bfd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    
  800c06:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c08:	39 f0                	cmp    %esi,%eax
  800c0a:	77 1c                	ja     800c28 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c0c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c0f:	83 f7 1f             	xor    $0x1f,%edi
  800c12:	75 3c                	jne    800c50 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c14:	39 f0                	cmp    %esi,%eax
  800c16:	0f 82 90 00 00 00    	jb     800cac <__udivdi3+0xf0>
  800c1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c1f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c22:	0f 86 84 00 00 00    	jbe    800cac <__udivdi3+0xf0>
  800c28:	31 f6                	xor    %esi,%esi
  800c2a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c2c:	89 f8                	mov    %edi,%eax
  800c2e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    
  800c37:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	89 f8                	mov    %edi,%eax
  800c3c:	f7 f1                	div    %ecx
  800c3e:	89 c7                	mov    %eax,%edi
  800c40:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c42:	89 f8                	mov    %edi,%eax
  800c44:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    
  800c4d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c50:	89 f9                	mov    %edi,%ecx
  800c52:	d3 e0                	shl    %cl,%eax
  800c54:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c57:	b8 20 00 00 00       	mov    $0x20,%eax
  800c5c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c61:	88 c1                	mov    %al,%cl
  800c63:	d3 ea                	shr    %cl,%edx
  800c65:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c68:	09 ca                	or     %ecx,%edx
  800c6a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c70:	89 f9                	mov    %edi,%ecx
  800c72:	d3 e2                	shl    %cl,%edx
  800c74:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c77:	89 f2                	mov    %esi,%edx
  800c79:	88 c1                	mov    %al,%cl
  800c7b:	d3 ea                	shr    %cl,%edx
  800c7d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c80:	89 f2                	mov    %esi,%edx
  800c82:	89 f9                	mov    %edi,%ecx
  800c84:	d3 e2                	shl    %cl,%edx
  800c86:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c89:	88 c1                	mov    %al,%cl
  800c8b:	d3 ee                	shr    %cl,%esi
  800c8d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c8f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	89 ca                	mov    %ecx,%edx
  800c96:	f7 75 ec             	divl   -0x14(%ebp)
  800c99:	89 d1                	mov    %edx,%ecx
  800c9b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c9d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca0:	39 d1                	cmp    %edx,%ecx
  800ca2:	72 28                	jb     800ccc <__udivdi3+0x110>
  800ca4:	74 1a                	je     800cc0 <__udivdi3+0x104>
  800ca6:	89 f7                	mov    %esi,%edi
  800ca8:	31 f6                	xor    %esi,%esi
  800caa:	eb 80                	jmp    800c2c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cac:	31 f6                	xor    %esi,%esi
  800cae:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb3:	89 f8                	mov    %edi,%eax
  800cb5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    
  800cbe:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cc3:	89 f9                	mov    %edi,%ecx
  800cc5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cc7:	39 c2                	cmp    %eax,%edx
  800cc9:	73 db                	jae    800ca6 <__udivdi3+0xea>
  800ccb:	90                   	nop
		{
		  q0--;
  800ccc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ccf:	31 f6                	xor    %esi,%esi
  800cd1:	e9 56 ff ff ff       	jmp    800c2c <__udivdi3+0x70>
	...

00800cd8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	83 ec 20             	sub    $0x20,%esp
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ce6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ce9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cef:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cf5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cf7:	85 ff                	test   %edi,%edi
  800cf9:	75 15                	jne    800d10 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cfb:	39 f1                	cmp    %esi,%ecx
  800cfd:	0f 86 99 00 00 00    	jbe    800d9c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d03:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d05:	89 d0                	mov    %edx,%eax
  800d07:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d09:	83 c4 20             	add    $0x20,%esp
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d10:	39 f7                	cmp    %esi,%edi
  800d12:	0f 87 a4 00 00 00    	ja     800dbc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d18:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d1b:	83 f0 1f             	xor    $0x1f,%eax
  800d1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d21:	0f 84 a1 00 00 00    	je     800dc8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d27:	89 f8                	mov    %edi,%eax
  800d29:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d2c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d2e:	bf 20 00 00 00       	mov    $0x20,%edi
  800d33:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d39:	89 f9                	mov    %edi,%ecx
  800d3b:	d3 ea                	shr    %cl,%edx
  800d3d:	09 c2                	or     %eax,%edx
  800d3f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d45:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d48:	d3 e0                	shl    %cl,%eax
  800d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d51:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d54:	d3 e0                	shl    %cl,%eax
  800d56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d5c:	89 f9                	mov    %edi,%ecx
  800d5e:	d3 e8                	shr    %cl,%eax
  800d60:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d62:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d64:	89 f2                	mov    %esi,%edx
  800d66:	f7 75 f0             	divl   -0x10(%ebp)
  800d69:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d6b:	f7 65 f4             	mull   -0xc(%ebp)
  800d6e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d71:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d73:	39 d6                	cmp    %edx,%esi
  800d75:	72 71                	jb     800de8 <__umoddi3+0x110>
  800d77:	74 7f                	je     800df8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d7c:	29 c8                	sub    %ecx,%eax
  800d7e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d80:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d83:	d3 e8                	shr    %cl,%eax
  800d85:	89 f2                	mov    %esi,%edx
  800d87:	89 f9                	mov    %edi,%ecx
  800d89:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d8b:	09 d0                	or     %edx,%eax
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d92:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d94:	83 c4 20             	add    $0x20,%esp
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    
  800d9b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	75 0b                	jne    800dab <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f1                	div    %ecx
  800da9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db4:	f7 f1                	div    %ecx
  800db6:	e9 4a ff ff ff       	jmp    800d05 <__umoddi3+0x2d>
  800dbb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dbc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dbe:	83 c4 20             	add    $0x20,%esp
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    
  800dc5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc8:	39 f7                	cmp    %esi,%edi
  800dca:	72 05                	jb     800dd1 <__umoddi3+0xf9>
  800dcc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dcf:	77 0c                	ja     800ddd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd1:	89 f2                	mov    %esi,%edx
  800dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd6:	29 c8                	sub    %ecx,%eax
  800dd8:	19 fa                	sbb    %edi,%edx
  800dda:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    
  800de7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800de8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800deb:	89 c1                	mov    %eax,%ecx
  800ded:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800df0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800df3:	eb 84                	jmp    800d79 <__umoddi3+0xa1>
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800df8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dfb:	72 eb                	jb     800de8 <__umoddi3+0x110>
  800dfd:	89 f2                	mov    %esi,%edx
  800dff:	e9 75 ff ff ff       	jmp    800d79 <__umoddi3+0xa1>
