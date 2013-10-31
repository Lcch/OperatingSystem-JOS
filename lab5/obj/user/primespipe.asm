
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
  80004d:	e8 69 15 00 00       	call   8015bb <readn>
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
  80006a:	68 20 23 80 00       	push   $0x802320
  80006f:	6a 15                	push   $0x15
  800071:	68 4f 23 80 00       	push   $0x80234f
  800076:	e8 31 02 00 00       	call   8002ac <_panic>

	cprintf("%d\n", p);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	ff 75 e0             	pushl  -0x20(%ebp)
  800081:	68 61 23 80 00       	push   $0x802361
  800086:	e8 f9 02 00 00       	call   800384 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  80008b:	89 3c 24             	mov    %edi,(%esp)
  80008e:	e8 23 1b 00 00       	call   801bb6 <pipe>
  800093:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <primeproc+0x7b>
		panic("pipe: %e", i);
  80009d:	50                   	push   %eax
  80009e:	68 65 23 80 00       	push   $0x802365
  8000a3:	6a 1b                	push   $0x1b
  8000a5:	68 4f 23 80 00       	push   $0x80234f
  8000aa:	e8 fd 01 00 00       	call   8002ac <_panic>
	if ((id = fork()) < 0)
  8000af:	e8 1a 0f 00 00       	call   800fce <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <primeproc+0x96>
		panic("fork: %e", id);
  8000b8:	50                   	push   %eax
  8000b9:	68 6e 23 80 00       	push   $0x80236e
  8000be:	6a 1d                	push   $0x1d
  8000c0:	68 4f 23 80 00       	push   $0x80234f
  8000c5:	e8 e2 01 00 00       	call   8002ac <_panic>
	if (id == 0) {
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 1f                	jne    8000ed <primeproc+0xb9>
		close(fd);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 20 13 00 00       	call   8013f7 <close>
		close(pfd[1]);
  8000d7:	83 c4 04             	add    $0x4,%esp
  8000da:	ff 75 dc             	pushl  -0x24(%ebp)
  8000dd:	e8 15 13 00 00       	call   8013f7 <close>
		fd = pfd[0];
  8000e2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	e9 59 ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f3:	e8 ff 12 00 00       	call   8013f7 <close>
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
  800108:	e8 ae 14 00 00       	call   8015bb <readn>
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
  800129:	68 77 23 80 00       	push   $0x802377
  80012e:	6a 2b                	push   $0x2b
  800130:	68 4f 23 80 00       	push   $0x80234f
  800135:	e8 72 01 00 00       	call   8002ac <_panic>
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
  80014c:	e8 bf 14 00 00       	call   801610 <write>
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
  80016c:	68 93 23 80 00       	push   $0x802393
  800171:	6a 2e                	push   $0x2e
  800173:	68 4f 23 80 00       	push   $0x80234f
  800178:	e8 2f 01 00 00       	call   8002ac <_panic>

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
  800184:	c7 05 00 30 80 00 ad 	movl   $0x8023ad,0x803000
  80018b:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	e8 1f 1a 00 00       	call   801bb6 <pipe>
  800197:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	85 c0                	test   %eax,%eax
  80019f:	79 12                	jns    8001b3 <umain+0x36>
		panic("pipe: %e", i);
  8001a1:	50                   	push   %eax
  8001a2:	68 65 23 80 00       	push   $0x802365
  8001a7:	6a 3a                	push   $0x3a
  8001a9:	68 4f 23 80 00       	push   $0x80234f
  8001ae:	e8 f9 00 00 00       	call   8002ac <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001b3:	e8 16 0e 00 00       	call   800fce <fork>
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	79 12                	jns    8001ce <umain+0x51>
		panic("fork: %e", id);
  8001bc:	50                   	push   %eax
  8001bd:	68 6e 23 80 00       	push   $0x80236e
  8001c2:	6a 3e                	push   $0x3e
  8001c4:	68 4f 23 80 00       	push   $0x80234f
  8001c9:	e8 de 00 00 00       	call   8002ac <_panic>

	if (id == 0) {
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	75 19                	jne    8001eb <umain+0x6e>
		close(p[1]);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d8:	e8 1a 12 00 00       	call   8013f7 <close>
		primeproc(p[0]);
  8001dd:	83 c4 04             	add    $0x4,%esp
  8001e0:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e3:	e8 4c fe ff ff       	call   800034 <primeproc>
  8001e8:	83 c4 10             	add    $0x10,%esp
	}

	close(p[0]);
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 ec             	pushl  -0x14(%ebp)
  8001f1:	e8 01 12 00 00       	call   8013f7 <close>

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
  80020c:	e8 ff 13 00 00       	call   801610 <write>
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
  800229:	68 b8 23 80 00       	push   $0x8023b8
  80022e:	6a 4a                	push   $0x4a
  800230:	68 4f 23 80 00       	push   $0x80234f
  800235:	e8 72 00 00 00       	call   8002ac <_panic>
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
  80024b:	e8 21 0b 00 00       	call   800d71 <sys_getenvid>
  800250:	25 ff 03 00 00       	and    $0x3ff,%eax
  800255:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80025c:	c1 e0 07             	shl    $0x7,%eax
  80025f:	29 d0                	sub    %edx,%eax
  800261:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800266:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80026b:	85 f6                	test   %esi,%esi
  80026d:	7e 07                	jle    800276 <libmain+0x36>
		binaryname = argv[0];
  80026f:	8b 03                	mov    (%ebx),%eax
  800271:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	53                   	push   %ebx
  80027a:	56                   	push   %esi
  80027b:	e8 fd fe ff ff       	call   80017d <umain>

	// exit gracefully
	exit();
  800280:	e8 0b 00 00 00       	call   800290 <exit>
  800285:	83 c4 10             	add    $0x10,%esp
}
  800288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    
	...

00800290 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800296:	e8 87 11 00 00       	call   801422 <close_all>
	sys_env_destroy(0);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	6a 00                	push   $0x0
  8002a0:	e8 aa 0a 00 00       	call   800d4f <sys_env_destroy>
  8002a5:	83 c4 10             	add    $0x10,%esp
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    
	...

008002ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002b1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002ba:	e8 b2 0a 00 00       	call   800d71 <sys_getenvid>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	53                   	push   %ebx
  8002c9:	50                   	push   %eax
  8002ca:	68 dc 23 80 00       	push   $0x8023dc
  8002cf:	e8 b0 00 00 00       	call   800384 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	56                   	push   %esi
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	e8 53 00 00 00       	call   800333 <vcprintf>
	cprintf("\n");
  8002e0:	c7 04 24 63 23 80 00 	movl   $0x802363,(%esp)
  8002e7:	e8 98 00 00 00       	call   800384 <cprintf>
  8002ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ef:	cc                   	int3   
  8002f0:	eb fd                	jmp    8002ef <_panic+0x43>
	...

008002f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 04             	sub    $0x4,%esp
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fe:	8b 03                	mov    (%ebx),%eax
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800307:	40                   	inc    %eax
  800308:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030f:	75 1a                	jne    80032b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	68 ff 00 00 00       	push   $0xff
  800319:	8d 43 08             	lea    0x8(%ebx),%eax
  80031c:	50                   	push   %eax
  80031d:	e8 e3 09 00 00       	call   800d05 <sys_cputs>
		b->idx = 0;
  800322:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800328:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80032b:	ff 43 04             	incl   0x4(%ebx)
}
  80032e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80033c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800343:	00 00 00 
	b.cnt = 0;
  800346:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80034d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80035c:	50                   	push   %eax
  80035d:	68 f4 02 80 00       	push   $0x8002f4
  800362:	e8 82 01 00 00       	call   8004e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800367:	83 c4 08             	add    $0x8,%esp
  80036a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800370:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800376:	50                   	push   %eax
  800377:	e8 89 09 00 00       	call   800d05 <sys_cputs>

	return b.cnt;
}
  80037c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80038d:	50                   	push   %eax
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 9d ff ff ff       	call   800333 <vcprintf>
	va_end(ap);

	return cnt;
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 2c             	sub    $0x2c,%esp
  8003a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a4:	89 d6                	mov    %edx,%esi
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003c5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8003c8:	72 0c                	jb     8003d6 <printnum+0x3e>
  8003ca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003cd:	76 07                	jbe    8003d6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cf:	4b                   	dec    %ebx
  8003d0:	85 db                	test   %ebx,%ebx
  8003d2:	7f 31                	jg     800405 <printnum+0x6d>
  8003d4:	eb 3f                	jmp    800415 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d6:	83 ec 0c             	sub    $0xc,%esp
  8003d9:	57                   	push   %edi
  8003da:	4b                   	dec    %ebx
  8003db:	53                   	push   %ebx
  8003dc:	50                   	push   %eax
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8003e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ec:	e8 db 1c 00 00       	call   8020cc <__udivdi3>
  8003f1:	83 c4 18             	add    $0x18,%esp
  8003f4:	52                   	push   %edx
  8003f5:	50                   	push   %eax
  8003f6:	89 f2                	mov    %esi,%edx
  8003f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fb:	e8 98 ff ff ff       	call   800398 <printnum>
  800400:	83 c4 20             	add    $0x20,%esp
  800403:	eb 10                	jmp    800415 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	56                   	push   %esi
  800409:	57                   	push   %edi
  80040a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040d:	4b                   	dec    %ebx
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	85 db                	test   %ebx,%ebx
  800413:	7f f0                	jg     800405 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	56                   	push   %esi
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	e8 bb 1d 00 00       	call   8021e8 <__umoddi3>
  80042d:	83 c4 14             	add    $0x14,%esp
  800430:	0f be 80 ff 23 80 00 	movsbl 0x8023ff(%eax),%eax
  800437:	50                   	push   %eax
  800438:	ff 55 e4             	call   *-0x1c(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
}
  80043e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800449:	83 fa 01             	cmp    $0x1,%edx
  80044c:	7e 0e                	jle    80045c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	eb 22                	jmp    80047e <getuint+0x38>
	else if (lflag)
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 10                	je     800470 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	eb 0e                	jmp    80047e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800483:	83 fa 01             	cmp    $0x1,%edx
  800486:	7e 0e                	jle    800496 <getint+0x16>
		return va_arg(*ap, long long);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	8b 52 04             	mov    0x4(%edx),%edx
  800494:	eb 1a                	jmp    8004b0 <getint+0x30>
	else if (lflag)
  800496:	85 d2                	test   %edx,%edx
  800498:	74 0c                	je     8004a6 <getint+0x26>
		return va_arg(*ap, long);
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049f:	89 08                	mov    %ecx,(%eax)
  8004a1:	8b 02                	mov    (%edx),%eax
  8004a3:	99                   	cltd   
  8004a4:	eb 0a                	jmp    8004b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8004a6:	8b 10                	mov    (%eax),%edx
  8004a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ab:	89 08                	mov    %ecx,(%eax)
  8004ad:	8b 02                	mov    (%edx),%eax
  8004af:	99                   	cltd   
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c0:	73 08                	jae    8004ca <sprintputch+0x18>
		*b->buf++ = ch;
  8004c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c5:	88 0a                	mov    %cl,(%edx)
  8004c7:	42                   	inc    %edx
  8004c8:	89 10                	mov    %edx,(%eax)
}
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d5:	50                   	push   %eax
  8004d6:	ff 75 10             	pushl  0x10(%ebp)
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 05 00 00 00       	call   8004e9 <vprintfmt>
	va_end(ap);
  8004e4:	83 c4 10             	add    $0x10,%esp
}
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    

