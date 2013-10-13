
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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
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
  800046:	e8 15 0d 00 00       	call   800d60 <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800052:	50                   	push   %eax
  800053:	68 c0 10 80 00       	push   $0x8010c0
  800058:	6a 20                	push   $0x20
  80005a:	68 d3 10 80 00       	push   $0x8010d3
  80005f:	e8 ec 01 00 00       	call   800250 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	6a 07                	push   $0x7
  800069:	68 00 00 40 00       	push   $0x400000
  80006e:	6a 00                	push   $0x0
  800070:	53                   	push   %ebx
  800071:	56                   	push   %esi
  800072:	e8 0d 0d 00 00       	call   800d84 <sys_page_map>
  800077:	83 c4 20             	add    $0x20,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	79 12                	jns    800090 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007e:	50                   	push   %eax
  80007f:	68 e3 10 80 00       	push   $0x8010e3
  800084:	6a 22                	push   $0x22
  800086:	68 d3 10 80 00       	push   $0x8010d3
  80008b:	e8 c0 01 00 00       	call   800250 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	68 00 10 00 00       	push   $0x1000
  800098:	53                   	push   %ebx
  800099:	68 00 00 40 00       	push   $0x400000
  80009e:	e8 fc 09 00 00       	call   800a9f <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	68 00 00 40 00       	push   $0x400000
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 f8 0c 00 00       	call   800daa <sys_page_unmap>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 12                	jns    8000cb <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b9:	50                   	push   %eax
  8000ba:	68 f4 10 80 00       	push   $0x8010f4
  8000bf:	6a 25                	push   $0x25
  8000c1:	68 d3 10 80 00       	push   $0x8010d3
  8000c6:	e8 85 01 00 00       	call   800250 <_panic>
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
  8000f8:	e8 53 01 00 00       	call   800250 <_panic>
	if (envid == 0) {
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	75 22                	jne    800123 <dumbfork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 0f 0c 00 00       	call   800d15 <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800121:	eb 6d                	jmp    800190 <dumbfork+0xbe>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800123:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80012a:	b8 08 20 80 00       	mov    $0x802008,%eax
  80012f:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800134:	76 24                	jbe    80015a <dumbfork+0x88>
  800136:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	50                   	push   %eax
  80013f:	53                   	push   %ebx
  800140:	e8 ef fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800148:	05 00 10 00 00       	add    $0x1000,%eax
  80014d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800158:	72 e1                	jb     80013b <dumbfork+0x69>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80015a:	83 ec 08             	sub    $0x8,%esp
  80015d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800160:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800165:	50                   	push   %eax
  800166:	56                   	push   %esi
  800167:	e8 c8 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80016c:	83 c4 08             	add    $0x8,%esp
  80016f:	6a 02                	push   $0x2
  800171:	56                   	push   %esi
  800172:	e8 56 0c 00 00       	call   800dcd <sys_env_set_status>
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 12                	jns    800190 <dumbfork+0xbe>
		panic("sys_env_set_status: %e", r);
  80017e:	50                   	push   %eax
  80017f:	68 17 11 80 00       	push   $0x801117
  800184:	6a 4c                	push   $0x4c
  800186:	68 d3 10 80 00       	push   $0x8010d3
  80018b:	e8 c0 00 00 00       	call   800250 <_panic>

	return envid;
}
  800190:	89 f0                	mov    %esi,%eax
  800192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80019e:	e8 2f ff ff ff       	call   8000d2 <dumbfork>
  8001a3:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a5:	be 00 00 00 00       	mov    $0x0,%esi
  8001aa:	eb 28                	jmp    8001d4 <umain+0x3b>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ac:	85 db                	test   %ebx,%ebx
  8001ae:	74 07                	je     8001b7 <umain+0x1e>
  8001b0:	b8 2e 11 80 00       	mov    $0x80112e,%eax
  8001b5:	eb 05                	jmp    8001bc <umain+0x23>
  8001b7:	b8 35 11 80 00       	mov    $0x801135,%eax
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	50                   	push   %eax
  8001c0:	56                   	push   %esi
  8001c1:	68 3b 11 80 00       	push   $0x80113b
  8001c6:	e8 5d 01 00 00       	call   800328 <cprintf>
		sys_yield();
  8001cb:	e8 69 0b 00 00       	call   800d39 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001d0:	46                   	inc    %esi
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	83 fb 01             	cmp    $0x1,%ebx
  8001d7:	19 c0                	sbb    %eax,%eax
  8001d9:	83 e0 0a             	and    $0xa,%eax
  8001dc:	83 c0 0a             	add    $0xa,%eax
  8001df:	39 c6                	cmp    %eax,%esi
  8001e1:	7c c9                	jl     8001ac <umain+0x13>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    
	...

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001f7:	e8 19 0b 00 00       	call   800d15 <sys_getenvid>
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800208:	c1 e0 07             	shl    $0x7,%eax
  80020b:	29 d0                	sub    %edx,%eax
  80020d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800212:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800217:	85 f6                	test   %esi,%esi
  800219:	7e 07                	jle    800222 <libmain+0x36>
		binaryname = argv[0];
  80021b:	8b 03                	mov    (%ebx),%eax
  80021d:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	53                   	push   %ebx
  800226:	56                   	push   %esi
  800227:	e8 6d ff ff ff       	call   800199 <umain>

	// exit gracefully
	exit();
  80022c:	e8 0b 00 00 00       	call   80023c <exit>
  800231:	83 c4 10             	add    $0x10,%esp
}
  800234:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	c9                   	leave  
  80023a:	c3                   	ret    
	...

0080023c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800242:	6a 00                	push   $0x0
  800244:	e8 aa 0a 00 00       	call   800cf3 <sys_env_destroy>
  800249:	83 c4 10             	add    $0x10,%esp
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    
	...

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800255:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800258:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80025e:	e8 b2 0a 00 00       	call   800d15 <sys_getenvid>
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	53                   	push   %ebx
  80026d:	50                   	push   %eax
  80026e:	68 58 11 80 00       	push   $0x801158
  800273:	e8 b0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	56                   	push   %esi
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 53 00 00 00       	call   8002d7 <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 4b 11 80 00 	movl   $0x80114b,(%esp)
  80028b:	e8 98 00 00 00       	call   800328 <cprintf>
  800290:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800293:	cc                   	int3   
  800294:	eb fd                	jmp    800293 <_panic+0x43>
	...

