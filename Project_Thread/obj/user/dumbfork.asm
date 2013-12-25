
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
  80002c:	e8 b7 01 00 00       	call   8001e8 <libmain>
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
  800053:	68 80 1f 80 00       	push   $0x801f80
  800058:	6a 20                	push   $0x20
  80005a:	68 93 1f 80 00       	push   $0x801f93
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
  80007f:	68 a3 1f 80 00       	push   $0x801fa3
  800084:	6a 22                	push   $0x22
  800086:	68 93 1f 80 00       	push   $0x801f93
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
  8000ba:	68 b4 1f 80 00       	push   $0x801fb4
  8000bf:	6a 25                	push   $0x25
  8000c1:	68 93 1f 80 00       	push   $0x801f93
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
  8000ec:	68 c7 1f 80 00       	push   $0x801fc7
  8000f1:	6a 37                	push   $0x37
  8000f3:	68 93 1f 80 00       	push   $0x801f93
  8000f8:	e8 53 01 00 00       	call   800250 <_panic>
	if (envid == 0) {
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	75 1d                	jne    80011e <dumbfork+0x4c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 0f 0c 00 00       	call   800d15 <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	89 c2                	mov    %eax,%edx
  80010d:	c1 e2 07             	shl    $0x7,%edx
  800110:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800117:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80011c:	eb 6d                	jmp    80018b <dumbfork+0xb9>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011e:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800125:	b8 00 60 80 00       	mov    $0x806000,%eax
  80012a:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80012f:	76 24                	jbe    800155 <dumbfork+0x83>
  800131:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	50                   	push   %eax
  80013a:	53                   	push   %ebx
  80013b:	e8 f4 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800140:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800143:	05 00 10 00 00       	add    $0x1000,%eax
  800148:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	3d 00 60 80 00       	cmp    $0x806000,%eax
  800153:	72 e1                	jb     800136 <dumbfork+0x64>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80015b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800160:	50                   	push   %eax
  800161:	56                   	push   %esi
  800162:	e8 cd fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800167:	83 c4 08             	add    $0x8,%esp
  80016a:	6a 02                	push   $0x2
  80016c:	56                   	push   %esi
  80016d:	e8 5b 0c 00 00       	call   800dcd <sys_env_set_status>
  800172:	83 c4 10             	add    $0x10,%esp
  800175:	85 c0                	test   %eax,%eax
  800177:	79 12                	jns    80018b <dumbfork+0xb9>
		panic("sys_env_set_status: %e", r);
  800179:	50                   	push   %eax
  80017a:	68 d7 1f 80 00       	push   $0x801fd7
  80017f:	6a 4c                	push   $0x4c
  800181:	68 93 1f 80 00       	push   $0x801f93
  800186:	e8 c5 00 00 00       	call   800250 <_panic>

	return envid;
}
  80018b:	89 f0                	mov    %esi,%eax
  80018d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800199:	e8 34 ff ff ff       	call   8000d2 <dumbfork>
  80019e:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a0:	be 00 00 00 00       	mov    $0x0,%esi
  8001a5:	eb 28                	jmp    8001cf <umain+0x3b>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	74 07                	je     8001b2 <umain+0x1e>
  8001ab:	b8 ee 1f 80 00       	mov    $0x801fee,%eax
  8001b0:	eb 05                	jmp    8001b7 <umain+0x23>
  8001b2:	b8 f5 1f 80 00       	mov    $0x801ff5,%eax
  8001b7:	83 ec 04             	sub    $0x4,%esp
  8001ba:	50                   	push   %eax
  8001bb:	56                   	push   %esi
  8001bc:	68 fb 1f 80 00       	push   $0x801ffb
  8001c1:	e8 62 01 00 00       	call   800328 <cprintf>
		sys_yield();
  8001c6:	e8 6e 0b 00 00       	call   800d39 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001cb:	46                   	inc    %esi
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	83 fb 01             	cmp    $0x1,%ebx
  8001d2:	19 c0                	sbb    %eax,%eax
  8001d4:	83 e0 0a             	and    $0xa,%eax
  8001d7:	83 c0 0a             	add    $0xa,%eax
  8001da:	39 c6                	cmp    %eax,%esi
  8001dc:	7c c9                	jl     8001a7 <umain+0x13>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    
  8001e5:	00 00                	add    %al,(%eax)
	...

008001e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001f3:	e8 1d 0b 00 00       	call   800d15 <sys_getenvid>
  8001f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fd:	89 c2                	mov    %eax,%edx
  8001ff:	c1 e2 07             	shl    $0x7,%edx
  800202:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800209:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x31>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	53                   	push   %ebx
  80021d:	56                   	push   %esi
  80021e:	e8 71 ff ff ff       	call   800194 <umain>

	// exit gracefully
	exit();
  800223:	e8 0c 00 00 00       	call   800234 <exit>
  800228:	83 c4 10             	add    $0x10,%esp
}
  80022b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	c9                   	leave  
  800231:	c3                   	ret    
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023a:	e8 d7 0e 00 00       	call   801116 <close_all>
	sys_env_destroy(0);
  80023f:	83 ec 0c             	sub    $0xc,%esp
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
  800258:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80025e:	e8 b2 0a 00 00       	call   800d15 <sys_getenvid>
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	53                   	push   %ebx
  80026d:	50                   	push   %eax
  80026e:	68 18 20 80 00       	push   $0x802018
  800273:	e8 b0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	56                   	push   %esi
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 53 00 00 00       	call   8002d7 <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 0b 20 80 00 	movl   $0x80200b,(%esp)
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
  800390:	e8 87 19 00 00       	call   801d1c <__udivdi3>
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
  8003cc:	e8 67 1a 00 00       	call   801e38 <__umoddi3>
  8003d1:	83 c4 14             	add    $0x14,%esp
  8003d4:	0f be 80 3b 20 80 00 	movsbl 0x80203b(%eax),%eax
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
  800518:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
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
  8005bf:	83 f8 0f             	cmp    $0xf,%eax
  8005c2:	7f 0b                	jg     8005cf <vprintfmt+0x142>
  8005c4:	8b 04 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 1a                	jne    8005e9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005cf:	52                   	push   %edx
  8005d0:	68 53 20 80 00       	push   $0x802053
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
  8005ea:	68 15 24 80 00       	push   $0x802415
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
  800620:	c7 45 d0 4c 20 80 00 	movl   $0x80204c,-0x30(%ebp)
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
  800c8e:	68 3f 23 80 00       	push   $0x80233f
  800c93:	6a 42                	push   $0x42
  800c95:	68 5c 23 80 00       	push   $0x80235c
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
  800d51:	b8 0b 00 00 00       	mov    $0xb,%eax
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

00800df0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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