008004e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	53                   	push   %ebx
  8004ef:	83 ec 2c             	sub    $0x2c,%esp
  8004f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f8:	eb 13                	jmp    80050d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	0f 84 6d 03 00 00    	je     80086f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	57                   	push   %edi
  800506:	50                   	push   %eax
  800507:	ff 55 08             	call   *0x8(%ebp)
  80050a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050d:	0f b6 06             	movzbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	83 f8 25             	cmp    $0x25,%eax
  800514:	75 e4                	jne    8004fa <vprintfmt+0x11>
  800516:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80051a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800521:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800528:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800534:	eb 28                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800538:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80053c:	eb 20                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800540:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800544:	eb 18                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800548:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054f:	eb 0d                	jmp    80055e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800551:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800557:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8a 06                	mov    (%esi),%al
  800560:	0f b6 d0             	movzbl %al,%edx
  800563:	8d 5e 01             	lea    0x1(%esi),%ebx
  800566:	83 e8 23             	sub    $0x23,%eax
  800569:	3c 55                	cmp    $0x55,%al
  80056b:	0f 87 e0 02 00 00    	ja     800851 <vprintfmt+0x368>
  800571:	0f b6 c0             	movzbl %al,%eax
  800574:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057b:	83 ea 30             	sub    $0x30,%edx
  80057e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800581:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800584:	8d 50 d0             	lea    -0x30(%eax),%edx
  800587:	83 fa 09             	cmp    $0x9,%edx
  80058a:	77 44                	ja     8005d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	89 de                	mov    %ebx,%esi
  80058e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800591:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800592:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800595:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800599:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80059c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059f:	83 fb 09             	cmp    $0x9,%ebx
  8005a2:	76 ed                	jbe    800591 <vprintfmt+0xa8>
  8005a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a7:	eb 29                	jmp    8005d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b9:	eb 17                	jmp    8005d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8005bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bf:	78 85                	js     800546 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	89 de                	mov    %ebx,%esi
  8005c3:	eb 99                	jmp    80055e <vprintfmt+0x75>
  8005c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8005ce:	eb 8e                	jmp    80055e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	79 86                	jns    80055e <vprintfmt+0x75>
  8005d8:	e9 74 ff ff ff       	jmp    800551 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	89 de                	mov    %ebx,%esi
  8005e0:	e9 79 ff ff ff       	jmp    80055e <vprintfmt+0x75>
  8005e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	ff 30                	pushl  (%eax)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8005fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800600:	e9 08 ff ff ff       	jmp    80050d <vprintfmt+0x24>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	79 02                	jns    800619 <vprintfmt+0x130>
  800617:	f7 d8                	neg    %eax
  800619:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061b:	83 f8 0f             	cmp    $0xf,%eax
  80061e:	7f 0b                	jg     80062b <vprintfmt+0x142>
  800620:	8b 04 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	75 1a                	jne    800645 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80062b:	52                   	push   %edx
  80062c:	68 17 24 80 00       	push   $0x802417
  800631:	57                   	push   %edi
  800632:	ff 75 08             	pushl  0x8(%ebp)
  800635:	e8 92 fe ff ff       	call   8004cc <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800640:	e9 c8 fe ff ff       	jmp    80050d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800645:	50                   	push   %eax
  800646:	68 55 29 80 00       	push   $0x802955
  80064b:	57                   	push   %edi
  80064c:	ff 75 08             	pushl  0x8(%ebp)
  80064f:	e8 78 fe ff ff       	call   8004cc <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065a:	e9 ae fe ff ff       	jmp    80050d <vprintfmt+0x24>
  80065f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800662:	89 de                	mov    %ebx,%esi
  800664:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800678:	85 c0                	test   %eax,%eax
  80067a:	75 07                	jne    800683 <vprintfmt+0x19a>
				p = "(null)";
  80067c:	c7 45 d0 10 24 80 00 	movl   $0x802410,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800683:	85 db                	test   %ebx,%ebx
  800685:	7e 42                	jle    8006c9 <vprintfmt+0x1e0>
  800687:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80068b:	74 3c                	je     8006c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	51                   	push   %ecx
  800691:	ff 75 d0             	pushl  -0x30(%ebp)
  800694:	e8 6f 02 00 00       	call   800908 <strnlen>
  800699:	29 c3                	sub    %eax,%ebx
  80069b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 db                	test   %ebx,%ebx
  8006a3:	7e 24                	jle    8006c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8006a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8006a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	57                   	push   %edi
  8006b3:	53                   	push   %ebx
  8006b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	4e                   	dec    %esi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 f6                	test   %esi,%esi
  8006bd:	7f f0                	jg     8006af <vprintfmt+0x1c6>
  8006bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006cc:	0f be 02             	movsbl (%edx),%eax
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	75 47                	jne    80071a <vprintfmt+0x231>
  8006d3:	eb 37                	jmp    80070c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	74 16                	je     8006f1 <vprintfmt+0x208>
  8006db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006de:	83 fa 5e             	cmp    $0x5e,%edx
  8006e1:	76 0e                	jbe    8006f1 <vprintfmt+0x208>
					putch('?', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	57                   	push   %edi
  8006e7:	6a 3f                	push   $0x3f
  8006e9:	ff 55 08             	call   *0x8(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 0b                	jmp    8006fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	57                   	push   %edi
  8006f5:	50                   	push   %eax
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8006ff:	0f be 03             	movsbl (%ebx),%eax
  800702:	85 c0                	test   %eax,%eax
  800704:	74 03                	je     800709 <vprintfmt+0x220>
  800706:	43                   	inc    %ebx
  800707:	eb 1b                	jmp    800724 <vprintfmt+0x23b>
  800709:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800710:	7f 1e                	jg     800730 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800715:	e9 f3 fd ff ff       	jmp    80050d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071d:	43                   	inc    %ebx
  80071e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800721:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800724:	85 f6                	test   %esi,%esi
  800726:	78 ad                	js     8006d5 <vprintfmt+0x1ec>
  800728:	4e                   	dec    %esi
  800729:	79 aa                	jns    8006d5 <vprintfmt+0x1ec>
  80072b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80072e:	eb dc                	jmp    80070c <vprintfmt+0x223>
  800730:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	57                   	push   %edi
  800737:	6a 20                	push   $0x20
  800739:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073c:	4b                   	dec    %ebx
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	85 db                	test   %ebx,%ebx
  800742:	7f ef                	jg     800733 <vprintfmt+0x24a>
  800744:	e9 c4 fd ff ff       	jmp    80050d <vprintfmt+0x24>
  800749:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074c:	89 ca                	mov    %ecx,%edx
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 2a fd ff ff       	call   800480 <getint>
  800756:	89 c3                	mov    %eax,%ebx
  800758:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80075a:	85 d2                	test   %edx,%edx
  80075c:	78 0a                	js     800768 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80075e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800763:	e9 b0 00 00 00       	jmp    800818 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	57                   	push   %edi
  80076c:	6a 2d                	push   $0x2d
  80076e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800771:	f7 db                	neg    %ebx
  800773:	83 d6 00             	adc    $0x0,%esi
  800776:	f7 de                	neg    %esi
  800778:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80077b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800780:	e9 93 00 00 00       	jmp    800818 <vprintfmt+0x32f>
  800785:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800788:	89 ca                	mov    %ecx,%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 b4 fc ff ff       	call   800446 <getuint>
  800792:	89 c3                	mov    %eax,%ebx
  800794:	89 d6                	mov    %edx,%esi
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80079b:	eb 7b                	jmp    800818 <vprintfmt+0x32f>
  80079d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 d6 fc ff ff       	call   800480 <getint>
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	78 07                	js     8007b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8007b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b7:	eb 5f                	jmp    800818 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	57                   	push   %edi
  8007bd:	6a 2d                	push   $0x2d
  8007bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8007c2:	f7 db                	neg    %ebx
  8007c4:	83 d6 00             	adc    $0x0,%esi
  8007c7:	f7 de                	neg    %esi
  8007c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8007cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8007d1:	eb 45                	jmp    800818 <vprintfmt+0x32f>
  8007d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	57                   	push   %edi
  8007da:	6a 30                	push   $0x30
  8007dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007df:	83 c4 08             	add    $0x8,%esp
  8007e2:	57                   	push   %edi
  8007e3:	6a 78                	push   $0x78
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f1:	8b 18                	mov    (%eax),%ebx
  8007f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800800:	eb 16                	jmp    800818 <vprintfmt+0x32f>
  800802:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800805:	89 ca                	mov    %ecx,%edx
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
  80080a:	e8 37 fc ff ff       	call   800446 <getuint>
  80080f:	89 c3                	mov    %eax,%ebx
  800811:	89 d6                	mov    %edx,%esi
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800818:	83 ec 0c             	sub    $0xc,%esp
  80081b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80081f:	52                   	push   %edx
  800820:	ff 75 e4             	pushl  -0x1c(%ebp)
  800823:	50                   	push   %eax
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	89 fa                	mov    %edi,%edx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	e8 68 fb ff ff       	call   800398 <printnum>
			break;
  800830:	83 c4 20             	add    $0x20,%esp
  800833:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800836:	e9 d2 fc ff ff       	jmp    80050d <vprintfmt+0x24>
  80083b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	57                   	push   %edi
  800842:	52                   	push   %edx
  800843:	ff 55 08             	call   *0x8(%ebp)
			break;
  800846:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084c:	e9 bc fc ff ff       	jmp    80050d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	57                   	push   %edi
  800855:	6a 25                	push   $0x25
  800857:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	eb 02                	jmp    800861 <vprintfmt+0x378>
  80085f:	89 c6                	mov    %eax,%esi
  800861:	8d 46 ff             	lea    -0x1(%esi),%eax
  800864:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800868:	75 f5                	jne    80085f <vprintfmt+0x376>
  80086a:	e9 9e fc ff ff       	jmp    80050d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800886:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800894:	85 c0                	test   %eax,%eax
  800896:	74 26                	je     8008be <vsnprintf+0x47>
  800898:	85 d2                	test   %edx,%edx
  80089a:	7e 29                	jle    8008c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	ff 75 14             	pushl  0x14(%ebp)
  80089f:	ff 75 10             	pushl  0x10(%ebp)
  8008a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	68 b2 04 80 00       	push   $0x8004b2
  8008ab:	e8 39 fc ff ff       	call   8004e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 0c                	jmp    8008ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c3:	eb 05                	jmp    8008ca <vsnprintf+0x53>
  8008c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d5:	50                   	push   %eax
  8008d6:	ff 75 10             	pushl  0x10(%ebp)
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 93 ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
	...

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	80 3a 00             	cmpb   $0x0,(%edx)
  8008f1:	74 0e                	je     800901 <strlen+0x19>
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fd:	75 f9                	jne    8008f8 <strlen+0x10>
  8008ff:	eb 05                	jmp    800906 <strlen+0x1e>
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	85 d2                	test   %edx,%edx
  800913:	74 17                	je     80092c <strnlen+0x24>
  800915:	80 39 00             	cmpb   $0x0,(%ecx)
  800918:	74 19                	je     800933 <strnlen+0x2b>
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80091f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800920:	39 d0                	cmp    %edx,%eax
  800922:	74 14                	je     800938 <strnlen+0x30>
  800924:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800928:	75 f5                	jne    80091f <strnlen+0x17>
  80092a:	eb 0c                	jmp    800938 <strnlen+0x30>
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 05                	jmp    800938 <strnlen+0x30>
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
  800949:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80094c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80094f:	42                   	inc    %edx
  800950:	84 c9                	test   %cl,%cl
  800952:	75 f5                	jne    800949 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095e:	53                   	push   %ebx
  80095f:	e8 84 ff ff ff       	call   8008e8 <strlen>
  800964:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80096d:	50                   	push   %eax
  80096e:	e8 c7 ff ff ff       	call   80093a <strcpy>
	return dst;
}
  800973:	89 d8                	mov    %ebx,%eax
  800975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800988:	85 f6                	test   %esi,%esi
  80098a:	74 15                	je     8009a1 <strncpy+0x27>
  80098c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800991:	8a 1a                	mov    (%edx),%bl
  800993:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800996:	80 3a 01             	cmpb   $0x1,(%edx)
  800999:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	41                   	inc    %ecx
  80099d:	39 ce                	cmp    %ecx,%esi
  80099f:	77 f0                	ja     800991 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 32                	je     8009ea <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009b8:	83 fe 01             	cmp    $0x1,%esi
  8009bb:	74 22                	je     8009df <strlcpy+0x3a>
  8009bd:	8a 0b                	mov    (%ebx),%cl
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	74 20                	je     8009e3 <strlcpy+0x3e>
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009ca:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cd:	88 08                	mov    %cl,(%eax)
  8009cf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d0:	39 f2                	cmp    %esi,%edx
  8009d2:	74 11                	je     8009e5 <strlcpy+0x40>
  8009d4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8009d8:	42                   	inc    %edx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	75 f0                	jne    8009cd <strlcpy+0x28>
  8009dd:	eb 06                	jmp    8009e5 <strlcpy+0x40>
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	eb 02                	jmp    8009e5 <strlcpy+0x40>
  8009e3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e5:	c6 00 00             	movb   $0x0,(%eax)
  8009e8:	eb 02                	jmp    8009ec <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ea:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8009ec:	29 f8                	sub    %edi,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fc:	8a 01                	mov    (%ecx),%al
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 10                	je     800a12 <strcmp+0x1f>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	75 0c                	jne    800a12 <strcmp+0x1f>
		p++, q++;
  800a06:	41                   	inc    %ecx
  800a07:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a08:	8a 01                	mov    (%ecx),%al
  800a0a:	84 c0                	test   %al,%al
  800a0c:	74 04                	je     800a12 <strcmp+0x1f>
  800a0e:	3a 02                	cmp    (%edx),%al
  800a10:	74 f4                	je     800a06 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a12:	0f b6 c0             	movzbl %al,%eax
  800a15:	0f b6 12             	movzbl (%edx),%edx
  800a18:	29 d0                	sub    %edx,%eax
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	53                   	push   %ebx
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a26:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	74 1b                	je     800a48 <strncmp+0x2c>
  800a2d:	8a 1a                	mov    (%edx),%bl
  800a2f:	84 db                	test   %bl,%bl
  800a31:	74 24                	je     800a57 <strncmp+0x3b>
  800a33:	3a 19                	cmp    (%ecx),%bl
  800a35:	75 20                	jne    800a57 <strncmp+0x3b>
  800a37:	48                   	dec    %eax
  800a38:	74 15                	je     800a4f <strncmp+0x33>
		n--, p++, q++;
  800a3a:	42                   	inc    %edx
  800a3b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3c:	8a 1a                	mov    (%edx),%bl
  800a3e:	84 db                	test   %bl,%bl
  800a40:	74 15                	je     800a57 <strncmp+0x3b>
  800a42:	3a 19                	cmp    (%ecx),%bl
  800a44:	74 f1                	je     800a37 <strncmp+0x1b>
  800a46:	eb 0f                	jmp    800a57 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	eb 05                	jmp    800a54 <strncmp+0x38>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a54:	5b                   	pop    %ebx
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a57:	0f b6 02             	movzbl (%edx),%eax
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	29 d0                	sub    %edx,%eax
  800a5f:	eb f3                	jmp    800a54 <strncmp+0x38>

00800a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a6a:	8a 10                	mov    (%eax),%dl
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	74 18                	je     800a88 <strchr+0x27>
		if (*s == c)
  800a70:	38 ca                	cmp    %cl,%dl
  800a72:	75 06                	jne    800a7a <strchr+0x19>
  800a74:	eb 17                	jmp    800a8d <strchr+0x2c>
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 13                	je     800a8d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	40                   	inc    %eax
  800a7b:	8a 10                	mov    (%eax),%dl
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f5                	jne    800a76 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	eb 05                	jmp    800a8d <strchr+0x2c>
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8d:	c9                   	leave  
  800a8e:	c3                   	ret    

00800a8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a98:	8a 10                	mov    (%eax),%dl
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	74 11                	je     800aaf <strfind+0x20>
		if (*s == c)
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	75 06                	jne    800aa8 <strfind+0x19>
  800aa2:	eb 0b                	jmp    800aaf <strfind+0x20>
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 07                	je     800aaf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	40                   	inc    %eax
  800aa9:	8a 10                	mov    (%eax),%dl
  800aab:	84 d2                	test   %dl,%dl
  800aad:	75 f5                	jne    800aa4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 30                	je     800af4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 25                	jne    800af1 <memset+0x40>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 20                	jne    800af1 <memset+0x40>
		c &= 0xFF;
  800ad1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	c1 e3 08             	shl    $0x8,%ebx
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	c1 e6 18             	shl    $0x18,%esi
  800ade:	89 d0                	mov    %edx,%eax
  800ae0:	c1 e0 10             	shl    $0x10,%eax
  800ae3:	09 f0                	or     %esi,%eax
  800ae5:	09 d0                	or     %edx,%eax
  800ae7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aec:	fc                   	cld    
  800aed:	f3 ab                	rep stos %eax,%es:(%edi)
  800aef:	eb 03                	jmp    800af4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af1:	fc                   	cld    
  800af2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af4:	89 f8                	mov    %edi,%eax
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b09:	39 c6                	cmp    %eax,%esi
  800b0b:	73 34                	jae    800b41 <memmove+0x46>
  800b0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b10:	39 d0                	cmp    %edx,%eax
  800b12:	73 2d                	jae    800b41 <memmove+0x46>
		s += n;
		d += n;
  800b14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	f6 c2 03             	test   $0x3,%dl
  800b1a:	75 1b                	jne    800b37 <memmove+0x3c>
  800b1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b22:	75 13                	jne    800b37 <memmove+0x3c>
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 0e                	jne    800b37 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b29:	83 ef 04             	sub    $0x4,%edi
  800b2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b32:	fd                   	std    
  800b33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b35:	eb 07                	jmp    800b3e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b37:	4f                   	dec    %edi
  800b38:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3b:	fd                   	std    
  800b3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3e:	fc                   	cld    
  800b3f:	eb 20                	jmp    800b61 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b47:	75 13                	jne    800b5c <memmove+0x61>
  800b49:	a8 03                	test   $0x3,%al
  800b4b:	75 0f                	jne    800b5c <memmove+0x61>
  800b4d:	f6 c1 03             	test   $0x3,%cl
  800b50:	75 0a                	jne    800b5c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b52:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	fc                   	cld    
  800b58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5a:	eb 05                	jmp    800b61 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b68:	ff 75 10             	pushl  0x10(%ebp)
  800b6b:	ff 75 0c             	pushl  0xc(%ebp)
  800b6e:	ff 75 08             	pushl  0x8(%ebp)
  800b71:	e8 85 ff ff ff       	call   800afb <memmove>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b84:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b87:	85 ff                	test   %edi,%edi
  800b89:	74 32                	je     800bbd <memcmp+0x45>
		if (*s1 != *s2)
  800b8b:	8a 03                	mov    (%ebx),%al
  800b8d:	8a 0e                	mov    (%esi),%cl
  800b8f:	38 c8                	cmp    %cl,%al
  800b91:	74 19                	je     800bac <memcmp+0x34>
  800b93:	eb 0d                	jmp    800ba2 <memcmp+0x2a>
  800b95:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b99:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b9d:	42                   	inc    %edx
  800b9e:	38 c8                	cmp    %cl,%al
  800ba0:	74 10                	je     800bb2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800ba2:	0f b6 c0             	movzbl %al,%eax
  800ba5:	0f b6 c9             	movzbl %cl,%ecx
  800ba8:	29 c8                	sub    %ecx,%eax
  800baa:	eb 16                	jmp    800bc2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bac:	4f                   	dec    %edi
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	39 fa                	cmp    %edi,%edx
  800bb4:	75 df                	jne    800b95 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 05                	jmp    800bc2 <memcmp+0x4a>
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd2:	39 d0                	cmp    %edx,%eax
  800bd4:	73 12                	jae    800be8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bd9:	38 08                	cmp    %cl,(%eax)
  800bdb:	75 06                	jne    800be3 <memfind+0x1c>
  800bdd:	eb 09                	jmp    800be8 <memfind+0x21>
  800bdf:	38 08                	cmp    %cl,(%eax)
  800be1:	74 05                	je     800be8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be3:	40                   	inc    %eax
  800be4:	39 c2                	cmp    %eax,%edx
  800be6:	77 f7                	ja     800bdf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf6:	eb 01                	jmp    800bf9 <strtol+0xf>
		s++;
  800bf8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf9:	8a 02                	mov    (%edx),%al
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f9                	je     800bf8 <strtol+0xe>
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f5                	je     800bf8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 08                	jne    800c0f <strtol+0x25>
		s++;
  800c07:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0d:	eb 13                	jmp    800c22 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0f:	3c 2d                	cmp    $0x2d,%al
  800c11:	75 0a                	jne    800c1d <strtol+0x33>
		s++, neg = 1;
  800c13:	8d 52 01             	lea    0x1(%edx),%edx
  800c16:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1b:	eb 05                	jmp    800c22 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c22:	85 db                	test   %ebx,%ebx
  800c24:	74 05                	je     800c2b <strtol+0x41>
  800c26:	83 fb 10             	cmp    $0x10,%ebx
  800c29:	75 28                	jne    800c53 <strtol+0x69>
  800c2b:	8a 02                	mov    (%edx),%al
  800c2d:	3c 30                	cmp    $0x30,%al
  800c2f:	75 10                	jne    800c41 <strtol+0x57>
  800c31:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c35:	75 0a                	jne    800c41 <strtol+0x57>
		s += 2, base = 16;
  800c37:	83 c2 02             	add    $0x2,%edx
  800c3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3f:	eb 12                	jmp    800c53 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c41:	85 db                	test   %ebx,%ebx
  800c43:	75 0e                	jne    800c53 <strtol+0x69>
  800c45:	3c 30                	cmp    $0x30,%al
  800c47:	75 05                	jne    800c4e <strtol+0x64>
		s++, base = 8;
  800c49:	42                   	inc    %edx
  800c4a:	b3 08                	mov    $0x8,%bl
  800c4c:	eb 05                	jmp    800c53 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
  800c58:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5a:	8a 0a                	mov    (%edx),%cl
  800c5c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c5f:	80 fb 09             	cmp    $0x9,%bl
  800c62:	77 08                	ja     800c6c <strtol+0x82>
			dig = *s - '0';
  800c64:	0f be c9             	movsbl %cl,%ecx
  800c67:	83 e9 30             	sub    $0x30,%ecx
  800c6a:	eb 1e                	jmp    800c8a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c6c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c6f:	80 fb 19             	cmp    $0x19,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x92>
			dig = *s - 'a' + 10;
  800c74:	0f be c9             	movsbl %cl,%ecx
  800c77:	83 e9 57             	sub    $0x57,%ecx
  800c7a:	eb 0e                	jmp    800c8a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c7c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 13                	ja     800c97 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c84:	0f be c9             	movsbl %cl,%ecx
  800c87:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8a:	39 f1                	cmp    %esi,%ecx
  800c8c:	7d 0d                	jge    800c9b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c8e:	42                   	inc    %edx
  800c8f:	0f af c6             	imul   %esi,%eax
  800c92:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c95:	eb c3                	jmp    800c5a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c97:	89 c1                	mov    %eax,%ecx
  800c99:	eb 02                	jmp    800c9d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca1:	74 05                	je     800ca8 <strtol+0xbe>
		*endptr = (char *) s;
  800ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	74 04                	je     800cb0 <strtol+0xc6>
  800cac:	89 c8                	mov    %ecx,%eax
  800cae:	f7 d8                	neg    %eax
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    
  800cb5:	00 00                	add    %al,(%eax)
	...

00800cb8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 1c             	sub    $0x1c,%esp
  800cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cc4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cc7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	8b 75 14             	mov    0x14(%ebp),%esi
  800ccc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ccf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd5:	cd 30                	int    $0x30
  800cd7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cdd:	74 1c                	je     800cfb <syscall+0x43>
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 18                	jle    800cfb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cea:	68 ff 26 80 00       	push   $0x8026ff
  800cef:	6a 42                	push   $0x42
  800cf1:	68 1c 27 80 00       	push   $0x80271c
  800cf6:	e8 b1 f5 ff ff       	call   8002ac <_panic>

	return ret;
}
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d21:	e8 92 ff ff ff       	call   800cb8 <syscall>
  800d26:	83 c4 10             	add    $0x10,%esp
	return;
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d43:	b8 01 00 00 00       	mov    $0x1,%eax
  800d48:	e8 6b ff ff ff       	call   800cb8 <syscall>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d55:	6a 00                	push   $0x0
  800d57:	6a 00                	push   $0x0
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d60:	ba 01 00 00 00       	mov    $0x1,%edx
  800d65:	b8 03 00 00 00       	mov    $0x3,%eax
  800d6a:	e8 49 ff ff ff       	call   800cb8 <syscall>
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	6a 00                	push   $0x0
  800d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8e:	e8 25 ff ff ff       	call   800cb8 <syscall>
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <sys_yield>:

