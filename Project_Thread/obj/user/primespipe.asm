
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 0f 02 00 00       	call   800240 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	6a 04                	push   $0x4
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	e8 cd 15 00 00       	call   80161f <readn>
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	83 f8 04             	cmp    $0x4,%eax
  800058:	74 21                	je     80007b <primeproc+0x47>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005a:	83 ec 0c             	sub    $0xc,%esp
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	85 c0                	test   %eax,%eax
  800061:	7e 05                	jle    800068 <primeproc+0x34>
  800063:	ba 00 00 00 00       	mov    $0x0,%edx
  800068:	52                   	push   %edx
  800069:	50                   	push   %eax
  80006a:	68 80 23 80 00       	push   $0x802380
  80006f:	6a 15                	push   $0x15
  800071:	68 af 23 80 00       	push   $0x8023af
  800076:	e8 2d 02 00 00       	call   8002a8 <_panic>

	cprintf("%d\n", p);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	ff 75 e0             	pushl  -0x20(%ebp)
  800081:	68 c1 23 80 00       	push   $0x8023c1
  800086:	e8 f5 02 00 00       	call   800380 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80008b:	89 3c 24             	mov    %edi,(%esp)
  80008e:	e8 87 1b 00 00       	call   801c1a <pipe>
  800093:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <primeproc+0x7b>
		panic("pipe: %e", i);
  80009d:	50                   	push   %eax
  80009e:	68 c5 23 80 00       	push   $0x8023c5
  8000a3:	6a 1b                	push   $0x1b
  8000a5:	68 af 23 80 00       	push   $0x8023af
  8000aa:	e8 f9 01 00 00       	call   8002a8 <_panic>
	if ((id = fork()) < 0)
  8000af:	e8 82 0f 00 00       	call   801036 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <primeproc+0x96>
		panic("fork: %e", id);
  8000b8:	50                   	push   %eax
  8000b9:	68 ce 23 80 00       	push   $0x8023ce
  8000be:	6a 1d                	push   $0x1d
  8000c0:	68 af 23 80 00       	push   $0x8023af
  8000c5:	e8 de 01 00 00       	call   8002a8 <_panic>
	if (id == 0) {
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 1f                	jne    8000ed <primeproc+0xb9>
		close(fd);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 84 13 00 00       	call   80145b <close>
		close(pfd[1]);
  8000d7:	83 c4 04             	add    $0x4,%esp
  8000da:	ff 75 dc             	pushl  -0x24(%ebp)
  8000dd:	e8 79 13 00 00       	call   80145b <close>
		fd = pfd[0];
  8000e2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	e9 59 ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f3:	e8 63 13 00 00       	call   80145b <close>
	wfd = pfd[1];
  8000f8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000fb:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fe:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	6a 04                	push   $0x4
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 12 15 00 00       	call   80161f <readn>
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	83 f8 04             	cmp    $0x4,%eax
  800113:	74 25                	je     80013a <primeproc+0x106>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800115:	83 ec 04             	sub    $0x4,%esp
  800118:	89 c2                	mov    %eax,%edx
  80011a:	85 c0                	test   %eax,%eax
  80011c:	7e 05                	jle    800123 <primeproc+0xef>
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	52                   	push   %edx
  800124:	50                   	push   %eax
  800125:	53                   	push   %ebx
  800126:	ff 75 e0             	pushl  -0x20(%ebp)
  800129:	68 d7 23 80 00       	push   $0x8023d7
  80012e:	6a 2b                	push   $0x2b
  800130:	68 af 23 80 00       	push   $0x8023af
  800135:	e8 6e 01 00 00       	call   8002a8 <_panic>
		if (i%p)
  80013a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013d:	99                   	cltd   
  80013e:	f7 7d e0             	idivl  -0x20(%ebp)
  800141:	85 d2                	test   %edx,%edx
  800143:	74 bc                	je     800101 <primeproc+0xcd>
			if ((r=write(wfd, &i, 4)) != 4)
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	6a 04                	push   $0x4
  80014a:	56                   	push   %esi
  80014b:	57                   	push   %edi
  80014c:	e8 23 15 00 00       	call   801674 <write>
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	83 f8 04             	cmp    $0x4,%eax
  800157:	74 a8                	je     800101 <primeproc+0xcd>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	89 c2                	mov    %eax,%edx
  80015e:	85 c0                	test   %eax,%eax
  800160:	7e 05                	jle    800167 <primeproc+0x133>
  800162:	ba 00 00 00 00       	mov    $0x0,%edx
  800167:	52                   	push   %edx
  800168:	50                   	push   %eax
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	68 f3 23 80 00       	push   $0x8023f3
  800171:	6a 2e                	push   $0x2e
  800173:	68 af 23 80 00       	push   $0x8023af
  800178:	e8 2b 01 00 00       	call   8002a8 <_panic>

0080017d <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	53                   	push   %ebx
  800181:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800184:	c7 05 00 30 80 00 0d 	movl   $0x80240d,0x803000
  80018b:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	e8 83 1a 00 00       	call   801c1a <pipe>
  800197:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	85 c0                	test   %eax,%eax
  80019f:	79 12                	jns    8001b3 <umain+0x36>
		panic("pipe: %e", i);
  8001a1:	50                   	push   %eax
  8001a2:	68 c5 23 80 00       	push   $0x8023c5
  8001a7:	6a 3a                	push   $0x3a
  8001a9:	68 af 23 80 00       	push   $0x8023af
  8001ae:	e8 f5 00 00 00       	call   8002a8 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001b3:	e8 7e 0e 00 00       	call   801036 <fork>
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	79 12                	jns    8001ce <umain+0x51>
		panic("fork: %e", id);
  8001bc:	50                   	push   %eax
  8001bd:	68 ce 23 80 00       	push   $0x8023ce
  8001c2:	6a 3e                	push   $0x3e
  8001c4:	68 af 23 80 00       	push   $0x8023af
  8001c9:	e8 da 00 00 00       	call   8002a8 <_panic>

	if (id == 0) {
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 19                	jne    8001eb <umain+0x6e>
		close(p[1]);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d8:	e8 7e 12 00 00       	call   80145b <close>
		primeproc(p[0]);
  8001dd:	83 c4 04             	add    $0x4,%esp
  8001e0:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e3:	e8 4c fe ff ff       	call   800034 <primeproc>
  8001e8:	83 c4 10             	add    $0x10,%esp
	}

	close(p[0]);
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 ec             	pushl  -0x14(%ebp)
  8001f1:	e8 65 12 00 00       	call   80145b <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f6:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001fd:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  800200:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	6a 04                	push   $0x4
  800208:	53                   	push   %ebx
  800209:	ff 75 f0             	pushl  -0x10(%ebp)
  80020c:	e8 63 14 00 00       	call   801674 <write>
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	83 f8 04             	cmp    $0x4,%eax
  800217:	74 21                	je     80023a <umain+0xbd>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	89 c2                	mov    %eax,%edx
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 05                	jle    800227 <umain+0xaa>
  800222:	ba 00 00 00 00       	mov    $0x0,%edx
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	68 18 24 80 00       	push   $0x802418
  80022e:	6a 4a                	push   $0x4a
  800230:	68 af 23 80 00       	push   $0x8023af
  800235:	e8 6e 00 00 00       	call   8002a8 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  80023a:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  80023d:	eb c4                	jmp    800203 <umain+0x86>
	...

00800240 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	8b 75 08             	mov    0x8(%ebp),%esi
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80024b:	e8 1d 0b 00 00       	call   800d6d <sys_getenvid>
  800250:	25 ff 03 00 00       	and    $0x3ff,%eax
  800255:	89 c2                	mov    %eax,%edx
  800257:	c1 e2 07             	shl    $0x7,%edx
  80025a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800261:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800266:	85 f6                	test   %esi,%esi
  800268:	7e 07                	jle    800271 <libmain+0x31>
		binaryname = argv[0];
  80026a:	8b 03                	mov    (%ebx),%eax
  80026c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	53                   	push   %ebx
  800275:	56                   	push   %esi
  800276:	e8 02 ff ff ff       	call   80017d <umain>

	// exit gracefully
	exit();
  80027b:	e8 0c 00 00 00       	call   80028c <exit>
  800280:	83 c4 10             	add    $0x10,%esp
}
  800283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	c9                   	leave  
  800289:	c3                   	ret    
	...

0080028c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800292:	e8 ef 11 00 00       	call   801486 <close_all>
	sys_env_destroy(0);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	6a 00                	push   $0x0
  80029c:	e8 aa 0a 00 00       	call   800d4b <sys_env_destroy>
  8002a1:	83 c4 10             	add    $0x10,%esp
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    
	...

008002a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002b6:	e8 b2 0a 00 00       	call   800d6d <sys_getenvid>
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	68 3c 24 80 00       	push   $0x80243c
  8002cb:	e8 b0 00 00 00       	call   800380 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d0:	83 c4 18             	add    $0x18,%esp
  8002d3:	56                   	push   %esi
  8002d4:	ff 75 10             	pushl  0x10(%ebp)
  8002d7:	e8 53 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002dc:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  8002e3:	e8 98 00 00 00       	call   800380 <cprintf>
  8002e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002eb:	cc                   	int3   
  8002ec:	eb fd                	jmp    8002eb <_panic+0x43>
	...

008002f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 04             	sub    $0x4,%esp
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800303:	40                   	inc    %eax
  800304:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800306:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030b:	75 1a                	jne    800327 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	68 ff 00 00 00       	push   $0xff
  800315:	8d 43 08             	lea    0x8(%ebx),%eax
  800318:	50                   	push   %eax
  800319:	e8 e3 09 00 00       	call   800d01 <sys_cputs>
		b->idx = 0;
  80031e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800324:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800327:	ff 43 04             	incl   0x4(%ebx)
}
  80032a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800358:	50                   	push   %eax
  800359:	68 f0 02 80 00       	push   $0x8002f0
  80035e:	e8 82 01 00 00       	call   8004e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800363:	83 c4 08             	add    $0x8,%esp
  800366:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80036c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800372:	50                   	push   %eax
  800373:	e8 89 09 00 00       	call   800d01 <sys_cputs>

	return b.cnt;
}
  800378:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800386:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 08             	pushl  0x8(%ebp)
  80038d:	e8 9d ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  80039d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a0:	89 d6                	mov    %edx,%esi
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003c4:	72 0c                	jb     8003d2 <printnum+0x3e>
  8003c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003c9:	76 07                	jbe    8003d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cb:	4b                   	dec    %ebx
  8003cc:	85 db                	test   %ebx,%ebx
  8003ce:	7f 31                	jg     800401 <printnum+0x6d>
  8003d0:	eb 3f                	jmp    800411 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d2:	83 ec 0c             	sub    $0xc,%esp
  8003d5:	57                   	push   %edi
  8003d6:	4b                   	dec    %ebx
  8003d7:	53                   	push   %ebx
  8003d8:	50                   	push   %eax
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003df:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e8:	e8 33 1d 00 00       	call   802120 <__udivdi3>
  8003ed:	83 c4 18             	add    $0x18,%esp
  8003f0:	52                   	push   %edx
  8003f1:	50                   	push   %eax
  8003f2:	89 f2                	mov    %esi,%edx
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	e8 98 ff ff ff       	call   800394 <printnum>
  8003fc:	83 c4 20             	add    $0x20,%esp
  8003ff:	eb 10                	jmp    800411 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	56                   	push   %esi
  800405:	57                   	push   %edi
  800406:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800409:	4b                   	dec    %ebx
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	85 db                	test   %ebx,%ebx
  80040f:	7f f0                	jg     800401 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	56                   	push   %esi
  800415:	83 ec 04             	sub    $0x4,%esp
  800418:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041b:	ff 75 d0             	pushl  -0x30(%ebp)
  80041e:	ff 75 dc             	pushl  -0x24(%ebp)
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	e8 13 1e 00 00       	call   80223c <__umoddi3>
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	0f be 80 5f 24 80 00 	movsbl 0x80245f(%eax),%eax
  800433:	50                   	push   %eax
  800434:	ff 55 e4             	call   *-0x1c(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
}
  80043a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043d:	5b                   	pop    %ebx
  80043e:	5e                   	pop    %esi
  80043f:	5f                   	pop    %edi
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800445:	83 fa 01             	cmp    $0x1,%edx
  800448:	7e 0e                	jle    800458 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044a:	8b 10                	mov    (%eax),%edx
  80044c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044f:	89 08                	mov    %ecx,(%eax)
  800451:	8b 02                	mov    (%edx),%eax
  800453:	8b 52 04             	mov    0x4(%edx),%edx
  800456:	eb 22                	jmp    80047a <getuint+0x38>
	else if (lflag)
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 10                	je     80046c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	eb 0e                	jmp    80047a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800471:	89 08                	mov    %ecx,(%eax)
  800473:	8b 02                	mov    (%edx),%eax
  800475:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047a:	c9                   	leave  
  80047b:	c3                   	ret    

