
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 e3 01 00 00       	call   800214 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	68 00 23 80 00       	push   $0x802300
  800041:	e8 12 03 00 00       	call   800358 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 a5 1c 00 00       	call   801cf6 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 19 23 80 00       	push   $0x802319
  80005e:	6a 0d                	push   $0xd
  800060:	68 22 23 80 00       	push   $0x802322
  800065:	e8 16 02 00 00       	call   800280 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  80006a:	e8 33 0f 00 00       	call   800fa2 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 36 23 80 00       	push   $0x802336
  80007b:	6a 10                	push   $0x10
  80007d:	68 22 23 80 00       	push   $0x802322
  800082:	e8 f9 01 00 00       	call   800280 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 59                	jne    8000e4 <umain+0xb0>
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	e8 5d 14 00 00       	call   8014f3 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if(pipeisclosed(p[0])){
  80009e:	83 ec 0c             	sub    $0xc,%esp
  8000a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a4:	e8 9d 1d 00 00       	call   801e46 <pipeisclosed>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	85 c0                	test   %eax,%eax
  8000ae:	74 15                	je     8000c5 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000b0:	83 ec 0c             	sub    $0xc,%esp
  8000b3:	68 3f 23 80 00       	push   $0x80233f
  8000b8:	e8 9b 02 00 00       	call   800358 <cprintf>
				exit();
  8000bd:	e8 a2 01 00 00       	call   800264 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c5:	e8 9f 0c 00 00       	call   800d69 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000ca:	43                   	inc    %ebx
  8000cb:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000d1:	75 cb                	jne    80009e <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	6a 00                	push   $0x0
  8000d8:	6a 00                	push   $0x0
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 0b 11 00 00       	call   8011ec <ipc_recv>
  8000e1:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	56                   	push   %esi
  8000e8:	68 5a 23 80 00       	push   $0x80235a
  8000ed:	e8 66 02 00 00       	call   800358 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8000f8:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  8000ff:	89 f3                	mov    %esi,%ebx
  800101:	c1 e3 07             	shl    $0x7,%ebx
  800104:	29 c3                	sub    %eax,%ebx
	cprintf("kid is %d\n", kid-envs);
  800106:	83 c4 08             	add    $0x8,%esp
  800109:	89 d8                	mov    %ebx,%eax
  80010b:	c1 f8 02             	sar    $0x2,%eax
  80010e:	89 c1                	mov    %eax,%ecx
  800110:	c1 e1 05             	shl    $0x5,%ecx
  800113:	89 c2                	mov    %eax,%edx
  800115:	c1 e2 0a             	shl    $0xa,%edx
  800118:	8d 14 11             	lea    (%ecx,%edx,1),%edx
  80011b:	01 c2                	add    %eax,%edx
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	c1 e1 0f             	shl    $0xf,%ecx
  800122:	01 ca                	add    %ecx,%edx
  800124:	c1 e2 05             	shl    $0x5,%edx
  800127:	8d 04 02             	lea    (%edx,%eax,1),%eax
  80012a:	f7 d8                	neg    %eax
  80012c:	50                   	push   %eax
  80012d:	68 65 23 80 00       	push   $0x802365
  800132:	e8 21 02 00 00       	call   800358 <cprintf>
	dup(p[0], 10);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	6a 0a                	push   $0xa
  80013c:	ff 75 f0             	pushl  -0x10(%ebp)
  80013f:	e8 fd 13 00 00       	call   801541 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800144:	81 c3 04 00 c0 ee    	add    $0xeec00004,%ebx
  80014a:	8b 43 50             	mov    0x50(%ebx),%eax
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	83 f8 02             	cmp    $0x2,%eax
  800153:	75 18                	jne    80016d <umain+0x139>
		dup(p[0], 10);
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	6a 0a                	push   $0xa
  80015a:	ff 75 f0             	pushl  -0x10(%ebp)
  80015d:	e8 df 13 00 00       	call   801541 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800162:	8b 43 50             	mov    0x50(%ebx),%eax
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	83 f8 02             	cmp    $0x2,%eax
  80016b:	74 e8                	je     800155 <umain+0x121>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	68 70 23 80 00       	push   $0x802370
  800175:	e8 de 01 00 00       	call   800358 <cprintf>
	if (pipeisclosed(p[0]))
  80017a:	83 c4 04             	add    $0x4,%esp
  80017d:	ff 75 f0             	pushl  -0x10(%ebp)
  800180:	e8 c1 1c 00 00       	call   801e46 <pipeisclosed>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	85 c0                	test   %eax,%eax
  80018a:	74 14                	je     8001a0 <umain+0x16c>
		panic("somehow the other end of p[0] got closed!");
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	68 cc 23 80 00       	push   $0x8023cc
  800194:	6a 3a                	push   $0x3a
  800196:	68 22 23 80 00       	push   $0x802322
  80019b:	e8 e0 00 00 00       	call   800280 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8001aa:	e8 00 12 00 00       	call   8013af <fd_lookup>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	85 c0                	test   %eax,%eax
  8001b4:	79 12                	jns    8001c8 <umain+0x194>
		panic("cannot look up p[0]: %e", r);
  8001b6:	50                   	push   %eax
  8001b7:	68 86 23 80 00       	push   $0x802386
  8001bc:	6a 3c                	push   $0x3c
  8001be:	68 22 23 80 00       	push   $0x802322
  8001c3:	e8 b8 00 00 00       	call   800280 <_panic>
	va = fd2data(fd);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ce:	e8 51 11 00 00       	call   801324 <fd2data>
	if (pageref(va) != 3+1)
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 e9 18 00 00       	call   801ac4 <pageref>
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	83 f8 04             	cmp    $0x4,%eax
  8001e1:	74 12                	je     8001f5 <umain+0x1c1>
		cprintf("\nchild detected race\n");
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	68 9e 23 80 00       	push   $0x80239e
  8001eb:	e8 68 01 00 00       	call   800358 <cprintf>
  8001f0:	83 c4 10             	add    $0x10,%esp
  8001f3:	eb 15                	jmp    80020a <umain+0x1d6>
	else
		cprintf("\nrace didn't happen\n", max);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	68 c8 00 00 00       	push   $0xc8
  8001fd:	68 b4 23 80 00       	push   $0x8023b4
  800202:	e8 51 01 00 00       	call   800358 <cprintf>
  800207:	83 c4 10             	add    $0x10,%esp
}
  80020a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	c9                   	leave  
  800210:	c3                   	ret    
  800211:	00 00                	add    %al,(%eax)
	...

00800214 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	8b 75 08             	mov    0x8(%ebp),%esi
  80021c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80021f:	e8 21 0b 00 00       	call   800d45 <sys_getenvid>
  800224:	25 ff 03 00 00       	and    $0x3ff,%eax
  800229:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800230:	c1 e0 07             	shl    $0x7,%eax
  800233:	29 d0                	sub    %edx,%eax
  800235:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023f:	85 f6                	test   %esi,%esi
  800241:	7e 07                	jle    80024a <libmain+0x36>
		binaryname = argv[0];
  800243:	8b 03                	mov    (%ebx),%eax
  800245:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	53                   	push   %ebx
  80024e:	56                   	push   %esi
  80024f:	e8 e0 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800254:	e8 0b 00 00 00       	call   800264 <exit>
  800259:	83 c4 10             	add    $0x10,%esp
}
  80025c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	c9                   	leave  
  800262:	c3                   	ret    
	...

00800264 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026a:	e8 af 12 00 00       	call   80151e <close_all>
	sys_env_destroy(0);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	6a 00                	push   $0x0
  800274:	e8 aa 0a 00 00       	call   800d23 <sys_env_destroy>
  800279:	83 c4 10             	add    $0x10,%esp
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    
	...

00800280 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800285:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800288:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80028e:	e8 b2 0a 00 00       	call   800d45 <sys_getenvid>
  800293:	83 ec 0c             	sub    $0xc,%esp
  800296:	ff 75 0c             	pushl  0xc(%ebp)
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	68 00 24 80 00       	push   $0x802400
  8002a3:	e8 b0 00 00 00       	call   800358 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a8:	83 c4 18             	add    $0x18,%esp
  8002ab:	56                   	push   %esi
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	e8 53 00 00 00       	call   800307 <vcprintf>
	cprintf("\n");
  8002b4:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  8002bb:	e8 98 00 00 00       	call   800358 <cprintf>
  8002c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c3:	cc                   	int3   
  8002c4:	eb fd                	jmp    8002c3 <_panic+0x43>
	...

008002c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 04             	sub    $0x4,%esp
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002d2:	8b 03                	mov    (%ebx),%eax
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002db:	40                   	inc    %eax
  8002dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e3:	75 1a                	jne    8002ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	68 ff 00 00 00       	push   $0xff
  8002ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f0:	50                   	push   %eax
  8002f1:	e8 e3 09 00 00       	call   800cd9 <sys_cputs>
		b->idx = 0;
  8002f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ff:	ff 43 04             	incl   0x4(%ebx)
}
  800302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800310:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800317:	00 00 00 
	b.cnt = 0;
  80031a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800321:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800324:	ff 75 0c             	pushl  0xc(%ebp)
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800330:	50                   	push   %eax
  800331:	68 c8 02 80 00       	push   $0x8002c8
  800336:	e8 82 01 00 00       	call   8004bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80033b:	83 c4 08             	add    $0x8,%esp
  80033e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800344:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80034a:	50                   	push   %eax
  80034b:	e8 89 09 00 00       	call   800cd9 <sys_cputs>

	return b.cnt;
}
  800350:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80035e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 9d ff ff ff       	call   800307 <vcprintf>
	va_end(ap);

	return cnt;
}
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 2c             	sub    $0x2c,%esp
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	89 d6                	mov    %edx,%esi
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800380:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800383:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800386:	8b 45 10             	mov    0x10(%ebp),%eax
  800389:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80038c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800392:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800399:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80039c:	72 0c                	jb     8003aa <printnum+0x3e>
  80039e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003a1:	76 07                	jbe    8003aa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a3:	4b                   	dec    %ebx
  8003a4:	85 db                	test   %ebx,%ebx
  8003a6:	7f 31                	jg     8003d9 <printnum+0x6d>
  8003a8:	eb 3f                	jmp    8003e9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	57                   	push   %edi
  8003ae:	4b                   	dec    %ebx
  8003af:	53                   	push   %ebx
  8003b0:	50                   	push   %eax
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8003ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c0:	e8 db 1c 00 00       	call   8020a0 <__udivdi3>
  8003c5:	83 c4 18             	add    $0x18,%esp
  8003c8:	52                   	push   %edx
  8003c9:	50                   	push   %eax
  8003ca:	89 f2                	mov    %esi,%edx
  8003cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003cf:	e8 98 ff ff ff       	call   80036c <printnum>
  8003d4:	83 c4 20             	add    $0x20,%esp
  8003d7:	eb 10                	jmp    8003e9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	56                   	push   %esi
  8003dd:	57                   	push   %edi
  8003de:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e1:	4b                   	dec    %ebx
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	85 db                	test   %ebx,%ebx
  8003e7:	7f f0                	jg     8003d9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	83 ec 04             	sub    $0x4,%esp
  8003f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fc:	e8 bb 1d 00 00       	call   8021bc <__umoddi3>
  800401:	83 c4 14             	add    $0x14,%esp
  800404:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  80040b:	50                   	push   %eax
  80040c:	ff 55 e4             	call   *-0x1c(%ebp)
  80040f:	83 c4 10             	add    $0x10,%esp
}
  800412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800415:	5b                   	pop    %ebx
  800416:	5e                   	pop    %esi
  800417:	5f                   	pop    %edi
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80041d:	83 fa 01             	cmp    $0x1,%edx
  800420:	7e 0e                	jle    800430 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 08             	lea    0x8(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	8b 52 04             	mov    0x4(%edx),%edx
  80042e:	eb 22                	jmp    800452 <getuint+0x38>
	else if (lflag)
  800430:	85 d2                	test   %edx,%edx
  800432:	74 10                	je     800444 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 0e                	jmp    800452 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800457:	83 fa 01             	cmp    $0x1,%edx
  80045a:	7e 0e                	jle    80046a <getint+0x16>
		return va_arg(*ap, long long);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	8b 52 04             	mov    0x4(%edx),%edx
  800468:	eb 1a                	jmp    800484 <getint+0x30>
	else if (lflag)
  80046a:	85 d2                	test   %edx,%edx
  80046c:	74 0c                	je     80047a <getint+0x26>
		return va_arg(*ap, long);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 04             	lea    0x4(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	99                   	cltd   
  800478:	eb 0a                	jmp    800484 <getint+0x30>
	else
		return va_arg(*ap, int);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	99                   	cltd   
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80048c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80048f:	8b 10                	mov    (%eax),%edx
  800491:	3b 50 04             	cmp    0x4(%eax),%edx
  800494:	73 08                	jae    80049e <sprintputch+0x18>
		*b->buf++ = ch;
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	88 0a                	mov    %cl,(%edx)
  80049b:	42                   	inc    %edx
  80049c:	89 10                	mov    %edx,(%eax)
}
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a9:	50                   	push   %eax
  8004aa:	ff 75 10             	pushl  0x10(%ebp)
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	ff 75 08             	pushl  0x8(%ebp)
  8004b3:	e8 05 00 00 00       	call   8004bd <vprintfmt>
	va_end(ap);
  8004b8:	83 c4 10             	add    $0x10,%esp
}
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    

