
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
  80003e:	e8 b2 00 00 00       	call   8000f5 <sys_cputs>
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
  800053:	e8 09 01 00 00       	call   800161 <sys_getenvid>
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
  80009c:	e8 9e 00 00 00       	call   80013f <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
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
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	8b 75 14             	mov    0x14(%ebp),%esi
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c5:	cd 30                	int    $0x30
  8000c7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8000cd:	74 1c                	je     8000eb <syscall+0x43>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7e 18                	jle    8000eb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000da:	68 e6 0d 80 00       	push   $0x800de6
  8000df:	6a 42                	push   $0x42
  8000e1:	68 03 0e 80 00       	push   $0x800e03
  8000e6:	e8 9d 00 00 00       	call   800188 <_panic>

	return ret;
}
  8000eb:	89 d0                	mov    %edx,%eax
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800107:	ba 00 00 00 00       	mov    $0x0,%edx
  80010c:	b8 00 00 00 00       	mov    $0x0,%eax
  800111:	e8 92 ff ff ff       	call   8000a8 <syscall>
  800116:	83 c4 10             	add    $0x10,%esp
	return;
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <sys_cgetc>:

int
sys_cgetc(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 01 00 00 00       	mov    $0x1,%eax
  800138:	e8 6b ff ff ff       	call   8000a8 <syscall>
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	6a 00                	push   $0x0
  80014b:	6a 00                	push   $0x0
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	ba 01 00 00 00       	mov    $0x1,%edx
  800155:	b8 03 00 00 00       	mov    $0x3,%eax
  80015a:	e8 49 ff ff ff       	call   8000a8 <syscall>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	e8 25 ff ff ff       	call   8000a8 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80018d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800190:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800196:	e8 c6 ff ff ff       	call   800161 <sys_getenvid>
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 0c             	pushl  0xc(%ebp)
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	53                   	push   %ebx
  8001a5:	50                   	push   %eax
  8001a6:	68 14 0e 80 00       	push   $0x800e14
  8001ab:	e8 b0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	83 c4 18             	add    $0x18,%esp
  8001b3:	56                   	push   %esi
  8001b4:	ff 75 10             	pushl  0x10(%ebp)
  8001b7:	e8 53 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bc:	c7 04 24 38 0e 80 00 	movl   $0x800e38,(%esp)
  8001c3:	e8 98 00 00 00       	call   800260 <cprintf>
  8001c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x43>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 1a                	jne    800207 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	68 ff 00 00 00       	push   $0xff
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 f7 fe ff ff       	call   8000f5 <sys_cputs>
		b->idx = 0;
  8001fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800204:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800207:	ff 43 04             	incl   0x4(%ebx)
}
  80020a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	ff 75 0c             	pushl  0xc(%ebp)
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	50                   	push   %eax
  800239:	68 d0 01 80 00       	push   $0x8001d0
  80023e:	e8 82 01 00 00       	call   8003c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	83 c4 08             	add    $0x8,%esp
  800246:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	e8 9d fe ff ff       	call   8000f5 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 08             	pushl  0x8(%ebp)
  80026d:	e8 9d ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 2c             	sub    $0x2c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d6                	mov    %edx,%esi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	8b 55 0c             	mov    0xc(%ebp),%edx
  800288:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80028e:	8b 45 10             	mov    0x10(%ebp),%eax
  800291:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800294:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800297:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002a4:	72 0c                	jb     8002b2 <printnum+0x3e>
  8002a6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002a9:	76 07                	jbe    8002b2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	4b                   	dec    %ebx
  8002ac:	85 db                	test   %ebx,%ebx
  8002ae:	7f 31                	jg     8002e1 <printnum+0x6d>
  8002b0:	eb 3f                	jmp    8002f1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	57                   	push   %edi
  8002b6:	4b                   	dec    %ebx
  8002b7:	53                   	push   %ebx
  8002b8:	50                   	push   %eax
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c8:	e8 c7 08 00 00       	call   800b94 <__udivdi3>
  8002cd:	83 c4 18             	add    $0x18,%esp
  8002d0:	52                   	push   %edx
  8002d1:	50                   	push   %eax
  8002d2:	89 f2                	mov    %esi,%edx
  8002d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d7:	e8 98 ff ff ff       	call   800274 <printnum>
  8002dc:	83 c4 20             	add    $0x20,%esp
  8002df:	eb 10                	jmp    8002f1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	56                   	push   %esi
  8002e5:	57                   	push   %edi
  8002e6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e9:	4b                   	dec    %ebx
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	85 db                	test   %ebx,%ebx
  8002ef:	7f f0                	jg     8002e1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	83 ec 04             	sub    $0x4,%esp
  8002f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800301:	ff 75 d8             	pushl  -0x28(%ebp)
  800304:	e8 a7 09 00 00       	call   800cb0 <__umoddi3>
  800309:	83 c4 14             	add    $0x14,%esp
  80030c:	0f be 80 3a 0e 80 00 	movsbl 0x800e3a(%eax),%eax
  800313:	50                   	push   %eax
  800314:	ff 55 e4             	call   *-0x1c(%ebp)
  800317:	83 c4 10             	add    $0x10,%esp
}
  80031a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800325:	83 fa 01             	cmp    $0x1,%edx
  800328:	7e 0e                	jle    800338 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	8b 52 04             	mov    0x4(%edx),%edx
  800336:	eb 22                	jmp    80035a <getuint+0x38>
	else if (lflag)
  800338:	85 d2                	test   %edx,%edx
  80033a:	74 10                	je     80034c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
  80034a:	eb 0e                	jmp    80035a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035f:	83 fa 01             	cmp    $0x1,%edx
  800362:	7e 0e                	jle    800372 <getint+0x16>
		return va_arg(*ap, long long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 08             	lea    0x8(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	8b 52 04             	mov    0x4(%edx),%edx
  800370:	eb 1a                	jmp    80038c <getint+0x30>
	else if (lflag)
  800372:	85 d2                	test   %edx,%edx
  800374:	74 0c                	je     800382 <getint+0x26>
		return va_arg(*ap, long);
  800376:	8b 10                	mov    (%eax),%edx
  800378:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037b:	89 08                	mov    %ecx,(%eax)
  80037d:	8b 02                	mov    (%edx),%eax
  80037f:	99                   	cltd   
  800380:	eb 0a                	jmp    80038c <getint+0x30>
	else
		return va_arg(*ap, int);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	99                   	cltd   
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800394:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 08                	jae    8003a6 <sprintputch+0x18>
		*b->buf++ = ch;
  80039e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a1:	88 0a                	mov    %cl,(%edx)
  8003a3:	42                   	inc    %edx
  8003a4:	89 10                	mov    %edx,(%eax)
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b1:	50                   	push   %eax
  8003b2:	ff 75 10             	pushl  0x10(%ebp)
  8003b5:	ff 75 0c             	pushl  0xc(%ebp)
  8003b8:	ff 75 08             	pushl  0x8(%ebp)
  8003bb:	e8 05 00 00 00       	call   8003c5 <vprintfmt>
	va_end(ap);
  8003c0:	83 c4 10             	add    $0x10,%esp
}
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	57                   	push   %edi
  8003c9:	56                   	push   %esi
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 2c             	sub    $0x2c,%esp
  8003ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d4:	eb 13                	jmp    8003e9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	0f 84 6d 03 00 00    	je     80074b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	57                   	push   %edi
  8003e2:	50                   	push   %eax
  8003e3:	ff 55 08             	call   *0x8(%ebp)
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e4                	jne    8003d6 <vprintfmt+0x11>
  8003f2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003fd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800404:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800410:	eb 28                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800414:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800418:	eb 20                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800420:	eb 18                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800424:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042b:	eb 0d                	jmp    80043a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800433:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8a 06                	mov    (%esi),%al
  80043c:	0f b6 d0             	movzbl %al,%edx
  80043f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800442:	83 e8 23             	sub    $0x23,%eax
  800445:	3c 55                	cmp    $0x55,%al
  800447:	0f 87 e0 02 00 00    	ja     80072d <vprintfmt+0x368>
  80044d:	0f b6 c0             	movzbl %al,%eax
  800450:	ff 24 85 c8 0e 80 00 	jmp    *0x800ec8(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800457:	83 ea 30             	sub    $0x30,%edx
  80045a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80045d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800460:	8d 50 d0             	lea    -0x30(%eax),%edx
  800463:	83 fa 09             	cmp    $0x9,%edx
  800466:	77 44                	ja     8004ac <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	89 de                	mov    %ebx,%esi
  80046a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80046e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800471:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800475:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800478:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047b:	83 fb 09             	cmp    $0x9,%ebx
  80047e:	76 ed                	jbe    80046d <vprintfmt+0xa8>
  800480:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800483:	eb 29                	jmp    8004ae <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800495:	eb 17                	jmp    8004ae <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	78 85                	js     800422 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	89 de                	mov    %ebx,%esi
  80049f:	eb 99                	jmp    80043a <vprintfmt+0x75>
  8004a1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004aa:	eb 8e                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b2:	79 86                	jns    80043a <vprintfmt+0x75>
  8004b4:	e9 74 ff ff ff       	jmp    80042d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	e9 79 ff ff ff       	jmp    80043a <vprintfmt+0x75>
  8004c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	57                   	push   %edi
  8004d1:	ff 30                	pushl  (%eax)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004dc:	e9 08 ff ff ff       	jmp    8003e9 <vprintfmt+0x24>
  8004e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	79 02                	jns    8004f5 <vprintfmt+0x130>
  8004f3:	f7 d8                	neg    %eax
  8004f5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f7:	83 f8 06             	cmp    $0x6,%eax
  8004fa:	7f 0b                	jg     800507 <vprintfmt+0x142>
  8004fc:	8b 04 85 20 10 80 00 	mov    0x801020(,%eax,4),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	75 1a                	jne    800521 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800507:	52                   	push   %edx
  800508:	68 52 0e 80 00       	push   $0x800e52
  80050d:	57                   	push   %edi
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	e8 92 fe ff ff       	call   8003a8 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 c8 fe ff ff       	jmp    8003e9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800521:	50                   	push   %eax
  800522:	68 5b 0e 80 00       	push   $0x800e5b
  800527:	57                   	push   %edi
  800528:	ff 75 08             	pushl  0x8(%ebp)
  80052b:	e8 78 fe ff ff       	call   8003a8 <printfmt>
  800530:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800536:	e9 ae fe ff ff       	jmp    8003e9 <vprintfmt+0x24>
  80053b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80053e:	89 de                	mov    %ebx,%esi
  800540:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800543:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800554:	85 c0                	test   %eax,%eax
  800556:	75 07                	jne    80055f <vprintfmt+0x19a>
				p = "(null)";
  800558:	c7 45 d0 4b 0e 80 00 	movl   $0x800e4b,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80055f:	85 db                	test   %ebx,%ebx
  800561:	7e 42                	jle    8005a5 <vprintfmt+0x1e0>
  800563:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800567:	74 3c                	je     8005a5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	51                   	push   %ecx
  80056d:	ff 75 d0             	pushl  -0x30(%ebp)
  800570:	e8 6f 02 00 00       	call   8007e4 <strnlen>
  800575:	29 c3                	sub    %eax,%ebx
  800577:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	85 db                	test   %ebx,%ebx
  80057f:	7e 24                	jle    8005a5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800581:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800585:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800588:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	57                   	push   %edi
  80058f:	53                   	push   %ebx
  800590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	4e                   	dec    %esi
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	85 f6                	test   %esi,%esi
  800599:	7f f0                	jg     80058b <vprintfmt+0x1c6>
  80059b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80059e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a8:	0f be 02             	movsbl (%edx),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 47                	jne    8005f6 <vprintfmt+0x231>
  8005af:	eb 37                	jmp    8005e8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b5:	74 16                	je     8005cd <vprintfmt+0x208>
  8005b7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ba:	83 fa 5e             	cmp    $0x5e,%edx
  8005bd:	76 0e                	jbe    8005cd <vprintfmt+0x208>
					putch('?', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	57                   	push   %edi
  8005d1:	50                   	push   %eax
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005db:	0f be 03             	movsbl (%ebx),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	74 03                	je     8005e5 <vprintfmt+0x220>
  8005e2:	43                   	inc    %ebx
  8005e3:	eb 1b                	jmp    800600 <vprintfmt+0x23b>
  8005e5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ec:	7f 1e                	jg     80060c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f1:	e9 f3 fd ff ff       	jmp    8003e9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f9:	43                   	inc    %ebx
  8005fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800600:	85 f6                	test   %esi,%esi
  800602:	78 ad                	js     8005b1 <vprintfmt+0x1ec>
  800604:	4e                   	dec    %esi
  800605:	79 aa                	jns    8005b1 <vprintfmt+0x1ec>
  800607:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80060a:	eb dc                	jmp    8005e8 <vprintfmt+0x223>
  80060c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 20                	push   $0x20
  800615:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800618:	4b                   	dec    %ebx
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f ef                	jg     80060f <vprintfmt+0x24a>
  800620:	e9 c4 fd ff ff       	jmp    8003e9 <vprintfmt+0x24>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 2a fd ff ff       	call   80035c <getint>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800636:	85 d2                	test   %edx,%edx
  800638:	78 0a                	js     800644 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 b0 00 00 00       	jmp    8006f4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	57                   	push   %edi
  800648:	6a 2d                	push   $0x2d
  80064a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064d:	f7 db                	neg    %ebx
  80064f:	83 d6 00             	adc    $0x0,%esi
  800652:	f7 de                	neg    %esi
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065c:	e9 93 00 00 00       	jmp    8006f4 <vprintfmt+0x32f>
  800661:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	89 ca                	mov    %ecx,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 b4 fc ff ff       	call   800322 <getuint>
  80066e:	89 c3                	mov    %eax,%ebx
  800670:	89 d6                	mov    %edx,%esi
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800677:	eb 7b                	jmp    8006f4 <vprintfmt+0x32f>
  800679:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 d6 fc ff ff       	call   80035c <getint>
  800686:	89 c3                	mov    %eax,%ebx
  800688:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80068a:	85 d2                	test   %edx,%edx
  80068c:	78 07                	js     800695 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 5f                	jmp    8006f4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	57                   	push   %edi
  800699:	6a 2d                	push   $0x2d
  80069b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80069e:	f7 db                	neg    %ebx
  8006a0:	83 d6 00             	adc    $0x0,%esi
  8006a3:	f7 de                	neg    %esi
  8006a5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ad:	eb 45                	jmp    8006f4 <vprintfmt+0x32f>
  8006af:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	57                   	push   %edi
  8006b6:	6a 30                	push   $0x30
  8006b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	57                   	push   %edi
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cd:	8b 18                	mov    (%eax),%ebx
  8006cf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006dc:	eb 16                	jmp    8006f4 <vprintfmt+0x32f>
  8006de:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 37 fc ff ff       	call   800322 <getuint>
  8006eb:	89 c3                	mov    %eax,%ebx
  8006ed:	89 d6                	mov    %edx,%esi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006fb:	52                   	push   %edx
  8006fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ff:	50                   	push   %eax
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	89 fa                	mov    %edi,%edx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	e8 68 fb ff ff       	call   800274 <printnum>
			break;
  80070c:	83 c4 20             	add    $0x20,%esp
  80070f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800712:	e9 d2 fc ff ff       	jmp    8003e9 <vprintfmt+0x24>
  800717:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	57                   	push   %edi
  80071e:	52                   	push   %edx
  80071f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 bc fc ff ff       	jmp    8003e9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	6a 25                	push   $0x25
  800733:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 02                	jmp    80073d <vprintfmt+0x378>
  80073b:	89 c6                	mov    %eax,%esi
  80073d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800740:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800744:	75 f5                	jne    80073b <vprintfmt+0x376>
  800746:	e9 9e fc ff ff       	jmp    8003e9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800762:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800766:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800769:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800770:	85 c0                	test   %eax,%eax
  800772:	74 26                	je     80079a <vsnprintf+0x47>
  800774:	85 d2                	test   %edx,%edx
  800776:	7e 29                	jle    8007a1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800778:	ff 75 14             	pushl  0x14(%ebp)
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	68 8e 03 80 00       	push   $0x80038e
  800787:	e8 39 fc ff ff       	call   8003c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 0c                	jmp    8007a6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x53>
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	ff 75 08             	pushl  0x8(%ebp)
  8007bb:	e8 93 ff ff ff       	call   800753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    
	...

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3a 00             	cmpb   $0x0,(%edx)
  8007cd:	74 0e                	je     8007dd <strlen+0x19>
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d9:	75 f9                	jne    8007d4 <strlen+0x10>
  8007db:	eb 05                	jmp    8007e2 <strlen+0x1e>
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 17                	je     800808 <strnlen+0x24>
  8007f1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f4:	74 19                	je     80080f <strnlen+0x2b>
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007fb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 d0                	cmp    %edx,%eax
  8007fe:	74 14                	je     800814 <strnlen+0x30>
  800800:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800804:	75 f5                	jne    8007fb <strnlen+0x17>
  800806:	eb 0c                	jmp    800814 <strnlen+0x30>
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	eb 05                	jmp    800814 <strnlen+0x30>
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800828:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082b:	42                   	inc    %edx
  80082c:	84 c9                	test   %cl,%cl
  80082e:	75 f5                	jne    800825 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800830:	5b                   	pop    %ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 84 ff ff ff       	call   8007c4 <strlen>
  800840:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800849:	50                   	push   %eax
  80084a:	e8 c7 ff ff ff       	call   800816 <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	85 f6                	test   %esi,%esi
  800866:	74 15                	je     80087d <strncpy+0x27>
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80086d:	8a 1a                	mov    (%edx),%bl
  80086f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 3a 01             	cmpb   $0x1,(%edx)
  800875:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800878:	41                   	inc    %ecx
  800879:	39 ce                	cmp    %ecx,%esi
  80087b:	77 f0                	ja     80086d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 f6                	test   %esi,%esi
  800892:	74 32                	je     8008c6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800894:	83 fe 01             	cmp    $0x1,%esi
  800897:	74 22                	je     8008bb <strlcpy+0x3a>
  800899:	8a 0b                	mov    (%ebx),%cl
  80089b:	84 c9                	test   %cl,%cl
  80089d:	74 20                	je     8008bf <strlcpy+0x3e>
  80089f:	89 f8                	mov    %edi,%eax
  8008a1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008a6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a9:	88 08                	mov    %cl,(%eax)
  8008ab:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ac:	39 f2                	cmp    %esi,%edx
  8008ae:	74 11                	je     8008c1 <strlcpy+0x40>
  8008b0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008b4:	42                   	inc    %edx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	75 f0                	jne    8008a9 <strlcpy+0x28>
  8008b9:	eb 06                	jmp    8008c1 <strlcpy+0x40>
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	eb 02                	jmp    8008c1 <strlcpy+0x40>
  8008bf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c1:	c6 00 00             	movb   $0x0,(%eax)
  8008c4:	eb 02                	jmp    8008c8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008c8:	29 f8                	sub    %edi,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d8:	8a 01                	mov    (%ecx),%al
  8008da:	84 c0                	test   %al,%al
  8008dc:	74 10                	je     8008ee <strcmp+0x1f>
  8008de:	3a 02                	cmp    (%edx),%al
  8008e0:	75 0c                	jne    8008ee <strcmp+0x1f>
		p++, q++;
  8008e2:	41                   	inc    %ecx
  8008e3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e4:	8a 01                	mov    (%ecx),%al
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 04                	je     8008ee <strcmp+0x1f>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	74 f4                	je     8008e2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 c0             	movzbl %al,%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800905:	85 c0                	test   %eax,%eax
  800907:	74 1b                	je     800924 <strncmp+0x2c>
  800909:	8a 1a                	mov    (%edx),%bl
  80090b:	84 db                	test   %bl,%bl
  80090d:	74 24                	je     800933 <strncmp+0x3b>
  80090f:	3a 19                	cmp    (%ecx),%bl
  800911:	75 20                	jne    800933 <strncmp+0x3b>
  800913:	48                   	dec    %eax
  800914:	74 15                	je     80092b <strncmp+0x33>
		n--, p++, q++;
  800916:	42                   	inc    %edx
  800917:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800918:	8a 1a                	mov    (%edx),%bl
  80091a:	84 db                	test   %bl,%bl
  80091c:	74 15                	je     800933 <strncmp+0x3b>
  80091e:	3a 19                	cmp    (%ecx),%bl
  800920:	74 f1                	je     800913 <strncmp+0x1b>
  800922:	eb 0f                	jmp    800933 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
  800929:	eb 05                	jmp    800930 <strncmp+0x38>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800930:	5b                   	pop    %ebx
  800931:	c9                   	leave  
  800932:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800933:	0f b6 02             	movzbl (%edx),%eax
  800936:	0f b6 11             	movzbl (%ecx),%edx
  800939:	29 d0                	sub    %edx,%eax
  80093b:	eb f3                	jmp    800930 <strncmp+0x38>

0080093d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800946:	8a 10                	mov    (%eax),%dl
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 18                	je     800964 <strchr+0x27>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	75 06                	jne    800956 <strchr+0x19>
  800950:	eb 17                	jmp    800969 <strchr+0x2c>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 13                	je     800969 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800956:	40                   	inc    %eax
  800957:	8a 10                	mov    (%eax),%dl
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f5                	jne    800952 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
  800962:	eb 05                	jmp    800969 <strchr+0x2c>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800974:	8a 10                	mov    (%eax),%dl
  800976:	84 d2                	test   %dl,%dl
  800978:	74 11                	je     80098b <strfind+0x20>
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	75 06                	jne    800984 <strfind+0x19>
  80097e:	eb 0b                	jmp    80098b <strfind+0x20>
  800980:	38 ca                	cmp    %cl,%dl
  800982:	74 07                	je     80098b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800984:	40                   	inc    %eax
  800985:	8a 10                	mov    (%eax),%dl
  800987:	84 d2                	test   %dl,%dl
  800989:	75 f5                	jne    800980 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 7d 08             	mov    0x8(%ebp),%edi
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099c:	85 c9                	test   %ecx,%ecx
  80099e:	74 30                	je     8009d0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a6:	75 25                	jne    8009cd <memset+0x40>
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 20                	jne    8009cd <memset+0x40>
		c &= 0xFF;
  8009ad:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b0:	89 d3                	mov    %edx,%ebx
  8009b2:	c1 e3 08             	shl    $0x8,%ebx
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	c1 e6 18             	shl    $0x18,%esi
  8009ba:	89 d0                	mov    %edx,%eax
  8009bc:	c1 e0 10             	shl    $0x10,%eax
  8009bf:	09 f0                	or     %esi,%eax
  8009c1:	09 d0                	or     %edx,%eax
  8009c3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c8:	fc                   	cld    
  8009c9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cb:	eb 03                	jmp    8009d0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cd:	fc                   	cld    
  8009ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d0:	89 f8                	mov    %edi,%eax
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e5:	39 c6                	cmp    %eax,%esi
  8009e7:	73 34                	jae    800a1d <memmove+0x46>
  8009e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ec:	39 d0                	cmp    %edx,%eax
  8009ee:	73 2d                	jae    800a1d <memmove+0x46>
		s += n;
		d += n;
  8009f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	f6 c2 03             	test   $0x3,%dl
  8009f6:	75 1b                	jne    800a13 <memmove+0x3c>
  8009f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fe:	75 13                	jne    800a13 <memmove+0x3c>
  800a00:	f6 c1 03             	test   $0x3,%cl
  800a03:	75 0e                	jne    800a13 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a05:	83 ef 04             	sub    $0x4,%edi
  800a08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 07                	jmp    800a1a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a13:	4f                   	dec    %edi
  800a14:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a17:	fd                   	std    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1a:	fc                   	cld    
  800a1b:	eb 20                	jmp    800a3d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a23:	75 13                	jne    800a38 <memmove+0x61>
  800a25:	a8 03                	test   $0x3,%al
  800a27:	75 0f                	jne    800a38 <memmove+0x61>
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 0a                	jne    800a38 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb 05                	jmp    800a3d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	fc                   	cld    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a44:	ff 75 10             	pushl  0x10(%ebp)
  800a47:	ff 75 0c             	pushl  0xc(%ebp)
  800a4a:	ff 75 08             	pushl  0x8(%ebp)
  800a4d:	e8 85 ff ff ff       	call   8009d7 <memmove>
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a60:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	85 ff                	test   %edi,%edi
  800a65:	74 32                	je     800a99 <memcmp+0x45>
		if (*s1 != *s2)
  800a67:	8a 03                	mov    (%ebx),%al
  800a69:	8a 0e                	mov    (%esi),%cl
  800a6b:	38 c8                	cmp    %cl,%al
  800a6d:	74 19                	je     800a88 <memcmp+0x34>
  800a6f:	eb 0d                	jmp    800a7e <memcmp+0x2a>
  800a71:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a75:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a79:	42                   	inc    %edx
  800a7a:	38 c8                	cmp    %cl,%al
  800a7c:	74 10                	je     800a8e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a7e:	0f b6 c0             	movzbl %al,%eax
  800a81:	0f b6 c9             	movzbl %cl,%ecx
  800a84:	29 c8                	sub    %ecx,%eax
  800a86:	eb 16                	jmp    800a9e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a88:	4f                   	dec    %edi
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	39 fa                	cmp    %edi,%edx
  800a90:	75 df                	jne    800a71 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	eb 05                	jmp    800a9e <memcmp+0x4a>
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	73 12                	jae    800ac4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ab5:	38 08                	cmp    %cl,(%eax)
  800ab7:	75 06                	jne    800abf <memfind+0x1c>
  800ab9:	eb 09                	jmp    800ac4 <memfind+0x21>
  800abb:	38 08                	cmp    %cl,(%eax)
  800abd:	74 05                	je     800ac4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abf:	40                   	inc    %eax
  800ac0:	39 c2                	cmp    %eax,%edx
  800ac2:	77 f7                	ja     800abb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad2:	eb 01                	jmp    800ad5 <strtol+0xf>
		s++;
  800ad4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad5:	8a 02                	mov    (%edx),%al
  800ad7:	3c 20                	cmp    $0x20,%al
  800ad9:	74 f9                	je     800ad4 <strtol+0xe>
  800adb:	3c 09                	cmp    $0x9,%al
  800add:	74 f5                	je     800ad4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adf:	3c 2b                	cmp    $0x2b,%al
  800ae1:	75 08                	jne    800aeb <strtol+0x25>
		s++;
  800ae3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae9:	eb 13                	jmp    800afe <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aeb:	3c 2d                	cmp    $0x2d,%al
  800aed:	75 0a                	jne    800af9 <strtol+0x33>
		s++, neg = 1;
  800aef:	8d 52 01             	lea    0x1(%edx),%edx
  800af2:	bf 01 00 00 00       	mov    $0x1,%edi
  800af7:	eb 05                	jmp    800afe <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afe:	85 db                	test   %ebx,%ebx
  800b00:	74 05                	je     800b07 <strtol+0x41>
  800b02:	83 fb 10             	cmp    $0x10,%ebx
  800b05:	75 28                	jne    800b2f <strtol+0x69>
  800b07:	8a 02                	mov    (%edx),%al
  800b09:	3c 30                	cmp    $0x30,%al
  800b0b:	75 10                	jne    800b1d <strtol+0x57>
  800b0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b11:	75 0a                	jne    800b1d <strtol+0x57>
		s += 2, base = 16;
  800b13:	83 c2 02             	add    $0x2,%edx
  800b16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1b:	eb 12                	jmp    800b2f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	75 0e                	jne    800b2f <strtol+0x69>
  800b21:	3c 30                	cmp    $0x30,%al
  800b23:	75 05                	jne    800b2a <strtol+0x64>
		s++, base = 8;
  800b25:	42                   	inc    %edx
  800b26:	b3 08                	mov    $0x8,%bl
  800b28:	eb 05                	jmp    800b2f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b36:	8a 0a                	mov    (%edx),%cl
  800b38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b3b:	80 fb 09             	cmp    $0x9,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0x82>
			dig = *s - '0';
  800b40:	0f be c9             	movsbl %cl,%ecx
  800b43:	83 e9 30             	sub    $0x30,%ecx
  800b46:	eb 1e                	jmp    800b66 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b50:	0f be c9             	movsbl %cl,%ecx
  800b53:	83 e9 57             	sub    $0x57,%ecx
  800b56:	eb 0e                	jmp    800b66 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b5b:	80 fb 19             	cmp    $0x19,%bl
  800b5e:	77 13                	ja     800b73 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b66:	39 f1                	cmp    %esi,%ecx
  800b68:	7d 0d                	jge    800b77 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b6a:	42                   	inc    %edx
  800b6b:	0f af c6             	imul   %esi,%eax
  800b6e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b71:	eb c3                	jmp    800b36 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b73:	89 c1                	mov    %eax,%ecx
  800b75:	eb 02                	jmp    800b79 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b77:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7d:	74 05                	je     800b84 <strtol+0xbe>
		*endptr = (char *) s;
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b82:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b84:	85 ff                	test   %edi,%edi
  800b86:	74 04                	je     800b8c <strtol+0xc6>
  800b88:	89 c8                	mov    %ecx,%eax
  800b8a:	f7 d8                	neg    %eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    
  800b91:	00 00                	add    %al,(%eax)
	...

00800b94 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	83 ec 10             	sub    $0x10,%esp
  800b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ba2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ba8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bab:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	75 2e                	jne    800be0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800bb2:	39 f1                	cmp    %esi,%ecx
  800bb4:	77 5a                	ja     800c10 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800bb6:	85 c9                	test   %ecx,%ecx
  800bb8:	75 0b                	jne    800bc5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bba:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbf:	31 d2                	xor    %edx,%edx
  800bc1:	f7 f1                	div    %ecx
  800bc3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bc5:	31 d2                	xor    %edx,%edx
  800bc7:	89 f0                	mov    %esi,%eax
  800bc9:	f7 f1                	div    %ecx
  800bcb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	f7 f1                	div    %ecx
  800bd1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800bd3:	89 f8                	mov    %edi,%eax
  800bd5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    
  800bde:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800be0:	39 f0                	cmp    %esi,%eax
  800be2:	77 1c                	ja     800c00 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800be4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800be7:	83 f7 1f             	xor    $0x1f,%edi
  800bea:	75 3c                	jne    800c28 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800bec:	39 f0                	cmp    %esi,%eax
  800bee:	0f 82 90 00 00 00    	jb     800c84 <__udivdi3+0xf0>
  800bf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800bfa:	0f 86 84 00 00 00    	jbe    800c84 <__udivdi3+0xf0>
  800c00:	31 f6                	xor    %esi,%esi
  800c02:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c04:	89 f8                	mov    %edi,%eax
  800c06:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    
  800c0f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c10:	89 f2                	mov    %esi,%edx
  800c12:	89 f8                	mov    %edi,%eax
  800c14:	f7 f1                	div    %ecx
  800c16:	89 c7                	mov    %eax,%edi
  800c18:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c1a:	89 f8                	mov    %edi,%eax
  800c1c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    
  800c25:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c28:	89 f9                	mov    %edi,%ecx
  800c2a:	d3 e0                	shl    %cl,%eax
  800c2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c2f:	b8 20 00 00 00       	mov    $0x20,%eax
  800c34:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c39:	88 c1                	mov    %al,%cl
  800c3b:	d3 ea                	shr    %cl,%edx
  800c3d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c40:	09 ca                	or     %ecx,%edx
  800c42:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c48:	89 f9                	mov    %edi,%ecx
  800c4a:	d3 e2                	shl    %cl,%edx
  800c4c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c4f:	89 f2                	mov    %esi,%edx
  800c51:	88 c1                	mov    %al,%cl
  800c53:	d3 ea                	shr    %cl,%edx
  800c55:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c58:	89 f2                	mov    %esi,%edx
  800c5a:	89 f9                	mov    %edi,%ecx
  800c5c:	d3 e2                	shl    %cl,%edx
  800c5e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c61:	88 c1                	mov    %al,%cl
  800c63:	d3 ee                	shr    %cl,%esi
  800c65:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c67:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	89 ca                	mov    %ecx,%edx
  800c6e:	f7 75 ec             	divl   -0x14(%ebp)
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800c75:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c78:	39 d1                	cmp    %edx,%ecx
  800c7a:	72 28                	jb     800ca4 <__udivdi3+0x110>
  800c7c:	74 1a                	je     800c98 <__udivdi3+0x104>
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	31 f6                	xor    %esi,%esi
  800c82:	eb 80                	jmp    800c04 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c84:	31 f6                	xor    %esi,%esi
  800c86:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c8b:	89 f8                	mov    %edi,%eax
  800c8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    
  800c96:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c9b:	89 f9                	mov    %edi,%ecx
  800c9d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800c9f:	39 c2                	cmp    %eax,%edx
  800ca1:	73 db                	jae    800c7e <__udivdi3+0xea>
  800ca3:	90                   	nop
		{
		  q0--;
  800ca4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ca7:	31 f6                	xor    %esi,%esi
  800ca9:	e9 56 ff ff ff       	jmp    800c04 <__udivdi3+0x70>
	...

00800cb0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	83 ec 20             	sub    $0x20,%esp
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cbe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cc4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ccd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ccf:	85 ff                	test   %edi,%edi
  800cd1:	75 15                	jne    800ce8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800cd3:	39 f1                	cmp    %esi,%ecx
  800cd5:	0f 86 99 00 00 00    	jbe    800d74 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cdb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800cdd:	89 d0                	mov    %edx,%eax
  800cdf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ce1:	83 c4 20             	add    $0x20,%esp
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ce8:	39 f7                	cmp    %esi,%edi
  800cea:	0f 87 a4 00 00 00    	ja     800d94 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cf3:	83 f0 1f             	xor    $0x1f,%eax
  800cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cf9:	0f 84 a1 00 00 00    	je     800da0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d04:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d06:	bf 20 00 00 00       	mov    $0x20,%edi
  800d0b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	09 c2                	or     %eax,%edx
  800d17:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d20:	d3 e0                	shl    %cl,%eax
  800d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d25:	89 f2                	mov    %esi,%edx
  800d27:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d2c:	d3 e0                	shl    %cl,%eax
  800d2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d34:	89 f9                	mov    %edi,%ecx
  800d36:	d3 e8                	shr    %cl,%eax
  800d38:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d3a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	f7 75 f0             	divl   -0x10(%ebp)
  800d41:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d43:	f7 65 f4             	mull   -0xc(%ebp)
  800d46:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d49:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d4b:	39 d6                	cmp    %edx,%esi
  800d4d:	72 71                	jb     800dc0 <__umoddi3+0x110>
  800d4f:	74 7f                	je     800dd0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d54:	29 c8                	sub    %ecx,%eax
  800d56:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d58:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	89 f9                	mov    %edi,%ecx
  800d61:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d63:	09 d0                	or     %edx,%eax
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d6a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d6c:	83 c4 20             	add    $0x20,%esp
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    
  800d73:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d74:	85 c9                	test   %ecx,%ecx
  800d76:	75 0b                	jne    800d83 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d78:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	f7 f1                	div    %ecx
  800d81:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d83:	89 f0                	mov    %esi,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d8c:	f7 f1                	div    %ecx
  800d8e:	e9 4a ff ff ff       	jmp    800cdd <__umoddi3+0x2d>
  800d93:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800d94:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d96:	83 c4 20             	add    $0x20,%esp
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800da0:	39 f7                	cmp    %esi,%edi
  800da2:	72 05                	jb     800da9 <__umoddi3+0xf9>
  800da4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800da7:	77 0c                	ja     800db5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da9:	89 f2                	mov    %esi,%edx
  800dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dae:	29 c8                	sub    %ecx,%eax
  800db0:	19 fa                	sbb    %edi,%edx
  800db2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800db8:	83 c4 20             	add    $0x20,%esp
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    
  800dbf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800dc8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dcb:	eb 84                	jmp    800d51 <__umoddi3+0xa1>
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dd0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800dd3:	72 eb                	jb     800dc0 <__umoddi3+0x110>
  800dd5:	89 f2                	mov    %esi,%edx
  800dd7:	e9 75 ff ff ff       	jmp    800d51 <__umoddi3+0xa1>
