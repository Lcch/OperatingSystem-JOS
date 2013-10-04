
obj/user/faultwritekernel:     file format elf32-i386


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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
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
  800047:	83 ec 08             	sub    $0x8,%esp
  80004a:	8b 45 08             	mov    0x8(%ebp),%eax
  80004d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800057:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	7e 08                	jle    800066 <libmain+0x22>
		binaryname = argv[0];
  80005e:	8b 0a                	mov    (%edx),%ecx
  800060:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	52                   	push   %edx
  80006a:	50                   	push   %eax
  80006b:	e8 c4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800070:	e8 07 00 00 00       	call   80007c <exit>
  800075:	83 c4 10             	add    $0x10,%esp
}
  800078:	c9                   	leave  
  800079:	c3                   	ret    
	...

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800082:	6a 00                	push   $0x0
  800084:	e8 44 00 00 00       	call   8000cd <sys_env_destroy>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    
	...

00800090 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	57                   	push   %edi
  800094:	56                   	push   %esi
  800095:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800096:	b8 00 00 00 00       	mov    $0x0,%eax
  80009b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009e:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a1:	89 c3                	mov    %eax,%ebx
  8000a3:	89 c7                	mov    %eax,%edi
  8000a5:	89 c6                	mov    %eax,%esi
  8000a7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5f                   	pop    %edi
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000be:	89 d1                	mov    %edx,%ecx
  8000c0:	89 d3                	mov    %edx,%ebx
  8000c2:	89 d7                	mov    %edx,%edi
  8000c4:	89 d6                	mov    %edx,%esi
  8000c6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000db:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	89 cb                	mov    %ecx,%ebx
  8000e5:	89 cf                	mov    %ecx,%edi
  8000e7:	89 ce                	mov    %ecx,%esi
  8000e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	7e 17                	jle    800106 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	50                   	push   %eax
  8000f3:	6a 03                	push   $0x3
  8000f5:	68 8e 0d 80 00       	push   $0x800d8e
  8000fa:	6a 23                	push   $0x23
  8000fc:	68 ab 0d 80 00       	push   $0x800dab
  800101:	e8 2a 00 00 00       	call   800130 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    

0080010e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	57                   	push   %edi
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800114:	ba 00 00 00 00       	mov    $0x0,%edx
  800119:	b8 02 00 00 00       	mov    $0x2,%eax
  80011e:	89 d1                	mov    %edx,%ecx
  800120:	89 d3                	mov    %edx,%ebx
  800122:	89 d7                	mov    %edx,%edi
  800124:	89 d6                	mov    %edx,%esi
  800126:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    
  80012d:	00 00                	add    %al,(%eax)
	...

00800130 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800135:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800138:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80013e:	e8 cb ff ff ff       	call   80010e <sys_getenvid>
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	ff 75 0c             	pushl  0xc(%ebp)
  800149:	ff 75 08             	pushl  0x8(%ebp)
  80014c:	53                   	push   %ebx
  80014d:	50                   	push   %eax
  80014e:	68 bc 0d 80 00       	push   $0x800dbc
  800153:	e8 b0 00 00 00       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800158:	83 c4 18             	add    $0x18,%esp
  80015b:	56                   	push   %esi
  80015c:	ff 75 10             	pushl  0x10(%ebp)
  80015f:	e8 53 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  800164:	c7 04 24 e0 0d 80 00 	movl   $0x800de0,(%esp)
  80016b:	e8 98 00 00 00       	call   800208 <cprintf>
  800170:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800173:	cc                   	int3   
  800174:	eb fd                	jmp    800173 <_panic+0x43>
	...