008004bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	57                   	push   %edi
  8004c1:	56                   	push   %esi
  8004c2:	53                   	push   %ebx
  8004c3:	83 ec 2c             	sub    $0x2c,%esp
  8004c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8004cc:	eb 13                	jmp    8004e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	0f 84 6d 03 00 00    	je     800843 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	57                   	push   %edi
  8004da:	50                   	push   %eax
  8004db:	ff 55 08             	call   *0x8(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e1:	0f b6 06             	movzbl (%esi),%eax
  8004e4:	46                   	inc    %esi
  8004e5:	83 f8 25             	cmp    $0x25,%eax
  8004e8:	75 e4                	jne    8004ce <vprintfmt+0x11>
  8004ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8004ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	eb 28                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80050c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800510:	eb 20                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800514:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800518:	eb 18                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80051c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800523:	eb 0d                	jmp    800532 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800525:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800528:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8a 06                	mov    (%esi),%al
  800534:	0f b6 d0             	movzbl %al,%edx
  800537:	8d 5e 01             	lea    0x1(%esi),%ebx
  80053a:	83 e8 23             	sub    $0x23,%eax
  80053d:	3c 55                	cmp    $0x55,%al
  80053f:	0f 87 e0 02 00 00    	ja     800825 <vprintfmt+0x368>
  800545:	0f b6 c0             	movzbl %al,%eax
  800548:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80054f:	83 ea 30             	sub    $0x30,%edx
  800552:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800555:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800558:	8d 50 d0             	lea    -0x30(%eax),%edx
  80055b:	83 fa 09             	cmp    $0x9,%edx
  80055e:	77 44                	ja     8005a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	89 de                	mov    %ebx,%esi
  800562:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800565:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800566:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800569:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80056d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800570:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800573:	83 fb 09             	cmp    $0x9,%ebx
  800576:	76 ed                	jbe    800565 <vprintfmt+0xa8>
  800578:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80057b:	eb 29                	jmp    8005a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058d:	eb 17                	jmp    8005a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800593:	78 85                	js     80051a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	89 de                	mov    %ebx,%esi
  800597:	eb 99                	jmp    800532 <vprintfmt+0x75>
  800599:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005a2:	eb 8e                	jmp    800532 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005aa:	79 86                	jns    800532 <vprintfmt+0x75>
  8005ac:	e9 74 ff ff ff       	jmp    800525 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	89 de                	mov    %ebx,%esi
  8005b4:	e9 79 ff ff ff       	jmp    800532 <vprintfmt+0x75>
  8005b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	ff 30                	pushl  (%eax)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005d4:	e9 08 ff ff ff       	jmp    8004e1 <vprintfmt+0x24>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 02                	jns    8005ed <vprintfmt+0x130>
  8005eb:	f7 d8                	neg    %eax
  8005ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ef:	83 f8 0f             	cmp    $0xf,%eax
  8005f2:	7f 0b                	jg     8005ff <vprintfmt+0x142>
  8005f4:	8b 04 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%eax
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	75 1a                	jne    800619 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005ff:	52                   	push   %edx
  800600:	68 3b 24 80 00       	push   $0x80243b
  800605:	57                   	push   %edi
  800606:	ff 75 08             	pushl  0x8(%ebp)
  800609:	e8 92 fe ff ff       	call   8004a0 <printfmt>
  80060e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800614:	e9 c8 fe ff ff       	jmp    8004e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800619:	50                   	push   %eax
  80061a:	68 91 29 80 00       	push   $0x802991
  80061f:	57                   	push   %edi
  800620:	ff 75 08             	pushl  0x8(%ebp)
  800623:	e8 78 fe ff ff       	call   8004a0 <printfmt>
  800628:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80062e:	e9 ae fe ff ff       	jmp    8004e1 <vprintfmt+0x24>
  800633:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800636:	89 de                	mov    %ebx,%esi
  800638:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80063b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	75 07                	jne    800657 <vprintfmt+0x19a>
				p = "(null)";
  800650:	c7 45 d0 34 24 80 00 	movl   $0x802434,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800657:	85 db                	test   %ebx,%ebx
  800659:	7e 42                	jle    80069d <vprintfmt+0x1e0>
  80065b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80065f:	74 3c                	je     80069d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	51                   	push   %ecx
  800665:	ff 75 d0             	pushl  -0x30(%ebp)
  800668:	e8 6f 02 00 00       	call   8008dc <strnlen>
  80066d:	29 c3                	sub    %eax,%ebx
  80066f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	85 db                	test   %ebx,%ebx
  800677:	7e 24                	jle    80069d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800679:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80067d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800680:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	57                   	push   %edi
  800687:	53                   	push   %ebx
  800688:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	4e                   	dec    %esi
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	85 f6                	test   %esi,%esi
  800691:	7f f0                	jg     800683 <vprintfmt+0x1c6>
  800693:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006a0:	0f be 02             	movsbl (%edx),%eax
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	75 47                	jne    8006ee <vprintfmt+0x231>
  8006a7:	eb 37                	jmp    8006e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	74 16                	je     8006c5 <vprintfmt+0x208>
  8006af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b2:	83 fa 5e             	cmp    $0x5e,%edx
  8006b5:	76 0e                	jbe    8006c5 <vprintfmt+0x208>
					putch('?', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	57                   	push   %edi
  8006bb:	6a 3f                	push   $0x3f
  8006bd:	ff 55 08             	call   *0x8(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 0b                	jmp    8006d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	57                   	push   %edi
  8006c9:	50                   	push   %eax
  8006ca:	ff 55 08             	call   *0x8(%ebp)
  8006cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d3:	0f be 03             	movsbl (%ebx),%eax
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	74 03                	je     8006dd <vprintfmt+0x220>
  8006da:	43                   	inc    %ebx
  8006db:	eb 1b                	jmp    8006f8 <vprintfmt+0x23b>
  8006dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e4:	7f 1e                	jg     800704 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006e9:	e9 f3 fd ff ff       	jmp    8004e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006f1:	43                   	inc    %ebx
  8006f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006f8:	85 f6                	test   %esi,%esi
  8006fa:	78 ad                	js     8006a9 <vprintfmt+0x1ec>
  8006fc:	4e                   	dec    %esi
  8006fd:	79 aa                	jns    8006a9 <vprintfmt+0x1ec>
  8006ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800702:	eb dc                	jmp    8006e0 <vprintfmt+0x223>
  800704:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	57                   	push   %edi
  80070b:	6a 20                	push   $0x20
  80070d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	4b                   	dec    %ebx
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 db                	test   %ebx,%ebx
  800716:	7f ef                	jg     800707 <vprintfmt+0x24a>
  800718:	e9 c4 fd ff ff       	jmp    8004e1 <vprintfmt+0x24>
  80071d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800720:	89 ca                	mov    %ecx,%edx
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	e8 2a fd ff ff       	call   800454 <getint>
  80072a:	89 c3                	mov    %eax,%ebx
  80072c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80072e:	85 d2                	test   %edx,%edx
  800730:	78 0a                	js     80073c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800732:	b8 0a 00 00 00       	mov    $0xa,%eax
  800737:	e9 b0 00 00 00       	jmp    8007ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	57                   	push   %edi
  800740:	6a 2d                	push   $0x2d
  800742:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800745:	f7 db                	neg    %ebx
  800747:	83 d6 00             	adc    $0x0,%esi
  80074a:	f7 de                	neg    %esi
  80074c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800754:	e9 93 00 00 00       	jmp    8007ec <vprintfmt+0x32f>
  800759:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 b4 fc ff ff       	call   80041a <getuint>
  800766:	89 c3                	mov    %eax,%ebx
  800768:	89 d6                	mov    %edx,%esi
			base = 10;
  80076a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80076f:	eb 7b                	jmp    8007ec <vprintfmt+0x32f>
  800771:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800774:	89 ca                	mov    %ecx,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 d6 fc ff ff       	call   800454 <getint>
  80077e:	89 c3                	mov    %eax,%ebx
  800780:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800782:	85 d2                	test   %edx,%edx
  800784:	78 07                	js     80078d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800786:	b8 08 00 00 00       	mov    $0x8,%eax
  80078b:	eb 5f                	jmp    8007ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	57                   	push   %edi
  800791:	6a 2d                	push   $0x2d
  800793:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800796:	f7 db                	neg    %ebx
  800798:	83 d6 00             	adc    $0x0,%esi
  80079b:	f7 de                	neg    %esi
  80079d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a5:	eb 45                	jmp    8007ec <vprintfmt+0x32f>
  8007a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	57                   	push   %edi
  8007ae:	6a 30                	push   $0x30
  8007b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b3:	83 c4 08             	add    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	6a 78                	push   $0x78
  8007b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 50 04             	lea    0x4(%eax),%edx
  8007c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c5:	8b 18                	mov    (%eax),%ebx
  8007c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d4:	eb 16                	jmp    8007ec <vprintfmt+0x32f>
  8007d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 37 fc ff ff       	call   80041a <getuint>
  8007e3:	89 c3                	mov    %eax,%ebx
  8007e5:	89 d6                	mov    %edx,%esi
			base = 16;
  8007e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ec:	83 ec 0c             	sub    $0xc,%esp
  8007ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007f3:	52                   	push   %edx
  8007f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f7:	50                   	push   %eax
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	89 fa                	mov    %edi,%edx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	e8 68 fb ff ff       	call   80036c <printnum>
			break;
  800804:	83 c4 20             	add    $0x20,%esp
  800807:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80080a:	e9 d2 fc ff ff       	jmp    8004e1 <vprintfmt+0x24>
  80080f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	57                   	push   %edi
  800816:	52                   	push   %edx
  800817:	ff 55 08             	call   *0x8(%ebp)
			break;
  80081a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800820:	e9 bc fc ff ff       	jmp    8004e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	57                   	push   %edi
  800829:	6a 25                	push   $0x25
  80082b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 02                	jmp    800835 <vprintfmt+0x378>
  800833:	89 c6                	mov    %eax,%esi
  800835:	8d 46 ff             	lea    -0x1(%esi),%eax
  800838:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80083c:	75 f5                	jne    800833 <vprintfmt+0x376>
  80083e:	e9 9e fc ff ff       	jmp    8004e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800843:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 18             	sub    $0x18,%esp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800868:	85 c0                	test   %eax,%eax
  80086a:	74 26                	je     800892 <vsnprintf+0x47>
  80086c:	85 d2                	test   %edx,%edx
  80086e:	7e 29                	jle    800899 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800870:	ff 75 14             	pushl  0x14(%ebp)
  800873:	ff 75 10             	pushl  0x10(%ebp)
  800876:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800879:	50                   	push   %eax
  80087a:	68 86 04 80 00       	push   $0x800486
  80087f:	e8 39 fc ff ff       	call   8004bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800884:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800887:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	eb 0c                	jmp    80089e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800897:	eb 05                	jmp    80089e <vsnprintf+0x53>
  800899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 10             	pushl  0x10(%ebp)
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	ff 75 08             	pushl  0x8(%ebp)
  8008b3:	e8 93 ff ff ff       	call   80084b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    
	...

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8008c5:	74 0e                	je     8008d5 <strlen+0x19>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008cc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f9                	jne    8008cc <strlen+0x10>
  8008d3:	eb 05                	jmp    8008da <strlen+0x1e>
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 17                	je     800900 <strnlen+0x24>
  8008e9:	80 39 00             	cmpb   $0x0,(%ecx)
  8008ec:	74 19                	je     800907 <strnlen+0x2b>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f4:	39 d0                	cmp    %edx,%eax
  8008f6:	74 14                	je     80090c <strnlen+0x30>
  8008f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008fc:	75 f5                	jne    8008f3 <strnlen+0x17>
  8008fe:	eb 0c                	jmp    80090c <strnlen+0x30>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 05                	jmp    80090c <strnlen+0x30>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800918:	ba 00 00 00 00       	mov    $0x0,%edx
  80091d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800920:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800923:	42                   	inc    %edx
  800924:	84 c9                	test   %cl,%cl
  800926:	75 f5                	jne    80091d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800928:	5b                   	pop    %ebx
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800932:	53                   	push   %ebx
  800933:	e8 84 ff ff ff       	call   8008bc <strlen>
  800938:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80093b:	ff 75 0c             	pushl  0xc(%ebp)
  80093e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800941:	50                   	push   %eax
  800942:	e8 c7 ff ff ff       	call   80090e <strcpy>
	return dst;
}
  800947:	89 d8                	mov    %ebx,%eax
  800949:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
  800959:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095c:	85 f6                	test   %esi,%esi
  80095e:	74 15                	je     800975 <strncpy+0x27>
  800960:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800965:	8a 1a                	mov    (%edx),%bl
  800967:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096a:	80 3a 01             	cmpb   $0x1,(%edx)
  80096d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800970:	41                   	inc    %ecx
  800971:	39 ce                	cmp    %ecx,%esi
  800973:	77 f0                	ja     800965 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800985:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800988:	85 f6                	test   %esi,%esi
  80098a:	74 32                	je     8009be <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80098c:	83 fe 01             	cmp    $0x1,%esi
  80098f:	74 22                	je     8009b3 <strlcpy+0x3a>
  800991:	8a 0b                	mov    (%ebx),%cl
  800993:	84 c9                	test   %cl,%cl
  800995:	74 20                	je     8009b7 <strlcpy+0x3e>
  800997:	89 f8                	mov    %edi,%eax
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80099e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a1:	88 08                	mov    %cl,(%eax)
  8009a3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a4:	39 f2                	cmp    %esi,%edx
  8009a6:	74 11                	je     8009b9 <strlcpy+0x40>
  8009a8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009ac:	42                   	inc    %edx
  8009ad:	84 c9                	test   %cl,%cl
  8009af:	75 f0                	jne    8009a1 <strlcpy+0x28>
  8009b1:	eb 06                	jmp    8009b9 <strlcpy+0x40>
  8009b3:	89 f8                	mov    %edi,%eax
  8009b5:	eb 02                	jmp    8009b9 <strlcpy+0x40>
  8009b7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b9:	c6 00 00             	movb   $0x0,(%eax)
  8009bc:	eb 02                	jmp    8009c0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009be:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009c0:	29 f8                	sub    %edi,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d0:	8a 01                	mov    (%ecx),%al
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 10                	je     8009e6 <strcmp+0x1f>
  8009d6:	3a 02                	cmp    (%edx),%al
  8009d8:	75 0c                	jne    8009e6 <strcmp+0x1f>
		p++, q++;
  8009da:	41                   	inc    %ecx
  8009db:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	84 c0                	test   %al,%al
  8009e0:	74 04                	je     8009e6 <strcmp+0x1f>
  8009e2:	3a 02                	cmp    (%edx),%al
  8009e4:	74 f4                	je     8009da <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e6:	0f b6 c0             	movzbl %al,%eax
  8009e9:	0f b6 12             	movzbl (%edx),%edx
  8009ec:	29 d0                	sub    %edx,%eax
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	74 1b                	je     800a1c <strncmp+0x2c>
  800a01:	8a 1a                	mov    (%edx),%bl
  800a03:	84 db                	test   %bl,%bl
  800a05:	74 24                	je     800a2b <strncmp+0x3b>
  800a07:	3a 19                	cmp    (%ecx),%bl
  800a09:	75 20                	jne    800a2b <strncmp+0x3b>
  800a0b:	48                   	dec    %eax
  800a0c:	74 15                	je     800a23 <strncmp+0x33>
		n--, p++, q++;
  800a0e:	42                   	inc    %edx
  800a0f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a10:	8a 1a                	mov    (%edx),%bl
  800a12:	84 db                	test   %bl,%bl
  800a14:	74 15                	je     800a2b <strncmp+0x3b>
  800a16:	3a 19                	cmp    (%ecx),%bl
  800a18:	74 f1                	je     800a0b <strncmp+0x1b>
  800a1a:	eb 0f                	jmp    800a2b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	eb 05                	jmp    800a28 <strncmp+0x38>
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a28:	5b                   	pop    %ebx
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2b:	0f b6 02             	movzbl (%edx),%eax
  800a2e:	0f b6 11             	movzbl (%ecx),%edx
  800a31:	29 d0                	sub    %edx,%eax
  800a33:	eb f3                	jmp    800a28 <strncmp+0x38>

00800a35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3e:	8a 10                	mov    (%eax),%dl
  800a40:	84 d2                	test   %dl,%dl
  800a42:	74 18                	je     800a5c <strchr+0x27>
		if (*s == c)
  800a44:	38 ca                	cmp    %cl,%dl
  800a46:	75 06                	jne    800a4e <strchr+0x19>
  800a48:	eb 17                	jmp    800a61 <strchr+0x2c>
  800a4a:	38 ca                	cmp    %cl,%dl
  800a4c:	74 13                	je     800a61 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4e:	40                   	inc    %eax
  800a4f:	8a 10                	mov    (%eax),%dl
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f5                	jne    800a4a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	eb 05                	jmp    800a61 <strchr+0x2c>
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6c:	8a 10                	mov    (%eax),%dl
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	74 11                	je     800a83 <strfind+0x20>
		if (*s == c)
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	75 06                	jne    800a7c <strfind+0x19>
  800a76:	eb 0b                	jmp    800a83 <strfind+0x20>
  800a78:	38 ca                	cmp    %cl,%dl
  800a7a:	74 07                	je     800a83 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a7c:	40                   	inc    %eax
  800a7d:	8a 10                	mov    (%eax),%dl
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f5                	jne    800a78 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 30                	je     800ac8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a98:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9e:	75 25                	jne    800ac5 <memset+0x40>
  800aa0:	f6 c1 03             	test   $0x3,%cl
  800aa3:	75 20                	jne    800ac5 <memset+0x40>
		c &= 0xFF;
  800aa5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	c1 e3 08             	shl    $0x8,%ebx
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	c1 e6 18             	shl    $0x18,%esi
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 10             	shl    $0x10,%eax
  800ab7:	09 f0                	or     %esi,%eax
  800ab9:	09 d0                	or     %edx,%eax
  800abb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac0:	fc                   	cld    
  800ac1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac3:	eb 03                	jmp    800ac8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac5:	fc                   	cld    
  800ac6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac8:	89 f8                	mov    %edi,%eax
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800add:	39 c6                	cmp    %eax,%esi
  800adf:	73 34                	jae    800b15 <memmove+0x46>
  800ae1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae4:	39 d0                	cmp    %edx,%eax
  800ae6:	73 2d                	jae    800b15 <memmove+0x46>
		s += n;
		d += n;
  800ae8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aeb:	f6 c2 03             	test   $0x3,%dl
  800aee:	75 1b                	jne    800b0b <memmove+0x3c>
  800af0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af6:	75 13                	jne    800b0b <memmove+0x3c>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 0e                	jne    800b0b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800afd:	83 ef 04             	sub    $0x4,%edi
  800b00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b03:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b06:	fd                   	std    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 07                	jmp    800b12 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0b:	4f                   	dec    %edi
  800b0c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0f:	fd                   	std    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b12:	fc                   	cld    
  800b13:	eb 20                	jmp    800b35 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1b:	75 13                	jne    800b30 <memmove+0x61>
  800b1d:	a8 03                	test   $0x3,%al
  800b1f:	75 0f                	jne    800b30 <memmove+0x61>
  800b21:	f6 c1 03             	test   $0x3,%cl
  800b24:	75 0a                	jne    800b30 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b26:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	fc                   	cld    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 05                	jmp    800b35 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b30:	89 c7                	mov    %eax,%edi
  800b32:	fc                   	cld    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	ff 75 08             	pushl  0x8(%ebp)
  800b45:	e8 85 ff ff ff       	call   800acf <memmove>
}
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	85 ff                	test   %edi,%edi
  800b5d:	74 32                	je     800b91 <memcmp+0x45>
		if (*s1 != *s2)
  800b5f:	8a 03                	mov    (%ebx),%al
  800b61:	8a 0e                	mov    (%esi),%cl
  800b63:	38 c8                	cmp    %cl,%al
  800b65:	74 19                	je     800b80 <memcmp+0x34>
  800b67:	eb 0d                	jmp    800b76 <memcmp+0x2a>
  800b69:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b6d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b71:	42                   	inc    %edx
  800b72:	38 c8                	cmp    %cl,%al
  800b74:	74 10                	je     800b86 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b76:	0f b6 c0             	movzbl %al,%eax
  800b79:	0f b6 c9             	movzbl %cl,%ecx
  800b7c:	29 c8                	sub    %ecx,%eax
  800b7e:	eb 16                	jmp    800b96 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b80:	4f                   	dec    %edi
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	39 fa                	cmp    %edi,%edx
  800b88:	75 df                	jne    800b69 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	eb 05                	jmp    800b96 <memcmp+0x4a>
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba1:	89 c2                	mov    %eax,%edx
  800ba3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba6:	39 d0                	cmp    %edx,%eax
  800ba8:	73 12                	jae    800bbc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800baa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bad:	38 08                	cmp    %cl,(%eax)
  800baf:	75 06                	jne    800bb7 <memfind+0x1c>
  800bb1:	eb 09                	jmp    800bbc <memfind+0x21>
  800bb3:	38 08                	cmp    %cl,(%eax)
  800bb5:	74 05                	je     800bbc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb7:	40                   	inc    %eax
  800bb8:	39 c2                	cmp    %eax,%edx
  800bba:	77 f7                	ja     800bb3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bca:	eb 01                	jmp    800bcd <strtol+0xf>
		s++;
  800bcc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcd:	8a 02                	mov    (%edx),%al
  800bcf:	3c 20                	cmp    $0x20,%al
  800bd1:	74 f9                	je     800bcc <strtol+0xe>
  800bd3:	3c 09                	cmp    $0x9,%al
  800bd5:	74 f5                	je     800bcc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd7:	3c 2b                	cmp    $0x2b,%al
  800bd9:	75 08                	jne    800be3 <strtol+0x25>
		s++;
  800bdb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800be1:	eb 13                	jmp    800bf6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800be3:	3c 2d                	cmp    $0x2d,%al
  800be5:	75 0a                	jne    800bf1 <strtol+0x33>
		s++, neg = 1;
  800be7:	8d 52 01             	lea    0x1(%edx),%edx
  800bea:	bf 01 00 00 00       	mov    $0x1,%edi
  800bef:	eb 05                	jmp    800bf6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf6:	85 db                	test   %ebx,%ebx
  800bf8:	74 05                	je     800bff <strtol+0x41>
  800bfa:	83 fb 10             	cmp    $0x10,%ebx
  800bfd:	75 28                	jne    800c27 <strtol+0x69>
  800bff:	8a 02                	mov    (%edx),%al
  800c01:	3c 30                	cmp    $0x30,%al
  800c03:	75 10                	jne    800c15 <strtol+0x57>
  800c05:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c09:	75 0a                	jne    800c15 <strtol+0x57>
		s += 2, base = 16;
  800c0b:	83 c2 02             	add    $0x2,%edx
  800c0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c13:	eb 12                	jmp    800c27 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c15:	85 db                	test   %ebx,%ebx
  800c17:	75 0e                	jne    800c27 <strtol+0x69>
  800c19:	3c 30                	cmp    $0x30,%al
  800c1b:	75 05                	jne    800c22 <strtol+0x64>
		s++, base = 8;
  800c1d:	42                   	inc    %edx
  800c1e:	b3 08                	mov    $0x8,%bl
  800c20:	eb 05                	jmp    800c27 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c27:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c2e:	8a 0a                	mov    (%edx),%cl
  800c30:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c33:	80 fb 09             	cmp    $0x9,%bl
  800c36:	77 08                	ja     800c40 <strtol+0x82>
			dig = *s - '0';
  800c38:	0f be c9             	movsbl %cl,%ecx
  800c3b:	83 e9 30             	sub    $0x30,%ecx
  800c3e:	eb 1e                	jmp    800c5e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c40:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 08                	ja     800c50 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c48:	0f be c9             	movsbl %cl,%ecx
  800c4b:	83 e9 57             	sub    $0x57,%ecx
  800c4e:	eb 0e                	jmp    800c5e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c50:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 13                	ja     800c6b <strtol+0xad>
			dig = *s - 'A' + 10;
  800c58:	0f be c9             	movsbl %cl,%ecx
  800c5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5e:	39 f1                	cmp    %esi,%ecx
  800c60:	7d 0d                	jge    800c6f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c62:	42                   	inc    %edx
  800c63:	0f af c6             	imul   %esi,%eax
  800c66:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c69:	eb c3                	jmp    800c2e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c6b:	89 c1                	mov    %eax,%ecx
  800c6d:	eb 02                	jmp    800c71 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c6f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c75:	74 05                	je     800c7c <strtol+0xbe>
		*endptr = (char *) s;
  800c77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c7a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c7c:	85 ff                	test   %edi,%edi
  800c7e:	74 04                	je     800c84 <strtol+0xc6>
  800c80:	89 c8                	mov    %ecx,%eax
  800c82:	f7 d8                	neg    %eax
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    
  800c89:	00 00                	add    %al,(%eax)
	...

00800c8c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 1c             	sub    $0x1c,%esp
  800c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c9b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	8b 75 14             	mov    0x14(%ebp),%esi
  800ca0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca9:	cd 30                	int    $0x30
  800cab:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cb1:	74 1c                	je     800ccf <syscall+0x43>
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 18                	jle    800ccf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cbe:	68 1f 27 80 00       	push   $0x80271f
  800cc3:	6a 42                	push   $0x42
  800cc5:	68 3c 27 80 00       	push   $0x80273c
  800cca:	e8 b1 f5 ff ff       	call   800280 <_panic>

	return ret;
}
  800ccf:	89 d0                	mov    %edx,%eax
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	6a 00                	push   $0x0
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf5:	e8 92 ff ff ff       	call   800c8c <syscall>
  800cfa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <sys_cgetc>:

int
sys_cgetc(void)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	6a 00                	push   $0x0
  800d0b:	6a 00                	push   $0x0
  800d0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d12:	ba 00 00 00 00       	mov    $0x0,%edx
  800d17:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1c:	e8 6b ff ff ff       	call   800c8c <syscall>
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d34:	ba 01 00 00 00       	mov    $0x1,%edx
  800d39:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3e:	e8 49 ff ff ff       	call   800c8c <syscall>
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d4b:	6a 00                	push   $0x0
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	6a 00                	push   $0x0
  800d53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d62:	e8 25 ff ff ff       	call   800c8c <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_yield>:

void
sys_yield(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d86:	e8 01 ff ff ff       	call   800c8c <syscall>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d96:	6a 00                	push   $0x0
  800d98:	6a 00                	push   $0x0
  800d9a:	ff 75 10             	pushl  0x10(%ebp)
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	ba 01 00 00 00       	mov    $0x1,%edx
  800da8:	b8 04 00 00 00       	mov    $0x4,%eax
  800dad:	e8 da fe ff ff       	call   800c8c <syscall>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800dba:	ff 75 18             	pushl  0x18(%ebp)
  800dbd:	ff 75 14             	pushl  0x14(%ebp)
  800dc0:	ff 75 10             	pushl  0x10(%ebp)
  800dc3:	ff 75 0c             	pushl  0xc(%ebp)
  800dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dce:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd3:	e8 b4 fe ff ff       	call   800c8c <syscall>
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800de0:	6a 00                	push   $0x0
  800de2:	6a 00                	push   $0x0
  800de4:	6a 00                	push   $0x0
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dec:	ba 01 00 00 00       	mov    $0x1,%edx
  800df1:	b8 06 00 00 00       	mov    $0x6,%eax
  800df6:	e8 91 fe ff ff       	call   800c8c <syscall>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	ff 75 0c             	pushl  0xc(%ebp)
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800e14:	b8 08 00 00 00       	mov    $0x8,%eax
  800e19:	e8 6e fe ff ff       	call   800c8c <syscall>
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e26:	6a 00                	push   $0x0
  800e28:	6a 00                	push   $0x0
  800e2a:	6a 00                	push   $0x0
  800e2c:	ff 75 0c             	pushl  0xc(%ebp)
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	ba 01 00 00 00       	mov    $0x1,%edx
  800e37:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3c:	e8 4b fe ff ff       	call   800c8c <syscall>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e49:	6a 00                	push   $0x0
  800e4b:	6a 00                	push   $0x0
  800e4d:	6a 00                	push   $0x0
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5f:	e8 28 fe ff ff       	call   800c8c <syscall>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e6c:	6a 00                	push   $0x0
  800e6e:	ff 75 14             	pushl  0x14(%ebp)
  800e71:	ff 75 10             	pushl  0x10(%ebp)
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e84:	e8 03 fe ff ff       	call   800c8c <syscall>
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e91:	6a 00                	push   $0x0
  800e93:	6a 00                	push   $0x0
  800e95:	6a 00                	push   $0x0
  800e97:	6a 00                	push   $0x0
  800e99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ea1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea6:	e8 e1 fd ff ff       	call   800c8c <syscall>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800eb3:	6a 00                	push   $0x0
  800eb5:	6a 00                	push   $0x0
  800eb7:	6a 00                	push   $0x0
  800eb9:	ff 75 0c             	pushl  0xc(%ebp)
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec9:	e8 be fd ff ff       	call   800c8c <syscall>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eda:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800edc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee0:	75 14                	jne    800ef6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	68 4c 27 80 00       	push   $0x80274c
  800eea:	6a 20                	push   $0x20
  800eec:	68 90 28 80 00       	push   $0x802890
  800ef1:	e8 8a f3 ff ff       	call   800280 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	c1 e8 16             	shr    $0x16,%eax
  800efb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f02:	a8 01                	test   $0x1,%al
  800f04:	74 11                	je     800f17 <pgfault+0x47>
  800f06:	89 d8                	mov    %ebx,%eax
  800f08:	c1 e8 0c             	shr    $0xc,%eax
  800f0b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f12:	f6 c4 08             	test   $0x8,%ah
  800f15:	75 14                	jne    800f2b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	68 70 27 80 00       	push   $0x802770
  800f1f:	6a 24                	push   $0x24
  800f21:	68 90 28 80 00       	push   $0x802890
  800f26:	e8 55 f3 ff ff       	call   800280 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	6a 07                	push   $0x7
  800f30:	68 00 f0 7f 00       	push   $0x7ff000
  800f35:	6a 00                	push   $0x0
  800f37:	e8 54 fe ff ff       	call   800d90 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <pgfault+0x85>
  800f43:	50                   	push   %eax
  800f44:	68 94 27 80 00       	push   $0x802794
  800f49:	6a 32                	push   $0x32
  800f4b:	68 90 28 80 00       	push   $0x802890
  800f50:	e8 2b f3 ff ff       	call   800280 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f55:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	68 00 10 00 00       	push   $0x1000
  800f63:	53                   	push   %ebx
  800f64:	68 00 f0 7f 00       	push   $0x7ff000
  800f69:	e8 cb fb ff ff       	call   800b39 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f6e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f75:	53                   	push   %ebx
  800f76:	6a 00                	push   $0x0
  800f78:	68 00 f0 7f 00       	push   $0x7ff000
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 30 fe ff ff       	call   800db4 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 12                	jns    800f9d <pgfault+0xcd>
  800f8b:	50                   	push   %eax
  800f8c:	68 b8 27 80 00       	push   $0x8027b8
  800f91:	6a 3a                	push   $0x3a
  800f93:	68 90 28 80 00       	push   $0x802890
  800f98:	e8 e3 f2 ff ff       	call   800280 <_panic>

	return;
}
  800f9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fab:	68 d0 0e 80 00       	push   $0x800ed0
  800fb0:	e8 57 10 00 00       	call   80200c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fb5:	ba 07 00 00 00       	mov    $0x7,%edx
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	cd 30                	int    $0x30
  800fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fc1:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 12                	jns    800fdc <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800fca:	50                   	push   %eax
  800fcb:	68 9b 28 80 00       	push   $0x80289b
  800fd0:	6a 7f                	push   $0x7f
  800fd2:	68 90 28 80 00       	push   $0x802890
  800fd7:	e8 a4 f2 ff ff       	call   800280 <_panic>
	}
	int r;

	if (childpid == 0) {
  800fdc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe0:	75 25                	jne    801007 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe2:	e8 5e fd ff ff       	call   800d45 <sys_getenvid>
  800fe7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ff3:	c1 e0 07             	shl    $0x7,%eax
  800ff6:	29 d0                	sub    %edx,%eax
  800ff8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffd:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  801002:	e9 be 01 00 00       	jmp    8011c5 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801007:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  80100c:	89 d8                	mov    %ebx,%eax
  80100e:	c1 e8 16             	shr    $0x16,%eax
  801011:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801018:	a8 01                	test   $0x1,%al
  80101a:	0f 84 10 01 00 00    	je     801130 <fork+0x18e>
  801020:	89 d8                	mov    %ebx,%eax
  801022:	c1 e8 0c             	shr    $0xc,%eax
  801025:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102c:	f6 c2 01             	test   $0x1,%dl
  80102f:	0f 84 fb 00 00 00    	je     801130 <fork+0x18e>
  801035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103c:	f6 c2 04             	test   $0x4,%dl
  80103f:	0f 84 eb 00 00 00    	je     801130 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801045:	89 c6                	mov    %eax,%esi
  801047:	c1 e6 0c             	shl    $0xc,%esi
  80104a:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801050:	0f 84 da 00 00 00    	je     801130 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801056:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105d:	f6 c6 04             	test   $0x4,%dh
  801060:	74 37                	je     801099 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	25 07 0e 00 00       	and    $0xe07,%eax
  801071:	50                   	push   %eax
  801072:	56                   	push   %esi
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	6a 00                	push   $0x0
  801077:	e8 38 fd ff ff       	call   800db4 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	0f 89 a9 00 00 00    	jns    801130 <fork+0x18e>
  801087:	50                   	push   %eax
  801088:	68 dc 27 80 00       	push   $0x8027dc
  80108d:	6a 54                	push   $0x54
  80108f:	68 90 28 80 00       	push   $0x802890
  801094:	e8 e7 f1 ff ff       	call   800280 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801099:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a0:	f6 c2 02             	test   $0x2,%dl
  8010a3:	75 0c                	jne    8010b1 <fork+0x10f>
  8010a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ac:	f6 c4 08             	test   $0x8,%ah
  8010af:	74 57                	je     801108 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	68 05 08 00 00       	push   $0x805
  8010b9:	56                   	push   %esi
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	e8 f1 fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 12                	jns    8010dc <fork+0x13a>
  8010ca:	50                   	push   %eax
  8010cb:	68 dc 27 80 00       	push   $0x8027dc
  8010d0:	6a 59                	push   $0x59
  8010d2:	68 90 28 80 00       	push   $0x802890
  8010d7:	e8 a4 f1 ff ff       	call   800280 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	68 05 08 00 00       	push   $0x805
  8010e4:	56                   	push   %esi
  8010e5:	6a 00                	push   $0x0
  8010e7:	56                   	push   %esi
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 c5 fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 3a                	jns    801130 <fork+0x18e>
  8010f6:	50                   	push   %eax
  8010f7:	68 dc 27 80 00       	push   $0x8027dc
  8010fc:	6a 5c                	push   $0x5c
  8010fe:	68 90 28 80 00       	push   $0x802890
  801103:	e8 78 f1 ff ff       	call   800280 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	6a 05                	push   $0x5
  80110d:	56                   	push   %esi
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	e8 9d fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801117:	83 c4 20             	add    $0x20,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 12                	jns    801130 <fork+0x18e>
  80111e:	50                   	push   %eax
  80111f:	68 dc 27 80 00       	push   $0x8027dc
  801124:	6a 60                	push   $0x60
  801126:	68 90 28 80 00       	push   $0x802890
  80112b:	e8 50 f1 ff ff       	call   800280 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801130:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801136:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80113c:	0f 85 ca fe ff ff    	jne    80100c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	6a 07                	push   $0x7
  801147:	68 00 f0 bf ee       	push   $0xeebff000
  80114c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114f:	e8 3c fc ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 15                	jns    801170 <fork+0x1ce>
  80115b:	50                   	push   %eax
  80115c:	68 00 28 80 00       	push   $0x802800
  801161:	68 94 00 00 00       	push   $0x94
  801166:	68 90 28 80 00       	push   $0x802890
  80116b:	e8 10 f1 ff ff       	call   800280 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	68 78 20 80 00       	push   $0x802078
  801178:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117b:	e8 c3 fc ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 15                	jns    80119c <fork+0x1fa>
  801187:	50                   	push   %eax
  801188:	68 38 28 80 00       	push   $0x802838
  80118d:	68 99 00 00 00       	push   $0x99
  801192:	68 90 28 80 00       	push   $0x802890
  801197:	e8 e4 f0 ff ff       	call   800280 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	6a 02                	push   $0x2
  8011a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a4:	e8 54 fc ff ff       	call   800dfd <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	79 15                	jns    8011c5 <fork+0x223>
  8011b0:	50                   	push   %eax
  8011b1:	68 5c 28 80 00       	push   $0x80285c
  8011b6:	68 a4 00 00 00       	push   $0xa4
  8011bb:	68 90 28 80 00       	push   $0x802890
  8011c0:	e8 bb f0 ff ff       	call   800280 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8011c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011d6:	68 b8 28 80 00       	push   $0x8028b8
  8011db:	68 b1 00 00 00       	push   $0xb1
  8011e0:	68 90 28 80 00       	push   $0x802890
  8011e5:	e8 96 f0 ff ff       	call   800280 <_panic>
	...

008011ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	74 0e                	je     80120c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	50                   	push   %eax
  801202:	e8 84 fc ff ff       	call   800e8b <sys_ipc_recv>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	eb 10                	jmp    80121c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	68 00 00 c0 ee       	push   $0xeec00000
  801214:	e8 72 fc ff ff       	call   800e8b <sys_ipc_recv>
  801219:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  80121c:	85 c0                	test   %eax,%eax
  80121e:	75 26                	jne    801246 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801220:	85 f6                	test   %esi,%esi
  801222:	74 0a                	je     80122e <ipc_recv+0x42>
  801224:	a1 04 40 80 00       	mov    0x804004,%eax
  801229:	8b 40 74             	mov    0x74(%eax),%eax
  80122c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80122e:	85 db                	test   %ebx,%ebx
  801230:	74 0a                	je     80123c <ipc_recv+0x50>
  801232:	a1 04 40 80 00       	mov    0x804004,%eax
  801237:	8b 40 78             	mov    0x78(%eax),%eax
  80123a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  80123c:	a1 04 40 80 00       	mov    0x804004,%eax
  801241:	8b 40 70             	mov    0x70(%eax),%eax
  801244:	eb 14                	jmp    80125a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801246:	85 f6                	test   %esi,%esi
  801248:	74 06                	je     801250 <ipc_recv+0x64>
  80124a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801250:	85 db                	test   %ebx,%ebx
  801252:	74 06                	je     80125a <ipc_recv+0x6e>
  801254:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  80125a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	c9                   	leave  
  801260:	c3                   	ret    

00801261 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	57                   	push   %edi
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80126d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801270:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801273:	85 db                	test   %ebx,%ebx
  801275:	75 25                	jne    80129c <ipc_send+0x3b>
  801277:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80127c:	eb 1e                	jmp    80129c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80127e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801281:	75 07                	jne    80128a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801283:	e8 e1 fa ff ff       	call   800d69 <sys_yield>
  801288:	eb 12                	jmp    80129c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80128a:	50                   	push   %eax
  80128b:	68 ce 28 80 00       	push   $0x8028ce
  801290:	6a 43                	push   $0x43
  801292:	68 e1 28 80 00       	push   $0x8028e1
  801297:	e8 e4 ef ff ff       	call   800280 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	57                   	push   %edi
  80129f:	ff 75 08             	pushl  0x8(%ebp)
  8012a2:	e8 bf fb ff ff       	call   800e66 <sys_ipc_try_send>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	75 d0                	jne    80127e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8012ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5f                   	pop    %edi
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    

008012b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	53                   	push   %ebx
  8012ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8012bd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8012c3:	74 22                	je     8012e7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012c5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8012ca:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	c1 e2 07             	shl    $0x7,%edx
  8012d6:	29 ca                	sub    %ecx,%edx
  8012d8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012de:	8b 52 50             	mov    0x50(%edx),%edx
  8012e1:	39 da                	cmp    %ebx,%edx
  8012e3:	75 1d                	jne    801302 <ipc_find_env+0x4c>
  8012e5:	eb 05                	jmp    8012ec <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8012ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012f3:	c1 e0 07             	shl    $0x7,%eax
  8012f6:	29 d0                	sub    %edx,%eax
  8012f8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8012fd:	8b 40 40             	mov    0x40(%eax),%eax
  801300:	eb 0c                	jmp    80130e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801302:	40                   	inc    %eax
  801303:	3d 00 04 00 00       	cmp    $0x400,%eax
  801308:	75 c0                	jne    8012ca <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80130a:	66 b8 00 00          	mov    $0x0,%ax
}
  80130e:	5b                   	pop    %ebx
  80130f:	c9                   	leave  
  801310:	c3                   	ret    
  801311:	00 00                	add    %al,(%eax)
	...

