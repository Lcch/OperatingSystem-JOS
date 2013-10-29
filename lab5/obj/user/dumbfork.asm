
obj/user/dumbfork.debug:     file format elf32-i386


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
  800046:	e8 1d 0d 00 00       	call   800d68 <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800052:	50                   	push   %eax
  800053:	68 60 1f 80 00       	push   $0x801f60
  800058:	6a 20                	push   $0x20
  80005a:	68 73 1f 80 00       	push   $0x801f73
  80005f:	e8 f4 01 00 00       	call   800258 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	6a 07                	push   $0x7
  800069:	68 00 00 40 00       	push   $0x400000
  80006e:	6a 00                	push   $0x0
  800070:	53                   	push   %ebx
  800071:	56                   	push   %esi
  800072:	e8 15 0d 00 00       	call   800d8c <sys_page_map>
  800077:	83 c4 20             	add    $0x20,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	79 12                	jns    800090 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007e:	50                   	push   %eax
  80007f:	68 83 1f 80 00       	push   $0x801f83
  800084:	6a 22                	push   $0x22
  800086:	68 73 1f 80 00       	push   $0x801f73
  80008b:	e8 c8 01 00 00       	call   800258 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	68 00 10 00 00       	push   $0x1000
  800098:	53                   	push   %ebx
  800099:	68 00 00 40 00       	push   $0x400000
  80009e:	e8 04 0a 00 00       	call   800aa7 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	68 00 00 40 00       	push   $0x400000
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 00 0d 00 00       	call   800db2 <sys_page_unmap>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 12                	jns    8000cb <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b9:	50                   	push   %eax
  8000ba:	68 94 1f 80 00       	push   $0x801f94
  8000bf:	6a 25                	push   $0x25
  8000c1:	68 73 1f 80 00       	push   $0x801f73
  8000c6:	e8 8d 01 00 00       	call   800258 <_panic>
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
  8000ec:	68 a7 1f 80 00       	push   $0x801fa7
  8000f1:	6a 37                	push   $0x37
  8000f3:	68 73 1f 80 00       	push   $0x801f73
  8000f8:	e8 5b 01 00 00       	call   800258 <_panic>
	if (envid == 0) {
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	75 22                	jne    800123 <dumbfork+0x51>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 17 0c 00 00       	call   800d1d <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800121:	eb 6d                	jmp    800190 <dumbfork+0xbe>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800123:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80012a:	b8 00 60 80 00       	mov    $0x806000,%eax
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
  800153:	3d 00 60 80 00       	cmp    $0x806000,%eax
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
  800172:	e8 5e 0c 00 00       	call   800dd5 <sys_env_set_status>
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 12                	jns    800190 <dumbfork+0xbe>
		panic("sys_env_set_status: %e", r);
  80017e:	50                   	push   %eax
  80017f:	68 b7 1f 80 00       	push   $0x801fb7
  800184:	6a 4c                	push   $0x4c
  800186:	68 73 1f 80 00       	push   $0x801f73
  80018b:	e8 c8 00 00 00       	call   800258 <_panic>

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
  8001b0:	b8 ce 1f 80 00       	mov    $0x801fce,%eax
  8001b5:	eb 05                	jmp    8001bc <umain+0x23>
  8001b7:	b8 d5 1f 80 00       	mov    $0x801fd5,%eax
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	50                   	push   %eax
  8001c0:	56                   	push   %esi
  8001c1:	68 db 1f 80 00       	push   $0x801fdb
  8001c6:	e8 65 01 00 00       	call   800330 <cprintf>
		sys_yield();
  8001cb:	e8 71 0b 00 00       	call   800d41 <sys_yield>

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
  8001f7:	e8 21 0b 00 00       	call   800d1d <sys_getenvid>
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800208:	c1 e0 07             	shl    $0x7,%eax
  80020b:	29 d0                	sub    %edx,%eax
  80020d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800212:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800217:	85 f6                	test   %esi,%esi
  800219:	7e 07                	jle    800222 <libmain+0x36>
		binaryname = argv[0];
  80021b:	8b 03                	mov    (%ebx),%eax
  80021d:	a3 00 30 80 00       	mov    %eax,0x803000
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
  80023f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800242:	e8 6b 0e 00 00       	call   8010b2 <close_all>
	sys_env_destroy(0);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	6a 00                	push   $0x0
  80024c:	e8 aa 0a 00 00       	call   800cfb <sys_env_destroy>
  800251:	83 c4 10             	add    $0x10,%esp
}
  800254:	c9                   	leave  
  800255:	c3                   	ret    
	...

00800258 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80025d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800260:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800266:	e8 b2 0a 00 00       	call   800d1d <sys_getenvid>
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	ff 75 0c             	pushl  0xc(%ebp)
  800271:	ff 75 08             	pushl  0x8(%ebp)
  800274:	53                   	push   %ebx
  800275:	50                   	push   %eax
  800276:	68 f8 1f 80 00       	push   $0x801ff8
  80027b:	e8 b0 00 00 00       	call   800330 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	e8 53 00 00 00       	call   8002df <vcprintf>
	cprintf("\n");
  80028c:	c7 04 24 eb 1f 80 00 	movl   $0x801feb,(%esp)
  800293:	e8 98 00 00 00       	call   800330 <cprintf>
  800298:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029b:	cc                   	int3   
  80029c:	eb fd                	jmp    80029b <_panic+0x43>
	...

