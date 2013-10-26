
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 07                	push   $0x7
  800044:	53                   	push   %ebx
  800045:	56                   	push   %esi
  800046:	e8 05 0d 00 00       	call   800d50 <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800052:	50                   	push   %eax
  800053:	68 c0 10 80 00       	push   $0x8010c0
  800058:	6a 20                	push   $0x20
  80005a:	68 d3 10 80 00       	push   $0x8010d3
  80005f:	e8 dc 01 00 00       	call   800240 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	6a 07                	push   $0x7
  800069:	68 00 00 40 00       	push   $0x400000
  80006e:	6a 00                	push   $0x0
  800070:	53                   	push   %ebx
  800071:	56                   	push   %esi
  800072:	e8 fd 0c 00 00       	call   800d74 <sys_page_map>
  800077:	83 c4 20             	add    $0x20,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	79 12                	jns    800090 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007e:	50                   	push   %eax
  80007f:	68 e3 10 80 00       	push   $0x8010e3
  800084:	6a 22                	push   $0x22
  800086:	68 d3 10 80 00       	push   $0x8010d3
  80008b:	e8 b0 01 00 00       	call   800240 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	68 00 10 00 00       	push   $0x1000
  800098:	53                   	push   %ebx
  800099:	68 00 00 40 00       	push   $0x400000
  80009e:	e8 ec 09 00 00       	call   800a8f <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	68 00 00 40 00       	push   $0x400000
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 e8 0c 00 00       	call   800d9a <sys_page_unmap>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 12                	jns    8000cb <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b9:	50                   	push   %eax
  8000ba:	68 f4 10 80 00       	push   $0x8010f4
  8000bf:	6a 25                	push   $0x25
  8000c1:	68 d3 10 80 00       	push   $0x8010d3
  8000c6:	e8 75 01 00 00       	call   800240 <_panic>
}
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000da:	be 07 00 00 00       	mov    $0x7,%esi
  8000df:	89 f0                	mov    %esi,%eax
  8000e1:	cd 30                	int    $0x30
  8000e3:	89 c6                	mov    %eax,%esi
  8000e5:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	79 12                	jns    8000fd <dumbfork+0x2b>
		panic("sys_exofork: %e", envid);
  8000eb:	50                   	push   %eax
  8000ec:	68 07 11 80 00       	push   $0x801107
  8000f1:	6a 37                	push   $0x37
  8000f3:	68 d3 10 80 00       	push   $0x8010d3
  8000f8:	e8 43 01 00 00       	call   800240 <_panic>
	if (envid == 0) {
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	75 19                	jne    80011a <dumbfork+0x48>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 ff 0b 00 00       	call   800d05 <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	c1 e0 07             	shl    $0x7,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800118:	eb 6d                	jmp    800187 <dumbfork+0xb5>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011a:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800121:	b8 08 20 80 00       	mov    $0x802008,%eax
  800126:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80012b:	76 24                	jbe    800151 <dumbfork+0x7f>
  80012d:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	50                   	push   %eax
  800136:	53                   	push   %ebx
  800137:	e8 f8 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80013c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80013f:	05 00 10 00 00       	add    $0x1000,%eax
  800144:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	3d 08 20 80 00       	cmp    $0x802008,%eax
  80014f:	72 e1                	jb     800132 <dumbfork+0x60>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800151:	83 ec 08             	sub    $0x8,%esp
  800154:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800157:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80015c:	50                   	push   %eax
  80015d:	56                   	push   %esi
  80015e:	e8 d1 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800163:	83 c4 08             	add    $0x8,%esp
  800166:	6a 02                	push   $0x2
  800168:	56                   	push   %esi
  800169:	e8 4f 0c 00 00       	call   800dbd <sys_env_set_status>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	85 c0                	test   %eax,%eax
  800173:	79 12                	jns    800187 <dumbfork+0xb5>
		panic("sys_env_set_status: %e", r);
  800175:	50                   	push   %eax
  800176:	68 17 11 80 00       	push   $0x801117
  80017b:	6a 4c                	push   $0x4c
  80017d:	68 d3 10 80 00       	push   $0x8010d3
  800182:	e8 b9 00 00 00       	call   800240 <_panic>

	return envid;
}
  800187:	89 f0                	mov    %esi,%eax
  800189:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800195:	e8 38 ff ff ff       	call   8000d2 <dumbfork>
  80019a:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80019c:	be 00 00 00 00       	mov    $0x0,%esi
  8001a1:	eb 28                	jmp    8001cb <umain+0x3b>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a3:	85 db                	test   %ebx,%ebx
  8001a5:	74 07                	je     8001ae <umain+0x1e>
  8001a7:	b8 2e 11 80 00       	mov    $0x80112e,%eax
  8001ac:	eb 05                	jmp    8001b3 <umain+0x23>
  8001ae:	b8 35 11 80 00       	mov    $0x801135,%eax
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 3b 11 80 00       	push   $0x80113b
  8001bd:	e8 56 01 00 00       	call   800318 <cprintf>
		sys_yield();
  8001c2:	e8 62 0b 00 00       	call   800d29 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c7:	46                   	inc    %esi
  8001c8:	83 c4 10             	add    $0x10,%esp
  8001cb:	83 fb 01             	cmp    $0x1,%ebx
  8001ce:	19 c0                	sbb    %eax,%eax
  8001d0:	83 e0 0a             	and    $0xa,%eax
  8001d3:	83 c0 0a             	add    $0xa,%eax
  8001d6:	39 c6                	cmp    %eax,%esi
  8001d8:	7c c9                	jl     8001a3 <umain+0x13>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5e                   	pop    %esi
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    
  8001e1:	00 00                	add    %al,(%eax)
	...

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001ef:	e8 11 0b 00 00       	call   800d05 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	c1 e0 07             	shl    $0x7,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 f6                	test   %esi,%esi
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 03                	mov    (%ebx),%eax
  80020c:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	53                   	push   %ebx
  800215:	56                   	push   %esi
  800216:	e8 75 ff ff ff       	call   800190 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0c 00 00 00       	call   80022c <exit>
  800220:	83 c4 10             	add    $0x10,%esp
}
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	c9                   	leave  
  800229:	c3                   	ret    
	...