00801314 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	05 00 00 00 30       	add    $0x30000000,%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 e5 ff ff ff       	call   801314 <fd2num>
  80132f:	83 c4 04             	add    $0x4,%esp
  801332:	05 20 00 0d 00       	add    $0xd0020,%eax
  801337:	c1 e0 0c             	shl    $0xc,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801343:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801348:	a8 01                	test   $0x1,%al
  80134a:	74 34                	je     801380 <fd_alloc+0x44>
  80134c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801351:	a8 01                	test   $0x1,%al
  801353:	74 32                	je     801387 <fd_alloc+0x4b>
  801355:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80135a:	89 c1                	mov    %eax,%ecx
  80135c:	89 c2                	mov    %eax,%edx
  80135e:	c1 ea 16             	shr    $0x16,%edx
  801361:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801368:	f6 c2 01             	test   $0x1,%dl
  80136b:	74 1f                	je     80138c <fd_alloc+0x50>
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	c1 ea 0c             	shr    $0xc,%edx
  801372:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801379:	f6 c2 01             	test   $0x1,%dl
  80137c:	75 17                	jne    801395 <fd_alloc+0x59>
  80137e:	eb 0c                	jmp    80138c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801380:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801385:	eb 05                	jmp    80138c <fd_alloc+0x50>
  801387:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80138c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	eb 17                	jmp    8013ac <fd_alloc+0x70>
  801395:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80139a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80139f:	75 b9                	jne    80135a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013ac:	5b                   	pop    %ebx
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b5:	83 f8 1f             	cmp    $0x1f,%eax
  8013b8:	77 36                	ja     8013f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ba:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013bf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 16             	shr    $0x16,%edx
  8013c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 24                	je     8013f7 <fd_lookup+0x48>
  8013d3:	89 c2                	mov    %eax,%edx
  8013d5:	c1 ea 0c             	shr    $0xc,%edx
  8013d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	74 1a                	je     8013fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ee:	eb 13                	jmp    801403 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f5:	eb 0c                	jmp    801403 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fc:	eb 05                	jmp    801403 <fd_lookup+0x54>
  8013fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 04             	sub    $0x4,%esp
  80140c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801412:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801418:	74 0d                	je     801427 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	eb 14                	jmp    801435 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801421:	39 0a                	cmp    %ecx,(%edx)
  801423:	75 10                	jne    801435 <dev_lookup+0x30>
  801425:	eb 05                	jmp    80142c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801427:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80142c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	eb 31                	jmp    801466 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801435:	40                   	inc    %eax
  801436:	8b 14 85 68 29 80 00 	mov    0x802968(,%eax,4),%edx
  80143d:	85 d2                	test   %edx,%edx
  80143f:	75 e0                	jne    801421 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801441:	a1 04 40 80 00       	mov    0x804004,%eax
  801446:	8b 40 48             	mov    0x48(%eax),%eax
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	51                   	push   %ecx
  80144d:	50                   	push   %eax
  80144e:	68 ec 28 80 00       	push   $0x8028ec
  801453:	e8 00 ef ff ff       	call   800358 <cprintf>
	*dev = 0;
  801458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	83 ec 20             	sub    $0x20,%esp
  801473:	8b 75 08             	mov    0x8(%ebp),%esi
  801476:	8a 45 0c             	mov    0xc(%ebp),%al
  801479:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80147c:	56                   	push   %esi
  80147d:	e8 92 fe ff ff       	call   801314 <fd2num>
  801482:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801485:	89 14 24             	mov    %edx,(%esp)
  801488:	50                   	push   %eax
  801489:	e8 21 ff ff ff       	call   8013af <fd_lookup>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 05                	js     80149c <fd_close+0x31>
	    || fd != fd2)
  801497:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80149a:	74 0d                	je     8014a9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80149c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014a0:	75 48                	jne    8014ea <fd_close+0x7f>
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a7:	eb 41                	jmp    8014ea <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	ff 36                	pushl  (%esi)
  8014b2:	e8 4e ff ff ff       	call   801405 <dev_lookup>
  8014b7:	89 c3                	mov    %eax,%ebx
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 1c                	js     8014dc <fd_close+0x71>
		if (dev->dev_close)
  8014c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c3:	8b 40 10             	mov    0x10(%eax),%eax
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	74 0d                	je     8014d7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	56                   	push   %esi
  8014ce:	ff d0                	call   *%eax
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb 05                	jmp    8014dc <fd_close+0x71>
		else
			r = 0;
  8014d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	56                   	push   %esi
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 f3 f8 ff ff       	call   800dda <sys_page_unmap>
	return r;
  8014e7:	83 c4 10             	add    $0x10,%esp
}
  8014ea:	89 d8                	mov    %ebx,%eax
  8014ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	ff 75 08             	pushl  0x8(%ebp)
  801500:	e8 aa fe ff ff       	call   8013af <fd_lookup>
  801505:	83 c4 08             	add    $0x8,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 10                	js     80151c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	6a 01                	push   $0x1
  801511:	ff 75 f4             	pushl  -0xc(%ebp)
  801514:	e8 52 ff ff ff       	call   80146b <fd_close>
  801519:	83 c4 10             	add    $0x10,%esp
}
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <close_all>:

void
close_all(void)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	53                   	push   %ebx
  801522:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801525:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	53                   	push   %ebx
  80152e:	e8 c0 ff ff ff       	call   8014f3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801533:	43                   	inc    %ebx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	83 fb 20             	cmp    $0x20,%ebx
  80153a:	75 ee                	jne    80152a <close_all+0xc>
		close(i);
}
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 2c             	sub    $0x2c,%esp
  80154a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80154d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	ff 75 08             	pushl  0x8(%ebp)
  801554:	e8 56 fe ff ff       	call   8013af <fd_lookup>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	0f 88 c0 00 00 00    	js     801626 <dup+0xe5>
		return r;
	close(newfdnum);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	57                   	push   %edi
  80156a:	e8 84 ff ff ff       	call   8014f3 <close>

	newfd = INDEX2FD(newfdnum);
  80156f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801575:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801578:	83 c4 04             	add    $0x4,%esp
  80157b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157e:	e8 a1 fd ff ff       	call   801324 <fd2data>
  801583:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801585:	89 34 24             	mov    %esi,(%esp)
  801588:	e8 97 fd ff ff       	call   801324 <fd2data>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801593:	89 d8                	mov    %ebx,%eax
  801595:	c1 e8 16             	shr    $0x16,%eax
  801598:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159f:	a8 01                	test   $0x1,%al
  8015a1:	74 37                	je     8015da <dup+0x99>
  8015a3:	89 d8                	mov    %ebx,%eax
  8015a5:	c1 e8 0c             	shr    $0xc,%eax
  8015a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015af:	f6 c2 01             	test   $0x1,%dl
  8015b2:	74 26                	je     8015da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c3:	50                   	push   %eax
  8015c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015c7:	6a 00                	push   $0x0
  8015c9:	53                   	push   %ebx
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 e3 f7 ff ff       	call   800db4 <sys_page_map>
  8015d1:	89 c3                	mov    %eax,%ebx
  8015d3:	83 c4 20             	add    $0x20,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 2d                	js     801607 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	c1 ea 0c             	shr    $0xc,%edx
  8015e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015f2:	52                   	push   %edx
  8015f3:	56                   	push   %esi
  8015f4:	6a 00                	push   $0x0
  8015f6:	50                   	push   %eax
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 b6 f7 ff ff       	call   800db4 <sys_page_map>
  8015fe:	89 c3                	mov    %eax,%ebx
  801600:	83 c4 20             	add    $0x20,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	79 1d                	jns    801624 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	56                   	push   %esi
  80160b:	6a 00                	push   $0x0
  80160d:	e8 c8 f7 ff ff       	call   800dda <sys_page_unmap>
	sys_page_unmap(0, nva);
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	ff 75 d4             	pushl  -0x2c(%ebp)
  801618:	6a 00                	push   $0x0
  80161a:	e8 bb f7 ff ff       	call   800dda <sys_page_unmap>
	return r;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	eb 02                	jmp    801626 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801624:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801626:	89 d8                	mov    %ebx,%eax
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	53                   	push   %ebx
  80163f:	e8 6b fd ff ff       	call   8013af <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 67                	js     8016b2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	ff 30                	pushl  (%eax)
  801657:	e8 a9 fd ff ff       	call   801405 <dev_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 4f                	js     8016b2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	8b 50 08             	mov    0x8(%eax),%edx
  801669:	83 e2 03             	and    $0x3,%edx
  80166c:	83 fa 01             	cmp    $0x1,%edx
  80166f:	75 21                	jne    801692 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801671:	a1 04 40 80 00       	mov    0x804004,%eax
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 2d 29 80 00       	push   $0x80292d
  801683:	e8 d0 ec ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801690:	eb 20                	jmp    8016b2 <read+0x82>
	}
	if (!dev->dev_read)
  801692:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801695:	8b 52 08             	mov    0x8(%edx),%edx
  801698:	85 d2                	test   %edx,%edx
  80169a:	74 11                	je     8016ad <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	50                   	push   %eax
  8016a6:	ff d2                	call   *%edx
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	eb 05                	jmp    8016b2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	57                   	push   %edi
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c6:	85 f6                	test   %esi,%esi
  8016c8:	74 31                	je     8016fb <readn+0x44>
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	89 f2                	mov    %esi,%edx
  8016d9:	29 c2                	sub    %eax,%edx
  8016db:	52                   	push   %edx
  8016dc:	03 45 0c             	add    0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	57                   	push   %edi
  8016e1:	e8 4a ff ff ff       	call   801630 <read>
		if (m < 0)
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 17                	js     801704 <readn+0x4d>
			return m;
		if (m == 0)
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	74 11                	je     801702 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f1:	01 c3                	add    %eax,%ebx
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	39 f3                	cmp    %esi,%ebx
  8016f7:	72 db                	jb     8016d4 <readn+0x1d>
  8016f9:	eb 09                	jmp    801704 <readn+0x4d>
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801700:	eb 02                	jmp    801704 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801702:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5f                   	pop    %edi
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	53                   	push   %ebx
  801710:	83 ec 14             	sub    $0x14,%esp
  801713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	53                   	push   %ebx
  80171b:	e8 8f fc ff ff       	call   8013af <fd_lookup>
  801720:	83 c4 08             	add    $0x8,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 62                	js     801789 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801731:	ff 30                	pushl  (%eax)
  801733:	e8 cd fc ff ff       	call   801405 <dev_lookup>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 4a                	js     801789 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801746:	75 21                	jne    801769 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801748:	a1 04 40 80 00       	mov    0x804004,%eax
  80174d:	8b 40 48             	mov    0x48(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	68 49 29 80 00       	push   $0x802949
  80175a:	e8 f9 eb ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb 20                	jmp    801789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176c:	8b 52 0c             	mov    0xc(%edx),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	74 11                	je     801784 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	ff 75 10             	pushl  0x10(%ebp)
  801779:	ff 75 0c             	pushl  0xc(%ebp)
  80177c:	50                   	push   %eax
  80177d:	ff d2                	call   *%edx
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	eb 05                	jmp    801789 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <seek>:

int
seek(int fdnum, off_t offset)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	ff 75 08             	pushl  0x8(%ebp)
  80179b:	e8 0f fc ff ff       	call   8013af <fd_lookup>
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 0e                	js     8017b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 14             	sub    $0x14,%esp
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	53                   	push   %ebx
  8017c6:	e8 e4 fb ff ff       	call   8013af <fd_lookup>
  8017cb:	83 c4 08             	add    $0x8,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 5f                	js     801831 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	ff 30                	pushl  (%eax)
  8017de:	e8 22 fc ff ff       	call   801405 <dev_lookup>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 47                	js     801831 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f1:	75 21                	jne    801814 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f8:	8b 40 48             	mov    0x48(%eax),%eax
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	50                   	push   %eax
  801800:	68 0c 29 80 00       	push   $0x80290c
  801805:	e8 4e eb ff ff       	call   800358 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801812:	eb 1d                	jmp    801831 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801814:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801817:	8b 52 18             	mov    0x18(%edx),%edx
  80181a:	85 d2                	test   %edx,%edx
  80181c:	74 0e                	je     80182c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	ff 75 0c             	pushl  0xc(%ebp)
  801824:	50                   	push   %eax
  801825:	ff d2                	call   *%edx
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	eb 05                	jmp    801831 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80182c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	53                   	push   %ebx
  80183a:	83 ec 14             	sub    $0x14,%esp
  80183d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	ff 75 08             	pushl  0x8(%ebp)
  801847:	e8 63 fb ff ff       	call   8013af <fd_lookup>
  80184c:	83 c4 08             	add    $0x8,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 52                	js     8018a5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185d:	ff 30                	pushl  (%eax)
  80185f:	e8 a1 fb ff ff       	call   801405 <dev_lookup>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	78 3a                	js     8018a5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801872:	74 2c                	je     8018a0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80187e:	00 00 00 
	stat->st_isdir = 0;
  801881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801888:	00 00 00 
	stat->st_dev = dev;
  80188b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	53                   	push   %ebx
  801895:	ff 75 f0             	pushl  -0x10(%ebp)
  801898:	ff 50 14             	call   *0x14(%eax)
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	eb 05                	jmp    8018a5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	56                   	push   %esi
  8018ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	6a 00                	push   $0x0
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 78 01 00 00       	call   801a34 <open>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 1b                	js     8018e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	50                   	push   %eax
  8018cc:	e8 65 ff ff ff       	call   801836 <fstat>
  8018d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018d3:	89 1c 24             	mov    %ebx,(%esp)
  8018d6:	e8 18 fc ff ff       	call   8014f3 <close>
	return r;
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	89 f3                	mov    %esi,%ebx
}
  8018e0:	89 d8                	mov    %ebx,%eax
  8018e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    
  8018e9:	00 00                	add    %al,(%eax)
	...