008002a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002aa:	8b 03                	mov    (%ebx),%eax
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b3:	40                   	inc    %eax
  8002b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bb:	75 1a                	jne    8002d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	68 ff 00 00 00       	push   $0xff
  8002c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c8:	50                   	push   %eax
  8002c9:	e8 e3 09 00 00       	call   800cb1 <sys_cputs>
		b->idx = 0;
  8002ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002d7:	ff 43 04             	incl   0x4(%ebx)
}
  8002da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ef:	00 00 00 
	b.cnt = 0;
  8002f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800308:	50                   	push   %eax
  800309:	68 a0 02 80 00       	push   $0x8002a0
  80030e:	e8 82 01 00 00       	call   800495 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800313:	83 c4 08             	add    $0x8,%esp
  800316:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80031c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	e8 89 09 00 00       	call   800cb1 <sys_cputs>

	return b.cnt;
}
  800328:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800336:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800339:	50                   	push   %eax
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	e8 9d ff ff ff       	call   8002df <vcprintf>
	va_end(ap);

	return cnt;
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d6                	mov    %edx,%esi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	8b 55 0c             	mov    0xc(%ebp),%edx
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80035e:	8b 45 10             	mov    0x10(%ebp),%eax
  800361:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800364:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800367:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80036a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800371:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800374:	72 0c                	jb     800382 <printnum+0x3e>
  800376:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800379:	76 07                	jbe    800382 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037b:	4b                   	dec    %ebx
  80037c:	85 db                	test   %ebx,%ebx
  80037e:	7f 31                	jg     8003b1 <printnum+0x6d>
  800380:	eb 3f                	jmp    8003c1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	57                   	push   %edi
  800386:	4b                   	dec    %ebx
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80038f:	ff 75 d0             	pushl  -0x30(%ebp)
  800392:	ff 75 dc             	pushl  -0x24(%ebp)
  800395:	ff 75 d8             	pushl  -0x28(%ebp)
  800398:	e8 7b 19 00 00       	call   801d18 <__udivdi3>
  80039d:	83 c4 18             	add    $0x18,%esp
  8003a0:	52                   	push   %edx
  8003a1:	50                   	push   %eax
  8003a2:	89 f2                	mov    %esi,%edx
  8003a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a7:	e8 98 ff ff ff       	call   800344 <printnum>
  8003ac:	83 c4 20             	add    $0x20,%esp
  8003af:	eb 10                	jmp    8003c1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	56                   	push   %esi
  8003b5:	57                   	push   %edi
  8003b6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b9:	4b                   	dec    %ebx
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	85 db                	test   %ebx,%ebx
  8003bf:	7f f0                	jg     8003b1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	56                   	push   %esi
  8003c5:	83 ec 04             	sub    $0x4,%esp
  8003c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003cb:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 5b 1a 00 00       	call   801e34 <__umoddi3>
  8003d9:	83 c4 14             	add    $0x14,%esp
  8003dc:	0f be 80 1b 20 80 00 	movsbl 0x80201b(%eax),%eax
  8003e3:	50                   	push   %eax
  8003e4:	ff 55 e4             	call   *-0x1c(%ebp)
  8003e7:	83 c4 10             	add    $0x10,%esp
}
  8003ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ed:	5b                   	pop    %ebx
  8003ee:	5e                   	pop    %esi
  8003ef:	5f                   	pop    %edi
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f5:	83 fa 01             	cmp    $0x1,%edx
  8003f8:	7e 0e                	jle    800408 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	8b 52 04             	mov    0x4(%edx),%edx
  800406:	eb 22                	jmp    80042a <getuint+0x38>
	else if (lflag)
  800408:	85 d2                	test   %edx,%edx
  80040a:	74 10                	je     80041c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80040c:	8b 10                	mov    (%eax),%edx
  80040e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800411:	89 08                	mov    %ecx,(%eax)
  800413:	8b 02                	mov    (%edx),%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	eb 0e                	jmp    80042a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 02                	mov    (%edx),%eax
  800425:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042f:	83 fa 01             	cmp    $0x1,%edx
  800432:	7e 0e                	jle    800442 <getint+0x16>
		return va_arg(*ap, long long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 08             	lea    0x8(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	8b 52 04             	mov    0x4(%edx),%edx
  800440:	eb 1a                	jmp    80045c <getint+0x30>
	else if (lflag)
  800442:	85 d2                	test   %edx,%edx
  800444:	74 0c                	je     800452 <getint+0x26>
		return va_arg(*ap, long);
  800446:	8b 10                	mov    (%eax),%edx
  800448:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044b:	89 08                	mov    %ecx,(%eax)
  80044d:	8b 02                	mov    (%edx),%eax
  80044f:	99                   	cltd   
  800450:	eb 0a                	jmp    80045c <getint+0x30>
	else
		return va_arg(*ap, int);
  800452:	8b 10                	mov    (%eax),%edx
  800454:	8d 4a 04             	lea    0x4(%edx),%ecx
  800457:	89 08                	mov    %ecx,(%eax)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	99                   	cltd   
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800464:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800467:	8b 10                	mov    (%eax),%edx
  800469:	3b 50 04             	cmp    0x4(%eax),%edx
  80046c:	73 08                	jae    800476 <sprintputch+0x18>
		*b->buf++ = ch;
  80046e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800471:	88 0a                	mov    %cl,(%edx)
  800473:	42                   	inc    %edx
  800474:	89 10                	mov    %edx,(%eax)
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80047e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800481:	50                   	push   %eax
  800482:	ff 75 10             	pushl  0x10(%ebp)
  800485:	ff 75 0c             	pushl  0xc(%ebp)
  800488:	ff 75 08             	pushl  0x8(%ebp)
  80048b:	e8 05 00 00 00       	call   800495 <vprintfmt>
	va_end(ap);
  800490:	83 c4 10             	add    $0x10,%esp
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	57                   	push   %edi
  800499:	56                   	push   %esi
  80049a:	53                   	push   %ebx
  80049b:	83 ec 2c             	sub    $0x2c,%esp
  80049e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004a1:	8b 75 10             	mov    0x10(%ebp),%esi
  8004a4:	eb 13                	jmp    8004b9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	0f 84 6d 03 00 00    	je     80081b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	57                   	push   %edi
  8004b2:	50                   	push   %eax
  8004b3:	ff 55 08             	call   *0x8(%ebp)
  8004b6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b9:	0f b6 06             	movzbl (%esi),%eax
  8004bc:	46                   	inc    %esi
  8004bd:	83 f8 25             	cmp    $0x25,%eax
  8004c0:	75 e4                	jne    8004a6 <vprintfmt+0x11>
  8004c2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004c6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004cd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004d4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e0:	eb 28                	jmp    80050a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004e8:	eb 20                	jmp    80050a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ec:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004f0:	eb 18                	jmp    80050a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800500:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800503:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8a 06                	mov    (%esi),%al
  80050c:	0f b6 d0             	movzbl %al,%edx
  80050f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800512:	83 e8 23             	sub    $0x23,%eax
  800515:	3c 55                	cmp    $0x55,%al
  800517:	0f 87 e0 02 00 00    	ja     8007fd <vprintfmt+0x368>
  80051d:	0f b6 c0             	movzbl %al,%eax
  800520:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800527:	83 ea 30             	sub    $0x30,%edx
  80052a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80052d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800530:	8d 50 d0             	lea    -0x30(%eax),%edx
  800533:	83 fa 09             	cmp    $0x9,%edx
  800536:	77 44                	ja     80057c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	89 de                	mov    %ebx,%esi
  80053a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80053d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80053e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800541:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800545:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800548:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80054b:	83 fb 09             	cmp    $0x9,%ebx
  80054e:	76 ed                	jbe    80053d <vprintfmt+0xa8>
  800550:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800553:	eb 29                	jmp    80057e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800565:	eb 17                	jmp    80057e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800567:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056b:	78 85                	js     8004f2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	eb 99                	jmp    80050a <vprintfmt+0x75>
  800571:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800573:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80057a:	eb 8e                	jmp    80050a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80057e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800582:	79 86                	jns    80050a <vprintfmt+0x75>
  800584:	e9 74 ff ff ff       	jmp    8004fd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800589:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	89 de                	mov    %ebx,%esi
  80058c:	e9 79 ff ff ff       	jmp    80050a <vprintfmt+0x75>
  800591:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	57                   	push   %edi
  8005a1:	ff 30                	pushl  (%eax)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ac:	e9 08 ff ff ff       	jmp    8004b9 <vprintfmt+0x24>
  8005b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	79 02                	jns    8005c5 <vprintfmt+0x130>
  8005c3:	f7 d8                	neg    %eax
  8005c5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c7:	83 f8 0f             	cmp    $0xf,%eax
  8005ca:	7f 0b                	jg     8005d7 <vprintfmt+0x142>
  8005cc:	8b 04 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	75 1a                	jne    8005f1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005d7:	52                   	push   %edx
  8005d8:	68 33 20 80 00       	push   $0x802033
  8005dd:	57                   	push   %edi
  8005de:	ff 75 08             	pushl  0x8(%ebp)
  8005e1:	e8 92 fe ff ff       	call   800478 <printfmt>
  8005e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005ec:	e9 c8 fe ff ff       	jmp    8004b9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005f1:	50                   	push   %eax
  8005f2:	68 fb 23 80 00       	push   $0x8023fb
  8005f7:	57                   	push   %edi
  8005f8:	ff 75 08             	pushl  0x8(%ebp)
  8005fb:	e8 78 fe ff ff       	call   800478 <printfmt>
  800600:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800606:	e9 ae fe ff ff       	jmp    8004b9 <vprintfmt+0x24>
  80060b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80060e:	89 de                	mov    %ebx,%esi
  800610:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800624:	85 c0                	test   %eax,%eax
  800626:	75 07                	jne    80062f <vprintfmt+0x19a>
				p = "(null)";
  800628:	c7 45 d0 2c 20 80 00 	movl   $0x80202c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80062f:	85 db                	test   %ebx,%ebx
  800631:	7e 42                	jle    800675 <vprintfmt+0x1e0>
  800633:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800637:	74 3c                	je     800675 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	51                   	push   %ecx
  80063d:	ff 75 d0             	pushl  -0x30(%ebp)
  800640:	e8 6f 02 00 00       	call   8008b4 <strnlen>
  800645:	29 c3                	sub    %eax,%ebx
  800647:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7e 24                	jle    800675 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800651:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800655:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800658:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	53                   	push   %ebx
  800660:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	4e                   	dec    %esi
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	85 f6                	test   %esi,%esi
  800669:	7f f0                	jg     80065b <vprintfmt+0x1c6>
  80066b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80066e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800678:	0f be 02             	movsbl (%edx),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	75 47                	jne    8006c6 <vprintfmt+0x231>
  80067f:	eb 37                	jmp    8006b8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800681:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800685:	74 16                	je     80069d <vprintfmt+0x208>
  800687:	8d 50 e0             	lea    -0x20(%eax),%edx
  80068a:	83 fa 5e             	cmp    $0x5e,%edx
  80068d:	76 0e                	jbe    80069d <vprintfmt+0x208>
					putch('?', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	57                   	push   %edi
  800693:	6a 3f                	push   $0x3f
  800695:	ff 55 08             	call   *0x8(%ebp)
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb 0b                	jmp    8006a8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	57                   	push   %edi
  8006a1:	50                   	push   %eax
  8006a2:	ff 55 08             	call   *0x8(%ebp)
  8006a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a8:	ff 4d e4             	decl   -0x1c(%ebp)
  8006ab:	0f be 03             	movsbl (%ebx),%eax
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	74 03                	je     8006b5 <vprintfmt+0x220>
  8006b2:	43                   	inc    %ebx
  8006b3:	eb 1b                	jmp    8006d0 <vprintfmt+0x23b>
  8006b5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bc:	7f 1e                	jg     8006dc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006c1:	e9 f3 fd ff ff       	jmp    8004b9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006c9:	43                   	inc    %ebx
  8006ca:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006cd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006d0:	85 f6                	test   %esi,%esi
  8006d2:	78 ad                	js     800681 <vprintfmt+0x1ec>
  8006d4:	4e                   	dec    %esi
  8006d5:	79 aa                	jns    800681 <vprintfmt+0x1ec>
  8006d7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006da:	eb dc                	jmp    8006b8 <vprintfmt+0x223>
  8006dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 20                	push   $0x20
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e8:	4b                   	dec    %ebx
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 db                	test   %ebx,%ebx
  8006ee:	7f ef                	jg     8006df <vprintfmt+0x24a>
  8006f0:	e9 c4 fd ff ff       	jmp    8004b9 <vprintfmt+0x24>
  8006f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f8:	89 ca                	mov    %ecx,%edx
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 2a fd ff ff       	call   80042c <getint>
  800702:	89 c3                	mov    %eax,%ebx
  800704:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800706:	85 d2                	test   %edx,%edx
  800708:	78 0a                	js     800714 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80070a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070f:	e9 b0 00 00 00       	jmp    8007c4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	57                   	push   %edi
  800718:	6a 2d                	push   $0x2d
  80071a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80071d:	f7 db                	neg    %ebx
  80071f:	83 d6 00             	adc    $0x0,%esi
  800722:	f7 de                	neg    %esi
  800724:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072c:	e9 93 00 00 00       	jmp    8007c4 <vprintfmt+0x32f>
  800731:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800734:	89 ca                	mov    %ecx,%edx
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
  800739:	e8 b4 fc ff ff       	call   8003f2 <getuint>
  80073e:	89 c3                	mov    %eax,%ebx
  800740:	89 d6                	mov    %edx,%esi
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800747:	eb 7b                	jmp    8007c4 <vprintfmt+0x32f>
  800749:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80074c:	89 ca                	mov    %ecx,%edx
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 d6 fc ff ff       	call   80042c <getint>
  800756:	89 c3                	mov    %eax,%ebx
  800758:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80075a:	85 d2                	test   %edx,%edx
  80075c:	78 07                	js     800765 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80075e:	b8 08 00 00 00       	mov    $0x8,%eax
  800763:	eb 5f                	jmp    8007c4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	57                   	push   %edi
  800769:	6a 2d                	push   $0x2d
  80076b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80076e:	f7 db                	neg    %ebx
  800770:	83 d6 00             	adc    $0x0,%esi
  800773:	f7 de                	neg    %esi
  800775:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800778:	b8 08 00 00 00       	mov    $0x8,%eax
  80077d:	eb 45                	jmp    8007c4 <vprintfmt+0x32f>
  80077f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	57                   	push   %edi
  800786:	6a 30                	push   $0x30
  800788:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80078b:	83 c4 08             	add    $0x8,%esp
  80078e:	57                   	push   %edi
  80078f:	6a 78                	push   $0x78
  800791:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079d:	8b 18                	mov    (%eax),%ebx
  80079f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007ac:	eb 16                	jmp    8007c4 <vprintfmt+0x32f>
  8007ae:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b1:	89 ca                	mov    %ecx,%edx
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b6:	e8 37 fc ff ff       	call   8003f2 <getuint>
  8007bb:	89 c3                	mov    %eax,%ebx
  8007bd:	89 d6                	mov    %edx,%esi
			base = 16;
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c4:	83 ec 0c             	sub    $0xc,%esp
  8007c7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007cb:	52                   	push   %edx
  8007cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	89 fa                	mov    %edi,%edx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	e8 68 fb ff ff       	call   800344 <printnum>
			break;
  8007dc:	83 c4 20             	add    $0x20,%esp
  8007df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007e2:	e9 d2 fc ff ff       	jmp    8004b9 <vprintfmt+0x24>
  8007e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	57                   	push   %edi
  8007ee:	52                   	push   %edx
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f8:	e9 bc fc ff ff       	jmp    8004b9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	57                   	push   %edi
  800801:	6a 25                	push   $0x25
  800803:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	eb 02                	jmp    80080d <vprintfmt+0x378>
  80080b:	89 c6                	mov    %eax,%esi
  80080d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800810:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800814:	75 f5                	jne    80080b <vprintfmt+0x376>
  800816:	e9 9e fc ff ff       	jmp    8004b9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80081b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 18             	sub    $0x18,%esp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800832:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800836:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800840:	85 c0                	test   %eax,%eax
  800842:	74 26                	je     80086a <vsnprintf+0x47>
  800844:	85 d2                	test   %edx,%edx
  800846:	7e 29                	jle    800871 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800848:	ff 75 14             	pushl  0x14(%ebp)
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	68 5e 04 80 00       	push   $0x80045e
  800857:	e8 39 fc ff ff       	call   800495 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 0c                	jmp    800876 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80086a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086f:	eb 05                	jmp    800876 <vsnprintf+0x53>
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800881:	50                   	push   %eax
  800882:	ff 75 10             	pushl  0x10(%ebp)
  800885:	ff 75 0c             	pushl  0xc(%ebp)
  800888:	ff 75 08             	pushl  0x8(%ebp)
  80088b:	e8 93 ff ff ff       	call   800823 <vsnprintf>
	va_end(ap);

	return rc;
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    
	...

00800894 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	80 3a 00             	cmpb   $0x0,(%edx)
  80089d:	74 0e                	je     8008ad <strlen+0x19>
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a9:	75 f9                	jne    8008a4 <strlen+0x10>
  8008ab:	eb 05                	jmp    8008b2 <strlen+0x1e>
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	74 17                	je     8008d8 <strnlen+0x24>
  8008c1:	80 39 00             	cmpb   $0x0,(%ecx)
  8008c4:	74 19                	je     8008df <strnlen+0x2b>
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008cb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	39 d0                	cmp    %edx,%eax
  8008ce:	74 14                	je     8008e4 <strnlen+0x30>
  8008d0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d4:	75 f5                	jne    8008cb <strnlen+0x17>
  8008d6:	eb 0c                	jmp    8008e4 <strnlen+0x30>
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dd:	eb 05                	jmp    8008e4 <strnlen+0x30>
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    

008008e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008f8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008fb:	42                   	inc    %edx
  8008fc:	84 c9                	test   %cl,%cl
  8008fe:	75 f5                	jne    8008f5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090a:	53                   	push   %ebx
  80090b:	e8 84 ff ff ff       	call   800894 <strlen>
  800910:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800913:	ff 75 0c             	pushl  0xc(%ebp)
  800916:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800919:	50                   	push   %eax
  80091a:	e8 c7 ff ff ff       	call   8008e6 <strcpy>
	return dst;
}
  80091f:	89 d8                	mov    %ebx,%eax
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	85 f6                	test   %esi,%esi
  800936:	74 15                	je     80094d <strncpy+0x27>
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80093d:	8a 1a                	mov    (%edx),%bl
  80093f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800942:	80 3a 01             	cmpb   $0x1,(%edx)
  800945:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	41                   	inc    %ecx
  800949:	39 ce                	cmp    %ecx,%esi
  80094b:	77 f0                	ja     80093d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	85 f6                	test   %esi,%esi
  800962:	74 32                	je     800996 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800964:	83 fe 01             	cmp    $0x1,%esi
  800967:	74 22                	je     80098b <strlcpy+0x3a>
  800969:	8a 0b                	mov    (%ebx),%cl
  80096b:	84 c9                	test   %cl,%cl
  80096d:	74 20                	je     80098f <strlcpy+0x3e>
  80096f:	89 f8                	mov    %edi,%eax
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800976:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	88 08                	mov    %cl,(%eax)
  80097b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80097c:	39 f2                	cmp    %esi,%edx
  80097e:	74 11                	je     800991 <strlcpy+0x40>
  800980:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800984:	42                   	inc    %edx
  800985:	84 c9                	test   %cl,%cl
  800987:	75 f0                	jne    800979 <strlcpy+0x28>
  800989:	eb 06                	jmp    800991 <strlcpy+0x40>
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	eb 02                	jmp    800991 <strlcpy+0x40>
  80098f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800991:	c6 00 00             	movb   $0x0,(%eax)
  800994:	eb 02                	jmp    800998 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800996:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800998:	29 f8                	sub    %edi,%eax
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a8:	8a 01                	mov    (%ecx),%al
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 10                	je     8009be <strcmp+0x1f>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	75 0c                	jne    8009be <strcmp+0x1f>
		p++, q++;
  8009b2:	41                   	inc    %ecx
  8009b3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b4:	8a 01                	mov    (%ecx),%al
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x1f>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 f4                	je     8009b2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009d5:	85 c0                	test   %eax,%eax
  8009d7:	74 1b                	je     8009f4 <strncmp+0x2c>
  8009d9:	8a 1a                	mov    (%edx),%bl
  8009db:	84 db                	test   %bl,%bl
  8009dd:	74 24                	je     800a03 <strncmp+0x3b>
  8009df:	3a 19                	cmp    (%ecx),%bl
  8009e1:	75 20                	jne    800a03 <strncmp+0x3b>
  8009e3:	48                   	dec    %eax
  8009e4:	74 15                	je     8009fb <strncmp+0x33>
		n--, p++, q++;
  8009e6:	42                   	inc    %edx
  8009e7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e8:	8a 1a                	mov    (%edx),%bl
  8009ea:	84 db                	test   %bl,%bl
  8009ec:	74 15                	je     800a03 <strncmp+0x3b>
  8009ee:	3a 19                	cmp    (%ecx),%bl
  8009f0:	74 f1                	je     8009e3 <strncmp+0x1b>
  8009f2:	eb 0f                	jmp    800a03 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	eb 05                	jmp    800a00 <strncmp+0x38>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a00:	5b                   	pop    %ebx
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a03:	0f b6 02             	movzbl (%edx),%eax
  800a06:	0f b6 11             	movzbl (%ecx),%edx
  800a09:	29 d0                	sub    %edx,%eax
  800a0b:	eb f3                	jmp    800a00 <strncmp+0x38>

00800a0d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a16:	8a 10                	mov    (%eax),%dl
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 18                	je     800a34 <strchr+0x27>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 06                	jne    800a26 <strchr+0x19>
  800a20:	eb 17                	jmp    800a39 <strchr+0x2c>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	74 13                	je     800a39 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a26:	40                   	inc    %eax
  800a27:	8a 10                	mov    (%eax),%dl
  800a29:	84 d2                	test   %dl,%dl
  800a2b:	75 f5                	jne    800a22 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	eb 05                	jmp    800a39 <strchr+0x2c>
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a44:	8a 10                	mov    (%eax),%dl
  800a46:	84 d2                	test   %dl,%dl
  800a48:	74 11                	je     800a5b <strfind+0x20>
		if (*s == c)
  800a4a:	38 ca                	cmp    %cl,%dl
  800a4c:	75 06                	jne    800a54 <strfind+0x19>
  800a4e:	eb 0b                	jmp    800a5b <strfind+0x20>
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	74 07                	je     800a5b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a54:	40                   	inc    %eax
  800a55:	8a 10                	mov    (%eax),%dl
  800a57:	84 d2                	test   %dl,%dl
  800a59:	75 f5                	jne    800a50 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6c:	85 c9                	test   %ecx,%ecx
  800a6e:	74 30                	je     800aa0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a70:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a76:	75 25                	jne    800a9d <memset+0x40>
  800a78:	f6 c1 03             	test   $0x3,%cl
  800a7b:	75 20                	jne    800a9d <memset+0x40>
		c &= 0xFF;
  800a7d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a80:	89 d3                	mov    %edx,%ebx
  800a82:	c1 e3 08             	shl    $0x8,%ebx
  800a85:	89 d6                	mov    %edx,%esi
  800a87:	c1 e6 18             	shl    $0x18,%esi
  800a8a:	89 d0                	mov    %edx,%eax
  800a8c:	c1 e0 10             	shl    $0x10,%eax
  800a8f:	09 f0                	or     %esi,%eax
  800a91:	09 d0                	or     %edx,%eax
  800a93:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a95:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a98:	fc                   	cld    
  800a99:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9b:	eb 03                	jmp    800aa0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9d:	fc                   	cld    
  800a9e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa0:	89 f8                	mov    %edi,%eax
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab5:	39 c6                	cmp    %eax,%esi
  800ab7:	73 34                	jae    800aed <memmove+0x46>
  800ab9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abc:	39 d0                	cmp    %edx,%eax
  800abe:	73 2d                	jae    800aed <memmove+0x46>
		s += n;
		d += n;
  800ac0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	f6 c2 03             	test   $0x3,%dl
  800ac6:	75 1b                	jne    800ae3 <memmove+0x3c>
  800ac8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ace:	75 13                	jne    800ae3 <memmove+0x3c>
  800ad0:	f6 c1 03             	test   $0x3,%cl
  800ad3:	75 0e                	jne    800ae3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad5:	83 ef 04             	sub    $0x4,%edi
  800ad8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ade:	fd                   	std    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 07                	jmp    800aea <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae3:	4f                   	dec    %edi
  800ae4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae7:	fd                   	std    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aea:	fc                   	cld    
  800aeb:	eb 20                	jmp    800b0d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af3:	75 13                	jne    800b08 <memmove+0x61>
  800af5:	a8 03                	test   $0x3,%al
  800af7:	75 0f                	jne    800b08 <memmove+0x61>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 0a                	jne    800b08 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afe:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	fc                   	cld    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 05                	jmp    800b0d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	fc                   	cld    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b14:	ff 75 10             	pushl  0x10(%ebp)
  800b17:	ff 75 0c             	pushl  0xc(%ebp)
  800b1a:	ff 75 08             	pushl  0x8(%ebp)
  800b1d:	e8 85 ff ff ff       	call   800aa7 <memmove>
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b33:	85 ff                	test   %edi,%edi
  800b35:	74 32                	je     800b69 <memcmp+0x45>
		if (*s1 != *s2)
  800b37:	8a 03                	mov    (%ebx),%al
  800b39:	8a 0e                	mov    (%esi),%cl
  800b3b:	38 c8                	cmp    %cl,%al
  800b3d:	74 19                	je     800b58 <memcmp+0x34>
  800b3f:	eb 0d                	jmp    800b4e <memcmp+0x2a>
  800b41:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b45:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b49:	42                   	inc    %edx
  800b4a:	38 c8                	cmp    %cl,%al
  800b4c:	74 10                	je     800b5e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b4e:	0f b6 c0             	movzbl %al,%eax
  800b51:	0f b6 c9             	movzbl %cl,%ecx
  800b54:	29 c8                	sub    %ecx,%eax
  800b56:	eb 16                	jmp    800b6e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b58:	4f                   	dec    %edi
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	39 fa                	cmp    %edi,%edx
  800b60:	75 df                	jne    800b41 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	eb 05                	jmp    800b6e <memcmp+0x4a>
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7e:	39 d0                	cmp    %edx,%eax
  800b80:	73 12                	jae    800b94 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b82:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b85:	38 08                	cmp    %cl,(%eax)
  800b87:	75 06                	jne    800b8f <memfind+0x1c>
  800b89:	eb 09                	jmp    800b94 <memfind+0x21>
  800b8b:	38 08                	cmp    %cl,(%eax)
  800b8d:	74 05                	je     800b94 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8f:	40                   	inc    %eax
  800b90:	39 c2                	cmp    %eax,%edx
  800b92:	77 f7                	ja     800b8b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba2:	eb 01                	jmp    800ba5 <strtol+0xf>
		s++;
  800ba4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba5:	8a 02                	mov    (%edx),%al
  800ba7:	3c 20                	cmp    $0x20,%al
  800ba9:	74 f9                	je     800ba4 <strtol+0xe>
  800bab:	3c 09                	cmp    $0x9,%al
  800bad:	74 f5                	je     800ba4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800baf:	3c 2b                	cmp    $0x2b,%al
  800bb1:	75 08                	jne    800bbb <strtol+0x25>
		s++;
  800bb3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb9:	eb 13                	jmp    800bce <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bbb:	3c 2d                	cmp    $0x2d,%al
  800bbd:	75 0a                	jne    800bc9 <strtol+0x33>
		s++, neg = 1;
  800bbf:	8d 52 01             	lea    0x1(%edx),%edx
  800bc2:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc7:	eb 05                	jmp    800bce <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bce:	85 db                	test   %ebx,%ebx
  800bd0:	74 05                	je     800bd7 <strtol+0x41>
  800bd2:	83 fb 10             	cmp    $0x10,%ebx
  800bd5:	75 28                	jne    800bff <strtol+0x69>
  800bd7:	8a 02                	mov    (%edx),%al
  800bd9:	3c 30                	cmp    $0x30,%al
  800bdb:	75 10                	jne    800bed <strtol+0x57>
  800bdd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800be1:	75 0a                	jne    800bed <strtol+0x57>
		s += 2, base = 16;
  800be3:	83 c2 02             	add    $0x2,%edx
  800be6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800beb:	eb 12                	jmp    800bff <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bed:	85 db                	test   %ebx,%ebx
  800bef:	75 0e                	jne    800bff <strtol+0x69>
  800bf1:	3c 30                	cmp    $0x30,%al
  800bf3:	75 05                	jne    800bfa <strtol+0x64>
		s++, base = 8;
  800bf5:	42                   	inc    %edx
  800bf6:	b3 08                	mov    $0x8,%bl
  800bf8:	eb 05                	jmp    800bff <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bfa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c06:	8a 0a                	mov    (%edx),%cl
  800c08:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c0b:	80 fb 09             	cmp    $0x9,%bl
  800c0e:	77 08                	ja     800c18 <strtol+0x82>
			dig = *s - '0';
  800c10:	0f be c9             	movsbl %cl,%ecx
  800c13:	83 e9 30             	sub    $0x30,%ecx
  800c16:	eb 1e                	jmp    800c36 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c18:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c1b:	80 fb 19             	cmp    $0x19,%bl
  800c1e:	77 08                	ja     800c28 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c20:	0f be c9             	movsbl %cl,%ecx
  800c23:	83 e9 57             	sub    $0x57,%ecx
  800c26:	eb 0e                	jmp    800c36 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c28:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c2b:	80 fb 19             	cmp    $0x19,%bl
  800c2e:	77 13                	ja     800c43 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c30:	0f be c9             	movsbl %cl,%ecx
  800c33:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c36:	39 f1                	cmp    %esi,%ecx
  800c38:	7d 0d                	jge    800c47 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c3a:	42                   	inc    %edx
  800c3b:	0f af c6             	imul   %esi,%eax
  800c3e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c41:	eb c3                	jmp    800c06 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c43:	89 c1                	mov    %eax,%ecx
  800c45:	eb 02                	jmp    800c49 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c47:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4d:	74 05                	je     800c54 <strtol+0xbe>
		*endptr = (char *) s;
  800c4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c52:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c54:	85 ff                	test   %edi,%edi
  800c56:	74 04                	je     800c5c <strtol+0xc6>
  800c58:	89 c8                	mov    %ecx,%eax
  800c5a:	f7 d8                	neg    %eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    
  800c61:	00 00                	add    %al,(%eax)
	...

00800c64 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 1c             	sub    $0x1c,%esp
  800c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c70:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c73:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	8b 75 14             	mov    0x14(%ebp),%esi
  800c78:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c81:	cd 30                	int    $0x30
  800c83:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c89:	74 1c                	je     800ca7 <syscall+0x43>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 18                	jle    800ca7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c96:	68 1f 23 80 00       	push   $0x80231f
  800c9b:	6a 42                	push   $0x42
  800c9d:	68 3c 23 80 00       	push   $0x80233c
  800ca2:	e8 b1 f5 ff ff       	call   800258 <_panic>

	return ret;
}
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccd:	e8 92 ff ff ff       	call   800c64 <syscall>
  800cd2:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cdd:	6a 00                	push   $0x0
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	6a 00                	push   $0x0
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	ba 00 00 00 00       	mov    $0x0,%edx
  800cef:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf4:	e8 6b ff ff ff       	call   800c64 <syscall>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d01:	6a 00                	push   $0x0
  800d03:	6a 00                	push   $0x0
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d11:	b8 03 00 00 00       	mov    $0x3,%eax
  800d16:	e8 49 ff ff ff       	call   800c64 <syscall>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3a:	e8 25 ff ff ff       	call   800c64 <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <sys_yield>:

void
sys_yield(void)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d47:	6a 00                	push   $0x0
  800d49:	6a 00                	push   $0x0
  800d4b:	6a 00                	push   $0x0
  800d4d:	6a 00                	push   $0x0
  800d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d54:	ba 00 00 00 00       	mov    $0x0,%edx
  800d59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5e:	e8 01 ff ff ff       	call   800c64 <syscall>
  800d63:	83 c4 10             	add    $0x10,%esp
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d6e:	6a 00                	push   $0x0
  800d70:	6a 00                	push   $0x0
  800d72:	ff 75 10             	pushl  0x10(%ebp)
  800d75:	ff 75 0c             	pushl  0xc(%ebp)
  800d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d80:	b8 04 00 00 00       	mov    $0x4,%eax
  800d85:	e8 da fe ff ff       	call   800c64 <syscall>
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d92:	ff 75 18             	pushl  0x18(%ebp)
  800d95:	ff 75 14             	pushl  0x14(%ebp)
  800d98:	ff 75 10             	pushl  0x10(%ebp)
  800d9b:	ff 75 0c             	pushl  0xc(%ebp)
  800d9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da1:	ba 01 00 00 00       	mov    $0x1,%edx
  800da6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dab:	e8 b4 fe ff ff       	call   800c64 <syscall>
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800db8:	6a 00                	push   $0x0
  800dba:	6a 00                	push   $0x0
  800dbc:	6a 00                	push   $0x0
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dce:	e8 91 fe ff ff       	call   800c64 <syscall>
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	ff 75 0c             	pushl  0xc(%ebp)
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	ba 01 00 00 00       	mov    $0x1,%edx
  800dec:	b8 08 00 00 00       	mov    $0x8,%eax
  800df1:	e8 6e fe ff ff       	call   800c64 <syscall>
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dfe:	6a 00                	push   $0x0
  800e00:	6a 00                	push   $0x0
  800e02:	6a 00                	push   $0x0
  800e04:	ff 75 0c             	pushl  0xc(%ebp)
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800e0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e14:	e8 4b fe ff ff       	call   800c64 <syscall>
}
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e21:	6a 00                	push   $0x0
  800e23:	6a 00                	push   $0x0
  800e25:	6a 00                	push   $0x0
  800e27:	ff 75 0c             	pushl  0xc(%ebp)
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e37:	e8 28 fe ff ff       	call   800c64 <syscall>
}
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e44:	6a 00                	push   $0x0
  800e46:	ff 75 14             	pushl  0x14(%ebp)
  800e49:	ff 75 10             	pushl  0x10(%ebp)
  800e4c:	ff 75 0c             	pushl  0xc(%ebp)
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5c:	e8 03 fe ff ff       	call   800c64 <syscall>
}
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e69:	6a 00                	push   $0x0
  800e6b:	6a 00                	push   $0x0
  800e6d:	6a 00                	push   $0x0
  800e6f:	6a 00                	push   $0x0
  800e71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e74:	ba 01 00 00 00       	mov    $0x1,%edx
  800e79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7e:	e8 e1 fd ff ff       	call   800c64 <syscall>
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e8b:	6a 00                	push   $0x0
  800e8d:	6a 00                	push   $0x0
  800e8f:	6a 00                	push   $0x0
  800e91:	ff 75 0c             	pushl  0xc(%ebp)
  800e94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea1:	e8 be fd ff ff       	call   800c64 <syscall>
}
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb3:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ebb:	ff 75 08             	pushl  0x8(%ebp)
  800ebe:	e8 e5 ff ff ff       	call   800ea8 <fd2num>
  800ec3:	83 c4 04             	add    $0x4,%esp
  800ec6:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ecb:	c1 e0 0c             	shl    $0xc,%eax
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800edc:	a8 01                	test   $0x1,%al
  800ede:	74 34                	je     800f14 <fd_alloc+0x44>
  800ee0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ee5:	a8 01                	test   $0x1,%al
  800ee7:	74 32                	je     800f1b <fd_alloc+0x4b>
  800ee9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	c1 ea 16             	shr    $0x16,%edx
  800ef5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	74 1f                	je     800f20 <fd_alloc+0x50>
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	c1 ea 0c             	shr    $0xc,%edx
  800f06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	75 17                	jne    800f29 <fd_alloc+0x59>
  800f12:	eb 0c                	jmp    800f20 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f14:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f19:	eb 05                	jmp    800f20 <fd_alloc+0x50>
  800f1b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f20:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 17                	jmp    800f40 <fd_alloc+0x70>
  800f29:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f33:	75 b9                	jne    800eee <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f3b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f40:	5b                   	pop    %ebx
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f49:	83 f8 1f             	cmp    $0x1f,%eax
  800f4c:	77 36                	ja     800f84 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f53:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f56:	89 c2                	mov    %eax,%edx
  800f58:	c1 ea 16             	shr    $0x16,%edx
  800f5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	74 24                	je     800f8b <fd_lookup+0x48>
  800f67:	89 c2                	mov    %eax,%edx
  800f69:	c1 ea 0c             	shr    $0xc,%edx
  800f6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	74 1a                	je     800f92 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f82:	eb 13                	jmp    800f97 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f89:	eb 0c                	jmp    800f97 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f90:	eb 05                	jmp    800f97 <fd_lookup+0x54>
  800f92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800fa6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800fac:	74 0d                	je     800fbb <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb3:	eb 14                	jmp    800fc9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800fb5:	39 0a                	cmp    %ecx,(%edx)
  800fb7:	75 10                	jne    800fc9 <dev_lookup+0x30>
  800fb9:	eb 05                	jmp    800fc0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fbb:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800fc0:	89 13                	mov    %edx,(%ebx)
			return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	eb 31                	jmp    800ffa <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc9:	40                   	inc    %eax
  800fca:	8b 14 85 cc 23 80 00 	mov    0x8023cc(,%eax,4),%edx
  800fd1:	85 d2                	test   %edx,%edx
  800fd3:	75 e0                	jne    800fb5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fda:	8b 40 48             	mov    0x48(%eax),%eax
  800fdd:	83 ec 04             	sub    $0x4,%esp
  800fe0:	51                   	push   %ecx
  800fe1:	50                   	push   %eax
  800fe2:	68 4c 23 80 00       	push   $0x80234c
  800fe7:	e8 44 f3 ff ff       	call   800330 <cprintf>
	*dev = 0;
  800fec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ffa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 20             	sub    $0x20,%esp
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
  80100a:	8a 45 0c             	mov    0xc(%ebp),%al
  80100d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801010:	56                   	push   %esi
  801011:	e8 92 fe ff ff       	call   800ea8 <fd2num>
  801016:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801019:	89 14 24             	mov    %edx,(%esp)
  80101c:	50                   	push   %eax
  80101d:	e8 21 ff ff ff       	call   800f43 <fd_lookup>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 05                	js     801030 <fd_close+0x31>
	    || fd != fd2)
  80102b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80102e:	74 0d                	je     80103d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801030:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801034:	75 48                	jne    80107e <fd_close+0x7f>
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	eb 41                	jmp    80107e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	ff 36                	pushl  (%esi)
  801046:	e8 4e ff ff ff       	call   800f99 <dev_lookup>
  80104b:	89 c3                	mov    %eax,%ebx
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 1c                	js     801070 <fd_close+0x71>
		if (dev->dev_close)
  801054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801057:	8b 40 10             	mov    0x10(%eax),%eax
  80105a:	85 c0                	test   %eax,%eax
  80105c:	74 0d                	je     80106b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	56                   	push   %esi
  801062:	ff d0                	call   *%eax
  801064:	89 c3                	mov    %eax,%ebx
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	eb 05                	jmp    801070 <fd_close+0x71>
		else
			r = 0;
  80106b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	56                   	push   %esi
  801074:	6a 00                	push   $0x0
  801076:	e8 37 fd ff ff       	call   800db2 <sys_page_unmap>
	return r;
  80107b:	83 c4 10             	add    $0x10,%esp
}
  80107e:	89 d8                	mov    %ebx,%eax
  801080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801090:	50                   	push   %eax
  801091:	ff 75 08             	pushl  0x8(%ebp)
  801094:	e8 aa fe ff ff       	call   800f43 <fd_lookup>
  801099:	83 c4 08             	add    $0x8,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 10                	js     8010b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	6a 01                	push   $0x1
  8010a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a8:	e8 52 ff ff ff       	call   800fff <fd_close>
  8010ad:	83 c4 10             	add    $0x10,%esp
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <close_all>:

void
close_all(void)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	53                   	push   %ebx
  8010c2:	e8 c0 ff ff ff       	call   801087 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c7:	43                   	inc    %ebx
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	83 fb 20             	cmp    $0x20,%ebx
  8010ce:	75 ee                	jne    8010be <close_all+0xc>
		close(i);
}
  8010d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 2c             	sub    $0x2c,%esp
  8010de:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	ff 75 08             	pushl  0x8(%ebp)
  8010e8:	e8 56 fe ff ff       	call   800f43 <fd_lookup>
  8010ed:	89 c3                	mov    %eax,%ebx
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	0f 88 c0 00 00 00    	js     8011ba <dup+0xe5>
		return r;
	close(newfdnum);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	57                   	push   %edi
  8010fe:	e8 84 ff ff ff       	call   801087 <close>

	newfd = INDEX2FD(newfdnum);
  801103:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801109:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80110c:	83 c4 04             	add    $0x4,%esp
  80110f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801112:	e8 a1 fd ff ff       	call   800eb8 <fd2data>
  801117:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801119:	89 34 24             	mov    %esi,(%esp)
  80111c:	e8 97 fd ff ff       	call   800eb8 <fd2data>
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801127:	89 d8                	mov    %ebx,%eax
  801129:	c1 e8 16             	shr    $0x16,%eax
  80112c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801133:	a8 01                	test   $0x1,%al
  801135:	74 37                	je     80116e <dup+0x99>
  801137:	89 d8                	mov    %ebx,%eax
  801139:	c1 e8 0c             	shr    $0xc,%eax
  80113c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801143:	f6 c2 01             	test   $0x1,%dl
  801146:	74 26                	je     80116e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801148:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	25 07 0e 00 00       	and    $0xe07,%eax
  801157:	50                   	push   %eax
  801158:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115b:	6a 00                	push   $0x0
  80115d:	53                   	push   %ebx
  80115e:	6a 00                	push   $0x0
  801160:	e8 27 fc ff ff       	call   800d8c <sys_page_map>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 2d                	js     80119b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80116e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 0c             	shr    $0xc,%edx
  801176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801186:	52                   	push   %edx
  801187:	56                   	push   %esi
  801188:	6a 00                	push   $0x0
  80118a:	50                   	push   %eax
  80118b:	6a 00                	push   $0x0
  80118d:	e8 fa fb ff ff       	call   800d8c <sys_page_map>
  801192:	89 c3                	mov    %eax,%ebx
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	79 1d                	jns    8011b8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	56                   	push   %esi
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 0c fc ff ff       	call   800db2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011a6:	83 c4 08             	add    $0x8,%esp
  8011a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 ff fb ff ff       	call   800db2 <sys_page_unmap>
	return r;
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	eb 02                	jmp    8011ba <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011b8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ba:	89 d8                	mov    %ebx,%eax
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 14             	sub    $0x14,%esp
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	53                   	push   %ebx
  8011d3:	e8 6b fd ff ff       	call   800f43 <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 67                	js     801246 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	ff 30                	pushl  (%eax)
  8011eb:	e8 a9 fd ff ff       	call   800f99 <dev_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 4f                	js     801246 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	8b 50 08             	mov    0x8(%eax),%edx
  8011fd:	83 e2 03             	and    $0x3,%edx
  801200:	83 fa 01             	cmp    $0x1,%edx
  801203:	75 21                	jne    801226 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801205:	a1 04 40 80 00       	mov    0x804004,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	53                   	push   %ebx
  801211:	50                   	push   %eax
  801212:	68 90 23 80 00       	push   $0x802390
  801217:	e8 14 f1 ff ff       	call   800330 <cprintf>
		return -E_INVAL;
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801224:	eb 20                	jmp    801246 <read+0x82>
	}
	if (!dev->dev_read)
  801226:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801229:	8b 52 08             	mov    0x8(%edx),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 11                	je     801241 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	ff 75 10             	pushl  0x10(%ebp)
  801236:	ff 75 0c             	pushl  0xc(%ebp)
  801239:	50                   	push   %eax
  80123a:	ff d2                	call   *%edx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	eb 05                	jmp    801246 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801241:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	8b 7d 08             	mov    0x8(%ebp),%edi
  801257:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125a:	85 f6                	test   %esi,%esi
  80125c:	74 31                	je     80128f <readn+0x44>
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	89 f2                	mov    %esi,%edx
  80126d:	29 c2                	sub    %eax,%edx
  80126f:	52                   	push   %edx
  801270:	03 45 0c             	add    0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	57                   	push   %edi
  801275:	e8 4a ff ff ff       	call   8011c4 <read>
		if (m < 0)
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 17                	js     801298 <readn+0x4d>
			return m;
		if (m == 0)
  801281:	85 c0                	test   %eax,%eax
  801283:	74 11                	je     801296 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801285:	01 c3                	add    %eax,%ebx
  801287:	89 d8                	mov    %ebx,%eax
  801289:	39 f3                	cmp    %esi,%ebx
  80128b:	72 db                	jb     801268 <readn+0x1d>
  80128d:	eb 09                	jmp    801298 <readn+0x4d>
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
  801294:	eb 02                	jmp    801298 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801296:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5f                   	pop    %edi
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 14             	sub    $0x14,%esp
  8012a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	53                   	push   %ebx
  8012af:	e8 8f fc ff ff       	call   800f43 <fd_lookup>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 62                	js     80131d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	ff 30                	pushl  (%eax)
  8012c7:	e8 cd fc ff ff       	call   800f99 <dev_lookup>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 4a                	js     80131d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012da:	75 21                	jne    8012fd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e1:	8b 40 48             	mov    0x48(%eax),%eax
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	53                   	push   %ebx
  8012e8:	50                   	push   %eax
  8012e9:	68 ac 23 80 00       	push   $0x8023ac
  8012ee:	e8 3d f0 ff ff       	call   800330 <cprintf>
		return -E_INVAL;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fb:	eb 20                	jmp    80131d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801300:	8b 52 0c             	mov    0xc(%edx),%edx
  801303:	85 d2                	test   %edx,%edx
  801305:	74 11                	je     801318 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	ff 75 10             	pushl  0x10(%ebp)
  80130d:	ff 75 0c             	pushl  0xc(%ebp)
  801310:	50                   	push   %eax
  801311:	ff d2                	call   *%edx
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	eb 05                	jmp    80131d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801318:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <seek>:

int
seek(int fdnum, off_t offset)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801328:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 0f fc ff ff       	call   800f43 <fd_lookup>
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 0e                	js     801349 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80133b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80133e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801341:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801344:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 14             	sub    $0x14,%esp
  801352:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	e8 e4 fb ff ff       	call   800f43 <fd_lookup>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 5f                	js     8013c5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	ff 30                	pushl  (%eax)
  801372:	e8 22 fc ff ff       	call   800f99 <dev_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 47                	js     8013c5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801385:	75 21                	jne    8013a8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801387:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	53                   	push   %ebx
  801393:	50                   	push   %eax
  801394:	68 6c 23 80 00       	push   $0x80236c
  801399:	e8 92 ef ff ff       	call   800330 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a6:	eb 1d                	jmp    8013c5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ab:	8b 52 18             	mov    0x18(%edx),%edx
  8013ae:	85 d2                	test   %edx,%edx
  8013b0:	74 0e                	je     8013c0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	ff 75 0c             	pushl  0xc(%ebp)
  8013b8:	50                   	push   %eax
  8013b9:	ff d2                	call   *%edx
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	eb 05                	jmp    8013c5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 14             	sub    $0x14,%esp
  8013d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d7:	50                   	push   %eax
  8013d8:	ff 75 08             	pushl  0x8(%ebp)
  8013db:	e8 63 fb ff ff       	call   800f43 <fd_lookup>
  8013e0:	83 c4 08             	add    $0x8,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 52                	js     801439 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	ff 30                	pushl  (%eax)
  8013f3:	e8 a1 fb ff ff       	call   800f99 <dev_lookup>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 3a                	js     801439 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801402:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801406:	74 2c                	je     801434 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801408:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801412:	00 00 00 
	stat->st_isdir = 0;
  801415:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141c:	00 00 00 
	stat->st_dev = dev;
  80141f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	53                   	push   %ebx
  801429:	ff 75 f0             	pushl  -0x10(%ebp)
  80142c:	ff 50 14             	call   *0x14(%eax)
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	eb 05                	jmp    801439 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801434:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	6a 00                	push   $0x0
  801448:	ff 75 08             	pushl  0x8(%ebp)
  80144b:	e8 8b 01 00 00       	call   8015db <open>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 1b                	js     801474 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	ff 75 0c             	pushl  0xc(%ebp)
  80145f:	50                   	push   %eax
  801460:	e8 65 ff ff ff       	call   8013ca <fstat>
  801465:	89 c6                	mov    %eax,%esi
	close(fd);
  801467:	89 1c 24             	mov    %ebx,(%esp)
  80146a:	e8 18 fc ff ff       	call   801087 <close>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 f3                	mov    %esi,%ebx
}
  801474:	89 d8                	mov    %ebx,%eax
  801476:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801479:	5b                   	pop    %ebx
  80147a:	5e                   	pop    %esi
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    
  80147d:	00 00                	add    %al,(%eax)
	...

