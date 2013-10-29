
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
  80004c:	e8 b1 1c 00 00       	call   801d02 <pipe>
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
  800091:	e8 49 14 00 00       	call   8014df <close>
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
  8000a4:	e8 a9 1d 00 00       	call   801e52 <pipeisclosed>
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
  8000dc:	e8 c7 10 00 00       	call   8011a8 <ipc_recv>
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
  80013f:	e8 e9 13 00 00       	call   80152d <dup>
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
  80015d:	e8 cb 13 00 00       	call   80152d <dup>
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
  800180:	e8 cd 1c 00 00       	call   801e52 <pipeisclosed>
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
  8001aa:	e8 ec 11 00 00       	call   80139b <fd_lookup>
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
  8001ce:	e8 3d 11 00 00       	call   801310 <fd2data>
	if (pageref(va) != 3+1)
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 f5 18 00 00       	call   801ad0 <pageref>
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
  80026a:	e8 9b 12 00 00       	call   80150a <close_all>
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
  8003c0:	e8 e7 1c 00 00       	call   8020ac <__udivdi3>
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
  8003fc:	e8 c7 1d 00 00       	call   8021c8 <__umoddi3>
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
  80061a:	68 ad 29 80 00       	push   $0x8029ad
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
  800fb0:	e8 63 10 00 00       	call   802018 <set_pgfault_handler>
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
  800fd0:	6a 7b                	push   $0x7b
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
  801002:	e9 7b 01 00 00       	jmp    801182 <fork+0x1e0>
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
  80101a:	0f 84 cd 00 00 00    	je     8010ed <fork+0x14b>
  801020:	89 d8                	mov    %ebx,%eax
  801022:	c1 e8 0c             	shr    $0xc,%eax
  801025:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102c:	f6 c2 01             	test   $0x1,%dl
  80102f:	0f 84 b8 00 00 00    	je     8010ed <fork+0x14b>
  801035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103c:	f6 c2 04             	test   $0x4,%dl
  80103f:	0f 84 a8 00 00 00    	je     8010ed <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801045:	89 c6                	mov    %eax,%esi
  801047:	c1 e6 0c             	shl    $0xc,%esi
  80104a:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801050:	0f 84 97 00 00 00    	je     8010ed <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801056:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105d:	f6 c2 02             	test   $0x2,%dl
  801060:	75 0c                	jne    80106e <fork+0xcc>
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	f6 c4 08             	test   $0x8,%ah
  80106c:	74 57                	je     8010c5 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	68 05 08 00 00       	push   $0x805
  801076:	56                   	push   %esi
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 34 fd ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 12                	jns    801099 <fork+0xf7>
  801087:	50                   	push   %eax
  801088:	68 dc 27 80 00       	push   $0x8027dc
  80108d:	6a 55                	push   $0x55
  80108f:	68 90 28 80 00       	push   $0x802890
  801094:	e8 e7 f1 ff ff       	call   800280 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	68 05 08 00 00       	push   $0x805
  8010a1:	56                   	push   %esi
  8010a2:	6a 00                	push   $0x0
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 08 fd ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 3a                	jns    8010ed <fork+0x14b>
  8010b3:	50                   	push   %eax
  8010b4:	68 dc 27 80 00       	push   $0x8027dc
  8010b9:	6a 58                	push   $0x58
  8010bb:	68 90 28 80 00       	push   $0x802890
  8010c0:	e8 bb f1 ff ff       	call   800280 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	6a 05                	push   $0x5
  8010ca:	56                   	push   %esi
  8010cb:	57                   	push   %edi
  8010cc:	56                   	push   %esi
  8010cd:	6a 00                	push   $0x0
  8010cf:	e8 e0 fc ff ff       	call   800db4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010d4:	83 c4 20             	add    $0x20,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 12                	jns    8010ed <fork+0x14b>
  8010db:	50                   	push   %eax
  8010dc:	68 dc 27 80 00       	push   $0x8027dc
  8010e1:	6a 5c                	push   $0x5c
  8010e3:	68 90 28 80 00       	push   $0x802890
  8010e8:	e8 93 f1 ff ff       	call   800280 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8010ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f3:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010f9:	0f 85 0d ff ff ff    	jne    80100c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	6a 07                	push   $0x7
  801104:	68 00 f0 bf ee       	push   $0xeebff000
  801109:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110c:	e8 7f fc ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	79 15                	jns    80112d <fork+0x18b>
  801118:	50                   	push   %eax
  801119:	68 00 28 80 00       	push   $0x802800
  80111e:	68 90 00 00 00       	push   $0x90
  801123:	68 90 28 80 00       	push   $0x802890
  801128:	e8 53 f1 ff ff       	call   800280 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	68 84 20 80 00       	push   $0x802084
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	e8 06 fd ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	79 15                	jns    801159 <fork+0x1b7>
  801144:	50                   	push   %eax
  801145:	68 38 28 80 00       	push   $0x802838
  80114a:	68 95 00 00 00       	push   $0x95
  80114f:	68 90 28 80 00       	push   $0x802890
  801154:	e8 27 f1 ff ff       	call   800280 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	6a 02                	push   $0x2
  80115e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801161:	e8 97 fc ff ff       	call   800dfd <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 15                	jns    801182 <fork+0x1e0>
  80116d:	50                   	push   %eax
  80116e:	68 5c 28 80 00       	push   $0x80285c
  801173:	68 a0 00 00 00       	push   $0xa0
  801178:	68 90 28 80 00       	push   $0x802890
  80117d:	e8 fe f0 ff ff       	call   800280 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <sfork>:

// Challenge!
int
sfork(void)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801193:	68 b8 28 80 00       	push   $0x8028b8
  801198:	68 ad 00 00 00       	push   $0xad
  80119d:	68 90 28 80 00       	push   $0x802890
  8011a2:	e8 d9 f0 ff ff       	call   800280 <_panic>
	...

