
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 b3 00 00 00       	call   8000f9 <sys_cputs>
  800046:	83 c4 10             	add    $0x10,%esp
}
  800049:	c9                   	leave  
  80004a:	c3                   	ret    
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800057:	e8 09 01 00 00       	call   800165 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800064:	c1 e0 05             	shl    $0x5,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 07                	jle    80007c <libmain+0x30>
		binaryname = argv[0];
  800075:	8b 03                	mov    (%ebx),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	56                   	push   %esi
  800081:	e8 ae ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800086:	e8 0d 00 00 00       	call   800098 <exit>
  80008b:	83 c4 10             	add    $0x10,%esp
}
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 9e 00 00 00       	call   800143 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 1c             	sub    $0x1c,%esp
  8000b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8000bb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c9:	cd 30                	int    $0x30
  8000cb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000d1:	74 1c                	je     8000ef <syscall+0x43>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7e 18                	jle    8000ef <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000de:	68 ea 0d 80 00       	push   $0x800dea
  8000e3:	6a 42                	push   $0x42
  8000e5:	68 07 0e 80 00       	push   $0x800e07
  8000ea:	e8 9d 00 00 00       	call   80018c <_panic>

	return ret;
}
  8000ef:	89 d0                	mov    %edx,%eax
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000ff:	6a 00                	push   $0x0
  800101:	6a 00                	push   $0x0
  800103:	6a 00                	push   $0x0
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010b:	ba 00 00 00 00       	mov    $0x0,%edx
  800110:	b8 00 00 00 00       	mov    $0x0,%eax
  800115:	e8 92 ff ff ff       	call   8000ac <syscall>
  80011a:	83 c4 10             	add    $0x10,%esp
	return;
}
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <sys_cgetc>:

int
sys_cgetc(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 01 00 00 00       	mov    $0x1,%eax
  80013c:	e8 6b ff ff ff       	call   8000ac <syscall>
}
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800154:	ba 01 00 00 00       	mov    $0x1,%edx
  800159:	b8 03 00 00 00       	mov    $0x3,%eax
  80015e:	e8 49 ff ff ff       	call   8000ac <syscall>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	6a 00                	push   $0x0
  800173:	b9 00 00 00 00       	mov    $0x0,%ecx
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	e8 25 ff ff ff       	call   8000ac <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800191:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800194:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80019a:	e8 c6 ff ff ff       	call   800165 <sys_getenvid>
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 0c             	pushl  0xc(%ebp)
  8001a5:	ff 75 08             	pushl  0x8(%ebp)
  8001a8:	53                   	push   %ebx
  8001a9:	50                   	push   %eax
  8001aa:	68 18 0e 80 00       	push   $0x800e18
  8001af:	e8 b0 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 10             	pushl  0x10(%ebp)
  8001bb:	e8 53 00 00 00       	call   800213 <vcprintf>
	cprintf("\n");
  8001c0:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  8001c7:	e8 98 00 00 00       	call   800264 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x43>
	...

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001de:	8b 03                	mov    (%ebx),%eax
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e7:	40                   	inc    %eax
  8001e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ef:	75 1a                	jne    80020b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 f7 fe ff ff       	call   8000f9 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800208:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020b:	ff 43 04             	incl   0x4(%ebx)
}
  80020e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	50                   	push   %eax
  80023d:	68 d4 01 80 00       	push   $0x8001d4
  800242:	e8 82 01 00 00       	call   8003c9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 9d fe ff ff       	call   8000f9 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	50                   	push   %eax
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 9d ff ff ff       	call   800213 <vcprintf>
	va_end(ap);

	return cnt;
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800284:	89 d6                	mov    %edx,%esi
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800292:	8b 45 10             	mov    0x10(%ebp),%eax
  800295:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800298:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002a8:	72 0c                	jb     8002b6 <printnum+0x3e>
  8002aa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002ad:	76 07                	jbe    8002b6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002af:	4b                   	dec    %ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f 31                	jg     8002e5 <printnum+0x6d>
  8002b4:	eb 3f                	jmp    8002f5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	57                   	push   %edi
  8002ba:	4b                   	dec    %ebx
  8002bb:	53                   	push   %ebx
  8002bc:	50                   	push   %eax
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 c7 08 00 00       	call   800b98 <__udivdi3>
  8002d1:	83 c4 18             	add    $0x18,%esp
  8002d4:	52                   	push   %edx
  8002d5:	50                   	push   %eax
  8002d6:	89 f2                	mov    %esi,%edx
  8002d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002db:	e8 98 ff ff ff       	call   800278 <printnum>
  8002e0:	83 c4 20             	add    $0x20,%esp
  8002e3:	eb 10                	jmp    8002f5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	57                   	push   %edi
  8002ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ed:	4b                   	dec    %ebx
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	7f f0                	jg     8002e5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	56                   	push   %esi
  8002f9:	83 ec 04             	sub    $0x4,%esp
  8002fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800302:	ff 75 dc             	pushl  -0x24(%ebp)
  800305:	ff 75 d8             	pushl  -0x28(%ebp)
  800308:	e8 a7 09 00 00       	call   800cb4 <__umoddi3>
  80030d:	83 c4 14             	add    $0x14,%esp
  800310:	0f be 80 3e 0e 80 00 	movsbl 0x800e3e(%eax),%eax
  800317:	50                   	push   %eax
  800318:	ff 55 e4             	call   *-0x1c(%ebp)
  80031b:	83 c4 10             	add    $0x10,%esp
}
  80031e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800363:	83 fa 01             	cmp    $0x1,%edx
  800366:	7e 0e                	jle    800376 <getint+0x16>
		return va_arg(*ap, long long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	8b 52 04             	mov    0x4(%edx),%edx
  800374:	eb 1a                	jmp    800390 <getint+0x30>
	else if (lflag)
  800376:	85 d2                	test   %edx,%edx
  800378:	74 0c                	je     800386 <getint+0x26>
		return va_arg(*ap, long);
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 02                	mov    (%edx),%eax
  800383:	99                   	cltd   
  800384:	eb 0a                	jmp    800390 <getint+0x30>
	else
		return va_arg(*ap, int);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	99                   	cltd   
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800398:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a0:	73 08                	jae    8003aa <sprintputch+0x18>
		*b->buf++ = ch;
  8003a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a5:	88 0a                	mov    %cl,(%edx)
  8003a7:	42                   	inc    %edx
  8003a8:	89 10                	mov    %edx,(%eax)
}
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b5:	50                   	push   %eax
  8003b6:	ff 75 10             	pushl  0x10(%ebp)
  8003b9:	ff 75 0c             	pushl  0xc(%ebp)
  8003bc:	ff 75 08             	pushl  0x8(%ebp)
  8003bf:	e8 05 00 00 00       	call   8003c9 <vprintfmt>
	va_end(ap);
  8003c4:	83 c4 10             	add    $0x10,%esp
}
  8003c7:	c9                   	leave  
  8003c8:	c3                   	ret    