00800e13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e19:	6a 00                	push   $0x0
  800e1b:	6a 00                	push   $0x0
  800e1d:	6a 00                	push   $0x0
  800e1f:	ff 75 0c             	pushl  0xc(%ebp)
  800e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e25:	ba 01 00 00 00       	mov    $0x1,%edx
  800e2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2f:	e8 28 fe ff ff       	call   800c5c <syscall>
}
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e3c:	6a 00                	push   $0x0
  800e3e:	ff 75 14             	pushl  0x14(%ebp)
  800e41:	ff 75 10             	pushl  0x10(%ebp)
  800e44:	ff 75 0c             	pushl  0xc(%ebp)
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e54:	e8 03 fe ff ff       	call   800c5c <syscall>
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e61:	6a 00                	push   $0x0
  800e63:	6a 00                	push   $0x0
  800e65:	6a 00                	push   $0x0
  800e67:	6a 00                	push   $0x0
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e76:	e8 e1 fd ff ff       	call   800c5c <syscall>
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e83:	6a 00                	push   $0x0
  800e85:	6a 00                	push   $0x0
  800e87:	6a 00                	push   $0x0
  800e89:	ff 75 0c             	pushl  0xc(%ebp)
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e99:	e8 be fd ff ff       	call   800c5c <syscall>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800ea6:	6a 00                	push   $0x0
  800ea8:	ff 75 14             	pushl  0x14(%ebp)
  800eab:	ff 75 10             	pushl  0x10(%ebp)
  800eae:	ff 75 0c             	pushl  0xc(%ebp)
  800eb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ebe:	e8 99 fd ff ff       	call   800c5c <syscall>
} 
  800ec3:	c9                   	leave  
  800ec4:	c3                   	ret    

00800ec5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800ecb:	6a 00                	push   $0x0
  800ecd:	6a 00                	push   $0x0
  800ecf:	6a 00                	push   $0x0
  800ed1:	6a 00                	push   $0x0
  800ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed6:	ba 00 00 00 00       	mov    $0x0,%edx
  800edb:	b8 11 00 00 00       	mov    $0x11,%eax
  800ee0:	e8 77 fd ff ff       	call   800c5c <syscall>
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800eed:	6a 00                	push   $0x0
  800eef:	6a 00                	push   $0x0
  800ef1:	6a 00                	push   $0x0
  800ef3:	6a 00                	push   $0x0
  800ef5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 10 00 00 00       	mov    $0x10,%eax
  800f04:	e8 53 fd ff ff       	call   800c5c <syscall>
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    
	...

00800f0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	05 00 00 00 30       	add    $0x30000000,%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1f:	ff 75 08             	pushl  0x8(%ebp)
  800f22:	e8 e5 ff ff ff       	call   800f0c <fd2num>
  800f27:	83 c4 04             	add    $0x4,%esp
  800f2a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f2f:	c1 e0 0c             	shl    $0xc,%eax
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800f40:	a8 01                	test   $0x1,%al
  800f42:	74 34                	je     800f78 <fd_alloc+0x44>
  800f44:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800f49:	a8 01                	test   $0x1,%al
  800f4b:	74 32                	je     800f7f <fd_alloc+0x4b>
  800f4d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800f52:	89 c1                	mov    %eax,%ecx
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 16             	shr    $0x16,%edx
  800f59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f60:	f6 c2 01             	test   $0x1,%dl
  800f63:	74 1f                	je     800f84 <fd_alloc+0x50>
  800f65:	89 c2                	mov    %eax,%edx
  800f67:	c1 ea 0c             	shr    $0xc,%edx
  800f6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f71:	f6 c2 01             	test   $0x1,%dl
  800f74:	75 17                	jne    800f8d <fd_alloc+0x59>
  800f76:	eb 0c                	jmp    800f84 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f78:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f7d:	eb 05                	jmp    800f84 <fd_alloc+0x50>
  800f7f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f84:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	eb 17                	jmp    800fa4 <fd_alloc+0x70>
  800f8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f97:	75 b9                	jne    800f52 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f99:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa4:	5b                   	pop    %ebx
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fad:	83 f8 1f             	cmp    $0x1f,%eax
  800fb0:	77 36                	ja     800fe8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fb7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fba:	89 c2                	mov    %eax,%edx
  800fbc:	c1 ea 16             	shr    $0x16,%edx
  800fbf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc6:	f6 c2 01             	test   $0x1,%dl
  800fc9:	74 24                	je     800fef <fd_lookup+0x48>
  800fcb:	89 c2                	mov    %eax,%edx
  800fcd:	c1 ea 0c             	shr    $0xc,%edx
  800fd0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd7:	f6 c2 01             	test   $0x1,%dl
  800fda:	74 1a                	je     800ff6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdf:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	eb 13                	jmp    800ffb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fe8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fed:	eb 0c                	jmp    800ffb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff4:	eb 05                	jmp    800ffb <fd_lookup+0x54>
  800ff6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	53                   	push   %ebx
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801007:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80100a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801010:	74 0d                	je     80101f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
  801017:	eb 14                	jmp    80102d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801019:	39 0a                	cmp    %ecx,(%edx)
  80101b:	75 10                	jne    80102d <dev_lookup+0x30>
  80101d:	eb 05                	jmp    801024 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80101f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801024:	89 13                	mov    %edx,(%ebx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 31                	jmp    80105e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80102d:	40                   	inc    %eax
  80102e:	8b 14 85 ec 23 80 00 	mov    0x8023ec(,%eax,4),%edx
  801035:	85 d2                	test   %edx,%edx
  801037:	75 e0                	jne    801019 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801039:	a1 04 40 80 00       	mov    0x804004,%eax
  80103e:	8b 40 48             	mov    0x48(%eax),%eax
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	51                   	push   %ecx
  801045:	50                   	push   %eax
  801046:	68 6c 23 80 00       	push   $0x80236c
  80104b:	e8 d8 f2 ff ff       	call   800328 <cprintf>
	*dev = 0;
  801050:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	83 ec 20             	sub    $0x20,%esp
  80106b:	8b 75 08             	mov    0x8(%ebp),%esi
  80106e:	8a 45 0c             	mov    0xc(%ebp),%al
  801071:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801074:	56                   	push   %esi
  801075:	e8 92 fe ff ff       	call   800f0c <fd2num>
  80107a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80107d:	89 14 24             	mov    %edx,(%esp)
  801080:	50                   	push   %eax
  801081:	e8 21 ff ff ff       	call   800fa7 <fd_lookup>
  801086:	89 c3                	mov    %eax,%ebx
  801088:	83 c4 08             	add    $0x8,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 05                	js     801094 <fd_close+0x31>
	    || fd != fd2)
  80108f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801092:	74 0d                	je     8010a1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801094:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801098:	75 48                	jne    8010e2 <fd_close+0x7f>
  80109a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109f:	eb 41                	jmp    8010e2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a7:	50                   	push   %eax
  8010a8:	ff 36                	pushl  (%esi)
  8010aa:	e8 4e ff ff ff       	call   800ffd <dev_lookup>
  8010af:	89 c3                	mov    %eax,%ebx
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 1c                	js     8010d4 <fd_close+0x71>
		if (dev->dev_close)
  8010b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010bb:	8b 40 10             	mov    0x10(%eax),%eax
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	74 0d                	je     8010cf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	56                   	push   %esi
  8010c6:	ff d0                	call   *%eax
  8010c8:	89 c3                	mov    %eax,%ebx
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	eb 05                	jmp    8010d4 <fd_close+0x71>
		else
			r = 0;
  8010cf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	56                   	push   %esi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 cb fc ff ff       	call   800daa <sys_page_unmap>
	return r;
  8010df:	83 c4 10             	add    $0x10,%esp
}
  8010e2:	89 d8                	mov    %ebx,%eax
  8010e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	e8 aa fe ff ff       	call   800fa7 <fd_lookup>
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 10                	js     801114 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	6a 01                	push   $0x1
  801109:	ff 75 f4             	pushl  -0xc(%ebp)
  80110c:	e8 52 ff ff ff       	call   801063 <fd_close>
  801111:	83 c4 10             	add    $0x10,%esp
}
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <close_all>:

void
close_all(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	53                   	push   %ebx
  80111a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	53                   	push   %ebx
  801126:	e8 c0 ff ff ff       	call   8010eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80112b:	43                   	inc    %ebx
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	83 fb 20             	cmp    $0x20,%ebx
  801132:	75 ee                	jne    801122 <close_all+0xc>
		close(i);
}
  801134:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801137:	c9                   	leave  
  801138:	c3                   	ret    

00801139 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	57                   	push   %edi
  80113d:	56                   	push   %esi
  80113e:	53                   	push   %ebx
  80113f:	83 ec 2c             	sub    $0x2c,%esp
  801142:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801145:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	ff 75 08             	pushl  0x8(%ebp)
  80114c:	e8 56 fe ff ff       	call   800fa7 <fd_lookup>
  801151:	89 c3                	mov    %eax,%ebx
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	0f 88 c0 00 00 00    	js     80121e <dup+0xe5>
		return r;
	close(newfdnum);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	57                   	push   %edi
  801162:	e8 84 ff ff ff       	call   8010eb <close>

	newfd = INDEX2FD(newfdnum);
  801167:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80116d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801170:	83 c4 04             	add    $0x4,%esp
  801173:	ff 75 e4             	pushl  -0x1c(%ebp)
  801176:	e8 a1 fd ff ff       	call   800f1c <fd2data>
  80117b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80117d:	89 34 24             	mov    %esi,(%esp)
  801180:	e8 97 fd ff ff       	call   800f1c <fd2data>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80118b:	89 d8                	mov    %ebx,%eax
  80118d:	c1 e8 16             	shr    $0x16,%eax
  801190:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801197:	a8 01                	test   $0x1,%al
  801199:	74 37                	je     8011d2 <dup+0x99>
  80119b:	89 d8                	mov    %ebx,%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
  8011a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 26                	je     8011d2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011bf:	6a 00                	push   $0x0
  8011c1:	53                   	push   %ebx
  8011c2:	6a 00                	push   $0x0
  8011c4:	e8 bb fb ff ff       	call   800d84 <sys_page_map>
  8011c9:	89 c3                	mov    %eax,%ebx
  8011cb:	83 c4 20             	add    $0x20,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 2d                	js     8011ff <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	c1 ea 0c             	shr    $0xc,%edx
  8011da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011ea:	52                   	push   %edx
  8011eb:	56                   	push   %esi
  8011ec:	6a 00                	push   $0x0
  8011ee:	50                   	push   %eax
  8011ef:	6a 00                	push   $0x0
  8011f1:	e8 8e fb ff ff       	call   800d84 <sys_page_map>
  8011f6:	89 c3                	mov    %eax,%ebx
  8011f8:	83 c4 20             	add    $0x20,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 1d                	jns    80121c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	56                   	push   %esi
  801203:	6a 00                	push   $0x0
  801205:	e8 a0 fb ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, nva);
  80120a:	83 c4 08             	add    $0x8,%esp
  80120d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801210:	6a 00                	push   $0x0
  801212:	e8 93 fb ff ff       	call   800daa <sys_page_unmap>
	return r;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	eb 02                	jmp    80121e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80121c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	53                   	push   %ebx
  801237:	e8 6b fd ff ff       	call   800fa7 <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 67                	js     8012aa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124d:	ff 30                	pushl  (%eax)
  80124f:	e8 a9 fd ff ff       	call   800ffd <dev_lookup>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 4f                	js     8012aa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80125b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125e:	8b 50 08             	mov    0x8(%eax),%edx
  801261:	83 e2 03             	and    $0x3,%edx
  801264:	83 fa 01             	cmp    $0x1,%edx
  801267:	75 21                	jne    80128a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801269:	a1 04 40 80 00       	mov    0x804004,%eax
  80126e:	8b 40 48             	mov    0x48(%eax),%eax
  801271:	83 ec 04             	sub    $0x4,%esp
  801274:	53                   	push   %ebx
  801275:	50                   	push   %eax
  801276:	68 b0 23 80 00       	push   $0x8023b0
  80127b:	e8 a8 f0 ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801288:	eb 20                	jmp    8012aa <read+0x82>
	}
	if (!dev->dev_read)
  80128a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128d:	8b 52 08             	mov    0x8(%edx),%edx
  801290:	85 d2                	test   %edx,%edx
  801292:	74 11                	je     8012a5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801294:	83 ec 04             	sub    $0x4,%esp
  801297:	ff 75 10             	pushl  0x10(%ebp)
  80129a:	ff 75 0c             	pushl  0xc(%ebp)
  80129d:	50                   	push   %eax
  80129e:	ff d2                	call   *%edx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	eb 05                	jmp    8012aa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012be:	85 f6                	test   %esi,%esi
  8012c0:	74 31                	je     8012f3 <readn+0x44>
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012cc:	83 ec 04             	sub    $0x4,%esp
  8012cf:	89 f2                	mov    %esi,%edx
  8012d1:	29 c2                	sub    %eax,%edx
  8012d3:	52                   	push   %edx
  8012d4:	03 45 0c             	add    0xc(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	57                   	push   %edi
  8012d9:	e8 4a ff ff ff       	call   801228 <read>
		if (m < 0)
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 17                	js     8012fc <readn+0x4d>
			return m;
		if (m == 0)
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 11                	je     8012fa <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e9:	01 c3                	add    %eax,%ebx
  8012eb:	89 d8                	mov    %ebx,%eax
  8012ed:	39 f3                	cmp    %esi,%ebx
  8012ef:	72 db                	jb     8012cc <readn+0x1d>
  8012f1:	eb 09                	jmp    8012fc <readn+0x4d>
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f8:	eb 02                	jmp    8012fc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012fa:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	53                   	push   %ebx
  801308:	83 ec 14             	sub    $0x14,%esp
  80130b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	53                   	push   %ebx
  801313:	e8 8f fc ff ff       	call   800fa7 <fd_lookup>
  801318:	83 c4 08             	add    $0x8,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 62                	js     801381 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	ff 30                	pushl  (%eax)
  80132b:	e8 cd fc ff ff       	call   800ffd <dev_lookup>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 4a                	js     801381 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133e:	75 21                	jne    801361 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801340:	a1 04 40 80 00       	mov    0x804004,%eax
  801345:	8b 40 48             	mov    0x48(%eax),%eax
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	50                   	push   %eax
  80134d:	68 cc 23 80 00       	push   $0x8023cc
  801352:	e8 d1 ef ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135f:	eb 20                	jmp    801381 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801361:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801364:	8b 52 0c             	mov    0xc(%edx),%edx
  801367:	85 d2                	test   %edx,%edx
  801369:	74 11                	je     80137c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	ff 75 10             	pushl  0x10(%ebp)
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	50                   	push   %eax
  801375:	ff d2                	call   *%edx
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	eb 05                	jmp    801381 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80137c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <seek>:

int
seek(int fdnum, off_t offset)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 75 08             	pushl  0x8(%ebp)
  801393:	e8 0f fc ff ff       	call   800fa7 <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 0e                	js     8013ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80139f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 14             	sub    $0x14,%esp
  8013b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	53                   	push   %ebx
  8013be:	e8 e4 fb ff ff       	call   800fa7 <fd_lookup>
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 5f                	js     801429 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	ff 30                	pushl  (%eax)
  8013d6:	e8 22 fc ff ff       	call   800ffd <dev_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 47                	js     801429 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e9:	75 21                	jne    80140c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013eb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	50                   	push   %eax
  8013f8:	68 8c 23 80 00       	push   $0x80238c
  8013fd:	e8 26 ef ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140a:	eb 1d                	jmp    801429 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80140c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80140f:	8b 52 18             	mov    0x18(%edx),%edx
  801412:	85 d2                	test   %edx,%edx
  801414:	74 0e                	je     801424 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	ff 75 0c             	pushl  0xc(%ebp)
  80141c:	50                   	push   %eax
  80141d:	ff d2                	call   *%edx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	eb 05                	jmp    801429 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801424:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 14             	sub    $0x14,%esp
  801435:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801438:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 63 fb ff ff       	call   800fa7 <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 52                	js     80149d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	ff 30                	pushl  (%eax)
  801457:	e8 a1 fb ff ff       	call   800ffd <dev_lookup>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 3a                	js     80149d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801466:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80146a:	74 2c                	je     801498 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80146c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80146f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801476:	00 00 00 
	stat->st_isdir = 0;
  801479:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801480:	00 00 00 
	stat->st_dev = dev;
  801483:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	53                   	push   %ebx
  80148d:	ff 75 f0             	pushl  -0x10(%ebp)
  801490:	ff 50 14             	call   *0x14(%eax)
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	eb 05                	jmp    80149d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801498:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	6a 00                	push   $0x0
  8014ac:	ff 75 08             	pushl  0x8(%ebp)
  8014af:	e8 78 01 00 00       	call   80162c <open>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 1b                	js     8014d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	50                   	push   %eax
  8014c4:	e8 65 ff ff ff       	call   80142e <fstat>
  8014c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8014cb:	89 1c 24             	mov    %ebx,(%esp)
  8014ce:	e8 18 fc ff ff       	call   8010eb <close>
	return r;
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	89 f3                	mov    %esi,%ebx
}
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5e                   	pop    %esi
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    
  8014e1:	00 00                	add    %al,(%eax)
	...