00800298 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	53                   	push   %ebx
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a2:	8b 03                	mov    (%ebx),%eax
  8002a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ab:	40                   	inc    %eax
  8002ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	75 1a                	jne    8002cf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	68 ff 00 00 00       	push   $0xff
  8002bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c0:	50                   	push   %eax
  8002c1:	e8 e3 09 00 00       	call   800ca9 <sys_cputs>
		b->idx = 0;
  8002c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002cf:	ff 43 04             	incl   0x4(%ebx)
}
  8002d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e7:	00 00 00 
	b.cnt = 0;
  8002ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f4:	ff 75 0c             	pushl  0xc(%ebp)
  8002f7:	ff 75 08             	pushl  0x8(%ebp)
  8002fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800300:	50                   	push   %eax
  800301:	68 98 02 80 00       	push   $0x800298
  800306:	e8 82 01 00 00       	call   80048d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030b:	83 c4 08             	add    $0x8,%esp
  80030e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800314:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031a:	50                   	push   %eax
  80031b:	e8 89 09 00 00       	call   800ca9 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	50                   	push   %eax
  800332:	ff 75 08             	pushl  0x8(%ebp)
  800335:	e8 9d ff ff ff       	call   8002d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	89 d6                	mov    %edx,%esi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800350:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800353:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800356:	8b 45 10             	mov    0x10(%ebp),%eax
  800359:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80035f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800362:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800369:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80036c:	72 0c                	jb     80037a <printnum+0x3e>
  80036e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800371:	76 07                	jbe    80037a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800373:	4b                   	dec    %ebx
  800374:	85 db                	test   %ebx,%ebx
  800376:	7f 31                	jg     8003a9 <printnum+0x6d>
  800378:	eb 3f                	jmp    8003b9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	57                   	push   %edi
  80037e:	4b                   	dec    %ebx
  80037f:	53                   	push   %ebx
  800380:	50                   	push   %eax
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	ff 75 d4             	pushl  -0x2c(%ebp)
  800387:	ff 75 d0             	pushl  -0x30(%ebp)
  80038a:	ff 75 dc             	pushl  -0x24(%ebp)
  80038d:	ff 75 d8             	pushl  -0x28(%ebp)
  800390:	e8 c7 0a 00 00       	call   800e5c <__udivdi3>
  800395:	83 c4 18             	add    $0x18,%esp
  800398:	52                   	push   %edx
  800399:	50                   	push   %eax
  80039a:	89 f2                	mov    %esi,%edx
  80039c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80039f:	e8 98 ff ff ff       	call   80033c <printnum>
  8003a4:	83 c4 20             	add    $0x20,%esp
  8003a7:	eb 10                	jmp    8003b9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	56                   	push   %esi
  8003ad:	57                   	push   %edi
  8003ae:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b1:	4b                   	dec    %ebx
  8003b2:	83 c4 10             	add    $0x10,%esp
  8003b5:	85 db                	test   %ebx,%ebx
  8003b7:	7f f0                	jg     8003a9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	56                   	push   %esi
  8003bd:	83 ec 04             	sub    $0x4,%esp
  8003c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cc:	e8 a7 0b 00 00       	call   800f78 <__umoddi3>
  8003d1:	83 c4 14             	add    $0x14,%esp
  8003d4:	0f be 80 7c 11 80 00 	movsbl 0x80117c(%eax),%eax
  8003db:	50                   	push   %eax
  8003dc:	ff 55 e4             	call   *-0x1c(%ebp)
  8003df:	83 c4 10             	add    $0x10,%esp
}
  8003e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5f                   	pop    %edi
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ed:	83 fa 01             	cmp    $0x1,%edx
  8003f0:	7e 0e                	jle    800400 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	8b 52 04             	mov    0x4(%edx),%edx
  8003fe:	eb 22                	jmp    800422 <getuint+0x38>
	else if (lflag)
  800400:	85 d2                	test   %edx,%edx
  800402:	74 10                	je     800414 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 04             	lea    0x4(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	eb 0e                	jmp    800422 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800414:	8b 10                	mov    (%eax),%edx
  800416:	8d 4a 04             	lea    0x4(%edx),%ecx
  800419:	89 08                	mov    %ecx,(%eax)
  80041b:	8b 02                	mov    (%edx),%eax
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800427:	83 fa 01             	cmp    $0x1,%edx
  80042a:	7e 0e                	jle    80043a <getint+0x16>
		return va_arg(*ap, long long);
  80042c:	8b 10                	mov    (%eax),%edx
  80042e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800431:	89 08                	mov    %ecx,(%eax)
  800433:	8b 02                	mov    (%edx),%eax
  800435:	8b 52 04             	mov    0x4(%edx),%edx
  800438:	eb 1a                	jmp    800454 <getint+0x30>
	else if (lflag)
  80043a:	85 d2                	test   %edx,%edx
  80043c:	74 0c                	je     80044a <getint+0x26>
		return va_arg(*ap, long);
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	8d 4a 04             	lea    0x4(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 02                	mov    (%edx),%eax
  800447:	99                   	cltd   
  800448:	eb 0a                	jmp    800454 <getint+0x30>
	else
		return va_arg(*ap, int);
  80044a:	8b 10                	mov    (%eax),%edx
  80044c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044f:	89 08                	mov    %ecx,(%eax)
  800451:	8b 02                	mov    (%edx),%eax
  800453:	99                   	cltd   
}
  800454:	c9                   	leave  
  800455:	c3                   	ret    

00800456 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80045f:	8b 10                	mov    (%eax),%edx
  800461:	3b 50 04             	cmp    0x4(%eax),%edx
  800464:	73 08                	jae    80046e <sprintputch+0x18>
		*b->buf++ = ch;
  800466:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800469:	88 0a                	mov    %cl,(%edx)
  80046b:	42                   	inc    %edx
  80046c:	89 10                	mov    %edx,(%eax)
}
  80046e:	c9                   	leave  
  80046f:	c3                   	ret    