0080047c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047f:	83 fa 01             	cmp    $0x1,%edx
  800482:	7e 0e                	jle    800492 <getint+0x16>
		return va_arg(*ap, long long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 4a 08             	lea    0x8(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	8b 52 04             	mov    0x4(%edx),%edx
  800490:	eb 1a                	jmp    8004ac <getint+0x30>
	else if (lflag)
  800492:	85 d2                	test   %edx,%edx
  800494:	74 0c                	je     8004a2 <getint+0x26>
		return va_arg(*ap, long);
  800496:	8b 10                	mov    (%eax),%edx
  800498:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049b:	89 08                	mov    %ecx,(%eax)
  80049d:	8b 02                	mov    (%edx),%eax
  80049f:	99                   	cltd   
  8004a0:	eb 0a                	jmp    8004ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	99                   	cltd   
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bc:	73 08                	jae    8004c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8004be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c1:	88 0a                	mov    %cl,(%edx)
  8004c3:	42                   	inc    %edx
  8004c4:	89 10                	mov    %edx,(%eax)
}
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 10             	pushl  0x10(%ebp)
  8004d5:	ff 75 0c             	pushl  0xc(%ebp)
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 05 00 00 00       	call   8004e5 <vprintfmt>
	va_end(ap);
  8004e0:	83 c4 10             	add    $0x10,%esp
}
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	53                   	push   %ebx
  8004eb:	83 ec 2c             	sub    $0x2c,%esp
  8004ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f4:	eb 13                	jmp    800509 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	0f 84 6d 03 00 00    	je     80086b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	57                   	push   %edi
  800502:	50                   	push   %eax
  800503:	ff 55 08             	call   *0x8(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800509:	0f b6 06             	movzbl (%esi),%eax
  80050c:	46                   	inc    %esi
  80050d:	83 f8 25             	cmp    $0x25,%eax
  800510:	75 e4                	jne    8004f6 <vprintfmt+0x11>
  800512:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800516:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80051d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800524:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800530:	eb 28                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800534:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800538:	eb 20                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80053c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800540:	eb 18                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800544:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80054d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800553:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8a 06                	mov    (%esi),%al
  80055c:	0f b6 d0             	movzbl %al,%edx
  80055f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800562:	83 e8 23             	sub    $0x23,%eax
  800565:	3c 55                	cmp    $0x55,%al
  800567:	0f 87 e0 02 00 00    	ja     80084d <vprintfmt+0x368>
  80056d:	0f b6 c0             	movzbl %al,%eax
  800570:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800577:	83 ea 30             	sub    $0x30,%edx
  80057a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80057d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800580:	8d 50 d0             	lea    -0x30(%eax),%edx
  800583:	83 fa 09             	cmp    $0x9,%edx
  800586:	77 44                	ja     8005cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	89 de                	mov    %ebx,%esi
  80058a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80058e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800591:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800595:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800598:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059b:	83 fb 09             	cmp    $0x9,%ebx
  80059e:	76 ed                	jbe    80058d <vprintfmt+0xa8>
  8005a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a3:	eb 29                	jmp    8005ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b5:	eb 17                	jmp    8005ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bb:	78 85                	js     800542 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	89 de                	mov    %ebx,%esi
  8005bf:	eb 99                	jmp    80055a <vprintfmt+0x75>
  8005c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ca:	eb 8e                	jmp    80055a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d2:	79 86                	jns    80055a <vprintfmt+0x75>
  8005d4:	e9 74 ff ff ff       	jmp    80054d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	89 de                	mov    %ebx,%esi
  8005dc:	e9 79 ff ff ff       	jmp    80055a <vprintfmt+0x75>
  8005e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	ff 30                	pushl  (%eax)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005fc:	e9 08 ff ff ff       	jmp    800509 <vprintfmt+0x24>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 02                	jns    800615 <vprintfmt+0x130>
  800613:	f7 d8                	neg    %eax
  800615:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800617:	83 f8 0f             	cmp    $0xf,%eax
  80061a:	7f 0b                	jg     800627 <vprintfmt+0x142>
  80061c:	8b 04 85 00 27 80 00 	mov    0x802700(,%eax,4),%eax
  800623:	85 c0                	test   %eax,%eax
  800625:	75 1a                	jne    800641 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800627:	52                   	push   %edx
  800628:	68 77 24 80 00       	push   $0x802477
  80062d:	57                   	push   %edi
  80062e:	ff 75 08             	pushl  0x8(%ebp)
  800631:	e8 92 fe ff ff       	call   8004c8 <printfmt>
  800636:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063c:	e9 c8 fe ff ff       	jmp    800509 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800641:	50                   	push   %eax
  800642:	68 b5 29 80 00       	push   $0x8029b5
  800647:	57                   	push   %edi
  800648:	ff 75 08             	pushl  0x8(%ebp)
  80064b:	e8 78 fe ff ff       	call   8004c8 <printfmt>
  800650:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800656:	e9 ae fe ff ff       	jmp    800509 <vprintfmt+0x24>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80065e:	89 de                	mov    %ebx,%esi
  800660:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800663:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800674:	85 c0                	test   %eax,%eax
  800676:	75 07                	jne    80067f <vprintfmt+0x19a>
				p = "(null)";
  800678:	c7 45 d0 70 24 80 00 	movl   $0x802470,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80067f:	85 db                	test   %ebx,%ebx
  800681:	7e 42                	jle    8006c5 <vprintfmt+0x1e0>
  800683:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800687:	74 3c                	je     8006c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	51                   	push   %ecx
  80068d:	ff 75 d0             	pushl  -0x30(%ebp)
  800690:	e8 6f 02 00 00       	call   800904 <strnlen>
  800695:	29 c3                	sub    %eax,%ebx
  800697:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 db                	test   %ebx,%ebx
  80069f:	7e 24                	jle    8006c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	53                   	push   %ebx
  8006b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	4e                   	dec    %esi
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	7f f0                	jg     8006ab <vprintfmt+0x1c6>
  8006bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c8:	0f be 02             	movsbl (%edx),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	75 47                	jne    800716 <vprintfmt+0x231>
  8006cf:	eb 37                	jmp    800708 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d5:	74 16                	je     8006ed <vprintfmt+0x208>
  8006d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006da:	83 fa 5e             	cmp    $0x5e,%edx
  8006dd:	76 0e                	jbe    8006ed <vprintfmt+0x208>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 3f                	push   $0x3f
  8006e5:	ff 55 08             	call   *0x8(%ebp)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 0b                	jmp    8006f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	57                   	push   %edi
  8006f1:	50                   	push   %eax
  8006f2:	ff 55 08             	call   *0x8(%ebp)
  8006f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8006fb:	0f be 03             	movsbl (%ebx),%eax
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 03                	je     800705 <vprintfmt+0x220>
  800702:	43                   	inc    %ebx
  800703:	eb 1b                	jmp    800720 <vprintfmt+0x23b>
  800705:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800708:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070c:	7f 1e                	jg     80072c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800711:	e9 f3 fd ff ff       	jmp    800509 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800716:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800719:	43                   	inc    %ebx
  80071a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80071d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800720:	85 f6                	test   %esi,%esi
  800722:	78 ad                	js     8006d1 <vprintfmt+0x1ec>
  800724:	4e                   	dec    %esi
  800725:	79 aa                	jns    8006d1 <vprintfmt+0x1ec>
  800727:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80072a:	eb dc                	jmp    800708 <vprintfmt+0x223>
  80072c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	57                   	push   %edi
  800733:	6a 20                	push   $0x20
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800738:	4b                   	dec    %ebx
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f ef                	jg     80072f <vprintfmt+0x24a>
  800740:	e9 c4 fd ff ff       	jmp    800509 <vprintfmt+0x24>
  800745:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800748:	89 ca                	mov    %ecx,%edx
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
  80074d:	e8 2a fd ff ff       	call   80047c <getint>
  800752:	89 c3                	mov    %eax,%ebx
  800754:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800756:	85 d2                	test   %edx,%edx
  800758:	78 0a                	js     800764 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075f:	e9 b0 00 00 00       	jmp    800814 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	57                   	push   %edi
  800768:	6a 2d                	push   $0x2d
  80076a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076d:	f7 db                	neg    %ebx
  80076f:	83 d6 00             	adc    $0x0,%esi
  800772:	f7 de                	neg    %esi
  800774:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077c:	e9 93 00 00 00       	jmp    800814 <vprintfmt+0x32f>
  800781:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800784:	89 ca                	mov    %ecx,%edx
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
  800789:	e8 b4 fc ff ff       	call   800442 <getuint>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	89 d6                	mov    %edx,%esi
			base = 10;
  800792:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800797:	eb 7b                	jmp    800814 <vprintfmt+0x32f>
  800799:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80079c:	89 ca                	mov    %ecx,%edx
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 d6 fc ff ff       	call   80047c <getint>
  8007a6:	89 c3                	mov    %eax,%ebx
  8007a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	78 07                	js     8007b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b3:	eb 5f                	jmp    800814 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	57                   	push   %edi
  8007b9:	6a 2d                	push   $0x2d
  8007bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007be:	f7 db                	neg    %ebx
  8007c0:	83 d6 00             	adc    $0x0,%esi
  8007c3:	f7 de                	neg    %esi
  8007c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cd:	eb 45                	jmp    800814 <vprintfmt+0x32f>
  8007cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	57                   	push   %edi
  8007d6:	6a 30                	push   $0x30
  8007d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	57                   	push   %edi
  8007df:	6a 78                	push   $0x78
  8007e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ed:	8b 18                	mov    (%eax),%ebx
  8007ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fc:	eb 16                	jmp    800814 <vprintfmt+0x32f>
  8007fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800801:	89 ca                	mov    %ecx,%edx
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	e8 37 fc ff ff       	call   800442 <getuint>
  80080b:	89 c3                	mov    %eax,%ebx
  80080d:	89 d6                	mov    %edx,%esi
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800814:	83 ec 0c             	sub    $0xc,%esp
  800817:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80081b:	52                   	push   %edx
  80081c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081f:	50                   	push   %eax
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	89 fa                	mov    %edi,%edx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	e8 68 fb ff ff       	call   800394 <printnum>
			break;
  80082c:	83 c4 20             	add    $0x20,%esp
  80082f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800832:	e9 d2 fc ff ff       	jmp    800509 <vprintfmt+0x24>
  800837:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	57                   	push   %edi
  80083e:	52                   	push   %edx
  80083f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800842:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800845:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800848:	e9 bc fc ff ff       	jmp    800509 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	57                   	push   %edi
  800851:	6a 25                	push   $0x25
  800853:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	eb 02                	jmp    80085d <vprintfmt+0x378>
  80085b:	89 c6                	mov    %eax,%esi
  80085d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800860:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800864:	75 f5                	jne    80085b <vprintfmt+0x376>
  800866:	e9 9e fc ff ff       	jmp    800509 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80086b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 18             	sub    $0x18,%esp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800882:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800886:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800890:	85 c0                	test   %eax,%eax
  800892:	74 26                	je     8008ba <vsnprintf+0x47>
  800894:	85 d2                	test   %edx,%edx
  800896:	7e 29                	jle    8008c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800898:	ff 75 14             	pushl  0x14(%ebp)
  80089b:	ff 75 10             	pushl  0x10(%ebp)
  80089e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	68 ae 04 80 00       	push   $0x8004ae
  8008a7:	e8 39 fc ff ff       	call   8004e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	eb 0c                	jmp    8008c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bf:	eb 05                	jmp    8008c6 <vsnprintf+0x53>
  8008c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d1:	50                   	push   %eax
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 93 ff ff ff       	call   800873 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    
	...

008008e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ed:	74 0e                	je     8008fd <strlen+0x19>
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f9:	75 f9                	jne    8008f4 <strlen+0x10>
  8008fb:	eb 05                	jmp    800902 <strlen+0x1e>
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090d:	85 d2                	test   %edx,%edx
  80090f:	74 17                	je     800928 <strnlen+0x24>
  800911:	80 39 00             	cmpb   $0x0,(%ecx)
  800914:	74 19                	je     80092f <strnlen+0x2b>
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	74 14                	je     800934 <strnlen+0x30>
  800920:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800924:	75 f5                	jne    80091b <strnlen+0x17>
  800926:	eb 0c                	jmp    800934 <strnlen+0x30>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 05                	jmp    800934 <strnlen+0x30>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800940:	ba 00 00 00 00       	mov    $0x0,%edx
  800945:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800948:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80094b:	42                   	inc    %edx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 f5                	jne    800945 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800950:	5b                   	pop    %ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095a:	53                   	push   %ebx
  80095b:	e8 84 ff ff ff       	call   8008e4 <strlen>
  800960:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800969:	50                   	push   %eax
  80096a:	e8 c7 ff ff ff       	call   800936 <strcpy>
	return dst;
}
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800984:	85 f6                	test   %esi,%esi
  800986:	74 15                	je     80099d <strncpy+0x27>
  800988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80098d:	8a 1a                	mov    (%edx),%bl
  80098f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800992:	80 3a 01             	cmpb   $0x1,(%edx)
  800995:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	41                   	inc    %ecx
  800999:	39 ce                	cmp    %ecx,%esi
  80099b:	77 f0                	ja     80098d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b0:	85 f6                	test   %esi,%esi
  8009b2:	74 32                	je     8009e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009b4:	83 fe 01             	cmp    $0x1,%esi
  8009b7:	74 22                	je     8009db <strlcpy+0x3a>
  8009b9:	8a 0b                	mov    (%ebx),%cl
  8009bb:	84 c9                	test   %cl,%cl
  8009bd:	74 20                	je     8009df <strlcpy+0x3e>
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	88 08                	mov    %cl,(%eax)
  8009cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009cc:	39 f2                	cmp    %esi,%edx
  8009ce:	74 11                	je     8009e1 <strlcpy+0x40>
  8009d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009d4:	42                   	inc    %edx
  8009d5:	84 c9                	test   %cl,%cl
  8009d7:	75 f0                	jne    8009c9 <strlcpy+0x28>
  8009d9:	eb 06                	jmp    8009e1 <strlcpy+0x40>
  8009db:	89 f8                	mov    %edi,%eax
  8009dd:	eb 02                	jmp    8009e1 <strlcpy+0x40>
  8009df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 00 00             	movb   $0x0,(%eax)
  8009e4:	eb 02                	jmp    8009e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009e8:	29 f8                	sub    %edi,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f8:	8a 01                	mov    (%ecx),%al
  8009fa:	84 c0                	test   %al,%al
  8009fc:	74 10                	je     800a0e <strcmp+0x1f>
  8009fe:	3a 02                	cmp    (%edx),%al
  800a00:	75 0c                	jne    800a0e <strcmp+0x1f>
		p++, q++;
  800a02:	41                   	inc    %ecx
  800a03:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a04:	8a 01                	mov    (%ecx),%al
  800a06:	84 c0                	test   %al,%al
  800a08:	74 04                	je     800a0e <strcmp+0x1f>
  800a0a:	3a 02                	cmp    (%edx),%al
  800a0c:	74 f4                	je     800a02 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	29 d0                	sub    %edx,%eax
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	53                   	push   %ebx
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a25:	85 c0                	test   %eax,%eax
  800a27:	74 1b                	je     800a44 <strncmp+0x2c>
  800a29:	8a 1a                	mov    (%edx),%bl
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	74 24                	je     800a53 <strncmp+0x3b>
  800a2f:	3a 19                	cmp    (%ecx),%bl
  800a31:	75 20                	jne    800a53 <strncmp+0x3b>
  800a33:	48                   	dec    %eax
  800a34:	74 15                	je     800a4b <strncmp+0x33>
		n--, p++, q++;
  800a36:	42                   	inc    %edx
  800a37:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a38:	8a 1a                	mov    (%edx),%bl
  800a3a:	84 db                	test   %bl,%bl
  800a3c:	74 15                	je     800a53 <strncmp+0x3b>
  800a3e:	3a 19                	cmp    (%ecx),%bl
  800a40:	74 f1                	je     800a33 <strncmp+0x1b>
  800a42:	eb 0f                	jmp    800a53 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	eb 05                	jmp    800a50 <strncmp+0x38>
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a50:	5b                   	pop    %ebx
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a53:	0f b6 02             	movzbl (%edx),%eax
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	29 d0                	sub    %edx,%eax
  800a5b:	eb f3                	jmp    800a50 <strncmp+0x38>

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a66:	8a 10                	mov    (%eax),%dl
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strchr+0x27>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 06                	jne    800a76 <strchr+0x19>
  800a70:	eb 17                	jmp    800a89 <strchr+0x2c>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	74 13                	je     800a89 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a76:	40                   	inc    %eax
  800a77:	8a 10                	mov    (%eax),%dl
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	75 f5                	jne    800a72 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	eb 05                	jmp    800a89 <strchr+0x2c>
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a94:	8a 10                	mov    (%eax),%dl
  800a96:	84 d2                	test   %dl,%dl
  800a98:	74 11                	je     800aab <strfind+0x20>
		if (*s == c)
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	75 06                	jne    800aa4 <strfind+0x19>
  800a9e:	eb 0b                	jmp    800aab <strfind+0x20>
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 07                	je     800aab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	40                   	inc    %eax
  800aa5:	8a 10                	mov    (%eax),%dl
  800aa7:	84 d2                	test   %dl,%dl
  800aa9:	75 f5                	jne    800aa0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	74 30                	je     800af0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac6:	75 25                	jne    800aed <memset+0x40>
  800ac8:	f6 c1 03             	test   $0x3,%cl
  800acb:	75 20                	jne    800aed <memset+0x40>
		c &= 0xFF;
  800acd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	c1 e3 08             	shl    $0x8,%ebx
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	c1 e6 18             	shl    $0x18,%esi
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	c1 e0 10             	shl    $0x10,%eax
  800adf:	09 f0                	or     %esi,%eax
  800ae1:	09 d0                	or     %edx,%eax
  800ae3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae8:	fc                   	cld    
  800ae9:	f3 ab                	rep stos %eax,%es:(%edi)
  800aeb:	eb 03                	jmp    800af0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	fc                   	cld    
  800aee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af0:	89 f8                	mov    %edi,%eax
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b05:	39 c6                	cmp    %eax,%esi
  800b07:	73 34                	jae    800b3d <memmove+0x46>
  800b09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0c:	39 d0                	cmp    %edx,%eax
  800b0e:	73 2d                	jae    800b3d <memmove+0x46>
		s += n;
		d += n;
  800b10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	f6 c2 03             	test   $0x3,%dl
  800b16:	75 1b                	jne    800b33 <memmove+0x3c>
  800b18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1e:	75 13                	jne    800b33 <memmove+0x3c>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 0e                	jne    800b33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b25:	83 ef 04             	sub    $0x4,%edi
  800b28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2e:	fd                   	std    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb 07                	jmp    800b3a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b33:	4f                   	dec    %edi
  800b34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b37:	fd                   	std    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3a:	fc                   	cld    
  800b3b:	eb 20                	jmp    800b5d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	75 13                	jne    800b58 <memmove+0x61>
  800b45:	a8 03                	test   $0x3,%al
  800b47:	75 0f                	jne    800b58 <memmove+0x61>
  800b49:	f6 c1 03             	test   $0x3,%cl
  800b4c:	75 0a                	jne    800b58 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	fc                   	cld    
  800b54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b56:	eb 05                	jmp    800b5d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	fc                   	cld    
  800b5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b64:	ff 75 10             	pushl  0x10(%ebp)
  800b67:	ff 75 0c             	pushl  0xc(%ebp)
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 85 ff ff ff       	call   800af7 <memmove>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b83:	85 ff                	test   %edi,%edi
  800b85:	74 32                	je     800bb9 <memcmp+0x45>
		if (*s1 != *s2)
  800b87:	8a 03                	mov    (%ebx),%al
  800b89:	8a 0e                	mov    (%esi),%cl
  800b8b:	38 c8                	cmp    %cl,%al
  800b8d:	74 19                	je     800ba8 <memcmp+0x34>
  800b8f:	eb 0d                	jmp    800b9e <memcmp+0x2a>
  800b91:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b95:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b99:	42                   	inc    %edx
  800b9a:	38 c8                	cmp    %cl,%al
  800b9c:	74 10                	je     800bae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c0             	movzbl %al,%eax
  800ba1:	0f b6 c9             	movzbl %cl,%ecx
  800ba4:	29 c8                	sub    %ecx,%eax
  800ba6:	eb 16                	jmp    800bbe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	4f                   	dec    %edi
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	39 fa                	cmp    %edi,%edx
  800bb0:	75 df                	jne    800b91 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	eb 05                	jmp    800bbe <memcmp+0x4a>
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	73 12                	jae    800be4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bd5:	38 08                	cmp    %cl,(%eax)
  800bd7:	75 06                	jne    800bdf <memfind+0x1c>
  800bd9:	eb 09                	jmp    800be4 <memfind+0x21>
  800bdb:	38 08                	cmp    %cl,(%eax)
  800bdd:	74 05                	je     800be4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bdf:	40                   	inc    %eax
  800be0:	39 c2                	cmp    %eax,%edx
  800be2:	77 f7                	ja     800bdb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf2:	eb 01                	jmp    800bf5 <strtol+0xf>
		s++;
  800bf4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf5:	8a 02                	mov    (%edx),%al
  800bf7:	3c 20                	cmp    $0x20,%al
  800bf9:	74 f9                	je     800bf4 <strtol+0xe>
  800bfb:	3c 09                	cmp    $0x9,%al
  800bfd:	74 f5                	je     800bf4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bff:	3c 2b                	cmp    $0x2b,%al
  800c01:	75 08                	jne    800c0b <strtol+0x25>
		s++;
  800c03:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c04:	bf 00 00 00 00       	mov    $0x0,%edi
  800c09:	eb 13                	jmp    800c1e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0b:	3c 2d                	cmp    $0x2d,%al
  800c0d:	75 0a                	jne    800c19 <strtol+0x33>
		s++, neg = 1;
  800c0f:	8d 52 01             	lea    0x1(%edx),%edx
  800c12:	bf 01 00 00 00       	mov    $0x1,%edi
  800c17:	eb 05                	jmp    800c1e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	85 db                	test   %ebx,%ebx
  800c20:	74 05                	je     800c27 <strtol+0x41>
  800c22:	83 fb 10             	cmp    $0x10,%ebx
  800c25:	75 28                	jne    800c4f <strtol+0x69>
  800c27:	8a 02                	mov    (%edx),%al
  800c29:	3c 30                	cmp    $0x30,%al
  800c2b:	75 10                	jne    800c3d <strtol+0x57>
  800c2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c31:	75 0a                	jne    800c3d <strtol+0x57>
		s += 2, base = 16;
  800c33:	83 c2 02             	add    $0x2,%edx
  800c36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3b:	eb 12                	jmp    800c4f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 db                	test   %ebx,%ebx
  800c3f:	75 0e                	jne    800c4f <strtol+0x69>
  800c41:	3c 30                	cmp    $0x30,%al
  800c43:	75 05                	jne    800c4a <strtol+0x64>
		s++, base = 8;
  800c45:	42                   	inc    %edx
  800c46:	b3 08                	mov    $0x8,%bl
  800c48:	eb 05                	jmp    800c4f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c54:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c56:	8a 0a                	mov    (%edx),%cl
  800c58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c5b:	80 fb 09             	cmp    $0x9,%bl
  800c5e:	77 08                	ja     800c68 <strtol+0x82>
			dig = *s - '0';
  800c60:	0f be c9             	movsbl %cl,%ecx
  800c63:	83 e9 30             	sub    $0x30,%ecx
  800c66:	eb 1e                	jmp    800c86 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c6b:	80 fb 19             	cmp    $0x19,%bl
  800c6e:	77 08                	ja     800c78 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c70:	0f be c9             	movsbl %cl,%ecx
  800c73:	83 e9 57             	sub    $0x57,%ecx
  800c76:	eb 0e                	jmp    800c86 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 13                	ja     800c93 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c80:	0f be c9             	movsbl %cl,%ecx
  800c83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c86:	39 f1                	cmp    %esi,%ecx
  800c88:	7d 0d                	jge    800c97 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c8a:	42                   	inc    %edx
  800c8b:	0f af c6             	imul   %esi,%eax
  800c8e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c91:	eb c3                	jmp    800c56 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c93:	89 c1                	mov    %eax,%ecx
  800c95:	eb 02                	jmp    800c99 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c97:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9d:	74 05                	je     800ca4 <strtol+0xbe>
		*endptr = (char *) s;
  800c9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca4:	85 ff                	test   %edi,%edi
  800ca6:	74 04                	je     800cac <strtol+0xc6>
  800ca8:	89 c8                	mov    %ecx,%eax
  800caa:	f7 d8                	neg    %eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    
  800cb1:	00 00                	add    %al,(%eax)
	...

