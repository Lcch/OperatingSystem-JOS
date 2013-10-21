
obj/user/faultwrite:     file format elf32-i386


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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

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
  80004f:	e8 09 01 00 00       	call   80015d <sys_getenvid>
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
  800098:	e8 9e 00 00 00       	call   80013b <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
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
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	8b 75 14             	mov    0x14(%ebp),%esi
  8000b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c1:	cd 30                	int    $0x30
  8000c3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000c9:	74 1c                	je     8000e7 <syscall+0x43>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7e 18                	jle    8000e7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	50                   	push   %eax
  8000d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000d6:	68 e2 0d 80 00       	push   $0x800de2
  8000db:	6a 42                	push   $0x42
  8000dd:	68 ff 0d 80 00       	push   $0x800dff
  8000e2:	e8 9d 00 00 00       	call   800184 <_panic>

	return ret;
}
  8000e7:	89 d0                	mov    %edx,%eax
  8000e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f7:	6a 00                	push   $0x0
  8000f9:	6a 00                	push   $0x0
  8000fb:	6a 00                	push   $0x0
  8000fd:	ff 75 0c             	pushl  0xc(%ebp)
  800100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800103:	ba 00 00 00 00       	mov    $0x0,%edx
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 92 ff ff ff       	call   8000a4 <syscall>
  800112:	83 c4 10             	add    $0x10,%esp
	return;
}
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <sys_cgetc>:

int
sys_cgetc(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80011d:	6a 00                	push   $0x0
  80011f:	6a 00                	push   $0x0
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 01 00 00 00       	mov    $0x1,%eax
  800134:	e8 6b ff ff ff       	call   8000a4 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014c:	ba 01 00 00 00       	mov    $0x1,%edx
  800151:	b8 03 00 00 00       	mov    $0x3,%eax
  800156:	e8 49 ff ff ff       	call   8000a4 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 02 00 00 00       	mov    $0x2,%eax
  80017a:	e8 25 ff ff ff       	call   8000a4 <syscall>
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800189:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800192:	e8 c6 ff ff ff       	call   80015d <sys_getenvid>
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 0c             	pushl  0xc(%ebp)
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	53                   	push   %ebx
  8001a1:	50                   	push   %eax
  8001a2:	68 10 0e 80 00       	push   $0x800e10
  8001a7:	e8 b0 00 00 00       	call   80025c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	56                   	push   %esi
  8001b0:	ff 75 10             	pushl  0x10(%ebp)
  8001b3:	e8 53 00 00 00       	call   80020b <vcprintf>
	cprintf("\n");
  8001b8:	c7 04 24 34 0e 80 00 	movl   $0x800e34,(%esp)
  8001bf:	e8 98 00 00 00       	call   80025c <cprintf>
  8001c4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x43>
	...

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d6:	8b 03                	mov    (%ebx),%eax
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001df:	40                   	inc    %eax
  8001e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e7:	75 1a                	jne    800203 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 f7 fe ff ff       	call   8000f1 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800200:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800203:	ff 43 04             	incl   0x4(%ebx)
}
  800206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	50                   	push   %eax
  800235:	68 cc 01 80 00       	push   $0x8001cc
  80023a:	e8 82 01 00 00       	call   8003c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023f:	83 c4 08             	add    $0x8,%esp
  800242:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800248:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024e:	50                   	push   %eax
  80024f:	e8 9d fe ff ff       	call   8000f1 <sys_cputs>

	return b.cnt;
}
  800254:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800262:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800265:	50                   	push   %eax
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 9d ff ff ff       	call   80020b <vcprintf>
	va_end(ap);

	return cnt;
}
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	8b 55 0c             	mov    0xc(%ebp),%edx
  800284:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800287:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800293:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800296:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80029d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002a0:	72 0c                	jb     8002ae <printnum+0x3e>
  8002a2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002a5:	76 07                	jbe    8002ae <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a7:	4b                   	dec    %ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f 31                	jg     8002dd <printnum+0x6d>
  8002ac:	eb 3f                	jmp    8002ed <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	57                   	push   %edi
  8002b2:	4b                   	dec    %ebx
  8002b3:	53                   	push   %ebx
  8002b4:	50                   	push   %eax
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 c7 08 00 00       	call   800b90 <__udivdi3>
  8002c9:	83 c4 18             	add    $0x18,%esp
  8002cc:	52                   	push   %edx
  8002cd:	50                   	push   %eax
  8002ce:	89 f2                	mov    %esi,%edx
  8002d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d3:	e8 98 ff ff ff       	call   800270 <printnum>
  8002d8:	83 c4 20             	add    $0x20,%esp
  8002db:	eb 10                	jmp    8002ed <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	56                   	push   %esi
  8002e1:	57                   	push   %edi
  8002e2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e5:	4b                   	dec    %ebx
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	85 db                	test   %ebx,%ebx
  8002eb:	7f f0                	jg     8002dd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	56                   	push   %esi
  8002f1:	83 ec 04             	sub    $0x4,%esp
  8002f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800300:	e8 a7 09 00 00       	call   800cac <__umoddi3>
  800305:	83 c4 14             	add    $0x14,%esp
  800308:	0f be 80 36 0e 80 00 	movsbl 0x800e36(%eax),%eax
  80030f:	50                   	push   %eax
  800310:	ff 55 e4             	call   *-0x1c(%ebp)
  800313:	83 c4 10             	add    $0x10,%esp
}
  800316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800321:	83 fa 01             	cmp    $0x1,%edx
  800324:	7e 0e                	jle    800334 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	8b 52 04             	mov    0x4(%edx),%edx
  800332:	eb 22                	jmp    800356 <getuint+0x38>
	else if (lflag)
  800334:	85 d2                	test   %edx,%edx
  800336:	74 10                	je     800348 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	eb 0e                	jmp    800356 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035b:	83 fa 01             	cmp    $0x1,%edx
  80035e:	7e 0e                	jle    80036e <getint+0x16>
		return va_arg(*ap, long long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 08             	lea    0x8(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	8b 52 04             	mov    0x4(%edx),%edx
  80036c:	eb 1a                	jmp    800388 <getint+0x30>
	else if (lflag)
  80036e:	85 d2                	test   %edx,%edx
  800370:	74 0c                	je     80037e <getint+0x26>
		return va_arg(*ap, long);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	99                   	cltd   
  80037c:	eb 0a                	jmp    800388 <getint+0x30>
	else
		return va_arg(*ap, int);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 04             	lea    0x4(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	99                   	cltd   
}
  800388:	c9                   	leave  
  800389:	c3                   	ret    

0080038a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800390:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 08                	jae    8003a2 <sprintputch+0x18>
		*b->buf++ = ch;
  80039a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039d:	88 0a                	mov    %cl,(%edx)
  80039f:	42                   	inc    %edx
  8003a0:	89 10                	mov    %edx,(%eax)
}
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ad:	50                   	push   %eax
  8003ae:	ff 75 10             	pushl  0x10(%ebp)
  8003b1:	ff 75 0c             	pushl  0xc(%ebp)
  8003b4:	ff 75 08             	pushl  0x8(%ebp)
  8003b7:	e8 05 00 00 00       	call   8003c1 <vprintfmt>
	va_end(ap);
  8003bc:	83 c4 10             	add    $0x10,%esp
}
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	57                   	push   %edi
  8003c5:	56                   	push   %esi
  8003c6:	53                   	push   %ebx
  8003c7:	83 ec 2c             	sub    $0x2c,%esp
  8003ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003cd:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d0:	eb 13                	jmp    8003e5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d2:	85 c0                	test   %eax,%eax
  8003d4:	0f 84 6d 03 00 00    	je     800747 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	57                   	push   %edi
  8003de:	50                   	push   %eax
  8003df:	ff 55 08             	call   *0x8(%ebp)
  8003e2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	46                   	inc    %esi
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e4                	jne    8003d2 <vprintfmt+0x11>
  8003ee:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800400:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800407:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040c:	eb 28                	jmp    800436 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800414:	eb 20                	jmp    800436 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80041c:	eb 18                	jmp    800436 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800420:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800427:	eb 0d                	jmp    800436 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800429:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80042c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8a 06                	mov    (%esi),%al
  800438:	0f b6 d0             	movzbl %al,%edx
  80043b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80043e:	83 e8 23             	sub    $0x23,%eax
  800441:	3c 55                	cmp    $0x55,%al
  800443:	0f 87 e0 02 00 00    	ja     800729 <vprintfmt+0x368>
  800449:	0f b6 c0             	movzbl %al,%eax
  80044c:	ff 24 85 c4 0e 80 00 	jmp    *0x800ec4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800453:	83 ea 30             	sub    $0x30,%edx
  800456:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800459:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80045c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80045f:	83 fa 09             	cmp    $0x9,%edx
  800462:	77 44                	ja     8004a8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	89 de                	mov    %ebx,%esi
  800466:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800469:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80046a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80046d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800471:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800474:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800477:	83 fb 09             	cmp    $0x9,%ebx
  80047a:	76 ed                	jbe    800469 <vprintfmt+0xa8>
  80047c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80047f:	eb 29                	jmp    8004aa <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800491:	eb 17                	jmp    8004aa <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800493:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800497:	78 85                	js     80041e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	89 de                	mov    %ebx,%esi
  80049b:	eb 99                	jmp    800436 <vprintfmt+0x75>
  80049d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004a6:	eb 8e                	jmp    800436 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ae:	79 86                	jns    800436 <vprintfmt+0x75>
  8004b0:	e9 74 ff ff ff       	jmp    800429 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	89 de                	mov    %ebx,%esi
  8004b8:	e9 79 ff ff ff       	jmp    800436 <vprintfmt+0x75>
  8004bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	57                   	push   %edi
  8004cd:	ff 30                	pushl  (%eax)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d8:	e9 08 ff ff ff       	jmp    8003e5 <vprintfmt+0x24>
  8004dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	79 02                	jns    8004f1 <vprintfmt+0x130>
  8004ef:	f7 d8                	neg    %eax
  8004f1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 06             	cmp    $0x6,%eax
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x142>
  8004f8:	8b 04 85 1c 10 80 00 	mov    0x80101c(,%eax,4),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	75 1a                	jne    80051d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800503:	52                   	push   %edx
  800504:	68 4e 0e 80 00       	push   $0x800e4e
  800509:	57                   	push   %edi
  80050a:	ff 75 08             	pushl  0x8(%ebp)
  80050d:	e8 92 fe ff ff       	call   8003a4 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 c8 fe ff ff       	jmp    8003e5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	50                   	push   %eax
  80051e:	68 57 0e 80 00       	push   $0x800e57
  800523:	57                   	push   %edi
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 78 fe ff ff       	call   8003a4 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800532:	e9 ae fe ff ff       	jmp    8003e5 <vprintfmt+0x24>
  800537:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80053a:	89 de                	mov    %ebx,%esi
  80053c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800550:	85 c0                	test   %eax,%eax
  800552:	75 07                	jne    80055b <vprintfmt+0x19a>
				p = "(null)";
  800554:	c7 45 d0 47 0e 80 00 	movl   $0x800e47,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80055b:	85 db                	test   %ebx,%ebx
  80055d:	7e 42                	jle    8005a1 <vprintfmt+0x1e0>
  80055f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800563:	74 3c                	je     8005a1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	51                   	push   %ecx
  800569:	ff 75 d0             	pushl  -0x30(%ebp)
  80056c:	e8 6f 02 00 00       	call   8007e0 <strnlen>
  800571:	29 c3                	sub    %eax,%ebx
  800573:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	85 db                	test   %ebx,%ebx
  80057b:	7e 24                	jle    8005a1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80057d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800581:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800584:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	53                   	push   %ebx
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4e                   	dec    %esi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	85 f6                	test   %esi,%esi
  800595:	7f f0                	jg     800587 <vprintfmt+0x1c6>
  800597:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80059a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a4:	0f be 02             	movsbl (%edx),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	75 47                	jne    8005f2 <vprintfmt+0x231>
  8005ab:	eb 37                	jmp    8005e4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	74 16                	je     8005c9 <vprintfmt+0x208>
  8005b3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b6:	83 fa 5e             	cmp    $0x5e,%edx
  8005b9:	76 0e                	jbe    8005c9 <vprintfmt+0x208>
					putch('?', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	6a 3f                	push   $0x3f
  8005c1:	ff 55 08             	call   *0x8(%ebp)
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	eb 0b                	jmp    8005d4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	57                   	push   %edi
  8005cd:	50                   	push   %eax
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d7:	0f be 03             	movsbl (%ebx),%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	74 03                	je     8005e1 <vprintfmt+0x220>
  8005de:	43                   	inc    %ebx
  8005df:	eb 1b                	jmp    8005fc <vprintfmt+0x23b>
  8005e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e8:	7f 1e                	jg     800608 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ed:	e9 f3 fd ff ff       	jmp    8003e5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f5:	43                   	inc    %ebx
  8005f6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005fc:	85 f6                	test   %esi,%esi
  8005fe:	78 ad                	js     8005ad <vprintfmt+0x1ec>
  800600:	4e                   	dec    %esi
  800601:	79 aa                	jns    8005ad <vprintfmt+0x1ec>
  800603:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800606:	eb dc                	jmp    8005e4 <vprintfmt+0x223>
  800608:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 20                	push   $0x20
  800611:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800614:	4b                   	dec    %ebx
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	85 db                	test   %ebx,%ebx
  80061a:	7f ef                	jg     80060b <vprintfmt+0x24a>
  80061c:	e9 c4 fd ff ff       	jmp    8003e5 <vprintfmt+0x24>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 2a fd ff ff       	call   800358 <getint>
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800632:	85 d2                	test   %edx,%edx
  800634:	78 0a                	js     800640 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 b0 00 00 00       	jmp    8006f0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	57                   	push   %edi
  800644:	6a 2d                	push   $0x2d
  800646:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800649:	f7 db                	neg    %ebx
  80064b:	83 d6 00             	adc    $0x0,%esi
  80064e:	f7 de                	neg    %esi
  800650:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800653:	b8 0a 00 00 00       	mov    $0xa,%eax
  800658:	e9 93 00 00 00       	jmp    8006f0 <vprintfmt+0x32f>
  80065d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	89 ca                	mov    %ecx,%edx
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 b4 fc ff ff       	call   80031e <getuint>
  80066a:	89 c3                	mov    %eax,%ebx
  80066c:	89 d6                	mov    %edx,%esi
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 7b                	jmp    8006f0 <vprintfmt+0x32f>
  800675:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800678:	89 ca                	mov    %ecx,%edx
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 d6 fc ff ff       	call   800358 <getint>
  800682:	89 c3                	mov    %eax,%ebx
  800684:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800686:	85 d2                	test   %edx,%edx
  800688:	78 07                	js     800691 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
  80068f:	eb 5f                	jmp    8006f0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	57                   	push   %edi
  800695:	6a 2d                	push   $0x2d
  800697:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80069a:	f7 db                	neg    %ebx
  80069c:	83 d6 00             	adc    $0x0,%esi
  80069f:	f7 de                	neg    %esi
  8006a1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a9:	eb 45                	jmp    8006f0 <vprintfmt+0x32f>
  8006ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	57                   	push   %edi
  8006b2:	6a 30                	push   $0x30
  8006b4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	57                   	push   %edi
  8006bb:	6a 78                	push   $0x78
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c9:	8b 18                	mov    (%eax),%ebx
  8006cb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d8:	eb 16                	jmp    8006f0 <vprintfmt+0x32f>
  8006da:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	89 ca                	mov    %ecx,%edx
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	e8 37 fc ff ff       	call   80031e <getuint>
  8006e7:	89 c3                	mov    %eax,%ebx
  8006e9:	89 d6                	mov    %edx,%esi
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006f7:	52                   	push   %edx
  8006f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006fb:	50                   	push   %eax
  8006fc:	56                   	push   %esi
  8006fd:	53                   	push   %ebx
  8006fe:	89 fa                	mov    %edi,%edx
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	e8 68 fb ff ff       	call   800270 <printnum>
			break;
  800708:	83 c4 20             	add    $0x20,%esp
  80070b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80070e:	e9 d2 fc ff ff       	jmp    8003e5 <vprintfmt+0x24>
  800713:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	57                   	push   %edi
  80071a:	52                   	push   %edx
  80071b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80071e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800724:	e9 bc fc ff ff       	jmp    8003e5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	57                   	push   %edi
  80072d:	6a 25                	push   $0x25
  80072f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 02                	jmp    800739 <vprintfmt+0x378>
  800737:	89 c6                	mov    %eax,%esi
  800739:	8d 46 ff             	lea    -0x1(%esi),%eax
  80073c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800740:	75 f5                	jne    800737 <vprintfmt+0x376>
  800742:	e9 9e fc ff ff       	jmp    8003e5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800762:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800765:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	74 26                	je     800796 <vsnprintf+0x47>
  800770:	85 d2                	test   %edx,%edx
  800772:	7e 29                	jle    80079d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800774:	ff 75 14             	pushl  0x14(%ebp)
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	68 8a 03 80 00       	push   $0x80038a
  800783:	e8 39 fc ff ff       	call   8003c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 0c                	jmp    8007a2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079b:	eb 05                	jmp    8007a2 <vsnprintf+0x53>
  80079d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ad:	50                   	push   %eax
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	ff 75 08             	pushl  0x8(%ebp)
  8007b7:	e8 93 ff ff ff       	call   80074f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c9:	74 0e                	je     8007d9 <strlen+0x19>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d5:	75 f9                	jne    8007d0 <strlen+0x10>
  8007d7:	eb 05                	jmp    8007de <strlen+0x1e>
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 17                	je     800804 <strnlen+0x24>
  8007ed:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f0:	74 19                	je     80080b <strnlen+0x2b>
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f8:	39 d0                	cmp    %edx,%eax
  8007fa:	74 14                	je     800810 <strnlen+0x30>
  8007fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800800:	75 f5                	jne    8007f7 <strnlen+0x17>
  800802:	eb 0c                	jmp    800810 <strnlen+0x30>
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	eb 05                	jmp    800810 <strnlen+0x30>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081c:	ba 00 00 00 00       	mov    $0x0,%edx
  800821:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800824:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800827:	42                   	inc    %edx
  800828:	84 c9                	test   %cl,%cl
  80082a:	75 f5                	jne    800821 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 84 ff ff ff       	call   8007c0 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800845:	50                   	push   %eax
  800846:	e8 c7 ff ff ff       	call   800812 <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	85 f6                	test   %esi,%esi
  800862:	74 15                	je     800879 <strncpy+0x27>
  800864:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800869:	8a 1a                	mov    (%edx),%bl
  80086b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 3a 01             	cmpb   $0x1,(%edx)
  800871:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	41                   	inc    %ecx
  800875:	39 ce                	cmp    %ecx,%esi
  800877:	77 f0                	ja     800869 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 7d 08             	mov    0x8(%ebp),%edi
  800886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800889:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088c:	85 f6                	test   %esi,%esi
  80088e:	74 32                	je     8008c2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800890:	83 fe 01             	cmp    $0x1,%esi
  800893:	74 22                	je     8008b7 <strlcpy+0x3a>
  800895:	8a 0b                	mov    (%ebx),%cl
  800897:	84 c9                	test   %cl,%cl
  800899:	74 20                	je     8008bb <strlcpy+0x3e>
  80089b:	89 f8                	mov    %edi,%eax
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008a2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a5:	88 08                	mov    %cl,(%eax)
  8008a7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a8:	39 f2                	cmp    %esi,%edx
  8008aa:	74 11                	je     8008bd <strlcpy+0x40>
  8008ac:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008b0:	42                   	inc    %edx
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	75 f0                	jne    8008a5 <strlcpy+0x28>
  8008b5:	eb 06                	jmp    8008bd <strlcpy+0x40>
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	eb 02                	jmp    8008bd <strlcpy+0x40>
  8008bb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008bd:	c6 00 00             	movb   $0x0,(%eax)
  8008c0:	eb 02                	jmp    8008c4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008c4:	29 f8                	sub    %edi,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d4:	8a 01                	mov    (%ecx),%al
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 10                	je     8008ea <strcmp+0x1f>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	75 0c                	jne    8008ea <strcmp+0x1f>
		p++, q++;
  8008de:	41                   	inc    %ecx
  8008df:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e0:	8a 01                	mov    (%ecx),%al
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 04                	je     8008ea <strcmp+0x1f>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	74 f4                	je     8008de <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	0f b6 c0             	movzbl %al,%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	53                   	push   %ebx
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800901:	85 c0                	test   %eax,%eax
  800903:	74 1b                	je     800920 <strncmp+0x2c>
  800905:	8a 1a                	mov    (%edx),%bl
  800907:	84 db                	test   %bl,%bl
  800909:	74 24                	je     80092f <strncmp+0x3b>
  80090b:	3a 19                	cmp    (%ecx),%bl
  80090d:	75 20                	jne    80092f <strncmp+0x3b>
  80090f:	48                   	dec    %eax
  800910:	74 15                	je     800927 <strncmp+0x33>
		n--, p++, q++;
  800912:	42                   	inc    %edx
  800913:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800914:	8a 1a                	mov    (%edx),%bl
  800916:	84 db                	test   %bl,%bl
  800918:	74 15                	je     80092f <strncmp+0x3b>
  80091a:	3a 19                	cmp    (%ecx),%bl
  80091c:	74 f1                	je     80090f <strncmp+0x1b>
  80091e:	eb 0f                	jmp    80092f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	eb 05                	jmp    80092c <strncmp+0x38>
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092c:	5b                   	pop    %ebx
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092f:	0f b6 02             	movzbl (%edx),%eax
  800932:	0f b6 11             	movzbl (%ecx),%edx
  800935:	29 d0                	sub    %edx,%eax
  800937:	eb f3                	jmp    80092c <strncmp+0x38>

00800939 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	74 18                	je     800960 <strchr+0x27>
		if (*s == c)
  800948:	38 ca                	cmp    %cl,%dl
  80094a:	75 06                	jne    800952 <strchr+0x19>
  80094c:	eb 17                	jmp    800965 <strchr+0x2c>
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 13                	je     800965 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800952:	40                   	inc    %eax
  800953:	8a 10                	mov    (%eax),%dl
  800955:	84 d2                	test   %dl,%dl
  800957:	75 f5                	jne    80094e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
  80095e:	eb 05                	jmp    800965 <strchr+0x2c>
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800970:	8a 10                	mov    (%eax),%dl
  800972:	84 d2                	test   %dl,%dl
  800974:	74 11                	je     800987 <strfind+0x20>
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	75 06                	jne    800980 <strfind+0x19>
  80097a:	eb 0b                	jmp    800987 <strfind+0x20>
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 07                	je     800987 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800980:	40                   	inc    %eax
  800981:	8a 10                	mov    (%eax),%dl
  800983:	84 d2                	test   %dl,%dl
  800985:	75 f5                	jne    80097c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800998:	85 c9                	test   %ecx,%ecx
  80099a:	74 30                	je     8009cc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a2:	75 25                	jne    8009c9 <memset+0x40>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 20                	jne    8009c9 <memset+0x40>
		c &= 0xFF;
  8009a9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ac:	89 d3                	mov    %edx,%ebx
  8009ae:	c1 e3 08             	shl    $0x8,%ebx
  8009b1:	89 d6                	mov    %edx,%esi
  8009b3:	c1 e6 18             	shl    $0x18,%esi
  8009b6:	89 d0                	mov    %edx,%eax
  8009b8:	c1 e0 10             	shl    $0x10,%eax
  8009bb:	09 f0                	or     %esi,%eax
  8009bd:	09 d0                	or     %edx,%eax
  8009bf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c4:	fc                   	cld    
  8009c5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c7:	eb 03                	jmp    8009cc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c9:	fc                   	cld    
  8009ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e1:	39 c6                	cmp    %eax,%esi
  8009e3:	73 34                	jae    800a19 <memmove+0x46>
  8009e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e8:	39 d0                	cmp    %edx,%eax
  8009ea:	73 2d                	jae    800a19 <memmove+0x46>
		s += n;
		d += n;
  8009ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	75 1b                	jne    800a0f <memmove+0x3c>
  8009f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fa:	75 13                	jne    800a0f <memmove+0x3c>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 0e                	jne    800a0f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a01:	83 ef 04             	sub    $0x4,%edi
  800a04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb 07                	jmp    800a16 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0f:	4f                   	dec    %edi
  800a10:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a13:	fd                   	std    
  800a14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a16:	fc                   	cld    
  800a17:	eb 20                	jmp    800a39 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1f:	75 13                	jne    800a34 <memmove+0x61>
  800a21:	a8 03                	test   $0x3,%al
  800a23:	75 0f                	jne    800a34 <memmove+0x61>
  800a25:	f6 c1 03             	test   $0x3,%cl
  800a28:	75 0a                	jne    800a34 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a40:	ff 75 10             	pushl  0x10(%ebp)
  800a43:	ff 75 0c             	pushl  0xc(%ebp)
  800a46:	ff 75 08             	pushl  0x8(%ebp)
  800a49:	e8 85 ff ff ff       	call   8009d3 <memmove>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5f:	85 ff                	test   %edi,%edi
  800a61:	74 32                	je     800a95 <memcmp+0x45>
		if (*s1 != *s2)
  800a63:	8a 03                	mov    (%ebx),%al
  800a65:	8a 0e                	mov    (%esi),%cl
  800a67:	38 c8                	cmp    %cl,%al
  800a69:	74 19                	je     800a84 <memcmp+0x34>
  800a6b:	eb 0d                	jmp    800a7a <memcmp+0x2a>
  800a6d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a71:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a75:	42                   	inc    %edx
  800a76:	38 c8                	cmp    %cl,%al
  800a78:	74 10                	je     800a8a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a7a:	0f b6 c0             	movzbl %al,%eax
  800a7d:	0f b6 c9             	movzbl %cl,%ecx
  800a80:	29 c8                	sub    %ecx,%eax
  800a82:	eb 16                	jmp    800a9a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a84:	4f                   	dec    %edi
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	39 fa                	cmp    %edi,%edx
  800a8c:	75 df                	jne    800a6d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	eb 05                	jmp    800a9a <memcmp+0x4a>
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa5:	89 c2                	mov    %eax,%edx
  800aa7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aaa:	39 d0                	cmp    %edx,%eax
  800aac:	73 12                	jae    800ac0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aae:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ab1:	38 08                	cmp    %cl,(%eax)
  800ab3:	75 06                	jne    800abb <memfind+0x1c>
  800ab5:	eb 09                	jmp    800ac0 <memfind+0x21>
  800ab7:	38 08                	cmp    %cl,(%eax)
  800ab9:	74 05                	je     800ac0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abb:	40                   	inc    %eax
  800abc:	39 c2                	cmp    %eax,%edx
  800abe:	77 f7                	ja     800ab7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ace:	eb 01                	jmp    800ad1 <strtol+0xf>
		s++;
  800ad0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad1:	8a 02                	mov    (%edx),%al
  800ad3:	3c 20                	cmp    $0x20,%al
  800ad5:	74 f9                	je     800ad0 <strtol+0xe>
  800ad7:	3c 09                	cmp    $0x9,%al
  800ad9:	74 f5                	je     800ad0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adb:	3c 2b                	cmp    $0x2b,%al
  800add:	75 08                	jne    800ae7 <strtol+0x25>
		s++;
  800adf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae5:	eb 13                	jmp    800afa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae7:	3c 2d                	cmp    $0x2d,%al
  800ae9:	75 0a                	jne    800af5 <strtol+0x33>
		s++, neg = 1;
  800aeb:	8d 52 01             	lea    0x1(%edx),%edx
  800aee:	bf 01 00 00 00       	mov    $0x1,%edi
  800af3:	eb 05                	jmp    800afa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afa:	85 db                	test   %ebx,%ebx
  800afc:	74 05                	je     800b03 <strtol+0x41>
  800afe:	83 fb 10             	cmp    $0x10,%ebx
  800b01:	75 28                	jne    800b2b <strtol+0x69>
  800b03:	8a 02                	mov    (%edx),%al
  800b05:	3c 30                	cmp    $0x30,%al
  800b07:	75 10                	jne    800b19 <strtol+0x57>
  800b09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0d:	75 0a                	jne    800b19 <strtol+0x57>
		s += 2, base = 16;
  800b0f:	83 c2 02             	add    $0x2,%edx
  800b12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b17:	eb 12                	jmp    800b2b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	75 0e                	jne    800b2b <strtol+0x69>
  800b1d:	3c 30                	cmp    $0x30,%al
  800b1f:	75 05                	jne    800b26 <strtol+0x64>
		s++, base = 8;
  800b21:	42                   	inc    %edx
  800b22:	b3 08                	mov    $0x8,%bl
  800b24:	eb 05                	jmp    800b2b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b26:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b30:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b32:	8a 0a                	mov    (%edx),%cl
  800b34:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b37:	80 fb 09             	cmp    $0x9,%bl
  800b3a:	77 08                	ja     800b44 <strtol+0x82>
			dig = *s - '0';
  800b3c:	0f be c9             	movsbl %cl,%ecx
  800b3f:	83 e9 30             	sub    $0x30,%ecx
  800b42:	eb 1e                	jmp    800b62 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b44:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b47:	80 fb 19             	cmp    $0x19,%bl
  800b4a:	77 08                	ja     800b54 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b4c:	0f be c9             	movsbl %cl,%ecx
  800b4f:	83 e9 57             	sub    $0x57,%ecx
  800b52:	eb 0e                	jmp    800b62 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b57:	80 fb 19             	cmp    $0x19,%bl
  800b5a:	77 13                	ja     800b6f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b5c:	0f be c9             	movsbl %cl,%ecx
  800b5f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b62:	39 f1                	cmp    %esi,%ecx
  800b64:	7d 0d                	jge    800b73 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b66:	42                   	inc    %edx
  800b67:	0f af c6             	imul   %esi,%eax
  800b6a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b6d:	eb c3                	jmp    800b32 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b6f:	89 c1                	mov    %eax,%ecx
  800b71:	eb 02                	jmp    800b75 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b73:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b79:	74 05                	je     800b80 <strtol+0xbe>
		*endptr = (char *) s;
  800b7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b80:	85 ff                	test   %edi,%edi
  800b82:	74 04                	je     800b88 <strtol+0xc6>
  800b84:	89 c8                	mov    %ecx,%eax
  800b86:	f7 d8                	neg    %eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    
  800b8d:	00 00                	add    %al,(%eax)
	...

00800b90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	83 ec 10             	sub    $0x10,%esp
  800b98:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b9e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ba1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ba4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	75 2e                	jne    800bdc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bae:	39 f1                	cmp    %esi,%ecx
  800bb0:	77 5a                	ja     800c0c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bb2:	85 c9                	test   %ecx,%ecx
  800bb4:	75 0b                	jne    800bc1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbb:	31 d2                	xor    %edx,%edx
  800bbd:	f7 f1                	div    %ecx
  800bbf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bc1:	31 d2                	xor    %edx,%edx
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	f7 f1                	div    %ecx
  800bc7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bc9:	89 f8                	mov    %edi,%eax
  800bcb:	f7 f1                	div    %ecx
  800bcd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bcf:	89 f8                	mov    %edi,%eax
  800bd1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    
  800bda:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800bdc:	39 f0                	cmp    %esi,%eax
  800bde:	77 1c                	ja     800bfc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800be0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800be3:	83 f7 1f             	xor    $0x1f,%edi
  800be6:	75 3c                	jne    800c24 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800be8:	39 f0                	cmp    %esi,%eax
  800bea:	0f 82 90 00 00 00    	jb     800c80 <__udivdi3+0xf0>
  800bf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bf6:	0f 86 84 00 00 00    	jbe    800c80 <__udivdi3+0xf0>
  800bfc:	31 f6                	xor    %esi,%esi
  800bfe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c00:	89 f8                	mov    %edi,%eax
  800c02:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    
  800c0b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	89 f8                	mov    %edi,%eax
  800c10:	f7 f1                	div    %ecx
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c16:	89 f8                	mov    %edi,%eax
  800c18:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    
  800c21:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c24:	89 f9                	mov    %edi,%ecx
  800c26:	d3 e0                	shl    %cl,%eax
  800c28:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c2b:	b8 20 00 00 00       	mov    $0x20,%eax
  800c30:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c35:	88 c1                	mov    %al,%cl
  800c37:	d3 ea                	shr    %cl,%edx
  800c39:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c3c:	09 ca                	or     %ecx,%edx
  800c3e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c44:	89 f9                	mov    %edi,%ecx
  800c46:	d3 e2                	shl    %cl,%edx
  800c48:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c4b:	89 f2                	mov    %esi,%edx
  800c4d:	88 c1                	mov    %al,%cl
  800c4f:	d3 ea                	shr    %cl,%edx
  800c51:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c54:	89 f2                	mov    %esi,%edx
  800c56:	89 f9                	mov    %edi,%ecx
  800c58:	d3 e2                	shl    %cl,%edx
  800c5a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c5d:	88 c1                	mov    %al,%cl
  800c5f:	d3 ee                	shr    %cl,%esi
  800c61:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c63:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	89 ca                	mov    %ecx,%edx
  800c6a:	f7 75 ec             	divl   -0x14(%ebp)
  800c6d:	89 d1                	mov    %edx,%ecx
  800c6f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c71:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c74:	39 d1                	cmp    %edx,%ecx
  800c76:	72 28                	jb     800ca0 <__udivdi3+0x110>
  800c78:	74 1a                	je     800c94 <__udivdi3+0x104>
  800c7a:	89 f7                	mov    %esi,%edi
  800c7c:	31 f6                	xor    %esi,%esi
  800c7e:	eb 80                	jmp    800c00 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c80:	31 f6                	xor    %esi,%esi
  800c82:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c87:	89 f8                	mov    %edi,%eax
  800c89:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    
  800c92:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c97:	89 f9                	mov    %edi,%ecx
  800c99:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c9b:	39 c2                	cmp    %eax,%edx
  800c9d:	73 db                	jae    800c7a <__udivdi3+0xea>
  800c9f:	90                   	nop
		{
		  q0--;
  800ca0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ca3:	31 f6                	xor    %esi,%esi
  800ca5:	e9 56 ff ff ff       	jmp    800c00 <__udivdi3+0x70>
	...

00800cac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	83 ec 20             	sub    $0x20,%esp
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cc9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ccb:	85 ff                	test   %edi,%edi
  800ccd:	75 15                	jne    800ce4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800ccf:	39 f1                	cmp    %esi,%ecx
  800cd1:	0f 86 99 00 00 00    	jbe    800d70 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cd7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cd9:	89 d0                	mov    %edx,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800cdd:	83 c4 20             	add    $0x20,%esp
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ce4:	39 f7                	cmp    %esi,%edi
  800ce6:	0f 87 a4 00 00 00    	ja     800d90 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cec:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cef:	83 f0 1f             	xor    $0x1f,%eax
  800cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cf5:	0f 84 a1 00 00 00    	je     800d9c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cfb:	89 f8                	mov    %edi,%eax
  800cfd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d00:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d02:	bf 20 00 00 00       	mov    $0x20,%edi
  800d07:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d0d:	89 f9                	mov    %edi,%ecx
  800d0f:	d3 ea                	shr    %cl,%edx
  800d11:	09 c2                	or     %eax,%edx
  800d13:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d19:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d1c:	d3 e0                	shl    %cl,%eax
  800d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d21:	89 f2                	mov    %esi,%edx
  800d23:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d28:	d3 e0                	shl    %cl,%eax
  800d2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d30:	89 f9                	mov    %edi,%ecx
  800d32:	d3 e8                	shr    %cl,%eax
  800d34:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d36:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	f7 75 f0             	divl   -0x10(%ebp)
  800d3d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d3f:	f7 65 f4             	mull   -0xc(%ebp)
  800d42:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d45:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	72 71                	jb     800dbc <__umoddi3+0x110>
  800d4b:	74 7f                	je     800dcc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d50:	29 c8                	sub    %ecx,%eax
  800d52:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d54:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	89 f2                	mov    %esi,%edx
  800d5b:	89 f9                	mov    %edi,%ecx
  800d5d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d5f:	09 d0                	or     %edx,%eax
  800d61:	89 f2                	mov    %esi,%edx
  800d63:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d66:	d3 ea                	shr    %cl,%edx
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
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d70:	85 c9                	test   %ecx,%ecx
  800d72:	75 0b                	jne    800d7f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d74:	b8 01 00 00 00       	mov    $0x1,%eax
  800d79:	31 d2                	xor    %edx,%edx
  800d7b:	f7 f1                	div    %ecx
  800d7d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d7f:	89 f0                	mov    %esi,%eax
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	e9 4a ff ff ff       	jmp    800cd9 <__umoddi3+0x2d>
  800d8f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d90:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d92:	83 c4 20             	add    $0x20,%esp
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    
  800d99:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d9c:	39 f7                	cmp    %esi,%edi
  800d9e:	72 05                	jb     800da5 <__umoddi3+0xf9>
  800da0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800da3:	77 0c                	ja     800db1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da5:	89 f2                	mov    %esi,%edx
  800da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800daa:	29 c8                	sub    %ecx,%eax
  800dac:	19 fa                	sbb    %edi,%edx
  800dae:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800db4:	83 c4 20             	add    $0x20,%esp
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	c9                   	leave  
  800dba:	c3                   	ret    
  800dbb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dbc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dc4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dc7:	eb 84                	jmp    800d4d <__umoddi3+0xa1>
  800dc9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dcc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dcf:	72 eb                	jb     800dbc <__umoddi3+0x110>
  800dd1:	89 f2                	mov    %esi,%edx
  800dd3:	e9 75 ff ff ff       	jmp    800d4d <__umoddi3+0xa1>