00800470 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800476:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800479:	50                   	push   %eax
  80047a:	ff 75 10             	pushl  0x10(%ebp)
  80047d:	ff 75 0c             	pushl  0xc(%ebp)
  800480:	ff 75 08             	pushl  0x8(%ebp)
  800483:	e8 05 00 00 00       	call   80048d <vprintfmt>
	va_end(ap);
  800488:	83 c4 10             	add    $0x10,%esp
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	57                   	push   %edi
  800491:	56                   	push   %esi
  800492:	53                   	push   %ebx
  800493:	83 ec 2c             	sub    $0x2c,%esp
  800496:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800499:	8b 75 10             	mov    0x10(%ebp),%esi
  80049c:	eb 13                	jmp    8004b1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	0f 84 6d 03 00 00    	je     800813 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	57                   	push   %edi
  8004aa:	50                   	push   %eax
  8004ab:	ff 55 08             	call   *0x8(%ebp)
  8004ae:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b1:	0f b6 06             	movzbl (%esi),%eax
  8004b4:	46                   	inc    %esi
  8004b5:	83 f8 25             	cmp    $0x25,%eax
  8004b8:	75 e4                	jne    80049e <vprintfmt+0x11>
  8004ba:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004be:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004c5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004cc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d8:	eb 28                	jmp    800502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004dc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004e0:	eb 20                	jmp    800502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f3:	eb 0d                	jmp    800502 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8a 06                	mov    (%esi),%al
  800504:	0f b6 d0             	movzbl %al,%edx
  800507:	8d 5e 01             	lea    0x1(%esi),%ebx
  80050a:	83 e8 23             	sub    $0x23,%eax
  80050d:	3c 55                	cmp    $0x55,%al
  80050f:	0f 87 e0 02 00 00    	ja     8007f5 <vprintfmt+0x368>
  800515:	0f b6 c0             	movzbl %al,%eax
  800518:	ff 24 85 40 12 80 00 	jmp    *0x801240(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051f:	83 ea 30             	sub    $0x30,%edx
  800522:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800525:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800528:	8d 50 d0             	lea    -0x30(%eax),%edx
  80052b:	83 fa 09             	cmp    $0x9,%edx
  80052e:	77 44                	ja     800574 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	89 de                	mov    %ebx,%esi
  800532:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800536:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800539:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80053d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800540:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800543:	83 fb 09             	cmp    $0x9,%ebx
  800546:	76 ed                	jbe    800535 <vprintfmt+0xa8>
  800548:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80054b:	eb 29                	jmp    800576 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055d:	eb 17                	jmp    800576 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	78 85                	js     8004ea <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	89 de                	mov    %ebx,%esi
  800567:	eb 99                	jmp    800502 <vprintfmt+0x75>
  800569:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80056b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800572:	eb 8e                	jmp    800502 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800576:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057a:	79 86                	jns    800502 <vprintfmt+0x75>
  80057c:	e9 74 ff ff ff       	jmp    8004f5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800581:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	89 de                	mov    %ebx,%esi
  800584:	e9 79 ff ff ff       	jmp    800502 <vprintfmt+0x75>
  800589:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	ff 30                	pushl  (%eax)
  80059b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80059e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a4:	e9 08 ff ff ff       	jmp    8004b1 <vprintfmt+0x24>
  8005a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	79 02                	jns    8005bd <vprintfmt+0x130>
  8005bb:	f7 d8                	neg    %eax
  8005bd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bf:	83 f8 08             	cmp    $0x8,%eax
  8005c2:	7f 0b                	jg     8005cf <vprintfmt+0x142>
  8005c4:	8b 04 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 1a                	jne    8005e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005cf:	52                   	push   %edx
  8005d0:	68 94 11 80 00       	push   $0x801194
  8005d5:	57                   	push   %edi
  8005d6:	ff 75 08             	pushl  0x8(%ebp)
  8005d9:	e8 92 fe ff ff       	call   800470 <printfmt>
  8005de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e4:	e9 c8 fe ff ff       	jmp    8004b1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005e9:	50                   	push   %eax
  8005ea:	68 9d 11 80 00       	push   $0x80119d
  8005ef:	57                   	push   %edi
  8005f0:	ff 75 08             	pushl  0x8(%ebp)
  8005f3:	e8 78 fe ff ff       	call   800470 <printfmt>
  8005f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005fe:	e9 ae fe ff ff       	jmp    8004b1 <vprintfmt+0x24>
  800603:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800606:	89 de                	mov    %ebx,%esi
  800608:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061c:	85 c0                	test   %eax,%eax
  80061e:	75 07                	jne    800627 <vprintfmt+0x19a>
				p = "(null)";
  800620:	c7 45 d0 8d 11 80 00 	movl   $0x80118d,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800627:	85 db                	test   %ebx,%ebx
  800629:	7e 42                	jle    80066d <vprintfmt+0x1e0>
  80062b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80062f:	74 3c                	je     80066d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	51                   	push   %ecx
  800635:	ff 75 d0             	pushl  -0x30(%ebp)
  800638:	e8 6f 02 00 00       	call   8008ac <strnlen>
  80063d:	29 c3                	sub    %eax,%ebx
  80063f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	85 db                	test   %ebx,%ebx
  800647:	7e 24                	jle    80066d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800649:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80064d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800650:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	57                   	push   %edi
  800657:	53                   	push   %ebx
  800658:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065b:	4e                   	dec    %esi
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	85 f6                	test   %esi,%esi
  800661:	7f f0                	jg     800653 <vprintfmt+0x1c6>
  800663:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800666:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800670:	0f be 02             	movsbl (%edx),%eax
  800673:	85 c0                	test   %eax,%eax
  800675:	75 47                	jne    8006be <vprintfmt+0x231>
  800677:	eb 37                	jmp    8006b0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	74 16                	je     800695 <vprintfmt+0x208>
  80067f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800682:	83 fa 5e             	cmp    $0x5e,%edx
  800685:	76 0e                	jbe    800695 <vprintfmt+0x208>
					putch('?', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	57                   	push   %edi
  80068b:	6a 3f                	push   $0x3f
  80068d:	ff 55 08             	call   *0x8(%ebp)
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb 0b                	jmp    8006a0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	57                   	push   %edi
  800699:	50                   	push   %eax
  80069a:	ff 55 08             	call   *0x8(%ebp)
  80069d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a0:	ff 4d e4             	decl   -0x1c(%ebp)
  8006a3:	0f be 03             	movsbl (%ebx),%eax
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	74 03                	je     8006ad <vprintfmt+0x220>
  8006aa:	43                   	inc    %ebx
  8006ab:	eb 1b                	jmp    8006c8 <vprintfmt+0x23b>
  8006ad:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b4:	7f 1e                	jg     8006d4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006b9:	e9 f3 fd ff ff       	jmp    8004b1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c1:	43                   	inc    %ebx
  8006c2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006c8:	85 f6                	test   %esi,%esi
  8006ca:	78 ad                	js     800679 <vprintfmt+0x1ec>
  8006cc:	4e                   	dec    %esi
  8006cd:	79 aa                	jns    800679 <vprintfmt+0x1ec>
  8006cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006d2:	eb dc                	jmp    8006b0 <vprintfmt+0x223>
  8006d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 20                	push   $0x20
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e0:	4b                   	dec    %ebx
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 db                	test   %ebx,%ebx
  8006e6:	7f ef                	jg     8006d7 <vprintfmt+0x24a>
  8006e8:	e9 c4 fd ff ff       	jmp    8004b1 <vprintfmt+0x24>
  8006ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f0:	89 ca                	mov    %ecx,%edx
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f5:	e8 2a fd ff ff       	call   800424 <getint>
  8006fa:	89 c3                	mov    %eax,%ebx
  8006fc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006fe:	85 d2                	test   %edx,%edx
  800700:	78 0a                	js     80070c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 b0 00 00 00       	jmp    8007bc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	57                   	push   %edi
  800710:	6a 2d                	push   $0x2d
  800712:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800715:	f7 db                	neg    %ebx
  800717:	83 d6 00             	adc    $0x0,%esi
  80071a:	f7 de                	neg    %esi
  80071c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80071f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800724:	e9 93 00 00 00       	jmp    8007bc <vprintfmt+0x32f>
  800729:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072c:	89 ca                	mov    %ecx,%edx
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	e8 b4 fc ff ff       	call   8003ea <getuint>
  800736:	89 c3                	mov    %eax,%ebx
  800738:	89 d6                	mov    %edx,%esi
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80073f:	eb 7b                	jmp    8007bc <vprintfmt+0x32f>
  800741:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 d6 fc ff ff       	call   800424 <getint>
  80074e:	89 c3                	mov    %eax,%ebx
  800750:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800752:	85 d2                	test   %edx,%edx
  800754:	78 07                	js     80075d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800756:	b8 08 00 00 00       	mov    $0x8,%eax
  80075b:	eb 5f                	jmp    8007bc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	57                   	push   %edi
  800761:	6a 2d                	push   $0x2d
  800763:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800766:	f7 db                	neg    %ebx
  800768:	83 d6 00             	adc    $0x0,%esi
  80076b:	f7 de                	neg    %esi
  80076d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800770:	b8 08 00 00 00       	mov    $0x8,%eax
  800775:	eb 45                	jmp    8007bc <vprintfmt+0x32f>
  800777:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	57                   	push   %edi
  80077e:	6a 30                	push   $0x30
  800780:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800783:	83 c4 08             	add    $0x8,%esp
  800786:	57                   	push   %edi
  800787:	6a 78                	push   $0x78
  800789:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800795:	8b 18                	mov    (%eax),%ebx
  800797:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80079c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007a4:	eb 16                	jmp    8007bc <vprintfmt+0x32f>
  8007a6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a9:	89 ca                	mov    %ecx,%edx
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 37 fc ff ff       	call   8003ea <getuint>
  8007b3:	89 c3                	mov    %eax,%ebx
  8007b5:	89 d6                	mov    %edx,%esi
			base = 16;
  8007b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bc:	83 ec 0c             	sub    $0xc,%esp
  8007bf:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007c3:	52                   	push   %edx
  8007c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007c7:	50                   	push   %eax
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	89 fa                	mov    %edi,%edx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	e8 68 fb ff ff       	call   80033c <printnum>
			break;
  8007d4:	83 c4 20             	add    $0x20,%esp
  8007d7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007da:	e9 d2 fc ff ff       	jmp    8004b1 <vprintfmt+0x24>
  8007df:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	57                   	push   %edi
  8007e6:	52                   	push   %edx
  8007e7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f0:	e9 bc fc ff ff       	jmp    8004b1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	57                   	push   %edi
  8007f9:	6a 25                	push   $0x25
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	eb 02                	jmp    800805 <vprintfmt+0x378>
  800803:	89 c6                	mov    %eax,%esi
  800805:	8d 46 ff             	lea    -0x1(%esi),%eax
  800808:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080c:	75 f5                	jne    800803 <vprintfmt+0x376>
  80080e:	e9 9e fc ff ff       	jmp    8004b1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800813:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5f                   	pop    %edi
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	83 ec 18             	sub    $0x18,%esp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800827:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800838:	85 c0                	test   %eax,%eax
  80083a:	74 26                	je     800862 <vsnprintf+0x47>
  80083c:	85 d2                	test   %edx,%edx
  80083e:	7e 29                	jle    800869 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800840:	ff 75 14             	pushl  0x14(%ebp)
  800843:	ff 75 10             	pushl  0x10(%ebp)
  800846:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	68 56 04 80 00       	push   $0x800456
  80084f:	e8 39 fc ff ff       	call   80048d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800854:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800857:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	eb 0c                	jmp    80086e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800867:	eb 05                	jmp    80086e <vsnprintf+0x53>
  800869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800879:	50                   	push   %eax
  80087a:	ff 75 10             	pushl  0x10(%ebp)
  80087d:	ff 75 0c             	pushl  0xc(%ebp)
  800880:	ff 75 08             	pushl  0x8(%ebp)
  800883:	e8 93 ff ff ff       	call   80081b <vsnprintf>
	va_end(ap);

	return rc;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    
	...

0080088c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800892:	80 3a 00             	cmpb   $0x0,(%edx)
  800895:	74 0e                	je     8008a5 <strlen+0x19>
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80089c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80089d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a1:	75 f9                	jne    80089c <strlen+0x10>
  8008a3:	eb 05                	jmp    8008aa <strlen+0x1e>
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 17                	je     8008d0 <strnlen+0x24>
  8008b9:	80 39 00             	cmpb   $0x0,(%ecx)
  8008bc:	74 19                	je     8008d7 <strnlen+0x2b>
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c4:	39 d0                	cmp    %edx,%eax
  8008c6:	74 14                	je     8008dc <strnlen+0x30>
  8008c8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cc:	75 f5                	jne    8008c3 <strnlen+0x17>
  8008ce:	eb 0c                	jmp    8008dc <strnlen+0x30>
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	eb 05                	jmp    8008dc <strnlen+0x30>
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ed:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008f0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f3:	42                   	inc    %edx
  8008f4:	84 c9                	test   %cl,%cl
  8008f6:	75 f5                	jne    8008ed <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800902:	53                   	push   %ebx
  800903:	e8 84 ff ff ff       	call   80088c <strlen>
  800908:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090b:	ff 75 0c             	pushl  0xc(%ebp)
  80090e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800911:	50                   	push   %eax
  800912:	e8 c7 ff ff ff       	call   8008de <strcpy>
	return dst;
}
  800917:	89 d8                	mov    %ebx,%eax
  800919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092c:	85 f6                	test   %esi,%esi
  80092e:	74 15                	je     800945 <strncpy+0x27>
  800930:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800935:	8a 1a                	mov    (%edx),%bl
  800937:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093a:	80 3a 01             	cmpb   $0x1,(%edx)
  80093d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800940:	41                   	inc    %ecx
  800941:	39 ce                	cmp    %ecx,%esi
  800943:	77 f0                	ja     800935 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800955:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800958:	85 f6                	test   %esi,%esi
  80095a:	74 32                	je     80098e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80095c:	83 fe 01             	cmp    $0x1,%esi
  80095f:	74 22                	je     800983 <strlcpy+0x3a>
  800961:	8a 0b                	mov    (%ebx),%cl
  800963:	84 c9                	test   %cl,%cl
  800965:	74 20                	je     800987 <strlcpy+0x3e>
  800967:	89 f8                	mov    %edi,%eax
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80096e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800971:	88 08                	mov    %cl,(%eax)
  800973:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800974:	39 f2                	cmp    %esi,%edx
  800976:	74 11                	je     800989 <strlcpy+0x40>
  800978:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80097c:	42                   	inc    %edx
  80097d:	84 c9                	test   %cl,%cl
  80097f:	75 f0                	jne    800971 <strlcpy+0x28>
  800981:	eb 06                	jmp    800989 <strlcpy+0x40>
  800983:	89 f8                	mov    %edi,%eax
  800985:	eb 02                	jmp    800989 <strlcpy+0x40>
  800987:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800989:	c6 00 00             	movb   $0x0,(%eax)
  80098c:	eb 02                	jmp    800990 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800990:	29 f8                	sub    %edi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a0:	8a 01                	mov    (%ecx),%al
  8009a2:	84 c0                	test   %al,%al
  8009a4:	74 10                	je     8009b6 <strcmp+0x1f>
  8009a6:	3a 02                	cmp    (%edx),%al
  8009a8:	75 0c                	jne    8009b6 <strcmp+0x1f>
		p++, q++;
  8009aa:	41                   	inc    %ecx
  8009ab:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ac:	8a 01                	mov    (%ecx),%al
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 04                	je     8009b6 <strcmp+0x1f>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	74 f4                	je     8009aa <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009cd:	85 c0                	test   %eax,%eax
  8009cf:	74 1b                	je     8009ec <strncmp+0x2c>
  8009d1:	8a 1a                	mov    (%edx),%bl
  8009d3:	84 db                	test   %bl,%bl
  8009d5:	74 24                	je     8009fb <strncmp+0x3b>
  8009d7:	3a 19                	cmp    (%ecx),%bl
  8009d9:	75 20                	jne    8009fb <strncmp+0x3b>
  8009db:	48                   	dec    %eax
  8009dc:	74 15                	je     8009f3 <strncmp+0x33>
		n--, p++, q++;
  8009de:	42                   	inc    %edx
  8009df:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e0:	8a 1a                	mov    (%edx),%bl
  8009e2:	84 db                	test   %bl,%bl
  8009e4:	74 15                	je     8009fb <strncmp+0x3b>
  8009e6:	3a 19                	cmp    (%ecx),%bl
  8009e8:	74 f1                	je     8009db <strncmp+0x1b>
  8009ea:	eb 0f                	jmp    8009fb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <strncmp+0x38>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fb:	0f b6 02             	movzbl (%edx),%eax
  8009fe:	0f b6 11             	movzbl (%ecx),%edx
  800a01:	29 d0                	sub    %edx,%eax
  800a03:	eb f3                	jmp    8009f8 <strncmp+0x38>

00800a05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0e:	8a 10                	mov    (%eax),%dl
  800a10:	84 d2                	test   %dl,%dl
  800a12:	74 18                	je     800a2c <strchr+0x27>
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	75 06                	jne    800a1e <strchr+0x19>
  800a18:	eb 17                	jmp    800a31 <strchr+0x2c>
  800a1a:	38 ca                	cmp    %cl,%dl
  800a1c:	74 13                	je     800a31 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1e:	40                   	inc    %eax
  800a1f:	8a 10                	mov    (%eax),%dl
  800a21:	84 d2                	test   %dl,%dl
  800a23:	75 f5                	jne    800a1a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	eb 05                	jmp    800a31 <strchr+0x2c>
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3c:	8a 10                	mov    (%eax),%dl
  800a3e:	84 d2                	test   %dl,%dl
  800a40:	74 11                	je     800a53 <strfind+0x20>
		if (*s == c)
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	75 06                	jne    800a4c <strfind+0x19>
  800a46:	eb 0b                	jmp    800a53 <strfind+0x20>
  800a48:	38 ca                	cmp    %cl,%dl
  800a4a:	74 07                	je     800a53 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4c:	40                   	inc    %eax
  800a4d:	8a 10                	mov    (%eax),%dl
  800a4f:	84 d2                	test   %dl,%dl
  800a51:	75 f5                	jne    800a48 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a64:	85 c9                	test   %ecx,%ecx
  800a66:	74 30                	je     800a98 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a68:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6e:	75 25                	jne    800a95 <memset+0x40>
  800a70:	f6 c1 03             	test   $0x3,%cl
  800a73:	75 20                	jne    800a95 <memset+0x40>
		c &= 0xFF;
  800a75:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	c1 e3 08             	shl    $0x8,%ebx
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	c1 e6 18             	shl    $0x18,%esi
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	c1 e0 10             	shl    $0x10,%eax
  800a87:	09 f0                	or     %esi,%eax
  800a89:	09 d0                	or     %edx,%eax
  800a8b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a90:	fc                   	cld    
  800a91:	f3 ab                	rep stos %eax,%es:(%edi)
  800a93:	eb 03                	jmp    800a98 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a95:	fc                   	cld    
  800a96:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a98:	89 f8                	mov    %edi,%eax
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aad:	39 c6                	cmp    %eax,%esi
  800aaf:	73 34                	jae    800ae5 <memmove+0x46>
  800ab1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab4:	39 d0                	cmp    %edx,%eax
  800ab6:	73 2d                	jae    800ae5 <memmove+0x46>
		s += n;
		d += n;
  800ab8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abb:	f6 c2 03             	test   $0x3,%dl
  800abe:	75 1b                	jne    800adb <memmove+0x3c>
  800ac0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac6:	75 13                	jne    800adb <memmove+0x3c>
  800ac8:	f6 c1 03             	test   $0x3,%cl
  800acb:	75 0e                	jne    800adb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800acd:	83 ef 04             	sub    $0x4,%edi
  800ad0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ad6:	fd                   	std    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb 07                	jmp    800ae2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adb:	4f                   	dec    %edi
  800adc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800adf:	fd                   	std    
  800ae0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae2:	fc                   	cld    
  800ae3:	eb 20                	jmp    800b05 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aeb:	75 13                	jne    800b00 <memmove+0x61>
  800aed:	a8 03                	test   $0x3,%al
  800aef:	75 0f                	jne    800b00 <memmove+0x61>
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 0a                	jne    800b00 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800af9:	89 c7                	mov    %eax,%edi
  800afb:	fc                   	cld    
  800afc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afe:	eb 05                	jmp    800b05 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b00:	89 c7                	mov    %eax,%edi
  800b02:	fc                   	cld    
  800b03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b0c:	ff 75 10             	pushl  0x10(%ebp)
  800b0f:	ff 75 0c             	pushl  0xc(%ebp)
  800b12:	ff 75 08             	pushl  0x8(%ebp)
  800b15:	e8 85 ff ff ff       	call   800a9f <memmove>
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	74 32                	je     800b61 <memcmp+0x45>
		if (*s1 != *s2)
  800b2f:	8a 03                	mov    (%ebx),%al
  800b31:	8a 0e                	mov    (%esi),%cl
  800b33:	38 c8                	cmp    %cl,%al
  800b35:	74 19                	je     800b50 <memcmp+0x34>
  800b37:	eb 0d                	jmp    800b46 <memcmp+0x2a>
  800b39:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b3d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b41:	42                   	inc    %edx
  800b42:	38 c8                	cmp    %cl,%al
  800b44:	74 10                	je     800b56 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b46:	0f b6 c0             	movzbl %al,%eax
  800b49:	0f b6 c9             	movzbl %cl,%ecx
  800b4c:	29 c8                	sub    %ecx,%eax
  800b4e:	eb 16                	jmp    800b66 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b50:	4f                   	dec    %edi
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	39 fa                	cmp    %edi,%edx
  800b58:	75 df                	jne    800b39 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	eb 05                	jmp    800b66 <memcmp+0x4a>
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 12                	jae    800b8c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b7d:	38 08                	cmp    %cl,(%eax)
  800b7f:	75 06                	jne    800b87 <memfind+0x1c>
  800b81:	eb 09                	jmp    800b8c <memfind+0x21>
  800b83:	38 08                	cmp    %cl,(%eax)
  800b85:	74 05                	je     800b8c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b87:	40                   	inc    %eax
  800b88:	39 c2                	cmp    %eax,%edx
  800b8a:	77 f7                	ja     800b83 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9a:	eb 01                	jmp    800b9d <strtol+0xf>
		s++;
  800b9c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9d:	8a 02                	mov    (%edx),%al
  800b9f:	3c 20                	cmp    $0x20,%al
  800ba1:	74 f9                	je     800b9c <strtol+0xe>
  800ba3:	3c 09                	cmp    $0x9,%al
  800ba5:	74 f5                	je     800b9c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba7:	3c 2b                	cmp    $0x2b,%al
  800ba9:	75 08                	jne    800bb3 <strtol+0x25>
		s++;
  800bab:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb1:	eb 13                	jmp    800bc6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb3:	3c 2d                	cmp    $0x2d,%al
  800bb5:	75 0a                	jne    800bc1 <strtol+0x33>
		s++, neg = 1;
  800bb7:	8d 52 01             	lea    0x1(%edx),%edx
  800bba:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbf:	eb 05                	jmp    800bc6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc6:	85 db                	test   %ebx,%ebx
  800bc8:	74 05                	je     800bcf <strtol+0x41>
  800bca:	83 fb 10             	cmp    $0x10,%ebx
  800bcd:	75 28                	jne    800bf7 <strtol+0x69>
  800bcf:	8a 02                	mov    (%edx),%al
  800bd1:	3c 30                	cmp    $0x30,%al
  800bd3:	75 10                	jne    800be5 <strtol+0x57>
  800bd5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd9:	75 0a                	jne    800be5 <strtol+0x57>
		s += 2, base = 16;
  800bdb:	83 c2 02             	add    $0x2,%edx
  800bde:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be3:	eb 12                	jmp    800bf7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800be5:	85 db                	test   %ebx,%ebx
  800be7:	75 0e                	jne    800bf7 <strtol+0x69>
  800be9:	3c 30                	cmp    $0x30,%al
  800beb:	75 05                	jne    800bf2 <strtol+0x64>
		s++, base = 8;
  800bed:	42                   	inc    %edx
  800bee:	b3 08                	mov    $0x8,%bl
  800bf0:	eb 05                	jmp    800bf7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bfe:	8a 0a                	mov    (%edx),%cl
  800c00:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c03:	80 fb 09             	cmp    $0x9,%bl
  800c06:	77 08                	ja     800c10 <strtol+0x82>
			dig = *s - '0';
  800c08:	0f be c9             	movsbl %cl,%ecx
  800c0b:	83 e9 30             	sub    $0x30,%ecx
  800c0e:	eb 1e                	jmp    800c2e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c10:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c18:	0f be c9             	movsbl %cl,%ecx
  800c1b:	83 e9 57             	sub    $0x57,%ecx
  800c1e:	eb 0e                	jmp    800c2e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c20:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c23:	80 fb 19             	cmp    $0x19,%bl
  800c26:	77 13                	ja     800c3b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c28:	0f be c9             	movsbl %cl,%ecx
  800c2b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2e:	39 f1                	cmp    %esi,%ecx
  800c30:	7d 0d                	jge    800c3f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c32:	42                   	inc    %edx
  800c33:	0f af c6             	imul   %esi,%eax
  800c36:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c39:	eb c3                	jmp    800bfe <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c3b:	89 c1                	mov    %eax,%ecx
  800c3d:	eb 02                	jmp    800c41 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c3f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c45:	74 05                	je     800c4c <strtol+0xbe>
		*endptr = (char *) s;
  800c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c4c:	85 ff                	test   %edi,%edi
  800c4e:	74 04                	je     800c54 <strtol+0xc6>
  800c50:	89 c8                	mov    %ecx,%eax
  800c52:	f7 d8                	neg    %eax
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    
  800c59:	00 00                	add    %al,(%eax)
	...

00800c5c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 1c             	sub    $0x1c,%esp
  800c65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c68:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c6b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c70:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	cd 30                	int    $0x30
  800c7b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c81:	74 1c                	je     800c9f <syscall+0x43>
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 18                	jle    800c9f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8e:	68 c4 13 80 00       	push   $0x8013c4
  800c93:	6a 42                	push   $0x42
  800c95:	68 e1 13 80 00       	push   $0x8013e1
  800c9a:	e8 b1 f5 ff ff       	call   800250 <_panic>

	return ret;
}
  800c9f:	89 d0                	mov    %edx,%eax
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc5:	e8 92 ff ff ff       	call   800c5c <syscall>
  800cca:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_cgetc>:

int
sys_cgetc(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cec:	e8 6b ff ff ff       	call   800c5c <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d04:	ba 01 00 00 00       	mov    $0x1,%edx
  800d09:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0e:	e8 49 ff ff ff       	call   800c5c <syscall>
}
  800d13:	c9                   	leave  
  800d14:	c3                   	ret    

00800d15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d1b:	6a 00                	push   $0x0
  800d1d:	6a 00                	push   $0x0
  800d1f:	6a 00                	push   $0x0
  800d21:	6a 00                	push   $0x0
  800d23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d32:	e8 25 ff ff ff       	call   800c5c <syscall>
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <sys_yield>:

void
sys_yield(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d3f:	6a 00                	push   $0x0
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	e8 01 ff ff ff       	call   800c5c <syscall>
  800d5b:	83 c4 10             	add    $0x10,%esp
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d66:	6a 00                	push   $0x0
  800d68:	6a 00                	push   $0x0
  800d6a:	ff 75 10             	pushl  0x10(%ebp)
  800d6d:	ff 75 0c             	pushl  0xc(%ebp)
  800d70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d73:	ba 01 00 00 00       	mov    $0x1,%edx
  800d78:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7d:	e8 da fe ff ff       	call   800c5c <syscall>
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d8a:	ff 75 18             	pushl  0x18(%ebp)
  800d8d:	ff 75 14             	pushl  0x14(%ebp)
  800d90:	ff 75 10             	pushl  0x10(%ebp)
  800d93:	ff 75 0c             	pushl  0xc(%ebp)
  800d96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d99:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800da3:	e8 b4 fe ff ff       	call   800c5c <syscall>
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800db0:	6a 00                	push   $0x0
  800db2:	6a 00                	push   $0x0
  800db4:	6a 00                	push   $0x0
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbc:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc1:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc6:	e8 91 fe ff ff       	call   800c5c <syscall>
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dd3:	6a 00                	push   $0x0
  800dd5:	6a 00                	push   $0x0
  800dd7:	6a 00                	push   $0x0
  800dd9:	ff 75 0c             	pushl  0xc(%ebp)
  800ddc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddf:	ba 01 00 00 00       	mov    $0x1,%edx
  800de4:	b8 08 00 00 00       	mov    $0x8,%eax
  800de9:	e8 6e fe ff ff       	call   800c5c <syscall>
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800df6:	6a 00                	push   $0x0
  800df8:	6a 00                	push   $0x0
  800dfa:	6a 00                	push   $0x0
  800dfc:	ff 75 0c             	pushl  0xc(%ebp)
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	ba 01 00 00 00       	mov    $0x1,%edx
  800e07:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0c:	e8 4b fe ff ff       	call   800c5c <syscall>
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e19:	6a 00                	push   $0x0
  800e1b:	ff 75 14             	pushl  0x14(%ebp)
  800e1e:	ff 75 10             	pushl  0x10(%ebp)
  800e21:	ff 75 0c             	pushl  0xc(%ebp)
  800e24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e27:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e31:	e8 26 fe ff ff       	call   800c5c <syscall>
}
  800e36:	c9                   	leave  
  800e37:	c3                   	ret    