00800cb4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 1c             	sub    $0x1c,%esp
  800cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cc0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cc3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	8b 75 14             	mov    0x14(%ebp),%esi
  800cc8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ccb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd1:	cd 30                	int    $0x30
  800cd3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cd9:	74 1c                	je     800cf7 <syscall+0x43>
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 18                	jle    800cf7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ce6:	68 5f 27 80 00       	push   $0x80275f
  800ceb:	6a 42                	push   $0x42
  800ced:	68 7c 27 80 00       	push   $0x80277c
  800cf2:	e8 b1 f5 ff ff       	call   8002a8 <_panic>

	return ret;
}
  800cf7:	89 d0                	mov    %edx,%eax
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d07:	6a 00                	push   $0x0
  800d09:	6a 00                	push   $0x0
  800d0b:	6a 00                	push   $0x0
  800d0d:	ff 75 0c             	pushl  0xc(%ebp)
  800d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1d:	e8 92 ff ff ff       	call   800cb4 <syscall>
  800d22:	83 c4 10             	add    $0x10,%esp
	return;
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d44:	e8 6b ff ff ff       	call   800cb4 <syscall>
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d51:	6a 00                	push   $0x0
  800d53:	6a 00                	push   $0x0
  800d55:	6a 00                	push   $0x0
  800d57:	6a 00                	push   $0x0
  800d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d61:	b8 03 00 00 00       	mov    $0x3,%eax
  800d66:	e8 49 ff ff ff       	call   800cb4 <syscall>
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8a:	e8 25 ff ff ff       	call   800cb4 <syscall>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <sys_yield>:

void
sys_yield(void)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d97:	6a 00                	push   $0x0
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dae:	e8 01 ff ff ff       	call   800cb4 <syscall>
  800db3:	83 c4 10             	add    $0x10,%esp
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800dbe:	6a 00                	push   $0x0
  800dc0:	6a 00                	push   $0x0
  800dc2:	ff 75 10             	pushl  0x10(%ebp)
  800dc5:	ff 75 0c             	pushl  0xc(%ebp)
  800dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcb:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd5:	e8 da fe ff ff       	call   800cb4 <syscall>
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800de2:	ff 75 18             	pushl  0x18(%ebp)
  800de5:	ff 75 14             	pushl  0x14(%ebp)
  800de8:	ff 75 10             	pushl  0x10(%ebp)
  800deb:	ff 75 0c             	pushl  0xc(%ebp)
  800dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df1:	ba 01 00 00 00       	mov    $0x1,%edx
  800df6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfb:	e8 b4 fe ff ff       	call   800cb4 <syscall>
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	6a 00                	push   $0x0
  800e0e:	ff 75 0c             	pushl  0xc(%ebp)
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	ba 01 00 00 00       	mov    $0x1,%edx
  800e19:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1e:	e8 91 fe ff ff       	call   800cb4 <syscall>
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e2b:	6a 00                	push   $0x0
  800e2d:	6a 00                	push   $0x0
  800e2f:	6a 00                	push   $0x0
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	ba 01 00 00 00       	mov    $0x1,%edx
  800e3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800e41:	e8 6e fe ff ff       	call   800cb4 <syscall>
}
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e4e:	6a 00                	push   $0x0
  800e50:	6a 00                	push   $0x0
  800e52:	6a 00                	push   $0x0
  800e54:	ff 75 0c             	pushl  0xc(%ebp)
  800e57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e64:	e8 4b fe ff ff       	call   800cb4 <syscall>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e71:	6a 00                	push   $0x0
  800e73:	6a 00                	push   $0x0
  800e75:	6a 00                	push   $0x0
  800e77:	ff 75 0c             	pushl  0xc(%ebp)
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e87:	e8 28 fe ff ff       	call   800cb4 <syscall>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e94:	6a 00                	push   $0x0
  800e96:	ff 75 14             	pushl  0x14(%ebp)
  800e99:	ff 75 10             	pushl  0x10(%ebp)
  800e9c:	ff 75 0c             	pushl  0xc(%ebp)
  800e9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eac:	e8 03 fe ff ff       	call   800cb4 <syscall>
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800eb9:	6a 00                	push   $0x0
  800ebb:	6a 00                	push   $0x0
  800ebd:	6a 00                	push   $0x0
  800ebf:	6a 00                	push   $0x0
  800ec1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ece:	e8 e1 fd ff ff       	call   800cb4 <syscall>
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800edb:	6a 00                	push   $0x0
  800edd:	6a 00                	push   $0x0
  800edf:	6a 00                	push   $0x0
  800ee1:	ff 75 0c             	pushl  0xc(%ebp)
  800ee4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef1:	e8 be fd ff ff       	call   800cb4 <syscall>
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800efe:	6a 00                	push   $0x0
  800f00:	ff 75 14             	pushl  0x14(%ebp)
  800f03:	ff 75 10             	pushl  0x10(%ebp)
  800f06:	ff 75 0c             	pushl  0xc(%ebp)
  800f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f11:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f16:	e8 99 fd ff ff       	call   800cb4 <syscall>
} 
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800f23:	6a 00                	push   $0x0
  800f25:	6a 00                	push   $0x0
  800f27:	6a 00                	push   $0x0
  800f29:	6a 00                	push   $0x0
  800f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 11 00 00 00       	mov    $0x11,%eax
  800f38:	e8 77 fd ff ff       	call   800cb4 <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_getpid>:

envid_t
sys_getpid(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800f45:	6a 00                	push   $0x0
  800f47:	6a 00                	push   $0x0
  800f49:	6a 00                	push   $0x0
  800f4b:	6a 00                	push   $0x0
  800f4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5c:	e8 53 fd ff ff       	call   800cb4 <syscall>
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    
	...

00800f64 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	53                   	push   %ebx
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f6e:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800f70:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f74:	75 14                	jne    800f8a <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 8c 27 80 00       	push   $0x80278c
  800f7e:	6a 20                	push   $0x20
  800f80:	68 d0 28 80 00       	push   $0x8028d0
  800f85:	e8 1e f3 ff ff       	call   8002a8 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f8a:	89 d8                	mov    %ebx,%eax
  800f8c:	c1 e8 16             	shr    $0x16,%eax
  800f8f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f96:	a8 01                	test   $0x1,%al
  800f98:	74 11                	je     800fab <pgfault+0x47>
  800f9a:	89 d8                	mov    %ebx,%eax
  800f9c:	c1 e8 0c             	shr    $0xc,%eax
  800f9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa6:	f6 c4 08             	test   $0x8,%ah
  800fa9:	75 14                	jne    800fbf <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	68 b0 27 80 00       	push   $0x8027b0
  800fb3:	6a 24                	push   $0x24
  800fb5:	68 d0 28 80 00       	push   $0x8028d0
  800fba:	e8 e9 f2 ff ff       	call   8002a8 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800fbf:	83 ec 04             	sub    $0x4,%esp
  800fc2:	6a 07                	push   $0x7
  800fc4:	68 00 f0 7f 00       	push   $0x7ff000
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 e8 fd ff ff       	call   800db8 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	79 12                	jns    800fe9 <pgfault+0x85>
  800fd7:	50                   	push   %eax
  800fd8:	68 d4 27 80 00       	push   $0x8027d4
  800fdd:	6a 32                	push   $0x32
  800fdf:	68 d0 28 80 00       	push   $0x8028d0
  800fe4:	e8 bf f2 ff ff       	call   8002a8 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800fe9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	68 00 10 00 00       	push   $0x1000
  800ff7:	53                   	push   %ebx
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	e8 5f fb ff ff       	call   800b61 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  801002:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801009:	53                   	push   %ebx
  80100a:	6a 00                	push   $0x0
  80100c:	68 00 f0 7f 00       	push   $0x7ff000
  801011:	6a 00                	push   $0x0
  801013:	e8 c4 fd ff ff       	call   800ddc <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 12                	jns    801031 <pgfault+0xcd>
  80101f:	50                   	push   %eax
  801020:	68 f8 27 80 00       	push   $0x8027f8
  801025:	6a 3a                	push   $0x3a
  801027:	68 d0 28 80 00       	push   $0x8028d0
  80102c:	e8 77 f2 ff ff       	call   8002a8 <_panic>

	return;
}
  801031:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80103f:	68 64 0f 80 00       	push   $0x800f64
  801044:	e8 e7 0e 00 00       	call   801f30 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801049:	ba 07 00 00 00       	mov    $0x7,%edx
  80104e:	89 d0                	mov    %edx,%eax
  801050:	cd 30                	int    $0x30
  801052:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801055:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	79 12                	jns    801070 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  80105e:	50                   	push   %eax
  80105f:	68 db 28 80 00       	push   $0x8028db
  801064:	6a 7f                	push   $0x7f
  801066:	68 d0 28 80 00       	push   $0x8028d0
  80106b:	e8 38 f2 ff ff       	call   8002a8 <_panic>
	}
	int r;

	if (childpid == 0) {
  801070:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801074:	75 20                	jne    801096 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  801076:	e8 f2 fc ff ff       	call   800d6d <sys_getenvid>
  80107b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801080:	89 c2                	mov    %eax,%edx
  801082:	c1 e2 07             	shl    $0x7,%edx
  801085:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80108c:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  801091:	e9 be 01 00 00       	jmp    801254 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	c1 e8 16             	shr    $0x16,%eax
  8010a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a7:	a8 01                	test   $0x1,%al
  8010a9:	0f 84 10 01 00 00    	je     8011bf <fork+0x189>
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	c1 e8 0c             	shr    $0xc,%eax
  8010b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bb:	f6 c2 01             	test   $0x1,%dl
  8010be:	0f 84 fb 00 00 00    	je     8011bf <fork+0x189>
  8010c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cb:	f6 c2 04             	test   $0x4,%dl
  8010ce:	0f 84 eb 00 00 00    	je     8011bf <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8010d4:	89 c6                	mov    %eax,%esi
  8010d6:	c1 e6 0c             	shl    $0xc,%esi
  8010d9:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8010df:	0f 84 da 00 00 00    	je     8011bf <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  8010e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ec:	f6 c6 04             	test   $0x4,%dh
  8010ef:	74 37                	je     801128 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801100:	50                   	push   %eax
  801101:	56                   	push   %esi
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	6a 00                	push   $0x0
  801106:	e8 d1 fc ff ff       	call   800ddc <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	85 c0                	test   %eax,%eax
  801110:	0f 89 a9 00 00 00    	jns    8011bf <fork+0x189>
  801116:	50                   	push   %eax
  801117:	68 1c 28 80 00       	push   $0x80281c
  80111c:	6a 54                	push   $0x54
  80111e:	68 d0 28 80 00       	push   $0x8028d0
  801123:	e8 80 f1 ff ff       	call   8002a8 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801128:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112f:	f6 c2 02             	test   $0x2,%dl
  801132:	75 0c                	jne    801140 <fork+0x10a>
  801134:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113b:	f6 c4 08             	test   $0x8,%ah
  80113e:	74 57                	je     801197 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	68 05 08 00 00       	push   $0x805
  801148:	56                   	push   %esi
  801149:	57                   	push   %edi
  80114a:	56                   	push   %esi
  80114b:	6a 00                	push   $0x0
  80114d:	e8 8a fc ff ff       	call   800ddc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801152:	83 c4 20             	add    $0x20,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	79 12                	jns    80116b <fork+0x135>
  801159:	50                   	push   %eax
  80115a:	68 1c 28 80 00       	push   $0x80281c
  80115f:	6a 59                	push   $0x59
  801161:	68 d0 28 80 00       	push   $0x8028d0
  801166:	e8 3d f1 ff ff       	call   8002a8 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	68 05 08 00 00       	push   $0x805
  801173:	56                   	push   %esi
  801174:	6a 00                	push   $0x0
  801176:	56                   	push   %esi
  801177:	6a 00                	push   $0x0
  801179:	e8 5e fc ff ff       	call   800ddc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80117e:	83 c4 20             	add    $0x20,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	79 3a                	jns    8011bf <fork+0x189>
  801185:	50                   	push   %eax
  801186:	68 1c 28 80 00       	push   $0x80281c
  80118b:	6a 5c                	push   $0x5c
  80118d:	68 d0 28 80 00       	push   $0x8028d0
  801192:	e8 11 f1 ff ff       	call   8002a8 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	6a 05                	push   $0x5
  80119c:	56                   	push   %esi
  80119d:	57                   	push   %edi
  80119e:	56                   	push   %esi
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 36 fc ff ff       	call   800ddc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8011a6:	83 c4 20             	add    $0x20,%esp
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	79 12                	jns    8011bf <fork+0x189>
  8011ad:	50                   	push   %eax
  8011ae:	68 1c 28 80 00       	push   $0x80281c
  8011b3:	6a 60                	push   $0x60
  8011b5:	68 d0 28 80 00       	push   $0x8028d0
  8011ba:	e8 e9 f0 ff ff       	call   8002a8 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8011bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011c5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8011cb:	0f 85 ca fe ff ff    	jne    80109b <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	6a 07                	push   $0x7
  8011d6:	68 00 f0 bf ee       	push   $0xeebff000
  8011db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011de:	e8 d5 fb ff ff       	call   800db8 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	79 15                	jns    8011ff <fork+0x1c9>
  8011ea:	50                   	push   %eax
  8011eb:	68 40 28 80 00       	push   $0x802840
  8011f0:	68 94 00 00 00       	push   $0x94
  8011f5:	68 d0 28 80 00       	push   $0x8028d0
  8011fa:	e8 a9 f0 ff ff       	call   8002a8 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	68 9c 1f 80 00       	push   $0x801f9c
  801207:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120a:	e8 5c fc ff ff       	call   800e6b <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	79 15                	jns    80122b <fork+0x1f5>
  801216:	50                   	push   %eax
  801217:	68 78 28 80 00       	push   $0x802878
  80121c:	68 99 00 00 00       	push   $0x99
  801221:	68 d0 28 80 00       	push   $0x8028d0
  801226:	e8 7d f0 ff ff       	call   8002a8 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	6a 02                	push   $0x2
  801230:	ff 75 e4             	pushl  -0x1c(%ebp)
  801233:	e8 ed fb ff ff       	call   800e25 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	79 15                	jns    801254 <fork+0x21e>
  80123f:	50                   	push   %eax
  801240:	68 9c 28 80 00       	push   $0x80289c
  801245:	68 a4 00 00 00       	push   $0xa4
  80124a:	68 d0 28 80 00       	push   $0x8028d0
  80124f:	e8 54 f0 ff ff       	call   8002a8 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <sfork>:

// Challenge!
int
sfork(void)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801265:	68 f8 28 80 00       	push   $0x8028f8
  80126a:	68 b1 00 00 00       	push   $0xb1
  80126f:	68 d0 28 80 00       	push   $0x8028d0
  801274:	e8 2f f0 ff ff       	call   8002a8 <_panic>
  801279:	00 00                	add    %al,(%eax)
	...

0080127c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	05 00 00 00 30       	add    $0x30000000,%eax
  801287:	c1 e8 0c             	shr    $0xc,%eax
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80128f:	ff 75 08             	pushl  0x8(%ebp)
  801292:	e8 e5 ff ff ff       	call   80127c <fd2num>
  801297:	83 c4 04             	add    $0x4,%esp
  80129a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80129f:	c1 e0 0c             	shl    $0xc,%eax
}
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	53                   	push   %ebx
  8012a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ab:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012b0:	a8 01                	test   $0x1,%al
  8012b2:	74 34                	je     8012e8 <fd_alloc+0x44>
  8012b4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012b9:	a8 01                	test   $0x1,%al
  8012bb:	74 32                	je     8012ef <fd_alloc+0x4b>
  8012bd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012c2:	89 c1                	mov    %eax,%ecx
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	c1 ea 16             	shr    $0x16,%edx
  8012c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d0:	f6 c2 01             	test   $0x1,%dl
  8012d3:	74 1f                	je     8012f4 <fd_alloc+0x50>
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	c1 ea 0c             	shr    $0xc,%edx
  8012da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e1:	f6 c2 01             	test   $0x1,%dl
  8012e4:	75 17                	jne    8012fd <fd_alloc+0x59>
  8012e6:	eb 0c                	jmp    8012f4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012e8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012ed:	eb 05                	jmp    8012f4 <fd_alloc+0x50>
  8012ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012f4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fb:	eb 17                	jmp    801314 <fd_alloc+0x70>
  8012fd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801302:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801307:	75 b9                	jne    8012c2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801309:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80130f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801314:	5b                   	pop    %ebx
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80131d:	83 f8 1f             	cmp    $0x1f,%eax
  801320:	77 36                	ja     801358 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801322:	05 00 00 0d 00       	add    $0xd0000,%eax
  801327:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132a:	89 c2                	mov    %eax,%edx
  80132c:	c1 ea 16             	shr    $0x16,%edx
  80132f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801336:	f6 c2 01             	test   $0x1,%dl
  801339:	74 24                	je     80135f <fd_lookup+0x48>
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	c1 ea 0c             	shr    $0xc,%edx
  801340:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	74 1a                	je     801366 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80134c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134f:	89 02                	mov    %eax,(%edx)
	return 0;
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
  801356:	eb 13                	jmp    80136b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801358:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135d:	eb 0c                	jmp    80136b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801364:	eb 05                	jmp    80136b <fd_lookup+0x54>
  801366:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	53                   	push   %ebx
  801371:	83 ec 04             	sub    $0x4,%esp
  801374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80137a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801380:	74 0d                	je     80138f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	eb 14                	jmp    80139d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801389:	39 0a                	cmp    %ecx,(%edx)
  80138b:	75 10                	jne    80139d <dev_lookup+0x30>
  80138d:	eb 05                	jmp    801394 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80138f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801394:	89 13                	mov    %edx,(%ebx)
			return 0;
  801396:	b8 00 00 00 00       	mov    $0x0,%eax
  80139b:	eb 31                	jmp    8013ce <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80139d:	40                   	inc    %eax
  80139e:	8b 14 85 8c 29 80 00 	mov    0x80298c(,%eax,4),%edx
  8013a5:	85 d2                	test   %edx,%edx
  8013a7:	75 e0                	jne    801389 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ae:	8b 40 48             	mov    0x48(%eax),%eax
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	51                   	push   %ecx
  8013b5:	50                   	push   %eax
  8013b6:	68 10 29 80 00       	push   $0x802910
  8013bb:	e8 c0 ef ff ff       	call   800380 <cprintf>
	*dev = 0;
  8013c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 20             	sub    $0x20,%esp
  8013db:	8b 75 08             	mov    0x8(%ebp),%esi
  8013de:	8a 45 0c             	mov    0xc(%ebp),%al
  8013e1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e4:	56                   	push   %esi
  8013e5:	e8 92 fe ff ff       	call   80127c <fd2num>
  8013ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013ed:	89 14 24             	mov    %edx,(%esp)
  8013f0:	50                   	push   %eax
  8013f1:	e8 21 ff ff ff       	call   801317 <fd_lookup>
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 05                	js     801404 <fd_close+0x31>
	    || fd != fd2)
  8013ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801402:	74 0d                	je     801411 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801404:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801408:	75 48                	jne    801452 <fd_close+0x7f>
  80140a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140f:	eb 41                	jmp    801452 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 36                	pushl  (%esi)
  80141a:	e8 4e ff ff ff       	call   80136d <dev_lookup>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 1c                	js     801444 <fd_close+0x71>
		if (dev->dev_close)
  801428:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142b:	8b 40 10             	mov    0x10(%eax),%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 0d                	je     80143f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	56                   	push   %esi
  801436:	ff d0                	call   *%eax
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	eb 05                	jmp    801444 <fd_close+0x71>
		else
			r = 0;
  80143f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	56                   	push   %esi
  801448:	6a 00                	push   $0x0
  80144a:	e8 b3 f9 ff ff       	call   800e02 <sys_page_unmap>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
}
  801452:	89 d8                	mov    %ebx,%eax
  801454:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	ff 75 08             	pushl  0x8(%ebp)
  801468:	e8 aa fe ff ff       	call   801317 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 10                	js     801484 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	6a 01                	push   $0x1
  801479:	ff 75 f4             	pushl  -0xc(%ebp)
  80147c:	e8 52 ff ff ff       	call   8013d3 <fd_close>
  801481:	83 c4 10             	add    $0x10,%esp
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <close_all>:

void
close_all(void)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	53                   	push   %ebx
  801496:	e8 c0 ff ff ff       	call   80145b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149b:	43                   	inc    %ebx
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	83 fb 20             	cmp    $0x20,%ebx
  8014a2:	75 ee                	jne    801492 <close_all+0xc>
		close(i);
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 2c             	sub    $0x2c,%esp
  8014b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	ff 75 08             	pushl  0x8(%ebp)
  8014bc:	e8 56 fe ff ff       	call   801317 <fd_lookup>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	0f 88 c0 00 00 00    	js     80158e <dup+0xe5>
		return r;
	close(newfdnum);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	57                   	push   %edi
  8014d2:	e8 84 ff ff ff       	call   80145b <close>

	newfd = INDEX2FD(newfdnum);
  8014d7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014dd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014e0:	83 c4 04             	add    $0x4,%esp
  8014e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e6:	e8 a1 fd ff ff       	call   80128c <fd2data>
  8014eb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ed:	89 34 24             	mov    %esi,(%esp)
  8014f0:	e8 97 fd ff ff       	call   80128c <fd2data>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	c1 e8 16             	shr    $0x16,%eax
  801500:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801507:	a8 01                	test   $0x1,%al
  801509:	74 37                	je     801542 <dup+0x99>
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	c1 e8 0c             	shr    $0xc,%eax
  801510:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801517:	f6 c2 01             	test   $0x1,%dl
  80151a:	74 26                	je     801542 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	25 07 0e 00 00       	and    $0xe07,%eax
  80152b:	50                   	push   %eax
  80152c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80152f:	6a 00                	push   $0x0
  801531:	53                   	push   %ebx
  801532:	6a 00                	push   $0x0
  801534:	e8 a3 f8 ff ff       	call   800ddc <sys_page_map>
  801539:	89 c3                	mov    %eax,%ebx
  80153b:	83 c4 20             	add    $0x20,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 2d                	js     80156f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801542:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801545:	89 c2                	mov    %eax,%edx
  801547:	c1 ea 0c             	shr    $0xc,%edx
  80154a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80155a:	52                   	push   %edx
  80155b:	56                   	push   %esi
  80155c:	6a 00                	push   $0x0
  80155e:	50                   	push   %eax
  80155f:	6a 00                	push   $0x0
  801561:	e8 76 f8 ff ff       	call   800ddc <sys_page_map>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	83 c4 20             	add    $0x20,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	79 1d                	jns    80158c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	56                   	push   %esi
  801573:	6a 00                	push   $0x0
  801575:	e8 88 f8 ff ff       	call   800e02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801580:	6a 00                	push   $0x0
  801582:	e8 7b f8 ff ff       	call   800e02 <sys_page_unmap>
	return r;
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb 02                	jmp    80158e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80158c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80158e:	89 d8                	mov    %ebx,%eax
  801590:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 14             	sub    $0x14,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	53                   	push   %ebx
  8015a7:	e8 6b fd ff ff       	call   801317 <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 67                	js     80161a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 a9 fd ff ff       	call   80136d <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 4f                	js     80161a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	8b 50 08             	mov    0x8(%eax),%edx
  8015d1:	83 e2 03             	and    $0x3,%edx
  8015d4:	83 fa 01             	cmp    $0x1,%edx
  8015d7:	75 21                	jne    8015fa <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015de:	8b 40 48             	mov    0x48(%eax),%eax
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	50                   	push   %eax
  8015e6:	68 51 29 80 00       	push   $0x802951
  8015eb:	e8 90 ed ff ff       	call   800380 <cprintf>
		return -E_INVAL;
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f8:	eb 20                	jmp    80161a <read+0x82>
	}
	if (!dev->dev_read)
  8015fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fd:	8b 52 08             	mov    0x8(%edx),%edx
  801600:	85 d2                	test   %edx,%edx
  801602:	74 11                	je     801615 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	ff 75 10             	pushl  0x10(%ebp)
  80160a:	ff 75 0c             	pushl  0xc(%ebp)
  80160d:	50                   	push   %eax
  80160e:	ff d2                	call   *%edx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	eb 05                	jmp    80161a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	57                   	push   %edi
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	8b 7d 08             	mov    0x8(%ebp),%edi
  80162b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162e:	85 f6                	test   %esi,%esi
  801630:	74 31                	je     801663 <readn+0x44>
  801632:	b8 00 00 00 00       	mov    $0x0,%eax
  801637:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	89 f2                	mov    %esi,%edx
  801641:	29 c2                	sub    %eax,%edx
  801643:	52                   	push   %edx
  801644:	03 45 0c             	add    0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	57                   	push   %edi
  801649:	e8 4a ff ff ff       	call   801598 <read>
		if (m < 0)
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 17                	js     80166c <readn+0x4d>
			return m;
		if (m == 0)
  801655:	85 c0                	test   %eax,%eax
  801657:	74 11                	je     80166a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801659:	01 c3                	add    %eax,%ebx
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	39 f3                	cmp    %esi,%ebx
  80165f:	72 db                	jb     80163c <readn+0x1d>
  801661:	eb 09                	jmp    80166c <readn+0x4d>
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
  801668:	eb 02                	jmp    80166c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80166a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80166c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	53                   	push   %ebx
  801678:	83 ec 14             	sub    $0x14,%esp
  80167b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	53                   	push   %ebx
  801683:	e8 8f fc ff ff       	call   801317 <fd_lookup>
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 62                	js     8016f1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	ff 30                	pushl  (%eax)
  80169b:	e8 cd fc ff ff       	call   80136d <dev_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 4a                	js     8016f1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ae:	75 21                	jne    8016d1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b5:	8b 40 48             	mov    0x48(%eax),%eax
  8016b8:	83 ec 04             	sub    $0x4,%esp
  8016bb:	53                   	push   %ebx
  8016bc:	50                   	push   %eax
  8016bd:	68 6d 29 80 00       	push   $0x80296d
  8016c2:	e8 b9 ec ff ff       	call   800380 <cprintf>
		return -E_INVAL;
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cf:	eb 20                	jmp    8016f1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d7:	85 d2                	test   %edx,%edx
  8016d9:	74 11                	je     8016ec <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	ff 75 10             	pushl  0x10(%ebp)
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	50                   	push   %eax
  8016e5:	ff d2                	call   *%edx
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	eb 05                	jmp    8016f1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ff:	50                   	push   %eax
  801700:	ff 75 08             	pushl  0x8(%ebp)
  801703:	e8 0f fc ff ff       	call   801317 <fd_lookup>
  801708:	83 c4 08             	add    $0x8,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 0e                	js     80171d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80170f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801712:	8b 55 0c             	mov    0xc(%ebp),%edx
  801715:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801718:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	53                   	push   %ebx
  801723:	83 ec 14             	sub    $0x14,%esp
  801726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801729:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	53                   	push   %ebx
  80172e:	e8 e4 fb ff ff       	call   801317 <fd_lookup>
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	78 5f                	js     801799 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801744:	ff 30                	pushl  (%eax)
  801746:	e8 22 fc ff ff       	call   80136d <dev_lookup>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 47                	js     801799 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801759:	75 21                	jne    80177c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80175b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801760:	8b 40 48             	mov    0x48(%eax),%eax
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	53                   	push   %ebx
  801767:	50                   	push   %eax
  801768:	68 30 29 80 00       	push   $0x802930
  80176d:	e8 0e ec ff ff       	call   800380 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80177a:	eb 1d                	jmp    801799 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80177c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177f:	8b 52 18             	mov    0x18(%edx),%edx
  801782:	85 d2                	test   %edx,%edx
  801784:	74 0e                	je     801794 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	ff 75 0c             	pushl  0xc(%ebp)
  80178c:	50                   	push   %eax
  80178d:	ff d2                	call   *%edx
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	eb 05                	jmp    801799 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801794:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	53                   	push   %ebx
  8017a2:	83 ec 14             	sub    $0x14,%esp
  8017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ab:	50                   	push   %eax
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 63 fb ff ff       	call   801317 <fd_lookup>
  8017b4:	83 c4 08             	add    $0x8,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 52                	js     80180d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c5:	ff 30                	pushl  (%eax)
  8017c7:	e8 a1 fb ff ff       	call   80136d <dev_lookup>
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	78 3a                	js     80180d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017da:	74 2c                	je     801808 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017e6:	00 00 00 
	stat->st_isdir = 0;
  8017e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f0:	00 00 00 
	stat->st_dev = dev;
  8017f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801800:	ff 50 14             	call   *0x14(%eax)
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 05                	jmp    80180d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80180d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	6a 00                	push   $0x0
  80181c:	ff 75 08             	pushl  0x8(%ebp)
  80181f:	e8 78 01 00 00       	call   80199c <open>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 1b                	js     801848 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	ff 75 0c             	pushl  0xc(%ebp)
  801833:	50                   	push   %eax
  801834:	e8 65 ff ff ff       	call   80179e <fstat>
  801839:	89 c6                	mov    %eax,%esi
	close(fd);
  80183b:	89 1c 24             	mov    %ebx,(%esp)
  80183e:	e8 18 fc ff ff       	call   80145b <close>
	return r;
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	89 f3                	mov    %esi,%ebx
}
  801848:	89 d8                	mov    %ebx,%eax
  80184a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5e                   	pop    %esi
  80184f:	c9                   	leave  
  801850:	c3                   	ret    
  801851:	00 00                	add    %al,(%eax)
	...

00801854 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80185d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801864:	75 12                	jne    801878 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	6a 01                	push   $0x1
  80186b:	e8 1e 08 00 00       	call   80208e <ipc_find_env>
  801870:	a3 00 40 80 00       	mov    %eax,0x804000
  801875:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801878:	6a 07                	push   $0x7
  80187a:	68 00 50 80 00       	push   $0x805000
  80187f:	53                   	push   %ebx
  801880:	ff 35 00 40 80 00    	pushl  0x804000
  801886:	e8 ae 07 00 00       	call   802039 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80188b:	83 c4 0c             	add    $0xc,%esp
  80188e:	6a 00                	push   $0x0
  801890:	56                   	push   %esi
  801891:	6a 00                	push   $0x0
  801893:	e8 2c 07 00 00       	call   801fc4 <ipc_recv>
}
  801898:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	83 ec 04             	sub    $0x4,%esp
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8018af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8018be:	e8 91 ff ff ff       	call   801854 <fsipc>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 2c                	js     8018f3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	68 00 50 80 00       	push   $0x805000
  8018cf:	53                   	push   %ebx
  8018d0:	e8 61 f0 ff ff       	call   800936 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	8b 40 0c             	mov    0xc(%eax),%eax
  801904:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
  80190e:	b8 06 00 00 00       	mov    $0x6,%eax
  801913:	e8 3c ff ff ff       	call   801854 <fsipc>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	8b 40 0c             	mov    0xc(%eax),%eax
  801928:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80192d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 03 00 00 00       	mov    $0x3,%eax
  80193d:	e8 12 ff ff ff       	call   801854 <fsipc>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	85 c0                	test   %eax,%eax
  801946:	78 4b                	js     801993 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801948:	39 c6                	cmp    %eax,%esi
  80194a:	73 16                	jae    801962 <devfile_read+0x48>
  80194c:	68 9c 29 80 00       	push   $0x80299c
  801951:	68 a3 29 80 00       	push   $0x8029a3
  801956:	6a 7d                	push   $0x7d
  801958:	68 b8 29 80 00       	push   $0x8029b8
  80195d:	e8 46 e9 ff ff       	call   8002a8 <_panic>
	assert(r <= PGSIZE);
  801962:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801967:	7e 16                	jle    80197f <devfile_read+0x65>
  801969:	68 c3 29 80 00       	push   $0x8029c3
  80196e:	68 a3 29 80 00       	push   $0x8029a3
  801973:	6a 7e                	push   $0x7e
  801975:	68 b8 29 80 00       	push   $0x8029b8
  80197a:	e8 29 e9 ff ff       	call   8002a8 <_panic>
	memmove(buf, &fsipcbuf, r);
  80197f:	83 ec 04             	sub    $0x4,%esp
  801982:	50                   	push   %eax
  801983:	68 00 50 80 00       	push   $0x805000
  801988:	ff 75 0c             	pushl  0xc(%ebp)
  80198b:	e8 67 f1 ff ff       	call   800af7 <memmove>
	return r;
  801990:	83 c4 10             	add    $0x10,%esp
}
  801993:	89 d8                	mov    %ebx,%eax
  801995:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801998:	5b                   	pop    %ebx
  801999:	5e                   	pop    %esi
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 1c             	sub    $0x1c,%esp
  8019a4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a7:	56                   	push   %esi
  8019a8:	e8 37 ef ff ff       	call   8008e4 <strlen>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b5:	7f 65                	jg     801a1c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 e1 f8 ff ff       	call   8012a4 <fd_alloc>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 55                	js     801a21 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	56                   	push   %esi
  8019d0:	68 00 50 80 00       	push   $0x805000
  8019d5:	e8 5c ef ff ff       	call   800936 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ea:	e8 65 fe ff ff       	call   801854 <fsipc>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 12                	jns    801a0a <open+0x6e>
		fd_close(fd, 0);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 ce f9 ff ff       	call   8013d3 <fd_close>
		return r;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	eb 17                	jmp    801a21 <open+0x85>
	}

	return fd2num(fd);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a10:	e8 67 f8 ff ff       	call   80127c <fd2num>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	eb 05                	jmp    801a21 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a21:	89 d8                	mov    %ebx,%eax
  801a23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    
	...

00801a2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	ff 75 08             	pushl  0x8(%ebp)
  801a3a:	e8 4d f8 ff ff       	call   80128c <fd2data>
  801a3f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a41:	83 c4 08             	add    $0x8,%esp
  801a44:	68 cf 29 80 00       	push   $0x8029cf
  801a49:	56                   	push   %esi
  801a4a:	e8 e7 ee ff ff       	call   800936 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a4f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a52:	2b 03                	sub    (%ebx),%eax
  801a54:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a5a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a61:	00 00 00 
	stat->st_dev = &devpipe;
  801a64:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a6b:	30 80 00 
	return 0;
}
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a84:	53                   	push   %ebx
  801a85:	6a 00                	push   $0x0
  801a87:	e8 76 f3 ff ff       	call   800e02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8c:	89 1c 24             	mov    %ebx,(%esp)
  801a8f:	e8 f8 f7 ff ff       	call   80128c <fd2data>
  801a94:	83 c4 08             	add    $0x8,%esp
  801a97:	50                   	push   %eax
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 63 f3 ff ff       	call   800e02 <sys_page_unmap>
}
  801a9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 1c             	sub    $0x1c,%esp
  801aad:	89 c7                	mov    %eax,%edi
  801aaf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	57                   	push   %edi
  801abe:	e8 19 06 00 00       	call   8020dc <pageref>
  801ac3:	89 c6                	mov    %eax,%esi
  801ac5:	83 c4 04             	add    $0x4,%esp
  801ac8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801acb:	e8 0c 06 00 00       	call   8020dc <pageref>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	39 c6                	cmp    %eax,%esi
  801ad5:	0f 94 c0             	sete   %al
  801ad8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801adb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae4:	39 cb                	cmp    %ecx,%ebx
  801ae6:	75 08                	jne    801af0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5f                   	pop    %edi
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801af0:	83 f8 01             	cmp    $0x1,%eax
  801af3:	75 bd                	jne    801ab2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af5:	8b 42 58             	mov    0x58(%edx),%eax
  801af8:	6a 01                	push   $0x1
  801afa:	50                   	push   %eax
  801afb:	53                   	push   %ebx
  801afc:	68 d6 29 80 00       	push   $0x8029d6
  801b01:	e8 7a e8 ff ff       	call   800380 <cprintf>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	eb a7                	jmp    801ab2 <_pipeisclosed+0xe>