void
sys_yield(void)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	6a 00                	push   $0x0
  800da1:	6a 00                	push   $0x0
  800da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db2:	e8 01 ff ff ff       	call   800cb8 <syscall>
  800db7:	83 c4 10             	add    $0x10,%esp
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800dc2:	6a 00                	push   $0x0
  800dc4:	6a 00                	push   $0x0
  800dc6:	ff 75 10             	pushl  0x10(%ebp)
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd9:	e8 da fe ff ff       	call   800cb8 <syscall>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800de6:	ff 75 18             	pushl  0x18(%ebp)
  800de9:	ff 75 14             	pushl  0x14(%ebp)
  800dec:	ff 75 10             	pushl  0x10(%ebp)
  800def:	ff 75 0c             	pushl  0xc(%ebp)
  800df2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df5:	ba 01 00 00 00       	mov    $0x1,%edx
  800dfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800dff:	e8 b4 fe ff ff       	call   800cb8 <syscall>
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e0c:	6a 00                	push   $0x0
  800e0e:	6a 00                	push   $0x0
  800e10:	6a 00                	push   $0x0
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	ba 01 00 00 00       	mov    $0x1,%edx
  800e1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e22:	e8 91 fe ff ff       	call   800cb8 <syscall>
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e2f:	6a 00                	push   $0x0
  800e31:	6a 00                	push   $0x0
  800e33:	6a 00                	push   $0x0
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e40:	b8 08 00 00 00       	mov    $0x8,%eax
  800e45:	e8 6e fe ff ff       	call   800cb8 <syscall>
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e52:	6a 00                	push   $0x0
  800e54:	6a 00                	push   $0x0
  800e56:	6a 00                	push   $0x0
  800e58:	ff 75 0c             	pushl  0xc(%ebp)
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	ba 01 00 00 00       	mov    $0x1,%edx
  800e63:	b8 09 00 00 00       	mov    $0x9,%eax
  800e68:	e8 4b fe ff ff       	call   800cb8 <syscall>
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e75:	6a 00                	push   $0x0
  800e77:	6a 00                	push   $0x0
  800e79:	6a 00                	push   $0x0
  800e7b:	ff 75 0c             	pushl  0xc(%ebp)
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	ba 01 00 00 00       	mov    $0x1,%edx
  800e86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8b:	e8 28 fe ff ff       	call   800cb8 <syscall>
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e98:	6a 00                	push   $0x0
  800e9a:	ff 75 14             	pushl  0x14(%ebp)
  800e9d:	ff 75 10             	pushl  0x10(%ebp)
  800ea0:	ff 75 0c             	pushl  0xc(%ebp)
  800ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb0:	e8 03 fe ff ff       	call   800cb8 <syscall>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ebd:	6a 00                	push   $0x0
  800ebf:	6a 00                	push   $0x0
  800ec1:	6a 00                	push   $0x0
  800ec3:	6a 00                	push   $0x0
  800ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ecd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed2:	e8 e1 fd ff ff       	call   800cb8 <syscall>
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800edf:	6a 00                	push   $0x0
  800ee1:	6a 00                	push   $0x0
  800ee3:	6a 00                	push   $0x0
  800ee5:	ff 75 0c             	pushl  0xc(%ebp)
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef5:	e8 be fd ff ff       	call   800cb8 <syscall>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	53                   	push   %ebx
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f06:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800f08:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f0c:	75 14                	jne    800f22 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 2c 27 80 00       	push   $0x80272c
  800f16:	6a 20                	push   $0x20
  800f18:	68 70 28 80 00       	push   $0x802870
  800f1d:	e8 8a f3 ff ff       	call   8002ac <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f22:	89 d8                	mov    %ebx,%eax
  800f24:	c1 e8 16             	shr    $0x16,%eax
  800f27:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2e:	a8 01                	test   $0x1,%al
  800f30:	74 11                	je     800f43 <pgfault+0x47>
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	c1 e8 0c             	shr    $0xc,%eax
  800f37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3e:	f6 c4 08             	test   $0x8,%ah
  800f41:	75 14                	jne    800f57 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 50 27 80 00       	push   $0x802750
  800f4b:	6a 24                	push   $0x24
  800f4d:	68 70 28 80 00       	push   $0x802870
  800f52:	e8 55 f3 ff ff       	call   8002ac <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	6a 07                	push   $0x7
  800f5c:	68 00 f0 7f 00       	push   $0x7ff000
  800f61:	6a 00                	push   $0x0
  800f63:	e8 54 fe ff ff       	call   800dbc <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	79 12                	jns    800f81 <pgfault+0x85>
  800f6f:	50                   	push   %eax
  800f70:	68 74 27 80 00       	push   $0x802774
  800f75:	6a 32                	push   $0x32
  800f77:	68 70 28 80 00       	push   $0x802870
  800f7c:	e8 2b f3 ff ff       	call   8002ac <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f81:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 00 10 00 00       	push   $0x1000
  800f8f:	53                   	push   %ebx
  800f90:	68 00 f0 7f 00       	push   $0x7ff000
  800f95:	e8 cb fb ff ff       	call   800b65 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f9a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa1:	53                   	push   %ebx
  800fa2:	6a 00                	push   $0x0
  800fa4:	68 00 f0 7f 00       	push   $0x7ff000
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 30 fe ff ff       	call   800de0 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 12                	jns    800fc9 <pgfault+0xcd>
  800fb7:	50                   	push   %eax
  800fb8:	68 98 27 80 00       	push   $0x802798
  800fbd:	6a 3a                	push   $0x3a
  800fbf:	68 70 28 80 00       	push   $0x802870
  800fc4:	e8 e3 f2 ff ff       	call   8002ac <_panic>

	return;
}
  800fc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fd7:	68 fc 0e 80 00       	push   $0x800efc
  800fdc:	e8 eb 0e 00 00       	call   801ecc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fe1:	ba 07 00 00 00       	mov    $0x7,%edx
  800fe6:	89 d0                	mov    %edx,%eax
  800fe8:	cd 30                	int    $0x30
  800fea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fed:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 12                	jns    801008 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800ff6:	50                   	push   %eax
  800ff7:	68 7b 28 80 00       	push   $0x80287b
  800ffc:	6a 7f                	push   $0x7f
  800ffe:	68 70 28 80 00       	push   $0x802870
  801003:	e8 a4 f2 ff ff       	call   8002ac <_panic>
	}
	int r;

	if (childpid == 0) {
  801008:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80100c:	75 25                	jne    801033 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  80100e:	e8 5e fd ff ff       	call   800d71 <sys_getenvid>
  801013:	25 ff 03 00 00       	and    $0x3ff,%eax
  801018:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80101f:	c1 e0 07             	shl    $0x7,%eax
  801022:	29 d0                	sub    %edx,%eax
  801024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801029:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  80102e:	e9 be 01 00 00       	jmp    8011f1 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	c1 e8 16             	shr    $0x16,%eax
  80103d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801044:	a8 01                	test   $0x1,%al
  801046:	0f 84 10 01 00 00    	je     80115c <fork+0x18e>
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	0f 84 fb 00 00 00    	je     80115c <fork+0x18e>
  801061:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801068:	f6 c2 04             	test   $0x4,%dl
  80106b:	0f 84 eb 00 00 00    	je     80115c <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801071:	89 c6                	mov    %eax,%esi
  801073:	c1 e6 0c             	shl    $0xc,%esi
  801076:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  80107c:	0f 84 da 00 00 00    	je     80115c <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801082:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801089:	f6 c6 04             	test   $0x4,%dh
  80108c:	74 37                	je     8010c5 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80108e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	25 07 0e 00 00       	and    $0xe07,%eax
  80109d:	50                   	push   %eax
  80109e:	56                   	push   %esi
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 38 fd ff ff       	call   800de0 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	0f 89 a9 00 00 00    	jns    80115c <fork+0x18e>
  8010b3:	50                   	push   %eax
  8010b4:	68 bc 27 80 00       	push   $0x8027bc
  8010b9:	6a 54                	push   $0x54
  8010bb:	68 70 28 80 00       	push   $0x802870
  8010c0:	e8 e7 f1 ff ff       	call   8002ac <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cc:	f6 c2 02             	test   $0x2,%dl
  8010cf:	75 0c                	jne    8010dd <fork+0x10f>
  8010d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d8:	f6 c4 08             	test   $0x8,%ah
  8010db:	74 57                	je     801134 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	68 05 08 00 00       	push   $0x805
  8010e5:	56                   	push   %esi
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 f1 fc ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 12                	jns    801108 <fork+0x13a>
  8010f6:	50                   	push   %eax
  8010f7:	68 bc 27 80 00       	push   $0x8027bc
  8010fc:	6a 59                	push   $0x59
  8010fe:	68 70 28 80 00       	push   $0x802870
  801103:	e8 a4 f1 ff ff       	call   8002ac <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	68 05 08 00 00       	push   $0x805
  801110:	56                   	push   %esi
  801111:	6a 00                	push   $0x0
  801113:	56                   	push   %esi
  801114:	6a 00                	push   $0x0
  801116:	e8 c5 fc ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80111b:	83 c4 20             	add    $0x20,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	79 3a                	jns    80115c <fork+0x18e>
  801122:	50                   	push   %eax
  801123:	68 bc 27 80 00       	push   $0x8027bc
  801128:	6a 5c                	push   $0x5c
  80112a:	68 70 28 80 00       	push   $0x802870
  80112f:	e8 78 f1 ff ff       	call   8002ac <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	6a 05                	push   $0x5
  801139:	56                   	push   %esi
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	6a 00                	push   $0x0
  80113e:	e8 9d fc ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 12                	jns    80115c <fork+0x18e>
  80114a:	50                   	push   %eax
  80114b:	68 bc 27 80 00       	push   $0x8027bc
  801150:	6a 60                	push   $0x60
  801152:	68 70 28 80 00       	push   $0x802870
  801157:	e8 50 f1 ff ff       	call   8002ac <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80115c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801162:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801168:	0f 85 ca fe ff ff    	jne    801038 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	6a 07                	push   $0x7
  801173:	68 00 f0 bf ee       	push   $0xeebff000
  801178:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117b:	e8 3c fc ff ff       	call   800dbc <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 15                	jns    80119c <fork+0x1ce>
  801187:	50                   	push   %eax
  801188:	68 e0 27 80 00       	push   $0x8027e0
  80118d:	68 94 00 00 00       	push   $0x94
  801192:	68 70 28 80 00       	push   $0x802870
  801197:	e8 10 f1 ff ff       	call   8002ac <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	68 38 1f 80 00       	push   $0x801f38
  8011a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a7:	e8 c3 fc ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	79 15                	jns    8011c8 <fork+0x1fa>
  8011b3:	50                   	push   %eax
  8011b4:	68 18 28 80 00       	push   $0x802818
  8011b9:	68 99 00 00 00       	push   $0x99
  8011be:	68 70 28 80 00       	push   $0x802870
  8011c3:	e8 e4 f0 ff ff       	call   8002ac <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	6a 02                	push   $0x2
  8011cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d0:	e8 54 fc ff ff       	call   800e29 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	79 15                	jns    8011f1 <fork+0x223>
  8011dc:	50                   	push   %eax
  8011dd:	68 3c 28 80 00       	push   $0x80283c
  8011e2:	68 a4 00 00 00       	push   $0xa4
  8011e7:	68 70 28 80 00       	push   $0x802870
  8011ec:	e8 bb f0 ff ff       	call   8002ac <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8011f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <sfork>:

// Challenge!
int
sfork(void)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801202:	68 98 28 80 00       	push   $0x802898
  801207:	68 b1 00 00 00       	push   $0xb1
  80120c:	68 70 28 80 00       	push   $0x802870
  801211:	e8 96 f0 ff ff       	call   8002ac <_panic>
	...

00801218 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	05 00 00 00 30       	add    $0x30000000,%eax
  801223:	c1 e8 0c             	shr    $0xc,%eax
}
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122b:	ff 75 08             	pushl  0x8(%ebp)
  80122e:	e8 e5 ff ff ff       	call   801218 <fd2num>
  801233:	83 c4 04             	add    $0x4,%esp
  801236:	05 20 00 0d 00       	add    $0xd0020,%eax
  80123b:	c1 e0 0c             	shl    $0xc,%eax
}
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801247:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80124c:	a8 01                	test   $0x1,%al
  80124e:	74 34                	je     801284 <fd_alloc+0x44>
  801250:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801255:	a8 01                	test   $0x1,%al
  801257:	74 32                	je     80128b <fd_alloc+0x4b>
  801259:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80125e:	89 c1                	mov    %eax,%ecx
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 16             	shr    $0x16,%edx
  801265:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	74 1f                	je     801290 <fd_alloc+0x50>
  801271:	89 c2                	mov    %eax,%edx
  801273:	c1 ea 0c             	shr    $0xc,%edx
  801276:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127d:	f6 c2 01             	test   $0x1,%dl
  801280:	75 17                	jne    801299 <fd_alloc+0x59>
  801282:	eb 0c                	jmp    801290 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801284:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801289:	eb 05                	jmp    801290 <fd_alloc+0x50>
  80128b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801290:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 17                	jmp    8012b0 <fd_alloc+0x70>
  801299:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a3:	75 b9                	jne    80125e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b0:	5b                   	pop    %ebx
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b9:	83 f8 1f             	cmp    $0x1f,%eax
  8012bc:	77 36                	ja     8012f4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012be:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012c3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 16             	shr    $0x16,%edx
  8012cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 24                	je     8012fb <fd_lookup+0x48>
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	c1 ea 0c             	shr    $0xc,%edx
  8012dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e3:	f6 c2 01             	test   $0x1,%dl
  8012e6:	74 1a                	je     801302 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012eb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	eb 13                	jmp    801307 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f9:	eb 0c                	jmp    801307 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801300:	eb 05                	jmp    801307 <fd_lookup+0x54>
  801302:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 04             	sub    $0x4,%esp
  801310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801316:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80131c:	74 0d                	je     80132b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	eb 14                	jmp    801339 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801325:	39 0a                	cmp    %ecx,(%edx)
  801327:	75 10                	jne    801339 <dev_lookup+0x30>
  801329:	eb 05                	jmp    801330 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801330:	89 13                	mov    %edx,(%ebx)
			return 0;
  801332:	b8 00 00 00 00       	mov    $0x0,%eax
  801337:	eb 31                	jmp    80136a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801339:	40                   	inc    %eax
  80133a:	8b 14 85 2c 29 80 00 	mov    0x80292c(,%eax,4),%edx
  801341:	85 d2                	test   %edx,%edx
  801343:	75 e0                	jne    801325 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801345:	a1 04 40 80 00       	mov    0x804004,%eax
  80134a:	8b 40 48             	mov    0x48(%eax),%eax
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	51                   	push   %ecx
  801351:	50                   	push   %eax
  801352:	68 b0 28 80 00       	push   $0x8028b0
  801357:	e8 28 f0 ff ff       	call   800384 <cprintf>
	*dev = 0;
  80135c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 20             	sub    $0x20,%esp
  801377:	8b 75 08             	mov    0x8(%ebp),%esi
  80137a:	8a 45 0c             	mov    0xc(%ebp),%al
  80137d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801380:	56                   	push   %esi
  801381:	e8 92 fe ff ff       	call   801218 <fd2num>
  801386:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801389:	89 14 24             	mov    %edx,(%esp)
  80138c:	50                   	push   %eax
  80138d:	e8 21 ff ff ff       	call   8012b3 <fd_lookup>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 05                	js     8013a0 <fd_close+0x31>
	    || fd != fd2)
  80139b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139e:	74 0d                	je     8013ad <fd_close+0x3e>
		return (must_exist ? r : 0);
  8013a0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013a4:	75 48                	jne    8013ee <fd_close+0x7f>
  8013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ab:	eb 41                	jmp    8013ee <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 36                	pushl  (%esi)
  8013b6:	e8 4e ff ff ff       	call   801309 <dev_lookup>
  8013bb:	89 c3                	mov    %eax,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 1c                	js     8013e0 <fd_close+0x71>
		if (dev->dev_close)
  8013c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c7:	8b 40 10             	mov    0x10(%eax),%eax
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	74 0d                	je     8013db <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	56                   	push   %esi
  8013d2:	ff d0                	call   *%eax
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	eb 05                	jmp    8013e0 <fd_close+0x71>
		else
			r = 0;
  8013db:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	56                   	push   %esi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 1b fa ff ff       	call   800e06 <sys_page_unmap>
	return r;
  8013eb:	83 c4 10             	add    $0x10,%esp
}
  8013ee:	89 d8                	mov    %ebx,%eax
  8013f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	ff 75 08             	pushl  0x8(%ebp)
  801404:	e8 aa fe ff ff       	call   8012b3 <fd_lookup>
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 10                	js     801420 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	6a 01                	push   $0x1
  801415:	ff 75 f4             	pushl  -0xc(%ebp)
  801418:	e8 52 ff ff ff       	call   80136f <fd_close>
  80141d:	83 c4 10             	add    $0x10,%esp
}
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <close_all>:

void
close_all(void)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801429:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	53                   	push   %ebx
  801432:	e8 c0 ff ff ff       	call   8013f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801437:	43                   	inc    %ebx
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	83 fb 20             	cmp    $0x20,%ebx
  80143e:	75 ee                	jne    80142e <close_all+0xc>
		close(i);
}
  801440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	57                   	push   %edi
  801449:	56                   	push   %esi
  80144a:	53                   	push   %ebx
  80144b:	83 ec 2c             	sub    $0x2c,%esp
  80144e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801451:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 56 fe ff ff       	call   8012b3 <fd_lookup>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	0f 88 c0 00 00 00    	js     80152a <dup+0xe5>
		return r;
	close(newfdnum);
  80146a:	83 ec 0c             	sub    $0xc,%esp
  80146d:	57                   	push   %edi
  80146e:	e8 84 ff ff ff       	call   8013f7 <close>

	newfd = INDEX2FD(newfdnum);
  801473:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801479:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80147c:	83 c4 04             	add    $0x4,%esp
  80147f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801482:	e8 a1 fd ff ff       	call   801228 <fd2data>
  801487:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801489:	89 34 24             	mov    %esi,(%esp)
  80148c:	e8 97 fd ff ff       	call   801228 <fd2data>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801497:	89 d8                	mov    %ebx,%eax
  801499:	c1 e8 16             	shr    $0x16,%eax
  80149c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a3:	a8 01                	test   $0x1,%al
  8014a5:	74 37                	je     8014de <dup+0x99>
  8014a7:	89 d8                	mov    %ebx,%eax
  8014a9:	c1 e8 0c             	shr    $0xc,%eax
  8014ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 26                	je     8014de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 0b f9 ff ff       	call   800de0 <sys_page_map>
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	83 c4 20             	add    $0x20,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 2d                	js     80150b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	c1 ea 0c             	shr    $0xc,%edx
  8014e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014f6:	52                   	push   %edx
  8014f7:	56                   	push   %esi
  8014f8:	6a 00                	push   $0x0
  8014fa:	50                   	push   %eax
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 de f8 ff ff       	call   800de0 <sys_page_map>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	83 c4 20             	add    $0x20,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	79 1d                	jns    801528 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	56                   	push   %esi
  80150f:	6a 00                	push   $0x0
  801511:	e8 f0 f8 ff ff       	call   800e06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	ff 75 d4             	pushl  -0x2c(%ebp)
  80151c:	6a 00                	push   $0x0
  80151e:	e8 e3 f8 ff ff       	call   800e06 <sys_page_unmap>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	eb 02                	jmp    80152a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801528:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80152a:	89 d8                	mov    %ebx,%eax
  80152c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 14             	sub    $0x14,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	53                   	push   %ebx
  801543:	e8 6b fd ff ff       	call   8012b3 <fd_lookup>
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 67                	js     8015b6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	ff 30                	pushl  (%eax)
  80155b:	e8 a9 fd ff ff       	call   801309 <dev_lookup>
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 4f                	js     8015b6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	8b 50 08             	mov    0x8(%eax),%edx
  80156d:	83 e2 03             	and    $0x3,%edx
  801570:	83 fa 01             	cmp    $0x1,%edx
  801573:	75 21                	jne    801596 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801575:	a1 04 40 80 00       	mov    0x804004,%eax
  80157a:	8b 40 48             	mov    0x48(%eax),%eax
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	53                   	push   %ebx
  801581:	50                   	push   %eax
  801582:	68 f1 28 80 00       	push   $0x8028f1
  801587:	e8 f8 ed ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801594:	eb 20                	jmp    8015b6 <read+0x82>
	}
	if (!dev->dev_read)
  801596:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801599:	8b 52 08             	mov    0x8(%edx),%edx
  80159c:	85 d2                	test   %edx,%edx
  80159e:	74 11                	je     8015b1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	ff 75 10             	pushl  0x10(%ebp)
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	50                   	push   %eax
  8015aa:	ff d2                	call   *%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 05                	jmp    8015b6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ca:	85 f6                	test   %esi,%esi
  8015cc:	74 31                	je     8015ff <readn+0x44>
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	89 f2                	mov    %esi,%edx
  8015dd:	29 c2                	sub    %eax,%edx
  8015df:	52                   	push   %edx
  8015e0:	03 45 0c             	add    0xc(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	57                   	push   %edi
  8015e5:	e8 4a ff ff ff       	call   801534 <read>
		if (m < 0)
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 17                	js     801608 <readn+0x4d>
			return m;
		if (m == 0)
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	74 11                	je     801606 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f5:	01 c3                	add    %eax,%ebx
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	39 f3                	cmp    %esi,%ebx
  8015fb:	72 db                	jb     8015d8 <readn+0x1d>
  8015fd:	eb 09                	jmp    801608 <readn+0x4d>
  8015ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801604:	eb 02                	jmp    801608 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801606:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801608:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5e                   	pop    %esi
  80160d:	5f                   	pop    %edi
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 14             	sub    $0x14,%esp
  801617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	53                   	push   %ebx
  80161f:	e8 8f fc ff ff       	call   8012b3 <fd_lookup>
  801624:	83 c4 08             	add    $0x8,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 62                	js     80168d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	ff 30                	pushl  (%eax)
  801637:	e8 cd fc ff ff       	call   801309 <dev_lookup>
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 4a                	js     80168d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801646:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164a:	75 21                	jne    80166d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80164c:	a1 04 40 80 00       	mov    0x804004,%eax
  801651:	8b 40 48             	mov    0x48(%eax),%eax
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	53                   	push   %ebx
  801658:	50                   	push   %eax
  801659:	68 0d 29 80 00       	push   $0x80290d
  80165e:	e8 21 ed ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166b:	eb 20                	jmp    80168d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	8b 52 0c             	mov    0xc(%edx),%edx
  801673:	85 d2                	test   %edx,%edx
  801675:	74 11                	je     801688 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	ff 75 10             	pushl  0x10(%ebp)
  80167d:	ff 75 0c             	pushl  0xc(%ebp)
  801680:	50                   	push   %eax
  801681:	ff d2                	call   *%edx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb 05                	jmp    80168d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801688:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <seek>:

int
seek(int fdnum, off_t offset)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801698:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 0f fc ff ff       	call   8012b3 <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 0e                	js     8016b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 14             	sub    $0x14,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	53                   	push   %ebx
  8016ca:	e8 e4 fb ff ff       	call   8012b3 <fd_lookup>
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 5f                	js     801735 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	ff 30                	pushl  (%eax)
  8016e2:	e8 22 fc ff ff       	call   801309 <dev_lookup>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 47                	js     801735 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f5:	75 21                	jne    801718 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fc:	8b 40 48             	mov    0x48(%eax),%eax
  8016ff:	83 ec 04             	sub    $0x4,%esp
  801702:	53                   	push   %ebx
  801703:	50                   	push   %eax
  801704:	68 d0 28 80 00       	push   $0x8028d0
  801709:	e8 76 ec ff ff       	call   800384 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801716:	eb 1d                	jmp    801735 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171b:	8b 52 18             	mov    0x18(%edx),%edx
  80171e:	85 d2                	test   %edx,%edx
  801720:	74 0e                	je     801730 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	50                   	push   %eax
  801729:	ff d2                	call   *%edx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 05                	jmp    801735 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801730:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 14             	sub    $0x14,%esp
  801741:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	ff 75 08             	pushl  0x8(%ebp)
  80174b:	e8 63 fb ff ff       	call   8012b3 <fd_lookup>
  801750:	83 c4 08             	add    $0x8,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 52                	js     8017a9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	ff 30                	pushl  (%eax)
  801763:	e8 a1 fb ff ff       	call   801309 <dev_lookup>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 3a                	js     8017a9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801776:	74 2c                	je     8017a4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801778:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80177b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801782:	00 00 00 
	stat->st_isdir = 0;
  801785:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80178c:	00 00 00 
	stat->st_dev = dev;
  80178f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	53                   	push   %ebx
  801799:	ff 75 f0             	pushl  -0x10(%ebp)
  80179c:	ff 50 14             	call   *0x14(%eax)
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	eb 05                	jmp    8017a9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 78 01 00 00       	call   801938 <open>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 1b                	js     8017e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	e8 65 ff ff ff       	call   80173a <fstat>
  8017d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d7:	89 1c 24             	mov    %ebx,(%esp)
  8017da:	e8 18 fc ff ff       	call   8013f7 <close>
	return r;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	89 f3                	mov    %esi,%ebx
}
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    
  8017ed:	00 00                	add    %al,(%eax)
	...