00801480 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	89 c3                	mov    %eax,%ebx
  801487:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801489:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801490:	75 12                	jne    8014a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	6a 01                	push   $0x1
  801497:	e8 dd 07 00 00       	call   801c79 <ipc_find_env>
  80149c:	a3 00 40 80 00       	mov    %eax,0x804000
  8014a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a4:	6a 07                	push   $0x7
  8014a6:	68 00 50 80 00       	push   $0x805000
  8014ab:	53                   	push   %ebx
  8014ac:	ff 35 00 40 80 00    	pushl  0x804000
  8014b2:	e8 6d 07 00 00       	call   801c24 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014b7:	83 c4 0c             	add    $0xc,%esp
  8014ba:	6a 00                	push   $0x0
  8014bc:	56                   	push   %esi
  8014bd:	6a 00                	push   $0x0
  8014bf:	e8 b8 06 00 00       	call   801b7c <ipc_recv>
}
  8014c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c7:	5b                   	pop    %ebx
  8014c8:	5e                   	pop    %esi
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ea:	e8 91 ff ff ff       	call   801480 <fsipc>
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 39                	js     80152c <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	68 dc 23 80 00       	push   $0x8023dc
  8014fb:	e8 30 ee ff ff       	call   800330 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	68 00 50 80 00       	push   $0x805000
  801508:	53                   	push   %ebx
  801509:	e8 d8 f3 ff ff       	call   8008e6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150e:	a1 80 50 80 00       	mov    0x805080,%eax
  801513:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801519:	a1 84 50 80 00       	mov    0x805084,%eax
  80151e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801537:	8b 45 08             	mov    0x8(%ebp),%eax
  80153a:	8b 40 0c             	mov    0xc(%eax),%eax
  80153d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 06 00 00 00       	mov    $0x6,%eax
  80154c:	e8 2f ff ff ff       	call   801480 <fsipc>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	56                   	push   %esi
  801557:	53                   	push   %ebx
  801558:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	8b 40 0c             	mov    0xc(%eax),%eax
  801561:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801566:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80156c:	ba 00 00 00 00       	mov    $0x0,%edx
  801571:	b8 03 00 00 00       	mov    $0x3,%eax
  801576:	e8 05 ff ff ff       	call   801480 <fsipc>
  80157b:	89 c3                	mov    %eax,%ebx
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 51                	js     8015d2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801581:	39 c6                	cmp    %eax,%esi
  801583:	73 19                	jae    80159e <devfile_read+0x4b>
  801585:	68 e2 23 80 00       	push   $0x8023e2
  80158a:	68 e9 23 80 00       	push   $0x8023e9
  80158f:	68 80 00 00 00       	push   $0x80
  801594:	68 fe 23 80 00       	push   $0x8023fe
  801599:	e8 ba ec ff ff       	call   800258 <_panic>
	assert(r <= PGSIZE);
  80159e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a3:	7e 19                	jle    8015be <devfile_read+0x6b>
  8015a5:	68 09 24 80 00       	push   $0x802409
  8015aa:	68 e9 23 80 00       	push   $0x8023e9
  8015af:	68 81 00 00 00       	push   $0x81
  8015b4:	68 fe 23 80 00       	push   $0x8023fe
  8015b9:	e8 9a ec ff ff       	call   800258 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	50                   	push   %eax
  8015c2:	68 00 50 80 00       	push   $0x805000
  8015c7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ca:	e8 d8 f4 ff ff       	call   800aa7 <memmove>
	return r;
  8015cf:	83 c4 10             	add    $0x10,%esp
}
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 1c             	sub    $0x1c,%esp
  8015e3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e6:	56                   	push   %esi
  8015e7:	e8 a8 f2 ff ff       	call   800894 <strlen>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f4:	7f 72                	jg     801668 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f6:	83 ec 0c             	sub    $0xc,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	e8 ce f8 ff ff       	call   800ed0 <fd_alloc>
  801602:	89 c3                	mov    %eax,%ebx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 62                	js     80166d <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	56                   	push   %esi
  80160f:	68 00 50 80 00       	push   $0x805000
  801614:	e8 cd f2 ff ff       	call   8008e6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801619:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161c:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801621:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801624:	b8 01 00 00 00       	mov    $0x1,%eax
  801629:	e8 52 fe ff ff       	call   801480 <fsipc>
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	79 12                	jns    801649 <open+0x6e>
		fd_close(fd, 0);
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	6a 00                	push   $0x0
  80163c:	ff 75 f4             	pushl  -0xc(%ebp)
  80163f:	e8 bb f9 ff ff       	call   800fff <fd_close>
		return r;
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	eb 24                	jmp    80166d <open+0x92>
	}


	cprintf("OPEN\n");
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	68 15 24 80 00       	push   $0x802415
  801651:	e8 da ec ff ff       	call   800330 <cprintf>

	return fd2num(fd);
  801656:	83 c4 04             	add    $0x4,%esp
  801659:	ff 75 f4             	pushl  -0xc(%ebp)
  80165c:	e8 47 f8 ff ff       	call   800ea8 <fd2num>
  801661:	89 c3                	mov    %eax,%ebx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	eb 05                	jmp    80166d <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801668:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	c9                   	leave  
  801675:	c3                   	ret    
	...

