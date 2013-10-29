
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
  80004d:	e8 25 15 00 00       	call   801577 <readn>
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
  80008e:	e8 ff 1a 00 00       	call   801b92 <pipe>
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
  8000d2:	e8 dc 12 00 00       	call   8013b3 <close>
		close(pfd[1]);
  8000d7:	83 c4 04             	add    $0x4,%esp
  8000da:	ff 75 dc             	pushl  -0x24(%ebp)
  8000dd:	e8 d1 12 00 00       	call   8013b3 <close>
		fd = pfd[0];
  8000e2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	e9 59 ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f3:	e8 bb 12 00 00       	call   8013b3 <close>
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
  800108:	e8 6a 14 00 00       	call   801577 <readn>
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
  80014c:	e8 7b 14 00 00       	call   8015cc <write>
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
  800192:	e8 fb 19 00 00       	call   801b92 <pipe>
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
  8001d8:	e8 d6 11 00 00       	call   8013b3 <close>
		primeproc(p[0]);
  8001dd:	83 c4 04             	add    $0x4,%esp
  8001e0:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e3:	e8 4c fe ff ff       	call   800034 <primeproc>
  8001e8:	83 c4 10             	add    $0x10,%esp
	}

	close(p[0]);
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 ec             	pushl  -0x14(%ebp)
  8001f1:	e8 bd 11 00 00       	call   8013b3 <close>

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
  80020c:	e8 bb 13 00 00       	call   8015cc <write>
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
  800296:	e8 43 11 00 00       	call   8013de <close_all>
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
  8002e0:	c7 04 24 79 29 80 00 	movl   $0x802979,(%esp)
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
  8003ec:	e8 e7 1c 00 00       	call   8020d8 <__udivdi3>
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
  800428:	e8 c7 1d 00 00       	call   8021f4 <__umoddi3>
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
  800646:	68 5b 29 80 00       	push   $0x80295b
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
  800fdc:	e8 c7 0e 00 00       	call   801ea8 <set_pgfault_handler>
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
  800ffc:	6a 7b                	push   $0x7b
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
  80102e:	e9 7b 01 00 00       	jmp    8011ae <fork+0x1e0>
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
  801046:	0f 84 cd 00 00 00    	je     801119 <fork+0x14b>
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	0f 84 b8 00 00 00    	je     801119 <fork+0x14b>
  801061:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801068:	f6 c2 04             	test   $0x4,%dl
  80106b:	0f 84 a8 00 00 00    	je     801119 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801071:	89 c6                	mov    %eax,%esi
  801073:	c1 e6 0c             	shl    $0xc,%esi
  801076:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  80107c:	0f 84 97 00 00 00    	je     801119 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801082:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801089:	f6 c2 02             	test   $0x2,%dl
  80108c:	75 0c                	jne    80109a <fork+0xcc>
  80108e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801095:	f6 c4 08             	test   $0x8,%ah
  801098:	74 57                	je     8010f1 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	68 05 08 00 00       	push   $0x805
  8010a2:	56                   	push   %esi
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 34 fd ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <fork+0xf7>
  8010b3:	50                   	push   %eax
  8010b4:	68 bc 27 80 00       	push   $0x8027bc
  8010b9:	6a 55                	push   $0x55
  8010bb:	68 70 28 80 00       	push   $0x802870
  8010c0:	e8 e7 f1 ff ff       	call   8002ac <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	68 05 08 00 00       	push   $0x805
  8010cd:	56                   	push   %esi
  8010ce:	6a 00                	push   $0x0
  8010d0:	56                   	push   %esi
  8010d1:	6a 00                	push   $0x0
  8010d3:	e8 08 fd ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	79 3a                	jns    801119 <fork+0x14b>
  8010df:	50                   	push   %eax
  8010e0:	68 bc 27 80 00       	push   $0x8027bc
  8010e5:	6a 58                	push   $0x58
  8010e7:	68 70 28 80 00       	push   $0x802870
  8010ec:	e8 bb f1 ff ff       	call   8002ac <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	6a 05                	push   $0x5
  8010f6:	56                   	push   %esi
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 e0 fc ff ff       	call   800de0 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 12                	jns    801119 <fork+0x14b>
  801107:	50                   	push   %eax
  801108:	68 bc 27 80 00       	push   $0x8027bc
  80110d:	6a 5c                	push   $0x5c
  80110f:	68 70 28 80 00       	push   $0x802870
  801114:	e8 93 f1 ff ff       	call   8002ac <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801119:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80111f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801125:	0f 85 0d ff ff ff    	jne    801038 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	6a 07                	push   $0x7
  801130:	68 00 f0 bf ee       	push   $0xeebff000
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	e8 7f fc ff ff       	call   800dbc <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	79 15                	jns    801159 <fork+0x18b>
  801144:	50                   	push   %eax
  801145:	68 e0 27 80 00       	push   $0x8027e0
  80114a:	68 90 00 00 00       	push   $0x90
  80114f:	68 70 28 80 00       	push   $0x802870
  801154:	e8 53 f1 ff ff       	call   8002ac <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	68 14 1f 80 00       	push   $0x801f14
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	e8 06 fd ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	79 15                	jns    801185 <fork+0x1b7>
  801170:	50                   	push   %eax
  801171:	68 18 28 80 00       	push   $0x802818
  801176:	68 95 00 00 00       	push   $0x95
  80117b:	68 70 28 80 00       	push   $0x802870
  801180:	e8 27 f1 ff ff       	call   8002ac <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	6a 02                	push   $0x2
  80118a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118d:	e8 97 fc ff ff       	call   800e29 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	79 15                	jns    8011ae <fork+0x1e0>
  801199:	50                   	push   %eax
  80119a:	68 3c 28 80 00       	push   $0x80283c
  80119f:	68 a0 00 00 00       	push   $0xa0
  8011a4:	68 70 28 80 00       	push   $0x802870
  8011a9:	e8 fe f0 ff ff       	call   8002ac <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8011ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011bf:	68 98 28 80 00       	push   $0x802898
  8011c4:	68 ad 00 00 00       	push   $0xad
  8011c9:	68 70 28 80 00       	push   $0x802870
  8011ce:	e8 d9 f0 ff ff       	call   8002ac <_panic>
	...