008011a8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	57                   	push   %edi
  8011bd:	68 ce 28 80 00       	push   $0x8028ce
  8011c2:	e8 91 f1 ff ff       	call   800358 <cprintf>
	int r;
	if (pg != NULL) {
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 db                	test   %ebx,%ebx
  8011cc:	74 28                	je     8011f6 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	68 de 28 80 00       	push   $0x8028de
  8011d6:	e8 7d f1 ff ff       	call   800358 <cprintf>
		r = sys_ipc_recv(pg);
  8011db:	89 1c 24             	mov    %ebx,(%esp)
  8011de:	e8 a8 fc ff ff       	call   800e8b <sys_ipc_recv>
  8011e3:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  8011e5:	c7 04 24 e5 28 80 00 	movl   $0x8028e5,(%esp)
  8011ec:	e8 67 f1 ff ff       	call   800358 <cprintf>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	eb 12                	jmp    801208 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	68 00 00 c0 ee       	push   $0xeec00000
  8011fe:	e8 88 fc ff ff       	call   800e8b <sys_ipc_recv>
  801203:	89 c3                	mov    %eax,%ebx
  801205:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801208:	85 db                	test   %ebx,%ebx
  80120a:	75 26                	jne    801232 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80120c:	85 ff                	test   %edi,%edi
  80120e:	74 0a                	je     80121a <ipc_recv+0x72>
  801210:	a1 04 40 80 00       	mov    0x804004,%eax
  801215:	8b 40 74             	mov    0x74(%eax),%eax
  801218:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80121a:	85 f6                	test   %esi,%esi
  80121c:	74 0a                	je     801228 <ipc_recv+0x80>
  80121e:	a1 04 40 80 00       	mov    0x804004,%eax
  801223:	8b 40 78             	mov    0x78(%eax),%eax
  801226:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801228:	a1 04 40 80 00       	mov    0x804004,%eax
  80122d:	8b 58 70             	mov    0x70(%eax),%ebx
  801230:	eb 14                	jmp    801246 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801232:	85 ff                	test   %edi,%edi
  801234:	74 06                	je     80123c <ipc_recv+0x94>
  801236:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  80123c:	85 f6                	test   %esi,%esi
  80123e:	74 06                	je     801246 <ipc_recv+0x9e>
  801240:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801246:	89 d8                	mov    %ebx,%eax
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80125c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801262:	85 db                	test   %ebx,%ebx
  801264:	75 25                	jne    80128b <ipc_send+0x3b>
  801266:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80126b:	eb 1e                	jmp    80128b <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80126d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801270:	75 07                	jne    801279 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801272:	e8 f2 fa ff ff       	call   800d69 <sys_yield>
  801277:	eb 12                	jmp    80128b <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801279:	50                   	push   %eax
  80127a:	68 eb 28 80 00       	push   $0x8028eb
  80127f:	6a 45                	push   $0x45
  801281:	68 fe 28 80 00       	push   $0x8028fe
  801286:	e8 f5 ef ff ff       	call   800280 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	57                   	push   %edi
  80128e:	ff 75 08             	pushl  0x8(%ebp)
  801291:	e8 d0 fb ff ff       	call   800e66 <sys_ipc_try_send>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	75 d0                	jne    80126d <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8012ac:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8012b2:	74 22                	je     8012d6 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012b4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8012b9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 e2 07             	shl    $0x7,%edx
  8012c5:	29 ca                	sub    %ecx,%edx
  8012c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012cd:	8b 52 50             	mov    0x50(%edx),%edx
  8012d0:	39 da                	cmp    %ebx,%edx
  8012d2:	75 1d                	jne    8012f1 <ipc_find_env+0x4c>
  8012d4:	eb 05                	jmp    8012db <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8012db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012e2:	c1 e0 07             	shl    $0x7,%eax
  8012e5:	29 d0                	sub    %edx,%eax
  8012e7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8012ec:	8b 40 40             	mov    0x40(%eax),%eax
  8012ef:	eb 0c                	jmp    8012fd <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012f1:	40                   	inc    %eax
  8012f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012f7:	75 c0                	jne    8012b9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8012fd:	5b                   	pop    %ebx
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	05 00 00 00 30       	add    $0x30000000,%eax
  80130b:	c1 e8 0c             	shr    $0xc,%eax
}
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 e5 ff ff ff       	call   801300 <fd2num>
  80131b:	83 c4 04             	add    $0x4,%esp
  80131e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801323:	c1 e0 0c             	shl    $0xc,%eax
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80132f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801334:	a8 01                	test   $0x1,%al
  801336:	74 34                	je     80136c <fd_alloc+0x44>
  801338:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80133d:	a8 01                	test   $0x1,%al
  80133f:	74 32                	je     801373 <fd_alloc+0x4b>
  801341:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801346:	89 c1                	mov    %eax,%ecx
  801348:	89 c2                	mov    %eax,%edx
  80134a:	c1 ea 16             	shr    $0x16,%edx
  80134d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801354:	f6 c2 01             	test   $0x1,%dl
  801357:	74 1f                	je     801378 <fd_alloc+0x50>
  801359:	89 c2                	mov    %eax,%edx
  80135b:	c1 ea 0c             	shr    $0xc,%edx
  80135e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801365:	f6 c2 01             	test   $0x1,%dl
  801368:	75 17                	jne    801381 <fd_alloc+0x59>
  80136a:	eb 0c                	jmp    801378 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80136c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801371:	eb 05                	jmp    801378 <fd_alloc+0x50>
  801373:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801378:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
  80137f:	eb 17                	jmp    801398 <fd_alloc+0x70>
  801381:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801386:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80138b:	75 b9                	jne    801346 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80138d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801393:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801398:	5b                   	pop    %ebx
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a1:	83 f8 1f             	cmp    $0x1f,%eax
  8013a4:	77 36                	ja     8013dc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013ab:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 16             	shr    $0x16,%edx
  8013b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	74 24                	je     8013e3 <fd_lookup+0x48>
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	c1 ea 0c             	shr    $0xc,%edx
  8013c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 1a                	je     8013ea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	eb 13                	jmp    8013ef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e1:	eb 0c                	jmp    8013ef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e8:	eb 05                	jmp    8013ef <fd_lookup+0x54>
  8013ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013fe:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801404:	74 0d                	je     801413 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
  80140b:	eb 14                	jmp    801421 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80140d:	39 0a                	cmp    %ecx,(%edx)
  80140f:	75 10                	jne    801421 <dev_lookup+0x30>
  801411:	eb 05                	jmp    801418 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801413:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801418:	89 13                	mov    %edx,(%ebx)
			return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	eb 31                	jmp    801452 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801421:	40                   	inc    %eax
  801422:	8b 14 85 84 29 80 00 	mov    0x802984(,%eax,4),%edx
  801429:	85 d2                	test   %edx,%edx
  80142b:	75 e0                	jne    80140d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80142d:	a1 04 40 80 00       	mov    0x804004,%eax
  801432:	8b 40 48             	mov    0x48(%eax),%eax
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	51                   	push   %ecx
  801439:	50                   	push   %eax
  80143a:	68 08 29 80 00       	push   $0x802908
  80143f:	e8 14 ef ff ff       	call   800358 <cprintf>
	*dev = 0;
  801444:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	83 ec 20             	sub    $0x20,%esp
  80145f:	8b 75 08             	mov    0x8(%ebp),%esi
  801462:	8a 45 0c             	mov    0xc(%ebp),%al
  801465:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801468:	56                   	push   %esi
  801469:	e8 92 fe ff ff       	call   801300 <fd2num>
  80146e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801471:	89 14 24             	mov    %edx,(%esp)
  801474:	50                   	push   %eax
  801475:	e8 21 ff ff ff       	call   80139b <fd_lookup>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 05                	js     801488 <fd_close+0x31>
	    || fd != fd2)
  801483:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801486:	74 0d                	je     801495 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801488:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80148c:	75 48                	jne    8014d6 <fd_close+0x7f>
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801493:	eb 41                	jmp    8014d6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	ff 36                	pushl  (%esi)
  80149e:	e8 4e ff ff ff       	call   8013f1 <dev_lookup>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 1c                	js     8014c8 <fd_close+0x71>
		if (dev->dev_close)
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	8b 40 10             	mov    0x10(%eax),%eax
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	74 0d                	je     8014c3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	56                   	push   %esi
  8014ba:	ff d0                	call   *%eax
  8014bc:	89 c3                	mov    %eax,%ebx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb 05                	jmp    8014c8 <fd_close+0x71>
		else
			r = 0;
  8014c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	56                   	push   %esi
  8014cc:	6a 00                	push   $0x0
  8014ce:	e8 07 f9 ff ff       	call   800dda <sys_page_unmap>
	return r;
  8014d3:	83 c4 10             	add    $0x10,%esp
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	ff 75 08             	pushl  0x8(%ebp)
  8014ec:	e8 aa fe ff ff       	call   80139b <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 10                	js     801508 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	6a 01                	push   $0x1
  8014fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801500:	e8 52 ff ff ff       	call   801457 <fd_close>
  801505:	83 c4 10             	add    $0x10,%esp
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <close_all>:

void
close_all(void)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801511:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	53                   	push   %ebx
  80151a:	e8 c0 ff ff ff       	call   8014df <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80151f:	43                   	inc    %ebx
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	83 fb 20             	cmp    $0x20,%ebx
  801526:	75 ee                	jne    801516 <close_all+0xc>
		close(i);
}
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	57                   	push   %edi
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 2c             	sub    $0x2c,%esp
  801536:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801539:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	ff 75 08             	pushl  0x8(%ebp)
  801540:	e8 56 fe ff ff       	call   80139b <fd_lookup>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	0f 88 c0 00 00 00    	js     801612 <dup+0xe5>
		return r;
	close(newfdnum);
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	57                   	push   %edi
  801556:	e8 84 ff ff ff       	call   8014df <close>

	newfd = INDEX2FD(newfdnum);
  80155b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801561:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801564:	83 c4 04             	add    $0x4,%esp
  801567:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156a:	e8 a1 fd ff ff       	call   801310 <fd2data>
  80156f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801571:	89 34 24             	mov    %esi,(%esp)
  801574:	e8 97 fd ff ff       	call   801310 <fd2data>
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80157f:	89 d8                	mov    %ebx,%eax
  801581:	c1 e8 16             	shr    $0x16,%eax
  801584:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80158b:	a8 01                	test   $0x1,%al
  80158d:	74 37                	je     8015c6 <dup+0x99>
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	c1 e8 0c             	shr    $0xc,%eax
  801594:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80159b:	f6 c2 01             	test   $0x1,%dl
  80159e:	74 26                	je     8015c6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8015af:	50                   	push   %eax
  8015b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b3:	6a 00                	push   $0x0
  8015b5:	53                   	push   %ebx
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 f7 f7 ff ff       	call   800db4 <sys_page_map>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 20             	add    $0x20,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 2d                	js     8015f3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c9:	89 c2                	mov    %eax,%edx
  8015cb:	c1 ea 0c             	shr    $0xc,%edx
  8015ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015de:	52                   	push   %edx
  8015df:	56                   	push   %esi
  8015e0:	6a 00                	push   $0x0
  8015e2:	50                   	push   %eax
  8015e3:	6a 00                	push   $0x0
  8015e5:	e8 ca f7 ff ff       	call   800db4 <sys_page_map>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 20             	add    $0x20,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	79 1d                	jns    801610 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	56                   	push   %esi
  8015f7:	6a 00                	push   $0x0
  8015f9:	e8 dc f7 ff ff       	call   800dda <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	ff 75 d4             	pushl  -0x2c(%ebp)
  801604:	6a 00                	push   $0x0
  801606:	e8 cf f7 ff ff       	call   800dda <sys_page_unmap>
	return r;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 02                	jmp    801612 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801610:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801612:	89 d8                	mov    %ebx,%eax
  801614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5f                   	pop    %edi
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 14             	sub    $0x14,%esp
  801623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801626:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	53                   	push   %ebx
  80162b:	e8 6b fd ff ff       	call   80139b <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 67                	js     80169e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	ff 30                	pushl  (%eax)
  801643:	e8 a9 fd ff ff       	call   8013f1 <dev_lookup>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 4f                	js     80169e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	8b 50 08             	mov    0x8(%eax),%edx
  801655:	83 e2 03             	and    $0x3,%edx
  801658:	83 fa 01             	cmp    $0x1,%edx
  80165b:	75 21                	jne    80167e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80165d:	a1 04 40 80 00       	mov    0x804004,%eax
  801662:	8b 40 48             	mov    0x48(%eax),%eax
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	53                   	push   %ebx
  801669:	50                   	push   %eax
  80166a:	68 49 29 80 00       	push   $0x802949
  80166f:	e8 e4 ec ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167c:	eb 20                	jmp    80169e <read+0x82>
	}
	if (!dev->dev_read)
  80167e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801681:	8b 52 08             	mov    0x8(%edx),%edx
  801684:	85 d2                	test   %edx,%edx
  801686:	74 11                	je     801699 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	ff 75 10             	pushl  0x10(%ebp)
  80168e:	ff 75 0c             	pushl  0xc(%ebp)
  801691:	50                   	push   %eax
  801692:	ff d2                	call   *%edx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb 05                	jmp    80169e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801699:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	57                   	push   %edi
  8016a7:	56                   	push   %esi
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b2:	85 f6                	test   %esi,%esi
  8016b4:	74 31                	je     8016e7 <readn+0x44>
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016c0:	83 ec 04             	sub    $0x4,%esp
  8016c3:	89 f2                	mov    %esi,%edx
  8016c5:	29 c2                	sub    %eax,%edx
  8016c7:	52                   	push   %edx
  8016c8:	03 45 0c             	add    0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	57                   	push   %edi
  8016cd:	e8 4a ff ff ff       	call   80161c <read>
		if (m < 0)
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 17                	js     8016f0 <readn+0x4d>
			return m;
		if (m == 0)
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	74 11                	je     8016ee <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016dd:	01 c3                	add    %eax,%ebx
  8016df:	89 d8                	mov    %ebx,%eax
  8016e1:	39 f3                	cmp    %esi,%ebx
  8016e3:	72 db                	jb     8016c0 <readn+0x1d>
  8016e5:	eb 09                	jmp    8016f0 <readn+0x4d>
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ec:	eb 02                	jmp    8016f0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016ee:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 14             	sub    $0x14,%esp
  8016ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801702:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	53                   	push   %ebx
  801707:	e8 8f fc ff ff       	call   80139b <fd_lookup>
  80170c:	83 c4 08             	add    $0x8,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 62                	js     801775 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	ff 30                	pushl  (%eax)
  80171f:	e8 cd fc ff ff       	call   8013f1 <dev_lookup>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 4a                	js     801775 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80172b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801732:	75 21                	jne    801755 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801734:	a1 04 40 80 00       	mov    0x804004,%eax
  801739:	8b 40 48             	mov    0x48(%eax),%eax
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	53                   	push   %ebx
  801740:	50                   	push   %eax
  801741:	68 65 29 80 00       	push   $0x802965
  801746:	e8 0d ec ff ff       	call   800358 <cprintf>
		return -E_INVAL;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801753:	eb 20                	jmp    801775 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801755:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801758:	8b 52 0c             	mov    0xc(%edx),%edx
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 11                	je     801770 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80175f:	83 ec 04             	sub    $0x4,%esp
  801762:	ff 75 10             	pushl  0x10(%ebp)
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	50                   	push   %eax
  801769:	ff d2                	call   *%edx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	eb 05                	jmp    801775 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <seek>:

int
seek(int fdnum, off_t offset)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801780:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801783:	50                   	push   %eax
  801784:	ff 75 08             	pushl  0x8(%ebp)
  801787:	e8 0f fc ff ff       	call   80139b <fd_lookup>
  80178c:	83 c4 08             	add    $0x8,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 0e                	js     8017a1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801793:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801796:	8b 55 0c             	mov    0xc(%ebp),%edx
  801799:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80179c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    

008017a3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 14             	sub    $0x14,%esp
  8017aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	53                   	push   %ebx
  8017b2:	e8 e4 fb ff ff       	call   80139b <fd_lookup>
  8017b7:	83 c4 08             	add    $0x8,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 5f                	js     80181d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c8:	ff 30                	pushl  (%eax)
  8017ca:	e8 22 fc ff ff       	call   8013f1 <dev_lookup>
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 47                	js     80181d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017dd:	75 21                	jne    801800 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017df:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017e4:	8b 40 48             	mov    0x48(%eax),%eax
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	53                   	push   %ebx
  8017eb:	50                   	push   %eax
  8017ec:	68 28 29 80 00       	push   $0x802928
  8017f1:	e8 62 eb ff ff       	call   800358 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fe:	eb 1d                	jmp    80181d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801800:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801803:	8b 52 18             	mov    0x18(%edx),%edx
  801806:	85 d2                	test   %edx,%edx
  801808:	74 0e                	je     801818 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	50                   	push   %eax
  801811:	ff d2                	call   *%edx
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	eb 05                	jmp    80181d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801818:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 14             	sub    $0x14,%esp
  801829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182f:	50                   	push   %eax
  801830:	ff 75 08             	pushl  0x8(%ebp)
  801833:	e8 63 fb ff ff       	call   80139b <fd_lookup>
  801838:	83 c4 08             	add    $0x8,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 52                	js     801891 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801845:	50                   	push   %eax
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	ff 30                	pushl  (%eax)
  80184b:	e8 a1 fb ff ff       	call   8013f1 <dev_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 3a                	js     801891 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80185e:	74 2c                	je     80188c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801860:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801863:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80186a:	00 00 00 
	stat->st_isdir = 0;
  80186d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801874:	00 00 00 
	stat->st_dev = dev;
  801877:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	53                   	push   %ebx
  801881:	ff 75 f0             	pushl  -0x10(%ebp)
  801884:	ff 50 14             	call   *0x14(%eax)
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 05                	jmp    801891 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80188c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	6a 00                	push   $0x0
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 8b 01 00 00       	call   801a33 <open>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 1b                	js     8018cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	50                   	push   %eax
  8018b8:	e8 65 ff ff ff       	call   801822 <fstat>
  8018bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8018bf:	89 1c 24             	mov    %ebx,(%esp)
  8018c2:	e8 18 fc ff ff       	call   8014df <close>
	return r;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	89 f3                	mov    %esi,%ebx
}
  8018cc:	89 d8                	mov    %ebx,%eax
  8018ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    
  8018d5:	00 00                	add    %al,(%eax)
	...