0080022c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800232:	6a 00                	push   $0x0
  800234:	e8 aa 0a 00 00       	call   800ce3 <sys_env_destroy>
  800239:	83 c4 10             	add    $0x10,%esp
}
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    
	...

00800240 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800245:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800248:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80024e:	e8 b2 0a 00 00       	call   800d05 <sys_getenvid>
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 0c             	pushl  0xc(%ebp)
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	53                   	push   %ebx
  80025d:	50                   	push   %eax
  80025e:	68 58 11 80 00       	push   $0x801158
  800263:	e8 b0 00 00 00       	call   800318 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	56                   	push   %esi
  80026c:	ff 75 10             	pushl  0x10(%ebp)
  80026f:	e8 53 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800274:	c7 04 24 4b 11 80 00 	movl   $0x80114b,(%esp)
  80027b:	e8 98 00 00 00       	call   800318 <cprintf>
  800280:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x43>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 04             	sub    $0x4,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 1a                	jne    8002bf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	68 ff 00 00 00       	push   $0xff
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 e3 09 00 00       	call   800c99 <sys_cputs>
		b->idx = 0;
  8002b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002bf:	ff 43 04             	incl   0x4(%ebx)
}
  8002c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	ff 75 0c             	pushl  0xc(%ebp)
  8002e7:	ff 75 08             	pushl  0x8(%ebp)
  8002ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f0:	50                   	push   %eax
  8002f1:	68 88 02 80 00       	push   $0x800288
  8002f6:	e8 82 01 00 00       	call   80047d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002fb:	83 c4 08             	add    $0x8,%esp
  8002fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800304:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030a:	50                   	push   %eax
  80030b:	e8 89 09 00 00       	call   800c99 <sys_cputs>

	return b.cnt;
}
  800310:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800321:	50                   	push   %eax
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 9d ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	56                   	push   %esi
  800331:	53                   	push   %ebx
  800332:	83 ec 2c             	sub    $0x2c,%esp
  800335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800338:	89 d6                	mov    %edx,%esi
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800340:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800343:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800346:	8b 45 10             	mov    0x10(%ebp),%eax
  800349:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800359:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80035c:	72 0c                	jb     80036a <printnum+0x3e>
  80035e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800361:	76 07                	jbe    80036a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800363:	4b                   	dec    %ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f 31                	jg     800399 <printnum+0x6d>
  800368:	eb 3f                	jmp    8003a9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036a:	83 ec 0c             	sub    $0xc,%esp
  80036d:	57                   	push   %edi
  80036e:	4b                   	dec    %ebx
  80036f:	53                   	push   %ebx
  800370:	50                   	push   %eax
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 d4             	pushl  -0x2c(%ebp)
  800377:	ff 75 d0             	pushl  -0x30(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 eb 0a 00 00       	call   800e70 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038f:	e8 98 ff ff ff       	call   80032c <printnum>
  800394:	83 c4 20             	add    $0x20,%esp
  800397:	eb 10                	jmp    8003a9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	57                   	push   %edi
  80039e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a1:	4b                   	dec    %ebx
  8003a2:	83 c4 10             	add    $0x10,%esp
  8003a5:	85 db                	test   %ebx,%ebx
  8003a7:	7f f0                	jg     800399 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	56                   	push   %esi
  8003ad:	83 ec 04             	sub    $0x4,%esp
  8003b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bc:	e8 cb 0b 00 00       	call   800f8c <__umoddi3>
  8003c1:	83 c4 14             	add    $0x14,%esp
  8003c4:	0f be 80 7c 11 80 00 	movsbl 0x80117c(%eax),%eax
  8003cb:	50                   	push   %eax
  8003cc:	ff 55 e4             	call   *-0x1c(%ebp)
  8003cf:	83 c4 10             	add    $0x10,%esp
}
  8003d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d5:	5b                   	pop    %ebx
  8003d6:	5e                   	pop    %esi
  8003d7:	5f                   	pop    %edi
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003dd:	83 fa 01             	cmp    $0x1,%edx
  8003e0:	7e 0e                	jle    8003f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	8b 52 04             	mov    0x4(%edx),%edx
  8003ee:	eb 22                	jmp    800412 <getuint+0x38>
	else if (lflag)
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 10                	je     800404 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	eb 0e                	jmp    800412 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 04             	lea    0x4(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800417:	83 fa 01             	cmp    $0x1,%edx
  80041a:	7e 0e                	jle    80042a <getint+0x16>
		return va_arg(*ap, long long);
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 02                	mov    (%edx),%eax
  800425:	8b 52 04             	mov    0x4(%edx),%edx
  800428:	eb 1a                	jmp    800444 <getint+0x30>
	else if (lflag)
  80042a:	85 d2                	test   %edx,%edx
  80042c:	74 0c                	je     80043a <getint+0x26>
		return va_arg(*ap, long);
  80042e:	8b 10                	mov    (%eax),%edx
  800430:	8d 4a 04             	lea    0x4(%edx),%ecx
  800433:	89 08                	mov    %ecx,(%eax)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	99                   	cltd   
  800438:	eb 0a                	jmp    800444 <getint+0x30>
	else
		return va_arg(*ap, int);
  80043a:	8b 10                	mov    (%eax),%edx
  80043c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043f:	89 08                	mov    %ecx,(%eax)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	99                   	cltd   
}
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80044f:	8b 10                	mov    (%eax),%edx
  800451:	3b 50 04             	cmp    0x4(%eax),%edx
  800454:	73 08                	jae    80045e <sprintputch+0x18>
		*b->buf++ = ch;
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 0a                	mov    %cl,(%edx)
  80045b:	42                   	inc    %edx
  80045c:	89 10                	mov    %edx,(%eax)
}
  80045e:	c9                   	leave  
  80045f:	c3                   	ret    

00800460 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800466:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800469:	50                   	push   %eax
  80046a:	ff 75 10             	pushl  0x10(%ebp)
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	ff 75 08             	pushl  0x8(%ebp)
  800473:	e8 05 00 00 00       	call   80047d <vprintfmt>
	va_end(ap);
  800478:	83 c4 10             	add    $0x10,%esp
}
  80047b:	c9                   	leave  
  80047c:	c3                   	ret    