008014e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f4:	75 12                	jne    801508 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	6a 01                	push   $0x1
  8014fb:	e8 8a 07 00 00       	call   801c8a <ipc_find_env>
  801500:	a3 00 40 80 00       	mov    %eax,0x804000
  801505:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801508:	6a 07                	push   $0x7
  80150a:	68 00 50 80 00       	push   $0x805000
  80150f:	53                   	push   %ebx
  801510:	ff 35 00 40 80 00    	pushl  0x804000
  801516:	e8 1a 07 00 00       	call   801c35 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80151b:	83 c4 0c             	add    $0xc,%esp
  80151e:	6a 00                	push   $0x0
  801520:	56                   	push   %esi
  801521:	6a 00                	push   $0x0
  801523:	e8 98 06 00 00       	call   801bc0 <ipc_recv>
}
  801528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	8b 40 0c             	mov    0xc(%eax),%eax
  80153f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 05 00 00 00       	mov    $0x5,%eax
  80154e:	e8 91 ff ff ff       	call   8014e4 <fsipc>
  801553:	85 c0                	test   %eax,%eax
  801555:	78 2c                	js     801583 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	68 00 50 80 00       	push   $0x805000
  80155f:	53                   	push   %ebx
  801560:	e8 79 f3 ff ff       	call   8008de <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801565:	a1 80 50 80 00       	mov    0x805080,%eax
  80156a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801570:	a1 84 50 80 00       	mov    0x805084,%eax
  801575:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80158e:	8b 45 08             	mov    0x8(%ebp),%eax
  801591:	8b 40 0c             	mov    0xc(%eax),%eax
  801594:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801599:	ba 00 00 00 00       	mov    $0x0,%edx
  80159e:	b8 06 00 00 00       	mov    $0x6,%eax
  8015a3:	e8 3c ff ff ff       	call   8014e4 <fsipc>
}
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015cd:	e8 12 ff ff ff       	call   8014e4 <fsipc>
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 4b                	js     801623 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d8:	39 c6                	cmp    %eax,%esi
  8015da:	73 16                	jae    8015f2 <devfile_read+0x48>
  8015dc:	68 fc 23 80 00       	push   $0x8023fc
  8015e1:	68 03 24 80 00       	push   $0x802403
  8015e6:	6a 7d                	push   $0x7d
  8015e8:	68 18 24 80 00       	push   $0x802418
  8015ed:	e8 5e ec ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  8015f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f7:	7e 16                	jle    80160f <devfile_read+0x65>
  8015f9:	68 23 24 80 00       	push   $0x802423
  8015fe:	68 03 24 80 00       	push   $0x802403
  801603:	6a 7e                	push   $0x7e
  801605:	68 18 24 80 00       	push   $0x802418
  80160a:	e8 41 ec ff ff       	call   800250 <_panic>
	memmove(buf, &fsipcbuf, r);
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	50                   	push   %eax
  801613:	68 00 50 80 00       	push   $0x805000
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	e8 7f f4 ff ff       	call   800a9f <memmove>
	return r;
  801620:	83 c4 10             	add    $0x10,%esp
}
  801623:	89 d8                	mov    %ebx,%eax
  801625:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	83 ec 1c             	sub    $0x1c,%esp
  801634:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801637:	56                   	push   %esi
  801638:	e8 4f f2 ff ff       	call   80088c <strlen>
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801645:	7f 65                	jg     8016ac <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	e8 e1 f8 ff ff       	call   800f34 <fd_alloc>
  801653:	89 c3                	mov    %eax,%ebx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 55                	js     8016b1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	56                   	push   %esi
  801660:	68 00 50 80 00       	push   $0x805000
  801665:	e8 74 f2 ff ff       	call   8008de <strcpy>
	fsipcbuf.open.req_omode = mode;
  80166a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801672:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801675:	b8 01 00 00 00       	mov    $0x1,%eax
  80167a:	e8 65 fe ff ff       	call   8014e4 <fsipc>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	79 12                	jns    80169a <open+0x6e>
		fd_close(fd, 0);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	6a 00                	push   $0x0
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	e8 ce f9 ff ff       	call   801063 <fd_close>
		return r;
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb 17                	jmp    8016b1 <open+0x85>
	}

	return fd2num(fd);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a0:	e8 67 f8 ff ff       	call   800f0c <fd2num>
  8016a5:	89 c3                	mov    %eax,%ebx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb 05                	jmp    8016b1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016ac:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016b1:	89 d8                	mov    %ebx,%eax
  8016b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    
	...