008011d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	05 00 00 00 30       	add    $0x30000000,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 e5 ff ff ff       	call   8011d4 <fd2num>
  8011ef:	83 c4 04             	add    $0x4,%esp
  8011f2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011f7:	c1 e0 0c             	shl    $0xc,%eax
}
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	53                   	push   %ebx
  801200:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801203:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801208:	a8 01                	test   $0x1,%al
  80120a:	74 34                	je     801240 <fd_alloc+0x44>
  80120c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801211:	a8 01                	test   $0x1,%al
  801213:	74 32                	je     801247 <fd_alloc+0x4b>
  801215:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80121a:	89 c1                	mov    %eax,%ecx
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 16             	shr    $0x16,%edx
  801221:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 1f                	je     80124c <fd_alloc+0x50>
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 0c             	shr    $0xc,%edx
  801232:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	75 17                	jne    801255 <fd_alloc+0x59>
  80123e:	eb 0c                	jmp    80124c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801240:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801245:	eb 05                	jmp    80124c <fd_alloc+0x50>
  801247:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80124c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
  801253:	eb 17                	jmp    80126c <fd_alloc+0x70>
  801255:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80125a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125f:	75 b9                	jne    80121a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801261:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801267:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126c:	5b                   	pop    %ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801275:	83 f8 1f             	cmp    $0x1f,%eax
  801278:	77 36                	ja     8012b0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80127f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801282:	89 c2                	mov    %eax,%edx
  801284:	c1 ea 16             	shr    $0x16,%edx
  801287:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 24                	je     8012b7 <fd_lookup+0x48>
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 0c             	shr    $0xc,%edx
  801298:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	74 1a                	je     8012be <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ae:	eb 13                	jmp    8012c3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b5:	eb 0c                	jmp    8012c3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bc:	eb 05                	jmp    8012c3 <fd_lookup+0x54>
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c3:	c9                   	leave  
  8012c4:	c3                   	ret    

008012c5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012d2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012d8:	74 0d                	je     8012e7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	eb 14                	jmp    8012f5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012e1:	39 0a                	cmp    %ecx,(%edx)
  8012e3:	75 10                	jne    8012f5 <dev_lookup+0x30>
  8012e5:	eb 05                	jmp    8012ec <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012ec:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	eb 31                	jmp    801326 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f5:	40                   	inc    %eax
  8012f6:	8b 14 85 2c 29 80 00 	mov    0x80292c(,%eax,4),%edx
  8012fd:	85 d2                	test   %edx,%edx
  8012ff:	75 e0                	jne    8012e1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801301:	a1 04 40 80 00       	mov    0x804004,%eax
  801306:	8b 40 48             	mov    0x48(%eax),%eax
  801309:	83 ec 04             	sub    $0x4,%esp
  80130c:	51                   	push   %ecx
  80130d:	50                   	push   %eax
  80130e:	68 b0 28 80 00       	push   $0x8028b0
  801313:	e8 6c f0 ff ff       	call   800384 <cprintf>
	*dev = 0;
  801318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	83 ec 20             	sub    $0x20,%esp
  801333:	8b 75 08             	mov    0x8(%ebp),%esi
  801336:	8a 45 0c             	mov    0xc(%ebp),%al
  801339:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133c:	56                   	push   %esi
  80133d:	e8 92 fe ff ff       	call   8011d4 <fd2num>
  801342:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801345:	89 14 24             	mov    %edx,(%esp)
  801348:	50                   	push   %eax
  801349:	e8 21 ff ff ff       	call   80126f <fd_lookup>
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 05                	js     80135c <fd_close+0x31>
	    || fd != fd2)
  801357:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135a:	74 0d                	je     801369 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80135c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801360:	75 48                	jne    8013aa <fd_close+0x7f>
  801362:	bb 00 00 00 00       	mov    $0x0,%ebx
  801367:	eb 41                	jmp    8013aa <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136f:	50                   	push   %eax
  801370:	ff 36                	pushl  (%esi)
  801372:	e8 4e ff ff ff       	call   8012c5 <dev_lookup>
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 1c                	js     80139c <fd_close+0x71>
		if (dev->dev_close)
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	8b 40 10             	mov    0x10(%eax),%eax
  801386:	85 c0                	test   %eax,%eax
  801388:	74 0d                	je     801397 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	56                   	push   %esi
  80138e:	ff d0                	call   *%eax
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	eb 05                	jmp    80139c <fd_close+0x71>
		else
			r = 0;
  801397:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	56                   	push   %esi
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 5f fa ff ff       	call   800e06 <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
}
  8013aa:	89 d8                	mov    %ebx,%eax
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 aa fe ff ff       	call   80126f <fd_lookup>
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 10                	js     8013dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	6a 01                	push   $0x1
  8013d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d4:	e8 52 ff ff ff       	call   80132b <fd_close>
  8013d9:	83 c4 10             	add    $0x10,%esp
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <close_all>:

void
close_all(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	53                   	push   %ebx
  8013ee:	e8 c0 ff ff ff       	call   8013b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	43                   	inc    %ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	83 fb 20             	cmp    $0x20,%ebx
  8013fa:	75 ee                	jne    8013ea <close_all+0xc>
		close(i);
}
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	57                   	push   %edi
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	83 ec 2c             	sub    $0x2c,%esp
  80140a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80140d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	ff 75 08             	pushl  0x8(%ebp)
  801414:	e8 56 fe ff ff       	call   80126f <fd_lookup>
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	0f 88 c0 00 00 00    	js     8014e6 <dup+0xe5>
		return r;
	close(newfdnum);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	57                   	push   %edi
  80142a:	e8 84 ff ff ff       	call   8013b3 <close>

	newfd = INDEX2FD(newfdnum);
  80142f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801435:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801438:	83 c4 04             	add    $0x4,%esp
  80143b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80143e:	e8 a1 fd ff ff       	call   8011e4 <fd2data>
  801443:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801445:	89 34 24             	mov    %esi,(%esp)
  801448:	e8 97 fd ff ff       	call   8011e4 <fd2data>
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801453:	89 d8                	mov    %ebx,%eax
  801455:	c1 e8 16             	shr    $0x16,%eax
  801458:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80145f:	a8 01                	test   $0x1,%al
  801461:	74 37                	je     80149a <dup+0x99>
  801463:	89 d8                	mov    %ebx,%eax
  801465:	c1 e8 0c             	shr    $0xc,%eax
  801468:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80146f:	f6 c2 01             	test   $0x1,%dl
  801472:	74 26                	je     80149a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801474:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147b:	83 ec 0c             	sub    $0xc,%esp
  80147e:	25 07 0e 00 00       	and    $0xe07,%eax
  801483:	50                   	push   %eax
  801484:	ff 75 d4             	pushl  -0x2c(%ebp)
  801487:	6a 00                	push   $0x0
  801489:	53                   	push   %ebx
  80148a:	6a 00                	push   $0x0
  80148c:	e8 4f f9 ff ff       	call   800de0 <sys_page_map>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 20             	add    $0x20,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 2d                	js     8014c7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	c1 ea 0c             	shr    $0xc,%edx
  8014a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a9:	83 ec 0c             	sub    $0xc,%esp
  8014ac:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014b2:	52                   	push   %edx
  8014b3:	56                   	push   %esi
  8014b4:	6a 00                	push   $0x0
  8014b6:	50                   	push   %eax
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 22 f9 ff ff       	call   800de0 <sys_page_map>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	83 c4 20             	add    $0x20,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 1d                	jns    8014e4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	56                   	push   %esi
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 34 f9 ff ff       	call   800e06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d8:	6a 00                	push   $0x0
  8014da:	e8 27 f9 ff ff       	call   800e06 <sys_page_unmap>
	return r;
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	eb 02                	jmp    8014e6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014e4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014e6:	89 d8                	mov    %ebx,%eax
  8014e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5e                   	pop    %esi
  8014ed:	5f                   	pop    %edi
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 14             	sub    $0x14,%esp
  8014f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	53                   	push   %ebx
  8014ff:	e8 6b fd ff ff       	call   80126f <fd_lookup>
  801504:	83 c4 08             	add    $0x8,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 67                	js     801572 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	ff 30                	pushl  (%eax)
  801517:	e8 a9 fd ff ff       	call   8012c5 <dev_lookup>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 4f                	js     801572 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	8b 50 08             	mov    0x8(%eax),%edx
  801529:	83 e2 03             	and    $0x3,%edx
  80152c:	83 fa 01             	cmp    $0x1,%edx
  80152f:	75 21                	jne    801552 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801531:	a1 04 40 80 00       	mov    0x804004,%eax
  801536:	8b 40 48             	mov    0x48(%eax),%eax
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	53                   	push   %ebx
  80153d:	50                   	push   %eax
  80153e:	68 f1 28 80 00       	push   $0x8028f1
  801543:	e8 3c ee ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801550:	eb 20                	jmp    801572 <read+0x82>
	}
	if (!dev->dev_read)
  801552:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801555:	8b 52 08             	mov    0x8(%edx),%edx
  801558:	85 d2                	test   %edx,%edx
  80155a:	74 11                	je     80156d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	ff 75 10             	pushl  0x10(%ebp)
  801562:	ff 75 0c             	pushl  0xc(%ebp)
  801565:	50                   	push   %eax
  801566:	ff d2                	call   *%edx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	eb 05                	jmp    801572 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80156d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	8b 7d 08             	mov    0x8(%ebp),%edi
  801583:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801586:	85 f6                	test   %esi,%esi
  801588:	74 31                	je     8015bb <readn+0x44>
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
  80158f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	89 f2                	mov    %esi,%edx
  801599:	29 c2                	sub    %eax,%edx
  80159b:	52                   	push   %edx
  80159c:	03 45 0c             	add    0xc(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	57                   	push   %edi
  8015a1:	e8 4a ff ff ff       	call   8014f0 <read>
		if (m < 0)
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 17                	js     8015c4 <readn+0x4d>
			return m;
		if (m == 0)
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	74 11                	je     8015c2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b1:	01 c3                	add    %eax,%ebx
  8015b3:	89 d8                	mov    %ebx,%eax
  8015b5:	39 f3                	cmp    %esi,%ebx
  8015b7:	72 db                	jb     801594 <readn+0x1d>
  8015b9:	eb 09                	jmp    8015c4 <readn+0x4d>
  8015bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c0:	eb 02                	jmp    8015c4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015c2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5f                   	pop    %edi
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 14             	sub    $0x14,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	53                   	push   %ebx
  8015db:	e8 8f fc ff ff       	call   80126f <fd_lookup>
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 62                	js     801649 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f1:	ff 30                	pushl  (%eax)
  8015f3:	e8 cd fc ff ff       	call   8012c5 <dev_lookup>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 4a                	js     801649 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801606:	75 21                	jne    801629 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801608:	a1 04 40 80 00       	mov    0x804004,%eax
  80160d:	8b 40 48             	mov    0x48(%eax),%eax
  801610:	83 ec 04             	sub    $0x4,%esp
  801613:	53                   	push   %ebx
  801614:	50                   	push   %eax
  801615:	68 0d 29 80 00       	push   $0x80290d
  80161a:	e8 65 ed ff ff       	call   800384 <cprintf>
		return -E_INVAL;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801627:	eb 20                	jmp    801649 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801629:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162c:	8b 52 0c             	mov    0xc(%edx),%edx
  80162f:	85 d2                	test   %edx,%edx
  801631:	74 11                	je     801644 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	ff 75 10             	pushl  0x10(%ebp)
  801639:	ff 75 0c             	pushl  0xc(%ebp)
  80163c:	50                   	push   %eax
  80163d:	ff d2                	call   *%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 05                	jmp    801649 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801644:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801649:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <seek>:

int
seek(int fdnum, off_t offset)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801654:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 0f fc ff ff       	call   80126f <fd_lookup>
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 0e                	js     801675 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801667:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80166a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 14             	sub    $0x14,%esp
  80167e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	53                   	push   %ebx
  801686:	e8 e4 fb ff ff       	call   80126f <fd_lookup>
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 5f                	js     8016f1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169c:	ff 30                	pushl  (%eax)
  80169e:	e8 22 fc ff ff       	call   8012c5 <dev_lookup>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 47                	js     8016f1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b1:	75 21                	jne    8016d4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016b3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b8:	8b 40 48             	mov    0x48(%eax),%eax
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	53                   	push   %ebx
  8016bf:	50                   	push   %eax
  8016c0:	68 d0 28 80 00       	push   $0x8028d0
  8016c5:	e8 ba ec ff ff       	call   800384 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d2:	eb 1d                	jmp    8016f1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d7:	8b 52 18             	mov    0x18(%edx),%edx
  8016da:	85 d2                	test   %edx,%edx
  8016dc:	74 0e                	je     8016ec <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	50                   	push   %eax
  8016e5:	ff d2                	call   *%edx
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	eb 05                	jmp    8016f1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 14             	sub    $0x14,%esp
  8016fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801700:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 63 fb ff ff       	call   80126f <fd_lookup>
  80170c:	83 c4 08             	add    $0x8,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 52                	js     801765 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	ff 30                	pushl  (%eax)
  80171f:	e8 a1 fb ff ff       	call   8012c5 <dev_lookup>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 3a                	js     801765 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801732:	74 2c                	je     801760 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801734:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801737:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173e:	00 00 00 
	stat->st_isdir = 0;
  801741:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801748:	00 00 00 
	stat->st_dev = dev;
  80174b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	53                   	push   %ebx
  801755:	ff 75 f0             	pushl  -0x10(%ebp)
  801758:	ff 50 14             	call   *0x14(%eax)
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	eb 05                	jmp    801765 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	6a 00                	push   $0x0
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	e8 8b 01 00 00       	call   801907 <open>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 1b                	js     8017a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	ff 75 0c             	pushl  0xc(%ebp)
  80178b:	50                   	push   %eax
  80178c:	e8 65 ff ff ff       	call   8016f6 <fstat>
  801791:	89 c6                	mov    %eax,%esi
	close(fd);
  801793:	89 1c 24             	mov    %ebx,(%esp)
  801796:	e8 18 fc ff ff       	call   8013b3 <close>
	return r;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	89 f3                	mov    %esi,%ebx
}
  8017a0:	89 d8                	mov    %ebx,%eax
  8017a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    
  8017a9:	00 00                	add    %al,(%eax)
	...