008017f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801800:	75 12                	jne    801814 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	6a 01                	push   $0x1
  801807:	e8 1e 08 00 00       	call   80202a <ipc_find_env>
  80180c:	a3 00 40 80 00       	mov    %eax,0x804000
  801811:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801814:	6a 07                	push   $0x7
  801816:	68 00 50 80 00       	push   $0x805000
  80181b:	53                   	push   %ebx
  80181c:	ff 35 00 40 80 00    	pushl  0x804000
  801822:	e8 ae 07 00 00       	call   801fd5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801827:	83 c4 0c             	add    $0xc,%esp
  80182a:	6a 00                	push   $0x0
  80182c:	56                   	push   %esi
  80182d:	6a 00                	push   $0x0
  80182f:	e8 2c 07 00 00       	call   801f60 <ipc_recv>
}
  801834:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	53                   	push   %ebx
  80183f:	83 ec 04             	sub    $0x4,%esp
  801842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	8b 40 0c             	mov    0xc(%eax),%eax
  80184b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 05 00 00 00       	mov    $0x5,%eax
  80185a:	e8 91 ff ff ff       	call   8017f0 <fsipc>
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 2c                	js     80188f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	68 00 50 80 00       	push   $0x805000
  80186b:	53                   	push   %ebx
  80186c:	e8 c9 f0 ff ff       	call   80093a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801871:	a1 80 50 80 00       	mov    0x805080,%eax
  801876:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187c:	a1 84 50 80 00       	mov    0x805084,%eax
  801881:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8018af:	e8 3c ff ff ff       	call   8017f0 <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d9:	e8 12 ff ff ff       	call   8017f0 <fsipc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 4b                	js     80192f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e4:	39 c6                	cmp    %eax,%esi
  8018e6:	73 16                	jae    8018fe <devfile_read+0x48>
  8018e8:	68 3c 29 80 00       	push   $0x80293c
  8018ed:	68 43 29 80 00       	push   $0x802943
  8018f2:	6a 7d                	push   $0x7d
  8018f4:	68 58 29 80 00       	push   $0x802958
  8018f9:	e8 ae e9 ff ff       	call   8002ac <_panic>
	assert(r <= PGSIZE);
  8018fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801903:	7e 16                	jle    80191b <devfile_read+0x65>
  801905:	68 63 29 80 00       	push   $0x802963
  80190a:	68 43 29 80 00       	push   $0x802943
  80190f:	6a 7e                	push   $0x7e
  801911:	68 58 29 80 00       	push   $0x802958
  801916:	e8 91 e9 ff ff       	call   8002ac <_panic>
	memmove(buf, &fsipcbuf, r);
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	50                   	push   %eax
  80191f:	68 00 50 80 00       	push   $0x805000
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	e8 cf f1 ff ff       	call   800afb <memmove>
	return r;
  80192c:	83 c4 10             	add    $0x10,%esp
}
  80192f:	89 d8                	mov    %ebx,%eax
  801931:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	83 ec 1c             	sub    $0x1c,%esp
  801940:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801943:	56                   	push   %esi
  801944:	e8 9f ef ff ff       	call   8008e8 <strlen>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801951:	7f 65                	jg     8019b8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801959:	50                   	push   %eax
  80195a:	e8 e1 f8 ff ff       	call   801240 <fd_alloc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	78 55                	js     8019bd <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	56                   	push   %esi
  80196c:	68 00 50 80 00       	push   $0x805000
  801971:	e8 c4 ef ff ff       	call   80093a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80197e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801981:	b8 01 00 00 00       	mov    $0x1,%eax
  801986:	e8 65 fe ff ff       	call   8017f0 <fsipc>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	79 12                	jns    8019a6 <open+0x6e>
		fd_close(fd, 0);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	6a 00                	push   $0x0
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	e8 ce f9 ff ff       	call   80136f <fd_close>
		return r;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	eb 17                	jmp    8019bd <open+0x85>
	}

	return fd2num(fd);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ac:	e8 67 f8 ff ff       	call   801218 <fd2num>
  8019b1:	89 c3                	mov    %eax,%ebx
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	eb 05                	jmp    8019bd <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019bd:	89 d8                	mov    %ebx,%eax
  8019bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    
	...