008018ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	89 c3                	mov    %eax,%ebx
  8018f3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018fc:	75 12                	jne    801910 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	6a 01                	push   $0x1
  801903:	e8 ae f9 ff ff       	call   8012b6 <ipc_find_env>
  801908:	a3 00 40 80 00       	mov    %eax,0x804000
  80190d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801910:	6a 07                	push   $0x7
  801912:	68 00 50 80 00       	push   $0x805000
  801917:	53                   	push   %ebx
  801918:	ff 35 00 40 80 00    	pushl  0x804000
  80191e:	e8 3e f9 ff ff       	call   801261 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801923:	83 c4 0c             	add    $0xc,%esp
  801926:	6a 00                	push   $0x0
  801928:	56                   	push   %esi
  801929:	6a 00                	push   $0x0
  80192b:	e8 bc f8 ff ff       	call   8011ec <ipc_recv>
}
  801930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	53                   	push   %ebx
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801941:	8b 45 08             	mov    0x8(%ebp),%eax
  801944:	8b 40 0c             	mov    0xc(%eax),%eax
  801947:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80194c:	ba 00 00 00 00       	mov    $0x0,%edx
  801951:	b8 05 00 00 00       	mov    $0x5,%eax
  801956:	e8 91 ff ff ff       	call   8018ec <fsipc>
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 2c                	js     80198b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	68 00 50 80 00       	push   $0x805000
  801967:	53                   	push   %ebx
  801968:	e8 a1 ef ff ff       	call   80090e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196d:	a1 80 50 80 00       	mov    0x805080,%eax
  801972:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801978:	a1 84 50 80 00       	mov    0x805084,%eax
  80197d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	8b 40 0c             	mov    0xc(%eax),%eax
  80199c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ab:	e8 3c ff ff ff       	call   8018ec <fsipc>
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	56                   	push   %esi
  8019b6:	53                   	push   %ebx
  8019b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d5:	e8 12 ff ff ff       	call   8018ec <fsipc>
  8019da:	89 c3                	mov    %eax,%ebx
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 4b                	js     801a2b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e0:	39 c6                	cmp    %eax,%esi
  8019e2:	73 16                	jae    8019fa <devfile_read+0x48>
  8019e4:	68 78 29 80 00       	push   $0x802978
  8019e9:	68 7f 29 80 00       	push   $0x80297f
  8019ee:	6a 7d                	push   $0x7d
  8019f0:	68 94 29 80 00       	push   $0x802994
  8019f5:	e8 86 e8 ff ff       	call   800280 <_panic>
	assert(r <= PGSIZE);
  8019fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ff:	7e 16                	jle    801a17 <devfile_read+0x65>
  801a01:	68 9f 29 80 00       	push   $0x80299f
  801a06:	68 7f 29 80 00       	push   $0x80297f
  801a0b:	6a 7e                	push   $0x7e
  801a0d:	68 94 29 80 00       	push   $0x802994
  801a12:	e8 69 e8 ff ff       	call   800280 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a17:	83 ec 04             	sub    $0x4,%esp
  801a1a:	50                   	push   %eax
  801a1b:	68 00 50 80 00       	push   $0x805000
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	e8 a7 f0 ff ff       	call   800acf <memmove>
	return r;
  801a28:	83 c4 10             	add    $0x10,%esp
}
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	83 ec 1c             	sub    $0x1c,%esp
  801a3c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3f:	56                   	push   %esi
  801a40:	e8 77 ee ff ff       	call   8008bc <strlen>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4d:	7f 65                	jg     801ab4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	e8 e1 f8 ff ff       	call   80133c <fd_alloc>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 55                	js     801ab9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	56                   	push   %esi
  801a68:	68 00 50 80 00       	push   $0x805000
  801a6d:	e8 9c ee ff ff       	call   80090e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a75:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a82:	e8 65 fe ff ff       	call   8018ec <fsipc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	79 12                	jns    801aa2 <open+0x6e>
		fd_close(fd, 0);
  801a90:	83 ec 08             	sub    $0x8,%esp
  801a93:	6a 00                	push   $0x0
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	e8 ce f9 ff ff       	call   80146b <fd_close>
		return r;
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb 17                	jmp    801ab9 <open+0x85>
	}

	return fd2num(fd);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa8:	e8 67 f8 ff ff       	call   801314 <fd2num>
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	eb 05                	jmp    801ab9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ab4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ab9:	89 d8                	mov    %ebx,%eax
  801abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    
	...

