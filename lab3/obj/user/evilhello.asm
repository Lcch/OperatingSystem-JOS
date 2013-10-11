
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
  800041:	e8 de 00 00 00       	call   800124 <sys_cputs>
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
  800057:	e8 34 01 00 00       	call   800190 <sys_getenvid>
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
  8000a0:	e8 c9 00 00 00       	call   80016e <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <my_sysenter>:

// Use my_sysenter, a5 must be 0.
// Attention: it will not update trapframe
static int32_t
my_sysenter(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
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
	assert(a5 == 0);
  8000bd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8000c1:	74 16                	je     8000d9 <my_sysenter+0x2d>
  8000c3:	68 12 0e 80 00       	push   $0x800e12
  8000c8:	68 1a 0e 80 00       	push   $0x800e1a
  8000cd:	6a 0b                	push   $0xb
  8000cf:	68 2f 0e 80 00       	push   $0x800e2f
  8000d4:	e8 db 00 00 00       	call   8001b4 <_panic>
	int32_t ret;

	asm volatile(
  8000d9:	be 00 00 00 00       	mov    $0x0,%esi
  8000de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ea:	55                   	push   %ebp
  8000eb:	54                   	push   %esp
  8000ec:	5d                   	pop    %ebp
  8000ed:	8d 35 f5 00 80 00    	lea    0x8000f5,%esi
  8000f3:	0f 34                	sysenter 

008000f5 <after_sysenter_label>:
  8000f5:	5d                   	pop    %ebp
  8000f6:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8000f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000fc:	74 1c                	je     80011a <after_sysenter_label+0x25>
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 18                	jle    80011a <after_sysenter_label+0x25>
		panic("my_sysenter %d returned %d (> 0)", num, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	50                   	push   %eax
  800106:	ff 75 e4             	pushl  -0x1c(%ebp)
  800109:	68 40 0e 80 00       	push   $0x800e40
  80010e:	6a 20                	push   $0x20
  800110:	68 2f 0e 80 00       	push   $0x800e2f
  800115:	e8 9a 00 00 00       	call   8001b4 <_panic>

	return ret;
}
  80011a:	89 d0                	mov    %edx,%eax
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{	
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80012a:	6a 00                	push   $0x0
  80012c:	6a 00                	push   $0x0
  80012e:	6a 00                	push   $0x0
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	b8 00 00 00 00       	mov    $0x0,%eax
  800140:	e8 67 ff ff ff       	call   8000ac <my_sysenter>
  800145:	83 c4 10             	add    $0x10,%esp
	return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	return;
}
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <sys_cgetc>:

int
sys_cgetc(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800150:	6a 00                	push   $0x0
  800152:	6a 00                	push   $0x0
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 01 00 00 00       	mov    $0x1,%eax
  800167:	e8 40 ff ff ff       	call   8000ac <my_sysenter>
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800174:	6a 00                	push   $0x0
  800176:	6a 00                	push   $0x0
  800178:	6a 00                	push   $0x0
  80017a:	6a 00                	push   $0x0
  80017c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017f:	ba 01 00 00 00       	mov    $0x1,%edx
  800184:	b8 03 00 00 00       	mov    $0x3,%eax
  800189:	e8 1e ff ff ff       	call   8000ac <my_sysenter>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 08             	sub    $0x8,%esp
	return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800196:	6a 00                	push   $0x0
  800198:	6a 00                	push   $0x0
  80019a:	6a 00                	push   $0x0
  80019c:	6a 00                	push   $0x0
  80019e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8001ad:	e8 fa fe ff ff       	call   8000ac <my_sysenter>
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001b9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c2:	e8 c9 ff ff ff       	call   800190 <sys_getenvid>
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	ff 75 08             	pushl  0x8(%ebp)
  8001d0:	53                   	push   %ebx
  8001d1:	50                   	push   %eax
  8001d2:	68 64 0e 80 00       	push   $0x800e64
  8001d7:	e8 b0 00 00 00       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	56                   	push   %esi
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	e8 53 00 00 00       	call   80023b <vcprintf>
	cprintf("\n");
  8001e8:	c7 04 24 88 0e 80 00 	movl   $0x800e88,(%esp)
  8001ef:	e8 98 00 00 00       	call   80028c <cprintf>
  8001f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x43>
	...

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 03                	mov    (%ebx),%eax
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80020f:	40                   	inc    %eax
  800210:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 1a                	jne    800233 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	68 ff 00 00 00       	push   $0xff
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	50                   	push   %eax
  800225:	e8 fa fe ff ff       	call   800124 <sys_cputs>
		b->idx = 0;
  80022a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800230:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800233:	ff 43 04             	incl   0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 fc 01 80 00       	push   $0x8001fc
  80026a:	e8 82 01 00 00       	call   8003f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 a0 fe ff ff       	call   800124 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 2c             	sub    $0x2c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002cd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002d0:	72 0c                	jb     8002de <printnum+0x3e>
  8002d2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002d5:	76 07                	jbe    8002de <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	4b                   	dec    %ebx
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7f 31                	jg     80030d <printnum+0x6d>
  8002dc:	eb 3f                	jmp    80031d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	57                   	push   %edi
  8002e2:	4b                   	dec    %ebx
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002eb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	e8 c7 08 00 00       	call   800bc0 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800303:	e8 98 ff ff ff       	call   8002a0 <printnum>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	eb 10                	jmp    80031d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	57                   	push   %edi
  800312:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800315:	4b                   	dec    %ebx
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	85 db                	test   %ebx,%ebx
  80031b:	7f f0                	jg     80030d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031d:	83 ec 08             	sub    $0x8,%esp
  800320:	56                   	push   %esi
  800321:	83 ec 04             	sub    $0x4,%esp
  800324:	ff 75 d4             	pushl  -0x2c(%ebp)
  800327:	ff 75 d0             	pushl  -0x30(%ebp)
  80032a:	ff 75 dc             	pushl  -0x24(%ebp)
  80032d:	ff 75 d8             	pushl  -0x28(%ebp)
  800330:	e8 a7 09 00 00       	call   800cdc <__umoddi3>
  800335:	83 c4 14             	add    $0x14,%esp
  800338:	0f be 80 8a 0e 80 00 	movsbl 0x800e8a(%eax),%eax
  80033f:	50                   	push   %eax
  800340:	ff 55 e4             	call   *-0x1c(%ebp)
  800343:	83 c4 10             	add    $0x10,%esp
}
  800346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 fa 01             	cmp    $0x1,%edx
  80038e:	7e 0e                	jle    80039e <getint+0x16>
		return va_arg(*ap, long long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 08             	lea    0x8(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	8b 52 04             	mov    0x4(%edx),%edx
  80039c:	eb 1a                	jmp    8003b8 <getint+0x30>
	else if (lflag)
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 0c                	je     8003ae <getint+0x26>
		return va_arg(*ap, long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	99                   	cltd   
  8003ac:	eb 0a                	jmp    8003b8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	99                   	cltd   
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c8:	73 08                	jae    8003d2 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cd:	88 0a                	mov    %cl,(%edx)
  8003cf:	42                   	inc    %edx
  8003d0:	89 10                	mov    %edx,(%eax)
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003dd:	50                   	push   %eax
  8003de:	ff 75 10             	pushl  0x10(%ebp)
  8003e1:	ff 75 0c             	pushl  0xc(%ebp)
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 05 00 00 00       	call   8003f1 <vprintfmt>
	va_end(ap);
  8003ec:	83 c4 10             	add    $0x10,%esp
}
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	57                   	push   %edi
  8003f5:	56                   	push   %esi
  8003f6:	53                   	push   %ebx
  8003f7:	83 ec 2c             	sub    $0x2c,%esp
  8003fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003fd:	8b 75 10             	mov    0x10(%ebp),%esi
  800400:	eb 13                	jmp    800415 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800402:	85 c0                	test   %eax,%eax
  800404:	0f 84 6d 03 00 00    	je     800777 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	57                   	push   %edi
  80040e:	50                   	push   %eax
  80040f:	ff 55 08             	call   *0x8(%ebp)
  800412:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800415:	0f b6 06             	movzbl (%esi),%eax
  800418:	46                   	inc    %esi
  800419:	83 f8 25             	cmp    $0x25,%eax
  80041c:	75 e4                	jne    800402 <vprintfmt+0x11>
  80041e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800422:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800429:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800430:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800437:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043c:	eb 28                	jmp    800466 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800440:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800444:	eb 20                	jmp    800466 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800448:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80044c:	eb 18                	jmp    800466 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800450:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800457:	eb 0d                	jmp    800466 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800459:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8a 06                	mov    (%esi),%al
  800468:	0f b6 d0             	movzbl %al,%edx
  80046b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80046e:	83 e8 23             	sub    $0x23,%eax
  800471:	3c 55                	cmp    $0x55,%al
  800473:	0f 87 e0 02 00 00    	ja     800759 <vprintfmt+0x368>
  800479:	0f b6 c0             	movzbl %al,%eax
  80047c:	ff 24 85 14 0f 80 00 	jmp    *0x800f14(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800483:	83 ea 30             	sub    $0x30,%edx
  800486:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800489:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80048c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80048f:	83 fa 09             	cmp    $0x9,%edx
  800492:	77 44                	ja     8004d8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	89 de                	mov    %ebx,%esi
  800496:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800499:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80049a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80049d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004a1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004a7:	83 fb 09             	cmp    $0x9,%ebx
  8004aa:	76 ed                	jbe    800499 <vprintfmt+0xa8>
  8004ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004af:	eb 29                	jmp    8004da <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c1:	eb 17                	jmp    8004da <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c7:	78 85                	js     80044e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	89 de                	mov    %ebx,%esi
  8004cb:	eb 99                	jmp    800466 <vprintfmt+0x75>
  8004cd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004d6:	eb 8e                	jmp    800466 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004de:	79 86                	jns    800466 <vprintfmt+0x75>
  8004e0:	e9 74 ff ff ff       	jmp    800459 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	89 de                	mov    %ebx,%esi
  8004e8:	e9 79 ff ff ff       	jmp    800466 <vprintfmt+0x75>
  8004ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 50 04             	lea    0x4(%eax),%edx
  8004f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	57                   	push   %edi
  8004fd:	ff 30                	pushl  (%eax)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
			break;
  800502:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800508:	e9 08 ff ff ff       	jmp    800415 <vprintfmt+0x24>
  80050d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	85 c0                	test   %eax,%eax
  80051d:	79 02                	jns    800521 <vprintfmt+0x130>
  80051f:	f7 d8                	neg    %eax
  800521:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 06             	cmp    $0x6,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x142>
  800528:	8b 04 85 6c 10 80 00 	mov    0x80106c(,%eax,4),%eax
  80052f:	85 c0                	test   %eax,%eax
  800531:	75 1a                	jne    80054d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800533:	52                   	push   %edx
  800534:	68 a2 0e 80 00       	push   $0x800ea2
  800539:	57                   	push   %edi
  80053a:	ff 75 08             	pushl  0x8(%ebp)
  80053d:	e8 92 fe ff ff       	call   8003d4 <printfmt>
  800542:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800548:	e9 c8 fe ff ff       	jmp    800415 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80054d:	50                   	push   %eax
  80054e:	68 2c 0e 80 00       	push   $0x800e2c
  800553:	57                   	push   %edi
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 78 fe ff ff       	call   8003d4 <printfmt>
  80055c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800562:	e9 ae fe ff ff       	jmp    800415 <vprintfmt+0x24>
  800567:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80056a:	89 de                	mov    %ebx,%esi
  80056c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800580:	85 c0                	test   %eax,%eax
  800582:	75 07                	jne    80058b <vprintfmt+0x19a>
				p = "(null)";
  800584:	c7 45 d0 9b 0e 80 00 	movl   $0x800e9b,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80058b:	85 db                	test   %ebx,%ebx
  80058d:	7e 42                	jle    8005d1 <vprintfmt+0x1e0>
  80058f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800593:	74 3c                	je     8005d1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	51                   	push   %ecx
  800599:	ff 75 d0             	pushl  -0x30(%ebp)
  80059c:	e8 6f 02 00 00       	call   800810 <strnlen>
  8005a1:	29 c3                	sub    %eax,%ebx
  8005a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	85 db                	test   %ebx,%ebx
  8005ab:	7e 24                	jle    8005d1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005ad:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005b1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	53                   	push   %ebx
  8005bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	4e                   	dec    %esi
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	7f f0                	jg     8005b7 <vprintfmt+0x1c6>
  8005c7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005d4:	0f be 02             	movsbl (%edx),%eax
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	75 47                	jne    800622 <vprintfmt+0x231>
  8005db:	eb 37                	jmp    800614 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e1:	74 16                	je     8005f9 <vprintfmt+0x208>
  8005e3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005e6:	83 fa 5e             	cmp    $0x5e,%edx
  8005e9:	76 0e                	jbe    8005f9 <vprintfmt+0x208>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 3f                	push   $0x3f
  8005f1:	ff 55 08             	call   *0x8(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb 0b                	jmp    800604 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	57                   	push   %edi
  8005fd:	50                   	push   %eax
  8005fe:	ff 55 08             	call   *0x8(%ebp)
  800601:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800604:	ff 4d e4             	decl   -0x1c(%ebp)
  800607:	0f be 03             	movsbl (%ebx),%eax
  80060a:	85 c0                	test   %eax,%eax
  80060c:	74 03                	je     800611 <vprintfmt+0x220>
  80060e:	43                   	inc    %ebx
  80060f:	eb 1b                	jmp    80062c <vprintfmt+0x23b>
  800611:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800614:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800618:	7f 1e                	jg     800638 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80061d:	e9 f3 fd ff ff       	jmp    800415 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800625:	43                   	inc    %ebx
  800626:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800629:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80062c:	85 f6                	test   %esi,%esi
  80062e:	78 ad                	js     8005dd <vprintfmt+0x1ec>
  800630:	4e                   	dec    %esi
  800631:	79 aa                	jns    8005dd <vprintfmt+0x1ec>
  800633:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800636:	eb dc                	jmp    800614 <vprintfmt+0x223>
  800638:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	57                   	push   %edi
  80063f:	6a 20                	push   $0x20
  800641:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800644:	4b                   	dec    %ebx
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	85 db                	test   %ebx,%ebx
  80064a:	7f ef                	jg     80063b <vprintfmt+0x24a>
  80064c:	e9 c4 fd ff ff       	jmp    800415 <vprintfmt+0x24>
  800651:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 2a fd ff ff       	call   800388 <getint>
  80065e:	89 c3                	mov    %eax,%ebx
  800660:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800662:	85 d2                	test   %edx,%edx
  800664:	78 0a                	js     800670 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 b0 00 00 00       	jmp    800720 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	57                   	push   %edi
  800674:	6a 2d                	push   $0x2d
  800676:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800679:	f7 db                	neg    %ebx
  80067b:	83 d6 00             	adc    $0x0,%esi
  80067e:	f7 de                	neg    %esi
  800680:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800683:	b8 0a 00 00 00       	mov    $0xa,%eax
  800688:	e9 93 00 00 00       	jmp    800720 <vprintfmt+0x32f>
  80068d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800690:	89 ca                	mov    %ecx,%edx
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 b4 fc ff ff       	call   80034e <getuint>
  80069a:	89 c3                	mov    %eax,%ebx
  80069c:	89 d6                	mov    %edx,%esi
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006a3:	eb 7b                	jmp    800720 <vprintfmt+0x32f>
  8006a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006a8:	89 ca                	mov    %ecx,%edx
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 d6 fc ff ff       	call   800388 <getint>
  8006b2:	89 c3                	mov    %eax,%ebx
  8006b4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	78 07                	js     8006c1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8006bf:	eb 5f                	jmp    800720 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	57                   	push   %edi
  8006c5:	6a 2d                	push   $0x2d
  8006c7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006ca:	f7 db                	neg    %ebx
  8006cc:	83 d6 00             	adc    $0x0,%esi
  8006cf:	f7 de                	neg    %esi
  8006d1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d9:	eb 45                	jmp    800720 <vprintfmt+0x32f>
  8006db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	57                   	push   %edi
  8006e2:	6a 30                	push   $0x30
  8006e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e7:	83 c4 08             	add    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	6a 78                	push   $0x78
  8006ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f9:	8b 18                	mov    (%eax),%ebx
  8006fb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800700:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800708:	eb 16                	jmp    800720 <vprintfmt+0x32f>
  80070a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070d:	89 ca                	mov    %ecx,%edx
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 37 fc ff ff       	call   80034e <getuint>
  800717:	89 c3                	mov    %eax,%ebx
  800719:	89 d6                	mov    %edx,%esi
			base = 16;
  80071b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800720:	83 ec 0c             	sub    $0xc,%esp
  800723:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800727:	52                   	push   %edx
  800728:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072b:	50                   	push   %eax
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	89 fa                	mov    %edi,%edx
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	e8 68 fb ff ff       	call   8002a0 <printnum>
			break;
  800738:	83 c4 20             	add    $0x20,%esp
  80073b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80073e:	e9 d2 fc ff ff       	jmp    800415 <vprintfmt+0x24>
  800743:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	57                   	push   %edi
  80074a:	52                   	push   %edx
  80074b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80074e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800754:	e9 bc fc ff ff       	jmp    800415 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	57                   	push   %edi
  80075d:	6a 25                	push   $0x25
  80075f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb 02                	jmp    800769 <vprintfmt+0x378>
  800767:	89 c6                	mov    %eax,%esi
  800769:	8d 46 ff             	lea    -0x1(%esi),%eax
  80076c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800770:	75 f5                	jne    800767 <vprintfmt+0x376>
  800772:	e9 9e fc ff ff       	jmp    800415 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800777:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077a:	5b                   	pop    %ebx
  80077b:	5e                   	pop    %esi
  80077c:	5f                   	pop    %edi
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 18             	sub    $0x18,%esp
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800792:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800795:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079c:	85 c0                	test   %eax,%eax
  80079e:	74 26                	je     8007c6 <vsnprintf+0x47>
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	7e 29                	jle    8007cd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a4:	ff 75 14             	pushl  0x14(%ebp)
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ad:	50                   	push   %eax
  8007ae:	68 ba 03 80 00       	push   $0x8003ba
  8007b3:	e8 39 fc ff ff       	call   8003f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb 0c                	jmp    8007d2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cb:	eb 05                	jmp    8007d2 <vsnprintf+0x53>
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dd:	50                   	push   %eax
  8007de:	ff 75 10             	pushl  0x10(%ebp)
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	ff 75 08             	pushl  0x8(%ebp)
  8007e7:	e8 93 ff ff ff       	call   80077f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f9:	74 0e                	je     800809 <strlen+0x19>
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800800:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800805:	75 f9                	jne    800800 <strlen+0x10>
  800807:	eb 05                	jmp    80080e <strlen+0x1e>
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 17                	je     800834 <strnlen+0x24>
  80081d:	80 39 00             	cmpb   $0x0,(%ecx)
  800820:	74 19                	je     80083b <strnlen+0x2b>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800827:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 d0                	cmp    %edx,%eax
  80082a:	74 14                	je     800840 <strnlen+0x30>
  80082c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800830:	75 f5                	jne    800827 <strnlen+0x17>
  800832:	eb 0c                	jmp    800840 <strnlen+0x30>
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	eb 05                	jmp    800840 <strnlen+0x30>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
  800851:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800854:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800857:	42                   	inc    %edx
  800858:	84 c9                	test   %cl,%cl
  80085a:	75 f5                	jne    800851 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80085c:	5b                   	pop    %ebx
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800866:	53                   	push   %ebx
  800867:	e8 84 ff ff ff       	call   8007f0 <strlen>
  80086c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800875:	50                   	push   %eax
  800876:	e8 c7 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80087b:	89 d8                	mov    %ebx,%eax
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800890:	85 f6                	test   %esi,%esi
  800892:	74 15                	je     8008a9 <strncpy+0x27>
  800894:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800899:	8a 1a                	mov    (%edx),%bl
  80089b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089e:	80 3a 01             	cmpb   $0x1,(%edx)
  8008a1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	41                   	inc    %ecx
  8008a5:	39 ce                	cmp    %ecx,%esi
  8008a7:	77 f0                	ja     800899 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
  8008b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bc:	85 f6                	test   %esi,%esi
  8008be:	74 32                	je     8008f2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008c0:	83 fe 01             	cmp    $0x1,%esi
  8008c3:	74 22                	je     8008e7 <strlcpy+0x3a>
  8008c5:	8a 0b                	mov    (%ebx),%cl
  8008c7:	84 c9                	test   %cl,%cl
  8008c9:	74 20                	je     8008eb <strlcpy+0x3e>
  8008cb:	89 f8                	mov    %edi,%eax
  8008cd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008d2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d5:	88 08                	mov    %cl,(%eax)
  8008d7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d8:	39 f2                	cmp    %esi,%edx
  8008da:	74 11                	je     8008ed <strlcpy+0x40>
  8008dc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008e0:	42                   	inc    %edx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	75 f0                	jne    8008d5 <strlcpy+0x28>
  8008e5:	eb 06                	jmp    8008ed <strlcpy+0x40>
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	eb 02                	jmp    8008ed <strlcpy+0x40>
  8008eb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ed:	c6 00 00             	movb   $0x0,(%eax)
  8008f0:	eb 02                	jmp    8008f4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008f4:	29 f8                	sub    %edi,%eax
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5f                   	pop    %edi
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800904:	8a 01                	mov    (%ecx),%al
  800906:	84 c0                	test   %al,%al
  800908:	74 10                	je     80091a <strcmp+0x1f>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	75 0c                	jne    80091a <strcmp+0x1f>
		p++, q++;
  80090e:	41                   	inc    %ecx
  80090f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800910:	8a 01                	mov    (%ecx),%al
  800912:	84 c0                	test   %al,%al
  800914:	74 04                	je     80091a <strcmp+0x1f>
  800916:	3a 02                	cmp    (%edx),%al
  800918:	74 f4                	je     80090e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091a:	0f b6 c0             	movzbl %al,%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 55 08             	mov    0x8(%ebp),%edx
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800931:	85 c0                	test   %eax,%eax
  800933:	74 1b                	je     800950 <strncmp+0x2c>
  800935:	8a 1a                	mov    (%edx),%bl
  800937:	84 db                	test   %bl,%bl
  800939:	74 24                	je     80095f <strncmp+0x3b>
  80093b:	3a 19                	cmp    (%ecx),%bl
  80093d:	75 20                	jne    80095f <strncmp+0x3b>
  80093f:	48                   	dec    %eax
  800940:	74 15                	je     800957 <strncmp+0x33>
		n--, p++, q++;
  800942:	42                   	inc    %edx
  800943:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800944:	8a 1a                	mov    (%edx),%bl
  800946:	84 db                	test   %bl,%bl
  800948:	74 15                	je     80095f <strncmp+0x3b>
  80094a:	3a 19                	cmp    (%ecx),%bl
  80094c:	74 f1                	je     80093f <strncmp+0x1b>
  80094e:	eb 0f                	jmp    80095f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
  800955:	eb 05                	jmp    80095c <strncmp+0x38>
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095c:	5b                   	pop    %ebx
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 02             	movzbl (%edx),%eax
  800962:	0f b6 11             	movzbl (%ecx),%edx
  800965:	29 d0                	sub    %edx,%eax
  800967:	eb f3                	jmp    80095c <strncmp+0x38>

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800972:	8a 10                	mov    (%eax),%dl
  800974:	84 d2                	test   %dl,%dl
  800976:	74 18                	je     800990 <strchr+0x27>
		if (*s == c)
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	75 06                	jne    800982 <strchr+0x19>
  80097c:	eb 17                	jmp    800995 <strchr+0x2c>
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 13                	je     800995 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800982:	40                   	inc    %eax
  800983:	8a 10                	mov    (%eax),%dl
  800985:	84 d2                	test   %dl,%dl
  800987:	75 f5                	jne    80097e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
  80098e:	eb 05                	jmp    800995 <strchr+0x2c>
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009a0:	8a 10                	mov    (%eax),%dl
  8009a2:	84 d2                	test   %dl,%dl
  8009a4:	74 11                	je     8009b7 <strfind+0x20>
		if (*s == c)
  8009a6:	38 ca                	cmp    %cl,%dl
  8009a8:	75 06                	jne    8009b0 <strfind+0x19>
  8009aa:	eb 0b                	jmp    8009b7 <strfind+0x20>
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 07                	je     8009b7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b0:	40                   	inc    %eax
  8009b1:	8a 10                	mov    (%eax),%dl
  8009b3:	84 d2                	test   %dl,%dl
  8009b5:	75 f5                	jne    8009ac <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c8:	85 c9                	test   %ecx,%ecx
  8009ca:	74 30                	je     8009fc <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d2:	75 25                	jne    8009f9 <memset+0x40>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 20                	jne    8009f9 <memset+0x40>
		c &= 0xFF;
  8009d9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 d0                	or     %edx,%eax
  8009ef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009f4:	fc                   	cld    
  8009f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f7:	eb 03                	jmp    8009fc <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f9:	fc                   	cld    
  8009fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fc:	89 f8                	mov    %edi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a11:	39 c6                	cmp    %eax,%esi
  800a13:	73 34                	jae    800a49 <memmove+0x46>
  800a15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a18:	39 d0                	cmp    %edx,%eax
  800a1a:	73 2d                	jae    800a49 <memmove+0x46>
		s += n;
		d += n;
  800a1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1f:	f6 c2 03             	test   $0x3,%dl
  800a22:	75 1b                	jne    800a3f <memmove+0x3c>
  800a24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2a:	75 13                	jne    800a3f <memmove+0x3c>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 0e                	jne    800a3f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 07                	jmp    800a46 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	4f                   	dec    %edi
  800a40:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	fd                   	std    
  800a44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a46:	fc                   	cld    
  800a47:	eb 20                	jmp    800a69 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a49:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4f:	75 13                	jne    800a64 <memmove+0x61>
  800a51:	a8 03                	test   $0x3,%al
  800a53:	75 0f                	jne    800a64 <memmove+0x61>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	75 0a                	jne    800a64 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	fc                   	cld    
  800a60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a62:	eb 05                	jmp    800a69 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	fc                   	cld    
  800a67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a70:	ff 75 10             	pushl  0x10(%ebp)
  800a73:	ff 75 0c             	pushl  0xc(%ebp)
  800a76:	ff 75 08             	pushl  0x8(%ebp)
  800a79:	e8 85 ff ff ff       	call   800a03 <memmove>
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8f:	85 ff                	test   %edi,%edi
  800a91:	74 32                	je     800ac5 <memcmp+0x45>
		if (*s1 != *s2)
  800a93:	8a 03                	mov    (%ebx),%al
  800a95:	8a 0e                	mov    (%esi),%cl
  800a97:	38 c8                	cmp    %cl,%al
  800a99:	74 19                	je     800ab4 <memcmp+0x34>
  800a9b:	eb 0d                	jmp    800aaa <memcmp+0x2a>
  800a9d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800aa1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800aa5:	42                   	inc    %edx
  800aa6:	38 c8                	cmp    %cl,%al
  800aa8:	74 10                	je     800aba <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aaa:	0f b6 c0             	movzbl %al,%eax
  800aad:	0f b6 c9             	movzbl %cl,%ecx
  800ab0:	29 c8                	sub    %ecx,%eax
  800ab2:	eb 16                	jmp    800aca <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab4:	4f                   	dec    %edi
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	39 fa                	cmp    %edi,%edx
  800abc:	75 df                	jne    800a9d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac3:	eb 05                	jmp    800aca <memcmp+0x4a>
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ada:	39 d0                	cmp    %edx,%eax
  800adc:	73 12                	jae    800af0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ade:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	75 06                	jne    800aeb <memfind+0x1c>
  800ae5:	eb 09                	jmp    800af0 <memfind+0x21>
  800ae7:	38 08                	cmp    %cl,(%eax)
  800ae9:	74 05                	je     800af0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aeb:	40                   	inc    %eax
  800aec:	39 c2                	cmp    %eax,%edx
  800aee:	77 f7                	ja     800ae7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afe:	eb 01                	jmp    800b01 <strtol+0xf>
		s++;
  800b00:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b01:	8a 02                	mov    (%edx),%al
  800b03:	3c 20                	cmp    $0x20,%al
  800b05:	74 f9                	je     800b00 <strtol+0xe>
  800b07:	3c 09                	cmp    $0x9,%al
  800b09:	74 f5                	je     800b00 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0b:	3c 2b                	cmp    $0x2b,%al
  800b0d:	75 08                	jne    800b17 <strtol+0x25>
		s++;
  800b0f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
  800b15:	eb 13                	jmp    800b2a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b17:	3c 2d                	cmp    $0x2d,%al
  800b19:	75 0a                	jne    800b25 <strtol+0x33>
		s++, neg = 1;
  800b1b:	8d 52 01             	lea    0x1(%edx),%edx
  800b1e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b23:	eb 05                	jmp    800b2a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2a:	85 db                	test   %ebx,%ebx
  800b2c:	74 05                	je     800b33 <strtol+0x41>
  800b2e:	83 fb 10             	cmp    $0x10,%ebx
  800b31:	75 28                	jne    800b5b <strtol+0x69>
  800b33:	8a 02                	mov    (%edx),%al
  800b35:	3c 30                	cmp    $0x30,%al
  800b37:	75 10                	jne    800b49 <strtol+0x57>
  800b39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b3d:	75 0a                	jne    800b49 <strtol+0x57>
		s += 2, base = 16;
  800b3f:	83 c2 02             	add    $0x2,%edx
  800b42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b47:	eb 12                	jmp    800b5b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b49:	85 db                	test   %ebx,%ebx
  800b4b:	75 0e                	jne    800b5b <strtol+0x69>
  800b4d:	3c 30                	cmp    $0x30,%al
  800b4f:	75 05                	jne    800b56 <strtol+0x64>
		s++, base = 8;
  800b51:	42                   	inc    %edx
  800b52:	b3 08                	mov    $0x8,%bl
  800b54:	eb 05                	jmp    800b5b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b56:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b62:	8a 0a                	mov    (%edx),%cl
  800b64:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b67:	80 fb 09             	cmp    $0x9,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x82>
			dig = *s - '0';
  800b6c:	0f be c9             	movsbl %cl,%ecx
  800b6f:	83 e9 30             	sub    $0x30,%ecx
  800b72:	eb 1e                	jmp    800b92 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b74:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b77:	80 fb 19             	cmp    $0x19,%bl
  800b7a:	77 08                	ja     800b84 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b7c:	0f be c9             	movsbl %cl,%ecx
  800b7f:	83 e9 57             	sub    $0x57,%ecx
  800b82:	eb 0e                	jmp    800b92 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b84:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b87:	80 fb 19             	cmp    $0x19,%bl
  800b8a:	77 13                	ja     800b9f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b8c:	0f be c9             	movsbl %cl,%ecx
  800b8f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b92:	39 f1                	cmp    %esi,%ecx
  800b94:	7d 0d                	jge    800ba3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b96:	42                   	inc    %edx
  800b97:	0f af c6             	imul   %esi,%eax
  800b9a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b9d:	eb c3                	jmp    800b62 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	89 c1                	mov    %eax,%ecx
  800ba1:	eb 02                	jmp    800ba5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba9:	74 05                	je     800bb0 <strtol+0xbe>
		*endptr = (char *) s;
  800bab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bae:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bb0:	85 ff                	test   %edi,%edi
  800bb2:	74 04                	je     800bb8 <strtol+0xc6>
  800bb4:	89 c8                	mov    %ecx,%eax
  800bb6:	f7 d8                	neg    %eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    
  800bbd:	00 00                	add    %al,(%eax)
	...

00800bc0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	83 ec 10             	sub    $0x10,%esp
  800bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bce:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bd4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bd7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	75 2e                	jne    800c0c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bde:	39 f1                	cmp    %esi,%ecx
  800be0:	77 5a                	ja     800c3c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800be2:	85 c9                	test   %ecx,%ecx
  800be4:	75 0b                	jne    800bf1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	31 d2                	xor    %edx,%edx
  800bed:	f7 f1                	div    %ecx
  800bef:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bf1:	31 d2                	xor    %edx,%edx
  800bf3:	89 f0                	mov    %esi,%eax
  800bf5:	f7 f1                	div    %ecx
  800bf7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	f7 f1                	div    %ecx
  800bfd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bff:	89 f8                	mov    %edi,%eax
  800c01:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    
  800c0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c0c:	39 f0                	cmp    %esi,%eax
  800c0e:	77 1c                	ja     800c2c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c10:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c13:	83 f7 1f             	xor    $0x1f,%edi
  800c16:	75 3c                	jne    800c54 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	0f 82 90 00 00 00    	jb     800cb0 <__udivdi3+0xf0>
  800c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c23:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c26:	0f 86 84 00 00 00    	jbe    800cb0 <__udivdi3+0xf0>
  800c2c:	31 f6                	xor    %esi,%esi
  800c2e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c30:	89 f8                	mov    %edi,%eax
  800c32:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    
  800c3b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c3c:	89 f2                	mov    %esi,%edx
  800c3e:	89 f8                	mov    %edi,%eax
  800c40:	f7 f1                	div    %ecx
  800c42:	89 c7                	mov    %eax,%edi
  800c44:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c46:	89 f8                	mov    %edi,%eax
  800c48:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    
  800c51:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c54:	89 f9                	mov    %edi,%ecx
  800c56:	d3 e0                	shl    %cl,%eax
  800c58:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c5b:	b8 20 00 00 00       	mov    $0x20,%eax
  800c60:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c65:	88 c1                	mov    %al,%cl
  800c67:	d3 ea                	shr    %cl,%edx
  800c69:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c6c:	09 ca                	or     %ecx,%edx
  800c6e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c74:	89 f9                	mov    %edi,%ecx
  800c76:	d3 e2                	shl    %cl,%edx
  800c78:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c7b:	89 f2                	mov    %esi,%edx
  800c7d:	88 c1                	mov    %al,%cl
  800c7f:	d3 ea                	shr    %cl,%edx
  800c81:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c84:	89 f2                	mov    %esi,%edx
  800c86:	89 f9                	mov    %edi,%ecx
  800c88:	d3 e2                	shl    %cl,%edx
  800c8a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c8d:	88 c1                	mov    %al,%cl
  800c8f:	d3 ee                	shr    %cl,%esi
  800c91:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c93:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	89 ca                	mov    %ecx,%edx
  800c9a:	f7 75 ec             	divl   -0x14(%ebp)
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ca1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca4:	39 d1                	cmp    %edx,%ecx
  800ca6:	72 28                	jb     800cd0 <__udivdi3+0x110>
  800ca8:	74 1a                	je     800cc4 <__udivdi3+0x104>
  800caa:	89 f7                	mov    %esi,%edi
  800cac:	31 f6                	xor    %esi,%esi
  800cae:	eb 80                	jmp    800c30 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cb0:	31 f6                	xor    %esi,%esi
  800cb2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cbb:	83 c4 10             	add    $0x10,%esp
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    
  800cc2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cc7:	89 f9                	mov    %edi,%ecx
  800cc9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ccb:	39 c2                	cmp    %eax,%edx
  800ccd:	73 db                	jae    800caa <__udivdi3+0xea>
  800ccf:	90                   	nop
		{
		  q0--;
  800cd0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cd3:	31 f6                	xor    %esi,%esi
  800cd5:	e9 56 ff ff ff       	jmp    800c30 <__udivdi3+0x70>
	...

00800cdc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	83 ec 20             	sub    $0x20,%esp
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cf0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cf9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	75 15                	jne    800d14 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cff:	39 f1                	cmp    %esi,%ecx
  800d01:	0f 86 99 00 00 00    	jbe    800da0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d07:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d0d:	83 c4 20             	add    $0x20,%esp
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d14:	39 f7                	cmp    %esi,%edi
  800d16:	0f 87 a4 00 00 00    	ja     800dc0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d1c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d1f:	83 f0 1f             	xor    $0x1f,%eax
  800d22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d25:	0f 84 a1 00 00 00    	je     800dcc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d2b:	89 f8                	mov    %edi,%eax
  800d2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d30:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d32:	bf 20 00 00 00       	mov    $0x20,%edi
  800d37:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d3d:	89 f9                	mov    %edi,%ecx
  800d3f:	d3 ea                	shr    %cl,%edx
  800d41:	09 c2                	or     %eax,%edx
  800d43:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d49:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d4c:	d3 e0                	shl    %cl,%eax
  800d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d51:	89 f2                	mov    %esi,%edx
  800d53:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d58:	d3 e0                	shl    %cl,%eax
  800d5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d60:	89 f9                	mov    %edi,%ecx
  800d62:	d3 e8                	shr    %cl,%eax
  800d64:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d66:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d68:	89 f2                	mov    %esi,%edx
  800d6a:	f7 75 f0             	divl   -0x10(%ebp)
  800d6d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d6f:	f7 65 f4             	mull   -0xc(%ebp)
  800d72:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d75:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d77:	39 d6                	cmp    %edx,%esi
  800d79:	72 71                	jb     800dec <__umoddi3+0x110>
  800d7b:	74 7f                	je     800dfc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d80:	29 c8                	sub    %ecx,%eax
  800d82:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d84:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d87:	d3 e8                	shr    %cl,%eax
  800d89:	89 f2                	mov    %esi,%edx
  800d8b:	89 f9                	mov    %edi,%ecx
  800d8d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d8f:	09 d0                	or     %edx,%eax
  800d91:	89 f2                	mov    %esi,%edx
  800d93:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d96:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d98:	83 c4 20             	add    $0x20,%esp
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    
  800d9f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	75 0b                	jne    800daf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da4:	b8 01 00 00 00       	mov    $0x1,%eax
  800da9:	31 d2                	xor    %edx,%edx
  800dab:	f7 f1                	div    %ecx
  800dad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800daf:	89 f0                	mov    %esi,%eax
  800db1:	31 d2                	xor    %edx,%edx
  800db3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db8:	f7 f1                	div    %ecx
  800dba:	e9 4a ff ff ff       	jmp    800d09 <__umoddi3+0x2d>
  800dbf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dc0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dc2:	83 c4 20             	add    $0x20,%esp
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    
  800dc9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dcc:	39 f7                	cmp    %esi,%edi
  800dce:	72 05                	jb     800dd5 <__umoddi3+0xf9>
  800dd0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dd3:	77 0c                	ja     800de1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd5:	89 f2                	mov    %esi,%edx
  800dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dda:	29 c8                	sub    %ecx,%eax
  800ddc:	19 fa                	sbb    %edi,%edx
  800dde:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de4:	83 c4 20             	add    $0x20,%esp
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    
  800deb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800def:	89 c1                	mov    %eax,%ecx
  800df1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800df4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800df7:	eb 84                	jmp    800d7d <__umoddi3+0xa1>
  800df9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dfc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dff:	72 eb                	jb     800dec <__umoddi3+0x110>
  800e01:	89 f2                	mov    %esi,%edx
  800e03:	e9 75 ff ff ff       	jmp    800d7d <__umoddi3+0xa1>