008016bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016c4:	83 ec 0c             	sub    $0xc,%esp
  8016c7:	ff 75 08             	pushl  0x8(%ebp)
  8016ca:	e8 4d f8 ff ff       	call   800f1c <fd2data>
  8016cf:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	68 2f 24 80 00       	push   $0x80242f
  8016d9:	56                   	push   %esi
  8016da:	e8 ff f1 ff ff       	call   8008de <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016df:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e2:	2b 03                	sub    (%ebx),%eax
  8016e4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016ea:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8016f1:	00 00 00 
	stat->st_dev = &devpipe;
  8016f4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016fb:	30 80 00 
	return 0;
}
  8016fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801703:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801706:	5b                   	pop    %ebx
  801707:	5e                   	pop    %esi
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801714:	53                   	push   %ebx
  801715:	6a 00                	push   $0x0
  801717:	e8 8e f6 ff ff       	call   800daa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80171c:	89 1c 24             	mov    %ebx,(%esp)
  80171f:	e8 f8 f7 ff ff       	call   800f1c <fd2data>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	50                   	push   %eax
  801728:	6a 00                	push   $0x0
  80172a:	e8 7b f6 ff ff       	call   800daa <sys_page_unmap>
}
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 1c             	sub    $0x1c,%esp
  80173d:	89 c7                	mov    %eax,%edi
  80173f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801742:	a1 04 40 80 00       	mov    0x804004,%eax
  801747:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80174a:	83 ec 0c             	sub    $0xc,%esp
  80174d:	57                   	push   %edi
  80174e:	e8 85 05 00 00       	call   801cd8 <pageref>
  801753:	89 c6                	mov    %eax,%esi
  801755:	83 c4 04             	add    $0x4,%esp
  801758:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175b:	e8 78 05 00 00       	call   801cd8 <pageref>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	39 c6                	cmp    %eax,%esi
  801765:	0f 94 c0             	sete   %al
  801768:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80176b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801771:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801774:	39 cb                	cmp    %ecx,%ebx
  801776:	75 08                	jne    801780 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801778:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5f                   	pop    %edi
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801780:	83 f8 01             	cmp    $0x1,%eax
  801783:	75 bd                	jne    801742 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801785:	8b 42 58             	mov    0x58(%edx),%eax
  801788:	6a 01                	push   $0x1
  80178a:	50                   	push   %eax
  80178b:	53                   	push   %ebx
  80178c:	68 36 24 80 00       	push   $0x802436
  801791:	e8 92 eb ff ff       	call   800328 <cprintf>
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	eb a7                	jmp    801742 <_pipeisclosed+0xe>