008019c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d0:	83 ec 0c             	sub    $0xc,%esp
  8019d3:	ff 75 08             	pushl  0x8(%ebp)
  8019d6:	e8 4d f8 ff ff       	call   801228 <fd2data>
  8019db:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019dd:	83 c4 08             	add    $0x8,%esp
  8019e0:	68 6f 29 80 00       	push   $0x80296f
  8019e5:	56                   	push   %esi
  8019e6:	e8 4f ef ff ff       	call   80093a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ee:	2b 03                	sub    (%ebx),%eax
  8019f0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019f6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019fd:	00 00 00 
	stat->st_dev = &devpipe;
  801a00:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a07:	30 80 00 
	return 0;
}
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	53                   	push   %ebx
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a20:	53                   	push   %ebx
  801a21:	6a 00                	push   $0x0
  801a23:	e8 de f3 ff ff       	call   800e06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a28:	89 1c 24             	mov    %ebx,(%esp)
  801a2b:	e8 f8 f7 ff ff       	call   801228 <fd2data>
  801a30:	83 c4 08             	add    $0x8,%esp
  801a33:	50                   	push   %eax
  801a34:	6a 00                	push   $0x0
  801a36:	e8 cb f3 ff ff       	call   800e06 <sys_page_unmap>
}
  801a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	57                   	push   %edi
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 1c             	sub    $0x1c,%esp
  801a49:	89 c7                	mov    %eax,%edi
  801a4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a53:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	57                   	push   %edi
  801a5a:	e8 29 06 00 00       	call   802088 <pageref>
  801a5f:	89 c6                	mov    %eax,%esi
  801a61:	83 c4 04             	add    $0x4,%esp
  801a64:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a67:	e8 1c 06 00 00       	call   802088 <pageref>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	39 c6                	cmp    %eax,%esi
  801a71:	0f 94 c0             	sete   %al
  801a74:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a77:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a80:	39 cb                	cmp    %ecx,%ebx
  801a82:	75 08                	jne    801a8c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a8c:	83 f8 01             	cmp    $0x1,%eax
  801a8f:	75 bd                	jne    801a4e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a91:	8b 42 58             	mov    0x58(%edx),%eax
  801a94:	6a 01                	push   $0x1
  801a96:	50                   	push   %eax
  801a97:	53                   	push   %ebx
  801a98:	68 76 29 80 00       	push   $0x802976
  801a9d:	e8 e2 e8 ff ff       	call   800384 <cprintf>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb a7                	jmp    801a4e <_pipeisclosed+0xe>