008018d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018e8:	75 12                	jne    8018fc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	6a 01                	push   $0x1
  8018ef:	e8 b1 f9 ff ff       	call   8012a5 <ipc_find_env>
  8018f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018fc:	6a 07                	push   $0x7
  8018fe:	68 00 50 80 00       	push   $0x805000
  801903:	53                   	push   %ebx
  801904:	ff 35 00 40 80 00    	pushl  0x804000
  80190a:	e8 41 f9 ff ff       	call   801250 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80190f:	83 c4 0c             	add    $0xc,%esp
  801912:	6a 00                	push   $0x0
  801914:	56                   	push   %esi
  801915:	6a 00                	push   $0x0
  801917:	e8 8c f8 ff ff       	call   8011a8 <ipc_recv>
}
  80191c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191f:	5b                   	pop    %ebx
  801920:	5e                   	pop    %esi
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 04             	sub    $0x4,%esp
  80192a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 40 0c             	mov    0xc(%eax),%eax
  801933:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801938:	ba 00 00 00 00       	mov    $0x0,%edx
  80193d:	b8 05 00 00 00       	mov    $0x5,%eax
  801942:	e8 91 ff ff ff       	call   8018d8 <fsipc>
  801947:	85 c0                	test   %eax,%eax
  801949:	78 39                	js     801984 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	68 e5 28 80 00       	push   $0x8028e5
  801953:	e8 00 ea ff ff       	call   800358 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801958:	83 c4 08             	add    $0x8,%esp
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	53                   	push   %ebx
  801961:	e8 a8 ef ff ff       	call   80090e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801966:	a1 80 50 80 00       	mov    0x805080,%eax
  80196b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801971:	a1 84 50 80 00       	mov    0x805084,%eax
  801976:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	8b 40 0c             	mov    0xc(%eax),%eax
  801995:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199a:	ba 00 00 00 00       	mov    $0x0,%edx
  80199f:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a4:	e8 2f ff ff ff       	call   8018d8 <fsipc>
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
  8019b0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ce:	e8 05 ff ff ff       	call   8018d8 <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 51                	js     801a2a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8019d9:	39 c6                	cmp    %eax,%esi
  8019db:	73 19                	jae    8019f6 <devfile_read+0x4b>
  8019dd:	68 94 29 80 00       	push   $0x802994
  8019e2:	68 9b 29 80 00       	push   $0x80299b
  8019e7:	68 80 00 00 00       	push   $0x80
  8019ec:	68 b0 29 80 00       	push   $0x8029b0
  8019f1:	e8 8a e8 ff ff       	call   800280 <_panic>
	assert(r <= PGSIZE);
  8019f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019fb:	7e 19                	jle    801a16 <devfile_read+0x6b>
  8019fd:	68 bb 29 80 00       	push   $0x8029bb
  801a02:	68 9b 29 80 00       	push   $0x80299b
  801a07:	68 81 00 00 00       	push   $0x81
  801a0c:	68 b0 29 80 00       	push   $0x8029b0
  801a11:	e8 6a e8 ff ff       	call   800280 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a16:	83 ec 04             	sub    $0x4,%esp
  801a19:	50                   	push   %eax
  801a1a:	68 00 50 80 00       	push   $0x805000
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	e8 a8 f0 ff ff       	call   800acf <memmove>
	return r;
  801a27:	83 c4 10             	add    $0x10,%esp
}
  801a2a:	89 d8                	mov    %ebx,%eax
  801a2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	83 ec 1c             	sub    $0x1c,%esp
  801a3b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3e:	56                   	push   %esi
  801a3f:	e8 78 ee ff ff       	call   8008bc <strlen>
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4c:	7f 72                	jg     801ac0 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	e8 ce f8 ff ff       	call   801328 <fd_alloc>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 62                	js     801ac5 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	56                   	push   %esi
  801a67:	68 00 50 80 00       	push   $0x805000
  801a6c:	e8 9d ee ff ff       	call   80090e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a74:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a81:	e8 52 fe ff ff       	call   8018d8 <fsipc>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	79 12                	jns    801aa1 <open+0x6e>
		fd_close(fd, 0);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	6a 00                	push   $0x0
  801a94:	ff 75 f4             	pushl  -0xc(%ebp)
  801a97:	e8 bb f9 ff ff       	call   801457 <fd_close>
		return r;
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb 24                	jmp    801ac5 <open+0x92>
	}


	cprintf("OPEN\n");
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	68 c7 29 80 00       	push   $0x8029c7
  801aa9:	e8 aa e8 ff ff       	call   800358 <cprintf>

	return fd2num(fd);
  801aae:	83 c4 04             	add    $0x4,%esp
  801ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab4:	e8 47 f8 ff ff       	call   801300 <fd2num>
  801ab9:	89 c3                	mov    %eax,%ebx
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	eb 05                	jmp    801ac5 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801ac5:	89 d8                	mov    %ebx,%eax
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    
	...

00801ad0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad6:	89 c2                	mov    %eax,%edx
  801ad8:	c1 ea 16             	shr    $0x16,%edx
  801adb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ae2:	f6 c2 01             	test   $0x1,%dl
  801ae5:	74 1e                	je     801b05 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ae7:	c1 e8 0c             	shr    $0xc,%eax
  801aea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af1:	a8 01                	test   $0x1,%al
  801af3:	74 17                	je     801b0c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af5:	c1 e8 0c             	shr    $0xc,%eax
  801af8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801aff:	ef 
  801b00:	0f b7 c0             	movzwl %ax,%eax
  801b03:	eb 0c                	jmp    801b11 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0a:	eb 05                	jmp    801b11 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    
	...

00801b14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	ff 75 08             	pushl  0x8(%ebp)
  801b22:	e8 e9 f7 ff ff       	call   801310 <fd2data>
  801b27:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b29:	83 c4 08             	add    $0x8,%esp
  801b2c:	68 cd 29 80 00       	push   $0x8029cd
  801b31:	56                   	push   %esi
  801b32:	e8 d7 ed ff ff       	call   80090e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b37:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3a:	2b 03                	sub    (%ebx),%eax
  801b3c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b42:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801b49:	00 00 00 
	stat->st_dev = &devpipe;
  801b4c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801b53:	30 80 00 
	return 0;
}
  801b56:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5e:	5b                   	pop    %ebx
  801b5f:	5e                   	pop    %esi
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	53                   	push   %ebx
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b6c:	53                   	push   %ebx
  801b6d:	6a 00                	push   $0x0
  801b6f:	e8 66 f2 ff ff       	call   800dda <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b74:	89 1c 24             	mov    %ebx,(%esp)
  801b77:	e8 94 f7 ff ff       	call   801310 <fd2data>
  801b7c:	83 c4 08             	add    $0x8,%esp
  801b7f:	50                   	push   %eax
  801b80:	6a 00                	push   $0x0
  801b82:	e8 53 f2 ff ff       	call   800dda <sys_page_unmap>
}
  801b87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	83 ec 1c             	sub    $0x1c,%esp
  801b95:	89 c7                	mov    %eax,%edi
  801b97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	57                   	push   %edi
  801ba6:	e8 25 ff ff ff       	call   801ad0 <pageref>
  801bab:	89 c6                	mov    %eax,%esi
  801bad:	83 c4 04             	add    $0x4,%esp
  801bb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb3:	e8 18 ff ff ff       	call   801ad0 <pageref>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	39 c6                	cmp    %eax,%esi
  801bbd:	0f 94 c0             	sete   %al
  801bc0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bc3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bc9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bcc:	39 cb                	cmp    %ecx,%ebx
  801bce:	75 08                	jne    801bd8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801bd8:	83 f8 01             	cmp    $0x1,%eax
  801bdb:	75 bd                	jne    801b9a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bdd:	8b 42 58             	mov    0x58(%edx),%eax
  801be0:	6a 01                	push   $0x1
  801be2:	50                   	push   %eax
  801be3:	53                   	push   %ebx
  801be4:	68 d4 29 80 00       	push   $0x8029d4
  801be9:	e8 6a e7 ff ff       	call   800358 <cprintf>
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	eb a7                	jmp    801b9a <_pipeisclosed+0xe>