0080179b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	57                   	push   %edi
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 28             	sub    $0x28,%esp
  8017a4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017a7:	56                   	push   %esi
  8017a8:	e8 6f f7 ff ff       	call   800f1c <fd2data>
  8017ad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017b6:	75 4a                	jne    801802 <devpipe_write+0x67>
  8017b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8017bd:	eb 56                	jmp    801815 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017bf:	89 da                	mov    %ebx,%edx
  8017c1:	89 f0                	mov    %esi,%eax
  8017c3:	e8 6c ff ff ff       	call   801734 <_pipeisclosed>
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	75 4d                	jne    801819 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017cc:	e8 68 f5 ff ff       	call   800d39 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017d1:	8b 43 04             	mov    0x4(%ebx),%eax
  8017d4:	8b 13                	mov    (%ebx),%edx
  8017d6:	83 c2 20             	add    $0x20,%edx
  8017d9:	39 d0                	cmp    %edx,%eax
  8017db:	73 e2                	jae    8017bf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017e5:	79 05                	jns    8017ec <devpipe_write+0x51>
  8017e7:	4a                   	dec    %edx
  8017e8:	83 ca e0             	or     $0xffffffe0,%edx
  8017eb:	42                   	inc    %edx
  8017ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ef:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8017f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017f6:	40                   	inc    %eax
  8017f7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017fa:	47                   	inc    %edi
  8017fb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8017fe:	77 07                	ja     801807 <devpipe_write+0x6c>
  801800:	eb 13                	jmp    801815 <devpipe_write+0x7a>
  801802:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801807:	8b 43 04             	mov    0x4(%ebx),%eax
  80180a:	8b 13                	mov    (%ebx),%edx
  80180c:	83 c2 20             	add    $0x20,%edx
  80180f:	39 d0                	cmp    %edx,%eax
  801811:	73 ac                	jae    8017bf <devpipe_write+0x24>
  801813:	eb c8                	jmp    8017dd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801815:	89 f8                	mov    %edi,%eax
  801817:	eb 05                	jmp    80181e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80181e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801821:	5b                   	pop    %ebx
  801822:	5e                   	pop    %esi
  801823:	5f                   	pop    %edi
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	57                   	push   %edi
  80182a:	56                   	push   %esi
  80182b:	53                   	push   %ebx
  80182c:	83 ec 18             	sub    $0x18,%esp
  80182f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801832:	57                   	push   %edi
  801833:	e8 e4 f6 ff ff       	call   800f1c <fd2data>
  801838:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801841:	75 44                	jne    801887 <devpipe_read+0x61>
  801843:	be 00 00 00 00       	mov    $0x0,%esi
  801848:	eb 4f                	jmp    801899 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80184a:	89 f0                	mov    %esi,%eax
  80184c:	eb 54                	jmp    8018a2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80184e:	89 da                	mov    %ebx,%edx
  801850:	89 f8                	mov    %edi,%eax
  801852:	e8 dd fe ff ff       	call   801734 <_pipeisclosed>
  801857:	85 c0                	test   %eax,%eax
  801859:	75 42                	jne    80189d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80185b:	e8 d9 f4 ff ff       	call   800d39 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801860:	8b 03                	mov    (%ebx),%eax
  801862:	3b 43 04             	cmp    0x4(%ebx),%eax
  801865:	74 e7                	je     80184e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801867:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80186c:	79 05                	jns    801873 <devpipe_read+0x4d>
  80186e:	48                   	dec    %eax
  80186f:	83 c8 e0             	or     $0xffffffe0,%eax
  801872:	40                   	inc    %eax
  801873:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80187a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80187d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80187f:	46                   	inc    %esi
  801880:	39 75 10             	cmp    %esi,0x10(%ebp)
  801883:	77 07                	ja     80188c <devpipe_read+0x66>
  801885:	eb 12                	jmp    801899 <devpipe_read+0x73>
  801887:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80188c:	8b 03                	mov    (%ebx),%eax
  80188e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801891:	75 d4                	jne    801867 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801893:	85 f6                	test   %esi,%esi
  801895:	75 b3                	jne    80184a <devpipe_read+0x24>
  801897:	eb b5                	jmp    80184e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801899:	89 f0                	mov    %esi,%eax
  80189b:	eb 05                	jmp    8018a2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 28             	sub    $0x28,%esp
  8018b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	e8 75 f6 ff ff       	call   800f34 <fd_alloc>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	0f 88 24 01 00 00    	js     8019f0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	68 07 04 00 00       	push   $0x407
  8018d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 82 f4 ff ff       	call   800d60 <sys_page_alloc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	0f 88 05 01 00 00    	js     8019f0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	e8 3d f6 ff ff       	call   800f34 <fd_alloc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	0f 88 dc 00 00 00    	js     8019e0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	68 07 04 00 00       	push   $0x407
  80190c:	ff 75 e0             	pushl  -0x20(%ebp)
  80190f:	6a 00                	push   $0x0
  801911:	e8 4a f4 ff ff       	call   800d60 <sys_page_alloc>
  801916:	89 c3                	mov    %eax,%ebx
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	0f 88 bd 00 00 00    	js     8019e0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 e4             	pushl  -0x1c(%ebp)
  801929:	e8 ee f5 ff ff       	call   800f1c <fd2data>
  80192e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801930:	83 c4 0c             	add    $0xc,%esp
  801933:	68 07 04 00 00       	push   $0x407
  801938:	50                   	push   %eax
  801939:	6a 00                	push   $0x0
  80193b:	e8 20 f4 ff ff       	call   800d60 <sys_page_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	0f 88 83 00 00 00    	js     8019d0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff 75 e0             	pushl  -0x20(%ebp)
  801953:	e8 c4 f5 ff ff       	call   800f1c <fd2data>
  801958:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80195f:	50                   	push   %eax
  801960:	6a 00                	push   $0x0
  801962:	56                   	push   %esi
  801963:	6a 00                	push   $0x0
  801965:	e8 1a f4 ff ff       	call   800d84 <sys_page_map>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 20             	add    $0x20,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 4f                	js     8019c2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801973:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801979:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80197e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801981:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801988:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801991:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801993:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801996:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a3:	e8 64 f5 ff ff       	call   800f0c <fd2num>
  8019a8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019aa:	83 c4 04             	add    $0x4,%esp
  8019ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b0:	e8 57 f5 ff ff       	call   800f0c <fd2num>
  8019b5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c0:	eb 2e                	jmp    8019f0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	56                   	push   %esi
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 dd f3 ff ff       	call   800daa <sys_page_unmap>
  8019cd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 cd f3 ff ff       	call   800daa <sys_page_unmap>
  8019dd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 bd f3 ff ff       	call   800daa <sys_page_unmap>
  8019ed:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a03:	50                   	push   %eax
  801a04:	ff 75 08             	pushl  0x8(%ebp)
  801a07:	e8 9b f5 ff ff       	call   800fa7 <fd_lookup>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 18                	js     801a2b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	ff 75 f4             	pushl  -0xc(%ebp)
  801a19:	e8 fe f4 ff ff       	call   800f1c <fd2data>
	return _pipeisclosed(fd, p);
  801a1e:	89 c2                	mov    %eax,%edx
  801a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a23:	e8 0c fd ff ff       	call   801734 <_pipeisclosed>
  801a28:	83 c4 10             	add    $0x10,%esp
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    
  801a2d:	00 00                	add    %al,(%eax)
	...

00801a30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a40:	68 4e 24 80 00       	push   $0x80244e
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	e8 91 ee ff ff       	call   8008de <strcpy>
	return 0;
}
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a64:	74 45                	je     801aab <devcons_write+0x57>
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a70:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a79:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a7b:	83 fb 7f             	cmp    $0x7f,%ebx
  801a7e:	76 05                	jbe    801a85 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a80:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	53                   	push   %ebx
  801a89:	03 45 0c             	add    0xc(%ebp),%eax
  801a8c:	50                   	push   %eax
  801a8d:	57                   	push   %edi
  801a8e:	e8 0c f0 ff ff       	call   800a9f <memmove>
		sys_cputs(buf, m);
  801a93:	83 c4 08             	add    $0x8,%esp
  801a96:	53                   	push   %ebx
  801a97:	57                   	push   %edi
  801a98:	e8 0c f2 ff ff       	call   800ca9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a9d:	01 de                	add    %ebx,%esi
  801a9f:	89 f0                	mov    %esi,%eax
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aa7:	72 cd                	jb     801a76 <devcons_write+0x22>
  801aa9:	eb 05                	jmp    801ab0 <devcons_write+0x5c>
  801aab:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ab0:	89 f0                	mov    %esi,%eax
  801ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ac0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac4:	75 07                	jne    801acd <devcons_read+0x13>
  801ac6:	eb 25                	jmp    801aed <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ac8:	e8 6c f2 ff ff       	call   800d39 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801acd:	e8 fd f1 ff ff       	call   800ccf <sys_cgetc>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	74 f2                	je     801ac8 <devcons_read+0xe>
  801ad6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 1d                	js     801af9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801adc:	83 f8 04             	cmp    $0x4,%eax
  801adf:	74 13                	je     801af4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae4:	88 10                	mov    %dl,(%eax)
	return 1;
  801ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  801aeb:	eb 0c                	jmp    801af9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
  801af2:	eb 05                	jmp    801af9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801af4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b07:	6a 01                	push   $0x1
  801b09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b0c:	50                   	push   %eax
  801b0d:	e8 97 f1 ff ff       	call   800ca9 <sys_cputs>
  801b12:	83 c4 10             	add    $0x10,%esp
}
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <getchar>:

int
getchar(void)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b1d:	6a 01                	push   $0x1
  801b1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b22:	50                   	push   %eax
  801b23:	6a 00                	push   $0x0
  801b25:	e8 fe f6 ff ff       	call   801228 <read>
	if (r < 0)
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 0f                	js     801b40 <getchar+0x29>
		return r;
	if (r < 1)
  801b31:	85 c0                	test   %eax,%eax
  801b33:	7e 06                	jle    801b3b <getchar+0x24>
		return -E_EOF;
	return c;
  801b35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b39:	eb 05                	jmp    801b40 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4b:	50                   	push   %eax
  801b4c:	ff 75 08             	pushl  0x8(%ebp)
  801b4f:	e8 53 f4 ff ff       	call   800fa7 <fd_lookup>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 11                	js     801b6c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b64:	39 10                	cmp    %edx,(%eax)
  801b66:	0f 94 c0             	sete   %al
  801b69:	0f b6 c0             	movzbl %al,%eax
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <opencons>:

int
opencons(void)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b77:	50                   	push   %eax
  801b78:	e8 b7 f3 ff ff       	call   800f34 <fd_alloc>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 3a                	js     801bbe <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 ca f1 ff ff       	call   800d60 <sys_page_alloc>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 21                	js     801bbe <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	50                   	push   %eax
  801bb6:	e8 51 f3 ff ff       	call   800f0c <fd2num>
  801bbb:	83 c4 10             	add    $0x10,%esp
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	74 0e                	je     801be0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	50                   	push   %eax
  801bd6:	e8 80 f2 ff ff       	call   800e5b <sys_ipc_recv>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	eb 10                	jmp    801bf0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	68 00 00 c0 ee       	push   $0xeec00000
  801be8:	e8 6e f2 ff ff       	call   800e5b <sys_ipc_recv>
  801bed:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	75 26                	jne    801c1a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801bf4:	85 f6                	test   %esi,%esi
  801bf6:	74 0a                	je     801c02 <ipc_recv+0x42>
  801bf8:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfd:	8b 40 74             	mov    0x74(%eax),%eax
  801c00:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c02:	85 db                	test   %ebx,%ebx
  801c04:	74 0a                	je     801c10 <ipc_recv+0x50>
  801c06:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0b:	8b 40 78             	mov    0x78(%eax),%eax
  801c0e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c10:	a1 04 40 80 00       	mov    0x804004,%eax
  801c15:	8b 40 70             	mov    0x70(%eax),%eax
  801c18:	eb 14                	jmp    801c2e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c1a:	85 f6                	test   %esi,%esi
  801c1c:	74 06                	je     801c24 <ipc_recv+0x64>
  801c1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801c24:	85 db                	test   %ebx,%ebx
  801c26:	74 06                	je     801c2e <ipc_recv+0x6e>
  801c28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801c2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 0c             	sub    $0xc,%esp
  801c3e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c44:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801c47:	85 db                	test   %ebx,%ebx
  801c49:	75 25                	jne    801c70 <ipc_send+0x3b>
  801c4b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801c50:	eb 1e                	jmp    801c70 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801c52:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c55:	75 07                	jne    801c5e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801c57:	e8 dd f0 ff ff       	call   800d39 <sys_yield>
  801c5c:	eb 12                	jmp    801c70 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801c5e:	50                   	push   %eax
  801c5f:	68 5a 24 80 00       	push   $0x80245a
  801c64:	6a 43                	push   $0x43
  801c66:	68 6d 24 80 00       	push   $0x80246d
  801c6b:	e8 e0 e5 ff ff       	call   800250 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	57                   	push   %edi
  801c73:	ff 75 08             	pushl  0x8(%ebp)
  801c76:	e8 bb f1 ff ff       	call   800e36 <sys_ipc_try_send>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	75 d0                	jne    801c52 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5f                   	pop    %edi
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c90:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801c96:	74 1a                	je     801cb2 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c98:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	c1 e2 07             	shl    $0x7,%edx
  801ca2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801ca9:	8b 52 50             	mov    0x50(%edx),%edx
  801cac:	39 ca                	cmp    %ecx,%edx
  801cae:	75 18                	jne    801cc8 <ipc_find_env+0x3e>
  801cb0:	eb 05                	jmp    801cb7 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801cb7:	89 c2                	mov    %eax,%edx
  801cb9:	c1 e2 07             	shl    $0x7,%edx
  801cbc:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801cc3:	8b 40 40             	mov    0x40(%eax),%eax
  801cc6:	eb 0c                	jmp    801cd4 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc8:	40                   	inc    %eax
  801cc9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cce:	75 cd                	jne    801c9d <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd0:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    
	...

00801cd8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	c1 ea 16             	shr    $0x16,%edx
  801ce3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cea:	f6 c2 01             	test   $0x1,%dl
  801ced:	74 1e                	je     801d0d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cef:	c1 e8 0c             	shr    $0xc,%eax
  801cf2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cf9:	a8 01                	test   $0x1,%al
  801cfb:	74 17                	je     801d14 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cfd:	c1 e8 0c             	shr    $0xc,%eax
  801d00:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d07:	ef 
  801d08:	0f b7 c0             	movzwl %ax,%eax
  801d0b:	eb 0c                	jmp    801d19 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d12:	eb 05                	jmp    801d19 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    
	...