00801aa7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	83 ec 28             	sub    $0x28,%esp
  801ab0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab3:	56                   	push   %esi
  801ab4:	e8 6f f7 ff ff       	call   801228 <fd2data>
  801ab9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac2:	75 4a                	jne    801b0e <devpipe_write+0x67>
  801ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac9:	eb 56                	jmp    801b21 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801acb:	89 da                	mov    %ebx,%edx
  801acd:	89 f0                	mov    %esi,%eax
  801acf:	e8 6c ff ff ff       	call   801a40 <_pipeisclosed>
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	75 4d                	jne    801b25 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad8:	e8 b8 f2 ff ff       	call   800d95 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801add:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae0:	8b 13                	mov    (%ebx),%edx
  801ae2:	83 c2 20             	add    $0x20,%edx
  801ae5:	39 d0                	cmp    %edx,%eax
  801ae7:	73 e2                	jae    801acb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae9:	89 c2                	mov    %eax,%edx
  801aeb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801af1:	79 05                	jns    801af8 <devpipe_write+0x51>
  801af3:	4a                   	dec    %edx
  801af4:	83 ca e0             	or     $0xffffffe0,%edx
  801af7:	42                   	inc    %edx
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801afe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b02:	40                   	inc    %eax
  801b03:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	47                   	inc    %edi
  801b07:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b0a:	77 07                	ja     801b13 <devpipe_write+0x6c>
  801b0c:	eb 13                	jmp    801b21 <devpipe_write+0x7a>
  801b0e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b13:	8b 43 04             	mov    0x4(%ebx),%eax
  801b16:	8b 13                	mov    (%ebx),%edx
  801b18:	83 c2 20             	add    $0x20,%edx
  801b1b:	39 d0                	cmp    %edx,%eax
  801b1d:	73 ac                	jae    801acb <devpipe_write+0x24>
  801b1f:	eb c8                	jmp    801ae9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b21:	89 f8                	mov    %edi,%eax
  801b23:	eb 05                	jmp    801b2a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 18             	sub    $0x18,%esp
  801b3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b3e:	57                   	push   %edi
  801b3f:	e8 e4 f6 ff ff       	call   801228 <fd2data>
  801b44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b4d:	75 44                	jne    801b93 <devpipe_read+0x61>
  801b4f:	be 00 00 00 00       	mov    $0x0,%esi
  801b54:	eb 4f                	jmp    801ba5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b56:	89 f0                	mov    %esi,%eax
  801b58:	eb 54                	jmp    801bae <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5a:	89 da                	mov    %ebx,%edx
  801b5c:	89 f8                	mov    %edi,%eax
  801b5e:	e8 dd fe ff ff       	call   801a40 <_pipeisclosed>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	75 42                	jne    801ba9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b67:	e8 29 f2 ff ff       	call   800d95 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6c:	8b 03                	mov    (%ebx),%eax
  801b6e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b71:	74 e7                	je     801b5a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b73:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b78:	79 05                	jns    801b7f <devpipe_read+0x4d>
  801b7a:	48                   	dec    %eax
  801b7b:	83 c8 e0             	or     $0xffffffe0,%eax
  801b7e:	40                   	inc    %eax
  801b7f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b86:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b89:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8b:	46                   	inc    %esi
  801b8c:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b8f:	77 07                	ja     801b98 <devpipe_read+0x66>
  801b91:	eb 12                	jmp    801ba5 <devpipe_read+0x73>
  801b93:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b98:	8b 03                	mov    (%ebx),%eax
  801b9a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b9d:	75 d4                	jne    801b73 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9f:	85 f6                	test   %esi,%esi
  801ba1:	75 b3                	jne    801b56 <devpipe_read+0x24>
  801ba3:	eb b5                	jmp    801b5a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ba5:	89 f0                	mov    %esi,%eax
  801ba7:	eb 05                	jmp    801bae <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	57                   	push   %edi
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 28             	sub    $0x28,%esp
  801bbf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 75 f6 ff ff       	call   801240 <fd_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 24 01 00 00    	js     801cfc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 07 04 00 00       	push   $0x407
  801be0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 d2 f1 ff ff       	call   800dbc <sys_page_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 05 01 00 00    	js     801cfc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bfd:	50                   	push   %eax
  801bfe:	e8 3d f6 ff ff       	call   801240 <fd_alloc>
  801c03:	89 c3                	mov    %eax,%ebx
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	0f 88 dc 00 00 00    	js     801cec <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c10:	83 ec 04             	sub    $0x4,%esp
  801c13:	68 07 04 00 00       	push   $0x407
  801c18:	ff 75 e0             	pushl  -0x20(%ebp)
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 9a f1 ff ff       	call   800dbc <sys_page_alloc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	0f 88 bd 00 00 00    	js     801cec <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c2f:	83 ec 0c             	sub    $0xc,%esp
  801c32:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c35:	e8 ee f5 ff ff       	call   801228 <fd2data>
  801c3a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3c:	83 c4 0c             	add    $0xc,%esp
  801c3f:	68 07 04 00 00       	push   $0x407
  801c44:	50                   	push   %eax
  801c45:	6a 00                	push   $0x0
  801c47:	e8 70 f1 ff ff       	call   800dbc <sys_page_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 83 00 00 00    	js     801cdc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c5f:	e8 c4 f5 ff ff       	call   801228 <fd2data>
  801c64:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c6b:	50                   	push   %eax
  801c6c:	6a 00                	push   $0x0
  801c6e:	56                   	push   %esi
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 6a f1 ff ff       	call   800de0 <sys_page_map>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	83 c4 20             	add    $0x20,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 4f                	js     801cce <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ca2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801caf:	e8 64 f5 ff ff       	call   801218 <fd2num>
  801cb4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cb6:	83 c4 04             	add    $0x4,%esp
  801cb9:	ff 75 e0             	pushl  -0x20(%ebp)
  801cbc:	e8 57 f5 ff ff       	call   801218 <fd2num>
  801cc1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ccc:	eb 2e                	jmp    801cfc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cce:	83 ec 08             	sub    $0x8,%esp
  801cd1:	56                   	push   %esi
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 2d f1 ff ff       	call   800e06 <sys_page_unmap>
  801cd9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 1d f1 ff ff       	call   800e06 <sys_page_unmap>
  801ce9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cec:	83 ec 08             	sub    $0x8,%esp
  801cef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 0d f1 ff ff       	call   800e06 <sys_page_unmap>
  801cf9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	ff 75 08             	pushl  0x8(%ebp)
  801d13:	e8 9b f5 ff ff       	call   8012b3 <fd_lookup>
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 18                	js     801d37 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 75 f4             	pushl  -0xc(%ebp)
  801d25:	e8 fe f4 ff ff       	call   801228 <fd2data>
	return _pipeisclosed(fd, p);
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	e8 0c fd ff ff       	call   801a40 <_pipeisclosed>
  801d34:	83 c4 10             	add    $0x10,%esp
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    
  801d39:	00 00                	add    %al,(%eax)
	...

00801d3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d4c:	68 89 29 80 00       	push   $0x802989
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	e8 e1 eb ff ff       	call   80093a <strcpy>
	return 0;
}
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	57                   	push   %edi
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d70:	74 45                	je     801db7 <devcons_write+0x57>
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
  801d77:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d85:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d87:	83 fb 7f             	cmp    $0x7f,%ebx
  801d8a:	76 05                	jbe    801d91 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d8c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	53                   	push   %ebx
  801d95:	03 45 0c             	add    0xc(%ebp),%eax
  801d98:	50                   	push   %eax
  801d99:	57                   	push   %edi
  801d9a:	e8 5c ed ff ff       	call   800afb <memmove>
		sys_cputs(buf, m);
  801d9f:	83 c4 08             	add    $0x8,%esp
  801da2:	53                   	push   %ebx
  801da3:	57                   	push   %edi
  801da4:	e8 5c ef ff ff       	call   800d05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da9:	01 de                	add    %ebx,%esi
  801dab:	89 f0                	mov    %esi,%eax
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db3:	72 cd                	jb     801d82 <devcons_write+0x22>
  801db5:	eb 05                	jmp    801dbc <devcons_write+0x5c>
  801db7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dbc:	89 f0                	mov    %esi,%eax
  801dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd0:	75 07                	jne    801dd9 <devcons_read+0x13>
  801dd2:	eb 25                	jmp    801df9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dd4:	e8 bc ef ff ff       	call   800d95 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd9:	e8 4d ef ff ff       	call   800d2b <sys_cgetc>
  801dde:	85 c0                	test   %eax,%eax
  801de0:	74 f2                	je     801dd4 <devcons_read+0xe>
  801de2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 1d                	js     801e05 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801de8:	83 f8 04             	cmp    $0x4,%eax
  801deb:	74 13                	je     801e00 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df0:	88 10                	mov    %dl,(%eax)
	return 1;
  801df2:	b8 01 00 00 00       	mov    $0x1,%eax
  801df7:	eb 0c                	jmp    801e05 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfe:	eb 05                	jmp    801e05 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e10:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e13:	6a 01                	push   $0x1
  801e15:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	e8 e7 ee ff ff       	call   800d05 <sys_cputs>
  801e1e:	83 c4 10             	add    $0x10,%esp
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <getchar>:

int
getchar(void)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e29:	6a 01                	push   $0x1
  801e2b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 fe f6 ff ff       	call   801534 <read>
	if (r < 0)
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	78 0f                	js     801e4c <getchar+0x29>
		return r;
	if (r < 1)
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	7e 06                	jle    801e47 <getchar+0x24>
		return -E_EOF;
	return c;
  801e41:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e45:	eb 05                	jmp    801e4c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e47:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e57:	50                   	push   %eax
  801e58:	ff 75 08             	pushl  0x8(%ebp)
  801e5b:	e8 53 f4 ff ff       	call   8012b3 <fd_lookup>
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 11                	js     801e78 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e70:	39 10                	cmp    %edx,(%eax)
  801e72:	0f 94 c0             	sete   %al
  801e75:	0f b6 c0             	movzbl %al,%eax
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <opencons>:

int
opencons(void)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	e8 b7 f3 ff ff       	call   801240 <fd_alloc>
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 3a                	js     801eca <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	68 07 04 00 00       	push   $0x407
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 1a ef ff ff       	call   800dbc <sys_page_alloc>
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	78 21                	js     801eca <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ea9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	50                   	push   %eax
  801ec2:	e8 51 f3 ff ff       	call   801218 <fd2num>
  801ec7:	83 c4 10             	add    $0x10,%esp
}
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed9:	75 52                	jne    801f2d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	6a 07                	push   $0x7
  801ee0:	68 00 f0 bf ee       	push   $0xeebff000
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 d0 ee ff ff       	call   800dbc <sys_page_alloc>
		if (r < 0) {
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	79 12                	jns    801f05 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ef3:	50                   	push   %eax
  801ef4:	68 95 29 80 00       	push   $0x802995
  801ef9:	6a 24                	push   $0x24
  801efb:	68 b0 29 80 00       	push   $0x8029b0
  801f00:	e8 a7 e3 ff ff       	call   8002ac <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f05:	83 ec 08             	sub    $0x8,%esp
  801f08:	68 38 1f 80 00       	push   $0x801f38
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 5b ef ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	85 c0                	test   %eax,%eax
  801f19:	79 12                	jns    801f2d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f1b:	50                   	push   %eax
  801f1c:	68 c0 29 80 00       	push   $0x8029c0
  801f21:	6a 2a                	push   $0x2a
  801f23:	68 b0 29 80 00       	push   $0x8029b0
  801f28:	e8 7f e3 ff ff       	call   8002ac <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    
	...

00801f38 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f38:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f39:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f40:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f43:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f47:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f4a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f4e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f52:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f54:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f57:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f58:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f5b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f5c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f5d:	c3                   	ret    
	...

00801f60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	8b 75 08             	mov    0x8(%ebp),%esi
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	74 0e                	je     801f80 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	50                   	push   %eax
  801f76:	e8 3c ef ff ff       	call   800eb7 <sys_ipc_recv>
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	eb 10                	jmp    801f90 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	68 00 00 c0 ee       	push   $0xeec00000
  801f88:	e8 2a ef ff ff       	call   800eb7 <sys_ipc_recv>
  801f8d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f90:	85 c0                	test   %eax,%eax
  801f92:	75 26                	jne    801fba <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f94:	85 f6                	test   %esi,%esi
  801f96:	74 0a                	je     801fa2 <ipc_recv+0x42>
  801f98:	a1 04 40 80 00       	mov    0x804004,%eax
  801f9d:	8b 40 74             	mov    0x74(%eax),%eax
  801fa0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fa2:	85 db                	test   %ebx,%ebx
  801fa4:	74 0a                	je     801fb0 <ipc_recv+0x50>
  801fa6:	a1 04 40 80 00       	mov    0x804004,%eax
  801fab:	8b 40 78             	mov    0x78(%eax),%eax
  801fae:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801fb0:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb5:	8b 40 70             	mov    0x70(%eax),%eax
  801fb8:	eb 14                	jmp    801fce <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fba:	85 f6                	test   %esi,%esi
  801fbc:	74 06                	je     801fc4 <ipc_recv+0x64>
  801fbe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801fc4:	85 db                	test   %ebx,%ebx
  801fc6:	74 06                	je     801fce <ipc_recv+0x6e>
  801fc8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	57                   	push   %edi
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fe1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801fe7:	85 db                	test   %ebx,%ebx
  801fe9:	75 25                	jne    802010 <ipc_send+0x3b>
  801feb:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ff0:	eb 1e                	jmp    802010 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ff2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff5:	75 07                	jne    801ffe <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ff7:	e8 99 ed ff ff       	call   800d95 <sys_yield>
  801ffc:	eb 12                	jmp    802010 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ffe:	50                   	push   %eax
  801fff:	68 e8 29 80 00       	push   $0x8029e8
  802004:	6a 43                	push   $0x43
  802006:	68 fb 29 80 00       	push   $0x8029fb
  80200b:	e8 9c e2 ff ff       	call   8002ac <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	57                   	push   %edi
  802013:	ff 75 08             	pushl  0x8(%ebp)
  802016:	e8 77 ee ff ff       	call   800e92 <sys_ipc_try_send>
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	85 c0                	test   %eax,%eax
  802020:	75 d0                	jne    801ff2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	53                   	push   %ebx
  80202e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802031:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802037:	74 22                	je     80205b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802039:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80203e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802045:	89 c2                	mov    %eax,%edx
  802047:	c1 e2 07             	shl    $0x7,%edx
  80204a:	29 ca                	sub    %ecx,%edx
  80204c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802052:	8b 52 50             	mov    0x50(%edx),%edx
  802055:	39 da                	cmp    %ebx,%edx
  802057:	75 1d                	jne    802076 <ipc_find_env+0x4c>
  802059:	eb 05                	jmp    802060 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802060:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802067:	c1 e0 07             	shl    $0x7,%eax
  80206a:	29 d0                	sub    %edx,%eax
  80206c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802071:	8b 40 40             	mov    0x40(%eax),%eax
  802074:	eb 0c                	jmp    802082 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802076:	40                   	inc    %eax
  802077:	3d 00 04 00 00       	cmp    $0x400,%eax
  80207c:	75 c0                	jne    80203e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80207e:	66 b8 00 00          	mov    $0x0,%ax
}
  802082:	5b                   	pop    %ebx
  802083:	c9                   	leave  
  802084:	c3                   	ret    
  802085:	00 00                	add    %al,(%eax)
	...

00802088 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208e:	89 c2                	mov    %eax,%edx
  802090:	c1 ea 16             	shr    $0x16,%edx
  802093:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80209a:	f6 c2 01             	test   $0x1,%dl
  80209d:	74 1e                	je     8020bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80209f:	c1 e8 0c             	shr    $0xc,%eax
  8020a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020a9:	a8 01                	test   $0x1,%al
  8020ab:	74 17                	je     8020c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ad:	c1 e8 0c             	shr    $0xc,%eax
  8020b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020b7:	ef 
  8020b8:	0f b7 c0             	movzwl %ax,%eax
  8020bb:	eb 0c                	jmp    8020c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c2:	eb 05                	jmp    8020c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    
	...

008020cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	57                   	push   %edi
  8020d0:	56                   	push   %esi
  8020d1:	83 ec 10             	sub    $0x10,%esp
  8020d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020da:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020e0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020e3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	75 2e                	jne    802118 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020ea:	39 f1                	cmp    %esi,%ecx
  8020ec:	77 5a                	ja     802148 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020ee:	85 c9                	test   %ecx,%ecx
  8020f0:	75 0b                	jne    8020fd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	31 d2                	xor    %edx,%edx
  8020f9:	f7 f1                	div    %ecx
  8020fb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020fd:	31 d2                	xor    %edx,%edx
  8020ff:	89 f0                	mov    %esi,%eax
  802101:	f7 f1                	div    %ecx
  802103:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802105:	89 f8                	mov    %edi,%eax
  802107:	f7 f1                	div    %ecx
  802109:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	5e                   	pop    %esi
  802113:	5f                   	pop    %edi
  802114:	c9                   	leave  
  802115:	c3                   	ret    
  802116:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802118:	39 f0                	cmp    %esi,%eax
  80211a:	77 1c                	ja     802138 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80211c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80211f:	83 f7 1f             	xor    $0x1f,%edi
  802122:	75 3c                	jne    802160 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802124:	39 f0                	cmp    %esi,%eax
  802126:	0f 82 90 00 00 00    	jb     8021bc <__udivdi3+0xf0>
  80212c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802132:	0f 86 84 00 00 00    	jbe    8021bc <__udivdi3+0xf0>
  802138:	31 f6                	xor    %esi,%esi
  80213a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80213c:	89 f8                	mov    %edi,%eax
  80213e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	5e                   	pop    %esi
  802144:	5f                   	pop    %edi
  802145:	c9                   	leave  
  802146:	c3                   	ret    
  802147:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802148:	89 f2                	mov    %esi,%edx
  80214a:	89 f8                	mov    %edi,%eax
  80214c:	f7 f1                	div    %ecx
  80214e:	89 c7                	mov    %eax,%edi
  802150:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802152:	89 f8                	mov    %edi,%eax
  802154:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    
  80215d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802160:	89 f9                	mov    %edi,%ecx
  802162:	d3 e0                	shl    %cl,%eax
  802164:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802167:	b8 20 00 00 00       	mov    $0x20,%eax
  80216c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80216e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802171:	88 c1                	mov    %al,%cl
  802173:	d3 ea                	shr    %cl,%edx
  802175:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802178:	09 ca                	or     %ecx,%edx
  80217a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80217d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802180:	89 f9                	mov    %edi,%ecx
  802182:	d3 e2                	shl    %cl,%edx
  802184:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802187:	89 f2                	mov    %esi,%edx
  802189:	88 c1                	mov    %al,%cl
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802190:	89 f2                	mov    %esi,%edx
  802192:	89 f9                	mov    %edi,%ecx
  802194:	d3 e2                	shl    %cl,%edx
  802196:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802199:	88 c1                	mov    %al,%cl
  80219b:	d3 ee                	shr    %cl,%esi
  80219d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80219f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021a2:	89 f0                	mov    %esi,%eax
  8021a4:	89 ca                	mov    %ecx,%edx
  8021a6:	f7 75 ec             	divl   -0x14(%ebp)
  8021a9:	89 d1                	mov    %edx,%ecx
  8021ab:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021ad:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b0:	39 d1                	cmp    %edx,%ecx
  8021b2:	72 28                	jb     8021dc <__udivdi3+0x110>
  8021b4:	74 1a                	je     8021d0 <__udivdi3+0x104>
  8021b6:	89 f7                	mov    %esi,%edi
  8021b8:	31 f6                	xor    %esi,%esi
  8021ba:	eb 80                	jmp    80213c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021bc:	31 f6                	xor    %esi,%esi
  8021be:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021c3:	89 f8                	mov    %edi,%eax
  8021c5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	5e                   	pop    %esi
  8021cb:	5f                   	pop    %edi
  8021cc:	c9                   	leave  
  8021cd:	c3                   	ret    
  8021ce:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021d7:	39 c2                	cmp    %eax,%edx
  8021d9:	73 db                	jae    8021b6 <__udivdi3+0xea>
  8021db:	90                   	nop
		{
		  q0--;
  8021dc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021df:	31 f6                	xor    %esi,%esi
  8021e1:	e9 56 ff ff ff       	jmp    80213c <__udivdi3+0x70>
	...

008021e8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	57                   	push   %edi
  8021ec:	56                   	push   %esi
  8021ed:	83 ec 20             	sub    $0x20,%esp
  8021f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021fc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802202:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802205:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802207:	85 ff                	test   %edi,%edi
  802209:	75 15                	jne    802220 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80220b:	39 f1                	cmp    %esi,%ecx
  80220d:	0f 86 99 00 00 00    	jbe    8022ac <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802213:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802215:	89 d0                	mov    %edx,%eax
  802217:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802219:	83 c4 20             	add    $0x20,%esp
  80221c:	5e                   	pop    %esi
  80221d:	5f                   	pop    %edi
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802220:	39 f7                	cmp    %esi,%edi
  802222:	0f 87 a4 00 00 00    	ja     8022cc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802228:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80222b:	83 f0 1f             	xor    $0x1f,%eax
  80222e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802231:	0f 84 a1 00 00 00    	je     8022d8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802237:	89 f8                	mov    %edi,%eax
  802239:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80223c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80223e:	bf 20 00 00 00       	mov    $0x20,%edi
  802243:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802246:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802249:	89 f9                	mov    %edi,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	09 c2                	or     %eax,%edx
  80224f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802252:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802255:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802258:	d3 e0                	shl    %cl,%eax
  80225a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802261:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802264:	d3 e0                	shl    %cl,%eax
  802266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802269:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80226c:	89 f9                	mov    %edi,%ecx
  80226e:	d3 e8                	shr    %cl,%eax
  802270:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802272:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802274:	89 f2                	mov    %esi,%edx
  802276:	f7 75 f0             	divl   -0x10(%ebp)
  802279:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80227b:	f7 65 f4             	mull   -0xc(%ebp)
  80227e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802281:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802283:	39 d6                	cmp    %edx,%esi
  802285:	72 71                	jb     8022f8 <__umoddi3+0x110>
  802287:	74 7f                	je     802308 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80228c:	29 c8                	sub    %ecx,%eax
  80228e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802290:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802293:	d3 e8                	shr    %cl,%eax
  802295:	89 f2                	mov    %esi,%edx
  802297:	89 f9                	mov    %edi,%ecx
  802299:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80229b:	09 d0                	or     %edx,%eax
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022a2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a4:	83 c4 20             	add    $0x20,%esp
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	c9                   	leave  
  8022aa:	c3                   	ret    
  8022ab:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022ac:	85 c9                	test   %ecx,%ecx
  8022ae:	75 0b                	jne    8022bb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b5:	31 d2                	xor    %edx,%edx
  8022b7:	f7 f1                	div    %ecx
  8022b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022bb:	89 f0                	mov    %esi,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c4:	f7 f1                	div    %ecx
  8022c6:	e9 4a ff ff ff       	jmp    802215 <__umoddi3+0x2d>
  8022cb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022cc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022ce:	83 c4 20             	add    $0x20,%esp
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022d8:	39 f7                	cmp    %esi,%edi
  8022da:	72 05                	jb     8022e1 <__umoddi3+0xf9>
  8022dc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022df:	77 0c                	ja     8022ed <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022e1:	89 f2                	mov    %esi,%edx
  8022e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e6:	29 c8                	sub    %ecx,%eax
  8022e8:	19 fa                	sbb    %edi,%edx
  8022ea:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f0:	83 c4 20             	add    $0x20,%esp
  8022f3:	5e                   	pop    %esi
  8022f4:	5f                   	pop    %edi
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    
  8022f7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022fb:	89 c1                	mov    %eax,%ecx
  8022fd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802300:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802303:	eb 84                	jmp    802289 <__umoddi3+0xa1>
  802305:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802308:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80230b:	72 eb                	jb     8022f8 <__umoddi3+0x110>
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	e9 75 ff ff ff       	jmp    802289 <__umoddi3+0xa1>