008017ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017bc:	75 12                	jne    8017d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	6a 01                	push   $0x1
  8017c3:	e8 71 08 00 00       	call   802039 <ipc_find_env>
  8017c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d0:	6a 07                	push   $0x7
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	53                   	push   %ebx
  8017d8:	ff 35 00 40 80 00    	pushl  0x804000
  8017de:	e8 01 08 00 00       	call   801fe4 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	83 c4 0c             	add    $0xc,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	56                   	push   %esi
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 4c 07 00 00       	call   801f3c <ipc_recv>
}
  8017f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	8b 40 0c             	mov    0xc(%eax),%eax
  801807:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 05 00 00 00       	mov    $0x5,%eax
  801816:	e8 91 ff ff ff       	call   8017ac <fsipc>
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 39                	js     801858 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	68 3c 29 80 00       	push   $0x80293c
  801827:	e8 58 eb ff ff       	call   800384 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182c:	83 c4 08             	add    $0x8,%esp
  80182f:	68 00 50 80 00       	push   $0x805000
  801834:	53                   	push   %ebx
  801835:	e8 00 f1 ff ff       	call   80093a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183a:	a1 80 50 80 00       	mov    0x805080,%eax
  80183f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801845:	a1 84 50 80 00       	mov    0x805084,%eax
  80184a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 40 0c             	mov    0xc(%eax),%eax
  801869:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 06 00 00 00       	mov    $0x6,%eax
  801878:	e8 2f ff ff ff       	call   8017ac <fsipc>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801892:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a2:	e8 05 ff ff ff       	call   8017ac <fsipc>
  8018a7:	89 c3                	mov    %eax,%ebx
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 51                	js     8018fe <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8018ad:	39 c6                	cmp    %eax,%esi
  8018af:	73 19                	jae    8018ca <devfile_read+0x4b>
  8018b1:	68 42 29 80 00       	push   $0x802942
  8018b6:	68 49 29 80 00       	push   $0x802949
  8018bb:	68 80 00 00 00       	push   $0x80
  8018c0:	68 5e 29 80 00       	push   $0x80295e
  8018c5:	e8 e2 e9 ff ff       	call   8002ac <_panic>
	assert(r <= PGSIZE);
  8018ca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cf:	7e 19                	jle    8018ea <devfile_read+0x6b>
  8018d1:	68 69 29 80 00       	push   $0x802969
  8018d6:	68 49 29 80 00       	push   $0x802949
  8018db:	68 81 00 00 00       	push   $0x81
  8018e0:	68 5e 29 80 00       	push   $0x80295e
  8018e5:	e8 c2 e9 ff ff       	call   8002ac <_panic>
	memmove(buf, &fsipcbuf, r);
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	50                   	push   %eax
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	e8 00 f2 ff ff       	call   800afb <memmove>
	return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
}
  8018fe:	89 d8                	mov    %ebx,%eax
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	83 ec 1c             	sub    $0x1c,%esp
  80190f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801912:	56                   	push   %esi
  801913:	e8 d0 ef ff ff       	call   8008e8 <strlen>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801920:	7f 72                	jg     801994 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801928:	50                   	push   %eax
  801929:	e8 ce f8 ff ff       	call   8011fc <fd_alloc>
  80192e:	89 c3                	mov    %eax,%ebx
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 62                	js     801999 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	56                   	push   %esi
  80193b:	68 00 50 80 00       	push   $0x805000
  801940:	e8 f5 ef ff ff       	call   80093a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801945:	8b 45 0c             	mov    0xc(%ebp),%eax
  801948:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80194d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801950:	b8 01 00 00 00       	mov    $0x1,%eax
  801955:	e8 52 fe ff ff       	call   8017ac <fsipc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	79 12                	jns    801975 <open+0x6e>
		fd_close(fd, 0);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	6a 00                	push   $0x0
  801968:	ff 75 f4             	pushl  -0xc(%ebp)
  80196b:	e8 bb f9 ff ff       	call   80132b <fd_close>
		return r;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb 24                	jmp    801999 <open+0x92>
	}


	cprintf("OPEN\n");
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	68 75 29 80 00       	push   $0x802975
  80197d:	e8 02 ea ff ff       	call   800384 <cprintf>

	return fd2num(fd);
  801982:	83 c4 04             	add    $0x4,%esp
  801985:	ff 75 f4             	pushl  -0xc(%ebp)
  801988:	e8 47 f8 ff ff       	call   8011d4 <fd2num>
  80198d:	89 c3                	mov    %eax,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	eb 05                	jmp    801999 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801994:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801999:	89 d8                	mov    %ebx,%eax
  80199b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    
	...

