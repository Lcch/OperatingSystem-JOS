
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
  80003e:	e8 51 00 00 00       	call   800094 <sys_cputs>
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
  80004b:	83 ec 08             	sub    $0x8,%esp
  80004e:	8b 45 08             	mov    0x8(%ebp),%eax
  800051:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800054:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80005b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	7e 08                	jle    80006a <libmain+0x22>
		binaryname = argv[0];
  800062:	8b 0a                	mov    (%edx),%ecx
  800064:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	52                   	push   %edx
  80006e:	50                   	push   %eax
  80006f:	e8 c0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800074:	e8 07 00 00 00       	call   800080 <exit>
  800079:	83 c4 10             	add    $0x10,%esp
}
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    
	...

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 44 00 00 00       	call   8000d1 <sys_env_destroy>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	57                   	push   %edi
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009a:	b8 00 00 00 00       	mov    $0x0,%eax
  80009f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a5:	89 c3                	mov    %eax,%ebx
  8000a7:	89 c7                	mov    %eax,%edi
  8000a9:	89 c6                	mov    %eax,%esi
  8000ab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5f                   	pop    %edi
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c2:	89 d1                	mov    %edx,%ecx
  8000c4:	89 d3                	mov    %edx,%ebx
  8000c6:	89 d7                	mov    %edx,%edi
  8000c8:	89 d6                	mov    %edx,%esi
  8000ca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000df:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 cb                	mov    %ecx,%ebx
  8000e9:	89 cf                	mov    %ecx,%edi
  8000eb:	89 ce                	mov    %ecx,%esi
  8000ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	7e 17                	jle    80010a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	6a 03                	push   $0x3
  8000f9:	68 92 0d 80 00       	push   $0x800d92
  8000fe:	6a 23                	push   $0x23
  800100:	68 af 0d 80 00       	push   $0x800daf
  800105:	e8 2a 00 00 00       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	c9                   	leave  
  800111:	c3                   	ret    