00801d1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	57                   	push   %edi
  801d20:	56                   	push   %esi
  801d21:	83 ec 10             	sub    $0x10,%esp
  801d24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d27:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d2a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801d2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d30:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d33:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d36:	85 c0                	test   %eax,%eax
  801d38:	75 2e                	jne    801d68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d3a:	39 f1                	cmp    %esi,%ecx
  801d3c:	77 5a                	ja     801d98 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d3e:	85 c9                	test   %ecx,%ecx
  801d40:	75 0b                	jne    801d4d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d42:	b8 01 00 00 00       	mov    $0x1,%eax
  801d47:	31 d2                	xor    %edx,%edx
  801d49:	f7 f1                	div    %ecx
  801d4b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	f7 f1                	div    %ecx
  801d53:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d55:	89 f8                	mov    %edi,%eax
  801d57:	f7 f1                	div    %ecx
  801d59:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d5b:	89 f8                	mov    %edi,%eax
  801d5d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    
  801d66:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d68:	39 f0                	cmp    %esi,%eax
  801d6a:	77 1c                	ja     801d88 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d6c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801d6f:	83 f7 1f             	xor    $0x1f,%edi
  801d72:	75 3c                	jne    801db0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d74:	39 f0                	cmp    %esi,%eax
  801d76:	0f 82 90 00 00 00    	jb     801e0c <__udivdi3+0xf0>
  801d7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d7f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801d82:	0f 86 84 00 00 00    	jbe    801e0c <__udivdi3+0xf0>
  801d88:	31 f6                	xor    %esi,%esi
  801d8a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d8c:	89 f8                	mov    %edi,%eax
  801d8e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    
  801d97:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d98:	89 f2                	mov    %esi,%edx
  801d9a:	89 f8                	mov    %edi,%eax
  801d9c:	f7 f1                	div    %ecx
  801d9e:	89 c7                	mov    %eax,%edi
  801da0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801da2:	89 f8                	mov    %edi,%eax
  801da4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801db0:	89 f9                	mov    %edi,%ecx
  801db2:	d3 e0                	shl    %cl,%eax
  801db4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801db7:	b8 20 00 00 00       	mov    $0x20,%eax
  801dbc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dc1:	88 c1                	mov    %al,%cl
  801dc3:	d3 ea                	shr    %cl,%edx
  801dc5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801dc8:	09 ca                	or     %ecx,%edx
  801dca:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801dcd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dd0:	89 f9                	mov    %edi,%ecx
  801dd2:	d3 e2                	shl    %cl,%edx
  801dd4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801dd7:	89 f2                	mov    %esi,%edx
  801dd9:	88 c1                	mov    %al,%cl
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	89 f9                	mov    %edi,%ecx
  801de4:	d3 e2                	shl    %cl,%edx
  801de6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801de9:	88 c1                	mov    %al,%cl
  801deb:	d3 ee                	shr    %cl,%esi
  801ded:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801def:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801df2:	89 f0                	mov    %esi,%eax
  801df4:	89 ca                	mov    %ecx,%edx
  801df6:	f7 75 ec             	divl   -0x14(%ebp)
  801df9:	89 d1                	mov    %edx,%ecx
  801dfb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dfd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e00:	39 d1                	cmp    %edx,%ecx
  801e02:	72 28                	jb     801e2c <__udivdi3+0x110>
  801e04:	74 1a                	je     801e20 <__udivdi3+0x104>
  801e06:	89 f7                	mov    %esi,%edi
  801e08:	31 f6                	xor    %esi,%esi
  801e0a:	eb 80                	jmp    801d8c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e0c:	31 f6                	xor    %esi,%esi
  801e0e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e13:	89 f8                	mov    %edi,%eax
  801e15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	5e                   	pop    %esi
  801e1b:	5f                   	pop    %edi
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    
  801e1e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e27:	39 c2                	cmp    %eax,%edx
  801e29:	73 db                	jae    801e06 <__udivdi3+0xea>
  801e2b:	90                   	nop
		{
		  q0--;
  801e2c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e2f:	31 f6                	xor    %esi,%esi
  801e31:	e9 56 ff ff ff       	jmp    801d8c <__udivdi3+0x70>
	...

00801e38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	57                   	push   %edi
  801e3c:	56                   	push   %esi
  801e3d:	83 ec 20             	sub    $0x20,%esp
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801e49:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e4c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801e55:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e57:	85 ff                	test   %edi,%edi
  801e59:	75 15                	jne    801e70 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801e5b:	39 f1                	cmp    %esi,%ecx
  801e5d:	0f 86 99 00 00 00    	jbe    801efc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e63:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e69:	83 c4 20             	add    $0x20,%esp
  801e6c:	5e                   	pop    %esi
  801e6d:	5f                   	pop    %edi
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e70:	39 f7                	cmp    %esi,%edi
  801e72:	0f 87 a4 00 00 00    	ja     801f1c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e78:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801e7b:	83 f0 1f             	xor    $0x1f,%eax
  801e7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e81:	0f 84 a1 00 00 00    	je     801f28 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e87:	89 f8                	mov    %edi,%eax
  801e89:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e8c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e8e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e93:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e99:	89 f9                	mov    %edi,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	09 c2                	or     %eax,%edx
  801e9f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ea8:	d3 e0                	shl    %cl,%eax
  801eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ead:	89 f2                	mov    %esi,%edx
  801eaf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801eb4:	d3 e0                	shl    %cl,%eax
  801eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801eb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ebc:	89 f9                	mov    %edi,%ecx
  801ebe:	d3 e8                	shr    %cl,%eax
  801ec0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ec2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	f7 75 f0             	divl   -0x10(%ebp)
  801ec9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ecb:	f7 65 f4             	mull   -0xc(%ebp)
  801ece:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801ed1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ed3:	39 d6                	cmp    %edx,%esi
  801ed5:	72 71                	jb     801f48 <__umoddi3+0x110>
  801ed7:	74 7f                	je     801f58 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ed9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801edc:	29 c8                	sub    %ecx,%eax
  801ede:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ee0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ee3:	d3 e8                	shr    %cl,%eax
  801ee5:	89 f2                	mov    %esi,%edx
  801ee7:	89 f9                	mov    %edi,%ecx
  801ee9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801eeb:	09 d0                	or     %edx,%eax
  801eed:	89 f2                	mov    %esi,%edx
  801eef:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ef2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ef4:	83 c4 20             	add    $0x20,%esp
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    
  801efb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801efc:	85 c9                	test   %ecx,%ecx
  801efe:	75 0b                	jne    801f0b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f00:	b8 01 00 00 00       	mov    $0x1,%eax
  801f05:	31 d2                	xor    %edx,%edx
  801f07:	f7 f1                	div    %ecx
  801f09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f0b:	89 f0                	mov    %esi,%eax
  801f0d:	31 d2                	xor    %edx,%edx
  801f0f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f14:	f7 f1                	div    %ecx
  801f16:	e9 4a ff ff ff       	jmp    801e65 <__umoddi3+0x2d>
  801f1b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f1c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f1e:	83 c4 20             	add    $0x20,%esp
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    
  801f25:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f28:	39 f7                	cmp    %esi,%edi
  801f2a:	72 05                	jb     801f31 <__umoddi3+0xf9>
  801f2c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801f2f:	77 0c                	ja     801f3d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f31:	89 f2                	mov    %esi,%edx
  801f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f36:	29 c8                	sub    %ecx,%eax
  801f38:	19 fa                	sbb    %edi,%edx
  801f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f40:	83 c4 20             	add    $0x20,%esp
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    
  801f47:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f48:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f4b:	89 c1                	mov    %eax,%ecx
  801f4d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801f50:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801f53:	eb 84                	jmp    801ed9 <__umoddi3+0xa1>
  801f55:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f58:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f5b:	72 eb                	jb     801f48 <__umoddi3+0x110>
  801f5d:	89 f2                	mov    %esi,%edx
  801f5f:	e9 75 ff ff ff       	jmp    801ed9 <__umoddi3+0xa1>