00801bf3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	57                   	push   %edi
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 28             	sub    $0x28,%esp
  801bfc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bff:	56                   	push   %esi
  801c00:	e8 0b f7 ff ff       	call   801310 <fd2data>
  801c05:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0e:	75 4a                	jne    801c5a <devpipe_write+0x67>
  801c10:	bf 00 00 00 00       	mov    $0x0,%edi
  801c15:	eb 56                	jmp    801c6d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c17:	89 da                	mov    %ebx,%edx
  801c19:	89 f0                	mov    %esi,%eax
  801c1b:	e8 6c ff ff ff       	call   801b8c <_pipeisclosed>
  801c20:	85 c0                	test   %eax,%eax
  801c22:	75 4d                	jne    801c71 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c24:	e8 40 f1 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c29:	8b 43 04             	mov    0x4(%ebx),%eax
  801c2c:	8b 13                	mov    (%ebx),%edx
  801c2e:	83 c2 20             	add    $0x20,%edx
  801c31:	39 d0                	cmp    %edx,%eax
  801c33:	73 e2                	jae    801c17 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c35:	89 c2                	mov    %eax,%edx
  801c37:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c3d:	79 05                	jns    801c44 <devpipe_write+0x51>
  801c3f:	4a                   	dec    %edx
  801c40:	83 ca e0             	or     $0xffffffe0,%edx
  801c43:	42                   	inc    %edx
  801c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c47:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	40                   	inc    %eax
  801c4f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c52:	47                   	inc    %edi
  801c53:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c56:	77 07                	ja     801c5f <devpipe_write+0x6c>
  801c58:	eb 13                	jmp    801c6d <devpipe_write+0x7a>
  801c5a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801c62:	8b 13                	mov    (%ebx),%edx
  801c64:	83 c2 20             	add    $0x20,%edx
  801c67:	39 d0                	cmp    %edx,%eax
  801c69:	73 ac                	jae    801c17 <devpipe_write+0x24>
  801c6b:	eb c8                	jmp    801c35 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c6d:	89 f8                	mov    %edi,%eax
  801c6f:	eb 05                	jmp    801c76 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 18             	sub    $0x18,%esp
  801c87:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c8a:	57                   	push   %edi
  801c8b:	e8 80 f6 ff ff       	call   801310 <fd2data>
  801c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c99:	75 44                	jne    801cdf <devpipe_read+0x61>
  801c9b:	be 00 00 00 00       	mov    $0x0,%esi
  801ca0:	eb 4f                	jmp    801cf1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ca2:	89 f0                	mov    %esi,%eax
  801ca4:	eb 54                	jmp    801cfa <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ca6:	89 da                	mov    %ebx,%edx
  801ca8:	89 f8                	mov    %edi,%eax
  801caa:	e8 dd fe ff ff       	call   801b8c <_pipeisclosed>
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	75 42                	jne    801cf5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cb3:	e8 b1 f0 ff ff       	call   800d69 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cb8:	8b 03                	mov    (%ebx),%eax
  801cba:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cbd:	74 e7                	je     801ca6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cbf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cc4:	79 05                	jns    801ccb <devpipe_read+0x4d>
  801cc6:	48                   	dec    %eax
  801cc7:	83 c8 e0             	or     $0xffffffe0,%eax
  801cca:	40                   	inc    %eax
  801ccb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801cd5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd7:	46                   	inc    %esi
  801cd8:	39 75 10             	cmp    %esi,0x10(%ebp)
  801cdb:	77 07                	ja     801ce4 <devpipe_read+0x66>
  801cdd:	eb 12                	jmp    801cf1 <devpipe_read+0x73>
  801cdf:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801ce4:	8b 03                	mov    (%ebx),%eax
  801ce6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ce9:	75 d4                	jne    801cbf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ceb:	85 f6                	test   %esi,%esi
  801ced:	75 b3                	jne    801ca2 <devpipe_read+0x24>
  801cef:	eb b5                	jmp    801ca6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	eb 05                	jmp    801cfa <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	57                   	push   %edi
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	83 ec 28             	sub    $0x28,%esp
  801d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	e8 11 f6 ff ff       	call   801328 <fd_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 24 01 00 00    	js     801e48 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 5a f0 ff ff       	call   800d90 <sys_page_alloc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	0f 88 05 01 00 00    	js     801e48 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801d49:	50                   	push   %eax
  801d4a:	e8 d9 f5 ff ff       	call   801328 <fd_alloc>
  801d4f:	89 c3                	mov    %eax,%ebx
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	85 c0                	test   %eax,%eax
  801d56:	0f 88 dc 00 00 00    	js     801e38 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	68 07 04 00 00       	push   $0x407
  801d64:	ff 75 e0             	pushl  -0x20(%ebp)
  801d67:	6a 00                	push   $0x0
  801d69:	e8 22 f0 ff ff       	call   800d90 <sys_page_alloc>
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	0f 88 bd 00 00 00    	js     801e38 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7b:	83 ec 0c             	sub    $0xc,%esp
  801d7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d81:	e8 8a f5 ff ff       	call   801310 <fd2data>
  801d86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d88:	83 c4 0c             	add    $0xc,%esp
  801d8b:	68 07 04 00 00       	push   $0x407
  801d90:	50                   	push   %eax
  801d91:	6a 00                	push   $0x0
  801d93:	e8 f8 ef ff ff       	call   800d90 <sys_page_alloc>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	0f 88 83 00 00 00    	js     801e28 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da5:	83 ec 0c             	sub    $0xc,%esp
  801da8:	ff 75 e0             	pushl  -0x20(%ebp)
  801dab:	e8 60 f5 ff ff       	call   801310 <fd2data>
  801db0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db7:	50                   	push   %eax
  801db8:	6a 00                	push   $0x0
  801dba:	56                   	push   %esi
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 f2 ef ff ff       	call   800db4 <sys_page_map>
  801dc2:	89 c3                	mov    %eax,%ebx
  801dc4:	83 c4 20             	add    $0x20,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 4f                	js     801e1a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dcb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dd9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801deb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dfb:	e8 00 f5 ff ff       	call   801300 <fd2num>
  801e00:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e02:	83 c4 04             	add    $0x4,%esp
  801e05:	ff 75 e0             	pushl  -0x20(%ebp)
  801e08:	e8 f3 f4 ff ff       	call   801300 <fd2num>
  801e0d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e18:	eb 2e                	jmp    801e48 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e1a:	83 ec 08             	sub    $0x8,%esp
  801e1d:	56                   	push   %esi
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 b5 ef ff ff       	call   800dda <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e28:	83 ec 08             	sub    $0x8,%esp
  801e2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e2e:	6a 00                	push   $0x0
  801e30:	e8 a5 ef ff ff       	call   800dda <sys_page_unmap>
  801e35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e38:	83 ec 08             	sub    $0x8,%esp
  801e3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 95 ef ff ff       	call   800dda <sys_page_unmap>
  801e45:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5b:	50                   	push   %eax
  801e5c:	ff 75 08             	pushl  0x8(%ebp)
  801e5f:	e8 37 f5 ff ff       	call   80139b <fd_lookup>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 18                	js     801e83 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e6b:	83 ec 0c             	sub    $0xc,%esp
  801e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e71:	e8 9a f4 ff ff       	call   801310 <fd2data>
	return _pipeisclosed(fd, p);
  801e76:	89 c2                	mov    %eax,%edx
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	e8 0c fd ff ff       	call   801b8c <_pipeisclosed>
  801e80:	83 c4 10             	add    $0x10,%esp
}
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    
  801e85:	00 00                	add    %al,(%eax)
	...