00801ac4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aca:	89 c2                	mov    %eax,%edx
  801acc:	c1 ea 16             	shr    $0x16,%edx
  801acf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ad6:	f6 c2 01             	test   $0x1,%dl
  801ad9:	74 1e                	je     801af9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801adb:	c1 e8 0c             	shr    $0xc,%eax
  801ade:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ae5:	a8 01                	test   $0x1,%al
  801ae7:	74 17                	je     801b00 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae9:	c1 e8 0c             	shr    $0xc,%eax
  801aec:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801af3:	ef 
  801af4:	0f b7 c0             	movzwl %ax,%eax
  801af7:	eb 0c                	jmp    801b05 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	eb 05                	jmp    801b05 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    
	...

00801b08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	ff 75 08             	pushl  0x8(%ebp)
  801b16:	e8 09 f8 ff ff       	call   801324 <fd2data>
  801b1b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b1d:	83 c4 08             	add    $0x8,%esp
  801b20:	68 ab 29 80 00       	push   $0x8029ab
  801b25:	56                   	push   %esi
  801b26:	e8 e3 ed ff ff       	call   80090e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2e:	2b 03                	sub    (%ebx),%eax
  801b30:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b36:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b3d:	00 00 00 
	stat->st_dev = &devpipe;
  801b40:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b47:	30 80 00 
	return 0;
}
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b52:	5b                   	pop    %ebx
  801b53:	5e                   	pop    %esi
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	53                   	push   %ebx
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b60:	53                   	push   %ebx
  801b61:	6a 00                	push   $0x0
  801b63:	e8 72 f2 ff ff       	call   800dda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b68:	89 1c 24             	mov    %ebx,(%esp)
  801b6b:	e8 b4 f7 ff ff       	call   801324 <fd2data>
  801b70:	83 c4 08             	add    $0x8,%esp
  801b73:	50                   	push   %eax
  801b74:	6a 00                	push   $0x0
  801b76:	e8 5f f2 ff ff       	call   800dda <sys_page_unmap>
}
  801b7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 1c             	sub    $0x1c,%esp
  801b89:	89 c7                	mov    %eax,%edi
  801b8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b93:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	57                   	push   %edi
  801b9a:	e8 25 ff ff ff       	call   801ac4 <pageref>
  801b9f:	89 c6                	mov    %eax,%esi
  801ba1:	83 c4 04             	add    $0x4,%esp
  801ba4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba7:	e8 18 ff ff ff       	call   801ac4 <pageref>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	39 c6                	cmp    %eax,%esi
  801bb1:	0f 94 c0             	sete   %al
  801bb4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bb7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bbd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc0:	39 cb                	cmp    %ecx,%ebx
  801bc2:	75 08                	jne    801bcc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801bcc:	83 f8 01             	cmp    $0x1,%eax
  801bcf:	75 bd                	jne    801b8e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd1:	8b 42 58             	mov    0x58(%edx),%eax
  801bd4:	6a 01                	push   $0x1
  801bd6:	50                   	push   %eax
  801bd7:	53                   	push   %ebx
  801bd8:	68 b2 29 80 00       	push   $0x8029b2
  801bdd:	e8 76 e7 ff ff       	call   800358 <cprintf>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	eb a7                	jmp    801b8e <_pipeisclosed+0xe>

00801be7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 28             	sub    $0x28,%esp
  801bf0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf3:	56                   	push   %esi
  801bf4:	e8 2b f7 ff ff       	call   801324 <fd2data>
  801bf9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c02:	75 4a                	jne    801c4e <devpipe_write+0x67>
  801c04:	bf 00 00 00 00       	mov    $0x0,%edi
  801c09:	eb 56                	jmp    801c61 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c0b:	89 da                	mov    %ebx,%edx
  801c0d:	89 f0                	mov    %esi,%eax
  801c0f:	e8 6c ff ff ff       	call   801b80 <_pipeisclosed>
  801c14:	85 c0                	test   %eax,%eax
  801c16:	75 4d                	jne    801c65 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c18:	e8 4c f1 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801c20:	8b 13                	mov    (%ebx),%edx
  801c22:	83 c2 20             	add    $0x20,%edx
  801c25:	39 d0                	cmp    %edx,%eax
  801c27:	73 e2                	jae    801c0b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c31:	79 05                	jns    801c38 <devpipe_write+0x51>
  801c33:	4a                   	dec    %edx
  801c34:	83 ca e0             	or     $0xffffffe0,%edx
  801c37:	42                   	inc    %edx
  801c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801c3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c42:	40                   	inc    %eax
  801c43:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c46:	47                   	inc    %edi
  801c47:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c4a:	77 07                	ja     801c53 <devpipe_write+0x6c>
  801c4c:	eb 13                	jmp    801c61 <devpipe_write+0x7a>
  801c4e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c53:	8b 43 04             	mov    0x4(%ebx),%eax
  801c56:	8b 13                	mov    (%ebx),%edx
  801c58:	83 c2 20             	add    $0x20,%edx
  801c5b:	39 d0                	cmp    %edx,%eax
  801c5d:	73 ac                	jae    801c0b <devpipe_write+0x24>
  801c5f:	eb c8                	jmp    801c29 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c61:	89 f8                	mov    %edi,%eax
  801c63:	eb 05                	jmp    801c6a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 18             	sub    $0x18,%esp
  801c7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c7e:	57                   	push   %edi
  801c7f:	e8 a0 f6 ff ff       	call   801324 <fd2data>
  801c84:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8d:	75 44                	jne    801cd3 <devpipe_read+0x61>
  801c8f:	be 00 00 00 00       	mov    $0x0,%esi
  801c94:	eb 4f                	jmp    801ce5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c96:	89 f0                	mov    %esi,%eax
  801c98:	eb 54                	jmp    801cee <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c9a:	89 da                	mov    %ebx,%edx
  801c9c:	89 f8                	mov    %edi,%eax
  801c9e:	e8 dd fe ff ff       	call   801b80 <_pipeisclosed>
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	75 42                	jne    801ce9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ca7:	e8 bd f0 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cac:	8b 03                	mov    (%ebx),%eax
  801cae:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cb1:	74 e7                	je     801c9a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cb3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cb8:	79 05                	jns    801cbf <devpipe_read+0x4d>
  801cba:	48                   	dec    %eax
  801cbb:	83 c8 e0             	or     $0xffffffe0,%eax
  801cbe:	40                   	inc    %eax
  801cbf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801cc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cc9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ccb:	46                   	inc    %esi
  801ccc:	39 75 10             	cmp    %esi,0x10(%ebp)
  801ccf:	77 07                	ja     801cd8 <devpipe_read+0x66>
  801cd1:	eb 12                	jmp    801ce5 <devpipe_read+0x73>
  801cd3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801cd8:	8b 03                	mov    (%ebx),%eax
  801cda:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cdd:	75 d4                	jne    801cb3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cdf:	85 f6                	test   %esi,%esi
  801ce1:	75 b3                	jne    801c96 <devpipe_read+0x24>
  801ce3:	eb b5                	jmp    801c9a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	eb 05                	jmp    801cee <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	57                   	push   %edi
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	83 ec 28             	sub    $0x28,%esp
  801cff:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	e8 31 f6 ff ff       	call   80133c <fd_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 24 01 00 00    	js     801e3c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	68 07 04 00 00       	push   $0x407
  801d20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d23:	6a 00                	push   $0x0
  801d25:	e8 66 f0 ff ff       	call   800d90 <sys_page_alloc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	0f 88 05 01 00 00    	js     801e3c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d3d:	50                   	push   %eax
  801d3e:	e8 f9 f5 ff ff       	call   80133c <fd_alloc>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	0f 88 dc 00 00 00    	js     801e2c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d50:	83 ec 04             	sub    $0x4,%esp
  801d53:	68 07 04 00 00       	push   $0x407
  801d58:	ff 75 e0             	pushl  -0x20(%ebp)
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 2e f0 ff ff       	call   800d90 <sys_page_alloc>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	0f 88 bd 00 00 00    	js     801e2c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d75:	e8 aa f5 ff ff       	call   801324 <fd2data>
  801d7a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7c:	83 c4 0c             	add    $0xc,%esp
  801d7f:	68 07 04 00 00       	push   $0x407
  801d84:	50                   	push   %eax
  801d85:	6a 00                	push   $0x0
  801d87:	e8 04 f0 ff ff       	call   800d90 <sys_page_alloc>
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 83 00 00 00    	js     801e1c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	ff 75 e0             	pushl  -0x20(%ebp)
  801d9f:	e8 80 f5 ff ff       	call   801324 <fd2data>
  801da4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dab:	50                   	push   %eax
  801dac:	6a 00                	push   $0x0
  801dae:	56                   	push   %esi
  801daf:	6a 00                	push   $0x0
  801db1:	e8 fe ef ff ff       	call   800db4 <sys_page_map>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	83 c4 20             	add    $0x20,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 4f                	js     801e0e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dbf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dd4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ddd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ddf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	ff 75 e4             	pushl  -0x1c(%ebp)
  801def:	e8 20 f5 ff ff       	call   801314 <fd2num>
  801df4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801df6:	83 c4 04             	add    $0x4,%esp
  801df9:	ff 75 e0             	pushl  -0x20(%ebp)
  801dfc:	e8 13 f5 ff ff       	call   801314 <fd2num>
  801e01:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e0c:	eb 2e                	jmp    801e3c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	56                   	push   %esi
  801e12:	6a 00                	push   $0x0
  801e14:	e8 c1 ef ff ff       	call   800dda <sys_page_unmap>
  801e19:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	ff 75 e0             	pushl  -0x20(%ebp)
  801e22:	6a 00                	push   $0x0
  801e24:	e8 b1 ef ff ff       	call   800dda <sys_page_unmap>
  801e29:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 a1 ef ff ff       	call   800dda <sys_page_unmap>
  801e39:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801e3c:	89 d8                	mov    %ebx,%eax
  801e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4f:	50                   	push   %eax
  801e50:	ff 75 08             	pushl  0x8(%ebp)
  801e53:	e8 57 f5 ff ff       	call   8013af <fd_lookup>
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 18                	js     801e77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	e8 ba f4 ff ff       	call   801324 <fd2data>
	return _pipeisclosed(fd, p);
  801e6a:	89 c2                	mov    %eax,%edx
  801e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6f:	e8 0c fd ff ff       	call   801b80 <_pipeisclosed>
  801e74:	83 c4 10             	add    $0x10,%esp
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    
  801e79:	00 00                	add    %al,(%eax)
	...