0080047d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 2c             	sub    $0x2c,%esp
  800486:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800489:	8b 75 10             	mov    0x10(%ebp),%esi
  80048c:	eb 13                	jmp    8004a1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80048e:	85 c0                	test   %eax,%eax
  800490:	0f 84 6d 03 00 00    	je     800803 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	57                   	push   %edi
  80049a:	50                   	push   %eax
  80049b:	ff 55 08             	call   *0x8(%ebp)
  80049e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a1:	0f b6 06             	movzbl (%esi),%eax
  8004a4:	46                   	inc    %esi
  8004a5:	83 f8 25             	cmp    $0x25,%eax
  8004a8:	75 e4                	jne    80048e <vprintfmt+0x11>
  8004aa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004b5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004bc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c8:	eb 28                	jmp    8004f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004cc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004d0:	eb 20                	jmp    8004f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004d8:	eb 18                	jmp    8004f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004e3:	eb 0d                	jmp    8004f2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8a 06                	mov    (%esi),%al
  8004f4:	0f b6 d0             	movzbl %al,%edx
  8004f7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004fa:	83 e8 23             	sub    $0x23,%eax
  8004fd:	3c 55                	cmp    $0x55,%al
  8004ff:	0f 87 e0 02 00 00    	ja     8007e5 <vprintfmt+0x368>
  800505:	0f b6 c0             	movzbl %al,%eax
  800508:	ff 24 85 40 12 80 00 	jmp    *0x801240(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050f:	83 ea 30             	sub    $0x30,%edx
  800512:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800515:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800518:	8d 50 d0             	lea    -0x30(%eax),%edx
  80051b:	83 fa 09             	cmp    $0x9,%edx
  80051e:	77 44                	ja     800564 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	89 de                	mov    %ebx,%esi
  800522:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800525:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800526:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800529:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80052d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800530:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800533:	83 fb 09             	cmp    $0x9,%ebx
  800536:	76 ed                	jbe    800525 <vprintfmt+0xa8>
  800538:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80053b:	eb 29                	jmp    800566 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80054d:	eb 17                	jmp    800566 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80054f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800553:	78 85                	js     8004da <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800555:	89 de                	mov    %ebx,%esi
  800557:	eb 99                	jmp    8004f2 <vprintfmt+0x75>
  800559:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80055b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800562:	eb 8e                	jmp    8004f2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800566:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056a:	79 86                	jns    8004f2 <vprintfmt+0x75>
  80056c:	e9 74 ff ff ff       	jmp    8004e5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800571:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	89 de                	mov    %ebx,%esi
  800574:	e9 79 ff ff ff       	jmp    8004f2 <vprintfmt+0x75>
  800579:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 04             	lea    0x4(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	57                   	push   %edi
  800589:	ff 30                	pushl  (%eax)
  80058b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80058e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800594:	e9 08 ff ff ff       	jmp    8004a1 <vprintfmt+0x24>
  800599:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 02                	jns    8005ad <vprintfmt+0x130>
  8005ab:	f7 d8                	neg    %eax
  8005ad:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005af:	83 f8 08             	cmp    $0x8,%eax
  8005b2:	7f 0b                	jg     8005bf <vprintfmt+0x142>
  8005b4:	8b 04 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%eax
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	75 1a                	jne    8005d9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005bf:	52                   	push   %edx
  8005c0:	68 94 11 80 00       	push   $0x801194
  8005c5:	57                   	push   %edi
  8005c6:	ff 75 08             	pushl  0x8(%ebp)
  8005c9:	e8 92 fe ff ff       	call   800460 <printfmt>
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d4:	e9 c8 fe ff ff       	jmp    8004a1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005d9:	50                   	push   %eax
  8005da:	68 9d 11 80 00       	push   $0x80119d
  8005df:	57                   	push   %edi
  8005e0:	ff 75 08             	pushl  0x8(%ebp)
  8005e3:	e8 78 fe ff ff       	call   800460 <printfmt>
  8005e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005ee:	e9 ae fe ff ff       	jmp    8004a1 <vprintfmt+0x24>
  8005f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005f6:	89 de                	mov    %ebx,%esi
  8005f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060c:	85 c0                	test   %eax,%eax
  80060e:	75 07                	jne    800617 <vprintfmt+0x19a>
				p = "(null)";
  800610:	c7 45 d0 8d 11 80 00 	movl   $0x80118d,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800617:	85 db                	test   %ebx,%ebx
  800619:	7e 42                	jle    80065d <vprintfmt+0x1e0>
  80061b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80061f:	74 3c                	je     80065d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	51                   	push   %ecx
  800625:	ff 75 d0             	pushl  -0x30(%ebp)
  800628:	e8 6f 02 00 00       	call   80089c <strnlen>
  80062d:	29 c3                	sub    %eax,%ebx
  80062f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	85 db                	test   %ebx,%ebx
  800637:	7e 24                	jle    80065d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800639:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80063d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800640:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	57                   	push   %edi
  800647:	53                   	push   %ebx
  800648:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064b:	4e                   	dec    %esi
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	85 f6                	test   %esi,%esi
  800651:	7f f0                	jg     800643 <vprintfmt+0x1c6>
  800653:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800656:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800660:	0f be 02             	movsbl (%edx),%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	75 47                	jne    8006ae <vprintfmt+0x231>
  800667:	eb 37                	jmp    8006a0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800669:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066d:	74 16                	je     800685 <vprintfmt+0x208>
  80066f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800672:	83 fa 5e             	cmp    $0x5e,%edx
  800675:	76 0e                	jbe    800685 <vprintfmt+0x208>
					putch('?', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	57                   	push   %edi
  80067b:	6a 3f                	push   $0x3f
  80067d:	ff 55 08             	call   *0x8(%ebp)
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	eb 0b                	jmp    800690 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	50                   	push   %eax
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800690:	ff 4d e4             	decl   -0x1c(%ebp)
  800693:	0f be 03             	movsbl (%ebx),%eax
  800696:	85 c0                	test   %eax,%eax
  800698:	74 03                	je     80069d <vprintfmt+0x220>
  80069a:	43                   	inc    %ebx
  80069b:	eb 1b                	jmp    8006b8 <vprintfmt+0x23b>
  80069d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	7f 1e                	jg     8006c4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006a9:	e9 f3 fd ff ff       	jmp    8004a1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b1:	43                   	inc    %ebx
  8006b2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006b8:	85 f6                	test   %esi,%esi
  8006ba:	78 ad                	js     800669 <vprintfmt+0x1ec>
  8006bc:	4e                   	dec    %esi
  8006bd:	79 aa                	jns    800669 <vprintfmt+0x1ec>
  8006bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006c2:	eb dc                	jmp    8006a0 <vprintfmt+0x223>
  8006c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	57                   	push   %edi
  8006cb:	6a 20                	push   $0x20
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d0:	4b                   	dec    %ebx
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	85 db                	test   %ebx,%ebx
  8006d6:	7f ef                	jg     8006c7 <vprintfmt+0x24a>
  8006d8:	e9 c4 fd ff ff       	jmp    8004a1 <vprintfmt+0x24>
  8006dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e0:	89 ca                	mov    %ecx,%edx
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 2a fd ff ff       	call   800414 <getint>
  8006ea:	89 c3                	mov    %eax,%ebx
  8006ec:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	78 0a                	js     8006fc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f7:	e9 b0 00 00 00       	jmp    8007ac <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	57                   	push   %edi
  800700:	6a 2d                	push   $0x2d
  800702:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800705:	f7 db                	neg    %ebx
  800707:	83 d6 00             	adc    $0x0,%esi
  80070a:	f7 de                	neg    %esi
  80070c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800714:	e9 93 00 00 00       	jmp    8007ac <vprintfmt+0x32f>
  800719:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071c:	89 ca                	mov    %ecx,%edx
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
  800721:	e8 b4 fc ff ff       	call   8003da <getuint>
  800726:	89 c3                	mov    %eax,%ebx
  800728:	89 d6                	mov    %edx,%esi
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80072f:	eb 7b                	jmp    8007ac <vprintfmt+0x32f>
  800731:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800734:	89 ca                	mov    %ecx,%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 d6 fc ff ff       	call   800414 <getint>
  80073e:	89 c3                	mov    %eax,%ebx
  800740:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800742:	85 d2                	test   %edx,%edx
  800744:	78 07                	js     80074d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800746:	b8 08 00 00 00       	mov    $0x8,%eax
  80074b:	eb 5f                	jmp    8007ac <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	57                   	push   %edi
  800751:	6a 2d                	push   $0x2d
  800753:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800756:	f7 db                	neg    %ebx
  800758:	83 d6 00             	adc    $0x0,%esi
  80075b:	f7 de                	neg    %esi
  80075d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800760:	b8 08 00 00 00       	mov    $0x8,%eax
  800765:	eb 45                	jmp    8007ac <vprintfmt+0x32f>
  800767:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	57                   	push   %edi
  80076e:	6a 30                	push   $0x30
  800770:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800773:	83 c4 08             	add    $0x8,%esp
  800776:	57                   	push   %edi
  800777:	6a 78                	push   $0x78
  800779:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 04             	lea    0x4(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800785:	8b 18                	mov    (%eax),%ebx
  800787:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800794:	eb 16                	jmp    8007ac <vprintfmt+0x32f>
  800796:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800799:	89 ca                	mov    %ecx,%edx
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 37 fc ff ff       	call   8003da <getuint>
  8007a3:	89 c3                	mov    %eax,%ebx
  8007a5:	89 d6                	mov    %edx,%esi
			base = 16;
  8007a7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ac:	83 ec 0c             	sub    $0xc,%esp
  8007af:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007b3:	52                   	push   %edx
  8007b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b7:	50                   	push   %eax
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	89 fa                	mov    %edi,%edx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	e8 68 fb ff ff       	call   80032c <printnum>
			break;
  8007c4:	83 c4 20             	add    $0x20,%esp
  8007c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007ca:	e9 d2 fc ff ff       	jmp    8004a1 <vprintfmt+0x24>
  8007cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	57                   	push   %edi
  8007d6:	52                   	push   %edx
  8007d7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e0:	e9 bc fc ff ff       	jmp    8004a1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	57                   	push   %edi
  8007e9:	6a 25                	push   $0x25
  8007eb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	eb 02                	jmp    8007f5 <vprintfmt+0x378>
  8007f3:	89 c6                	mov    %eax,%esi
  8007f5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007f8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fc:	75 f5                	jne    8007f3 <vprintfmt+0x376>
  8007fe:	e9 9e fc ff ff       	jmp    8004a1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800803:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5f                   	pop    %edi
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	83 ec 18             	sub    $0x18,%esp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800817:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800821:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 26                	je     800852 <vsnprintf+0x47>
  80082c:	85 d2                	test   %edx,%edx
  80082e:	7e 29                	jle    800859 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800830:	ff 75 14             	pushl  0x14(%ebp)
  800833:	ff 75 10             	pushl  0x10(%ebp)
  800836:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	68 46 04 80 00       	push   $0x800446
  80083f:	e8 39 fc ff ff       	call   80047d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800847:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	eb 0c                	jmp    80085e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800857:	eb 05                	jmp    80085e <vsnprintf+0x53>
  800859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800869:	50                   	push   %eax
  80086a:	ff 75 10             	pushl  0x10(%ebp)
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 93 ff ff ff       	call   80080b <vsnprintf>
	va_end(ap);

	return rc;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    
	...

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	80 3a 00             	cmpb   $0x0,(%edx)
  800885:	74 0e                	je     800895 <strlen+0x19>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80088c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800891:	75 f9                	jne    80088c <strlen+0x10>
  800893:	eb 05                	jmp    80089a <strlen+0x1e>
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	74 17                	je     8008c0 <strnlen+0x24>
  8008a9:	80 39 00             	cmpb   $0x0,(%ecx)
  8008ac:	74 19                	je     8008c7 <strnlen+0x2b>
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b4:	39 d0                	cmp    %edx,%eax
  8008b6:	74 14                	je     8008cc <strnlen+0x30>
  8008b8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008bc:	75 f5                	jne    8008b3 <strnlen+0x17>
  8008be:	eb 0c                	jmp    8008cc <strnlen+0x30>
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 05                	jmp    8008cc <strnlen+0x30>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008dd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e3:	42                   	inc    %edx
  8008e4:	84 c9                	test   %cl,%cl
  8008e6:	75 f5                	jne    8008dd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f2:	53                   	push   %ebx
  8008f3:	e8 84 ff ff ff       	call   80087c <strlen>
  8008f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800901:	50                   	push   %eax
  800902:	e8 c7 ff ff ff       	call   8008ce <strcpy>
	return dst;
}
  800907:	89 d8                	mov    %ebx,%eax
  800909:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
  800919:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091c:	85 f6                	test   %esi,%esi
  80091e:	74 15                	je     800935 <strncpy+0x27>
  800920:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800925:	8a 1a                	mov    (%edx),%bl
  800927:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092a:	80 3a 01             	cmpb   $0x1,(%edx)
  80092d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800930:	41                   	inc    %ecx
  800931:	39 ce                	cmp    %ecx,%esi
  800933:	77 f0                	ja     800925 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800945:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800948:	85 f6                	test   %esi,%esi
  80094a:	74 32                	je     80097e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80094c:	83 fe 01             	cmp    $0x1,%esi
  80094f:	74 22                	je     800973 <strlcpy+0x3a>
  800951:	8a 0b                	mov    (%ebx),%cl
  800953:	84 c9                	test   %cl,%cl
  800955:	74 20                	je     800977 <strlcpy+0x3e>
  800957:	89 f8                	mov    %edi,%eax
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80095e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800961:	88 08                	mov    %cl,(%eax)
  800963:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800964:	39 f2                	cmp    %esi,%edx
  800966:	74 11                	je     800979 <strlcpy+0x40>
  800968:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80096c:	42                   	inc    %edx
  80096d:	84 c9                	test   %cl,%cl
  80096f:	75 f0                	jne    800961 <strlcpy+0x28>
  800971:	eb 06                	jmp    800979 <strlcpy+0x40>
  800973:	89 f8                	mov    %edi,%eax
  800975:	eb 02                	jmp    800979 <strlcpy+0x40>
  800977:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800979:	c6 00 00             	movb   $0x0,(%eax)
  80097c:	eb 02                	jmp    800980 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800980:	29 f8                	sub    %edi,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800990:	8a 01                	mov    (%ecx),%al
  800992:	84 c0                	test   %al,%al
  800994:	74 10                	je     8009a6 <strcmp+0x1f>
  800996:	3a 02                	cmp    (%edx),%al
  800998:	75 0c                	jne    8009a6 <strcmp+0x1f>
		p++, q++;
  80099a:	41                   	inc    %ecx
  80099b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099c:	8a 01                	mov    (%ecx),%al
  80099e:	84 c0                	test   %al,%al
  8009a0:	74 04                	je     8009a6 <strcmp+0x1f>
  8009a2:	3a 02                	cmp    (%edx),%al
  8009a4:	74 f4                	je     80099a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ba:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	74 1b                	je     8009dc <strncmp+0x2c>
  8009c1:	8a 1a                	mov    (%edx),%bl
  8009c3:	84 db                	test   %bl,%bl
  8009c5:	74 24                	je     8009eb <strncmp+0x3b>
  8009c7:	3a 19                	cmp    (%ecx),%bl
  8009c9:	75 20                	jne    8009eb <strncmp+0x3b>
  8009cb:	48                   	dec    %eax
  8009cc:	74 15                	je     8009e3 <strncmp+0x33>
		n--, p++, q++;
  8009ce:	42                   	inc    %edx
  8009cf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d0:	8a 1a                	mov    (%edx),%bl
  8009d2:	84 db                	test   %bl,%bl
  8009d4:	74 15                	je     8009eb <strncmp+0x3b>
  8009d6:	3a 19                	cmp    (%ecx),%bl
  8009d8:	74 f1                	je     8009cb <strncmp+0x1b>
  8009da:	eb 0f                	jmp    8009eb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	eb 05                	jmp    8009e8 <strncmp+0x38>
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 02             	movzbl (%edx),%eax
  8009ee:	0f b6 11             	movzbl (%ecx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
  8009f3:	eb f3                	jmp    8009e8 <strncmp+0x38>

008009f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009fe:	8a 10                	mov    (%eax),%dl
  800a00:	84 d2                	test   %dl,%dl
  800a02:	74 18                	je     800a1c <strchr+0x27>
		if (*s == c)
  800a04:	38 ca                	cmp    %cl,%dl
  800a06:	75 06                	jne    800a0e <strchr+0x19>
  800a08:	eb 17                	jmp    800a21 <strchr+0x2c>
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 13                	je     800a21 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	40                   	inc    %eax
  800a0f:	8a 10                	mov    (%eax),%dl
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f5                	jne    800a0a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 05                	jmp    800a21 <strchr+0x2c>
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a2c:	8a 10                	mov    (%eax),%dl
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	74 11                	je     800a43 <strfind+0x20>
		if (*s == c)
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	75 06                	jne    800a3c <strfind+0x19>
  800a36:	eb 0b                	jmp    800a43 <strfind+0x20>
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	74 07                	je     800a43 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3c:	40                   	inc    %eax
  800a3d:	8a 10                	mov    (%eax),%dl
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f5                	jne    800a38 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a54:	85 c9                	test   %ecx,%ecx
  800a56:	74 30                	je     800a88 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5e:	75 25                	jne    800a85 <memset+0x40>
  800a60:	f6 c1 03             	test   $0x3,%cl
  800a63:	75 20                	jne    800a85 <memset+0x40>
		c &= 0xFF;
  800a65:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	c1 e3 08             	shl    $0x8,%ebx
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	c1 e6 18             	shl    $0x18,%esi
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	c1 e0 10             	shl    $0x10,%eax
  800a77:	09 f0                	or     %esi,%eax
  800a79:	09 d0                	or     %edx,%eax
  800a7b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a80:	fc                   	cld    
  800a81:	f3 ab                	rep stos %eax,%es:(%edi)
  800a83:	eb 03                	jmp    800a88 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	fc                   	cld    
  800a86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a88:	89 f8                	mov    %edi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 34                	jae    800ad5 <memmove+0x46>
  800aa1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 2d                	jae    800ad5 <memmove+0x46>
		s += n;
		d += n;
  800aa8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	f6 c2 03             	test   $0x3,%dl
  800aae:	75 1b                	jne    800acb <memmove+0x3c>
  800ab0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab6:	75 13                	jne    800acb <memmove+0x3c>
  800ab8:	f6 c1 03             	test   $0x3,%cl
  800abb:	75 0e                	jne    800acb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800abd:	83 ef 04             	sub    $0x4,%edi
  800ac0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ac6:	fd                   	std    
  800ac7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac9:	eb 07                	jmp    800ad2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acb:	4f                   	dec    %edi
  800acc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800acf:	fd                   	std    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad2:	fc                   	cld    
  800ad3:	eb 20                	jmp    800af5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adb:	75 13                	jne    800af0 <memmove+0x61>
  800add:	a8 03                	test   $0x3,%al
  800adf:	75 0f                	jne    800af0 <memmove+0x61>
  800ae1:	f6 c1 03             	test   $0x3,%cl
  800ae4:	75 0a                	jne    800af0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	fc                   	cld    
  800aec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aee:	eb 05                	jmp    800af5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	fc                   	cld    
  800af3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afc:	ff 75 10             	pushl  0x10(%ebp)
  800aff:	ff 75 0c             	pushl  0xc(%ebp)
  800b02:	ff 75 08             	pushl  0x8(%ebp)
  800b05:	e8 85 ff ff ff       	call   800a8f <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1b:	85 ff                	test   %edi,%edi
  800b1d:	74 32                	je     800b51 <memcmp+0x45>
		if (*s1 != *s2)
  800b1f:	8a 03                	mov    (%ebx),%al
  800b21:	8a 0e                	mov    (%esi),%cl
  800b23:	38 c8                	cmp    %cl,%al
  800b25:	74 19                	je     800b40 <memcmp+0x34>
  800b27:	eb 0d                	jmp    800b36 <memcmp+0x2a>
  800b29:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b2d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b31:	42                   	inc    %edx
  800b32:	38 c8                	cmp    %cl,%al
  800b34:	74 10                	je     800b46 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b36:	0f b6 c0             	movzbl %al,%eax
  800b39:	0f b6 c9             	movzbl %cl,%ecx
  800b3c:	29 c8                	sub    %ecx,%eax
  800b3e:	eb 16                	jmp    800b56 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b40:	4f                   	dec    %edi
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	39 fa                	cmp    %edi,%edx
  800b48:	75 df                	jne    800b29 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	eb 05                	jmp    800b56 <memcmp+0x4a>
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b61:	89 c2                	mov    %eax,%edx
  800b63:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b66:	39 d0                	cmp    %edx,%eax
  800b68:	73 12                	jae    800b7c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b6d:	38 08                	cmp    %cl,(%eax)
  800b6f:	75 06                	jne    800b77 <memfind+0x1c>
  800b71:	eb 09                	jmp    800b7c <memfind+0x21>
  800b73:	38 08                	cmp    %cl,(%eax)
  800b75:	74 05                	je     800b7c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	40                   	inc    %eax
  800b78:	39 c2                	cmp    %eax,%edx
  800b7a:	77 f7                	ja     800b73 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8a:	eb 01                	jmp    800b8d <strtol+0xf>
		s++;
  800b8c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8d:	8a 02                	mov    (%edx),%al
  800b8f:	3c 20                	cmp    $0x20,%al
  800b91:	74 f9                	je     800b8c <strtol+0xe>
  800b93:	3c 09                	cmp    $0x9,%al
  800b95:	74 f5                	je     800b8c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b97:	3c 2b                	cmp    $0x2b,%al
  800b99:	75 08                	jne    800ba3 <strtol+0x25>
		s++;
  800b9b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba1:	eb 13                	jmp    800bb6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba3:	3c 2d                	cmp    $0x2d,%al
  800ba5:	75 0a                	jne    800bb1 <strtol+0x33>
		s++, neg = 1;
  800ba7:	8d 52 01             	lea    0x1(%edx),%edx
  800baa:	bf 01 00 00 00       	mov    $0x1,%edi
  800baf:	eb 05                	jmp    800bb6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	74 05                	je     800bbf <strtol+0x41>
  800bba:	83 fb 10             	cmp    $0x10,%ebx
  800bbd:	75 28                	jne    800be7 <strtol+0x69>
  800bbf:	8a 02                	mov    (%edx),%al
  800bc1:	3c 30                	cmp    $0x30,%al
  800bc3:	75 10                	jne    800bd5 <strtol+0x57>
  800bc5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc9:	75 0a                	jne    800bd5 <strtol+0x57>
		s += 2, base = 16;
  800bcb:	83 c2 02             	add    $0x2,%edx
  800bce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd3:	eb 12                	jmp    800be7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	75 0e                	jne    800be7 <strtol+0x69>
  800bd9:	3c 30                	cmp    $0x30,%al
  800bdb:	75 05                	jne    800be2 <strtol+0x64>
		s++, base = 8;
  800bdd:	42                   	inc    %edx
  800bde:	b3 08                	mov    $0x8,%bl
  800be0:	eb 05                	jmp    800be7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bee:	8a 0a                	mov    (%edx),%cl
  800bf0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf3:	80 fb 09             	cmp    $0x9,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0x82>
			dig = *s - '0';
  800bf8:	0f be c9             	movsbl %cl,%ecx
  800bfb:	83 e9 30             	sub    $0x30,%ecx
  800bfe:	eb 1e                	jmp    800c1e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c00:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c03:	80 fb 19             	cmp    $0x19,%bl
  800c06:	77 08                	ja     800c10 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c08:	0f be c9             	movsbl %cl,%ecx
  800c0b:	83 e9 57             	sub    $0x57,%ecx
  800c0e:	eb 0e                	jmp    800c1e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c10:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 13                	ja     800c2b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c18:	0f be c9             	movsbl %cl,%ecx
  800c1b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1e:	39 f1                	cmp    %esi,%ecx
  800c20:	7d 0d                	jge    800c2f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c22:	42                   	inc    %edx
  800c23:	0f af c6             	imul   %esi,%eax
  800c26:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c29:	eb c3                	jmp    800bee <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c2b:	89 c1                	mov    %eax,%ecx
  800c2d:	eb 02                	jmp    800c31 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c35:	74 05                	je     800c3c <strtol+0xbe>
		*endptr = (char *) s;
  800c37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c3c:	85 ff                	test   %edi,%edi
  800c3e:	74 04                	je     800c44 <strtol+0xc6>
  800c40:	89 c8                	mov    %ecx,%eax
  800c42:	f7 d8                	neg    %eax
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    
  800c49:	00 00                	add    %al,(%eax)
	...

00800c4c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 1c             	sub    $0x1c,%esp
  800c55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c58:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c5b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c60:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c69:	cd 30                	int    $0x30
  800c6b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c71:	74 1c                	je     800c8f <syscall+0x43>
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 18                	jle    800c8f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c7e:	68 c4 13 80 00       	push   $0x8013c4
  800c83:	6a 42                	push   $0x42
  800c85:	68 e1 13 80 00       	push   $0x8013e1
  800c8a:	e8 b1 f5 ff ff       	call   800240 <_panic>

	return ret;
}
  800c8f:	89 d0                	mov    %edx,%eax
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb5:	e8 92 ff ff ff       	call   800c4c <syscall>
  800cba:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cc5:	6a 00                	push   $0x0
  800cc7:	6a 00                	push   $0x0
  800cc9:	6a 00                	push   $0x0
  800ccb:	6a 00                	push   $0x0
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdc:	e8 6b ff ff ff       	call   800c4c <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cfe:	e8 49 ff ff ff       	call   800c4c <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d22:	e8 25 ff ff ff       	call   800c4c <syscall>
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <sys_yield>:

void
sys_yield(void)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d2f:	6a 00                	push   $0x0
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	6a 00                	push   $0x0
  800d37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d46:	e8 01 ff ff ff       	call   800c4c <syscall>
  800d4b:	83 c4 10             	add    $0x10,%esp
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d56:	6a 00                	push   $0x0
  800d58:	6a 00                	push   $0x0
  800d5a:	ff 75 10             	pushl  0x10(%ebp)
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d63:	ba 01 00 00 00       	mov    $0x1,%edx
  800d68:	b8 04 00 00 00       	mov    $0x4,%eax
  800d6d:	e8 da fe ff ff       	call   800c4c <syscall>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d7a:	ff 75 18             	pushl  0x18(%ebp)
  800d7d:	ff 75 14             	pushl  0x14(%ebp)
  800d80:	ff 75 10             	pushl  0x10(%ebp)
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d89:	ba 01 00 00 00       	mov    $0x1,%edx
  800d8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d93:	e8 b4 fe ff ff       	call   800c4c <syscall>
}
  800d98:	c9                   	leave  
  800d99:	c3                   	ret    

00800d9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800da0:	6a 00                	push   $0x0
  800da2:	6a 00                	push   $0x0
  800da4:	6a 00                	push   $0x0
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dac:	ba 01 00 00 00       	mov    $0x1,%edx
  800db1:	b8 06 00 00 00       	mov    $0x6,%eax
  800db6:	e8 91 fe ff ff       	call   800c4c <syscall>
}
  800dbb:	c9                   	leave  
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd9:	e8 6e fe ff ff       	call   800c4c <syscall>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800de6:	6a 00                	push   $0x0
  800de8:	6a 00                	push   $0x0
  800dea:	6a 00                	push   $0x0
  800dec:	ff 75 0c             	pushl  0xc(%ebp)
  800def:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df2:	ba 01 00 00 00       	mov    $0x1,%edx
  800df7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfc:	e8 4b fe ff ff       	call   800c4c <syscall>
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e09:	6a 00                	push   $0x0
  800e0b:	ff 75 14             	pushl  0x14(%ebp)
  800e0e:	ff 75 10             	pushl  0x10(%ebp)
  800e11:	ff 75 0c             	pushl  0xc(%ebp)
  800e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e21:	e8 26 fe ff ff       	call   800c4c <syscall>
}
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    