00801e88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    

00801e92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e98:	68 ec 29 80 00       	push   $0x8029ec
  801e9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ea0:	e8 69 ea ff ff       	call   80090e <strcpy>
	return 0;
}
  801ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	57                   	push   %edi
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebc:	74 45                	je     801f03 <devcons_write+0x57>
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ed1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ed3:	83 fb 7f             	cmp    $0x7f,%ebx
  801ed6:	76 05                	jbe    801edd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ed8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801edd:	83 ec 04             	sub    $0x4,%esp
  801ee0:	53                   	push   %ebx
  801ee1:	03 45 0c             	add    0xc(%ebp),%eax
  801ee4:	50                   	push   %eax
  801ee5:	57                   	push   %edi
  801ee6:	e8 e4 eb ff ff       	call   800acf <memmove>
		sys_cputs(buf, m);
  801eeb:	83 c4 08             	add    $0x8,%esp
  801eee:	53                   	push   %ebx
  801eef:	57                   	push   %edi
  801ef0:	e8 e4 ed ff ff       	call   800cd9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef5:	01 de                	add    %ebx,%esi
  801ef7:	89 f0                	mov    %esi,%eax
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eff:	72 cd                	jb     801ece <devcons_write+0x22>
  801f01:	eb 05                	jmp    801f08 <devcons_write+0x5c>
  801f03:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f08:	89 f0                	mov    %esi,%eax
  801f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f1c:	75 07                	jne    801f25 <devcons_read+0x13>
  801f1e:	eb 25                	jmp    801f45 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f20:	e8 44 ee ff ff       	call   800d69 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f25:	e8 d5 ed ff ff       	call   800cff <sys_cgetc>
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	74 f2                	je     801f20 <devcons_read+0xe>
  801f2e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 1d                	js     801f51 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f34:	83 f8 04             	cmp    $0x4,%eax
  801f37:	74 13                	je     801f4c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3c:	88 10                	mov    %dl,(%eax)
	return 1;
  801f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f43:	eb 0c                	jmp    801f51 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	eb 05                	jmp    801f51 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f5f:	6a 01                	push   $0x1
  801f61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	e8 6f ed ff ff       	call   800cd9 <sys_cputs>
  801f6a:	83 c4 10             	add    $0x10,%esp
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <getchar>:

int
getchar(void)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f75:	6a 01                	push   $0x1
  801f77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 9a f6 ff ff       	call   80161c <read>
	if (r < 0)
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 0f                	js     801f98 <getchar+0x29>
		return r;
	if (r < 1)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	7e 06                	jle    801f93 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f91:	eb 05                	jmp    801f98 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f93:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa3:	50                   	push   %eax
  801fa4:	ff 75 08             	pushl  0x8(%ebp)
  801fa7:	e8 ef f3 ff ff       	call   80139b <fd_lookup>
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 11                	js     801fc4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbc:	39 10                	cmp    %edx,(%eax)
  801fbe:	0f 94 c0             	sete   %al
  801fc1:	0f b6 c0             	movzbl %al,%eax
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <opencons>:

int
opencons(void)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	e8 53 f3 ff ff       	call   801328 <fd_alloc>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 3a                	js     802016 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdc:	83 ec 04             	sub    $0x4,%esp
  801fdf:	68 07 04 00 00       	push   $0x407
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 a2 ed ff ff       	call   800d90 <sys_page_alloc>
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	78 21                	js     802016 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802003:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	50                   	push   %eax
  80200e:	e8 ed f2 ff ff       	call   801300 <fd2num>
  802013:	83 c4 10             	add    $0x10,%esp
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80201e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802025:	75 52                	jne    802079 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802027:	83 ec 04             	sub    $0x4,%esp
  80202a:	6a 07                	push   $0x7
  80202c:	68 00 f0 bf ee       	push   $0xeebff000
  802031:	6a 00                	push   $0x0
  802033:	e8 58 ed ff ff       	call   800d90 <sys_page_alloc>
		if (r < 0) {
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	79 12                	jns    802051 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80203f:	50                   	push   %eax
  802040:	68 f8 29 80 00       	push   $0x8029f8
  802045:	6a 24                	push   $0x24
  802047:	68 13 2a 80 00       	push   $0x802a13
  80204c:	e8 2f e2 ff ff       	call   800280 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802051:	83 ec 08             	sub    $0x8,%esp
  802054:	68 84 20 80 00       	push   $0x802084
  802059:	6a 00                	push   $0x0
  80205b:	e8 e3 ed ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	79 12                	jns    802079 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802067:	50                   	push   %eax
  802068:	68 24 2a 80 00       	push   $0x802a24
  80206d:	6a 2a                	push   $0x2a
  80206f:	68 13 2a 80 00       	push   $0x802a13
  802074:	e8 07 e2 ff ff       	call   800280 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802079:	8b 45 08             	mov    0x8(%ebp),%eax
  80207c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    
	...

00802084 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802084:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802085:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80208a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80208c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80208f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802093:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802096:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  80209a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80209e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8020a0:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8020a3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8020a4:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8020a7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020a8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020a9:	c3                   	ret    
	...

008020ac <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	83 ec 10             	sub    $0x10,%esp
  8020b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ba:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020c0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020c3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	75 2e                	jne    8020f8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020ca:	39 f1                	cmp    %esi,%ecx
  8020cc:	77 5a                	ja     802128 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020ce:	85 c9                	test   %ecx,%ecx
  8020d0:	75 0b                	jne    8020dd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d7:	31 d2                	xor    %edx,%edx
  8020d9:	f7 f1                	div    %ecx
  8020db:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020dd:	31 d2                	xor    %edx,%edx
  8020df:	89 f0                	mov    %esi,%eax
  8020e1:	f7 f1                	div    %ecx
  8020e3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020e5:	89 f8                	mov    %edi,%eax
  8020e7:	f7 f1                	div    %ecx
  8020e9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020eb:	89 f8                	mov    %edi,%eax
  8020ed:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	c9                   	leave  
  8020f5:	c3                   	ret    
  8020f6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	77 1c                	ja     802118 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020fc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8020ff:	83 f7 1f             	xor    $0x1f,%edi
  802102:	75 3c                	jne    802140 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802104:	39 f0                	cmp    %esi,%eax
  802106:	0f 82 90 00 00 00    	jb     80219c <__udivdi3+0xf0>
  80210c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802112:	0f 86 84 00 00 00    	jbe    80219c <__udivdi3+0xf0>
  802118:	31 f6                	xor    %esi,%esi
  80211a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80211c:	89 f8                	mov    %edi,%eax
  80211e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	5e                   	pop    %esi
  802124:	5f                   	pop    %edi
  802125:	c9                   	leave  
  802126:	c3                   	ret    
  802127:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802128:	89 f2                	mov    %esi,%edx
  80212a:	89 f8                	mov    %edi,%eax
  80212c:	f7 f1                	div    %ecx
  80212e:	89 c7                	mov    %eax,%edi
  802130:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802132:	89 f8                	mov    %edi,%eax
  802134:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	c9                   	leave  
  80213c:	c3                   	ret    
  80213d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802140:	89 f9                	mov    %edi,%ecx
  802142:	d3 e0                	shl    %cl,%eax
  802144:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802147:	b8 20 00 00 00       	mov    $0x20,%eax
  80214c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80214e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802151:	88 c1                	mov    %al,%cl
  802153:	d3 ea                	shr    %cl,%edx
  802155:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802158:	09 ca                	or     %ecx,%edx
  80215a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80215d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802160:	89 f9                	mov    %edi,%ecx
  802162:	d3 e2                	shl    %cl,%edx
  802164:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802167:	89 f2                	mov    %esi,%edx
  802169:	88 c1                	mov    %al,%cl
  80216b:	d3 ea                	shr    %cl,%edx
  80216d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802170:	89 f2                	mov    %esi,%edx
  802172:	89 f9                	mov    %edi,%ecx
  802174:	d3 e2                	shl    %cl,%edx
  802176:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802179:	88 c1                	mov    %al,%cl
  80217b:	d3 ee                	shr    %cl,%esi
  80217d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80217f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802182:	89 f0                	mov    %esi,%eax
  802184:	89 ca                	mov    %ecx,%edx
  802186:	f7 75 ec             	divl   -0x14(%ebp)
  802189:	89 d1                	mov    %edx,%ecx
  80218b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80218d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802190:	39 d1                	cmp    %edx,%ecx
  802192:	72 28                	jb     8021bc <__udivdi3+0x110>
  802194:	74 1a                	je     8021b0 <__udivdi3+0x104>
  802196:	89 f7                	mov    %esi,%edi
  802198:	31 f6                	xor    %esi,%esi
  80219a:	eb 80                	jmp    80211c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80219c:	31 f6                	xor    %esi,%esi
  80219e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021a3:	89 f8                	mov    %edi,%eax
  8021a5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021a7:	83 c4 10             	add    $0x10,%esp
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	c9                   	leave  
  8021ad:	c3                   	ret    
  8021ae:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b7:	39 c2                	cmp    %eax,%edx
  8021b9:	73 db                	jae    802196 <__udivdi3+0xea>
  8021bb:	90                   	nop
		{
		  q0--;
  8021bc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021bf:	31 f6                	xor    %esi,%esi
  8021c1:	e9 56 ff ff ff       	jmp    80211c <__udivdi3+0x70>
	...

008021c8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	57                   	push   %edi
  8021cc:	56                   	push   %esi
  8021cd:	83 ec 20             	sub    $0x20,%esp
  8021d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021dc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021df:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8021e5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021e7:	85 ff                	test   %edi,%edi
  8021e9:	75 15                	jne    802200 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8021eb:	39 f1                	cmp    %esi,%ecx
  8021ed:	0f 86 99 00 00 00    	jbe    80228c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021f3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021f9:	83 c4 20             	add    $0x20,%esp
  8021fc:	5e                   	pop    %esi
  8021fd:	5f                   	pop    %edi
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802200:	39 f7                	cmp    %esi,%edi
  802202:	0f 87 a4 00 00 00    	ja     8022ac <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802208:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80220b:	83 f0 1f             	xor    $0x1f,%eax
  80220e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802211:	0f 84 a1 00 00 00    	je     8022b8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802217:	89 f8                	mov    %edi,%eax
  802219:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80221c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80221e:	bf 20 00 00 00       	mov    $0x20,%edi
  802223:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802226:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802229:	89 f9                	mov    %edi,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	09 c2                	or     %eax,%edx
  80222f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802232:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802235:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802238:	d3 e0                	shl    %cl,%eax
  80223a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802241:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802244:	d3 e0                	shl    %cl,%eax
  802246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802249:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80224c:	89 f9                	mov    %edi,%ecx
  80224e:	d3 e8                	shr    %cl,%eax
  802250:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802252:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802254:	89 f2                	mov    %esi,%edx
  802256:	f7 75 f0             	divl   -0x10(%ebp)
  802259:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80225b:	f7 65 f4             	mull   -0xc(%ebp)
  80225e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802261:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802263:	39 d6                	cmp    %edx,%esi
  802265:	72 71                	jb     8022d8 <__umoddi3+0x110>
  802267:	74 7f                	je     8022e8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80226c:	29 c8                	sub    %ecx,%eax
  80226e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802270:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802273:	d3 e8                	shr    %cl,%eax
  802275:	89 f2                	mov    %esi,%edx
  802277:	89 f9                	mov    %edi,%ecx
  802279:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80227b:	09 d0                	or     %edx,%eax
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802282:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802284:	83 c4 20             	add    $0x20,%esp
  802287:	5e                   	pop    %esi
  802288:	5f                   	pop    %edi
  802289:	c9                   	leave  
  80228a:	c3                   	ret    
  80228b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80228c:	85 c9                	test   %ecx,%ecx
  80228e:	75 0b                	jne    80229b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802290:	b8 01 00 00 00       	mov    $0x1,%eax
  802295:	31 d2                	xor    %edx,%edx
  802297:	f7 f1                	div    %ecx
  802299:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80229b:	89 f0                	mov    %esi,%eax
  80229d:	31 d2                	xor    %edx,%edx
  80229f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a4:	f7 f1                	div    %ecx
  8022a6:	e9 4a ff ff ff       	jmp    8021f5 <__umoddi3+0x2d>
  8022ab:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022ac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ae:	83 c4 20             	add    $0x20,%esp
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    
  8022b5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022b8:	39 f7                	cmp    %esi,%edi
  8022ba:	72 05                	jb     8022c1 <__umoddi3+0xf9>
  8022bc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022bf:	77 0c                	ja     8022cd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022c1:	89 f2                	mov    %esi,%edx
  8022c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c6:	29 c8                	sub    %ecx,%eax
  8022c8:	19 fa                	sbb    %edi,%edx
  8022ca:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022d0:	83 c4 20             	add    $0x20,%esp
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    
  8022d7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022db:	89 c1                	mov    %eax,%ecx
  8022dd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8022e0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8022e3:	eb 84                	jmp    802269 <__umoddi3+0xa1>
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022e8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022eb:	72 eb                	jb     8022d8 <__umoddi3+0x110>
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	e9 75 ff ff ff       	jmp    802269 <__umoddi3+0xa1>