008003c9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	57                   	push   %edi
  8003cd:	56                   	push   %esi
  8003ce:	53                   	push   %ebx
  8003cf:	83 ec 2c             	sub    $0x2c,%esp
  8003d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d5:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d8:	eb 13                	jmp    8003ed <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	0f 84 6d 03 00 00    	je     80074f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003e2:	83 ec 08             	sub    $0x8,%esp
  8003e5:	57                   	push   %edi
  8003e6:	50                   	push   %eax
  8003e7:	ff 55 08             	call   *0x8(%ebp)
  8003ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e4                	jne    8003da <vprintfmt+0x11>
  8003f6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800401:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800408:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800414:	eb 28                	jmp    80043e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80041c:	eb 20                	jmp    80043e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800424:	eb 18                	jmp    80043e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800428:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042f:	eb 0d                	jmp    80043e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800437:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8a 06                	mov    (%esi),%al
  800440:	0f b6 d0             	movzbl %al,%edx
  800443:	8d 5e 01             	lea    0x1(%esi),%ebx
  800446:	83 e8 23             	sub    $0x23,%eax
  800449:	3c 55                	cmp    $0x55,%al
  80044b:	0f 87 e0 02 00 00    	ja     800731 <vprintfmt+0x368>
  800451:	0f b6 c0             	movzbl %al,%eax
  800454:	ff 24 85 cc 0e 80 00 	jmp    *0x800ecc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	83 ea 30             	sub    $0x30,%edx
  80045e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800461:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800464:	8d 50 d0             	lea    -0x30(%eax),%edx
  800467:	83 fa 09             	cmp    $0x9,%edx
  80046a:	77 44                	ja     8004b0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	89 de                	mov    %ebx,%esi
  80046e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800472:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800475:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800479:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80047c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047f:	83 fb 09             	cmp    $0x9,%ebx
  800482:	76 ed                	jbe    800471 <vprintfmt+0xa8>
  800484:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800487:	eb 29                	jmp    8004b2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800499:	eb 17                	jmp    8004b2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80049b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049f:	78 85                	js     800426 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	89 de                	mov    %ebx,%esi
  8004a3:	eb 99                	jmp    80043e <vprintfmt+0x75>
  8004a5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ae:	eb 8e                	jmp    80043e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	79 86                	jns    80043e <vprintfmt+0x75>
  8004b8:	e9 74 ff ff ff       	jmp    800431 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	89 de                	mov    %ebx,%esi
  8004c0:	e9 79 ff ff ff       	jmp    80043e <vprintfmt+0x75>
  8004c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	57                   	push   %edi
  8004d5:	ff 30                	pushl  (%eax)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 08 ff ff ff       	jmp    8003ed <vprintfmt+0x24>
  8004e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	79 02                	jns    8004f9 <vprintfmt+0x130>
  8004f7:	f7 d8                	neg    %eax
  8004f9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fb:	83 f8 06             	cmp    $0x6,%eax
  8004fe:	7f 0b                	jg     80050b <vprintfmt+0x142>
  800500:	8b 04 85 24 10 80 00 	mov    0x801024(,%eax,4),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	75 1a                	jne    800525 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80050b:	52                   	push   %edx
  80050c:	68 56 0e 80 00       	push   $0x800e56
  800511:	57                   	push   %edi
  800512:	ff 75 08             	pushl  0x8(%ebp)
  800515:	e8 92 fe ff ff       	call   8003ac <printfmt>
  80051a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800520:	e9 c8 fe ff ff       	jmp    8003ed <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800525:	50                   	push   %eax
  800526:	68 5f 0e 80 00       	push   $0x800e5f
  80052b:	57                   	push   %edi
  80052c:	ff 75 08             	pushl  0x8(%ebp)
  80052f:	e8 78 fe ff ff       	call   8003ac <printfmt>
  800534:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80053a:	e9 ae fe ff ff       	jmp    8003ed <vprintfmt+0x24>
  80053f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800542:	89 de                	mov    %ebx,%esi
  800544:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800547:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800558:	85 c0                	test   %eax,%eax
  80055a:	75 07                	jne    800563 <vprintfmt+0x19a>
				p = "(null)";
  80055c:	c7 45 d0 4f 0e 80 00 	movl   $0x800e4f,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800563:	85 db                	test   %ebx,%ebx
  800565:	7e 42                	jle    8005a9 <vprintfmt+0x1e0>
  800567:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80056b:	74 3c                	je     8005a9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	51                   	push   %ecx
  800571:	ff 75 d0             	pushl  -0x30(%ebp)
  800574:	e8 6f 02 00 00       	call   8007e8 <strnlen>
  800579:	29 c3                	sub    %eax,%ebx
  80057b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	85 db                	test   %ebx,%ebx
  800583:	7e 24                	jle    8005a9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800585:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800589:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80058c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	57                   	push   %edi
  800593:	53                   	push   %ebx
  800594:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	4e                   	dec    %esi
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	85 f6                	test   %esi,%esi
  80059d:	7f f0                	jg     80058f <vprintfmt+0x1c6>
  80059f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ac:	0f be 02             	movsbl (%edx),%eax
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	75 47                	jne    8005fa <vprintfmt+0x231>
  8005b3:	eb 37                	jmp    8005ec <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b9:	74 16                	je     8005d1 <vprintfmt+0x208>
  8005bb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005be:	83 fa 5e             	cmp    $0x5e,%edx
  8005c1:	76 0e                	jbe    8005d1 <vprintfmt+0x208>
					putch('?', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 3f                	push   $0x3f
  8005c9:	ff 55 08             	call   *0x8(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	eb 0b                	jmp    8005dc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	ff 55 08             	call   *0x8(%ebp)
  8005d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dc:	ff 4d e4             	decl   -0x1c(%ebp)
  8005df:	0f be 03             	movsbl (%ebx),%eax
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	74 03                	je     8005e9 <vprintfmt+0x220>
  8005e6:	43                   	inc    %ebx
  8005e7:	eb 1b                	jmp    800604 <vprintfmt+0x23b>
  8005e9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f0:	7f 1e                	jg     800610 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f5:	e9 f3 fd ff ff       	jmp    8003ed <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005fd:	43                   	inc    %ebx
  8005fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800601:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800604:	85 f6                	test   %esi,%esi
  800606:	78 ad                	js     8005b5 <vprintfmt+0x1ec>
  800608:	4e                   	dec    %esi
  800609:	79 aa                	jns    8005b5 <vprintfmt+0x1ec>
  80060b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80060e:	eb dc                	jmp    8005ec <vprintfmt+0x223>
  800610:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	57                   	push   %edi
  800617:	6a 20                	push   $0x20
  800619:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061c:	4b                   	dec    %ebx
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	85 db                	test   %ebx,%ebx
  800622:	7f ef                	jg     800613 <vprintfmt+0x24a>
  800624:	e9 c4 fd ff ff       	jmp    8003ed <vprintfmt+0x24>
  800629:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 2a fd ff ff       	call   800360 <getint>
  800636:	89 c3                	mov    %eax,%ebx
  800638:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80063a:	85 d2                	test   %edx,%edx
  80063c:	78 0a                	js     800648 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 b0 00 00 00       	jmp    8006f8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	57                   	push   %edi
  80064c:	6a 2d                	push   $0x2d
  80064e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800651:	f7 db                	neg    %ebx
  800653:	83 d6 00             	adc    $0x0,%esi
  800656:	f7 de                	neg    %esi
  800658:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800660:	e9 93 00 00 00       	jmp    8006f8 <vprintfmt+0x32f>
  800665:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	89 ca                	mov    %ecx,%edx
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 b4 fc ff ff       	call   800326 <getuint>
  800672:	89 c3                	mov    %eax,%ebx
  800674:	89 d6                	mov    %edx,%esi
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067b:	eb 7b                	jmp    8006f8 <vprintfmt+0x32f>
  80067d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 d6 fc ff ff       	call   800360 <getint>
  80068a:	89 c3                	mov    %eax,%ebx
  80068c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80068e:	85 d2                	test   %edx,%edx
  800690:	78 07                	js     800699 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800692:	b8 08 00 00 00       	mov    $0x8,%eax
  800697:	eb 5f                	jmp    8006f8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	57                   	push   %edi
  80069d:	6a 2d                	push   $0x2d
  80069f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006a2:	f7 db                	neg    %ebx
  8006a4:	83 d6 00             	adc    $0x0,%esi
  8006a7:	f7 de                	neg    %esi
  8006a9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 45                	jmp    8006f8 <vprintfmt+0x32f>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	57                   	push   %edi
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bf:	83 c4 08             	add    $0x8,%esp
  8006c2:	57                   	push   %edi
  8006c3:	6a 78                	push   $0x78
  8006c5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d1:	8b 18                	mov    (%eax),%ebx
  8006d3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e0:	eb 16                	jmp    8006f8 <vprintfmt+0x32f>
  8006e2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 37 fc ff ff       	call   800326 <getuint>
  8006ef:	89 c3                	mov    %eax,%ebx
  8006f1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ff:	52                   	push   %edx
  800700:	ff 75 e4             	pushl  -0x1c(%ebp)
  800703:	50                   	push   %eax
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	89 fa                	mov    %edi,%edx
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	e8 68 fb ff ff       	call   800278 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800716:	e9 d2 fc ff ff       	jmp    8003ed <vprintfmt+0x24>
  80071b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	57                   	push   %edi
  800722:	52                   	push   %edx
  800723:	ff 55 08             	call   *0x8(%ebp)
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 bc fc ff ff       	jmp    8003ed <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	57                   	push   %edi
  800735:	6a 25                	push   $0x25
  800737:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 02                	jmp    800741 <vprintfmt+0x378>
  80073f:	89 c6                	mov    %eax,%esi
  800741:	8d 46 ff             	lea    -0x1(%esi),%eax
  800744:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800748:	75 f5                	jne    80073f <vprintfmt+0x376>
  80074a:	e9 9e fc ff ff       	jmp    8003ed <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	83 ec 18             	sub    $0x18,%esp
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800763:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800766:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800774:	85 c0                	test   %eax,%eax
  800776:	74 26                	je     80079e <vsnprintf+0x47>
  800778:	85 d2                	test   %edx,%edx
  80077a:	7e 29                	jle    8007a5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077c:	ff 75 14             	pushl  0x14(%ebp)
  80077f:	ff 75 10             	pushl  0x10(%ebp)
  800782:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800785:	50                   	push   %eax
  800786:	68 92 03 80 00       	push   $0x800392
  80078b:	e8 39 fc ff ff       	call   8003c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	eb 0c                	jmp    8007aa <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a3:	eb 05                	jmp    8007aa <vsnprintf+0x53>
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	ff 75 08             	pushl  0x8(%ebp)
  8007bf:	e8 93 ff ff ff       	call   800757 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	80 3a 00             	cmpb   $0x0,(%edx)
  8007d1:	74 0e                	je     8007e1 <strlen+0x19>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007dd:	75 f9                	jne    8007d8 <strlen+0x10>
  8007df:	eb 05                	jmp    8007e6 <strlen+0x1e>
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 17                	je     80080c <strnlen+0x24>
  8007f5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f8:	74 19                	je     800813 <strnlen+0x2b>
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ff:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800800:	39 d0                	cmp    %edx,%eax
  800802:	74 14                	je     800818 <strnlen+0x30>
  800804:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800808:	75 f5                	jne    8007ff <strnlen+0x17>
  80080a:	eb 0c                	jmp    800818 <strnlen+0x30>
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	eb 05                	jmp    800818 <strnlen+0x30>
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
  800829:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082f:	42                   	inc    %edx
  800830:	84 c9                	test   %cl,%cl
  800832:	75 f5                	jne    800829 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 84 ff ff ff       	call   8007c8 <strlen>
  800844:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80084d:	50                   	push   %eax
  80084e:	e8 c7 ff ff ff       	call   80081a <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800868:	85 f6                	test   %esi,%esi
  80086a:	74 15                	je     800881 <strncpy+0x27>
  80086c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800871:	8a 1a                	mov    (%edx),%bl
  800873:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800876:	80 3a 01             	cmpb   $0x1,(%edx)
  800879:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	41                   	inc    %ecx
  80087d:	39 ce                	cmp    %ecx,%esi
  80087f:	77 f0                	ja     800871 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	57                   	push   %edi
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800891:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	85 f6                	test   %esi,%esi
  800896:	74 32                	je     8008ca <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800898:	83 fe 01             	cmp    $0x1,%esi
  80089b:	74 22                	je     8008bf <strlcpy+0x3a>
  80089d:	8a 0b                	mov    (%ebx),%cl
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 20                	je     8008c3 <strlcpy+0x3e>
  8008a3:	89 f8                	mov    %edi,%eax
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008aa:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	88 08                	mov    %cl,(%eax)
  8008af:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b0:	39 f2                	cmp    %esi,%edx
  8008b2:	74 11                	je     8008c5 <strlcpy+0x40>
  8008b4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008b8:	42                   	inc    %edx
  8008b9:	84 c9                	test   %cl,%cl
  8008bb:	75 f0                	jne    8008ad <strlcpy+0x28>
  8008bd:	eb 06                	jmp    8008c5 <strlcpy+0x40>
  8008bf:	89 f8                	mov    %edi,%eax
  8008c1:	eb 02                	jmp    8008c5 <strlcpy+0x40>
  8008c3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c5:	c6 00 00             	movb   $0x0,(%eax)
  8008c8:	eb 02                	jmp    8008cc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ca:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008cc:	29 f8                	sub    %edi,%eax
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5f                   	pop    %edi
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dc:	8a 01                	mov    (%ecx),%al
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 10                	je     8008f2 <strcmp+0x1f>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	75 0c                	jne    8008f2 <strcmp+0x1f>
		p++, q++;
  8008e6:	41                   	inc    %ecx
  8008e7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e8:	8a 01                	mov    (%ecx),%al
  8008ea:	84 c0                	test   %al,%al
  8008ec:	74 04                	je     8008f2 <strcmp+0x1f>
  8008ee:	3a 02                	cmp    (%edx),%al
  8008f0:	74 f4                	je     8008e6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f2:	0f b6 c0             	movzbl %al,%eax
  8008f5:	0f b6 12             	movzbl (%edx),%edx
  8008f8:	29 d0                	sub    %edx,%eax
}
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 55 08             	mov    0x8(%ebp),%edx
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800909:	85 c0                	test   %eax,%eax
  80090b:	74 1b                	je     800928 <strncmp+0x2c>
  80090d:	8a 1a                	mov    (%edx),%bl
  80090f:	84 db                	test   %bl,%bl
  800911:	74 24                	je     800937 <strncmp+0x3b>
  800913:	3a 19                	cmp    (%ecx),%bl
  800915:	75 20                	jne    800937 <strncmp+0x3b>
  800917:	48                   	dec    %eax
  800918:	74 15                	je     80092f <strncmp+0x33>
		n--, p++, q++;
  80091a:	42                   	inc    %edx
  80091b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091c:	8a 1a                	mov    (%edx),%bl
  80091e:	84 db                	test   %bl,%bl
  800920:	74 15                	je     800937 <strncmp+0x3b>
  800922:	3a 19                	cmp    (%ecx),%bl
  800924:	74 f1                	je     800917 <strncmp+0x1b>
  800926:	eb 0f                	jmp    800937 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 05                	jmp    800934 <strncmp+0x38>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800934:	5b                   	pop    %ebx
  800935:	c9                   	leave  
  800936:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800937:	0f b6 02             	movzbl (%edx),%eax
  80093a:	0f b6 11             	movzbl (%ecx),%edx
  80093d:	29 d0                	sub    %edx,%eax
  80093f:	eb f3                	jmp    800934 <strncmp+0x38>

00800941 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094a:	8a 10                	mov    (%eax),%dl
  80094c:	84 d2                	test   %dl,%dl
  80094e:	74 18                	je     800968 <strchr+0x27>
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	75 06                	jne    80095a <strchr+0x19>
  800954:	eb 17                	jmp    80096d <strchr+0x2c>
  800956:	38 ca                	cmp    %cl,%dl
  800958:	74 13                	je     80096d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	40                   	inc    %eax
  80095b:	8a 10                	mov    (%eax),%dl
  80095d:	84 d2                	test   %dl,%dl
  80095f:	75 f5                	jne    800956 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
  800966:	eb 05                	jmp    80096d <strchr+0x2c>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800978:	8a 10                	mov    (%eax),%dl
  80097a:	84 d2                	test   %dl,%dl
  80097c:	74 11                	je     80098f <strfind+0x20>
		if (*s == c)
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	75 06                	jne    800988 <strfind+0x19>
  800982:	eb 0b                	jmp    80098f <strfind+0x20>
  800984:	38 ca                	cmp    %cl,%dl
  800986:	74 07                	je     80098f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800988:	40                   	inc    %eax
  800989:	8a 10                	mov    (%eax),%dl
  80098b:	84 d2                	test   %dl,%dl
  80098d:	75 f5                	jne    800984 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 30                	je     8009d4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 25                	jne    8009d1 <memset+0x40>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 20                	jne    8009d1 <memset+0x40>
		c &= 0xFF;
  8009b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b4:	89 d3                	mov    %edx,%ebx
  8009b6:	c1 e3 08             	shl    $0x8,%ebx
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	c1 e6 18             	shl    $0x18,%esi
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	c1 e0 10             	shl    $0x10,%eax
  8009c3:	09 f0                	or     %esi,%eax
  8009c5:	09 d0                	or     %edx,%eax
  8009c7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009cc:	fc                   	cld    
  8009cd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cf:	eb 03                	jmp    8009d4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d1:	fc                   	cld    
  8009d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e9:	39 c6                	cmp    %eax,%esi
  8009eb:	73 34                	jae    800a21 <memmove+0x46>
  8009ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f0:	39 d0                	cmp    %edx,%eax
  8009f2:	73 2d                	jae    800a21 <memmove+0x46>
		s += n;
		d += n;
  8009f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	f6 c2 03             	test   $0x3,%dl
  8009fa:	75 1b                	jne    800a17 <memmove+0x3c>
  8009fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a02:	75 13                	jne    800a17 <memmove+0x3c>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 0e                	jne    800a17 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a09:	83 ef 04             	sub    $0x4,%edi
  800a0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a12:	fd                   	std    
  800a13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a15:	eb 07                	jmp    800a1e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a17:	4f                   	dec    %edi
  800a18:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1b:	fd                   	std    
  800a1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1e:	fc                   	cld    
  800a1f:	eb 20                	jmp    800a41 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a27:	75 13                	jne    800a3c <memmove+0x61>
  800a29:	a8 03                	test   $0x3,%al
  800a2b:	75 0f                	jne    800a3c <memmove+0x61>
  800a2d:	f6 c1 03             	test   $0x3,%cl
  800a30:	75 0a                	jne    800a3c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a32:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb 05                	jmp    800a41 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a48:	ff 75 10             	pushl  0x10(%ebp)
  800a4b:	ff 75 0c             	pushl  0xc(%ebp)
  800a4e:	ff 75 08             	pushl  0x8(%ebp)
  800a51:	e8 85 ff ff ff       	call   8009db <memmove>
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a64:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a67:	85 ff                	test   %edi,%edi
  800a69:	74 32                	je     800a9d <memcmp+0x45>
		if (*s1 != *s2)
  800a6b:	8a 03                	mov    (%ebx),%al
  800a6d:	8a 0e                	mov    (%esi),%cl
  800a6f:	38 c8                	cmp    %cl,%al
  800a71:	74 19                	je     800a8c <memcmp+0x34>
  800a73:	eb 0d                	jmp    800a82 <memcmp+0x2a>
  800a75:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a79:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a7d:	42                   	inc    %edx
  800a7e:	38 c8                	cmp    %cl,%al
  800a80:	74 10                	je     800a92 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c0             	movzbl %al,%eax
  800a85:	0f b6 c9             	movzbl %cl,%ecx
  800a88:	29 c8                	sub    %ecx,%eax
  800a8a:	eb 16                	jmp    800aa2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8c:	4f                   	dec    %edi
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	39 fa                	cmp    %edi,%edx
  800a94:	75 df                	jne    800a75 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	eb 05                	jmp    800aa2 <memcmp+0x4a>
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab2:	39 d0                	cmp    %edx,%eax
  800ab4:	73 12                	jae    800ac8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ab9:	38 08                	cmp    %cl,(%eax)
  800abb:	75 06                	jne    800ac3 <memfind+0x1c>
  800abd:	eb 09                	jmp    800ac8 <memfind+0x21>
  800abf:	38 08                	cmp    %cl,(%eax)
  800ac1:	74 05                	je     800ac8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac3:	40                   	inc    %eax
  800ac4:	39 c2                	cmp    %eax,%edx
  800ac6:	77 f7                	ja     800abf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad6:	eb 01                	jmp    800ad9 <strtol+0xf>
		s++;
  800ad8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad9:	8a 02                	mov    (%edx),%al
  800adb:	3c 20                	cmp    $0x20,%al
  800add:	74 f9                	je     800ad8 <strtol+0xe>
  800adf:	3c 09                	cmp    $0x9,%al
  800ae1:	74 f5                	je     800ad8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae3:	3c 2b                	cmp    $0x2b,%al
  800ae5:	75 08                	jne    800aef <strtol+0x25>
		s++;
  800ae7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aed:	eb 13                	jmp    800b02 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aef:	3c 2d                	cmp    $0x2d,%al
  800af1:	75 0a                	jne    800afd <strtol+0x33>
		s++, neg = 1;
  800af3:	8d 52 01             	lea    0x1(%edx),%edx
  800af6:	bf 01 00 00 00       	mov    $0x1,%edi
  800afb:	eb 05                	jmp    800b02 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	74 05                	je     800b0b <strtol+0x41>
  800b06:	83 fb 10             	cmp    $0x10,%ebx
  800b09:	75 28                	jne    800b33 <strtol+0x69>
  800b0b:	8a 02                	mov    (%edx),%al
  800b0d:	3c 30                	cmp    $0x30,%al
  800b0f:	75 10                	jne    800b21 <strtol+0x57>
  800b11:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b15:	75 0a                	jne    800b21 <strtol+0x57>
		s += 2, base = 16;
  800b17:	83 c2 02             	add    $0x2,%edx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb 12                	jmp    800b33 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b21:	85 db                	test   %ebx,%ebx
  800b23:	75 0e                	jne    800b33 <strtol+0x69>
  800b25:	3c 30                	cmp    $0x30,%al
  800b27:	75 05                	jne    800b2e <strtol+0x64>
		s++, base = 8;
  800b29:	42                   	inc    %edx
  800b2a:	b3 08                	mov    $0x8,%bl
  800b2c:	eb 05                	jmp    800b33 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b2e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
  800b38:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3a:	8a 0a                	mov    (%edx),%cl
  800b3c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b3f:	80 fb 09             	cmp    $0x9,%bl
  800b42:	77 08                	ja     800b4c <strtol+0x82>
			dig = *s - '0';
  800b44:	0f be c9             	movsbl %cl,%ecx
  800b47:	83 e9 30             	sub    $0x30,%ecx
  800b4a:	eb 1e                	jmp    800b6a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b4c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b4f:	80 fb 19             	cmp    $0x19,%bl
  800b52:	77 08                	ja     800b5c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b54:	0f be c9             	movsbl %cl,%ecx
  800b57:	83 e9 57             	sub    $0x57,%ecx
  800b5a:	eb 0e                	jmp    800b6a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b5f:	80 fb 19             	cmp    $0x19,%bl
  800b62:	77 13                	ja     800b77 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b64:	0f be c9             	movsbl %cl,%ecx
  800b67:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6a:	39 f1                	cmp    %esi,%ecx
  800b6c:	7d 0d                	jge    800b7b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b6e:	42                   	inc    %edx
  800b6f:	0f af c6             	imul   %esi,%eax
  800b72:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b75:	eb c3                	jmp    800b3a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b77:	89 c1                	mov    %eax,%ecx
  800b79:	eb 02                	jmp    800b7d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b81:	74 05                	je     800b88 <strtol+0xbe>
		*endptr = (char *) s;
  800b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b86:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b88:	85 ff                	test   %edi,%edi
  800b8a:	74 04                	je     800b90 <strtol+0xc6>
  800b8c:	89 c8                	mov    %ecx,%eax
  800b8e:	f7 d8                	neg    %eax
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    
  800b95:	00 00                	add    %al,(%eax)
	...

00800b98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	83 ec 10             	sub    $0x10,%esp
  800ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ba6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ba9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	75 2e                	jne    800be4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bb6:	39 f1                	cmp    %esi,%ecx
  800bb8:	77 5a                	ja     800c14 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bba:	85 c9                	test   %ecx,%ecx
  800bbc:	75 0b                	jne    800bc9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc3:	31 d2                	xor    %edx,%edx
  800bc5:	f7 f1                	div    %ecx
  800bc7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bc9:	31 d2                	xor    %edx,%edx
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	f7 f1                	div    %ecx
  800bcf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bd1:	89 f8                	mov    %edi,%eax
  800bd3:	f7 f1                	div    %ecx
  800bd5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bd7:	89 f8                	mov    %edi,%eax
  800bd9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    
  800be2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800be4:	39 f0                	cmp    %esi,%eax
  800be6:	77 1c                	ja     800c04 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800be8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800beb:	83 f7 1f             	xor    $0x1f,%edi
  800bee:	75 3c                	jne    800c2c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bf0:	39 f0                	cmp    %esi,%eax
  800bf2:	0f 82 90 00 00 00    	jb     800c88 <__udivdi3+0xf0>
  800bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bfb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bfe:	0f 86 84 00 00 00    	jbe    800c88 <__udivdi3+0xf0>
  800c04:	31 f6                	xor    %esi,%esi
  800c06:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c08:	89 f8                	mov    %edi,%eax
  800c0a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    
  800c13:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c14:	89 f2                	mov    %esi,%edx
  800c16:	89 f8                	mov    %edi,%eax
  800c18:	f7 f1                	div    %ecx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c1e:	89 f8                	mov    %edi,%eax
  800c20:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    
  800c29:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c2c:	89 f9                	mov    %edi,%ecx
  800c2e:	d3 e0                	shl    %cl,%eax
  800c30:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c33:	b8 20 00 00 00       	mov    $0x20,%eax
  800c38:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c3d:	88 c1                	mov    %al,%cl
  800c3f:	d3 ea                	shr    %cl,%edx
  800c41:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c44:	09 ca                	or     %ecx,%edx
  800c46:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c4c:	89 f9                	mov    %edi,%ecx
  800c4e:	d3 e2                	shl    %cl,%edx
  800c50:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c53:	89 f2                	mov    %esi,%edx
  800c55:	88 c1                	mov    %al,%cl
  800c57:	d3 ea                	shr    %cl,%edx
  800c59:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c5c:	89 f2                	mov    %esi,%edx
  800c5e:	89 f9                	mov    %edi,%ecx
  800c60:	d3 e2                	shl    %cl,%edx
  800c62:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c65:	88 c1                	mov    %al,%cl
  800c67:	d3 ee                	shr    %cl,%esi
  800c69:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c6b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c6e:	89 f0                	mov    %esi,%eax
  800c70:	89 ca                	mov    %ecx,%edx
  800c72:	f7 75 ec             	divl   -0x14(%ebp)
  800c75:	89 d1                	mov    %edx,%ecx
  800c77:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c79:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c7c:	39 d1                	cmp    %edx,%ecx
  800c7e:	72 28                	jb     800ca8 <__udivdi3+0x110>
  800c80:	74 1a                	je     800c9c <__udivdi3+0x104>
  800c82:	89 f7                	mov    %esi,%edi
  800c84:	31 f6                	xor    %esi,%esi
  800c86:	eb 80                	jmp    800c08 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c88:	31 f6                	xor    %esi,%esi
  800c8a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c8f:	89 f8                	mov    %edi,%eax
  800c91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c93:	83 c4 10             	add    $0x10,%esp
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    
  800c9a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c9f:	89 f9                	mov    %edi,%ecx
  800ca1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca3:	39 c2                	cmp    %eax,%edx
  800ca5:	73 db                	jae    800c82 <__udivdi3+0xea>
  800ca7:	90                   	nop
		{
		  q0--;
  800ca8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cab:	31 f6                	xor    %esi,%esi
  800cad:	e9 56 ff ff ff       	jmp    800c08 <__udivdi3+0x70>
	...

00800cb4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	83 ec 20             	sub    $0x20,%esp
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cd1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cd3:	85 ff                	test   %edi,%edi
  800cd5:	75 15                	jne    800cec <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cd7:	39 f1                	cmp    %esi,%ecx
  800cd9:	0f 86 99 00 00 00    	jbe    800d78 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cdf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ce1:	89 d0                	mov    %edx,%eax
  800ce3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ce5:	83 c4 20             	add    $0x20,%esp
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cec:	39 f7                	cmp    %esi,%edi
  800cee:	0f 87 a4 00 00 00    	ja     800d98 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cf7:	83 f0 1f             	xor    $0x1f,%eax
  800cfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cfd:	0f 84 a1 00 00 00    	je     800da4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d03:	89 f8                	mov    %edi,%eax
  800d05:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d08:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d0a:	bf 20 00 00 00       	mov    $0x20,%edi
  800d0f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d15:	89 f9                	mov    %edi,%ecx
  800d17:	d3 ea                	shr    %cl,%edx
  800d19:	09 c2                	or     %eax,%edx
  800d1b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d21:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d24:	d3 e0                	shl    %cl,%eax
  800d26:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d29:	89 f2                	mov    %esi,%edx
  800d2b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d30:	d3 e0                	shl    %cl,%eax
  800d32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d38:	89 f9                	mov    %edi,%ecx
  800d3a:	d3 e8                	shr    %cl,%eax
  800d3c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d3e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	f7 75 f0             	divl   -0x10(%ebp)
  800d45:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d47:	f7 65 f4             	mull   -0xc(%ebp)
  800d4a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d4d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d4f:	39 d6                	cmp    %edx,%esi
  800d51:	72 71                	jb     800dc4 <__umoddi3+0x110>
  800d53:	74 7f                	je     800dd4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d58:	29 c8                	sub    %ecx,%eax
  800d5a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d5c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d5f:	d3 e8                	shr    %cl,%eax
  800d61:	89 f2                	mov    %esi,%edx
  800d63:	89 f9                	mov    %edi,%ecx
  800d65:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d67:	09 d0                	or     %edx,%eax
  800d69:	89 f2                	mov    %esi,%edx
  800d6b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d6e:	d3 ea                	shr    %cl,%edx
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
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d78:	85 c9                	test   %ecx,%ecx
  800d7a:	75 0b                	jne    800d87 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	f7 f1                	div    %ecx
  800d85:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d87:	89 f0                	mov    %esi,%eax
  800d89:	31 d2                	xor    %edx,%edx
  800d8b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d90:	f7 f1                	div    %ecx
  800d92:	e9 4a ff ff ff       	jmp    800ce1 <__umoddi3+0x2d>
  800d97:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d98:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d9a:	83 c4 20             	add    $0x20,%esp
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    
  800da1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800da4:	39 f7                	cmp    %esi,%edi
  800da6:	72 05                	jb     800dad <__umoddi3+0xf9>
  800da8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dab:	77 0c                	ja     800db9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dad:	89 f2                	mov    %esi,%edx
  800daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db2:	29 c8                	sub    %ecx,%eax
  800db4:	19 fa                	sbb    %edi,%edx
  800db6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    
  800dc3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dc7:	89 c1                	mov    %eax,%ecx
  800dc9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dcc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dcf:	eb 84                	jmp    800d55 <__umoddi3+0xa1>
  800dd1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dd7:	72 eb                	jb     800dc4 <__umoddi3+0x110>
  800dd9:	89 f2                	mov    %esi,%edx
  800ddb:	e9 75 ff ff ff       	jmp    800d55 <__umoddi3+0xa1>