00800e38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e3e:	6a 00                	push   $0x0
  800e40:	6a 00                	push   $0x0
  800e42:	6a 00                	push   $0x0
  800e44:	6a 00                	push   $0x0
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e53:	e8 04 fe ff ff       	call   800c5c <syscall>
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    
	...

00800e5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	83 ec 10             	sub    $0x10,%esp
  800e64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e67:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e6a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800e6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e70:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e73:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e76:	85 c0                	test   %eax,%eax
  800e78:	75 2e                	jne    800ea8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e7a:	39 f1                	cmp    %esi,%ecx
  800e7c:	77 5a                	ja     800ed8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e7e:	85 c9                	test   %ecx,%ecx
  800e80:	75 0b                	jne    800e8d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e82:	b8 01 00 00 00       	mov    $0x1,%eax
  800e87:	31 d2                	xor    %edx,%edx
  800e89:	f7 f1                	div    %ecx
  800e8b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e8d:	31 d2                	xor    %edx,%edx
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	f7 f1                	div    %ecx
  800e93:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	f7 f1                	div    %ecx
  800e99:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e9b:	89 f8                	mov    %edi,%eax
  800e9d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    
  800ea6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea8:	39 f0                	cmp    %esi,%eax
  800eaa:	77 1c                	ja     800ec8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eac:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800eaf:	83 f7 1f             	xor    $0x1f,%edi
  800eb2:	75 3c                	jne    800ef0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eb4:	39 f0                	cmp    %esi,%eax
  800eb6:	0f 82 90 00 00 00    	jb     800f4c <__udivdi3+0xf0>
  800ebc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ebf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ec2:	0f 86 84 00 00 00    	jbe    800f4c <__udivdi3+0xf0>
  800ec8:	31 f6                	xor    %esi,%esi
  800eca:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ecc:	89 f8                	mov    %edi,%eax
  800ece:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    
  800ed7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed8:	89 f2                	mov    %esi,%edx
  800eda:	89 f8                	mov    %edi,%eax
  800edc:	f7 f1                	div    %ecx
  800ede:	89 c7                	mov    %eax,%edi
  800ee0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee2:	89 f8                	mov    %edi,%eax
  800ee4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ef0:	89 f9                	mov    %edi,%ecx
  800ef2:	d3 e0                	shl    %cl,%eax
  800ef4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ef7:	b8 20 00 00 00       	mov    $0x20,%eax
  800efc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f01:	88 c1                	mov    %al,%cl
  800f03:	d3 ea                	shr    %cl,%edx
  800f05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800f08:	09 ca                	or     %ecx,%edx
  800f0a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800f0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f10:	89 f9                	mov    %edi,%ecx
  800f12:	d3 e2                	shl    %cl,%edx
  800f14:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800f17:	89 f2                	mov    %esi,%edx
  800f19:	88 c1                	mov    %al,%cl
  800f1b:	d3 ea                	shr    %cl,%edx
  800f1d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	89 f9                	mov    %edi,%ecx
  800f24:	d3 e2                	shl    %cl,%edx
  800f26:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f29:	88 c1                	mov    %al,%cl
  800f2b:	d3 ee                	shr    %cl,%esi
  800f2d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f2f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800f32:	89 f0                	mov    %esi,%eax
  800f34:	89 ca                	mov    %ecx,%edx
  800f36:	f7 75 ec             	divl   -0x14(%ebp)
  800f39:	89 d1                	mov    %edx,%ecx
  800f3b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f3d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f40:	39 d1                	cmp    %edx,%ecx
  800f42:	72 28                	jb     800f6c <__udivdi3+0x110>
  800f44:	74 1a                	je     800f60 <__udivdi3+0x104>
  800f46:	89 f7                	mov    %esi,%edi
  800f48:	31 f6                	xor    %esi,%esi
  800f4a:	eb 80                	jmp    800ecc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f4c:	31 f6                	xor    %esi,%esi
  800f4e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f53:	89 f8                	mov    %edi,%eax
  800f55:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    
  800f5e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f67:	39 c2                	cmp    %eax,%edx
  800f69:	73 db                	jae    800f46 <__udivdi3+0xea>
  800f6b:	90                   	nop
		{
		  q0--;
  800f6c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f6f:	31 f6                	xor    %esi,%esi
  800f71:	e9 56 ff ff ff       	jmp    800ecc <__udivdi3+0x70>
	...

00800f78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	83 ec 20             	sub    $0x20,%esp
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f86:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800f8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800f95:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f97:	85 ff                	test   %edi,%edi
  800f99:	75 15                	jne    800fb0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800f9b:	39 f1                	cmp    %esi,%ecx
  800f9d:	0f 86 99 00 00 00    	jbe    80103c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fa3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fb0:	39 f7                	cmp    %esi,%edi
  800fb2:	0f 87 a4 00 00 00    	ja     80105c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fb8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800fbb:	83 f0 1f             	xor    $0x1f,%eax
  800fbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc1:	0f 84 a1 00 00 00    	je     801068 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fc7:	89 f8                	mov    %edi,%eax
  800fc9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fcc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fce:	bf 20 00 00 00       	mov    $0x20,%edi
  800fd3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fd9:	89 f9                	mov    %edi,%ecx
  800fdb:	d3 ea                	shr    %cl,%edx
  800fdd:	09 c2                	or     %eax,%edx
  800fdf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fe8:	d3 e0                	shl    %cl,%eax
  800fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fed:	89 f2                	mov    %esi,%edx
  800fef:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ff1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ff4:	d3 e0                	shl    %cl,%eax
  800ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ff9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ffc:	89 f9                	mov    %edi,%ecx
  800ffe:	d3 e8                	shr    %cl,%eax
  801000:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801002:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801004:	89 f2                	mov    %esi,%edx
  801006:	f7 75 f0             	divl   -0x10(%ebp)
  801009:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80100b:	f7 65 f4             	mull   -0xc(%ebp)
  80100e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801011:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801013:	39 d6                	cmp    %edx,%esi
  801015:	72 71                	jb     801088 <__umoddi3+0x110>
  801017:	74 7f                	je     801098 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101c:	29 c8                	sub    %ecx,%eax
  80101e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801020:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801023:	d3 e8                	shr    %cl,%eax
  801025:	89 f2                	mov    %esi,%edx
  801027:	89 f9                	mov    %edi,%ecx
  801029:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80102b:	09 d0                	or     %edx,%eax
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801032:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801034:	83 c4 20             	add    $0x20,%esp
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	c9                   	leave  
  80103a:	c3                   	ret    
  80103b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80103c:	85 c9                	test   %ecx,%ecx
  80103e:	75 0b                	jne    80104b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801040:	b8 01 00 00 00       	mov    $0x1,%eax
  801045:	31 d2                	xor    %edx,%edx
  801047:	f7 f1                	div    %ecx
  801049:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	31 d2                	xor    %edx,%edx
  80104f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801051:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801054:	f7 f1                	div    %ecx
  801056:	e9 4a ff ff ff       	jmp    800fa5 <__umoddi3+0x2d>
  80105b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80105c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	5e                   	pop    %esi
  801062:	5f                   	pop    %edi
  801063:	c9                   	leave  
  801064:	c3                   	ret    
  801065:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801068:	39 f7                	cmp    %esi,%edi
  80106a:	72 05                	jb     801071 <__umoddi3+0xf9>
  80106c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80106f:	77 0c                	ja     80107d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801071:	89 f2                	mov    %esi,%edx
  801073:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801076:	29 c8                	sub    %ecx,%eax
  801078:	19 fa                	sbb    %edi,%edx
  80107a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80107d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	c9                   	leave  
  801086:	c3                   	ret    
  801087:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801088:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80108b:	89 c1                	mov    %eax,%ecx
  80108d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801090:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801093:	eb 84                	jmp    801019 <__umoddi3+0xa1>
  801095:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801098:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80109b:	72 eb                	jb     801088 <__umoddi3+0x110>
  80109d:	89 f2                	mov    %esi,%edx
  80109f:	e9 75 ff ff ff       	jmp    801019 <__umoddi3+0xa1>