00801678 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	e8 2d f8 ff ff       	call   800eb8 <fd2data>
  80168b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	68 1b 24 80 00       	push   $0x80241b
  801695:	56                   	push   %esi
  801696:	e8 4b f2 ff ff       	call   8008e6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80169b:	8b 43 04             	mov    0x4(%ebx),%eax
  80169e:	2b 03                	sub    (%ebx),%eax
  8016a0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016a6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8016ad:	00 00 00 
	stat->st_dev = &devpipe;
  8016b0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016b7:	30 80 00 
	return 0;
}
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5e                   	pop    %esi
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d0:	53                   	push   %ebx
  8016d1:	6a 00                	push   $0x0
  8016d3:	e8 da f6 ff ff       	call   800db2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d8:	89 1c 24             	mov    %ebx,(%esp)
  8016db:	e8 d8 f7 ff ff       	call   800eb8 <fd2data>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	50                   	push   %eax
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 c7 f6 ff ff       	call   800db2 <sys_page_unmap>
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 1c             	sub    $0x1c,%esp
  8016f9:	89 c7                	mov    %eax,%edi
  8016fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801703:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801706:	83 ec 0c             	sub    $0xc,%esp
  801709:	57                   	push   %edi
  80170a:	e8 c5 05 00 00       	call   801cd4 <pageref>
  80170f:	89 c6                	mov    %eax,%esi
  801711:	83 c4 04             	add    $0x4,%esp
  801714:	ff 75 e4             	pushl  -0x1c(%ebp)
  801717:	e8 b8 05 00 00       	call   801cd4 <pageref>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	39 c6                	cmp    %eax,%esi
  801721:	0f 94 c0             	sete   %al
  801724:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801727:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80172d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801730:	39 cb                	cmp    %ecx,%ebx
  801732:	75 08                	jne    80173c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5f                   	pop    %edi
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80173c:	83 f8 01             	cmp    $0x1,%eax
  80173f:	75 bd                	jne    8016fe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801741:	8b 42 58             	mov    0x58(%edx),%eax
  801744:	6a 01                	push   $0x1
  801746:	50                   	push   %eax
  801747:	53                   	push   %ebx
  801748:	68 22 24 80 00       	push   $0x802422
  80174d:	e8 de eb ff ff       	call   800330 <cprintf>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb a7                	jmp    8016fe <_pipeisclosed+0xe>