00801e7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e8c:	68 ca 29 80 00       	push   $0x8029ca
  801e91:	ff 75 0c             	pushl  0xc(%ebp)
  801e94:	e8 75 ea ff ff       	call   80090e <strcpy>
	return 0;
}
  801e99:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	57                   	push   %edi
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb0:	74 45                	je     801ef7 <devcons_write+0x57>
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ebc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ec7:	83 fb 7f             	cmp    $0x7f,%ebx
  801eca:	76 05                	jbe    801ed1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ecc:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	53                   	push   %ebx
  801ed5:	03 45 0c             	add    0xc(%ebp),%eax
  801ed8:	50                   	push   %eax
  801ed9:	57                   	push   %edi
  801eda:	e8 f0 eb ff ff       	call   800acf <memmove>
		sys_cputs(buf, m);
  801edf:	83 c4 08             	add    $0x8,%esp
  801ee2:	53                   	push   %ebx
  801ee3:	57                   	push   %edi
  801ee4:	e8 f0 ed ff ff       	call   800cd9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee9:	01 de                	add    %ebx,%esi
  801eeb:	89 f0                	mov    %esi,%eax
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef3:	72 cd                	jb     801ec2 <devcons_write+0x22>
  801ef5:	eb 05                	jmp    801efc <devcons_write+0x5c>
  801ef7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801efc:	89 f0                	mov    %esi,%eax
  801efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f10:	75 07                	jne    801f19 <devcons_read+0x13>
  801f12:	eb 25                	jmp    801f39 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f14:	e8 50 ee ff ff       	call   800d69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f19:	e8 e1 ed ff ff       	call   800cff <sys_cgetc>
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	74 f2                	je     801f14 <devcons_read+0xe>
  801f22:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 1d                	js     801f45 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f28:	83 f8 04             	cmp    $0x4,%eax
  801f2b:	74 13                	je     801f40 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f30:	88 10                	mov    %dl,(%eax)
	return 1;
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	eb 0c                	jmp    801f45 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	eb 05                	jmp    801f45 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f53:	6a 01                	push   $0x1
  801f55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f58:	50                   	push   %eax
  801f59:	e8 7b ed ff ff       	call   800cd9 <sys_cputs>
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <getchar>:

int
getchar(void)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f69:	6a 01                	push   $0x1
  801f6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6e:	50                   	push   %eax
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 ba f6 ff ff       	call   801630 <read>
	if (r < 0)
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 0f                	js     801f8c <getchar+0x29>
		return r;
	if (r < 1)
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	7e 06                	jle    801f87 <getchar+0x24>
		return -E_EOF;
	return c;
  801f81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f85:	eb 05                	jmp    801f8c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f97:	50                   	push   %eax
  801f98:	ff 75 08             	pushl  0x8(%ebp)
  801f9b:	e8 0f f4 ff ff       	call   8013af <fd_lookup>
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 11                	js     801fb8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb0:	39 10                	cmp    %edx,(%eax)
  801fb2:	0f 94 c0             	sete   %al
  801fb5:	0f b6 c0             	movzbl %al,%eax
}
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <opencons>:

int
opencons(void)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc3:	50                   	push   %eax
  801fc4:	e8 73 f3 ff ff       	call   80133c <fd_alloc>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 3a                	js     80200a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 07 04 00 00       	push   $0x407
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 ae ed ff ff       	call   800d90 <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 21                	js     80200a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffe:	83 ec 0c             	sub    $0xc,%esp
  802001:	50                   	push   %eax
  802002:	e8 0d f3 ff ff       	call   801314 <fd2num>
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802012:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802019:	75 52                	jne    80206d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	6a 07                	push   $0x7
  802020:	68 00 f0 bf ee       	push   $0xeebff000
  802025:	6a 00                	push   $0x0
  802027:	e8 64 ed ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) {
  80202c:	83 c4 10             	add    $0x10,%esp
  80202f:	85 c0                	test   %eax,%eax
  802031:	79 12                	jns    802045 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802033:	50                   	push   %eax
  802034:	68 d6 29 80 00       	push   $0x8029d6
  802039:	6a 24                	push   $0x24
  80203b:	68 f1 29 80 00       	push   $0x8029f1
  802040:	e8 3b e2 ff ff       	call   800280 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802045:	83 ec 08             	sub    $0x8,%esp
  802048:	68 78 20 80 00       	push   $0x802078
  80204d:	6a 00                	push   $0x0
  80204f:	e8 ef ed ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	79 12                	jns    80206d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80205b:	50                   	push   %eax
  80205c:	68 00 2a 80 00       	push   $0x802a00
  802061:	6a 2a                	push   $0x2a
  802063:	68 f1 29 80 00       	push   $0x8029f1
  802068:	e8 13 e2 ff ff       	call   800280 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80206d:	8b 45 08             	mov    0x8(%ebp),%eax
  802070:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    
	...

00802078 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802078:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802079:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80207e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802080:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802083:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802087:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80208a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80208e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802092:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  802094:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  802097:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802098:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80209b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80209c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209d:	c3                   	ret    
	...

008020a0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	57                   	push   %edi
  8020a4:	56                   	push   %esi
  8020a5:	83 ec 10             	sub    $0x10,%esp
  8020a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ae:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020b4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020b7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	75 2e                	jne    8020ec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020be:	39 f1                	cmp    %esi,%ecx
  8020c0:	77 5a                	ja     80211c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020c2:	85 c9                	test   %ecx,%ecx
  8020c4:	75 0b                	jne    8020d1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f1                	div    %ecx
  8020cf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020d1:	31 d2                	xor    %edx,%edx
  8020d3:	89 f0                	mov    %esi,%eax
  8020d5:	f7 f1                	div    %ecx
  8020d7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020d9:	89 f8                	mov    %edi,%eax
  8020db:	f7 f1                	div    %ecx
  8020dd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    
  8020ea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020ec:	39 f0                	cmp    %esi,%eax
  8020ee:	77 1c                	ja     80210c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020f0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020f3:	83 f7 1f             	xor    $0x1f,%edi
  8020f6:	75 3c                	jne    802134 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	0f 82 90 00 00 00    	jb     802190 <__udivdi3+0xf0>
  802100:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802103:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802106:	0f 86 84 00 00 00    	jbe    802190 <__udivdi3+0xf0>
  80210c:	31 f6                	xor    %esi,%esi
  80210e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802110:	89 f8                	mov    %edi,%eax
  802112:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802114:	83 c4 10             	add    $0x10,%esp
  802117:	5e                   	pop    %esi
  802118:	5f                   	pop    %edi
  802119:	c9                   	leave  
  80211a:	c3                   	ret    
  80211b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	89 f8                	mov    %edi,%eax
  802120:	f7 f1                	div    %ecx
  802122:	89 c7                	mov    %eax,%edi
  802124:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802126:	89 f8                	mov    %edi,%eax
  802128:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	5e                   	pop    %esi
  80212e:	5f                   	pop    %edi
  80212f:	c9                   	leave  
  802130:	c3                   	ret    
  802131:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802134:	89 f9                	mov    %edi,%ecx
  802136:	d3 e0                	shl    %cl,%eax
  802138:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80213b:	b8 20 00 00 00       	mov    $0x20,%eax
  802140:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802142:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802145:	88 c1                	mov    %al,%cl
  802147:	d3 ea                	shr    %cl,%edx
  802149:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80214c:	09 ca                	or     %ecx,%edx
  80214e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802151:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802154:	89 f9                	mov    %edi,%ecx
  802156:	d3 e2                	shl    %cl,%edx
  802158:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80215b:	89 f2                	mov    %esi,%edx
  80215d:	88 c1                	mov    %al,%cl
  80215f:	d3 ea                	shr    %cl,%edx
  802161:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802164:	89 f2                	mov    %esi,%edx
  802166:	89 f9                	mov    %edi,%ecx
  802168:	d3 e2                	shl    %cl,%edx
  80216a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80216d:	88 c1                	mov    %al,%cl
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802173:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802176:	89 f0                	mov    %esi,%eax
  802178:	89 ca                	mov    %ecx,%edx
  80217a:	f7 75 ec             	divl   -0x14(%ebp)
  80217d:	89 d1                	mov    %edx,%ecx
  80217f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802181:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802184:	39 d1                	cmp    %edx,%ecx
  802186:	72 28                	jb     8021b0 <__udivdi3+0x110>
  802188:	74 1a                	je     8021a4 <__udivdi3+0x104>
  80218a:	89 f7                	mov    %esi,%edi
  80218c:	31 f6                	xor    %esi,%esi
  80218e:	eb 80                	jmp    802110 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802190:	31 f6                	xor    %esi,%esi
  802192:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802197:	89 f8                	mov    %edi,%eax
  802199:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    
  8021a2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021a7:	89 f9                	mov    %edi,%ecx
  8021a9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ab:	39 c2                	cmp    %eax,%edx
  8021ad:	73 db                	jae    80218a <__udivdi3+0xea>
  8021af:	90                   	nop
		{
		  q0--;
  8021b0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021b3:	31 f6                	xor    %esi,%esi
  8021b5:	e9 56 ff ff ff       	jmp    802110 <__udivdi3+0x70>
	...

008021bc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	57                   	push   %edi
  8021c0:	56                   	push   %esi
  8021c1:	83 ec 20             	sub    $0x20,%esp
  8021c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021d0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021d9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021db:	85 ff                	test   %edi,%edi
  8021dd:	75 15                	jne    8021f4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021df:	39 f1                	cmp    %esi,%ecx
  8021e1:	0f 86 99 00 00 00    	jbe    802280 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021e7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021ed:	83 c4 20             	add    $0x20,%esp
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	c9                   	leave  
  8021f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021f4:	39 f7                	cmp    %esi,%edi
  8021f6:	0f 87 a4 00 00 00    	ja     8022a0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021fc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021ff:	83 f0 1f             	xor    $0x1f,%eax
  802202:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802205:	0f 84 a1 00 00 00    	je     8022ac <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80220b:	89 f8                	mov    %edi,%eax
  80220d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802210:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802212:	bf 20 00 00 00       	mov    $0x20,%edi
  802217:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80221a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80221d:	89 f9                	mov    %edi,%ecx
  80221f:	d3 ea                	shr    %cl,%edx
  802221:	09 c2                	or     %eax,%edx
  802223:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802226:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802229:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802231:	89 f2                	mov    %esi,%edx
  802233:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802235:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802238:	d3 e0                	shl    %cl,%eax
  80223a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80223d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802240:	89 f9                	mov    %edi,%ecx
  802242:	d3 e8                	shr    %cl,%eax
  802244:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802246:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802248:	89 f2                	mov    %esi,%edx
  80224a:	f7 75 f0             	divl   -0x10(%ebp)
  80224d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80224f:	f7 65 f4             	mull   -0xc(%ebp)
  802252:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802255:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802257:	39 d6                	cmp    %edx,%esi
  802259:	72 71                	jb     8022cc <__umoddi3+0x110>
  80225b:	74 7f                	je     8022dc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80225d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802260:	29 c8                	sub    %ecx,%eax
  802262:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802264:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 f2                	mov    %esi,%edx
  80226b:	89 f9                	mov    %edi,%ecx
  80226d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80226f:	09 d0                	or     %edx,%eax
  802271:	89 f2                	mov    %esi,%edx
  802273:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802276:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802278:	83 c4 20             	add    $0x20,%esp
  80227b:	5e                   	pop    %esi
  80227c:	5f                   	pop    %edi
  80227d:	c9                   	leave  
  80227e:	c3                   	ret    
  80227f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802280:	85 c9                	test   %ecx,%ecx
  802282:	75 0b                	jne    80228f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802284:	b8 01 00 00 00       	mov    $0x1,%eax
  802289:	31 d2                	xor    %edx,%edx
  80228b:	f7 f1                	div    %ecx
  80228d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80228f:	89 f0                	mov    %esi,%eax
  802291:	31 d2                	xor    %edx,%edx
  802293:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802298:	f7 f1                	div    %ecx
  80229a:	e9 4a ff ff ff       	jmp    8021e9 <__umoddi3+0x2d>
  80229f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a2:	83 c4 20             	add    $0x20,%esp
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	c9                   	leave  
  8022a8:	c3                   	ret    
  8022a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022ac:	39 f7                	cmp    %esi,%edi
  8022ae:	72 05                	jb     8022b5 <__umoddi3+0xf9>
  8022b0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022b3:	77 0c                	ja     8022c1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022b5:	89 f2                	mov    %esi,%edx
  8022b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ba:	29 c8                	sub    %ecx,%eax
  8022bc:	19 fa                	sbb    %edi,%edx
  8022be:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022c4:	83 c4 20             	add    $0x20,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022cc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022cf:	89 c1                	mov    %eax,%ecx
  8022d1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022d4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022d7:	eb 84                	jmp    80225d <__umoddi3+0xa1>
  8022d9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022dc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022df:	72 eb                	jb     8022cc <__umoddi3+0x110>
  8022e1:	89 f2                	mov    %esi,%edx
  8022e3:	e9 75 ff ff ff       	jmp    80225d <__umoddi3+0xa1>