00801b0b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	57                   	push   %edi
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 28             	sub    $0x28,%esp
  801b14:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b17:	56                   	push   %esi
  801b18:	e8 6f f7 ff ff       	call   80128c <fd2data>
  801b1d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b26:	75 4a                	jne    801b72 <devpipe_write+0x67>
  801b28:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2d:	eb 56                	jmp    801b85 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2f:	89 da                	mov    %ebx,%edx
  801b31:	89 f0                	mov    %esi,%eax
  801b33:	e8 6c ff ff ff       	call   801aa4 <_pipeisclosed>
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	75 4d                	jne    801b89 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b3c:	e8 50 f2 ff ff       	call   800d91 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b41:	8b 43 04             	mov    0x4(%ebx),%eax
  801b44:	8b 13                	mov    (%ebx),%edx
  801b46:	83 c2 20             	add    $0x20,%edx
  801b49:	39 d0                	cmp    %edx,%eax
  801b4b:	73 e2                	jae    801b2f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4d:	89 c2                	mov    %eax,%edx
  801b4f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b55:	79 05                	jns    801b5c <devpipe_write+0x51>
  801b57:	4a                   	dec    %edx
  801b58:	83 ca e0             	or     $0xffffffe0,%edx
  801b5b:	42                   	inc    %edx
  801b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b62:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b66:	40                   	inc    %eax
  801b67:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	47                   	inc    %edi
  801b6b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b6e:	77 07                	ja     801b77 <devpipe_write+0x6c>
  801b70:	eb 13                	jmp    801b85 <devpipe_write+0x7a>
  801b72:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b77:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7a:	8b 13                	mov    (%ebx),%edx
  801b7c:	83 c2 20             	add    $0x20,%edx
  801b7f:	39 d0                	cmp    %edx,%eax
  801b81:	73 ac                	jae    801b2f <devpipe_write+0x24>
  801b83:	eb c8                	jmp    801b4d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b85:	89 f8                	mov    %edi,%eax
  801b87:	eb 05                	jmp    801b8e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 18             	sub    $0x18,%esp
  801b9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba2:	57                   	push   %edi
  801ba3:	e8 e4 f6 ff ff       	call   80128c <fd2data>
  801ba8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb1:	75 44                	jne    801bf7 <devpipe_read+0x61>
  801bb3:	be 00 00 00 00       	mov    $0x0,%esi
  801bb8:	eb 4f                	jmp    801c09 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bba:	89 f0                	mov    %esi,%eax
  801bbc:	eb 54                	jmp    801c12 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bbe:	89 da                	mov    %ebx,%edx
  801bc0:	89 f8                	mov    %edi,%eax
  801bc2:	e8 dd fe ff ff       	call   801aa4 <_pipeisclosed>
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	75 42                	jne    801c0d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bcb:	e8 c1 f1 ff ff       	call   800d91 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd0:	8b 03                	mov    (%ebx),%eax
  801bd2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd5:	74 e7                	je     801bbe <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bdc:	79 05                	jns    801be3 <devpipe_read+0x4d>
  801bde:	48                   	dec    %eax
  801bdf:	83 c8 e0             	or     $0xffffffe0,%eax
  801be2:	40                   	inc    %eax
  801be3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bea:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bed:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bef:	46                   	inc    %esi
  801bf0:	39 75 10             	cmp    %esi,0x10(%ebp)
  801bf3:	77 07                	ja     801bfc <devpipe_read+0x66>
  801bf5:	eb 12                	jmp    801c09 <devpipe_read+0x73>
  801bf7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801bfc:	8b 03                	mov    (%ebx),%eax
  801bfe:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c01:	75 d4                	jne    801bd7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c03:	85 f6                	test   %esi,%esi
  801c05:	75 b3                	jne    801bba <devpipe_read+0x24>
  801c07:	eb b5                	jmp    801bbe <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	eb 05                	jmp    801c12 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    

00801c1a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	57                   	push   %edi
  801c1e:	56                   	push   %esi
  801c1f:	53                   	push   %ebx
  801c20:	83 ec 28             	sub    $0x28,%esp
  801c23:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c26:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 75 f6 ff ff       	call   8012a4 <fd_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 24 01 00 00    	js     801d60 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3c:	83 ec 04             	sub    $0x4,%esp
  801c3f:	68 07 04 00 00       	push   $0x407
  801c44:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c47:	6a 00                	push   $0x0
  801c49:	e8 6a f1 ff ff       	call   800db8 <sys_page_alloc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 05 01 00 00    	js     801d60 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 3d f6 ff ff       	call   8012a4 <fd_alloc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 dc 00 00 00    	js     801d50 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 32 f1 ff ff       	call   800db8 <sys_page_alloc>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	0f 88 bd 00 00 00    	js     801d50 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c99:	e8 ee f5 ff ff       	call   80128c <fd2data>
  801c9e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca0:	83 c4 0c             	add    $0xc,%esp
  801ca3:	68 07 04 00 00       	push   $0x407
  801ca8:	50                   	push   %eax
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 08 f1 ff ff       	call   800db8 <sys_page_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 83 00 00 00    	js     801d40 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	ff 75 e0             	pushl  -0x20(%ebp)
  801cc3:	e8 c4 f5 ff ff       	call   80128c <fd2data>
  801cc8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ccf:	50                   	push   %eax
  801cd0:	6a 00                	push   $0x0
  801cd2:	56                   	push   %esi
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 02 f1 ff ff       	call   800ddc <sys_page_map>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	83 c4 20             	add    $0x20,%esp
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 4f                	js     801d32 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cec:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d01:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d03:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d06:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d0d:	83 ec 0c             	sub    $0xc,%esp
  801d10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d13:	e8 64 f5 ff ff       	call   80127c <fd2num>
  801d18:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d1a:	83 c4 04             	add    $0x4,%esp
  801d1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801d20:	e8 57 f5 ff ff       	call   80127c <fd2num>
  801d25:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d30:	eb 2e                	jmp    801d60 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	56                   	push   %esi
  801d36:	6a 00                	push   $0x0
  801d38:	e8 c5 f0 ff ff       	call   800e02 <sys_page_unmap>
  801d3d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d40:	83 ec 08             	sub    $0x8,%esp
  801d43:	ff 75 e0             	pushl  -0x20(%ebp)
  801d46:	6a 00                	push   $0x0
  801d48:	e8 b5 f0 ff ff       	call   800e02 <sys_page_unmap>
  801d4d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d50:	83 ec 08             	sub    $0x8,%esp
  801d53:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d56:	6a 00                	push   $0x0
  801d58:	e8 a5 f0 ff ff       	call   800e02 <sys_page_unmap>
  801d5d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d60:	89 d8                	mov    %ebx,%eax
  801d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	ff 75 08             	pushl  0x8(%ebp)
  801d77:	e8 9b f5 ff ff       	call   801317 <fd_lookup>
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 18                	js     801d9b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	ff 75 f4             	pushl  -0xc(%ebp)
  801d89:	e8 fe f4 ff ff       	call   80128c <fd2data>
	return _pipeisclosed(fd, p);
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	e8 0c fd ff ff       	call   801aa4 <_pipeisclosed>
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    
  801d9d:	00 00                	add    %al,(%eax)
	...

00801da0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db0:	68 e9 29 80 00       	push   $0x8029e9
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	e8 79 eb ff ff       	call   800936 <strcpy>
	return 0;
}
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	57                   	push   %edi
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd4:	74 45                	je     801e1b <devcons_write+0x57>
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801deb:	83 fb 7f             	cmp    $0x7f,%ebx
  801dee:	76 05                	jbe    801df5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801df0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	53                   	push   %ebx
  801df9:	03 45 0c             	add    0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	57                   	push   %edi
  801dfe:	e8 f4 ec ff ff       	call   800af7 <memmove>
		sys_cputs(buf, m);
  801e03:	83 c4 08             	add    $0x8,%esp
  801e06:	53                   	push   %ebx
  801e07:	57                   	push   %edi
  801e08:	e8 f4 ee ff ff       	call   800d01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0d:	01 de                	add    %ebx,%esi
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e17:	72 cd                	jb     801de6 <devcons_write+0x22>
  801e19:	eb 05                	jmp    801e20 <devcons_write+0x5c>
  801e1b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e34:	75 07                	jne    801e3d <devcons_read+0x13>
  801e36:	eb 25                	jmp    801e5d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e38:	e8 54 ef ff ff       	call   800d91 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e3d:	e8 e5 ee ff ff       	call   800d27 <sys_cgetc>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	74 f2                	je     801e38 <devcons_read+0xe>
  801e46:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	78 1d                	js     801e69 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e4c:	83 f8 04             	cmp    $0x4,%eax
  801e4f:	74 13                	je     801e64 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e54:	88 10                	mov    %dl,(%eax)
	return 1;
  801e56:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5b:	eb 0c                	jmp    801e69 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e62:	eb 05                	jmp    801e69 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e77:	6a 01                	push   $0x1
  801e79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	e8 7f ee ff ff       	call   800d01 <sys_cputs>
  801e82:	83 c4 10             	add    $0x10,%esp
}
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <getchar>:

int
getchar(void)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e8d:	6a 01                	push   $0x1
  801e8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	6a 00                	push   $0x0
  801e95:	e8 fe f6 ff ff       	call   801598 <read>
	if (r < 0)
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 0f                	js     801eb0 <getchar+0x29>
		return r;
	if (r < 1)
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	7e 06                	jle    801eab <getchar+0x24>
		return -E_EOF;
	return c;
  801ea5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ea9:	eb 05                	jmp    801eb0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	ff 75 08             	pushl  0x8(%ebp)
  801ebf:	e8 53 f4 ff ff       	call   801317 <fd_lookup>
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 11                	js     801edc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ece:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed4:	39 10                	cmp    %edx,(%eax)
  801ed6:	0f 94 c0             	sete   %al
  801ed9:	0f b6 c0             	movzbl %al,%eax
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <opencons>:

int
opencons(void)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	e8 b7 f3 ff ff       	call   8012a4 <fd_alloc>
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 3a                	js     801f2e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef4:	83 ec 04             	sub    $0x4,%esp
  801ef7:	68 07 04 00 00       	push   $0x407
  801efc:	ff 75 f4             	pushl  -0xc(%ebp)
  801eff:	6a 00                	push   $0x0
  801f01:	e8 b2 ee ff ff       	call   800db8 <sys_page_alloc>
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 21                	js     801f2e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f16:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	50                   	push   %eax
  801f26:	e8 51 f3 ff ff       	call   80127c <fd2num>
  801f2b:	83 c4 10             	add    $0x10,%esp
}
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f36:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f3d:	75 52                	jne    801f91 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	6a 07                	push   $0x7
  801f44:	68 00 f0 bf ee       	push   $0xeebff000
  801f49:	6a 00                	push   $0x0
  801f4b:	e8 68 ee ff ff       	call   800db8 <sys_page_alloc>
		if (r < 0) {
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	85 c0                	test   %eax,%eax
  801f55:	79 12                	jns    801f69 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801f57:	50                   	push   %eax
  801f58:	68 f5 29 80 00       	push   $0x8029f5
  801f5d:	6a 24                	push   $0x24
  801f5f:	68 10 2a 80 00       	push   $0x802a10
  801f64:	e8 3f e3 ff ff       	call   8002a8 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	68 9c 1f 80 00       	push   $0x801f9c
  801f71:	6a 00                	push   $0x0
  801f73:	e8 f3 ee ff ff       	call   800e6b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	79 12                	jns    801f91 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f7f:	50                   	push   %eax
  801f80:	68 20 2a 80 00       	push   $0x802a20
  801f85:	6a 2a                	push   $0x2a
  801f87:	68 10 2a 80 00       	push   $0x802a10
  801f8c:	e8 17 e3 ff ff       	call   8002a8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f91:	8b 45 08             	mov    0x8(%ebp),%eax
  801f94:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    
	...

00801f9c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f9d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801fa7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801fab:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801fae:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801fb2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801fb6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801fb8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801fbb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801fbc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801fbf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fc0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fc1:	c3                   	ret    
	...

00801fc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	74 0e                	je     801fe4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	50                   	push   %eax
  801fda:	e8 d4 ee ff ff       	call   800eb3 <sys_ipc_recv>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	eb 10                	jmp    801ff4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	68 00 00 c0 ee       	push   $0xeec00000
  801fec:	e8 c2 ee ff ff       	call   800eb3 <sys_ipc_recv>
  801ff1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	75 26                	jne    80201e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ff8:	85 f6                	test   %esi,%esi
  801ffa:	74 0a                	je     802006 <ipc_recv+0x42>
  801ffc:	a1 04 40 80 00       	mov    0x804004,%eax
  802001:	8b 40 74             	mov    0x74(%eax),%eax
  802004:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802006:	85 db                	test   %ebx,%ebx
  802008:	74 0a                	je     802014 <ipc_recv+0x50>
  80200a:	a1 04 40 80 00       	mov    0x804004,%eax
  80200f:	8b 40 78             	mov    0x78(%eax),%eax
  802012:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802014:	a1 04 40 80 00       	mov    0x804004,%eax
  802019:	8b 40 70             	mov    0x70(%eax),%eax
  80201c:	eb 14                	jmp    802032 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80201e:	85 f6                	test   %esi,%esi
  802020:	74 06                	je     802028 <ipc_recv+0x64>
  802022:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802028:	85 db                	test   %ebx,%ebx
  80202a:	74 06                	je     802032 <ipc_recv+0x6e>
  80202c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802032:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	57                   	push   %edi
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802045:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802048:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80204b:	85 db                	test   %ebx,%ebx
  80204d:	75 25                	jne    802074 <ipc_send+0x3b>
  80204f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802054:	eb 1e                	jmp    802074 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802056:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802059:	75 07                	jne    802062 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80205b:	e8 31 ed ff ff       	call   800d91 <sys_yield>
  802060:	eb 12                	jmp    802074 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802062:	50                   	push   %eax
  802063:	68 48 2a 80 00       	push   $0x802a48
  802068:	6a 43                	push   $0x43
  80206a:	68 5b 2a 80 00       	push   $0x802a5b
  80206f:	e8 34 e2 ff ff       	call   8002a8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802074:	56                   	push   %esi
  802075:	53                   	push   %ebx
  802076:	57                   	push   %edi
  802077:	ff 75 08             	pushl  0x8(%ebp)
  80207a:	e8 0f ee ff ff       	call   800e8e <sys_ipc_try_send>
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	75 d0                	jne    802056 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802094:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80209a:	74 1a                	je     8020b6 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80209c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8020a1:	89 c2                	mov    %eax,%edx
  8020a3:	c1 e2 07             	shl    $0x7,%edx
  8020a6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8020ad:	8b 52 50             	mov    0x50(%edx),%edx
  8020b0:	39 ca                	cmp    %ecx,%edx
  8020b2:	75 18                	jne    8020cc <ipc_find_env+0x3e>
  8020b4:	eb 05                	jmp    8020bb <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	c1 e2 07             	shl    $0x7,%edx
  8020c0:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8020c7:	8b 40 40             	mov    0x40(%eax),%eax
  8020ca:	eb 0c                	jmp    8020d8 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020cc:	40                   	inc    %eax
  8020cd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d2:	75 cd                	jne    8020a1 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d4:	66 b8 00 00          	mov    $0x0,%ax
}
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    
	...

008020dc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e2:	89 c2                	mov    %eax,%edx
  8020e4:	c1 ea 16             	shr    $0x16,%edx
  8020e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020ee:	f6 c2 01             	test   $0x1,%dl
  8020f1:	74 1e                	je     802111 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f3:	c1 e8 0c             	shr    $0xc,%eax
  8020f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020fd:	a8 01                	test   $0x1,%al
  8020ff:	74 17                	je     802118 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802101:	c1 e8 0c             	shr    $0xc,%eax
  802104:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80210b:	ef 
  80210c:	0f b7 c0             	movzwl %ax,%eax
  80210f:	eb 0c                	jmp    80211d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
  802116:	eb 05                	jmp    80211d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802118:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    
	...

00802120 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	83 ec 10             	sub    $0x10,%esp
  802128:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80212e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802131:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802134:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802137:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80213a:	85 c0                	test   %eax,%eax
  80213c:	75 2e                	jne    80216c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80213e:	39 f1                	cmp    %esi,%ecx
  802140:	77 5a                	ja     80219c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802142:	85 c9                	test   %ecx,%ecx
  802144:	75 0b                	jne    802151 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f1                	div    %ecx
  80214f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802151:	31 d2                	xor    %edx,%edx
  802153:	89 f0                	mov    %esi,%eax
  802155:	f7 f1                	div    %ecx
  802157:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802159:	89 f8                	mov    %edi,%eax
  80215b:	f7 f1                	div    %ecx
  80215d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80215f:	89 f8                	mov    %edi,%eax
  802161:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	c9                   	leave  
  802169:	c3                   	ret    
  80216a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80216c:	39 f0                	cmp    %esi,%eax
  80216e:	77 1c                	ja     80218c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802170:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802173:	83 f7 1f             	xor    $0x1f,%edi
  802176:	75 3c                	jne    8021b4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802178:	39 f0                	cmp    %esi,%eax
  80217a:	0f 82 90 00 00 00    	jb     802210 <__udivdi3+0xf0>
  802180:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802183:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802186:	0f 86 84 00 00 00    	jbe    802210 <__udivdi3+0xf0>
  80218c:	31 f6                	xor    %esi,%esi
  80218e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802190:	89 f8                	mov    %edi,%eax
  802192:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	c9                   	leave  
  80219a:	c3                   	ret    
  80219b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80219c:	89 f2                	mov    %esi,%edx
  80219e:	89 f8                	mov    %edi,%eax
  8021a0:	f7 f1                	div    %ecx
  8021a2:	89 c7                	mov    %eax,%edi
  8021a4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021a6:	89 f8                	mov    %edi,%eax
  8021a8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	c9                   	leave  
  8021b0:	c3                   	ret    
  8021b1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8021b4:	89 f9                	mov    %edi,%ecx
  8021b6:	d3 e0                	shl    %cl,%eax
  8021b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8021bb:	b8 20 00 00 00       	mov    $0x20,%eax
  8021c0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8021c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021c5:	88 c1                	mov    %al,%cl
  8021c7:	d3 ea                	shr    %cl,%edx
  8021c9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021cc:	09 ca                	or     %ecx,%edx
  8021ce:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8021d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d4:	89 f9                	mov    %edi,%ecx
  8021d6:	d3 e2                	shl    %cl,%edx
  8021d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021db:	89 f2                	mov    %esi,%edx
  8021dd:	88 c1                	mov    %al,%cl
  8021df:	d3 ea                	shr    %cl,%edx
  8021e1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021e4:	89 f2                	mov    %esi,%edx
  8021e6:	89 f9                	mov    %edi,%ecx
  8021e8:	d3 e2                	shl    %cl,%edx
  8021ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021ed:	88 c1                	mov    %al,%cl
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021f3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021f6:	89 f0                	mov    %esi,%eax
  8021f8:	89 ca                	mov    %ecx,%edx
  8021fa:	f7 75 ec             	divl   -0x14(%ebp)
  8021fd:	89 d1                	mov    %edx,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802201:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802204:	39 d1                	cmp    %edx,%ecx
  802206:	72 28                	jb     802230 <__udivdi3+0x110>
  802208:	74 1a                	je     802224 <__udivdi3+0x104>
  80220a:	89 f7                	mov    %esi,%edi
  80220c:	31 f6                	xor    %esi,%esi
  80220e:	eb 80                	jmp    802190 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802210:	31 f6                	xor    %esi,%esi
  802212:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802217:	89 f8                	mov    %edi,%eax
  802219:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80221b:	83 c4 10             	add    $0x10,%esp
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	c9                   	leave  
  802221:	c3                   	ret    
  802222:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802224:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802227:	89 f9                	mov    %edi,%ecx
  802229:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80222b:	39 c2                	cmp    %eax,%edx
  80222d:	73 db                	jae    80220a <__udivdi3+0xea>
  80222f:	90                   	nop
		{
		  q0--;
  802230:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802233:	31 f6                	xor    %esi,%esi
  802235:	e9 56 ff ff ff       	jmp    802190 <__udivdi3+0x70>
	...

0080223c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	57                   	push   %edi
  802240:	56                   	push   %esi
  802241:	83 ec 20             	sub    $0x20,%esp
  802244:	8b 45 08             	mov    0x8(%ebp),%eax
  802247:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80224a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80224d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802250:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802253:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802256:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802259:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80225b:	85 ff                	test   %edi,%edi
  80225d:	75 15                	jne    802274 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80225f:	39 f1                	cmp    %esi,%ecx
  802261:	0f 86 99 00 00 00    	jbe    802300 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802267:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802269:	89 d0                	mov    %edx,%eax
  80226b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80226d:	83 c4 20             	add    $0x20,%esp
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	c9                   	leave  
  802273:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802274:	39 f7                	cmp    %esi,%edi
  802276:	0f 87 a4 00 00 00    	ja     802320 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80227c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80227f:	83 f0 1f             	xor    $0x1f,%eax
  802282:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802285:	0f 84 a1 00 00 00    	je     80232c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80228b:	89 f8                	mov    %edi,%eax
  80228d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802290:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802292:	bf 20 00 00 00       	mov    $0x20,%edi
  802297:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80229a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80229d:	89 f9                	mov    %edi,%ecx
  80229f:	d3 ea                	shr    %cl,%edx
  8022a1:	09 c2                	or     %eax,%edx
  8022a3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8022a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022b1:	89 f2                	mov    %esi,%edx
  8022b3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8022b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022b8:	d3 e0                	shl    %cl,%eax
  8022ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8022bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022c0:	89 f9                	mov    %edi,%ecx
  8022c2:	d3 e8                	shr    %cl,%eax
  8022c4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8022c6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022c8:	89 f2                	mov    %esi,%edx
  8022ca:	f7 75 f0             	divl   -0x10(%ebp)
  8022cd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022cf:	f7 65 f4             	mull   -0xc(%ebp)
  8022d2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022d5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022d7:	39 d6                	cmp    %edx,%esi
  8022d9:	72 71                	jb     80234c <__umoddi3+0x110>
  8022db:	74 7f                	je     80235c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e0:	29 c8                	sub    %ecx,%eax
  8022e2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022e4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 f2                	mov    %esi,%edx
  8022eb:	89 f9                	mov    %edi,%ecx
  8022ed:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022ef:	09 d0                	or     %edx,%eax
  8022f1:	89 f2                	mov    %esi,%edx
  8022f3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022f6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f8:	83 c4 20             	add    $0x20,%esp
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	c9                   	leave  
  8022fe:	c3                   	ret    
  8022ff:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802300:	85 c9                	test   %ecx,%ecx
  802302:	75 0b                	jne    80230f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802304:	b8 01 00 00 00       	mov    $0x1,%eax
  802309:	31 d2                	xor    %edx,%edx
  80230b:	f7 f1                	div    %ecx
  80230d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80230f:	89 f0                	mov    %esi,%eax
  802311:	31 d2                	xor    %edx,%edx
  802313:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802318:	f7 f1                	div    %ecx
  80231a:	e9 4a ff ff ff       	jmp    802269 <__umoddi3+0x2d>
  80231f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802320:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802322:	83 c4 20             	add    $0x20,%esp
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	c9                   	leave  
  802328:	c3                   	ret    
  802329:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	72 05                	jb     802335 <__umoddi3+0xf9>
  802330:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802333:	77 0c                	ja     802341 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802335:	89 f2                	mov    %esi,%edx
  802337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80233a:	29 c8                	sub    %ecx,%eax
  80233c:	19 fa                	sbb    %edi,%edx
  80233e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802344:	83 c4 20             	add    $0x20,%esp
  802347:	5e                   	pop    %esi
  802348:	5f                   	pop    %edi
  802349:	c9                   	leave  
  80234a:	c3                   	ret    
  80234b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80234c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80234f:	89 c1                	mov    %eax,%ecx
  802351:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802354:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802357:	eb 84                	jmp    8022dd <__umoddi3+0xa1>
  802359:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80235c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80235f:	72 eb                	jb     80234c <__umoddi3+0x110>
  802361:	89 f2                	mov    %esi,%edx
  802363:	e9 75 ff ff ff       	jmp    8022dd <__umoddi3+0xa1>