00801757 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	57                   	push   %edi
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	83 ec 28             	sub    $0x28,%esp
  801760:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801763:	56                   	push   %esi
  801764:	e8 4f f7 ff ff       	call   800eb8 <fd2data>
  801769:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801772:	75 4a                	jne    8017be <devpipe_write+0x67>
  801774:	bf 00 00 00 00       	mov    $0x0,%edi
  801779:	eb 56                	jmp    8017d1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80177b:	89 da                	mov    %ebx,%edx
  80177d:	89 f0                	mov    %esi,%eax
  80177f:	e8 6c ff ff ff       	call   8016f0 <_pipeisclosed>
  801784:	85 c0                	test   %eax,%eax
  801786:	75 4d                	jne    8017d5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801788:	e8 b4 f5 ff ff       	call   800d41 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80178d:	8b 43 04             	mov    0x4(%ebx),%eax
  801790:	8b 13                	mov    (%ebx),%edx
  801792:	83 c2 20             	add    $0x20,%edx
  801795:	39 d0                	cmp    %edx,%eax
  801797:	73 e2                	jae    80177b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801799:	89 c2                	mov    %eax,%edx
  80179b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017a1:	79 05                	jns    8017a8 <devpipe_write+0x51>
  8017a3:	4a                   	dec    %edx
  8017a4:	83 ca e0             	or     $0xffffffe0,%edx
  8017a7:	42                   	inc    %edx
  8017a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ab:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8017ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b2:	40                   	inc    %eax
  8017b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b6:	47                   	inc    %edi
  8017b7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8017ba:	77 07                	ja     8017c3 <devpipe_write+0x6c>
  8017bc:	eb 13                	jmp    8017d1 <devpipe_write+0x7a>
  8017be:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c6:	8b 13                	mov    (%ebx),%edx
  8017c8:	83 c2 20             	add    $0x20,%edx
  8017cb:	39 d0                	cmp    %edx,%eax
  8017cd:	73 ac                	jae    80177b <devpipe_write+0x24>
  8017cf:	eb c8                	jmp    801799 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017d1:	89 f8                	mov    %edi,%eax
  8017d3:	eb 05                	jmp    8017da <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017d5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5f                   	pop    %edi
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	57                   	push   %edi
  8017e6:	56                   	push   %esi
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 18             	sub    $0x18,%esp
  8017eb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ee:	57                   	push   %edi
  8017ef:	e8 c4 f6 ff ff       	call   800eb8 <fd2data>
  8017f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017fd:	75 44                	jne    801843 <devpipe_read+0x61>
  8017ff:	be 00 00 00 00       	mov    $0x0,%esi
  801804:	eb 4f                	jmp    801855 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801806:	89 f0                	mov    %esi,%eax
  801808:	eb 54                	jmp    80185e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80180a:	89 da                	mov    %ebx,%edx
  80180c:	89 f8                	mov    %edi,%eax
  80180e:	e8 dd fe ff ff       	call   8016f0 <_pipeisclosed>
  801813:	85 c0                	test   %eax,%eax
  801815:	75 42                	jne    801859 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801817:	e8 25 f5 ff ff       	call   800d41 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80181c:	8b 03                	mov    (%ebx),%eax
  80181e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801821:	74 e7                	je     80180a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801823:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801828:	79 05                	jns    80182f <devpipe_read+0x4d>
  80182a:	48                   	dec    %eax
  80182b:	83 c8 e0             	or     $0xffffffe0,%eax
  80182e:	40                   	inc    %eax
  80182f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801833:	8b 55 0c             	mov    0xc(%ebp),%edx
  801836:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801839:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183b:	46                   	inc    %esi
  80183c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80183f:	77 07                	ja     801848 <devpipe_read+0x66>
  801841:	eb 12                	jmp    801855 <devpipe_read+0x73>
  801843:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801848:	8b 03                	mov    (%ebx),%eax
  80184a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80184d:	75 d4                	jne    801823 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80184f:	85 f6                	test   %esi,%esi
  801851:	75 b3                	jne    801806 <devpipe_read+0x24>
  801853:	eb b5                	jmp    80180a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801855:	89 f0                	mov    %esi,%eax
  801857:	eb 05                	jmp    80185e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801859:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80185e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801861:	5b                   	pop    %ebx
  801862:	5e                   	pop    %esi
  801863:	5f                   	pop    %edi
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	57                   	push   %edi
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	83 ec 28             	sub    $0x28,%esp
  80186f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801872:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	e8 55 f6 ff ff       	call   800ed0 <fd_alloc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 24 01 00 00    	js     8019ac <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	68 07 04 00 00       	push   $0x407
  801890:	ff 75 e4             	pushl  -0x1c(%ebp)
  801893:	6a 00                	push   $0x0
  801895:	e8 ce f4 ff ff       	call   800d68 <sys_page_alloc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	0f 88 05 01 00 00    	js     8019ac <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018ad:	50                   	push   %eax
  8018ae:	e8 1d f6 ff ff       	call   800ed0 <fd_alloc>
  8018b3:	89 c3                	mov    %eax,%ebx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	0f 88 dc 00 00 00    	js     80199c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	68 07 04 00 00       	push   $0x407
  8018c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018cb:	6a 00                	push   $0x0
  8018cd:	e8 96 f4 ff ff       	call   800d68 <sys_page_alloc>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	0f 88 bd 00 00 00    	js     80199c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018e5:	e8 ce f5 ff ff       	call   800eb8 <fd2data>
  8018ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ec:	83 c4 0c             	add    $0xc,%esp
  8018ef:	68 07 04 00 00       	push   $0x407
  8018f4:	50                   	push   %eax
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 6c f4 ff ff       	call   800d68 <sys_page_alloc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	0f 88 83 00 00 00    	js     80198c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801909:	83 ec 0c             	sub    $0xc,%esp
  80190c:	ff 75 e0             	pushl  -0x20(%ebp)
  80190f:	e8 a4 f5 ff ff       	call   800eb8 <fd2data>
  801914:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80191b:	50                   	push   %eax
  80191c:	6a 00                	push   $0x0
  80191e:	56                   	push   %esi
  80191f:	6a 00                	push   $0x0
  801921:	e8 66 f4 ff ff       	call   800d8c <sys_page_map>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	83 c4 20             	add    $0x20,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 4f                	js     80197e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80192f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801938:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801944:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80194d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80194f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801952:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80195f:	e8 44 f5 ff ff       	call   800ea8 <fd2num>
  801964:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801966:	83 c4 04             	add    $0x4,%esp
  801969:	ff 75 e0             	pushl  -0x20(%ebp)
  80196c:	e8 37 f5 ff ff       	call   800ea8 <fd2num>
  801971:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197c:	eb 2e                	jmp    8019ac <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	56                   	push   %esi
  801982:	6a 00                	push   $0x0
  801984:	e8 29 f4 ff ff       	call   800db2 <sys_page_unmap>
  801989:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	ff 75 e0             	pushl  -0x20(%ebp)
  801992:	6a 00                	push   $0x0
  801994:	e8 19 f4 ff ff       	call   800db2 <sys_page_unmap>
  801999:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a2:	6a 00                	push   $0x0
  8019a4:	e8 09 f4 ff ff       	call   800db2 <sys_page_unmap>
  8019a9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8019ac:	89 d8                	mov    %ebx,%eax
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	ff 75 08             	pushl  0x8(%ebp)
  8019c3:	e8 7b f5 ff ff       	call   800f43 <fd_lookup>
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 18                	js     8019e7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019cf:	83 ec 0c             	sub    $0xc,%esp
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	e8 de f4 ff ff       	call   800eb8 <fd2data>
	return _pipeisclosed(fd, p);
  8019da:	89 c2                	mov    %eax,%edx
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	e8 0c fd ff ff       	call   8016f0 <_pipeisclosed>
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    
  8019e9:	00 00                	add    %al,(%eax)
	...