00800e28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e2e:	6a 00                	push   $0x0
  800e30:	6a 00                	push   $0x0
  800e32:	6a 00                	push   $0x0
  800e34:	6a 00                	push   $0x0
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	ba 01 00 00 00       	mov    $0x1,%edx
  800e3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e43:	e8 04 fe ff ff       	call   800c4c <syscall>
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e50:	6a 00                	push   $0x0
  800e52:	6a 00                	push   $0x0
  800e54:	6a 00                	push   $0x0
  800e56:	ff 75 0c             	pushl  0xc(%ebp)
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e61:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e66:	e8 e1 fd ff ff       	call   800c4c <syscall>
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    
  800e6d:	00 00                	add    %al,(%eax)
	...

00800e70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	83 ec 10             	sub    $0x10,%esp
  800e78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e7e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800e81:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e84:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e87:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	75 2e                	jne    800ebc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e8e:	39 f1                	cmp    %esi,%ecx
  800e90:	77 5a                	ja     800eec <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e92:	85 c9                	test   %ecx,%ecx
  800e94:	75 0b                	jne    800ea1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f1                	div    %ecx
  800e9f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ea1:	31 d2                	xor    %edx,%edx
  800ea3:	89 f0                	mov    %esi,%eax
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea9:	89 f8                	mov    %edi,%eax
  800eab:	f7 f1                	div    %ecx
  800ead:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eaf:	89 f8                	mov    %edi,%eax
  800eb1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    
  800eba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ebc:	39 f0                	cmp    %esi,%eax
  800ebe:	77 1c                	ja     800edc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ec0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800ec3:	83 f7 1f             	xor    $0x1f,%edi
  800ec6:	75 3c                	jne    800f04 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec8:	39 f0                	cmp    %esi,%eax
  800eca:	0f 82 90 00 00 00    	jb     800f60 <__udivdi3+0xf0>
  800ed0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ed6:	0f 86 84 00 00 00    	jbe    800f60 <__udivdi3+0xf0>
  800edc:	31 f6                	xor    %esi,%esi
  800ede:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee0:	89 f8                	mov    %edi,%eax
  800ee2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    
  800eeb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eec:	89 f2                	mov    %esi,%edx
  800eee:	89 f8                	mov    %edi,%eax
  800ef0:	f7 f1                	div    %ecx
  800ef2:	89 c7                	mov    %eax,%edi
  800ef4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ef6:	89 f8                	mov    %edi,%eax
  800ef8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    
  800f01:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f04:	89 f9                	mov    %edi,%ecx
  800f06:	d3 e0                	shl    %cl,%eax
  800f08:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f0b:	b8 20 00 00 00       	mov    $0x20,%eax
  800f10:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f15:	88 c1                	mov    %al,%cl
  800f17:	d3 ea                	shr    %cl,%edx
  800f19:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800f1c:	09 ca                	or     %ecx,%edx
  800f1e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800f21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f24:	89 f9                	mov    %edi,%ecx
  800f26:	d3 e2                	shl    %cl,%edx
  800f28:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	88 c1                	mov    %al,%cl
  800f2f:	d3 ea                	shr    %cl,%edx
  800f31:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800f34:	89 f2                	mov    %esi,%edx
  800f36:	89 f9                	mov    %edi,%ecx
  800f38:	d3 e2                	shl    %cl,%edx
  800f3a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f3d:	88 c1                	mov    %al,%cl
  800f3f:	d3 ee                	shr    %cl,%esi
  800f41:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f43:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800f46:	89 f0                	mov    %esi,%eax
  800f48:	89 ca                	mov    %ecx,%edx
  800f4a:	f7 75 ec             	divl   -0x14(%ebp)
  800f4d:	89 d1                	mov    %edx,%ecx
  800f4f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f51:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f54:	39 d1                	cmp    %edx,%ecx
  800f56:	72 28                	jb     800f80 <__udivdi3+0x110>
  800f58:	74 1a                	je     800f74 <__udivdi3+0x104>
  800f5a:	89 f7                	mov    %esi,%edi
  800f5c:	31 f6                	xor    %esi,%esi
  800f5e:	eb 80                	jmp    800ee0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f60:	31 f6                	xor    %esi,%esi
  800f62:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f67:	89 f8                	mov    %edi,%eax
  800f69:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    
  800f72:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f77:	89 f9                	mov    %edi,%ecx
  800f79:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f7b:	39 c2                	cmp    %eax,%edx
  800f7d:	73 db                	jae    800f5a <__udivdi3+0xea>
  800f7f:	90                   	nop
		{
		  q0--;
  800f80:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f83:	31 f6                	xor    %esi,%esi
  800f85:	e9 56 ff ff ff       	jmp    800ee0 <__udivdi3+0x70>
	...

00800f8c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	83 ec 20             	sub    $0x20,%esp
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800fa0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800fa3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800fa9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fab:	85 ff                	test   %edi,%edi
  800fad:	75 15                	jne    800fc4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800faf:	39 f1                	cmp    %esi,%ecx
  800fb1:	0f 86 99 00 00 00    	jbe    801050 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fb7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fbd:	83 c4 20             	add    $0x20,%esp
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fc4:	39 f7                	cmp    %esi,%edi
  800fc6:	0f 87 a4 00 00 00    	ja     801070 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fcc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800fcf:	83 f0 1f             	xor    $0x1f,%eax
  800fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fd5:	0f 84 a1 00 00 00    	je     80107c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fdb:	89 f8                	mov    %edi,%eax
  800fdd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fe0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fe2:	bf 20 00 00 00       	mov    $0x20,%edi
  800fe7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fed:	89 f9                	mov    %edi,%ecx
  800fef:	d3 ea                	shr    %cl,%edx
  800ff1:	09 c2                	or     %eax,%edx
  800ff3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ffc:	d3 e0                	shl    %cl,%eax
  800ffe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801001:	89 f2                	mov    %esi,%edx
  801003:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801005:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801008:	d3 e0                	shl    %cl,%eax
  80100a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80100d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801010:	89 f9                	mov    %edi,%ecx
  801012:	d3 e8                	shr    %cl,%eax
  801014:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801016:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801018:	89 f2                	mov    %esi,%edx
  80101a:	f7 75 f0             	divl   -0x10(%ebp)
  80101d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80101f:	f7 65 f4             	mull   -0xc(%ebp)
  801022:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801025:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801027:	39 d6                	cmp    %edx,%esi
  801029:	72 71                	jb     80109c <__umoddi3+0x110>
  80102b:	74 7f                	je     8010ac <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80102d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801030:	29 c8                	sub    %ecx,%eax
  801032:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801034:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 f2                	mov    %esi,%edx
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80103f:	09 d0                	or     %edx,%eax
  801041:	89 f2                	mov    %esi,%edx
  801043:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801046:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    
  80104f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801050:	85 c9                	test   %ecx,%ecx
  801052:	75 0b                	jne    80105f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801054:	b8 01 00 00 00       	mov    $0x1,%eax
  801059:	31 d2                	xor    %edx,%edx
  80105b:	f7 f1                	div    %ecx
  80105d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80105f:	89 f0                	mov    %esi,%eax
  801061:	31 d2                	xor    %edx,%edx
  801063:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801068:	f7 f1                	div    %ecx
  80106a:	e9 4a ff ff ff       	jmp    800fb9 <__umoddi3+0x2d>
  80106f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801070:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	c9                   	leave  
  801078:	c3                   	ret    
  801079:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80107c:	39 f7                	cmp    %esi,%edi
  80107e:	72 05                	jb     801085 <__umoddi3+0xf9>
  801080:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801083:	77 0c                	ja     801091 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801085:	89 f2                	mov    %esi,%edx
  801087:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108a:	29 c8                	sub    %ecx,%eax
  80108c:	19 fa                	sbb    %edi,%edx
  80108e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801091:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801094:	83 c4 20             	add    $0x20,%esp
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	c9                   	leave  
  80109a:	c3                   	ret    
  80109b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80109c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80109f:	89 c1                	mov    %eax,%ecx
  8010a1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8010a4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8010a7:	eb 84                	jmp    80102d <__umoddi3+0xa1>
  8010a9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010af:	72 eb                	jb     80109c <__umoddi3+0x110>
  8010b1:	89 f2                	mov    %esi,%edx
  8010b3:	e9 75 ff ff ff       	jmp    80102d <__umoddi3+0xa1>