008019a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff 75 08             	pushl  0x8(%ebp)
  8019b2:	e8 2d f8 ff ff       	call   8011e4 <fd2data>
  8019b7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	68 7b 29 80 00       	push   $0x80297b
  8019c1:	56                   	push   %esi
  8019c2:	e8 73 ef ff ff       	call   80093a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ca:	2b 03                	sub    (%ebx),%eax
  8019cc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019d2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019d9:	00 00 00 
	stat->st_dev = &devpipe;
  8019dc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019e3:	30 80 00 
	return 0;
}
  8019e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fc:	53                   	push   %ebx
  8019fd:	6a 00                	push   $0x0
  8019ff:	e8 02 f4 ff ff       	call   800e06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a04:	89 1c 24             	mov    %ebx,(%esp)
  801a07:	e8 d8 f7 ff ff       	call   8011e4 <fd2data>
  801a0c:	83 c4 08             	add    $0x8,%esp
  801a0f:	50                   	push   %eax
  801a10:	6a 00                	push   $0x0
  801a12:	e8 ef f3 ff ff       	call   800e06 <sys_page_unmap>
}
  801a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 1c             	sub    $0x1c,%esp
  801a25:	89 c7                	mov    %eax,%edi
  801a27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	57                   	push   %edi
  801a36:	e8 59 06 00 00       	call   802094 <pageref>
  801a3b:	89 c6                	mov    %eax,%esi
  801a3d:	83 c4 04             	add    $0x4,%esp
  801a40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a43:	e8 4c 06 00 00       	call   802094 <pageref>
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	39 c6                	cmp    %eax,%esi
  801a4d:	0f 94 c0             	sete   %al
  801a50:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a5c:	39 cb                	cmp    %ecx,%ebx
  801a5e:	75 08                	jne    801a68 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5f                   	pop    %edi
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a68:	83 f8 01             	cmp    $0x1,%eax
  801a6b:	75 bd                	jne    801a2a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a6d:	8b 42 58             	mov    0x58(%edx),%eax
  801a70:	6a 01                	push   $0x1
  801a72:	50                   	push   %eax
  801a73:	53                   	push   %ebx
  801a74:	68 82 29 80 00       	push   $0x802982
  801a79:	e8 06 e9 ff ff       	call   800384 <cprintf>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	eb a7                	jmp    801a2a <_pipeisclosed+0xe>

00801a83 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	57                   	push   %edi
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	83 ec 28             	sub    $0x28,%esp
  801a8c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a8f:	56                   	push   %esi
  801a90:	e8 4f f7 ff ff       	call   8011e4 <fd2data>
  801a95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a9e:	75 4a                	jne    801aea <devpipe_write+0x67>
  801aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa5:	eb 56                	jmp    801afd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa7:	89 da                	mov    %ebx,%edx
  801aa9:	89 f0                	mov    %esi,%eax
  801aab:	e8 6c ff ff ff       	call   801a1c <_pipeisclosed>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	75 4d                	jne    801b01 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab4:	e8 dc f2 ff ff       	call   800d95 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab9:	8b 43 04             	mov    0x4(%ebx),%eax
  801abc:	8b 13                	mov    (%ebx),%edx
  801abe:	83 c2 20             	add    $0x20,%edx
  801ac1:	39 d0                	cmp    %edx,%eax
  801ac3:	73 e2                	jae    801aa7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801acd:	79 05                	jns    801ad4 <devpipe_write+0x51>
  801acf:	4a                   	dec    %edx
  801ad0:	83 ca e0             	or     $0xffffffe0,%edx
  801ad3:	42                   	inc    %edx
  801ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ada:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ade:	40                   	inc    %eax
  801adf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	47                   	inc    %edi
  801ae3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ae6:	77 07                	ja     801aef <devpipe_write+0x6c>
  801ae8:	eb 13                	jmp    801afd <devpipe_write+0x7a>
  801aea:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aef:	8b 43 04             	mov    0x4(%ebx),%eax
  801af2:	8b 13                	mov    (%ebx),%edx
  801af4:	83 c2 20             	add    $0x20,%edx
  801af7:	39 d0                	cmp    %edx,%eax
  801af9:	73 ac                	jae    801aa7 <devpipe_write+0x24>
  801afb:	eb c8                	jmp    801ac5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801afd:	89 f8                	mov    %edi,%eax
  801aff:	eb 05                	jmp    801b06 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 18             	sub    $0x18,%esp
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1a:	57                   	push   %edi
  801b1b:	e8 c4 f6 ff ff       	call   8011e4 <fd2data>
  801b20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b29:	75 44                	jne    801b6f <devpipe_read+0x61>
  801b2b:	be 00 00 00 00       	mov    $0x0,%esi
  801b30:	eb 4f                	jmp    801b81 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b32:	89 f0                	mov    %esi,%eax
  801b34:	eb 54                	jmp    801b8a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b36:	89 da                	mov    %ebx,%edx
  801b38:	89 f8                	mov    %edi,%eax
  801b3a:	e8 dd fe ff ff       	call   801a1c <_pipeisclosed>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	75 42                	jne    801b85 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b43:	e8 4d f2 ff ff       	call   800d95 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b48:	8b 03                	mov    (%ebx),%eax
  801b4a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b4d:	74 e7                	je     801b36 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b54:	79 05                	jns    801b5b <devpipe_read+0x4d>
  801b56:	48                   	dec    %eax
  801b57:	83 c8 e0             	or     $0xffffffe0,%eax
  801b5a:	40                   	inc    %eax
  801b5b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b62:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b65:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b67:	46                   	inc    %esi
  801b68:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b6b:	77 07                	ja     801b74 <devpipe_read+0x66>
  801b6d:	eb 12                	jmp    801b81 <devpipe_read+0x73>
  801b6f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b74:	8b 03                	mov    (%ebx),%eax
  801b76:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b79:	75 d4                	jne    801b4f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7b:	85 f6                	test   %esi,%esi
  801b7d:	75 b3                	jne    801b32 <devpipe_read+0x24>
  801b7f:	eb b5                	jmp    801b36 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b81:	89 f0                	mov    %esi,%eax
  801b83:	eb 05                	jmp    801b8a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 28             	sub    $0x28,%esp
  801b9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 55 f6 ff ff       	call   8011fc <fd_alloc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 24 01 00 00    	js     801cd8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	68 07 04 00 00       	push   $0x407
  801bbc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 f6 f1 ff ff       	call   800dbc <sys_page_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 05 01 00 00    	js     801cd8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	e8 1d f6 ff ff       	call   8011fc <fd_alloc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 dc 00 00 00    	js     801cc8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bec:	83 ec 04             	sub    $0x4,%esp
  801bef:	68 07 04 00 00       	push   $0x407
  801bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 be f1 ff ff       	call   800dbc <sys_page_alloc>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	0f 88 bd 00 00 00    	js     801cc8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c11:	e8 ce f5 ff ff       	call   8011e4 <fd2data>
  801c16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 c4 0c             	add    $0xc,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	50                   	push   %eax
  801c21:	6a 00                	push   $0x0
  801c23:	e8 94 f1 ff ff       	call   800dbc <sys_page_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 83 00 00 00    	js     801cb8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 e0             	pushl  -0x20(%ebp)
  801c3b:	e8 a4 f5 ff ff       	call   8011e4 <fd2data>
  801c40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c47:	50                   	push   %eax
  801c48:	6a 00                	push   $0x0
  801c4a:	56                   	push   %esi
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 8e f1 ff ff       	call   800de0 <sys_page_map>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 20             	add    $0x20,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 4f                	js     801caa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c8b:	e8 44 f5 ff ff       	call   8011d4 <fd2num>
  801c90:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c92:	83 c4 04             	add    $0x4,%esp
  801c95:	ff 75 e0             	pushl  -0x20(%ebp)
  801c98:	e8 37 f5 ff ff       	call   8011d4 <fd2num>
  801c9d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca8:	eb 2e                	jmp    801cd8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	56                   	push   %esi
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 51 f1 ff ff       	call   800e06 <sys_page_unmap>
  801cb5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb8:	83 ec 08             	sub    $0x8,%esp
  801cbb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 41 f1 ff ff       	call   800e06 <sys_page_unmap>
  801cc5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 31 f1 ff ff       	call   800e06 <sys_page_unmap>
  801cd5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	ff 75 08             	pushl  0x8(%ebp)
  801cef:	e8 7b f5 ff ff       	call   80126f <fd_lookup>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 18                	js     801d13 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801d01:	e8 de f4 ff ff       	call   8011e4 <fd2data>
	return _pipeisclosed(fd, p);
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	e8 0c fd ff ff       	call   801a1c <_pipeisclosed>
  801d10:	83 c4 10             	add    $0x10,%esp
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    
  801d15:	00 00                	add    %al,(%eax)
	...