008019ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019fc:	68 3a 24 80 00       	push   $0x80243a
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	e8 dd ee ff ff       	call   8008e6 <strcpy>
	return 0;
}
  801a09:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a20:	74 45                	je     801a67 <devcons_write+0x57>
  801a22:	b8 00 00 00 00       	mov    $0x0,%eax
  801a27:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a2c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a35:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a37:	83 fb 7f             	cmp    $0x7f,%ebx
  801a3a:	76 05                	jbe    801a41 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a3c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	53                   	push   %ebx
  801a45:	03 45 0c             	add    0xc(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	57                   	push   %edi
  801a4a:	e8 58 f0 ff ff       	call   800aa7 <memmove>
		sys_cputs(buf, m);
  801a4f:	83 c4 08             	add    $0x8,%esp
  801a52:	53                   	push   %ebx
  801a53:	57                   	push   %edi
  801a54:	e8 58 f2 ff ff       	call   800cb1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a59:	01 de                	add    %ebx,%esi
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a63:	72 cd                	jb     801a32 <devcons_write+0x22>
  801a65:	eb 05                	jmp    801a6c <devcons_write+0x5c>
  801a67:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a6c:	89 f0                	mov    %esi,%eax
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a80:	75 07                	jne    801a89 <devcons_read+0x13>
  801a82:	eb 25                	jmp    801aa9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a84:	e8 b8 f2 ff ff       	call   800d41 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a89:	e8 49 f2 ff ff       	call   800cd7 <sys_cgetc>
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	74 f2                	je     801a84 <devcons_read+0xe>
  801a92:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 1d                	js     801ab5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a98:	83 f8 04             	cmp    $0x4,%eax
  801a9b:	74 13                	je     801ab0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa0:	88 10                	mov    %dl,(%eax)
	return 1;
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	eb 0c                	jmp    801ab5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aae:	eb 05                	jmp    801ab5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ac3:	6a 01                	push   $0x1
  801ac5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ac8:	50                   	push   %eax
  801ac9:	e8 e3 f1 ff ff       	call   800cb1 <sys_cputs>
  801ace:	83 c4 10             	add    $0x10,%esp
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <getchar>:

int
getchar(void)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ad9:	6a 01                	push   $0x1
  801adb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 de f6 ff ff       	call   8011c4 <read>
	if (r < 0)
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 0f                	js     801afc <getchar+0x29>
		return r;
	if (r < 1)
  801aed:	85 c0                	test   %eax,%eax
  801aef:	7e 06                	jle    801af7 <getchar+0x24>
		return -E_EOF;
	return c;
  801af1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801af5:	eb 05                	jmp    801afc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801af7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b07:	50                   	push   %eax
  801b08:	ff 75 08             	pushl  0x8(%ebp)
  801b0b:	e8 33 f4 ff ff       	call   800f43 <fd_lookup>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 11                	js     801b28 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b20:	39 10                	cmp    %edx,(%eax)
  801b22:	0f 94 c0             	sete   %al
  801b25:	0f b6 c0             	movzbl %al,%eax
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <opencons>:

int
opencons(void)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b33:	50                   	push   %eax
  801b34:	e8 97 f3 ff ff       	call   800ed0 <fd_alloc>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 3a                	js     801b7a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	68 07 04 00 00       	push   $0x407
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 16 f2 ff ff       	call   800d68 <sys_page_alloc>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 21                	js     801b7a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b59:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b62:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b67:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	50                   	push   %eax
  801b72:	e8 31 f3 ff ff       	call   800ea8 <fd2num>
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b8b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	57                   	push   %edi
  801b91:	68 46 24 80 00       	push   $0x802446
  801b96:	e8 95 e7 ff ff       	call   800330 <cprintf>
	int r;
	if (pg != NULL) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 db                	test   %ebx,%ebx
  801ba0:	74 28                	je     801bca <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	68 56 24 80 00       	push   $0x802456
  801baa:	e8 81 e7 ff ff       	call   800330 <cprintf>
		r = sys_ipc_recv(pg);
  801baf:	89 1c 24             	mov    %ebx,(%esp)
  801bb2:	e8 ac f2 ff ff       	call   800e63 <sys_ipc_recv>
  801bb7:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801bb9:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  801bc0:	e8 6b e7 ff ff       	call   800330 <cprintf>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	eb 12                	jmp    801bdc <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	68 00 00 c0 ee       	push   $0xeec00000
  801bd2:	e8 8c f2 ff ff       	call   800e63 <sys_ipc_recv>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801bdc:	85 db                	test   %ebx,%ebx
  801bde:	75 26                	jne    801c06 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801be0:	85 ff                	test   %edi,%edi
  801be2:	74 0a                	je     801bee <ipc_recv+0x72>
  801be4:	a1 04 40 80 00       	mov    0x804004,%eax
  801be9:	8b 40 74             	mov    0x74(%eax),%eax
  801bec:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801bee:	85 f6                	test   %esi,%esi
  801bf0:	74 0a                	je     801bfc <ipc_recv+0x80>
  801bf2:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf7:	8b 40 78             	mov    0x78(%eax),%eax
  801bfa:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801bfc:	a1 04 40 80 00       	mov    0x804004,%eax
  801c01:	8b 58 70             	mov    0x70(%eax),%ebx
  801c04:	eb 14                	jmp    801c1a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c06:	85 ff                	test   %edi,%edi
  801c08:	74 06                	je     801c10 <ipc_recv+0x94>
  801c0a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801c10:	85 f6                	test   %esi,%esi
  801c12:	74 06                	je     801c1a <ipc_recv+0x9e>
  801c14:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	57                   	push   %edi
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c33:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801c36:	85 db                	test   %ebx,%ebx
  801c38:	75 25                	jne    801c5f <ipc_send+0x3b>
  801c3a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801c3f:	eb 1e                	jmp    801c5f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801c41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c44:	75 07                	jne    801c4d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801c46:	e8 f6 f0 ff ff       	call   800d41 <sys_yield>
  801c4b:	eb 12                	jmp    801c5f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801c4d:	50                   	push   %eax
  801c4e:	68 5d 24 80 00       	push   $0x80245d
  801c53:	6a 45                	push   $0x45
  801c55:	68 70 24 80 00       	push   $0x802470
  801c5a:	e8 f9 e5 ff ff       	call   800258 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	57                   	push   %edi
  801c62:	ff 75 08             	pushl  0x8(%ebp)
  801c65:	e8 d4 f1 ff ff       	call   800e3e <sys_ipc_try_send>
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	75 d0                	jne    801c41 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	53                   	push   %ebx
  801c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c80:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801c86:	74 22                	je     801caa <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c88:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801c8d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c94:	89 c2                	mov    %eax,%edx
  801c96:	c1 e2 07             	shl    $0x7,%edx
  801c99:	29 ca                	sub    %ecx,%edx
  801c9b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ca1:	8b 52 50             	mov    0x50(%edx),%edx
  801ca4:	39 da                	cmp    %ebx,%edx
  801ca6:	75 1d                	jne    801cc5 <ipc_find_env+0x4c>
  801ca8:	eb 05                	jmp    801caf <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801caf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801cb6:	c1 e0 07             	shl    $0x7,%eax
  801cb9:	29 d0                	sub    %edx,%eax
  801cbb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cc0:	8b 40 40             	mov    0x40(%eax),%eax
  801cc3:	eb 0c                	jmp    801cd1 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc5:	40                   	inc    %eax
  801cc6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ccb:	75 c0                	jne    801c8d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ccd:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd1:	5b                   	pop    %ebx
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	c1 ea 16             	shr    $0x16,%edx
  801cdf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ce6:	f6 c2 01             	test   $0x1,%dl
  801ce9:	74 1e                	je     801d09 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ceb:	c1 e8 0c             	shr    $0xc,%eax
  801cee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cf5:	a8 01                	test   $0x1,%al
  801cf7:	74 17                	je     801d10 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cf9:	c1 e8 0c             	shr    $0xc,%eax
  801cfc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d03:	ef 
  801d04:	0f b7 c0             	movzwl %ax,%eax
  801d07:	eb 0c                	jmp    801d15 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d09:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0e:	eb 05                	jmp    801d15 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    
	...

00801d18 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d23:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d26:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801d29:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d2c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d2f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d32:	85 c0                	test   %eax,%eax
  801d34:	75 2e                	jne    801d64 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d36:	39 f1                	cmp    %esi,%ecx
  801d38:	77 5a                	ja     801d94 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d3a:	85 c9                	test   %ecx,%ecx
  801d3c:	75 0b                	jne    801d49 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f1                	div    %ecx
  801d47:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d49:	31 d2                	xor    %edx,%edx
  801d4b:	89 f0                	mov    %esi,%eax
  801d4d:	f7 f1                	div    %ecx
  801d4f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d51:	89 f8                	mov    %edi,%eax
  801d53:	f7 f1                	div    %ecx
  801d55:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d57:	89 f8                	mov    %edi,%eax
  801d59:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    
  801d62:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d64:	39 f0                	cmp    %esi,%eax
  801d66:	77 1c                	ja     801d84 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d68:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801d6b:	83 f7 1f             	xor    $0x1f,%edi
  801d6e:	75 3c                	jne    801dac <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d70:	39 f0                	cmp    %esi,%eax
  801d72:	0f 82 90 00 00 00    	jb     801e08 <__udivdi3+0xf0>
  801d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d7b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801d7e:	0f 86 84 00 00 00    	jbe    801e08 <__udivdi3+0xf0>
  801d84:	31 f6                	xor    %esi,%esi
  801d86:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d88:	89 f8                	mov    %edi,%eax
  801d8a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    
  801d93:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d94:	89 f2                	mov    %esi,%edx
  801d96:	89 f8                	mov    %edi,%eax
  801d98:	f7 f1                	div    %ecx
  801d9a:	89 c7                	mov    %eax,%edi
  801d9c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d9e:	89 f8                	mov    %edi,%eax
  801da0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    
  801da9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dac:	89 f9                	mov    %edi,%ecx
  801dae:	d3 e0                	shl    %cl,%eax
  801db0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801db3:	b8 20 00 00 00       	mov    $0x20,%eax
  801db8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dbd:	88 c1                	mov    %al,%cl
  801dbf:	d3 ea                	shr    %cl,%edx
  801dc1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801dc4:	09 ca                	or     %ecx,%edx
  801dc6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801dc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dcc:	89 f9                	mov    %edi,%ecx
  801dce:	d3 e2                	shl    %cl,%edx
  801dd0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801dd3:	89 f2                	mov    %esi,%edx
  801dd5:	88 c1                	mov    %al,%cl
  801dd7:	d3 ea                	shr    %cl,%edx
  801dd9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801ddc:	89 f2                	mov    %esi,%edx
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	d3 e2                	shl    %cl,%edx
  801de2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801de5:	88 c1                	mov    %al,%cl
  801de7:	d3 ee                	shr    %cl,%esi
  801de9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801deb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	89 ca                	mov    %ecx,%edx
  801df2:	f7 75 ec             	divl   -0x14(%ebp)
  801df5:	89 d1                	mov    %edx,%ecx
  801df7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801df9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dfc:	39 d1                	cmp    %edx,%ecx
  801dfe:	72 28                	jb     801e28 <__udivdi3+0x110>
  801e00:	74 1a                	je     801e1c <__udivdi3+0x104>
  801e02:	89 f7                	mov    %esi,%edi
  801e04:	31 f6                	xor    %esi,%esi
  801e06:	eb 80                	jmp    801d88 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e08:	31 f6                	xor    %esi,%esi
  801e0a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e0f:	89 f8                	mov    %edi,%eax
  801e11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    
  801e1a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e1f:	89 f9                	mov    %edi,%ecx
  801e21:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e23:	39 c2                	cmp    %eax,%edx
  801e25:	73 db                	jae    801e02 <__udivdi3+0xea>
  801e27:	90                   	nop
		{
		  q0--;
  801e28:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e2b:	31 f6                	xor    %esi,%esi
  801e2d:	e9 56 ff ff ff       	jmp    801d88 <__udivdi3+0x70>
	...

00801e34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	57                   	push   %edi
  801e38:	56                   	push   %esi
  801e39:	83 ec 20             	sub    $0x20,%esp
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801e45:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801e51:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e53:	85 ff                	test   %edi,%edi
  801e55:	75 15                	jne    801e6c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801e57:	39 f1                	cmp    %esi,%ecx
  801e59:	0f 86 99 00 00 00    	jbe    801ef8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e5f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e61:	89 d0                	mov    %edx,%eax
  801e63:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e65:	83 c4 20             	add    $0x20,%esp
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e6c:	39 f7                	cmp    %esi,%edi
  801e6e:	0f 87 a4 00 00 00    	ja     801f18 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e74:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801e77:	83 f0 1f             	xor    $0x1f,%eax
  801e7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e7d:	0f 84 a1 00 00 00    	je     801f24 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e83:	89 f8                	mov    %edi,%eax
  801e85:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e88:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e8a:	bf 20 00 00 00       	mov    $0x20,%edi
  801e8f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	d3 ea                	shr    %cl,%edx
  801e99:	09 c2                	or     %eax,%edx
  801e9b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ea4:	d3 e0                	shl    %cl,%eax
  801ea6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ea9:	89 f2                	mov    %esi,%edx
  801eab:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ead:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801eb0:	d3 e0                	shl    %cl,%eax
  801eb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801eb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801eb8:	89 f9                	mov    %edi,%ecx
  801eba:	d3 e8                	shr    %cl,%eax
  801ebc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ebe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ec0:	89 f2                	mov    %esi,%edx
  801ec2:	f7 75 f0             	divl   -0x10(%ebp)
  801ec5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ec7:	f7 65 f4             	mull   -0xc(%ebp)
  801eca:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801ecd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ecf:	39 d6                	cmp    %edx,%esi
  801ed1:	72 71                	jb     801f44 <__umoddi3+0x110>
  801ed3:	74 7f                	je     801f54 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed8:	29 c8                	sub    %ecx,%eax
  801eda:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801edc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801edf:	d3 e8                	shr    %cl,%eax
  801ee1:	89 f2                	mov    %esi,%edx
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801ee7:	09 d0                	or     %edx,%eax
  801ee9:	89 f2                	mov    %esi,%edx
  801eeb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801eee:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ef0:	83 c4 20             	add    $0x20,%esp
  801ef3:	5e                   	pop    %esi
  801ef4:	5f                   	pop    %edi
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    
  801ef7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ef8:	85 c9                	test   %ecx,%ecx
  801efa:	75 0b                	jne    801f07 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	31 d2                	xor    %edx,%edx
  801f03:	f7 f1                	div    %ecx
  801f05:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f07:	89 f0                	mov    %esi,%eax
  801f09:	31 d2                	xor    %edx,%edx
  801f0b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f10:	f7 f1                	div    %ecx
  801f12:	e9 4a ff ff ff       	jmp    801e61 <__umoddi3+0x2d>
  801f17:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f18:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f1a:	83 c4 20             	add    $0x20,%esp
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    
  801f21:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f24:	39 f7                	cmp    %esi,%edi
  801f26:	72 05                	jb     801f2d <__umoddi3+0xf9>
  801f28:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801f2b:	77 0c                	ja     801f39 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f2d:	89 f2                	mov    %esi,%edx
  801f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f32:	29 c8                	sub    %ecx,%eax
  801f34:	19 fa                	sbb    %edi,%edx
  801f36:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f3c:	83 c4 20             	add    $0x20,%esp
  801f3f:	5e                   	pop    %esi
  801f40:	5f                   	pop    %edi
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    
  801f43:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f44:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f47:	89 c1                	mov    %eax,%ecx
  801f49:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801f4c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801f4f:	eb 84                	jmp    801ed5 <__umoddi3+0xa1>
  801f51:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f57:	72 eb                	jb     801f44 <__umoddi3+0x110>
  801f59:	89 f2                	mov    %esi,%edx
  801f5b:	e9 75 ff ff ff       	jmp    801ed5 <__umoddi3+0xa1>