00800178 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	53                   	push   %ebx
  80017c:	83 ec 04             	sub    $0x4,%esp
  80017f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800182:	8b 03                	mov    (%ebx),%eax
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018b:	40                   	inc    %eax
  80018c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800193:	75 1a                	jne    8001af <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	68 ff 00 00 00       	push   $0xff
  80019d:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a0:	50                   	push   %eax
  8001a1:	e8 ea fe ff ff       	call   800090 <sys_cputs>
		b->idx = 0;
  8001a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ac:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001af:	ff 43 04             	incl   0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 78 01 80 00       	push   $0x800178
  8001e6:	e8 82 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 90 fe ff ff       	call   800090 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	89 d6                	mov    %edx,%esi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800230:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800233:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800242:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800249:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80024c:	72 0c                	jb     80025a <printnum+0x3e>
  80024e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800251:	76 07                	jbe    80025a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800253:	4b                   	dec    %ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7f 31                	jg     800289 <printnum+0x6d>
  800258:	eb 3f                	jmp    800299 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	57                   	push   %edi
  80025e:	4b                   	dec    %ebx
  80025f:	53                   	push   %ebx
  800260:	50                   	push   %eax
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 d4             	pushl  -0x2c(%ebp)
  800267:	ff 75 d0             	pushl  -0x30(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 c7 08 00 00       	call   800b3c <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027f:	e8 98 ff ff ff       	call   80021c <printnum>
  800284:	83 c4 20             	add    $0x20,%esp
  800287:	eb 10                	jmp    800299 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	57                   	push   %edi
  80028e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	4b                   	dec    %ebx
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	85 db                	test   %ebx,%ebx
  800297:	7f f0                	jg     800289 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	83 ec 04             	sub    $0x4,%esp
  8002a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ac:	e8 a7 09 00 00       	call   800c58 <__umoddi3>
  8002b1:	83 c4 14             	add    $0x14,%esp
  8002b4:	0f be 80 e2 0d 80 00 	movsbl 0x800de2(%eax),%eax
  8002bb:	50                   	push   %eax
  8002bc:	ff 55 e4             	call   *-0x1c(%ebp)
  8002bf:	83 c4 10             	add    $0x10,%esp
}
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cd:	83 fa 01             	cmp    $0x1,%edx
  8002d0:	7e 0e                	jle    8002e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	8b 52 04             	mov    0x4(%edx),%edx
  8002de:	eb 22                	jmp    800302 <getuint+0x38>
	else if (lflag)
  8002e0:	85 d2                	test   %edx,%edx
  8002e2:	74 10                	je     8002f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 0e                	jmp    800302 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800307:	83 fa 01             	cmp    $0x1,%edx
  80030a:	7e 0e                	jle    80031a <getint+0x16>
		return va_arg(*ap, long long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	8b 52 04             	mov    0x4(%edx),%edx
  800318:	eb 1a                	jmp    800334 <getint+0x30>
	else if (lflag)
  80031a:	85 d2                	test   %edx,%edx
  80031c:	74 0c                	je     80032a <getint+0x26>
		return va_arg(*ap, long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	99                   	cltd   
  800328:	eb 0a                	jmp    800334 <getint+0x30>
	else
		return va_arg(*ap, int);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	99                   	cltd   
}
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 08                	jae    80034e <sprintputch+0x18>
		*b->buf++ = ch;
  800346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800349:	88 0a                	mov    %cl,(%edx)
  80034b:	42                   	inc    %edx
  80034c:	89 10                	mov    %edx,(%eax)
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	pushl  0x10(%ebp)
  80035d:	ff 75 0c             	pushl  0xc(%ebp)
  800360:	ff 75 08             	pushl  0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
	va_end(ap);
  800368:	83 c4 10             	add    $0x10,%esp
}
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 2c             	sub    $0x2c,%esp
  800376:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800379:	8b 75 10             	mov    0x10(%ebp),%esi
  80037c:	eb 13                	jmp    800391 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 6d 03 00 00    	je     8006f3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	57                   	push   %edi
  80038a:	50                   	push   %eax
  80038b:	ff 55 08             	call   *0x8(%ebp)
  80038e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800391:	0f b6 06             	movzbl (%esi),%eax
  800394:	46                   	inc    %esi
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e4                	jne    80037e <vprintfmt+0x11>
  80039a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80039e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b8:	eb 28                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c0:	eb 20                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c8:	eb 18                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d3:	eb 0d                	jmp    8003e2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8a 06                	mov    (%esi),%al
  8003e4:	0f b6 d0             	movzbl %al,%edx
  8003e7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 e0 02 00 00    	ja     8006d5 <vprintfmt+0x368>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 70 0e 80 00 	jmp    *0x800e70(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	83 ea 30             	sub    $0x30,%edx
  800402:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800405:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800408:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040b:	83 fa 09             	cmp    $0x9,%edx
  80040e:	77 44                	ja     800454 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	89 de                	mov    %ebx,%esi
  800412:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800415:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800416:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800419:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80041d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800420:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800423:	83 fb 09             	cmp    $0x9,%ebx
  800426:	76 ed                	jbe    800415 <vprintfmt+0xa8>
  800428:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80042b:	eb 29                	jmp    800456 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043d:	eb 17                	jmp    800456 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80043f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800443:	78 85                	js     8003ca <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	89 de                	mov    %ebx,%esi
  800447:	eb 99                	jmp    8003e2 <vprintfmt+0x75>
  800449:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800452:	eb 8e                	jmp    8003e2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800456:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045a:	79 86                	jns    8003e2 <vprintfmt+0x75>
  80045c:	e9 74 ff ff ff       	jmp    8003d5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800461:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	89 de                	mov    %ebx,%esi
  800464:	e9 79 ff ff ff       	jmp    8003e2 <vprintfmt+0x75>
  800469:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	57                   	push   %edi
  800479:	ff 30                	pushl  (%eax)
  80047b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800484:	e9 08 ff ff ff       	jmp    800391 <vprintfmt+0x24>
  800489:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	79 02                	jns    80049d <vprintfmt+0x130>
  80049b:	f7 d8                	neg    %eax
  80049d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 06             	cmp    $0x6,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x142>
  8004a4:	8b 04 85 c8 0f 80 00 	mov    0x800fc8(,%eax,4),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 1a                	jne    8004c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004af:	52                   	push   %edx
  8004b0:	68 fa 0d 80 00       	push   $0x800dfa
  8004b5:	57                   	push   %edi
  8004b6:	ff 75 08             	pushl  0x8(%ebp)
  8004b9:	e8 92 fe ff ff       	call   800350 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 c8 fe ff ff       	jmp    800391 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	50                   	push   %eax
  8004ca:	68 03 0e 80 00       	push   $0x800e03
  8004cf:	57                   	push   %edi
  8004d0:	ff 75 08             	pushl  0x8(%ebp)
  8004d3:	e8 78 fe ff ff       	call   800350 <printfmt>
  8004d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004de:	e9 ae fe ff ff       	jmp    800391 <vprintfmt+0x24>
  8004e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004e6:	89 de                	mov    %ebx,%esi
  8004e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	75 07                	jne    800507 <vprintfmt+0x19a>
				p = "(null)";
  800500:	c7 45 d0 f3 0d 80 00 	movl   $0x800df3,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800507:	85 db                	test   %ebx,%ebx
  800509:	7e 42                	jle    80054d <vprintfmt+0x1e0>
  80050b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80050f:	74 3c                	je     80054d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	51                   	push   %ecx
  800515:	ff 75 d0             	pushl  -0x30(%ebp)
  800518:	e8 6f 02 00 00       	call   80078c <strnlen>
  80051d:	29 c3                	sub    %eax,%ebx
  80051f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 db                	test   %ebx,%ebx
  800527:	7e 24                	jle    80054d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800529:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80052d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800530:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	57                   	push   %edi
  800537:	53                   	push   %ebx
  800538:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	4e                   	dec    %esi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 f6                	test   %esi,%esi
  800541:	7f f0                	jg     800533 <vprintfmt+0x1c6>
  800543:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800546:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800550:	0f be 02             	movsbl (%edx),%eax
  800553:	85 c0                	test   %eax,%eax
  800555:	75 47                	jne    80059e <vprintfmt+0x231>
  800557:	eb 37                	jmp    800590 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055d:	74 16                	je     800575 <vprintfmt+0x208>
  80055f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800562:	83 fa 5e             	cmp    $0x5e,%edx
  800565:	76 0e                	jbe    800575 <vprintfmt+0x208>
					putch('?', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 0b                	jmp    800580 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	50                   	push   %eax
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	ff 4d e4             	decl   -0x1c(%ebp)
  800583:	0f be 03             	movsbl (%ebx),%eax
  800586:	85 c0                	test   %eax,%eax
  800588:	74 03                	je     80058d <vprintfmt+0x220>
  80058a:	43                   	inc    %ebx
  80058b:	eb 1b                	jmp    8005a8 <vprintfmt+0x23b>
  80058d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800594:	7f 1e                	jg     8005b4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800599:	e9 f3 fd ff ff       	jmp    800391 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a1:	43                   	inc    %ebx
  8005a2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a8:	85 f6                	test   %esi,%esi
  8005aa:	78 ad                	js     800559 <vprintfmt+0x1ec>
  8005ac:	4e                   	dec    %esi
  8005ad:	79 aa                	jns    800559 <vprintfmt+0x1ec>
  8005af:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b2:	eb dc                	jmp    800590 <vprintfmt+0x223>
  8005b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 20                	push   $0x20
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c0:	4b                   	dec    %ebx
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f ef                	jg     8005b7 <vprintfmt+0x24a>
  8005c8:	e9 c4 fd ff ff       	jmp    800391 <vprintfmt+0x24>
  8005cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 2a fd ff ff       	call   800304 <getint>
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	78 0a                	js     8005ec <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 b0 00 00 00       	jmp    80069c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f5:	f7 db                	neg    %ebx
  8005f7:	83 d6 00             	adc    $0x0,%esi
  8005fa:	f7 de                	neg    %esi
  8005fc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 93 00 00 00       	jmp    80069c <vprintfmt+0x32f>
  800609:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 b4 fc ff ff       	call   8002ca <getuint>
  800616:	89 c3                	mov    %eax,%ebx
  800618:	89 d6                	mov    %edx,%esi
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061f:	eb 7b                	jmp    80069c <vprintfmt+0x32f>
  800621:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 d6 fc ff ff       	call   800304 <getint>
  80062e:	89 c3                	mov    %eax,%ebx
  800630:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800632:	85 d2                	test   %edx,%edx
  800634:	78 07                	js     80063d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800636:	b8 08 00 00 00       	mov    $0x8,%eax
  80063b:	eb 5f                	jmp    80069c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	57                   	push   %edi
  800641:	6a 2d                	push   $0x2d
  800643:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800646:	f7 db                	neg    %ebx
  800648:	83 d6 00             	adc    $0x0,%esi
  80064b:	f7 de                	neg    %esi
  80064d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800650:	b8 08 00 00 00       	mov    $0x8,%eax
  800655:	eb 45                	jmp    80069c <vprintfmt+0x32f>
  800657:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	57                   	push   %edi
  80065e:	6a 30                	push   $0x30
  800660:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	57                   	push   %edi
  800667:	6a 78                	push   $0x78
  800669:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	8b 18                	mov    (%eax),%ebx
  800677:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800684:	eb 16                	jmp    80069c <vprintfmt+0x32f>
  800686:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 37 fc ff ff       	call   8002ca <getuint>
  800693:	89 c3                	mov    %eax,%ebx
  800695:	89 d6                	mov    %edx,%esi
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006a3:	52                   	push   %edx
  8006a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a7:	50                   	push   %eax
  8006a8:	56                   	push   %esi
  8006a9:	53                   	push   %ebx
  8006aa:	89 fa                	mov    %edi,%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 68 fb ff ff       	call   80021c <printnum>
			break;
  8006b4:	83 c4 20             	add    $0x20,%esp
  8006b7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ba:	e9 d2 fc ff ff       	jmp    800391 <vprintfmt+0x24>
  8006bf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	57                   	push   %edi
  8006c6:	52                   	push   %edx
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d0:	e9 bc fc ff ff       	jmp    800391 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	57                   	push   %edi
  8006d9:	6a 25                	push   $0x25
  8006db:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 02                	jmp    8006e5 <vprintfmt+0x378>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006e8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ec:	75 f5                	jne    8006e3 <vprintfmt+0x376>
  8006ee:	e9 9e fc ff ff       	jmp    800391 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x47>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 29                	jle    800749 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 36 03 80 00       	push   $0x800336
  80072f:	e8 39 fc ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 0c                	jmp    80074e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb 05                	jmp    80074e <vsnprintf+0x53>
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 93 ff ff ff       	call   8006fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3a 00             	cmpb   $0x0,(%edx)
  800775:	74 0e                	je     800785 <strlen+0x19>
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80077c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800781:	75 f9                	jne    80077c <strlen+0x10>
  800783:	eb 05                	jmp    80078a <strlen+0x1e>
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	85 d2                	test   %edx,%edx
  800797:	74 17                	je     8007b0 <strnlen+0x24>
  800799:	80 39 00             	cmpb   $0x0,(%ecx)
  80079c:	74 19                	je     8007b7 <strnlen+0x2b>
  80079e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a4:	39 d0                	cmp    %edx,%eax
  8007a6:	74 14                	je     8007bc <strnlen+0x30>
  8007a8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ac:	75 f5                	jne    8007a3 <strnlen+0x17>
  8007ae:	eb 0c                	jmp    8007bc <strnlen+0x30>
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 05                	jmp    8007bc <strnlen+0x30>
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d3:	42                   	inc    %edx
  8007d4:	84 c9                	test   %cl,%cl
  8007d6:	75 f5                	jne    8007cd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	53                   	push   %ebx
  8007e3:	e8 84 ff ff ff       	call   80076c <strlen>
  8007e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 c7 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	85 f6                	test   %esi,%esi
  80080e:	74 15                	je     800825 <strncpy+0x27>
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800815:	8a 1a                	mov    (%edx),%bl
  800817:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 3a 01             	cmpb   $0x1,(%edx)
  80081d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	41                   	inc    %ecx
  800821:	39 ce                	cmp    %ecx,%esi
  800823:	77 f0                	ja     800815 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	57                   	push   %edi
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800835:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 f6                	test   %esi,%esi
  80083a:	74 32                	je     80086e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80083c:	83 fe 01             	cmp    $0x1,%esi
  80083f:	74 22                	je     800863 <strlcpy+0x3a>
  800841:	8a 0b                	mov    (%ebx),%cl
  800843:	84 c9                	test   %cl,%cl
  800845:	74 20                	je     800867 <strlcpy+0x3e>
  800847:	89 f8                	mov    %edi,%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80084e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800851:	88 08                	mov    %cl,(%eax)
  800853:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 f2                	cmp    %esi,%edx
  800856:	74 11                	je     800869 <strlcpy+0x40>
  800858:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80085c:	42                   	inc    %edx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	75 f0                	jne    800851 <strlcpy+0x28>
  800861:	eb 06                	jmp    800869 <strlcpy+0x40>
  800863:	89 f8                	mov    %edi,%eax
  800865:	eb 02                	jmp    800869 <strlcpy+0x40>
  800867:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800869:	c6 00 00             	movb   $0x0,(%eax)
  80086c:	eb 02                	jmp    800870 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800870:	29 f8                	sub    %edi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	8a 01                	mov    (%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 10                	je     800896 <strcmp+0x1f>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	75 0c                	jne    800896 <strcmp+0x1f>
		p++, q++;
  80088a:	41                   	inc    %ecx
  80088b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088c:	8a 01                	mov    (%ecx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1f>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 f4                	je     80088a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	74 1b                	je     8008cc <strncmp+0x2c>
  8008b1:	8a 1a                	mov    (%edx),%bl
  8008b3:	84 db                	test   %bl,%bl
  8008b5:	74 24                	je     8008db <strncmp+0x3b>
  8008b7:	3a 19                	cmp    (%ecx),%bl
  8008b9:	75 20                	jne    8008db <strncmp+0x3b>
  8008bb:	48                   	dec    %eax
  8008bc:	74 15                	je     8008d3 <strncmp+0x33>
		n--, p++, q++;
  8008be:	42                   	inc    %edx
  8008bf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c0:	8a 1a                	mov    (%edx),%bl
  8008c2:	84 db                	test   %bl,%bl
  8008c4:	74 15                	je     8008db <strncmp+0x3b>
  8008c6:	3a 19                	cmp    (%ecx),%bl
  8008c8:	74 f1                	je     8008bb <strncmp+0x1b>
  8008ca:	eb 0f                	jmp    8008db <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 05                	jmp    8008d8 <strncmp+0x38>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 02             	movzbl (%edx),%eax
  8008de:	0f b6 11             	movzbl (%ecx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb f3                	jmp    8008d8 <strncmp+0x38>

008008e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ee:	8a 10                	mov    (%eax),%dl
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	74 18                	je     80090c <strchr+0x27>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	75 06                	jne    8008fe <strchr+0x19>
  8008f8:	eb 17                	jmp    800911 <strchr+0x2c>
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	74 13                	je     800911 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fe:	40                   	inc    %eax
  8008ff:	8a 10                	mov    (%eax),%dl
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f5                	jne    8008fa <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	eb 05                	jmp    800911 <strchr+0x2c>
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091c:	8a 10                	mov    (%eax),%dl
  80091e:	84 d2                	test   %dl,%dl
  800920:	74 11                	je     800933 <strfind+0x20>
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	75 06                	jne    80092c <strfind+0x19>
  800926:	eb 0b                	jmp    800933 <strfind+0x20>
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	74 07                	je     800933 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092c:	40                   	inc    %eax
  80092d:	8a 10                	mov    (%eax),%dl
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f5                	jne    800928 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 30                	je     800978 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 25                	jne    800975 <memset+0x40>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 20                	jne    800975 <memset+0x40>
		c &= 0xFF;
  800955:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 d0                	or     %edx,%eax
  80096b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800970:	fc                   	cld    
  800971:	f3 ab                	rep stos %eax,%es:(%edi)
  800973:	eb 03                	jmp    800978 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098d:	39 c6                	cmp    %eax,%esi
  80098f:	73 34                	jae    8009c5 <memmove+0x46>
  800991:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800994:	39 d0                	cmp    %edx,%eax
  800996:	73 2d                	jae    8009c5 <memmove+0x46>
		s += n;
		d += n;
  800998:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	75 1b                	jne    8009bb <memmove+0x3c>
  8009a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a6:	75 13                	jne    8009bb <memmove+0x3c>
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 0e                	jne    8009bb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ad:	83 ef 04             	sub    $0x4,%edi
  8009b0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b6:	fd                   	std    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 07                	jmp    8009c2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bb:	4f                   	dec    %edi
  8009bc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c2:	fc                   	cld    
  8009c3:	eb 20                	jmp    8009e5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	75 13                	jne    8009e0 <memmove+0x61>
  8009cd:	a8 03                	test   $0x3,%al
  8009cf:	75 0f                	jne    8009e0 <memmove+0x61>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0a                	jne    8009e0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 05                	jmp    8009e5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ec:	ff 75 10             	pushl  0x10(%ebp)
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	ff 75 08             	pushl  0x8(%ebp)
  8009f5:	e8 85 ff ff ff       	call   80097f <memmove>
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a08:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	74 32                	je     800a41 <memcmp+0x45>
		if (*s1 != *s2)
  800a0f:	8a 03                	mov    (%ebx),%al
  800a11:	8a 0e                	mov    (%esi),%cl
  800a13:	38 c8                	cmp    %cl,%al
  800a15:	74 19                	je     800a30 <memcmp+0x34>
  800a17:	eb 0d                	jmp    800a26 <memcmp+0x2a>
  800a19:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a1d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a21:	42                   	inc    %edx
  800a22:	38 c8                	cmp    %cl,%al
  800a24:	74 10                	je     800a36 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c0             	movzbl %al,%eax
  800a29:	0f b6 c9             	movzbl %cl,%ecx
  800a2c:	29 c8                	sub    %ecx,%eax
  800a2e:	eb 16                	jmp    800a46 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	4f                   	dec    %edi
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	39 fa                	cmp    %edi,%edx
  800a38:	75 df                	jne    800a19 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	eb 05                	jmp    800a46 <memcmp+0x4a>
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	73 12                	jae    800a6c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	75 06                	jne    800a67 <memfind+0x1c>
  800a61:	eb 09                	jmp    800a6c <memfind+0x21>
  800a63:	38 08                	cmp    %cl,(%eax)
  800a65:	74 05                	je     800a6c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	40                   	inc    %eax
  800a68:	39 c2                	cmp    %eax,%edx
  800a6a:	77 f7                	ja     800a63 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 01                	jmp    800a7d <strtol+0xf>
		s++;
  800a7c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7d:	8a 02                	mov    (%edx),%al
  800a7f:	3c 20                	cmp    $0x20,%al
  800a81:	74 f9                	je     800a7c <strtol+0xe>
  800a83:	3c 09                	cmp    $0x9,%al
  800a85:	74 f5                	je     800a7c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a87:	3c 2b                	cmp    $0x2b,%al
  800a89:	75 08                	jne    800a93 <strtol+0x25>
		s++;
  800a8b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	eb 13                	jmp    800aa6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	75 0a                	jne    800aa1 <strtol+0x33>
		s++, neg = 1;
  800a97:	8d 52 01             	lea    0x1(%edx),%edx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9f:	eb 05                	jmp    800aa6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 05                	je     800aaf <strtol+0x41>
  800aaa:	83 fb 10             	cmp    $0x10,%ebx
  800aad:	75 28                	jne    800ad7 <strtol+0x69>
  800aaf:	8a 02                	mov    (%edx),%al
  800ab1:	3c 30                	cmp    $0x30,%al
  800ab3:	75 10                	jne    800ac5 <strtol+0x57>
  800ab5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab9:	75 0a                	jne    800ac5 <strtol+0x57>
		s += 2, base = 16;
  800abb:	83 c2 02             	add    $0x2,%edx
  800abe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac3:	eb 12                	jmp    800ad7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	75 0e                	jne    800ad7 <strtol+0x69>
  800ac9:	3c 30                	cmp    $0x30,%al
  800acb:	75 05                	jne    800ad2 <strtol+0x64>
		s++, base = 8;
  800acd:	42                   	inc    %edx
  800ace:	b3 08                	mov    $0x8,%bl
  800ad0:	eb 05                	jmp    800ad7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ade:	8a 0a                	mov    (%edx),%cl
  800ae0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae3:	80 fb 09             	cmp    $0x9,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x82>
			dig = *s - '0';
  800ae8:	0f be c9             	movsbl %cl,%ecx
  800aeb:	83 e9 30             	sub    $0x30,%ecx
  800aee:	eb 1e                	jmp    800b0e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0x92>
			dig = *s - 'a' + 10;
  800af8:	0f be c9             	movsbl %cl,%ecx
  800afb:	83 e9 57             	sub    $0x57,%ecx
  800afe:	eb 0e                	jmp    800b0e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 13                	ja     800b1b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b08:	0f be c9             	movsbl %cl,%ecx
  800b0b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0e:	39 f1                	cmp    %esi,%ecx
  800b10:	7d 0d                	jge    800b1f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b12:	42                   	inc    %edx
  800b13:	0f af c6             	imul   %esi,%eax
  800b16:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b19:	eb c3                	jmp    800ade <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1b:	89 c1                	mov    %eax,%ecx
  800b1d:	eb 02                	jmp    800b21 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b25:	74 05                	je     800b2c <strtol+0xbe>
		*endptr = (char *) s;
  800b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	74 04                	je     800b34 <strtol+0xc6>
  800b30:	89 c8                	mov    %ecx,%eax
  800b32:	f7 d8                	neg    %eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    
  800b39:	00 00                	add    %al,(%eax)
	...

00800b3c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	83 ec 10             	sub    $0x10,%esp
  800b44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b47:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b4a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b50:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	75 2e                	jne    800b88 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b5a:	39 f1                	cmp    %esi,%ecx
  800b5c:	77 5a                	ja     800bb8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b5e:	85 c9                	test   %ecx,%ecx
  800b60:	75 0b                	jne    800b6d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	31 d2                	xor    %edx,%edx
  800b69:	f7 f1                	div    %ecx
  800b6b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b6d:	31 d2                	xor    %edx,%edx
  800b6f:	89 f0                	mov    %esi,%eax
  800b71:	f7 f1                	div    %ecx
  800b73:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b75:	89 f8                	mov    %edi,%eax
  800b77:	f7 f1                	div    %ecx
  800b79:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b7b:	89 f8                	mov    %edi,%eax
  800b7d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    
  800b86:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b88:	39 f0                	cmp    %esi,%eax
  800b8a:	77 1c                	ja     800ba8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b8c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b8f:	83 f7 1f             	xor    $0x1f,%edi
  800b92:	75 3c                	jne    800bd0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b94:	39 f0                	cmp    %esi,%eax
  800b96:	0f 82 90 00 00 00    	jb     800c2c <__udivdi3+0xf0>
  800b9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b9f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ba2:	0f 86 84 00 00 00    	jbe    800c2c <__udivdi3+0xf0>
  800ba8:	31 f6                	xor    %esi,%esi
  800baa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bac:	89 f8                	mov    %edi,%eax
  800bae:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    
  800bb7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bb8:	89 f2                	mov    %esi,%edx
  800bba:	89 f8                	mov    %edi,%eax
  800bbc:	f7 f1                	div    %ecx
  800bbe:	89 c7                	mov    %eax,%edi
  800bc0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc2:	89 f8                	mov    %edi,%eax
  800bc4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bc6:	83 c4 10             	add    $0x10,%esp
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bd0:	89 f9                	mov    %edi,%ecx
  800bd2:	d3 e0                	shl    %cl,%eax
  800bd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bd7:	b8 20 00 00 00       	mov    $0x20,%eax
  800bdc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be1:	88 c1                	mov    %al,%cl
  800be3:	d3 ea                	shr    %cl,%edx
  800be5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800be8:	09 ca                	or     %ecx,%edx
  800bea:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf0:	89 f9                	mov    %edi,%ecx
  800bf2:	d3 e2                	shl    %cl,%edx
  800bf4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800bf7:	89 f2                	mov    %esi,%edx
  800bf9:	88 c1                	mov    %al,%cl
  800bfb:	d3 ea                	shr    %cl,%edx
  800bfd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c00:	89 f2                	mov    %esi,%edx
  800c02:	89 f9                	mov    %edi,%ecx
  800c04:	d3 e2                	shl    %cl,%edx
  800c06:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c09:	88 c1                	mov    %al,%cl
  800c0b:	d3 ee                	shr    %cl,%esi
  800c0d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c0f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c12:	89 f0                	mov    %esi,%eax
  800c14:	89 ca                	mov    %ecx,%edx
  800c16:	f7 75 ec             	divl   -0x14(%ebp)
  800c19:	89 d1                	mov    %edx,%ecx
  800c1b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c1d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c20:	39 d1                	cmp    %edx,%ecx
  800c22:	72 28                	jb     800c4c <__udivdi3+0x110>
  800c24:	74 1a                	je     800c40 <__udivdi3+0x104>
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	31 f6                	xor    %esi,%esi
  800c2a:	eb 80                	jmp    800bac <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c2c:	31 f6                	xor    %esi,%esi
  800c2e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c33:	89 f8                	mov    %edi,%eax
  800c35:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    
  800c3e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c43:	89 f9                	mov    %edi,%ecx
  800c45:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c47:	39 c2                	cmp    %eax,%edx
  800c49:	73 db                	jae    800c26 <__udivdi3+0xea>
  800c4b:	90                   	nop
		{
		  q0--;
  800c4c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c4f:	31 f6                	xor    %esi,%esi
  800c51:	e9 56 ff ff ff       	jmp    800bac <__udivdi3+0x70>
	...

00800c58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	83 ec 20             	sub    $0x20,%esp
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c66:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c75:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c77:	85 ff                	test   %edi,%edi
  800c79:	75 15                	jne    800c90 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c7b:	39 f1                	cmp    %esi,%ecx
  800c7d:	0f 86 99 00 00 00    	jbe    800d1c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c83:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c85:	89 d0                	mov    %edx,%eax
  800c87:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c89:	83 c4 20             	add    $0x20,%esp
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c90:	39 f7                	cmp    %esi,%edi
  800c92:	0f 87 a4 00 00 00    	ja     800d3c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c98:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800c9b:	83 f0 1f             	xor    $0x1f,%eax
  800c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca1:	0f 84 a1 00 00 00    	je     800d48 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ca7:	89 f8                	mov    %edi,%eax
  800ca9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cac:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cae:	bf 20 00 00 00       	mov    $0x20,%edi
  800cb3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	d3 ea                	shr    %cl,%edx
  800cbd:	09 c2                	or     %eax,%edx
  800cbf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cc8:	d3 e0                	shl    %cl,%eax
  800cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ccd:	89 f2                	mov    %esi,%edx
  800ccf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cd4:	d3 e0                	shl    %cl,%eax
  800cd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cdc:	89 f9                	mov    %edi,%ecx
  800cde:	d3 e8                	shr    %cl,%eax
  800ce0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ce2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ce4:	89 f2                	mov    %esi,%edx
  800ce6:	f7 75 f0             	divl   -0x10(%ebp)
  800ce9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ceb:	f7 65 f4             	mull   -0xc(%ebp)
  800cee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800cf1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	72 71                	jb     800d68 <__umoddi3+0x110>
  800cf7:	74 7f                	je     800d78 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cfc:	29 c8                	sub    %ecx,%eax
  800cfe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d00:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 f2                	mov    %esi,%edx
  800d07:	89 f9                	mov    %edi,%ecx
  800d09:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d0b:	09 d0                	or     %edx,%eax
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d12:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d14:	83 c4 20             	add    $0x20,%esp
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    
  800d1b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d1c:	85 c9                	test   %ecx,%ecx
  800d1e:	75 0b                	jne    800d2b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d20:	b8 01 00 00 00       	mov    $0x1,%eax
  800d25:	31 d2                	xor    %edx,%edx
  800d27:	f7 f1                	div    %ecx
  800d29:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d2b:	89 f0                	mov    %esi,%eax
  800d2d:	31 d2                	xor    %edx,%edx
  800d2f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d34:	f7 f1                	div    %ecx
  800d36:	e9 4a ff ff ff       	jmp    800c85 <__umoddi3+0x2d>
  800d3b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d3c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d3e:	83 c4 20             	add    $0x20,%esp
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d48:	39 f7                	cmp    %esi,%edi
  800d4a:	72 05                	jb     800d51 <__umoddi3+0xf9>
  800d4c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d4f:	77 0c                	ja     800d5d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d51:	89 f2                	mov    %esi,%edx
  800d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d56:	29 c8                	sub    %ecx,%eax
  800d58:	19 fa                	sbb    %edi,%edx
  800d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d68:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d6b:	89 c1                	mov    %eax,%ecx
  800d6d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d70:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d73:	eb 84                	jmp    800cf9 <__umoddi3+0xa1>
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d7b:	72 eb                	jb     800d68 <__umoddi3+0x110>
  800d7d:	89 f2                	mov    %esi,%edx
  800d7f:	e9 75 ff ff ff       	jmp    800cf9 <__umoddi3+0xa1>