00800112 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	b8 02 00 00 00       	mov    $0x2,%eax
  800122:	89 d1                	mov    %edx,%ecx
  800124:	89 d3                	mov    %edx,%ebx
  800126:	89 d7                	mov    %edx,%edi
  800128:	89 d6                	mov    %edx,%esi
  80012a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800142:	e8 cb ff ff ff       	call   800112 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	53                   	push   %ebx
  800151:	50                   	push   %eax
  800152:	68 c0 0d 80 00       	push   $0x800dc0
  800157:	e8 b0 00 00 00       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	56                   	push   %esi
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 53 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 e4 0d 80 00 	movl   $0x800de4,(%esp)
  80016f:	e8 98 00 00 00       	call   80020c <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>
	...

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 03                	mov    (%ebx),%eax
  800188:	8b 55 08             	mov    0x8(%ebp),%edx
  80018b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018f:	40                   	inc    %eax
  800190:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 ea fe ff ff       	call   800094 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	ff 43 04             	incl   0x4(%ebx)
}
  8001b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 7c 01 80 00       	push   $0x80017c
  8001ea:	e8 82 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 90 fe ff ff       	call   800094 <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800212:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800215:	50                   	push   %eax
  800216:	ff 75 08             	pushl  0x8(%ebp)
  800219:	e8 9d ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800246:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80024d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800250:	72 0c                	jb     80025e <printnum+0x3e>
  800252:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800255:	76 07                	jbe    80025e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f 31                	jg     80028d <printnum+0x6d>
  80025c:	eb 3f                	jmp    80029d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	57                   	push   %edi
  800262:	4b                   	dec    %ebx
  800263:	53                   	push   %ebx
  800264:	50                   	push   %eax
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026b:	ff 75 d0             	pushl  -0x30(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 c7 08 00 00       	call   800b40 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800283:	e8 98 ff ff ff       	call   800220 <printnum>
  800288:	83 c4 20             	add    $0x20,%esp
  80028b:	eb 10                	jmp    80029d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	56                   	push   %esi
  800291:	57                   	push   %edi
  800292:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800295:	4b                   	dec    %ebx
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f f0                	jg     80028d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 a7 09 00 00       	call   800c5c <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 e6 0d 80 00 	movsbl 0x800de6(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002c3:	83 c4 10             	add    $0x10,%esp
}
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7e 0e                	jle    8002e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	eb 22                	jmp    800306 <getuint+0x38>
	else if (lflag)
  8002e4:	85 d2                	test   %edx,%edx
  8002e6:	74 10                	je     8002f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	eb 0e                	jmp    800306 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 fa 01             	cmp    $0x1,%edx
  80030e:	7e 0e                	jle    80031e <getint+0x16>
		return va_arg(*ap, long long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 08             	lea    0x8(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	8b 52 04             	mov    0x4(%edx),%edx
  80031c:	eb 1a                	jmp    800338 <getint+0x30>
	else if (lflag)
  80031e:	85 d2                	test   %edx,%edx
  800320:	74 0c                	je     80032e <getint+0x26>
		return va_arg(*ap, long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	99                   	cltd   
  80032c:	eb 0a                	jmp    800338 <getint+0x30>
	else
		return va_arg(*ap, int);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 04             	lea    0x4(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	99                   	cltd   
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800340:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 08                	jae    800352 <sprintputch+0x18>
		*b->buf++ = ch;
  80034a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034d:	88 0a                	mov    %cl,(%edx)
  80034f:	42                   	inc    %edx
  800350:	89 10                	mov    %edx,(%eax)
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
	va_end(ap);
  80036c:	83 c4 10             	add    $0x10,%esp
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 2c             	sub    $0x2c,%esp
  80037a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80037d:	8b 75 10             	mov    0x10(%ebp),%esi
  800380:	eb 13                	jmp    800395 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800382:	85 c0                	test   %eax,%eax
  800384:	0f 84 6d 03 00 00    	je     8006f7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	57                   	push   %edi
  80038e:	50                   	push   %eax
  80038f:	ff 55 08             	call   *0x8(%ebp)
  800392:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	0f b6 06             	movzbl (%esi),%eax
  800398:	46                   	inc    %esi
  800399:	83 f8 25             	cmp    $0x25,%eax
  80039c:	75 e4                	jne    800382 <vprintfmt+0x11>
  80039e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bc:	eb 28                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c4:	eb 20                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003cc:	eb 18                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d7:	eb 0d                	jmp    8003e6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003df:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8a 06                	mov    (%esi),%al
  8003e8:	0f b6 d0             	movzbl %al,%edx
  8003eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 e0 02 00 00    	ja     8006d9 <vprintfmt+0x368>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 74 0e 80 00 	jmp    *0x800e74(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	83 ea 30             	sub    $0x30,%edx
  800406:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800409:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80040c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040f:	83 fa 09             	cmp    $0x9,%edx
  800412:	77 44                	ja     800458 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	89 de                	mov    %ebx,%esi
  800416:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80041a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80041d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800421:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800424:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800427:	83 fb 09             	cmp    $0x9,%ebx
  80042a:	76 ed                	jbe    800419 <vprintfmt+0xa8>
  80042c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80042f:	eb 29                	jmp    80045a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800441:	eb 17                	jmp    80045a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800447:	78 85                	js     8003ce <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	89 de                	mov    %ebx,%esi
  80044b:	eb 99                	jmp    8003e6 <vprintfmt+0x75>
  80044d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800456:	eb 8e                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80045a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045e:	79 86                	jns    8003e6 <vprintfmt+0x75>
  800460:	e9 74 ff ff ff       	jmp    8003d9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800465:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	89 de                	mov    %ebx,%esi
  800468:	e9 79 ff ff ff       	jmp    8003e6 <vprintfmt+0x75>
  80046d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	57                   	push   %edi
  80047d:	ff 30                	pushl  (%eax)
  80047f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800488:	e9 08 ff ff ff       	jmp    800395 <vprintfmt+0x24>
  80048d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 02                	jns    8004a1 <vprintfmt+0x130>
  80049f:	f7 d8                	neg    %eax
  8004a1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 f8 06             	cmp    $0x6,%eax
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x142>
  8004a8:	8b 04 85 cc 0f 80 00 	mov    0x800fcc(,%eax,4),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 1a                	jne    8004cd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	52                   	push   %edx
  8004b4:	68 fe 0d 80 00       	push   $0x800dfe
  8004b9:	57                   	push   %edi
  8004ba:	ff 75 08             	pushl  0x8(%ebp)
  8004bd:	e8 92 fe ff ff       	call   800354 <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c8:	e9 c8 fe ff ff       	jmp    800395 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004cd:	50                   	push   %eax
  8004ce:	68 07 0e 80 00       	push   $0x800e07
  8004d3:	57                   	push   %edi
  8004d4:	ff 75 08             	pushl  0x8(%ebp)
  8004d7:	e8 78 fe ff ff       	call   800354 <printfmt>
  8004dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e2:	e9 ae fe ff ff       	jmp    800395 <vprintfmt+0x24>
  8004e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ea:	89 de                	mov    %ebx,%esi
  8004ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800500:	85 c0                	test   %eax,%eax
  800502:	75 07                	jne    80050b <vprintfmt+0x19a>
				p = "(null)";
  800504:	c7 45 d0 f7 0d 80 00 	movl   $0x800df7,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80050b:	85 db                	test   %ebx,%ebx
  80050d:	7e 42                	jle    800551 <vprintfmt+0x1e0>
  80050f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800513:	74 3c                	je     800551 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	51                   	push   %ecx
  800519:	ff 75 d0             	pushl  -0x30(%ebp)
  80051c:	e8 6f 02 00 00       	call   800790 <strnlen>
  800521:	29 c3                	sub    %eax,%ebx
  800523:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 db                	test   %ebx,%ebx
  80052b:	7e 24                	jle    800551 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80052d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800531:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800534:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	57                   	push   %edi
  80053b:	53                   	push   %ebx
  80053c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	4e                   	dec    %esi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	85 f6                	test   %esi,%esi
  800545:	7f f0                	jg     800537 <vprintfmt+0x1c6>
  800547:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800551:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800554:	0f be 02             	movsbl (%edx),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	75 47                	jne    8005a2 <vprintfmt+0x231>
  80055b:	eb 37                	jmp    800594 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800561:	74 16                	je     800579 <vprintfmt+0x208>
  800563:	8d 50 e0             	lea    -0x20(%eax),%edx
  800566:	83 fa 5e             	cmp    $0x5e,%edx
  800569:	76 0e                	jbe    800579 <vprintfmt+0x208>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	6a 3f                	push   $0x3f
  800571:	ff 55 08             	call   *0x8(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb 0b                	jmp    800584 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	50                   	push   %eax
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	ff 4d e4             	decl   -0x1c(%ebp)
  800587:	0f be 03             	movsbl (%ebx),%eax
  80058a:	85 c0                	test   %eax,%eax
  80058c:	74 03                	je     800591 <vprintfmt+0x220>
  80058e:	43                   	inc    %ebx
  80058f:	eb 1b                	jmp    8005ac <vprintfmt+0x23b>
  800591:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800598:	7f 1e                	jg     8005b8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059d:	e9 f3 fd ff ff       	jmp    800395 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a5:	43                   	inc    %ebx
  8005a6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005ac:	85 f6                	test   %esi,%esi
  8005ae:	78 ad                	js     80055d <vprintfmt+0x1ec>
  8005b0:	4e                   	dec    %esi
  8005b1:	79 aa                	jns    80055d <vprintfmt+0x1ec>
  8005b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b6:	eb dc                	jmp    800594 <vprintfmt+0x223>
  8005b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	6a 20                	push   $0x20
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	4b                   	dec    %ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	85 db                	test   %ebx,%ebx
  8005ca:	7f ef                	jg     8005bb <vprintfmt+0x24a>
  8005cc:	e9 c4 fd ff ff       	jmp    800395 <vprintfmt+0x24>
  8005d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 2a fd ff ff       	call   800308 <getint>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	78 0a                	js     8005f0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005eb:	e9 b0 00 00 00       	jmp    8006a0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	57                   	push   %edi
  8005f4:	6a 2d                	push   $0x2d
  8005f6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f9:	f7 db                	neg    %ebx
  8005fb:	83 d6 00             	adc    $0x0,%esi
  8005fe:	f7 de                	neg    %esi
  800600:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
  800608:	e9 93 00 00 00       	jmp    8006a0 <vprintfmt+0x32f>
  80060d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 b4 fc ff ff       	call   8002ce <getuint>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	89 d6                	mov    %edx,%esi
			base = 10;
  80061e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800623:	eb 7b                	jmp    8006a0 <vprintfmt+0x32f>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 d6 fc ff ff       	call   800308 <getint>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800636:	85 d2                	test   %edx,%edx
  800638:	78 07                	js     800641 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80063a:	b8 08 00 00 00       	mov    $0x8,%eax
  80063f:	eb 5f                	jmp    8006a0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	57                   	push   %edi
  800645:	6a 2d                	push   $0x2d
  800647:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80064a:	f7 db                	neg    %ebx
  80064c:	83 d6 00             	adc    $0x0,%esi
  80064f:	f7 de                	neg    %esi
  800651:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
  800659:	eb 45                	jmp    8006a0 <vprintfmt+0x32f>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	6a 30                	push   $0x30
  800664:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	57                   	push   %edi
  80066b:	6a 78                	push   $0x78
  80066d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800679:	8b 18                	mov    (%eax),%ebx
  80067b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800680:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800688:	eb 16                	jmp    8006a0 <vprintfmt+0x32f>
  80068a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	89 ca                	mov    %ecx,%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 37 fc ff ff       	call   8002ce <getuint>
  800697:	89 c3                	mov    %eax,%ebx
  800699:	89 d6                	mov    %edx,%esi
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006a7:	52                   	push   %edx
  8006a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	56                   	push   %esi
  8006ad:	53                   	push   %ebx
  8006ae:	89 fa                	mov    %edi,%edx
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	e8 68 fb ff ff       	call   800220 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
  8006bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006be:	e9 d2 fc ff ff       	jmp    800395 <vprintfmt+0x24>
  8006c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	57                   	push   %edi
  8006ca:	52                   	push   %edx
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d4:	e9 bc fc ff ff       	jmp    800395 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	57                   	push   %edi
  8006dd:	6a 25                	push   $0x25
  8006df:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb 02                	jmp    8006e9 <vprintfmt+0x378>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f0:	75 f5                	jne    8006e7 <vprintfmt+0x376>
  8006f2:	e9 9e fc ff ff       	jmp    800395 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5f                   	pop    %edi
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800712:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071c:	85 c0                	test   %eax,%eax
  80071e:	74 26                	je     800746 <vsnprintf+0x47>
  800720:	85 d2                	test   %edx,%edx
  800722:	7e 29                	jle    80074d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800724:	ff 75 14             	pushl  0x14(%ebp)
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	68 3a 03 80 00       	push   $0x80033a
  800733:	e8 39 fc ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb 0c                	jmp    800752 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 05                	jmp    800752 <vsnprintf+0x53>
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	50                   	push   %eax
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	ff 75 08             	pushl  0x8(%ebp)
  800767:	e8 93 ff ff ff       	call   8006ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    
	...

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3a 00             	cmpb   $0x0,(%edx)
  800779:	74 0e                	je     800789 <strlen+0x19>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800780:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800781:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800785:	75 f9                	jne    800780 <strlen+0x10>
  800787:	eb 05                	jmp    80078e <strlen+0x1e>
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 17                	je     8007b4 <strnlen+0x24>
  80079d:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a0:	74 19                	je     8007bb <strnlen+0x2b>
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 d0                	cmp    %edx,%eax
  8007aa:	74 14                	je     8007c0 <strnlen+0x30>
  8007ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b0:	75 f5                	jne    8007a7 <strnlen+0x17>
  8007b2:	eb 0c                	jmp    8007c0 <strnlen+0x30>
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	eb 05                	jmp    8007c0 <strnlen+0x30>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d7:	42                   	inc    %edx
  8007d8:	84 c9                	test   %cl,%cl
  8007da:	75 f5                	jne    8007d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e6:	53                   	push   %ebx
  8007e7:	e8 84 ff ff ff       	call   800770 <strlen>
  8007ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c7 ff ff ff       	call   8007c2 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	85 f6                	test   %esi,%esi
  800812:	74 15                	je     800829 <strncpy+0x27>
  800814:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800819:	8a 1a                	mov    (%edx),%bl
  80081b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081e:	80 3a 01             	cmpb   $0x1,(%edx)
  800821:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	41                   	inc    %ecx
  800825:	39 ce                	cmp    %ecx,%esi
  800827:	77 f0                	ja     800819 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	57                   	push   %edi
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 7d 08             	mov    0x8(%ebp),%edi
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800839:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	85 f6                	test   %esi,%esi
  80083e:	74 32                	je     800872 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800840:	83 fe 01             	cmp    $0x1,%esi
  800843:	74 22                	je     800867 <strlcpy+0x3a>
  800845:	8a 0b                	mov    (%ebx),%cl
  800847:	84 c9                	test   %cl,%cl
  800849:	74 20                	je     80086b <strlcpy+0x3e>
  80084b:	89 f8                	mov    %edi,%eax
  80084d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800852:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800855:	88 08                	mov    %cl,(%eax)
  800857:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800858:	39 f2                	cmp    %esi,%edx
  80085a:	74 11                	je     80086d <strlcpy+0x40>
  80085c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800860:	42                   	inc    %edx
  800861:	84 c9                	test   %cl,%cl
  800863:	75 f0                	jne    800855 <strlcpy+0x28>
  800865:	eb 06                	jmp    80086d <strlcpy+0x40>
  800867:	89 f8                	mov    %edi,%eax
  800869:	eb 02                	jmp    80086d <strlcpy+0x40>
  80086b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086d:	c6 00 00             	movb   $0x0,(%eax)
  800870:	eb 02                	jmp    800874 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800874:	29 f8                	sub    %edi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	8a 01                	mov    (%ecx),%al
  800886:	84 c0                	test   %al,%al
  800888:	74 10                	je     80089a <strcmp+0x1f>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	75 0c                	jne    80089a <strcmp+0x1f>
		p++, q++;
  80088e:	41                   	inc    %ecx
  80088f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800890:	8a 01                	mov    (%ecx),%al
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x1f>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 f4                	je     80088e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	74 1b                	je     8008d0 <strncmp+0x2c>
  8008b5:	8a 1a                	mov    (%edx),%bl
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	74 24                	je     8008df <strncmp+0x3b>
  8008bb:	3a 19                	cmp    (%ecx),%bl
  8008bd:	75 20                	jne    8008df <strncmp+0x3b>
  8008bf:	48                   	dec    %eax
  8008c0:	74 15                	je     8008d7 <strncmp+0x33>
		n--, p++, q++;
  8008c2:	42                   	inc    %edx
  8008c3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c4:	8a 1a                	mov    (%edx),%bl
  8008c6:	84 db                	test   %bl,%bl
  8008c8:	74 15                	je     8008df <strncmp+0x3b>
  8008ca:	3a 19                	cmp    (%ecx),%bl
  8008cc:	74 f1                	je     8008bf <strncmp+0x1b>
  8008ce:	eb 0f                	jmp    8008df <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	eb 05                	jmp    8008dc <strncmp+0x38>
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 02             	movzbl (%edx),%eax
  8008e2:	0f b6 11             	movzbl (%ecx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb f3                	jmp    8008dc <strncmp+0x38>

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	8a 10                	mov    (%eax),%dl
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	74 18                	je     800910 <strchr+0x27>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	75 06                	jne    800902 <strchr+0x19>
  8008fc:	eb 17                	jmp    800915 <strchr+0x2c>
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 13                	je     800915 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	40                   	inc    %eax
  800903:	8a 10                	mov    (%eax),%dl
  800905:	84 d2                	test   %dl,%dl
  800907:	75 f5                	jne    8008fe <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
  80090e:	eb 05                	jmp    800915 <strchr+0x2c>
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800920:	8a 10                	mov    (%eax),%dl
  800922:	84 d2                	test   %dl,%dl
  800924:	74 11                	je     800937 <strfind+0x20>
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	75 06                	jne    800930 <strfind+0x19>
  80092a:	eb 0b                	jmp    800937 <strfind+0x20>
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 07                	je     800937 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800930:	40                   	inc    %eax
  800931:	8a 10                	mov    (%eax),%dl
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f5                	jne    80092c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 30                	je     80097c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800952:	75 25                	jne    800979 <memset+0x40>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 20                	jne    800979 <memset+0x40>
		c &= 0xFF;
  800959:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095c:	89 d3                	mov    %edx,%ebx
  80095e:	c1 e3 08             	shl    $0x8,%ebx
  800961:	89 d6                	mov    %edx,%esi
  800963:	c1 e6 18             	shl    $0x18,%esi
  800966:	89 d0                	mov    %edx,%eax
  800968:	c1 e0 10             	shl    $0x10,%eax
  80096b:	09 f0                	or     %esi,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800971:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800974:	fc                   	cld    
  800975:	f3 ab                	rep stos %eax,%es:(%edi)
  800977:	eb 03                	jmp    80097c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 34                	jae    8009c9 <memmove+0x46>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2d                	jae    8009c9 <memmove+0x46>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	f6 c2 03             	test   $0x3,%dl
  8009a2:	75 1b                	jne    8009bf <memmove+0x3c>
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 13                	jne    8009bf <memmove+0x3c>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 07                	jmp    8009c6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	4f                   	dec    %edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 20                	jmp    8009e9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cf:	75 13                	jne    8009e4 <memmove+0x61>
  8009d1:	a8 03                	test   $0x3,%al
  8009d3:	75 0f                	jne    8009e4 <memmove+0x61>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009da:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 85 ff ff ff       	call   800983 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	85 ff                	test   %edi,%edi
  800a11:	74 32                	je     800a45 <memcmp+0x45>
		if (*s1 != *s2)
  800a13:	8a 03                	mov    (%ebx),%al
  800a15:	8a 0e                	mov    (%esi),%cl
  800a17:	38 c8                	cmp    %cl,%al
  800a19:	74 19                	je     800a34 <memcmp+0x34>
  800a1b:	eb 0d                	jmp    800a2a <memcmp+0x2a>
  800a1d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a21:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a25:	42                   	inc    %edx
  800a26:	38 c8                	cmp    %cl,%al
  800a28:	74 10                	je     800a3a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 c9             	movzbl %cl,%ecx
  800a30:	29 c8                	sub    %ecx,%eax
  800a32:	eb 16                	jmp    800a4a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	4f                   	dec    %edi
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	39 fa                	cmp    %edi,%edx
  800a3c:	75 df                	jne    800a1d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	eb 05                	jmp    800a4a <memcmp+0x4a>
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5a:	39 d0                	cmp    %edx,%eax
  800a5c:	73 12                	jae    800a70 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	75 06                	jne    800a6b <memfind+0x1c>
  800a65:	eb 09                	jmp    800a70 <memfind+0x21>
  800a67:	38 08                	cmp    %cl,(%eax)
  800a69:	74 05                	je     800a70 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6b:	40                   	inc    %eax
  800a6c:	39 c2                	cmp    %eax,%edx
  800a6e:	77 f7                	ja     800a67 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	eb 01                	jmp    800a81 <strtol+0xf>
		s++;
  800a80:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	8a 02                	mov    (%edx),%al
  800a83:	3c 20                	cmp    $0x20,%al
  800a85:	74 f9                	je     800a80 <strtol+0xe>
  800a87:	3c 09                	cmp    $0x9,%al
  800a89:	74 f5                	je     800a80 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8b:	3c 2b                	cmp    $0x2b,%al
  800a8d:	75 08                	jne    800a97 <strtol+0x25>
		s++;
  800a8f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
  800a95:	eb 13                	jmp    800aaa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a97:	3c 2d                	cmp    $0x2d,%al
  800a99:	75 0a                	jne    800aa5 <strtol+0x33>
		s++, neg = 1;
  800a9b:	8d 52 01             	lea    0x1(%edx),%edx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa3:	eb 05                	jmp    800aaa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 05                	je     800ab3 <strtol+0x41>
  800aae:	83 fb 10             	cmp    $0x10,%ebx
  800ab1:	75 28                	jne    800adb <strtol+0x69>
  800ab3:	8a 02                	mov    (%edx),%al
  800ab5:	3c 30                	cmp    $0x30,%al
  800ab7:	75 10                	jne    800ac9 <strtol+0x57>
  800ab9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abd:	75 0a                	jne    800ac9 <strtol+0x57>
		s += 2, base = 16;
  800abf:	83 c2 02             	add    $0x2,%edx
  800ac2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac7:	eb 12                	jmp    800adb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	75 0e                	jne    800adb <strtol+0x69>
  800acd:	3c 30                	cmp    $0x30,%al
  800acf:	75 05                	jne    800ad6 <strtol+0x64>
		s++, base = 8;
  800ad1:	42                   	inc    %edx
  800ad2:	b3 08                	mov    $0x8,%bl
  800ad4:	eb 05                	jmp    800adb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae2:	8a 0a                	mov    (%edx),%cl
  800ae4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae7:	80 fb 09             	cmp    $0x9,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x82>
			dig = *s - '0';
  800aec:	0f be c9             	movsbl %cl,%ecx
  800aef:	83 e9 30             	sub    $0x30,%ecx
  800af2:	eb 1e                	jmp    800b12 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afc:	0f be c9             	movsbl %cl,%ecx
  800aff:	83 e9 57             	sub    $0x57,%ecx
  800b02:	eb 0e                	jmp    800b12 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 13                	ja     800b1f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b0c:	0f be c9             	movsbl %cl,%ecx
  800b0f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b12:	39 f1                	cmp    %esi,%ecx
  800b14:	7d 0d                	jge    800b23 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b16:	42                   	inc    %edx
  800b17:	0f af c6             	imul   %esi,%eax
  800b1a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b1d:	eb c3                	jmp    800ae2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	89 c1                	mov    %eax,%ecx
  800b21:	eb 02                	jmp    800b25 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b23:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b29:	74 05                	je     800b30 <strtol+0xbe>
		*endptr = (char *) s;
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b30:	85 ff                	test   %edi,%edi
  800b32:	74 04                	je     800b38 <strtol+0xc6>
  800b34:	89 c8                	mov    %ecx,%eax
  800b36:	f7 d8                	neg    %eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    
  800b3d:	00 00                	add    %al,(%eax)
	...

00800b40 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	83 ec 10             	sub    $0x10,%esp
  800b48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800b4e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800b51:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800b54:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800b57:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	75 2e                	jne    800b8c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800b5e:	39 f1                	cmp    %esi,%ecx
  800b60:	77 5a                	ja     800bbc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800b62:	85 c9                	test   %ecx,%ecx
  800b64:	75 0b                	jne    800b71 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800b66:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6b:	31 d2                	xor    %edx,%edx
  800b6d:	f7 f1                	div    %ecx
  800b6f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800b71:	31 d2                	xor    %edx,%edx
  800b73:	89 f0                	mov    %esi,%eax
  800b75:	f7 f1                	div    %ecx
  800b77:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800b79:	89 f8                	mov    %edi,%eax
  800b7b:	f7 f1                	div    %ecx
  800b7d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800b7f:	89 f8                	mov    %edi,%eax
  800b81:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    
  800b8a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800b8c:	39 f0                	cmp    %esi,%eax
  800b8e:	77 1c                	ja     800bac <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800b90:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800b93:	83 f7 1f             	xor    $0x1f,%edi
  800b96:	75 3c                	jne    800bd4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800b98:	39 f0                	cmp    %esi,%eax
  800b9a:	0f 82 90 00 00 00    	jb     800c30 <__udivdi3+0xf0>
  800ba0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ba6:	0f 86 84 00 00 00    	jbe    800c30 <__udivdi3+0xf0>
  800bac:	31 f6                	xor    %esi,%esi
  800bae:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bb0:	89 f8                	mov    %edi,%eax
  800bb2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    
  800bbb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	89 f8                	mov    %edi,%eax
  800bc0:	f7 f1                	div    %ecx
  800bc2:	89 c7                	mov    %eax,%edi
  800bc4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    
  800bd1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800bd4:	89 f9                	mov    %edi,%ecx
  800bd6:	d3 e0                	shl    %cl,%eax
  800bd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800bdb:	b8 20 00 00 00       	mov    $0x20,%eax
  800be0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800be2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be5:	88 c1                	mov    %al,%cl
  800be7:	d3 ea                	shr    %cl,%edx
  800be9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800bec:	09 ca                	or     %ecx,%edx
  800bee:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800bf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf4:	89 f9                	mov    %edi,%ecx
  800bf6:	d3 e2                	shl    %cl,%edx
  800bf8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800bfb:	89 f2                	mov    %esi,%edx
  800bfd:	88 c1                	mov    %al,%cl
  800bff:	d3 ea                	shr    %cl,%edx
  800c01:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c04:	89 f2                	mov    %esi,%edx
  800c06:	89 f9                	mov    %edi,%ecx
  800c08:	d3 e2                	shl    %cl,%edx
  800c0a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c0d:	88 c1                	mov    %al,%cl
  800c0f:	d3 ee                	shr    %cl,%esi
  800c11:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c13:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c16:	89 f0                	mov    %esi,%eax
  800c18:	89 ca                	mov    %ecx,%edx
  800c1a:	f7 75 ec             	divl   -0x14(%ebp)
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c21:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c24:	39 d1                	cmp    %edx,%ecx
  800c26:	72 28                	jb     800c50 <__udivdi3+0x110>
  800c28:	74 1a                	je     800c44 <__udivdi3+0x104>
  800c2a:	89 f7                	mov    %esi,%edi
  800c2c:	31 f6                	xor    %esi,%esi
  800c2e:	eb 80                	jmp    800bb0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c37:	89 f8                	mov    %edi,%eax
  800c39:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    
  800c42:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c44:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c47:	89 f9                	mov    %edi,%ecx
  800c49:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c4b:	39 c2                	cmp    %eax,%edx
  800c4d:	73 db                	jae    800c2a <__udivdi3+0xea>
  800c4f:	90                   	nop
		{
		  q0--;
  800c50:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800c53:	31 f6                	xor    %esi,%esi
  800c55:	e9 56 ff ff ff       	jmp    800bb0 <__udivdi3+0x70>
	...

00800c5c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	83 ec 20             	sub    $0x20,%esp
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800c6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800c70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800c73:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800c79:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c7b:	85 ff                	test   %edi,%edi
  800c7d:	75 15                	jne    800c94 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800c7f:	39 f1                	cmp    %esi,%ecx
  800c81:	0f 86 99 00 00 00    	jbe    800d20 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c87:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800c89:	89 d0                	mov    %edx,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800c8d:	83 c4 20             	add    $0x20,%esp
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c94:	39 f7                	cmp    %esi,%edi
  800c96:	0f 87 a4 00 00 00    	ja     800d40 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c9c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800c9f:	83 f0 1f             	xor    $0x1f,%eax
  800ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca5:	0f 84 a1 00 00 00    	je     800d4c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cab:	89 f8                	mov    %edi,%eax
  800cad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800cb0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800cb2:	bf 20 00 00 00       	mov    $0x20,%edi
  800cb7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cbd:	89 f9                	mov    %edi,%ecx
  800cbf:	d3 ea                	shr    %cl,%edx
  800cc1:	09 c2                	or     %eax,%edx
  800cc3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ccc:	d3 e0                	shl    %cl,%eax
  800cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cd1:	89 f2                	mov    %esi,%edx
  800cd3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cd8:	d3 e0                	shl    %cl,%eax
  800cda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800cdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ce0:	89 f9                	mov    %edi,%ecx
  800ce2:	d3 e8                	shr    %cl,%eax
  800ce4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ce6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ce8:	89 f2                	mov    %esi,%edx
  800cea:	f7 75 f0             	divl   -0x10(%ebp)
  800ced:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800cef:	f7 65 f4             	mull   -0xc(%ebp)
  800cf2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800cf5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cf7:	39 d6                	cmp    %edx,%esi
  800cf9:	72 71                	jb     800d6c <__umoddi3+0x110>
  800cfb:	74 7f                	je     800d7c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d00:	29 c8                	sub    %ecx,%eax
  800d02:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d04:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d0f:	09 d0                	or     %edx,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d16:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d18:	83 c4 20             	add    $0x20,%esp
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    
  800d1f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d20:	85 c9                	test   %ecx,%ecx
  800d22:	75 0b                	jne    800d2f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d24:	b8 01 00 00 00       	mov    $0x1,%eax
  800d29:	31 d2                	xor    %edx,%edx
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d38:	f7 f1                	div    %ecx
  800d3a:	e9 4a ff ff ff       	jmp    800c89 <__umoddi3+0x2d>
  800d3f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d40:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d42:	83 c4 20             	add    $0x20,%esp
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    
  800d49:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d4c:	39 f7                	cmp    %esi,%edi
  800d4e:	72 05                	jb     800d55 <__umoddi3+0xf9>
  800d50:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800d53:	77 0c                	ja     800d61 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d55:	89 f2                	mov    %esi,%edx
  800d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5a:	29 c8                	sub    %ecx,%eax
  800d5c:	19 fa                	sbb    %edi,%edx
  800d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d64:	83 c4 20             	add    $0x20,%esp
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    
  800d6b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800d74:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800d77:	eb 84                	jmp    800cfd <__umoddi3+0xa1>
  800d79:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800d7f:	72 eb                	jb     800d6c <__umoddi3+0x110>
  800d81:	89 f2                	mov    %esi,%edx
  800d83:	e9 75 ff ff ff       	jmp    800cfd <__umoddi3+0xa1>