00801d18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d28:	68 95 29 80 00       	push   $0x802995
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	e8 05 ec ff ff       	call   80093a <strcpy>
	return 0;
}
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4c:	74 45                	je     801d93 <devcons_write+0x57>
  801d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d61:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d63:	83 fb 7f             	cmp    $0x7f,%ebx
  801d66:	76 05                	jbe    801d6d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d68:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d6d:	83 ec 04             	sub    $0x4,%esp
  801d70:	53                   	push   %ebx
  801d71:	03 45 0c             	add    0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	57                   	push   %edi
  801d76:	e8 80 ed ff ff       	call   800afb <memmove>
		sys_cputs(buf, m);
  801d7b:	83 c4 08             	add    $0x8,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	57                   	push   %edi
  801d80:	e8 80 ef ff ff       	call   800d05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d85:	01 de                	add    %ebx,%esi
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8f:	72 cd                	jb     801d5e <devcons_write+0x22>
  801d91:	eb 05                	jmp    801d98 <devcons_write+0x5c>
  801d93:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d98:	89 f0                	mov    %esi,%eax
  801d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801da8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dac:	75 07                	jne    801db5 <devcons_read+0x13>
  801dae:	eb 25                	jmp    801dd5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db0:	e8 e0 ef ff ff       	call   800d95 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db5:	e8 71 ef ff ff       	call   800d2b <sys_cgetc>
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	74 f2                	je     801db0 <devcons_read+0xe>
  801dbe:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 1d                	js     801de1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc4:	83 f8 04             	cmp    $0x4,%eax
  801dc7:	74 13                	je     801ddc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcc:	88 10                	mov    %dl,(%eax)
	return 1;
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	eb 0c                	jmp    801de1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dda:	eb 05                	jmp    801de1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801def:	6a 01                	push   $0x1
  801df1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	e8 0b ef ff ff       	call   800d05 <sys_cputs>
  801dfa:	83 c4 10             	add    $0x10,%esp
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <getchar>:

int
getchar(void)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e05:	6a 01                	push   $0x1
  801e07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 de f6 ff ff       	call   8014f0 <read>
	if (r < 0)
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 0f                	js     801e28 <getchar+0x29>
		return r;
	if (r < 1)
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	7e 06                	jle    801e23 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e21:	eb 05                	jmp    801e28 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e23:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	ff 75 08             	pushl  0x8(%ebp)
  801e37:	e8 33 f4 ff ff       	call   80126f <fd_lookup>
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 11                	js     801e54 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e4c:	39 10                	cmp    %edx,(%eax)
  801e4e:	0f 94 c0             	sete   %al
  801e51:	0f b6 c0             	movzbl %al,%eax
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <opencons>:

int
opencons(void)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	e8 97 f3 ff ff       	call   8011fc <fd_alloc>
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 3a                	js     801ea6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6c:	83 ec 04             	sub    $0x4,%esp
  801e6f:	68 07 04 00 00       	push   $0x407
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 3e ef ff ff       	call   800dbc <sys_page_alloc>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 21                	js     801ea6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	50                   	push   %eax
  801e9e:	e8 31 f3 ff ff       	call   8011d4 <fd2num>
  801ea3:	83 c4 10             	add    $0x10,%esp
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb5:	75 52                	jne    801f09 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801eb7:	83 ec 04             	sub    $0x4,%esp
  801eba:	6a 07                	push   $0x7
  801ebc:	68 00 f0 bf ee       	push   $0xeebff000
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 f4 ee ff ff       	call   800dbc <sys_page_alloc>
		if (r < 0) {
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	79 12                	jns    801ee1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ecf:	50                   	push   %eax
  801ed0:	68 a1 29 80 00       	push   $0x8029a1
  801ed5:	6a 24                	push   $0x24
  801ed7:	68 bc 29 80 00       	push   $0x8029bc
  801edc:	e8 cb e3 ff ff       	call   8002ac <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	68 14 1f 80 00       	push   $0x801f14
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 7f ef ff ff       	call   800e6f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 12                	jns    801f09 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801ef7:	50                   	push   %eax
  801ef8:	68 cc 29 80 00       	push   $0x8029cc
  801efd:	6a 2a                	push   $0x2a
  801eff:	68 bc 29 80 00       	push   $0x8029bc
  801f04:	e8 a3 e3 ff ff       	call   8002ac <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f09:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    
	...

00801f14 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f15:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f1c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f1f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f23:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f26:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f2a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f2e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f30:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f33:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f34:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f37:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f38:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f39:	c3                   	ret    
	...

00801f3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	57                   	push   %edi
  801f40:	56                   	push   %esi
  801f41:	53                   	push   %ebx
  801f42:	83 ec 0c             	sub    $0xc,%esp
  801f45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f4b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	57                   	push   %edi
  801f51:	68 f4 29 80 00       	push   $0x8029f4
  801f56:	e8 29 e4 ff ff       	call   800384 <cprintf>
	int r;
	if (pg != NULL) {
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	85 db                	test   %ebx,%ebx
  801f60:	74 28                	je     801f8a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801f62:	83 ec 0c             	sub    $0xc,%esp
  801f65:	68 04 2a 80 00       	push   $0x802a04
  801f6a:	e8 15 e4 ff ff       	call   800384 <cprintf>
		r = sys_ipc_recv(pg);
  801f6f:	89 1c 24             	mov    %ebx,(%esp)
  801f72:	e8 40 ef ff ff       	call   800eb7 <sys_ipc_recv>
  801f77:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801f79:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801f80:	e8 ff e3 ff ff       	call   800384 <cprintf>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	eb 12                	jmp    801f9c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f8a:	83 ec 0c             	sub    $0xc,%esp
  801f8d:	68 00 00 c0 ee       	push   $0xeec00000
  801f92:	e8 20 ef ff ff       	call   800eb7 <sys_ipc_recv>
  801f97:	89 c3                	mov    %eax,%ebx
  801f99:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f9c:	85 db                	test   %ebx,%ebx
  801f9e:	75 26                	jne    801fc6 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801fa0:	85 ff                	test   %edi,%edi
  801fa2:	74 0a                	je     801fae <ipc_recv+0x72>
  801fa4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa9:	8b 40 74             	mov    0x74(%eax),%eax
  801fac:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fae:	85 f6                	test   %esi,%esi
  801fb0:	74 0a                	je     801fbc <ipc_recv+0x80>
  801fb2:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb7:	8b 40 78             	mov    0x78(%eax),%eax
  801fba:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801fbc:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc1:	8b 58 70             	mov    0x70(%eax),%ebx
  801fc4:	eb 14                	jmp    801fda <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fc6:	85 ff                	test   %edi,%edi
  801fc8:	74 06                	je     801fd0 <ipc_recv+0x94>
  801fca:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801fd0:	85 f6                	test   %esi,%esi
  801fd2:	74 06                	je     801fda <ipc_recv+0x9e>
  801fd4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801fda:	89 d8                	mov    %ebx,%eax
  801fdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	83 ec 0c             	sub    $0xc,%esp
  801fed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ff0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff3:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ff6:	85 db                	test   %ebx,%ebx
  801ff8:	75 25                	jne    80201f <ipc_send+0x3b>
  801ffa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fff:	eb 1e                	jmp    80201f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802004:	75 07                	jne    80200d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802006:	e8 8a ed ff ff       	call   800d95 <sys_yield>
  80200b:	eb 12                	jmp    80201f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80200d:	50                   	push   %eax
  80200e:	68 0b 2a 80 00       	push   $0x802a0b
  802013:	6a 45                	push   $0x45
  802015:	68 1e 2a 80 00       	push   $0x802a1e
  80201a:	e8 8d e2 ff ff       	call   8002ac <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	57                   	push   %edi
  802022:	ff 75 08             	pushl  0x8(%ebp)
  802025:	e8 68 ee ff ff       	call   800e92 <sys_ipc_try_send>
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	85 c0                	test   %eax,%eax
  80202f:	75 d0                	jne    802001 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	53                   	push   %ebx
  80203d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802040:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802046:	74 22                	je     80206a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802048:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80204d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802054:	89 c2                	mov    %eax,%edx
  802056:	c1 e2 07             	shl    $0x7,%edx
  802059:	29 ca                	sub    %ecx,%edx
  80205b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802061:	8b 52 50             	mov    0x50(%edx),%edx
  802064:	39 da                	cmp    %ebx,%edx
  802066:	75 1d                	jne    802085 <ipc_find_env+0x4c>
  802068:	eb 05                	jmp    80206f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80206f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802076:	c1 e0 07             	shl    $0x7,%eax
  802079:	29 d0                	sub    %edx,%eax
  80207b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802080:	8b 40 40             	mov    0x40(%eax),%eax
  802083:	eb 0c                	jmp    802091 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802085:	40                   	inc    %eax
  802086:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208b:	75 c0                	jne    80204d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80208d:	66 b8 00 00          	mov    $0x0,%ax
}
  802091:	5b                   	pop    %ebx
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209a:	89 c2                	mov    %eax,%edx
  80209c:	c1 ea 16             	shr    $0x16,%edx
  80209f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020a6:	f6 c2 01             	test   $0x1,%dl
  8020a9:	74 1e                	je     8020c9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ab:	c1 e8 0c             	shr    $0xc,%eax
  8020ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020b5:	a8 01                	test   $0x1,%al
  8020b7:	74 17                	je     8020d0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b9:	c1 e8 0c             	shr    $0xc,%eax
  8020bc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020c3:	ef 
  8020c4:	0f b7 c0             	movzwl %ax,%eax
  8020c7:	eb 0c                	jmp    8020d5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ce:	eb 05                	jmp    8020d5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020d0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    
	...

008020d8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	57                   	push   %edi
  8020dc:	56                   	push   %esi
  8020dd:	83 ec 10             	sub    $0x10,%esp
  8020e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020e6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020ec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020ef:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	75 2e                	jne    802124 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020f6:	39 f1                	cmp    %esi,%ecx
  8020f8:	77 5a                	ja     802154 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020fa:	85 c9                	test   %ecx,%ecx
  8020fc:	75 0b                	jne    802109 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f1                	div    %ecx
  802107:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802109:	31 d2                	xor    %edx,%edx
  80210b:	89 f0                	mov    %esi,%eax
  80210d:	f7 f1                	div    %ecx
  80210f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802111:	89 f8                	mov    %edi,%eax
  802113:	f7 f1                	div    %ecx
  802115:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802117:	89 f8                	mov    %edi,%eax
  802119:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	c9                   	leave  
  802121:	c3                   	ret    
  802122:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802124:	39 f0                	cmp    %esi,%eax
  802126:	77 1c                	ja     802144 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802128:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80212b:	83 f7 1f             	xor    $0x1f,%edi
  80212e:	75 3c                	jne    80216c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802130:	39 f0                	cmp    %esi,%eax
  802132:	0f 82 90 00 00 00    	jb     8021c8 <__udivdi3+0xf0>
  802138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80213e:	0f 86 84 00 00 00    	jbe    8021c8 <__udivdi3+0xf0>
  802144:	31 f6                	xor    %esi,%esi
  802146:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802148:	89 f8                	mov    %edi,%eax
  80214a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	5e                   	pop    %esi
  802150:	5f                   	pop    %edi
  802151:	c9                   	leave  
  802152:	c3                   	ret    
  802153:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802154:	89 f2                	mov    %esi,%edx
  802156:	89 f8                	mov    %edi,%eax
  802158:	f7 f1                	div    %ecx
  80215a:	89 c7                	mov    %eax,%edi
  80215c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80215e:	89 f8                	mov    %edi,%eax
  802160:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	c9                   	leave  
  802168:	c3                   	ret    
  802169:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80216c:	89 f9                	mov    %edi,%ecx
  80216e:	d3 e0                	shl    %cl,%eax
  802170:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802173:	b8 20 00 00 00       	mov    $0x20,%eax
  802178:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80217a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217d:	88 c1                	mov    %al,%cl
  80217f:	d3 ea                	shr    %cl,%edx
  802181:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802184:	09 ca                	or     %ecx,%edx
  802186:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802189:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80218c:	89 f9                	mov    %edi,%ecx
  80218e:	d3 e2                	shl    %cl,%edx
  802190:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802193:	89 f2                	mov    %esi,%edx
  802195:	88 c1                	mov    %al,%cl
  802197:	d3 ea                	shr    %cl,%edx
  802199:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80219c:	89 f2                	mov    %esi,%edx
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	d3 e2                	shl    %cl,%edx
  8021a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021a5:	88 c1                	mov    %al,%cl
  8021a7:	d3 ee                	shr    %cl,%esi
  8021a9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021ab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021ae:	89 f0                	mov    %esi,%eax
  8021b0:	89 ca                	mov    %ecx,%edx
  8021b2:	f7 75 ec             	divl   -0x14(%ebp)
  8021b5:	89 d1                	mov    %edx,%ecx
  8021b7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021b9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021bc:	39 d1                	cmp    %edx,%ecx
  8021be:	72 28                	jb     8021e8 <__udivdi3+0x110>
  8021c0:	74 1a                	je     8021dc <__udivdi3+0x104>
  8021c2:	89 f7                	mov    %esi,%edi
  8021c4:	31 f6                	xor    %esi,%esi
  8021c6:	eb 80                	jmp    802148 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021cf:	89 f8                	mov    %edi,%eax
  8021d1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021d3:	83 c4 10             	add    $0x10,%esp
  8021d6:	5e                   	pop    %esi
  8021d7:	5f                   	pop    %edi
  8021d8:	c9                   	leave  
  8021d9:	c3                   	ret    
  8021da:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021df:	89 f9                	mov    %edi,%ecx
  8021e1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e3:	39 c2                	cmp    %eax,%edx
  8021e5:	73 db                	jae    8021c2 <__udivdi3+0xea>
  8021e7:	90                   	nop
		{
		  q0--;
  8021e8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021eb:	31 f6                	xor    %esi,%esi
  8021ed:	e9 56 ff ff ff       	jmp    802148 <__udivdi3+0x70>
	...

008021f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	57                   	push   %edi
  8021f8:	56                   	push   %esi
  8021f9:	83 ec 20             	sub    $0x20,%esp
  8021fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802202:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802205:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802208:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80220b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80220e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802211:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802213:	85 ff                	test   %edi,%edi
  802215:	75 15                	jne    80222c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802217:	39 f1                	cmp    %esi,%ecx
  802219:	0f 86 99 00 00 00    	jbe    8022b8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80221f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802221:	89 d0                	mov    %edx,%eax
  802223:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802225:	83 c4 20             	add    $0x20,%esp
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	0f 87 a4 00 00 00    	ja     8022d8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802234:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802237:	83 f0 1f             	xor    $0x1f,%eax
  80223a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80223d:	0f 84 a1 00 00 00    	je     8022e4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802243:	89 f8                	mov    %edi,%eax
  802245:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802248:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80224a:	bf 20 00 00 00       	mov    $0x20,%edi
  80224f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	09 c2                	or     %eax,%edx
  80225b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80225e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802261:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802264:	d3 e0                	shl    %cl,%eax
  802266:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802269:	89 f2                	mov    %esi,%edx
  80226b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80226d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802270:	d3 e0                	shl    %cl,%eax
  802272:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802275:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802278:	89 f9                	mov    %edi,%ecx
  80227a:	d3 e8                	shr    %cl,%eax
  80227c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80227e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802280:	89 f2                	mov    %esi,%edx
  802282:	f7 75 f0             	divl   -0x10(%ebp)
  802285:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802287:	f7 65 f4             	mull   -0xc(%ebp)
  80228a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80228d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80228f:	39 d6                	cmp    %edx,%esi
  802291:	72 71                	jb     802304 <__umoddi3+0x110>
  802293:	74 7f                	je     802314 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802298:	29 c8                	sub    %ecx,%eax
  80229a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80229c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80229f:	d3 e8                	shr    %cl,%eax
  8022a1:	89 f2                	mov    %esi,%edx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022a7:	09 d0                	or     %edx,%eax
  8022a9:	89 f2                	mov    %esi,%edx
  8022ab:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022ae:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022b0:	83 c4 20             	add    $0x20,%esp
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    
  8022b7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022b8:	85 c9                	test   %ecx,%ecx
  8022ba:	75 0b                	jne    8022c7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c1:	31 d2                	xor    %edx,%edx
  8022c3:	f7 f1                	div    %ecx
  8022c5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022c7:	89 f0                	mov    %esi,%eax
  8022c9:	31 d2                	xor    %edx,%edx
  8022cb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d0:	f7 f1                	div    %ecx
  8022d2:	e9 4a ff ff ff       	jmp    802221 <__umoddi3+0x2d>
  8022d7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022d8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022da:	83 c4 20             	add    $0x20,%esp
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    
  8022e1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e4:	39 f7                	cmp    %esi,%edi
  8022e6:	72 05                	jb     8022ed <__umoddi3+0xf9>
  8022e8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022eb:	77 0c                	ja     8022f9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f2:	29 c8                	sub    %ecx,%eax
  8022f4:	19 fa                	sbb    %edi,%edx
  8022f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022fc:	83 c4 20             	add    $0x20,%esp
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	c9                   	leave  
  802302:	c3                   	ret    
  802303:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802304:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802307:	89 c1                	mov    %eax,%ecx
  802309:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80230c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80230f:	eb 84                	jmp    802295 <__umoddi3+0xa1>
  802311:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802314:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802317:	72 eb                	jb     802304 <__umoddi3+0x110>
  802319:	89 f2                	mov    %esi,%edx
  80231b:	e9 75 ff ff ff       	jmp    802295 <__umoddi3+0xa1>
