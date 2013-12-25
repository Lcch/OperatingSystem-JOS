
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 83 02 00 00       	call   8002b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 60 	movl   $0x802460,0x803004
  800043:	24 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	50                   	push   %eax
  80004a:	e8 3f 1c 00 00       	call   801c8e <pipe>
  80004f:	89 c6                	mov    %eax,%esi
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", i);
  800058:	50                   	push   %eax
  800059:	68 6c 24 80 00       	push   $0x80246c
  80005e:	6a 0e                	push   $0xe
  800060:	68 75 24 80 00       	push   $0x802475
  800065:	e8 b2 02 00 00       	call   80031c <_panic>

	if ((pid = fork()) < 0)
  80006a:	e8 3b 10 00 00       	call   8010aa <fork>
  80006f:	89 c3                	mov    %eax,%ebx
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", i);
  800075:	56                   	push   %esi
  800076:	68 85 24 80 00       	push   $0x802485
  80007b:	6a 11                	push   $0x11
  80007d:	68 75 24 80 00       	push   $0x802475
  800082:	e8 95 02 00 00       	call   80031c <_panic>

	if (pid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 85 b8 00 00 00    	jne    800147 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	8b 40 48             	mov    0x48(%eax),%eax
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	ff 75 90             	pushl  -0x70(%ebp)
  80009d:	50                   	push   %eax
  80009e:	68 8e 24 80 00       	push   $0x80248e
  8000a3:	e8 4c 03 00 00       	call   8003f4 <cprintf>
		close(p[1]);
  8000a8:	83 c4 04             	add    $0x4,%esp
  8000ab:	ff 75 90             	pushl  -0x70(%ebp)
  8000ae:	e8 1c 14 00 00       	call   8014cf <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b8:	8b 40 48             	mov    0x48(%eax),%eax
  8000bb:	83 c4 0c             	add    $0xc,%esp
  8000be:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c1:	50                   	push   %eax
  8000c2:	68 ab 24 80 00       	push   $0x8024ab
  8000c7:	e8 28 03 00 00       	call   8003f4 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cc:	83 c4 0c             	add    $0xc,%esp
  8000cf:	6a 63                	push   $0x63
  8000d1:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d4:	50                   	push   %eax
  8000d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d8:	e8 b6 15 00 00       	call   801693 <readn>
  8000dd:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <umain+0xc4>
			panic("read: %e", i);
  8000e6:	50                   	push   %eax
  8000e7:	68 c8 24 80 00       	push   $0x8024c8
  8000ec:	6a 19                	push   $0x19
  8000ee:	68 75 24 80 00       	push   $0x802475
  8000f3:	e8 24 02 00 00       	call   80031c <_panic>
		buf[i] = 0;
  8000f8:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	ff 35 00 30 80 00    	pushl  0x803000
  800106:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800109:	50                   	push   %eax
  80010a:	e8 54 09 00 00       	call   800a63 <strcmp>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	75 12                	jne    800128 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	68 d1 24 80 00       	push   $0x8024d1
  80011e:	e8 d1 02 00 00       	call   8003f4 <cprintf>
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	eb 15                	jmp    80013d <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	56                   	push   %esi
  800130:	68 ed 24 80 00       	push   $0x8024ed
  800135:	e8 ba 02 00 00       	call   8003f4 <cprintf>
  80013a:	83 c4 10             	add    $0x10,%esp
		exit();
  80013d:	e8 be 01 00 00       	call   800300 <exit>
  800142:	e9 94 00 00 00       	jmp    8001db <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800147:	a1 04 40 80 00       	mov    0x804004,%eax
  80014c:	8b 40 48             	mov    0x48(%eax),%eax
  80014f:	83 ec 04             	sub    $0x4,%esp
  800152:	ff 75 8c             	pushl  -0x74(%ebp)
  800155:	50                   	push   %eax
  800156:	68 8e 24 80 00       	push   $0x80248e
  80015b:	e8 94 02 00 00       	call   8003f4 <cprintf>
		close(p[0]);
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 8c             	pushl  -0x74(%ebp)
  800166:	e8 64 13 00 00       	call   8014cf <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016b:	a1 04 40 80 00       	mov    0x804004,%eax
  800170:	8b 40 48             	mov    0x48(%eax),%eax
  800173:	83 c4 0c             	add    $0xc,%esp
  800176:	ff 75 90             	pushl  -0x70(%ebp)
  800179:	50                   	push   %eax
  80017a:	68 00 25 80 00       	push   $0x802500
  80017f:	e8 70 02 00 00       	call   8003f4 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800184:	83 c4 04             	add    $0x4,%esp
  800187:	ff 35 00 30 80 00    	pushl  0x803000
  80018d:	e8 c6 07 00 00       	call   800958 <strlen>
  800192:	83 c4 0c             	add    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	ff 35 00 30 80 00    	pushl  0x803000
  80019c:	ff 75 90             	pushl  -0x70(%ebp)
  80019f:	e8 44 15 00 00       	call   8016e8 <write>
  8001a4:	89 c6                	mov    %eax,%esi
  8001a6:	83 c4 04             	add    $0x4,%esp
  8001a9:	ff 35 00 30 80 00    	pushl  0x803000
  8001af:	e8 a4 07 00 00       	call   800958 <strlen>
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	39 c6                	cmp    %eax,%esi
  8001b9:	74 12                	je     8001cd <umain+0x199>
			panic("write: %e", i);
  8001bb:	56                   	push   %esi
  8001bc:	68 1d 25 80 00       	push   $0x80251d
  8001c1:	6a 25                	push   $0x25
  8001c3:	68 75 24 80 00       	push   $0x802475
  8001c8:	e8 4f 01 00 00       	call   80031c <_panic>
		close(p[1]);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	ff 75 90             	pushl  -0x70(%ebp)
  8001d3:	e8 f7 12 00 00       	call   8014cf <close>
  8001d8:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	53                   	push   %ebx
  8001df:	e8 30 1c 00 00       	call   801e14 <wait>

	binaryname = "pipewriteeof";
  8001e4:	c7 05 04 30 80 00 27 	movl   $0x802527,0x803004
  8001eb:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ee:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 95 1a 00 00       	call   801c8e <pipe>
  8001f9:	89 c6                	mov    %eax,%esi
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	85 c0                	test   %eax,%eax
  800200:	79 12                	jns    800214 <umain+0x1e0>
		panic("pipe: %e", i);
  800202:	50                   	push   %eax
  800203:	68 6c 24 80 00       	push   $0x80246c
  800208:	6a 2c                	push   $0x2c
  80020a:	68 75 24 80 00       	push   $0x802475
  80020f:	e8 08 01 00 00       	call   80031c <_panic>

	if ((pid = fork()) < 0)
  800214:	e8 91 0e 00 00       	call   8010aa <fork>
  800219:	89 c3                	mov    %eax,%ebx
  80021b:	85 c0                	test   %eax,%eax
  80021d:	79 12                	jns    800231 <umain+0x1fd>
		panic("fork: %e", i);
  80021f:	56                   	push   %esi
  800220:	68 85 24 80 00       	push   $0x802485
  800225:	6a 2f                	push   $0x2f
  800227:	68 75 24 80 00       	push   $0x802475
  80022c:	e8 eb 00 00 00       	call   80031c <_panic>

	if (pid == 0) {
  800231:	85 c0                	test   %eax,%eax
  800233:	75 4a                	jne    80027f <umain+0x24b>
		close(p[0]);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 8c             	pushl  -0x74(%ebp)
  80023b:	e8 8f 12 00 00       	call   8014cf <close>
  800240:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	68 34 25 80 00       	push   $0x802534
  80024b:	e8 a4 01 00 00       	call   8003f4 <cprintf>
			if (write(p[1], "x", 1) != 1)
  800250:	83 c4 0c             	add    $0xc,%esp
  800253:	6a 01                	push   $0x1
  800255:	68 36 25 80 00       	push   $0x802536
  80025a:	ff 75 90             	pushl  -0x70(%ebp)
  80025d:	e8 86 14 00 00       	call   8016e8 <write>
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	83 f8 01             	cmp    $0x1,%eax
  800268:	74 d9                	je     800243 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 38 25 80 00       	push   $0x802538
  800272:	e8 7d 01 00 00       	call   8003f4 <cprintf>
		exit();
  800277:	e8 84 00 00 00       	call   800300 <exit>
  80027c:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	ff 75 8c             	pushl  -0x74(%ebp)
  800285:	e8 45 12 00 00       	call   8014cf <close>
	close(p[1]);
  80028a:	83 c4 04             	add    $0x4,%esp
  80028d:	ff 75 90             	pushl  -0x70(%ebp)
  800290:	e8 3a 12 00 00       	call   8014cf <close>
	wait(pid);
  800295:	89 1c 24             	mov    %ebx,(%esp)
  800298:	e8 77 1b 00 00       	call   801e14 <wait>

	cprintf("pipe tests passed\n");
  80029d:	c7 04 24 55 25 80 00 	movl   $0x802555,(%esp)
  8002a4:	e8 4b 01 00 00       	call   8003f4 <cprintf>
  8002a9:	83 c4 10             	add    $0x10,%esp
}
  8002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    
	...

008002b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8002bf:	e8 1d 0b 00 00       	call   800de1 <sys_getenvid>
  8002c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c9:	89 c2                	mov    %eax,%edx
  8002cb:	c1 e2 07             	shl    $0x7,%edx
  8002ce:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8002d5:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002da:	85 f6                	test   %esi,%esi
  8002dc:	7e 07                	jle    8002e5 <libmain+0x31>
		binaryname = argv[0];
  8002de:	8b 03                	mov    (%ebx),%eax
  8002e0:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	53                   	push   %ebx
  8002e9:	56                   	push   %esi
  8002ea:	e8 45 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002ef:	e8 0c 00 00 00       	call   800300 <exit>
  8002f4:	83 c4 10             	add    $0x10,%esp
}
  8002f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    
	...

00800300 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800306:	e8 ef 11 00 00       	call   8014fa <close_all>
	sys_env_destroy(0);
  80030b:	83 ec 0c             	sub    $0xc,%esp
  80030e:	6a 00                	push   $0x0
  800310:	e8 aa 0a 00 00       	call   800dbf <sys_env_destroy>
  800315:	83 c4 10             	add    $0x10,%esp
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    
	...

0080031c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800321:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800324:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80032a:	e8 b2 0a 00 00       	call   800de1 <sys_getenvid>
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	ff 75 0c             	pushl  0xc(%ebp)
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	53                   	push   %ebx
  800339:	50                   	push   %eax
  80033a:	68 b8 25 80 00       	push   $0x8025b8
  80033f:	e8 b0 00 00 00       	call   8003f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800344:	83 c4 18             	add    $0x18,%esp
  800347:	56                   	push   %esi
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	e8 53 00 00 00       	call   8003a3 <vcprintf>
	cprintf("\n");
  800350:	c7 04 24 a9 24 80 00 	movl   $0x8024a9,(%esp)
  800357:	e8 98 00 00 00       	call   8003f4 <cprintf>
  80035c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035f:	cc                   	int3   
  800360:	eb fd                	jmp    80035f <_panic+0x43>
	...

00800364 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	53                   	push   %ebx
  800368:	83 ec 04             	sub    $0x4,%esp
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036e:	8b 03                	mov    (%ebx),%eax
  800370:	8b 55 08             	mov    0x8(%ebp),%edx
  800373:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800377:	40                   	inc    %eax
  800378:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80037a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037f:	75 1a                	jne    80039b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	68 ff 00 00 00       	push   $0xff
  800389:	8d 43 08             	lea    0x8(%ebx),%eax
  80038c:	50                   	push   %eax
  80038d:	e8 e3 09 00 00       	call   800d75 <sys_cputs>
		b->idx = 0;
  800392:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800398:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039b:	ff 43 04             	incl   0x4(%ebx)
}
  80039e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b3:	00 00 00 
	b.cnt = 0;
  8003b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c0:	ff 75 0c             	pushl  0xc(%ebp)
  8003c3:	ff 75 08             	pushl  0x8(%ebp)
  8003c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	68 64 03 80 00       	push   $0x800364
  8003d2:	e8 82 01 00 00       	call   800559 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d7:	83 c4 08             	add    $0x8,%esp
  8003da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e6:	50                   	push   %eax
  8003e7:	e8 89 09 00 00       	call   800d75 <sys_cputs>

	return b.cnt;
}
  8003ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 9d ff ff ff       	call   8003a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
  80040e:	83 ec 2c             	sub    $0x2c,%esp
  800411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800414:	89 d6                	mov    %edx,%esi
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800422:	8b 45 10             	mov    0x10(%ebp),%eax
  800425:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800428:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80042e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800435:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800438:	72 0c                	jb     800446 <printnum+0x3e>
  80043a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80043d:	76 07                	jbe    800446 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80043f:	4b                   	dec    %ebx
  800440:	85 db                	test   %ebx,%ebx
  800442:	7f 31                	jg     800475 <printnum+0x6d>
  800444:	eb 3f                	jmp    800485 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800446:	83 ec 0c             	sub    $0xc,%esp
  800449:	57                   	push   %edi
  80044a:	4b                   	dec    %ebx
  80044b:	53                   	push   %ebx
  80044c:	50                   	push   %eax
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 d4             	pushl  -0x2c(%ebp)
  800453:	ff 75 d0             	pushl  -0x30(%ebp)
  800456:	ff 75 dc             	pushl  -0x24(%ebp)
  800459:	ff 75 d8             	pushl  -0x28(%ebp)
  80045c:	e8 b3 1d 00 00       	call   802214 <__udivdi3>
  800461:	83 c4 18             	add    $0x18,%esp
  800464:	52                   	push   %edx
  800465:	50                   	push   %eax
  800466:	89 f2                	mov    %esi,%edx
  800468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046b:	e8 98 ff ff ff       	call   800408 <printnum>
  800470:	83 c4 20             	add    $0x20,%esp
  800473:	eb 10                	jmp    800485 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	56                   	push   %esi
  800479:	57                   	push   %edi
  80047a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047d:	4b                   	dec    %ebx
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 db                	test   %ebx,%ebx
  800483:	7f f0                	jg     800475 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	56                   	push   %esi
  800489:	83 ec 04             	sub    $0x4,%esp
  80048c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80048f:	ff 75 d0             	pushl  -0x30(%ebp)
  800492:	ff 75 dc             	pushl  -0x24(%ebp)
  800495:	ff 75 d8             	pushl  -0x28(%ebp)
  800498:	e8 93 1e 00 00       	call   802330 <__umoddi3>
  80049d:	83 c4 14             	add    $0x14,%esp
  8004a0:	0f be 80 db 25 80 00 	movsbl 0x8025db(%eax),%eax
  8004a7:	50                   	push   %eax
  8004a8:	ff 55 e4             	call   *-0x1c(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
}
  8004ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b1:	5b                   	pop    %ebx
  8004b2:	5e                   	pop    %esi
  8004b3:	5f                   	pop    %edi
  8004b4:	c9                   	leave  
  8004b5:	c3                   	ret    

008004b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b9:	83 fa 01             	cmp    $0x1,%edx
  8004bc:	7e 0e                	jle    8004cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ca:	eb 22                	jmp    8004ee <getuint+0x38>
	else if (lflag)
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 10                	je     8004e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	eb 0e                	jmp    8004ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 02                	mov    (%edx),%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f3:	83 fa 01             	cmp    $0x1,%edx
  8004f6:	7e 0e                	jle    800506 <getint+0x16>
		return va_arg(*ap, long long);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	8b 52 04             	mov    0x4(%edx),%edx
  800504:	eb 1a                	jmp    800520 <getint+0x30>
	else if (lflag)
  800506:	85 d2                	test   %edx,%edx
  800508:	74 0c                	je     800516 <getint+0x26>
		return va_arg(*ap, long);
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050f:	89 08                	mov    %ecx,(%eax)
  800511:	8b 02                	mov    (%edx),%eax
  800513:	99                   	cltd   
  800514:	eb 0a                	jmp    800520 <getint+0x30>
	else
		return va_arg(*ap, int);
  800516:	8b 10                	mov    (%eax),%edx
  800518:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051b:	89 08                	mov    %ecx,(%eax)
  80051d:	8b 02                	mov    (%edx),%eax
  80051f:	99                   	cltd   
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800528:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80052b:	8b 10                	mov    (%eax),%edx
  80052d:	3b 50 04             	cmp    0x4(%eax),%edx
  800530:	73 08                	jae    80053a <sprintputch+0x18>
		*b->buf++ = ch;
  800532:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800535:	88 0a                	mov    %cl,(%edx)
  800537:	42                   	inc    %edx
  800538:	89 10                	mov    %edx,(%eax)
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800542:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800545:	50                   	push   %eax
  800546:	ff 75 10             	pushl  0x10(%ebp)
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	ff 75 08             	pushl  0x8(%ebp)
  80054f:	e8 05 00 00 00       	call   800559 <vprintfmt>
	va_end(ap);
  800554:	83 c4 10             	add    $0x10,%esp
}
  800557:	c9                   	leave  
  800558:	c3                   	ret    

00800559 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	57                   	push   %edi
  80055d:	56                   	push   %esi
  80055e:	53                   	push   %ebx
  80055f:	83 ec 2c             	sub    $0x2c,%esp
  800562:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800565:	8b 75 10             	mov    0x10(%ebp),%esi
  800568:	eb 13                	jmp    80057d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056a:	85 c0                	test   %eax,%eax
  80056c:	0f 84 6d 03 00 00    	je     8008df <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	57                   	push   %edi
  800576:	50                   	push   %eax
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057d:	0f b6 06             	movzbl (%esi),%eax
  800580:	46                   	inc    %esi
  800581:	83 f8 25             	cmp    $0x25,%eax
  800584:	75 e4                	jne    80056a <vprintfmt+0x11>
  800586:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80058a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800591:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800598:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80059f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a4:	eb 28                	jmp    8005ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8005ac:	eb 20                	jmp    8005ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005b4:	eb 18                	jmp    8005ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005bf:	eb 0d                	jmp    8005ce <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8a 06                	mov    (%esi),%al
  8005d0:	0f b6 d0             	movzbl %al,%edx
  8005d3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005d6:	83 e8 23             	sub    $0x23,%eax
  8005d9:	3c 55                	cmp    $0x55,%al
  8005db:	0f 87 e0 02 00 00    	ja     8008c1 <vprintfmt+0x368>
  8005e1:	0f b6 c0             	movzbl %al,%eax
  8005e4:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005eb:	83 ea 30             	sub    $0x30,%edx
  8005ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005f1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005f7:	83 fa 09             	cmp    $0x9,%edx
  8005fa:	77 44                	ja     800640 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	89 de                	mov    %ebx,%esi
  8005fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800601:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800602:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800605:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800609:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80060c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80060f:	83 fb 09             	cmp    $0x9,%ebx
  800612:	76 ed                	jbe    800601 <vprintfmt+0xa8>
  800614:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800617:	eb 29                	jmp    800642 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800629:	eb 17                	jmp    800642 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80062b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062f:	78 85                	js     8005b6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	89 de                	mov    %ebx,%esi
  800633:	eb 99                	jmp    8005ce <vprintfmt+0x75>
  800635:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800637:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80063e:	eb 8e                	jmp    8005ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800642:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800646:	79 86                	jns    8005ce <vprintfmt+0x75>
  800648:	e9 74 ff ff ff       	jmp    8005c1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80064d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	89 de                	mov    %ebx,%esi
  800650:	e9 79 ff ff ff       	jmp    8005ce <vprintfmt+0x75>
  800655:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	57                   	push   %edi
  800665:	ff 30                	pushl  (%eax)
  800667:	ff 55 08             	call   *0x8(%ebp)
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800670:	e9 08 ff ff ff       	jmp    80057d <vprintfmt+0x24>
  800675:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	85 c0                	test   %eax,%eax
  800685:	79 02                	jns    800689 <vprintfmt+0x130>
  800687:	f7 d8                	neg    %eax
  800689:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068b:	83 f8 0f             	cmp    $0xf,%eax
  80068e:	7f 0b                	jg     80069b <vprintfmt+0x142>
  800690:	8b 04 85 80 28 80 00 	mov    0x802880(,%eax,4),%eax
  800697:	85 c0                	test   %eax,%eax
  800699:	75 1a                	jne    8006b5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80069b:	52                   	push   %edx
  80069c:	68 f3 25 80 00       	push   $0x8025f3
  8006a1:	57                   	push   %edi
  8006a2:	ff 75 08             	pushl  0x8(%ebp)
  8006a5:	e8 92 fe ff ff       	call   80053c <printfmt>
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b0:	e9 c8 fe ff ff       	jmp    80057d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8006b5:	50                   	push   %eax
  8006b6:	68 35 2b 80 00       	push   $0x802b35
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 08             	pushl  0x8(%ebp)
  8006bf:	e8 78 fe ff ff       	call   80053c <printfmt>
  8006c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ca:	e9 ae fe ff ff       	jmp    80057d <vprintfmt+0x24>
  8006cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006d2:	89 de                	mov    %ebx,%esi
  8006d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 50 04             	lea    0x4(%eax),%edx
  8006e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	75 07                	jne    8006f3 <vprintfmt+0x19a>
				p = "(null)";
  8006ec:	c7 45 d0 ec 25 80 00 	movl   $0x8025ec,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006f3:	85 db                	test   %ebx,%ebx
  8006f5:	7e 42                	jle    800739 <vprintfmt+0x1e0>
  8006f7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006fb:	74 3c                	je     800739 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	51                   	push   %ecx
  800701:	ff 75 d0             	pushl  -0x30(%ebp)
  800704:	e8 6f 02 00 00       	call   800978 <strnlen>
  800709:	29 c3                	sub    %eax,%ebx
  80070b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	85 db                	test   %ebx,%ebx
  800713:	7e 24                	jle    800739 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800715:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800719:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80071c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	53                   	push   %ebx
  800724:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800727:	4e                   	dec    %esi
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 f6                	test   %esi,%esi
  80072d:	7f f0                	jg     80071f <vprintfmt+0x1c6>
  80072f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800732:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800739:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80073c:	0f be 02             	movsbl (%edx),%eax
  80073f:	85 c0                	test   %eax,%eax
  800741:	75 47                	jne    80078a <vprintfmt+0x231>
  800743:	eb 37                	jmp    80077c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800745:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800749:	74 16                	je     800761 <vprintfmt+0x208>
  80074b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80074e:	83 fa 5e             	cmp    $0x5e,%edx
  800751:	76 0e                	jbe    800761 <vprintfmt+0x208>
					putch('?', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	57                   	push   %edi
  800757:	6a 3f                	push   $0x3f
  800759:	ff 55 08             	call   *0x8(%ebp)
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb 0b                	jmp    80076c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	57                   	push   %edi
  800765:	50                   	push   %eax
  800766:	ff 55 08             	call   *0x8(%ebp)
  800769:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076c:	ff 4d e4             	decl   -0x1c(%ebp)
  80076f:	0f be 03             	movsbl (%ebx),%eax
  800772:	85 c0                	test   %eax,%eax
  800774:	74 03                	je     800779 <vprintfmt+0x220>
  800776:	43                   	inc    %ebx
  800777:	eb 1b                	jmp    800794 <vprintfmt+0x23b>
  800779:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800780:	7f 1e                	jg     8007a0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800785:	e9 f3 fd ff ff       	jmp    80057d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80078d:	43                   	inc    %ebx
  80078e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800791:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800794:	85 f6                	test   %esi,%esi
  800796:	78 ad                	js     800745 <vprintfmt+0x1ec>
  800798:	4e                   	dec    %esi
  800799:	79 aa                	jns    800745 <vprintfmt+0x1ec>
  80079b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80079e:	eb dc                	jmp    80077c <vprintfmt+0x223>
  8007a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	57                   	push   %edi
  8007a7:	6a 20                	push   $0x20
  8007a9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ac:	4b                   	dec    %ebx
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 db                	test   %ebx,%ebx
  8007b2:	7f ef                	jg     8007a3 <vprintfmt+0x24a>
  8007b4:	e9 c4 fd ff ff       	jmp    80057d <vprintfmt+0x24>
  8007b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007bc:	89 ca                	mov    %ecx,%edx
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	e8 2a fd ff ff       	call   8004f0 <getint>
  8007c6:	89 c3                	mov    %eax,%ebx
  8007c8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	78 0a                	js     8007d8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d3:	e9 b0 00 00 00       	jmp    800888 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	57                   	push   %edi
  8007dc:	6a 2d                	push   $0x2d
  8007de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007e1:	f7 db                	neg    %ebx
  8007e3:	83 d6 00             	adc    $0x0,%esi
  8007e6:	f7 de                	neg    %esi
  8007e8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f0:	e9 93 00 00 00       	jmp    800888 <vprintfmt+0x32f>
  8007f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f8:	89 ca                	mov    %ecx,%edx
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fd:	e8 b4 fc ff ff       	call   8004b6 <getuint>
  800802:	89 c3                	mov    %eax,%ebx
  800804:	89 d6                	mov    %edx,%esi
			base = 10;
  800806:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80080b:	eb 7b                	jmp    800888 <vprintfmt+0x32f>
  80080d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800810:	89 ca                	mov    %ecx,%edx
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
  800815:	e8 d6 fc ff ff       	call   8004f0 <getint>
  80081a:	89 c3                	mov    %eax,%ebx
  80081c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80081e:	85 d2                	test   %edx,%edx
  800820:	78 07                	js     800829 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800822:	b8 08 00 00 00       	mov    $0x8,%eax
  800827:	eb 5f                	jmp    800888 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	57                   	push   %edi
  80082d:	6a 2d                	push   $0x2d
  80082f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800832:	f7 db                	neg    %ebx
  800834:	83 d6 00             	adc    $0x0,%esi
  800837:	f7 de                	neg    %esi
  800839:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80083c:	b8 08 00 00 00       	mov    $0x8,%eax
  800841:	eb 45                	jmp    800888 <vprintfmt+0x32f>
  800843:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	57                   	push   %edi
  80084a:	6a 30                	push   $0x30
  80084c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	57                   	push   %edi
  800853:	6a 78                	push   $0x78
  800855:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800861:	8b 18                	mov    (%eax),%ebx
  800863:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800868:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800870:	eb 16                	jmp    800888 <vprintfmt+0x32f>
  800872:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800875:	89 ca                	mov    %ecx,%edx
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
  80087a:	e8 37 fc ff ff       	call   8004b6 <getuint>
  80087f:	89 c3                	mov    %eax,%ebx
  800881:	89 d6                	mov    %edx,%esi
			base = 16;
  800883:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80088f:	52                   	push   %edx
  800890:	ff 75 e4             	pushl  -0x1c(%ebp)
  800893:	50                   	push   %eax
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	89 fa                	mov    %edi,%edx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	e8 68 fb ff ff       	call   800408 <printnum>
			break;
  8008a0:	83 c4 20             	add    $0x20,%esp
  8008a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008a6:	e9 d2 fc ff ff       	jmp    80057d <vprintfmt+0x24>
  8008ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	57                   	push   %edi
  8008b2:	52                   	push   %edx
  8008b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008bc:	e9 bc fc ff ff       	jmp    80057d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	57                   	push   %edi
  8008c5:	6a 25                	push   $0x25
  8008c7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	eb 02                	jmp    8008d1 <vprintfmt+0x378>
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008d4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008d8:	75 f5                	jne    8008cf <vprintfmt+0x376>
  8008da:	e9 9e fc ff ff       	jmp    80057d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 18             	sub    $0x18,%esp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800904:	85 c0                	test   %eax,%eax
  800906:	74 26                	je     80092e <vsnprintf+0x47>
  800908:	85 d2                	test   %edx,%edx
  80090a:	7e 29                	jle    800935 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090c:	ff 75 14             	pushl  0x14(%ebp)
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800915:	50                   	push   %eax
  800916:	68 22 05 80 00       	push   $0x800522
  80091b:	e8 39 fc ff ff       	call   800559 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800920:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800923:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	eb 0c                	jmp    80093a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80092e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800933:	eb 05                	jmp    80093a <vsnprintf+0x53>
  800935:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800945:	50                   	push   %eax
  800946:	ff 75 10             	pushl  0x10(%ebp)
  800949:	ff 75 0c             	pushl  0xc(%ebp)
  80094c:	ff 75 08             	pushl  0x8(%ebp)
  80094f:	e8 93 ff ff ff       	call   8008e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    
	...

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095e:	80 3a 00             	cmpb   $0x0,(%edx)
  800961:	74 0e                	je     800971 <strlen+0x19>
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800968:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800969:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096d:	75 f9                	jne    800968 <strlen+0x10>
  80096f:	eb 05                	jmp    800976 <strlen+0x1e>
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800981:	85 d2                	test   %edx,%edx
  800983:	74 17                	je     80099c <strnlen+0x24>
  800985:	80 39 00             	cmpb   $0x0,(%ecx)
  800988:	74 19                	je     8009a3 <strnlen+0x2b>
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80098f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800990:	39 d0                	cmp    %edx,%eax
  800992:	74 14                	je     8009a8 <strnlen+0x30>
  800994:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800998:	75 f5                	jne    80098f <strnlen+0x17>
  80099a:	eb 0c                	jmp    8009a8 <strnlen+0x30>
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 05                	jmp    8009a8 <strnlen+0x30>
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009bc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009bf:	42                   	inc    %edx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	75 f5                	jne    8009b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ce:	53                   	push   %ebx
  8009cf:	e8 84 ff ff ff       	call   800958 <strlen>
  8009d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009dd:	50                   	push   %eax
  8009de:	e8 c7 ff ff ff       	call   8009aa <strcpy>
	return dst;
}
  8009e3:	89 d8                	mov    %ebx,%eax
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f8:	85 f6                	test   %esi,%esi
  8009fa:	74 15                	je     800a11 <strncpy+0x27>
  8009fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a01:	8a 1a                	mov    (%edx),%bl
  800a03:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a06:	80 3a 01             	cmpb   $0x1,(%edx)
  800a09:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0c:	41                   	inc    %ecx
  800a0d:	39 ce                	cmp    %ecx,%esi
  800a0f:	77 f0                	ja     800a01 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a21:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a24:	85 f6                	test   %esi,%esi
  800a26:	74 32                	je     800a5a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a28:	83 fe 01             	cmp    $0x1,%esi
  800a2b:	74 22                	je     800a4f <strlcpy+0x3a>
  800a2d:	8a 0b                	mov    (%ebx),%cl
  800a2f:	84 c9                	test   %cl,%cl
  800a31:	74 20                	je     800a53 <strlcpy+0x3e>
  800a33:	89 f8                	mov    %edi,%eax
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a3a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	88 08                	mov    %cl,(%eax)
  800a3f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a40:	39 f2                	cmp    %esi,%edx
  800a42:	74 11                	je     800a55 <strlcpy+0x40>
  800a44:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a48:	42                   	inc    %edx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 f0                	jne    800a3d <strlcpy+0x28>
  800a4d:	eb 06                	jmp    800a55 <strlcpy+0x40>
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	eb 02                	jmp    800a55 <strlcpy+0x40>
  800a53:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a55:	c6 00 00             	movb   $0x0,(%eax)
  800a58:	eb 02                	jmp    800a5c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a5c:	29 f8                	sub    %edi,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6c:	8a 01                	mov    (%ecx),%al
  800a6e:	84 c0                	test   %al,%al
  800a70:	74 10                	je     800a82 <strcmp+0x1f>
  800a72:	3a 02                	cmp    (%edx),%al
  800a74:	75 0c                	jne    800a82 <strcmp+0x1f>
		p++, q++;
  800a76:	41                   	inc    %ecx
  800a77:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a78:	8a 01                	mov    (%ecx),%al
  800a7a:	84 c0                	test   %al,%al
  800a7c:	74 04                	je     800a82 <strcmp+0x1f>
  800a7e:	3a 02                	cmp    (%edx),%al
  800a80:	74 f4                	je     800a76 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a82:	0f b6 c0             	movzbl %al,%eax
  800a85:	0f b6 12             	movzbl (%edx),%edx
  800a88:	29 d0                	sub    %edx,%eax
}
  800a8a:	c9                   	leave  
  800a8b:	c3                   	ret    

00800a8c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	53                   	push   %ebx
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	74 1b                	je     800ab8 <strncmp+0x2c>
  800a9d:	8a 1a                	mov    (%edx),%bl
  800a9f:	84 db                	test   %bl,%bl
  800aa1:	74 24                	je     800ac7 <strncmp+0x3b>
  800aa3:	3a 19                	cmp    (%ecx),%bl
  800aa5:	75 20                	jne    800ac7 <strncmp+0x3b>
  800aa7:	48                   	dec    %eax
  800aa8:	74 15                	je     800abf <strncmp+0x33>
		n--, p++, q++;
  800aaa:	42                   	inc    %edx
  800aab:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aac:	8a 1a                	mov    (%edx),%bl
  800aae:	84 db                	test   %bl,%bl
  800ab0:	74 15                	je     800ac7 <strncmp+0x3b>
  800ab2:	3a 19                	cmp    (%ecx),%bl
  800ab4:	74 f1                	je     800aa7 <strncmp+0x1b>
  800ab6:	eb 0f                	jmp    800ac7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	eb 05                	jmp    800ac4 <strncmp+0x38>
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 02             	movzbl (%edx),%eax
  800aca:	0f b6 11             	movzbl (%ecx),%edx
  800acd:	29 d0                	sub    %edx,%eax
  800acf:	eb f3                	jmp    800ac4 <strncmp+0x38>

00800ad1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ada:	8a 10                	mov    (%eax),%dl
  800adc:	84 d2                	test   %dl,%dl
  800ade:	74 18                	je     800af8 <strchr+0x27>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	75 06                	jne    800aea <strchr+0x19>
  800ae4:	eb 17                	jmp    800afd <strchr+0x2c>
  800ae6:	38 ca                	cmp    %cl,%dl
  800ae8:	74 13                	je     800afd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aea:	40                   	inc    %eax
  800aeb:	8a 10                	mov    (%eax),%dl
  800aed:	84 d2                	test   %dl,%dl
  800aef:	75 f5                	jne    800ae6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	eb 05                	jmp    800afd <strchr+0x2c>
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b08:	8a 10                	mov    (%eax),%dl
  800b0a:	84 d2                	test   %dl,%dl
  800b0c:	74 11                	je     800b1f <strfind+0x20>
		if (*s == c)
  800b0e:	38 ca                	cmp    %cl,%dl
  800b10:	75 06                	jne    800b18 <strfind+0x19>
  800b12:	eb 0b                	jmp    800b1f <strfind+0x20>
  800b14:	38 ca                	cmp    %cl,%dl
  800b16:	74 07                	je     800b1f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b18:	40                   	inc    %eax
  800b19:	8a 10                	mov    (%eax),%dl
  800b1b:	84 d2                	test   %dl,%dl
  800b1d:	75 f5                	jne    800b14 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b30:	85 c9                	test   %ecx,%ecx
  800b32:	74 30                	je     800b64 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3a:	75 25                	jne    800b61 <memset+0x40>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 20                	jne    800b61 <memset+0x40>
		c &= 0xFF;
  800b41:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	c1 e3 08             	shl    $0x8,%ebx
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	c1 e6 18             	shl    $0x18,%esi
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	c1 e0 10             	shl    $0x10,%eax
  800b53:	09 f0                	or     %esi,%eax
  800b55:	09 d0                	or     %edx,%eax
  800b57:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b59:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b5c:	fc                   	cld    
  800b5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5f:	eb 03                	jmp    800b64 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b61:	fc                   	cld    
  800b62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b64:	89 f8                	mov    %edi,%eax
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b79:	39 c6                	cmp    %eax,%esi
  800b7b:	73 34                	jae    800bb1 <memmove+0x46>
  800b7d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b80:	39 d0                	cmp    %edx,%eax
  800b82:	73 2d                	jae    800bb1 <memmove+0x46>
		s += n;
		d += n;
  800b84:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b87:	f6 c2 03             	test   $0x3,%dl
  800b8a:	75 1b                	jne    800ba7 <memmove+0x3c>
  800b8c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b92:	75 13                	jne    800ba7 <memmove+0x3c>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 0e                	jne    800ba7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b99:	83 ef 04             	sub    $0x4,%edi
  800b9c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba2:	fd                   	std    
  800ba3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba5:	eb 07                	jmp    800bae <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ba7:	4f                   	dec    %edi
  800ba8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bab:	fd                   	std    
  800bac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bae:	fc                   	cld    
  800baf:	eb 20                	jmp    800bd1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb7:	75 13                	jne    800bcc <memmove+0x61>
  800bb9:	a8 03                	test   $0x3,%al
  800bbb:	75 0f                	jne    800bcc <memmove+0x61>
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 0a                	jne    800bcc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc5:	89 c7                	mov    %eax,%edi
  800bc7:	fc                   	cld    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb 05                	jmp    800bd1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd8:	ff 75 10             	pushl  0x10(%ebp)
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	ff 75 08             	pushl  0x8(%ebp)
  800be1:	e8 85 ff ff ff       	call   800b6b <memmove>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	85 ff                	test   %edi,%edi
  800bf9:	74 32                	je     800c2d <memcmp+0x45>
		if (*s1 != *s2)
  800bfb:	8a 03                	mov    (%ebx),%al
  800bfd:	8a 0e                	mov    (%esi),%cl
  800bff:	38 c8                	cmp    %cl,%al
  800c01:	74 19                	je     800c1c <memcmp+0x34>
  800c03:	eb 0d                	jmp    800c12 <memcmp+0x2a>
  800c05:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800c09:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800c0d:	42                   	inc    %edx
  800c0e:	38 c8                	cmp    %cl,%al
  800c10:	74 10                	je     800c22 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800c12:	0f b6 c0             	movzbl %al,%eax
  800c15:	0f b6 c9             	movzbl %cl,%ecx
  800c18:	29 c8                	sub    %ecx,%eax
  800c1a:	eb 16                	jmp    800c32 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1c:	4f                   	dec    %edi
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	39 fa                	cmp    %edi,%edx
  800c24:	75 df                	jne    800c05 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	eb 05                	jmp    800c32 <memcmp+0x4a>
  800c2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c42:	39 d0                	cmp    %edx,%eax
  800c44:	73 12                	jae    800c58 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c46:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c49:	38 08                	cmp    %cl,(%eax)
  800c4b:	75 06                	jne    800c53 <memfind+0x1c>
  800c4d:	eb 09                	jmp    800c58 <memfind+0x21>
  800c4f:	38 08                	cmp    %cl,(%eax)
  800c51:	74 05                	je     800c58 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c53:	40                   	inc    %eax
  800c54:	39 c2                	cmp    %eax,%edx
  800c56:	77 f7                	ja     800c4f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c66:	eb 01                	jmp    800c69 <strtol+0xf>
		s++;
  800c68:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	8a 02                	mov    (%edx),%al
  800c6b:	3c 20                	cmp    $0x20,%al
  800c6d:	74 f9                	je     800c68 <strtol+0xe>
  800c6f:	3c 09                	cmp    $0x9,%al
  800c71:	74 f5                	je     800c68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c73:	3c 2b                	cmp    $0x2b,%al
  800c75:	75 08                	jne    800c7f <strtol+0x25>
		s++;
  800c77:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 13                	jmp    800c92 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c7f:	3c 2d                	cmp    $0x2d,%al
  800c81:	75 0a                	jne    800c8d <strtol+0x33>
		s++, neg = 1;
  800c83:	8d 52 01             	lea    0x1(%edx),%edx
  800c86:	bf 01 00 00 00       	mov    $0x1,%edi
  800c8b:	eb 05                	jmp    800c92 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c92:	85 db                	test   %ebx,%ebx
  800c94:	74 05                	je     800c9b <strtol+0x41>
  800c96:	83 fb 10             	cmp    $0x10,%ebx
  800c99:	75 28                	jne    800cc3 <strtol+0x69>
  800c9b:	8a 02                	mov    (%edx),%al
  800c9d:	3c 30                	cmp    $0x30,%al
  800c9f:	75 10                	jne    800cb1 <strtol+0x57>
  800ca1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca5:	75 0a                	jne    800cb1 <strtol+0x57>
		s += 2, base = 16;
  800ca7:	83 c2 02             	add    $0x2,%edx
  800caa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800caf:	eb 12                	jmp    800cc3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cb1:	85 db                	test   %ebx,%ebx
  800cb3:	75 0e                	jne    800cc3 <strtol+0x69>
  800cb5:	3c 30                	cmp    $0x30,%al
  800cb7:	75 05                	jne    800cbe <strtol+0x64>
		s++, base = 8;
  800cb9:	42                   	inc    %edx
  800cba:	b3 08                	mov    $0x8,%bl
  800cbc:	eb 05                	jmp    800cc3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cbe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cca:	8a 0a                	mov    (%edx),%cl
  800ccc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ccf:	80 fb 09             	cmp    $0x9,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0x82>
			dig = *s - '0';
  800cd4:	0f be c9             	movsbl %cl,%ecx
  800cd7:	83 e9 30             	sub    $0x30,%ecx
  800cda:	eb 1e                	jmp    800cfa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cdc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cdf:	80 fb 19             	cmp    $0x19,%bl
  800ce2:	77 08                	ja     800cec <strtol+0x92>
			dig = *s - 'a' + 10;
  800ce4:	0f be c9             	movsbl %cl,%ecx
  800ce7:	83 e9 57             	sub    $0x57,%ecx
  800cea:	eb 0e                	jmp    800cfa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cec:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cef:	80 fb 19             	cmp    $0x19,%bl
  800cf2:	77 13                	ja     800d07 <strtol+0xad>
			dig = *s - 'A' + 10;
  800cf4:	0f be c9             	movsbl %cl,%ecx
  800cf7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cfa:	39 f1                	cmp    %esi,%ecx
  800cfc:	7d 0d                	jge    800d0b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800cfe:	42                   	inc    %edx
  800cff:	0f af c6             	imul   %esi,%eax
  800d02:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d05:	eb c3                	jmp    800cca <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d07:	89 c1                	mov    %eax,%ecx
  800d09:	eb 02                	jmp    800d0d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d0b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d11:	74 05                	je     800d18 <strtol+0xbe>
		*endptr = (char *) s;
  800d13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d16:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d18:	85 ff                	test   %edi,%edi
  800d1a:	74 04                	je     800d20 <strtol+0xc6>
  800d1c:	89 c8                	mov    %ecx,%eax
  800d1e:	f7 d8                	neg    %eax
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    
  800d25:	00 00                	add    %al,(%eax)
	...

00800d28 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 1c             	sub    $0x1c,%esp
  800d31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d34:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d37:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	8b 75 14             	mov    0x14(%ebp),%esi
  800d3c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d45:	cd 30                	int    $0x30
  800d47:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d4d:	74 1c                	je     800d6b <syscall+0x43>
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 18                	jle    800d6b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d5a:	68 df 28 80 00       	push   $0x8028df
  800d5f:	6a 42                	push   $0x42
  800d61:	68 fc 28 80 00       	push   $0x8028fc
  800d66:	e8 b1 f5 ff ff       	call   80031c <_panic>

	return ret;
}
  800d6b:	89 d0                	mov    %edx,%eax
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d7b:	6a 00                	push   $0x0
  800d7d:	6a 00                	push   $0x0
  800d7f:	6a 00                	push   $0x0
  800d81:	ff 75 0c             	pushl  0xc(%ebp)
  800d84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d91:	e8 92 ff ff ff       	call   800d28 <syscall>
  800d96:	83 c4 10             	add    $0x10,%esp
	return;
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800da1:	6a 00                	push   $0x0
  800da3:	6a 00                	push   $0x0
  800da5:	6a 00                	push   $0x0
  800da7:	6a 00                	push   $0x0
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
  800db3:	b8 01 00 00 00       	mov    $0x1,%eax
  800db8:	e8 6b ff ff ff       	call   800d28 <syscall>
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800dda:	e8 49 ff ff ff       	call   800d28 <syscall>
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800de7:	6a 00                	push   $0x0
  800de9:	6a 00                	push   $0x0
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
  800df9:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfe:	e8 25 ff ff ff       	call   800d28 <syscall>
}
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    

00800e05 <sys_yield>:

void
sys_yield(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e0b:	6a 00                	push   $0x0
  800e0d:	6a 00                	push   $0x0
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e18:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e22:	e8 01 ff ff ff       	call   800d28 <syscall>
  800e27:	83 c4 10             	add    $0x10,%esp
}
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e32:	6a 00                	push   $0x0
  800e34:	6a 00                	push   $0x0
  800e36:	ff 75 10             	pushl  0x10(%ebp)
  800e39:	ff 75 0c             	pushl  0xc(%ebp)
  800e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3f:	ba 01 00 00 00       	mov    $0x1,%edx
  800e44:	b8 04 00 00 00       	mov    $0x4,%eax
  800e49:	e8 da fe ff ff       	call   800d28 <syscall>
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e56:	ff 75 18             	pushl  0x18(%ebp)
  800e59:	ff 75 14             	pushl  0x14(%ebp)
  800e5c:	ff 75 10             	pushl  0x10(%ebp)
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e65:	ba 01 00 00 00       	mov    $0x1,%edx
  800e6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6f:	e8 b4 fe ff ff       	call   800d28 <syscall>
}
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    

00800e76 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e7c:	6a 00                	push   $0x0
  800e7e:	6a 00                	push   $0x0
  800e80:	6a 00                	push   $0x0
  800e82:	ff 75 0c             	pushl  0xc(%ebp)
  800e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e88:	ba 01 00 00 00       	mov    $0x1,%edx
  800e8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e92:	e8 91 fe ff ff       	call   800d28 <syscall>
}
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e9f:	6a 00                	push   $0x0
  800ea1:	6a 00                	push   $0x0
  800ea3:	6a 00                	push   $0x0
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb5:	e8 6e fe ff ff       	call   800d28 <syscall>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ec2:	6a 00                	push   $0x0
  800ec4:	6a 00                	push   $0x0
  800ec6:	6a 00                	push   $0x0
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ece:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed8:	e8 4b fe ff ff       	call   800d28 <syscall>
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ee5:	6a 00                	push   $0x0
  800ee7:	6a 00                	push   $0x0
  800ee9:	6a 00                	push   $0x0
  800eeb:	ff 75 0c             	pushl  0xc(%ebp)
  800eee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efb:	e8 28 fe ff ff       	call   800d28 <syscall>
}
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f08:	6a 00                	push   $0x0
  800f0a:	ff 75 14             	pushl  0x14(%ebp)
  800f0d:	ff 75 10             	pushl  0x10(%ebp)
  800f10:	ff 75 0c             	pushl  0xc(%ebp)
  800f13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f16:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f20:	e8 03 fe ff ff       	call   800d28 <syscall>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f2d:	6a 00                	push   $0x0
  800f2f:	6a 00                	push   $0x0
  800f31:	6a 00                	push   $0x0
  800f33:	6a 00                	push   $0x0
  800f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f38:	ba 01 00 00 00       	mov    $0x1,%edx
  800f3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f42:	e8 e1 fd ff ff       	call   800d28 <syscall>
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800f4f:	6a 00                	push   $0x0
  800f51:	6a 00                	push   $0x0
  800f53:	6a 00                	push   $0x0
  800f55:	ff 75 0c             	pushl  0xc(%ebp)
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f60:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f65:	e8 be fd ff ff       	call   800d28 <syscall>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800f72:	6a 00                	push   $0x0
  800f74:	ff 75 14             	pushl  0x14(%ebp)
  800f77:	ff 75 10             	pushl  0x10(%ebp)
  800f7a:	ff 75 0c             	pushl  0xc(%ebp)
  800f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f80:	ba 00 00 00 00       	mov    $0x0,%edx
  800f85:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f8a:	e8 99 fd ff ff       	call   800d28 <syscall>
} 
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    

00800f91 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800f97:	6a 00                	push   $0x0
  800f99:	6a 00                	push   $0x0
  800f9b:	6a 00                	push   $0x0
  800f9d:	6a 00                	push   $0x0
  800f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa7:	b8 11 00 00 00       	mov    $0x11,%eax
  800fac:	e8 77 fd ff ff       	call   800d28 <syscall>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800fb9:	6a 00                	push   $0x0
  800fbb:	6a 00                	push   $0x0
  800fbd:	6a 00                	push   $0x0
  800fbf:	6a 00                	push   $0x0
  800fc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcb:	b8 10 00 00 00       	mov    $0x10,%eax
  800fd0:	e8 53 fd ff ff       	call   800d28 <syscall>
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    
	...

00800fd8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fe2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800fe4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fe8:	75 14                	jne    800ffe <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 0c 29 80 00       	push   $0x80290c
  800ff2:	6a 20                	push   $0x20
  800ff4:	68 50 2a 80 00       	push   $0x802a50
  800ff9:	e8 1e f3 ff ff       	call   80031c <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ffe:	89 d8                	mov    %ebx,%eax
  801000:	c1 e8 16             	shr    $0x16,%eax
  801003:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100a:	a8 01                	test   $0x1,%al
  80100c:	74 11                	je     80101f <pgfault+0x47>
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	c1 e8 0c             	shr    $0xc,%eax
  801013:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101a:	f6 c4 08             	test   $0x8,%ah
  80101d:	75 14                	jne    801033 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	68 30 29 80 00       	push   $0x802930
  801027:	6a 24                	push   $0x24
  801029:	68 50 2a 80 00       	push   $0x802a50
  80102e:	e8 e9 f2 ff ff       	call   80031c <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	6a 07                	push   $0x7
  801038:	68 00 f0 7f 00       	push   $0x7ff000
  80103d:	6a 00                	push   $0x0
  80103f:	e8 e8 fd ff ff       	call   800e2c <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 12                	jns    80105d <pgfault+0x85>
  80104b:	50                   	push   %eax
  80104c:	68 54 29 80 00       	push   $0x802954
  801051:	6a 32                	push   $0x32
  801053:	68 50 2a 80 00       	push   $0x802a50
  801058:	e8 bf f2 ff ff       	call   80031c <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  80105d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 00 10 00 00       	push   $0x1000
  80106b:	53                   	push   %ebx
  80106c:	68 00 f0 7f 00       	push   $0x7ff000
  801071:	e8 5f fb ff ff       	call   800bd5 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  801076:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80107d:	53                   	push   %ebx
  80107e:	6a 00                	push   $0x0
  801080:	68 00 f0 7f 00       	push   $0x7ff000
  801085:	6a 00                	push   $0x0
  801087:	e8 c4 fd ff ff       	call   800e50 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  80108c:	83 c4 20             	add    $0x20,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 12                	jns    8010a5 <pgfault+0xcd>
  801093:	50                   	push   %eax
  801094:	68 78 29 80 00       	push   $0x802978
  801099:	6a 3a                	push   $0x3a
  80109b:	68 50 2a 80 00       	push   $0x802a50
  8010a0:	e8 77 f2 ff ff       	call   80031c <_panic>

	return;
}
  8010a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010b3:	68 d8 0f 80 00       	push   $0x800fd8
  8010b8:	e8 67 0f 00 00       	call   802024 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010bd:	ba 07 00 00 00       	mov    $0x7,%edx
  8010c2:	89 d0                	mov    %edx,%eax
  8010c4:	cd 30                	int    $0x30
  8010c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c9:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	79 12                	jns    8010e4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  8010d2:	50                   	push   %eax
  8010d3:	68 5b 2a 80 00       	push   $0x802a5b
  8010d8:	6a 7f                	push   $0x7f
  8010da:	68 50 2a 80 00       	push   $0x802a50
  8010df:	e8 38 f2 ff ff       	call   80031c <_panic>
	}
	int r;

	if (childpid == 0) {
  8010e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010e8:	75 20                	jne    80110a <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  8010ea:	e8 f2 fc ff ff       	call   800de1 <sys_getenvid>
  8010ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	c1 e2 07             	shl    $0x7,%edx
  8010f9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801100:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  801105:	e9 be 01 00 00       	jmp    8012c8 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  80110a:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	c1 e8 16             	shr    $0x16,%eax
  801114:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111b:	a8 01                	test   $0x1,%al
  80111d:	0f 84 10 01 00 00    	je     801233 <fork+0x189>
  801123:	89 d8                	mov    %ebx,%eax
  801125:	c1 e8 0c             	shr    $0xc,%eax
  801128:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	0f 84 fb 00 00 00    	je     801233 <fork+0x189>
  801138:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113f:	f6 c2 04             	test   $0x4,%dl
  801142:	0f 84 eb 00 00 00    	je     801233 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801148:	89 c6                	mov    %eax,%esi
  80114a:	c1 e6 0c             	shl    $0xc,%esi
  80114d:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801153:	0f 84 da 00 00 00    	je     801233 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801159:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801160:	f6 c6 04             	test   $0x4,%dh
  801163:	74 37                	je     80119c <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801165:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	25 07 0e 00 00       	and    $0xe07,%eax
  801174:	50                   	push   %eax
  801175:	56                   	push   %esi
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	6a 00                	push   $0x0
  80117a:	e8 d1 fc ff ff       	call   800e50 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80117f:	83 c4 20             	add    $0x20,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	0f 89 a9 00 00 00    	jns    801233 <fork+0x189>
  80118a:	50                   	push   %eax
  80118b:	68 9c 29 80 00       	push   $0x80299c
  801190:	6a 54                	push   $0x54
  801192:	68 50 2a 80 00       	push   $0x802a50
  801197:	e8 80 f1 ff ff       	call   80031c <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80119c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011a3:	f6 c2 02             	test   $0x2,%dl
  8011a6:	75 0c                	jne    8011b4 <fork+0x10a>
  8011a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011af:	f6 c4 08             	test   $0x8,%ah
  8011b2:	74 57                	je     80120b <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	68 05 08 00 00       	push   $0x805
  8011bc:	56                   	push   %esi
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	6a 00                	push   $0x0
  8011c1:	e8 8a fc ff ff       	call   800e50 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8011c6:	83 c4 20             	add    $0x20,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	79 12                	jns    8011df <fork+0x135>
  8011cd:	50                   	push   %eax
  8011ce:	68 9c 29 80 00       	push   $0x80299c
  8011d3:	6a 59                	push   $0x59
  8011d5:	68 50 2a 80 00       	push   $0x802a50
  8011da:	e8 3d f1 ff ff       	call   80031c <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8011df:	83 ec 0c             	sub    $0xc,%esp
  8011e2:	68 05 08 00 00       	push   $0x805
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	56                   	push   %esi
  8011eb:	6a 00                	push   $0x0
  8011ed:	e8 5e fc ff ff       	call   800e50 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8011f2:	83 c4 20             	add    $0x20,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	79 3a                	jns    801233 <fork+0x189>
  8011f9:	50                   	push   %eax
  8011fa:	68 9c 29 80 00       	push   $0x80299c
  8011ff:	6a 5c                	push   $0x5c
  801201:	68 50 2a 80 00       	push   $0x802a50
  801206:	e8 11 f1 ff ff       	call   80031c <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80120b:	83 ec 0c             	sub    $0xc,%esp
  80120e:	6a 05                	push   $0x5
  801210:	56                   	push   %esi
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	6a 00                	push   $0x0
  801215:	e8 36 fc ff ff       	call   800e50 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80121a:	83 c4 20             	add    $0x20,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 12                	jns    801233 <fork+0x189>
  801221:	50                   	push   %eax
  801222:	68 9c 29 80 00       	push   $0x80299c
  801227:	6a 60                	push   $0x60
  801229:	68 50 2a 80 00       	push   $0x802a50
  80122e:	e8 e9 f0 ff ff       	call   80031c <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801233:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801239:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80123f:	0f 85 ca fe ff ff    	jne    80110f <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801245:	83 ec 04             	sub    $0x4,%esp
  801248:	6a 07                	push   $0x7
  80124a:	68 00 f0 bf ee       	push   $0xeebff000
  80124f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801252:	e8 d5 fb ff ff       	call   800e2c <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	79 15                	jns    801273 <fork+0x1c9>
  80125e:	50                   	push   %eax
  80125f:	68 c0 29 80 00       	push   $0x8029c0
  801264:	68 94 00 00 00       	push   $0x94
  801269:	68 50 2a 80 00       	push   $0x802a50
  80126e:	e8 a9 f0 ff ff       	call   80031c <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	68 90 20 80 00       	push   $0x802090
  80127b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127e:	e8 5c fc ff ff       	call   800edf <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	79 15                	jns    80129f <fork+0x1f5>
  80128a:	50                   	push   %eax
  80128b:	68 f8 29 80 00       	push   $0x8029f8
  801290:	68 99 00 00 00       	push   $0x99
  801295:	68 50 2a 80 00       	push   $0x802a50
  80129a:	e8 7d f0 ff ff       	call   80031c <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	6a 02                	push   $0x2
  8012a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a7:	e8 ed fb ff ff       	call   800e99 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	79 15                	jns    8012c8 <fork+0x21e>
  8012b3:	50                   	push   %eax
  8012b4:	68 1c 2a 80 00       	push   $0x802a1c
  8012b9:	68 a4 00 00 00       	push   $0xa4
  8012be:	68 50 2a 80 00       	push   $0x802a50
  8012c3:	e8 54 f0 ff ff       	call   80031c <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8012c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <sfork>:

// Challenge!
int
sfork(void)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012d9:	68 78 2a 80 00       	push   $0x802a78
  8012de:	68 b1 00 00 00       	push   $0xb1
  8012e3:	68 50 2a 80 00       	push   $0x802a50
  8012e8:	e8 2f f0 ff ff       	call   80031c <_panic>
  8012ed:	00 00                	add    %al,(%eax)
	...

008012f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801303:	ff 75 08             	pushl  0x8(%ebp)
  801306:	e8 e5 ff ff ff       	call   8012f0 <fd2num>
  80130b:	83 c4 04             	add    $0x4,%esp
  80130e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801313:	c1 e0 0c             	shl    $0xc,%eax
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80131f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801324:	a8 01                	test   $0x1,%al
  801326:	74 34                	je     80135c <fd_alloc+0x44>
  801328:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80132d:	a8 01                	test   $0x1,%al
  80132f:	74 32                	je     801363 <fd_alloc+0x4b>
  801331:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801336:	89 c1                	mov    %eax,%ecx
  801338:	89 c2                	mov    %eax,%edx
  80133a:	c1 ea 16             	shr    $0x16,%edx
  80133d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801344:	f6 c2 01             	test   $0x1,%dl
  801347:	74 1f                	je     801368 <fd_alloc+0x50>
  801349:	89 c2                	mov    %eax,%edx
  80134b:	c1 ea 0c             	shr    $0xc,%edx
  80134e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801355:	f6 c2 01             	test   $0x1,%dl
  801358:	75 17                	jne    801371 <fd_alloc+0x59>
  80135a:	eb 0c                	jmp    801368 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80135c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801361:	eb 05                	jmp    801368 <fd_alloc+0x50>
  801363:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801368:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
  80136f:	eb 17                	jmp    801388 <fd_alloc+0x70>
  801371:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801376:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137b:	75 b9                	jne    801336 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801383:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801388:	5b                   	pop    %ebx
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801391:	83 f8 1f             	cmp    $0x1f,%eax
  801394:	77 36                	ja     8013cc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801396:	05 00 00 0d 00       	add    $0xd0000,%eax
  80139b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	c1 ea 16             	shr    $0x16,%edx
  8013a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	74 24                	je     8013d3 <fd_lookup+0x48>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	c1 ea 0c             	shr    $0xc,%edx
  8013b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bb:	f6 c2 01             	test   $0x1,%dl
  8013be:	74 1a                	je     8013da <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	eb 13                	jmp    8013df <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb 0c                	jmp    8013df <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 05                	jmp    8013df <fd_lookup+0x54>
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013df:	c9                   	leave  
  8013e0:	c3                   	ret    

008013e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013ee:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8013f4:	74 0d                	je     801403 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	eb 14                	jmp    801411 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8013fd:	39 0a                	cmp    %ecx,(%edx)
  8013ff:	75 10                	jne    801411 <dev_lookup+0x30>
  801401:	eb 05                	jmp    801408 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801403:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801408:	89 13                	mov    %edx,(%ebx)
			return 0;
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
  80140f:	eb 31                	jmp    801442 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801411:	40                   	inc    %eax
  801412:	8b 14 85 0c 2b 80 00 	mov    0x802b0c(,%eax,4),%edx
  801419:	85 d2                	test   %edx,%edx
  80141b:	75 e0                	jne    8013fd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80141d:	a1 04 40 80 00       	mov    0x804004,%eax
  801422:	8b 40 48             	mov    0x48(%eax),%eax
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	51                   	push   %ecx
  801429:	50                   	push   %eax
  80142a:	68 90 2a 80 00       	push   $0x802a90
  80142f:	e8 c0 ef ff ff       	call   8003f4 <cprintf>
	*dev = 0;
  801434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
  80144c:	83 ec 20             	sub    $0x20,%esp
  80144f:	8b 75 08             	mov    0x8(%ebp),%esi
  801452:	8a 45 0c             	mov    0xc(%ebp),%al
  801455:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801458:	56                   	push   %esi
  801459:	e8 92 fe ff ff       	call   8012f0 <fd2num>
  80145e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801461:	89 14 24             	mov    %edx,(%esp)
  801464:	50                   	push   %eax
  801465:	e8 21 ff ff ff       	call   80138b <fd_lookup>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 05                	js     801478 <fd_close+0x31>
	    || fd != fd2)
  801473:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801476:	74 0d                	je     801485 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801478:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80147c:	75 48                	jne    8014c6 <fd_close+0x7f>
  80147e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801483:	eb 41                	jmp    8014c6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 36                	pushl  (%esi)
  80148e:	e8 4e ff ff ff       	call   8013e1 <dev_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 1c                	js     8014b8 <fd_close+0x71>
		if (dev->dev_close)
  80149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149f:	8b 40 10             	mov    0x10(%eax),%eax
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	74 0d                	je     8014b3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	56                   	push   %esi
  8014aa:	ff d0                	call   *%eax
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	eb 05                	jmp    8014b8 <fd_close+0x71>
		else
			r = 0;
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	56                   	push   %esi
  8014bc:	6a 00                	push   $0x0
  8014be:	e8 b3 f9 ff ff       	call   800e76 <sys_page_unmap>
	return r;
  8014c3:	83 c4 10             	add    $0x10,%esp
}
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	ff 75 08             	pushl  0x8(%ebp)
  8014dc:	e8 aa fe ff ff       	call   80138b <fd_lookup>
  8014e1:	83 c4 08             	add    $0x8,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 10                	js     8014f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	6a 01                	push   $0x1
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	e8 52 ff ff ff       	call   801447 <fd_close>
  8014f5:	83 c4 10             	add    $0x10,%esp
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <close_all>:

void
close_all(void)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801501:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	53                   	push   %ebx
  80150a:	e8 c0 ff ff ff       	call   8014cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80150f:	43                   	inc    %ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	83 fb 20             	cmp    $0x20,%ebx
  801516:	75 ee                	jne    801506 <close_all+0xc>
		close(i);
}
  801518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 2c             	sub    $0x2c,%esp
  801526:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801529:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 56 fe ff ff       	call   80138b <fd_lookup>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	0f 88 c0 00 00 00    	js     801602 <dup+0xe5>
		return r;
	close(newfdnum);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	57                   	push   %edi
  801546:	e8 84 ff ff ff       	call   8014cf <close>

	newfd = INDEX2FD(newfdnum);
  80154b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801551:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801554:	83 c4 04             	add    $0x4,%esp
  801557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155a:	e8 a1 fd ff ff       	call   801300 <fd2data>
  80155f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801561:	89 34 24             	mov    %esi,(%esp)
  801564:	e8 97 fd ff ff       	call   801300 <fd2data>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	c1 e8 16             	shr    $0x16,%eax
  801574:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80157b:	a8 01                	test   $0x1,%al
  80157d:	74 37                	je     8015b6 <dup+0x99>
  80157f:	89 d8                	mov    %ebx,%eax
  801581:	c1 e8 0c             	shr    $0xc,%eax
  801584:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80158b:	f6 c2 01             	test   $0x1,%dl
  80158e:	74 26                	je     8015b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801590:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	25 07 0e 00 00       	and    $0xe07,%eax
  80159f:	50                   	push   %eax
  8015a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a3:	6a 00                	push   $0x0
  8015a5:	53                   	push   %ebx
  8015a6:	6a 00                	push   $0x0
  8015a8:	e8 a3 f8 ff ff       	call   800e50 <sys_page_map>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	83 c4 20             	add    $0x20,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 2d                	js     8015e3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	c1 ea 0c             	shr    $0xc,%edx
  8015be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015ce:	52                   	push   %edx
  8015cf:	56                   	push   %esi
  8015d0:	6a 00                	push   $0x0
  8015d2:	50                   	push   %eax
  8015d3:	6a 00                	push   $0x0
  8015d5:	e8 76 f8 ff ff       	call   800e50 <sys_page_map>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	83 c4 20             	add    $0x20,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	79 1d                	jns    801600 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	56                   	push   %esi
  8015e7:	6a 00                	push   $0x0
  8015e9:	e8 88 f8 ff ff       	call   800e76 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f4:	6a 00                	push   $0x0
  8015f6:	e8 7b f8 ff ff       	call   800e76 <sys_page_unmap>
	return r;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb 02                	jmp    801602 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801600:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801602:	89 d8                	mov    %ebx,%eax
  801604:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 14             	sub    $0x14,%esp
  801613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	53                   	push   %ebx
  80161b:	e8 6b fd ff ff       	call   80138b <fd_lookup>
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 67                	js     80168e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	ff 30                	pushl  (%eax)
  801633:	e8 a9 fd ff ff       	call   8013e1 <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 4f                	js     80168e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801642:	8b 50 08             	mov    0x8(%eax),%edx
  801645:	83 e2 03             	and    $0x3,%edx
  801648:	83 fa 01             	cmp    $0x1,%edx
  80164b:	75 21                	jne    80166e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80164d:	a1 04 40 80 00       	mov    0x804004,%eax
  801652:	8b 40 48             	mov    0x48(%eax),%eax
  801655:	83 ec 04             	sub    $0x4,%esp
  801658:	53                   	push   %ebx
  801659:	50                   	push   %eax
  80165a:	68 d1 2a 80 00       	push   $0x802ad1
  80165f:	e8 90 ed ff ff       	call   8003f4 <cprintf>
		return -E_INVAL;
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166c:	eb 20                	jmp    80168e <read+0x82>
	}
	if (!dev->dev_read)
  80166e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801671:	8b 52 08             	mov    0x8(%edx),%edx
  801674:	85 d2                	test   %edx,%edx
  801676:	74 11                	je     801689 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801678:	83 ec 04             	sub    $0x4,%esp
  80167b:	ff 75 10             	pushl  0x10(%ebp)
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	50                   	push   %eax
  801682:	ff d2                	call   *%edx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 05                	jmp    80168e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801689:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80168e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	57                   	push   %edi
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80169f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a2:	85 f6                	test   %esi,%esi
  8016a4:	74 31                	je     8016d7 <readn+0x44>
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	89 f2                	mov    %esi,%edx
  8016b5:	29 c2                	sub    %eax,%edx
  8016b7:	52                   	push   %edx
  8016b8:	03 45 0c             	add    0xc(%ebp),%eax
  8016bb:	50                   	push   %eax
  8016bc:	57                   	push   %edi
  8016bd:	e8 4a ff ff ff       	call   80160c <read>
		if (m < 0)
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 17                	js     8016e0 <readn+0x4d>
			return m;
		if (m == 0)
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	74 11                	je     8016de <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016cd:	01 c3                	add    %eax,%ebx
  8016cf:	89 d8                	mov    %ebx,%eax
  8016d1:	39 f3                	cmp    %esi,%ebx
  8016d3:	72 db                	jb     8016b0 <readn+0x1d>
  8016d5:	eb 09                	jmp    8016e0 <readn+0x4d>
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dc:	eb 02                	jmp    8016e0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016de:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5f                   	pop    %edi
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 14             	sub    $0x14,%esp
  8016ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	53                   	push   %ebx
  8016f7:	e8 8f fc ff ff       	call   80138b <fd_lookup>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 62                	js     801765 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 cd fc ff ff       	call   8013e1 <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 4a                	js     801765 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801722:	75 21                	jne    801745 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801724:	a1 04 40 80 00       	mov    0x804004,%eax
  801729:	8b 40 48             	mov    0x48(%eax),%eax
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	53                   	push   %ebx
  801730:	50                   	push   %eax
  801731:	68 ed 2a 80 00       	push   $0x802aed
  801736:	e8 b9 ec ff ff       	call   8003f4 <cprintf>
		return -E_INVAL;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801743:	eb 20                	jmp    801765 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801748:	8b 52 0c             	mov    0xc(%edx),%edx
  80174b:	85 d2                	test   %edx,%edx
  80174d:	74 11                	je     801760 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80174f:	83 ec 04             	sub    $0x4,%esp
  801752:	ff 75 10             	pushl  0x10(%ebp)
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	50                   	push   %eax
  801759:	ff d2                	call   *%edx
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	eb 05                	jmp    801765 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <seek>:

int
seek(int fdnum, off_t offset)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801770:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	e8 0f fc ff ff       	call   80138b <fd_lookup>
  80177c:	83 c4 08             	add    $0x8,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 0e                	js     801791 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801783:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
  801789:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 14             	sub    $0x14,%esp
  80179a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	53                   	push   %ebx
  8017a2:	e8 e4 fb ff ff       	call   80138b <fd_lookup>
  8017a7:	83 c4 08             	add    $0x8,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 5f                	js     80180d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b4:	50                   	push   %eax
  8017b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b8:	ff 30                	pushl  (%eax)
  8017ba:	e8 22 fc ff ff       	call   8013e1 <dev_lookup>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 47                	js     80180d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017cd:	75 21                	jne    8017f0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d4:	8b 40 48             	mov    0x48(%eax),%eax
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	53                   	push   %ebx
  8017db:	50                   	push   %eax
  8017dc:	68 b0 2a 80 00       	push   $0x802ab0
  8017e1:	e8 0e ec ff ff       	call   8003f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ee:	eb 1d                	jmp    80180d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8017f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f3:	8b 52 18             	mov    0x18(%edx),%edx
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	74 0e                	je     801808 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	50                   	push   %eax
  801801:	ff d2                	call   *%edx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 05                	jmp    80180d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80180d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 14             	sub    $0x14,%esp
  801819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	ff 75 08             	pushl  0x8(%ebp)
  801823:	e8 63 fb ff ff       	call   80138b <fd_lookup>
  801828:	83 c4 08             	add    $0x8,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 52                	js     801881 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	ff 30                	pushl  (%eax)
  80183b:	e8 a1 fb ff ff       	call   8013e1 <dev_lookup>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 3a                	js     801881 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184e:	74 2c                	je     80187c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185a:	00 00 00 
	stat->st_isdir = 0;
  80185d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801864:	00 00 00 
	stat->st_dev = dev;
  801867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	53                   	push   %ebx
  801871:	ff 75 f0             	pushl  -0x10(%ebp)
  801874:	ff 50 14             	call   *0x14(%eax)
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 05                	jmp    801881 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80187c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	6a 00                	push   $0x0
  801890:	ff 75 08             	pushl  0x8(%ebp)
  801893:	e8 78 01 00 00       	call   801a10 <open>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 1b                	js     8018bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	50                   	push   %eax
  8018a8:	e8 65 ff ff ff       	call   801812 <fstat>
  8018ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8018af:	89 1c 24             	mov    %ebx,(%esp)
  8018b2:	e8 18 fc ff ff       	call   8014cf <close>
	return r;
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	89 f3                	mov    %esi,%ebx
}
  8018bc:	89 d8                	mov    %ebx,%eax
  8018be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c1:	5b                   	pop    %ebx
  8018c2:	5e                   	pop    %esi
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    
  8018c5:	00 00                	add    %al,(%eax)
	...

008018c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	56                   	push   %esi
  8018cc:	53                   	push   %ebx
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d8:	75 12                	jne    8018ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	6a 01                	push   $0x1
  8018df:	e8 9e 08 00 00       	call   802182 <ipc_find_env>
  8018e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ec:	6a 07                	push   $0x7
  8018ee:	68 00 50 80 00       	push   $0x805000
  8018f3:	53                   	push   %ebx
  8018f4:	ff 35 00 40 80 00    	pushl  0x804000
  8018fa:	e8 2e 08 00 00       	call   80212d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018ff:	83 c4 0c             	add    $0xc,%esp
  801902:	6a 00                	push   $0x0
  801904:	56                   	push   %esi
  801905:	6a 00                	push   $0x0
  801907:	e8 ac 07 00 00       	call   8020b8 <ipc_recv>
}
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	53                   	push   %ebx
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 05 00 00 00       	mov    $0x5,%eax
  801932:	e8 91 ff ff ff       	call   8018c8 <fsipc>
  801937:	85 c0                	test   %eax,%eax
  801939:	78 2c                	js     801967 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	68 00 50 80 00       	push   $0x805000
  801943:	53                   	push   %ebx
  801944:	e8 61 f0 ff ff       	call   8009aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801949:	a1 80 50 80 00       	mov    0x805080,%eax
  80194e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801954:	a1 84 50 80 00       	mov    0x805084,%eax
  801959:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	8b 40 0c             	mov    0xc(%eax),%eax
  801978:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80197d:	ba 00 00 00 00       	mov    $0x0,%edx
  801982:	b8 06 00 00 00       	mov    $0x6,%eax
  801987:	e8 3c ff ff ff       	call   8018c8 <fsipc>
}
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	8b 40 0c             	mov    0xc(%eax),%eax
  80199c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b1:	e8 12 ff ff ff       	call   8018c8 <fsipc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 4b                	js     801a07 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019bc:	39 c6                	cmp    %eax,%esi
  8019be:	73 16                	jae    8019d6 <devfile_read+0x48>
  8019c0:	68 1c 2b 80 00       	push   $0x802b1c
  8019c5:	68 23 2b 80 00       	push   $0x802b23
  8019ca:	6a 7d                	push   $0x7d
  8019cc:	68 38 2b 80 00       	push   $0x802b38
  8019d1:	e8 46 e9 ff ff       	call   80031c <_panic>
	assert(r <= PGSIZE);
  8019d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019db:	7e 16                	jle    8019f3 <devfile_read+0x65>
  8019dd:	68 43 2b 80 00       	push   $0x802b43
  8019e2:	68 23 2b 80 00       	push   $0x802b23
  8019e7:	6a 7e                	push   $0x7e
  8019e9:	68 38 2b 80 00       	push   $0x802b38
  8019ee:	e8 29 e9 ff ff       	call   80031c <_panic>
	memmove(buf, &fsipcbuf, r);
  8019f3:	83 ec 04             	sub    $0x4,%esp
  8019f6:	50                   	push   %eax
  8019f7:	68 00 50 80 00       	push   $0x805000
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	e8 67 f1 ff ff       	call   800b6b <memmove>
	return r;
  801a04:	83 c4 10             	add    $0x10,%esp
}
  801a07:	89 d8                	mov    %ebx,%eax
  801a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	83 ec 1c             	sub    $0x1c,%esp
  801a18:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1b:	56                   	push   %esi
  801a1c:	e8 37 ef ff ff       	call   800958 <strlen>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a29:	7f 65                	jg     801a90 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a31:	50                   	push   %eax
  801a32:	e8 e1 f8 ff ff       	call   801318 <fd_alloc>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 55                	js     801a95 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	56                   	push   %esi
  801a44:	68 00 50 80 00       	push   $0x805000
  801a49:	e8 5c ef ff ff       	call   8009aa <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a59:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5e:	e8 65 fe ff ff       	call   8018c8 <fsipc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	79 12                	jns    801a7e <open+0x6e>
		fd_close(fd, 0);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 f4             	pushl  -0xc(%ebp)
  801a74:	e8 ce f9 ff ff       	call   801447 <fd_close>
		return r;
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb 17                	jmp    801a95 <open+0x85>
	}

	return fd2num(fd);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	e8 67 f8 ff ff       	call   8012f0 <fd2num>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	eb 05                	jmp    801a95 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a90:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    
	...

00801aa0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 08             	pushl  0x8(%ebp)
  801aae:	e8 4d f8 ff ff       	call   801300 <fd2data>
  801ab3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ab5:	83 c4 08             	add    $0x8,%esp
  801ab8:	68 4f 2b 80 00       	push   $0x802b4f
  801abd:	56                   	push   %esi
  801abe:	e8 e7 ee ff ff       	call   8009aa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac3:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac6:	2b 03                	sub    (%ebx),%eax
  801ac8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ace:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ad5:	00 00 00 
	stat->st_dev = &devpipe;
  801ad8:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801adf:	30 80 00 
	return 0;
}
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	53                   	push   %ebx
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801af8:	53                   	push   %ebx
  801af9:	6a 00                	push   $0x0
  801afb:	e8 76 f3 ff ff       	call   800e76 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b00:	89 1c 24             	mov    %ebx,(%esp)
  801b03:	e8 f8 f7 ff ff       	call   801300 <fd2data>
  801b08:	83 c4 08             	add    $0x8,%esp
  801b0b:	50                   	push   %eax
  801b0c:	6a 00                	push   $0x0
  801b0e:	e8 63 f3 ff ff       	call   800e76 <sys_page_unmap>
}
  801b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 1c             	sub    $0x1c,%esp
  801b21:	89 c7                	mov    %eax,%edi
  801b23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b26:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	57                   	push   %edi
  801b32:	e8 99 06 00 00       	call   8021d0 <pageref>
  801b37:	89 c6                	mov    %eax,%esi
  801b39:	83 c4 04             	add    $0x4,%esp
  801b3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3f:	e8 8c 06 00 00       	call   8021d0 <pageref>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	39 c6                	cmp    %eax,%esi
  801b49:	0f 94 c0             	sete   %al
  801b4c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b4f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b55:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b58:	39 cb                	cmp    %ecx,%ebx
  801b5a:	75 08                	jne    801b64 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5f                   	pop    %edi
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b64:	83 f8 01             	cmp    $0x1,%eax
  801b67:	75 bd                	jne    801b26 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b69:	8b 42 58             	mov    0x58(%edx),%eax
  801b6c:	6a 01                	push   $0x1
  801b6e:	50                   	push   %eax
  801b6f:	53                   	push   %ebx
  801b70:	68 56 2b 80 00       	push   $0x802b56
  801b75:	e8 7a e8 ff ff       	call   8003f4 <cprintf>
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	eb a7                	jmp    801b26 <_pipeisclosed+0xe>

00801b7f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 28             	sub    $0x28,%esp
  801b88:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b8b:	56                   	push   %esi
  801b8c:	e8 6f f7 ff ff       	call   801300 <fd2data>
  801b91:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b9a:	75 4a                	jne    801be6 <devpipe_write+0x67>
  801b9c:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba1:	eb 56                	jmp    801bf9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ba3:	89 da                	mov    %ebx,%edx
  801ba5:	89 f0                	mov    %esi,%eax
  801ba7:	e8 6c ff ff ff       	call   801b18 <_pipeisclosed>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	75 4d                	jne    801bfd <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bb0:	e8 50 f2 ff ff       	call   800e05 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb5:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb8:	8b 13                	mov    (%ebx),%edx
  801bba:	83 c2 20             	add    $0x20,%edx
  801bbd:	39 d0                	cmp    %edx,%eax
  801bbf:	73 e2                	jae    801ba3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bc9:	79 05                	jns    801bd0 <devpipe_write+0x51>
  801bcb:	4a                   	dec    %edx
  801bcc:	83 ca e0             	or     $0xffffffe0,%edx
  801bcf:	42                   	inc    %edx
  801bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801bd6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bda:	40                   	inc    %eax
  801bdb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bde:	47                   	inc    %edi
  801bdf:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801be2:	77 07                	ja     801beb <devpipe_write+0x6c>
  801be4:	eb 13                	jmp    801bf9 <devpipe_write+0x7a>
  801be6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801beb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bee:	8b 13                	mov    (%ebx),%edx
  801bf0:	83 c2 20             	add    $0x20,%edx
  801bf3:	39 d0                	cmp    %edx,%eax
  801bf5:	73 ac                	jae    801ba3 <devpipe_write+0x24>
  801bf7:	eb c8                	jmp    801bc1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bf9:	89 f8                	mov    %edi,%eax
  801bfb:	eb 05                	jmp    801c02 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	57                   	push   %edi
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	83 ec 18             	sub    $0x18,%esp
  801c13:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c16:	57                   	push   %edi
  801c17:	e8 e4 f6 ff ff       	call   801300 <fd2data>
  801c1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c25:	75 44                	jne    801c6b <devpipe_read+0x61>
  801c27:	be 00 00 00 00       	mov    $0x0,%esi
  801c2c:	eb 4f                	jmp    801c7d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c2e:	89 f0                	mov    %esi,%eax
  801c30:	eb 54                	jmp    801c86 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c32:	89 da                	mov    %ebx,%edx
  801c34:	89 f8                	mov    %edi,%eax
  801c36:	e8 dd fe ff ff       	call   801b18 <_pipeisclosed>
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	75 42                	jne    801c81 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c3f:	e8 c1 f1 ff ff       	call   800e05 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c44:	8b 03                	mov    (%ebx),%eax
  801c46:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c49:	74 e7                	je     801c32 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c4b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c50:	79 05                	jns    801c57 <devpipe_read+0x4d>
  801c52:	48                   	dec    %eax
  801c53:	83 c8 e0             	or     $0xffffffe0,%eax
  801c56:	40                   	inc    %eax
  801c57:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c61:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c63:	46                   	inc    %esi
  801c64:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c67:	77 07                	ja     801c70 <devpipe_read+0x66>
  801c69:	eb 12                	jmp    801c7d <devpipe_read+0x73>
  801c6b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801c70:	8b 03                	mov    (%ebx),%eax
  801c72:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c75:	75 d4                	jne    801c4b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c77:	85 f6                	test   %esi,%esi
  801c79:	75 b3                	jne    801c2e <devpipe_read+0x24>
  801c7b:	eb b5                	jmp    801c32 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c7d:	89 f0                	mov    %esi,%eax
  801c7f:	eb 05                	jmp    801c86 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c81:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5e                   	pop    %esi
  801c8b:	5f                   	pop    %edi
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 28             	sub    $0x28,%esp
  801c97:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c9d:	50                   	push   %eax
  801c9e:	e8 75 f6 ff ff       	call   801318 <fd_alloc>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 24 01 00 00    	js     801dd4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb0:	83 ec 04             	sub    $0x4,%esp
  801cb3:	68 07 04 00 00       	push   $0x407
  801cb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 6a f1 ff ff       	call   800e2c <sys_page_alloc>
  801cc2:	89 c3                	mov    %eax,%ebx
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	0f 88 05 01 00 00    	js     801dd4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cd5:	50                   	push   %eax
  801cd6:	e8 3d f6 ff ff       	call   801318 <fd_alloc>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	0f 88 dc 00 00 00    	js     801dc4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce8:	83 ec 04             	sub    $0x4,%esp
  801ceb:	68 07 04 00 00       	push   $0x407
  801cf0:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf3:	6a 00                	push   $0x0
  801cf5:	e8 32 f1 ff ff       	call   800e2c <sys_page_alloc>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	0f 88 bd 00 00 00    	js     801dc4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d07:	83 ec 0c             	sub    $0xc,%esp
  801d0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d0d:	e8 ee f5 ff ff       	call   801300 <fd2data>
  801d12:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d14:	83 c4 0c             	add    $0xc,%esp
  801d17:	68 07 04 00 00       	push   $0x407
  801d1c:	50                   	push   %eax
  801d1d:	6a 00                	push   $0x0
  801d1f:	e8 08 f1 ff ff       	call   800e2c <sys_page_alloc>
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 83 00 00 00    	js     801db4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff 75 e0             	pushl  -0x20(%ebp)
  801d37:	e8 c4 f5 ff ff       	call   801300 <fd2data>
  801d3c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d43:	50                   	push   %eax
  801d44:	6a 00                	push   $0x0
  801d46:	56                   	push   %esi
  801d47:	6a 00                	push   $0x0
  801d49:	e8 02 f1 ff ff       	call   800e50 <sys_page_map>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	78 4f                	js     801da6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d57:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d60:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d6c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d72:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d75:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d7a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d87:	e8 64 f5 ff ff       	call   8012f0 <fd2num>
  801d8c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d8e:	83 c4 04             	add    $0x4,%esp
  801d91:	ff 75 e0             	pushl  -0x20(%ebp)
  801d94:	e8 57 f5 ff ff       	call   8012f0 <fd2num>
  801d99:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da4:	eb 2e                	jmp    801dd4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801da6:	83 ec 08             	sub    $0x8,%esp
  801da9:	56                   	push   %esi
  801daa:	6a 00                	push   $0x0
  801dac:	e8 c5 f0 ff ff       	call   800e76 <sys_page_unmap>
  801db1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801db4:	83 ec 08             	sub    $0x8,%esp
  801db7:	ff 75 e0             	pushl  -0x20(%ebp)
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 b5 f0 ff ff       	call   800e76 <sys_page_unmap>
  801dc1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 a5 f0 ff ff       	call   800e76 <sys_page_unmap>
  801dd1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801dd4:	89 d8                	mov    %ebx,%eax
  801dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	ff 75 08             	pushl  0x8(%ebp)
  801deb:	e8 9b f5 ff ff       	call   80138b <fd_lookup>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	78 18                	js     801e0f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfd:	e8 fe f4 ff ff       	call   801300 <fd2data>
	return _pipeisclosed(fd, p);
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	e8 0c fd ff ff       	call   801b18 <_pipeisclosed>
  801e0c:	83 c4 10             	add    $0x10,%esp
}
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    
  801e11:	00 00                	add    %al,(%eax)
	...

00801e14 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	8b 55 08             	mov    0x8(%ebp),%edx
	const volatile struct Env *e;

	assert(envid != 0);
  801e20:	85 d2                	test   %edx,%edx
  801e22:	75 16                	jne    801e3a <wait+0x26>
  801e24:	68 6e 2b 80 00       	push   $0x802b6e
  801e29:	68 23 2b 80 00       	push   $0x802b23
  801e2e:	6a 09                	push   $0x9
  801e30:	68 79 2b 80 00       	push   $0x802b79
  801e35:	e8 e2 e4 ff ff       	call   80031c <_panic>
	e = &envs[ENVX(envid)];
  801e3a:	89 d0                	mov    %edx,%eax
  801e3c:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e41:	89 c1                	mov    %eax,%ecx
  801e43:	c1 e1 07             	shl    $0x7,%ecx
  801e46:	8d 8c 81 08 00 c0 ee 	lea    -0x113ffff8(%ecx,%eax,4),%ecx
  801e4d:	8b 79 40             	mov    0x40(%ecx),%edi
  801e50:	39 d7                	cmp    %edx,%edi
  801e52:	75 36                	jne    801e8a <wait+0x76>
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	c1 e2 07             	shl    $0x7,%edx
  801e59:	8d 94 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%edx
  801e60:	8b 52 50             	mov    0x50(%edx),%edx
  801e63:	85 d2                	test   %edx,%edx
  801e65:	74 23                	je     801e8a <wait+0x76>
  801e67:	89 c2                	mov    %eax,%edx
  801e69:	c1 e2 07             	shl    $0x7,%edx
  801e6c:	8d 34 82             	lea    (%edx,%eax,4),%esi
  801e6f:	89 cb                	mov    %ecx,%ebx
  801e71:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801e77:	e8 89 ef ff ff       	call   800e05 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e7c:	8b 43 40             	mov    0x40(%ebx),%eax
  801e7f:	39 f8                	cmp    %edi,%eax
  801e81:	75 07                	jne    801e8a <wait+0x76>
  801e83:	8b 46 50             	mov    0x50(%esi),%eax
  801e86:	85 c0                	test   %eax,%eax
  801e88:	75 ed                	jne    801e77 <wait+0x63>
		sys_yield();
}
  801e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    
	...

00801e94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ea4:	68 84 2b 80 00       	push   $0x802b84
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	e8 f9 ea ff ff       	call   8009aa <strcpy>
	return 0;
}
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	57                   	push   %edi
  801ebc:	56                   	push   %esi
  801ebd:	53                   	push   %ebx
  801ebe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ec8:	74 45                	je     801f0f <devcons_write+0x57>
  801eca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801edd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801edf:	83 fb 7f             	cmp    $0x7f,%ebx
  801ee2:	76 05                	jbe    801ee9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ee4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	53                   	push   %ebx
  801eed:	03 45 0c             	add    0xc(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	57                   	push   %edi
  801ef2:	e8 74 ec ff ff       	call   800b6b <memmove>
		sys_cputs(buf, m);
  801ef7:	83 c4 08             	add    $0x8,%esp
  801efa:	53                   	push   %ebx
  801efb:	57                   	push   %edi
  801efc:	e8 74 ee ff ff       	call   800d75 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f01:	01 de                	add    %ebx,%esi
  801f03:	89 f0                	mov    %esi,%eax
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0b:	72 cd                	jb     801eda <devcons_write+0x22>
  801f0d:	eb 05                	jmp    801f14 <devcons_write+0x5c>
  801f0f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f14:	89 f0                	mov    %esi,%eax
  801f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f28:	75 07                	jne    801f31 <devcons_read+0x13>
  801f2a:	eb 25                	jmp    801f51 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f2c:	e8 d4 ee ff ff       	call   800e05 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f31:	e8 65 ee ff ff       	call   800d9b <sys_cgetc>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	74 f2                	je     801f2c <devcons_read+0xe>
  801f3a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 1d                	js     801f5d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f40:	83 f8 04             	cmp    $0x4,%eax
  801f43:	74 13                	je     801f58 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f48:	88 10                	mov    %dl,(%eax)
	return 1;
  801f4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4f:	eb 0c                	jmp    801f5d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
  801f56:	eb 05                	jmp    801f5d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f65:	8b 45 08             	mov    0x8(%ebp),%eax
  801f68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f6b:	6a 01                	push   $0x1
  801f6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f70:	50                   	push   %eax
  801f71:	e8 ff ed ff ff       	call   800d75 <sys_cputs>
  801f76:	83 c4 10             	add    $0x10,%esp
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <getchar>:

int
getchar(void)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f81:	6a 01                	push   $0x1
  801f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	6a 00                	push   $0x0
  801f89:	e8 7e f6 ff ff       	call   80160c <read>
	if (r < 0)
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 0f                	js     801fa4 <getchar+0x29>
		return r;
	if (r < 1)
  801f95:	85 c0                	test   %eax,%eax
  801f97:	7e 06                	jle    801f9f <getchar+0x24>
		return -E_EOF;
	return c;
  801f99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f9d:	eb 05                	jmp    801fa4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801faf:	50                   	push   %eax
  801fb0:	ff 75 08             	pushl  0x8(%ebp)
  801fb3:	e8 d3 f3 ff ff       	call   80138b <fd_lookup>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	78 11                	js     801fd0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fc8:	39 10                	cmp    %edx,(%eax)
  801fca:	0f 94 c0             	sete   %al
  801fcd:	0f b6 c0             	movzbl %al,%eax
}
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <opencons>:

int
opencons(void)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdb:	50                   	push   %eax
  801fdc:	e8 37 f3 ff ff       	call   801318 <fd_alloc>
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	78 3a                	js     802022 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe8:	83 ec 04             	sub    $0x4,%esp
  801feb:	68 07 04 00 00       	push   $0x407
  801ff0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 32 ee ff ff       	call   800e2c <sys_page_alloc>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 21                	js     802022 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802001:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802016:	83 ec 0c             	sub    $0xc,%esp
  802019:	50                   	push   %eax
  80201a:	e8 d1 f2 ff ff       	call   8012f0 <fd2num>
  80201f:	83 c4 10             	add    $0x10,%esp
}
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80202a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802031:	75 52                	jne    802085 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802033:	83 ec 04             	sub    $0x4,%esp
  802036:	6a 07                	push   $0x7
  802038:	68 00 f0 bf ee       	push   $0xeebff000
  80203d:	6a 00                	push   $0x0
  80203f:	e8 e8 ed ff ff       	call   800e2c <sys_page_alloc>
		if (r < 0) {
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	85 c0                	test   %eax,%eax
  802049:	79 12                	jns    80205d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80204b:	50                   	push   %eax
  80204c:	68 90 2b 80 00       	push   $0x802b90
  802051:	6a 24                	push   $0x24
  802053:	68 ab 2b 80 00       	push   $0x802bab
  802058:	e8 bf e2 ff ff       	call   80031c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80205d:	83 ec 08             	sub    $0x8,%esp
  802060:	68 90 20 80 00       	push   $0x802090
  802065:	6a 00                	push   $0x0
  802067:	e8 73 ee ff ff       	call   800edf <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	85 c0                	test   %eax,%eax
  802071:	79 12                	jns    802085 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802073:	50                   	push   %eax
  802074:	68 bc 2b 80 00       	push   $0x802bbc
  802079:	6a 2a                	push   $0x2a
  80207b:	68 ab 2b 80 00       	push   $0x802bab
  802080:	e8 97 e2 ff ff       	call   80031c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802085:	8b 45 08             	mov    0x8(%ebp),%eax
  802088:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    
	...

00802090 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802090:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802091:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802096:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802098:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80209b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80209f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8020a2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8020a6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8020aa:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8020ac:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8020af:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8020b0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8020b3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8020b4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020b5:	c3                   	ret    
	...

008020b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	74 0e                	je     8020d8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	50                   	push   %eax
  8020ce:	e8 54 ee ff ff       	call   800f27 <sys_ipc_recv>
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	eb 10                	jmp    8020e8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8020d8:	83 ec 0c             	sub    $0xc,%esp
  8020db:	68 00 00 c0 ee       	push   $0xeec00000
  8020e0:	e8 42 ee ff ff       	call   800f27 <sys_ipc_recv>
  8020e5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	75 26                	jne    802112 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8020ec:	85 f6                	test   %esi,%esi
  8020ee:	74 0a                	je     8020fa <ipc_recv+0x42>
  8020f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f5:	8b 40 74             	mov    0x74(%eax),%eax
  8020f8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8020fa:	85 db                	test   %ebx,%ebx
  8020fc:	74 0a                	je     802108 <ipc_recv+0x50>
  8020fe:	a1 04 40 80 00       	mov    0x804004,%eax
  802103:	8b 40 78             	mov    0x78(%eax),%eax
  802106:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802108:	a1 04 40 80 00       	mov    0x804004,%eax
  80210d:	8b 40 70             	mov    0x70(%eax),%eax
  802110:	eb 14                	jmp    802126 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802112:	85 f6                	test   %esi,%esi
  802114:	74 06                	je     80211c <ipc_recv+0x64>
  802116:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80211c:	85 db                	test   %ebx,%ebx
  80211e:	74 06                	je     802126 <ipc_recv+0x6e>
  802120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802129:	5b                   	pop    %ebx
  80212a:	5e                   	pop    %esi
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    

0080212d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	57                   	push   %edi
  802131:	56                   	push   %esi
  802132:	53                   	push   %ebx
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802139:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80213c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80213f:	85 db                	test   %ebx,%ebx
  802141:	75 25                	jne    802168 <ipc_send+0x3b>
  802143:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802148:	eb 1e                	jmp    802168 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80214a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214d:	75 07                	jne    802156 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80214f:	e8 b1 ec ff ff       	call   800e05 <sys_yield>
  802154:	eb 12                	jmp    802168 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802156:	50                   	push   %eax
  802157:	68 e4 2b 80 00       	push   $0x802be4
  80215c:	6a 43                	push   $0x43
  80215e:	68 f7 2b 80 00       	push   $0x802bf7
  802163:	e8 b4 e1 ff ff       	call   80031c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802168:	56                   	push   %esi
  802169:	53                   	push   %ebx
  80216a:	57                   	push   %edi
  80216b:	ff 75 08             	pushl  0x8(%ebp)
  80216e:	e8 8f ed ff ff       	call   800f02 <sys_ipc_try_send>
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	85 c0                	test   %eax,%eax
  802178:	75 d0                	jne    80214a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80217a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	c9                   	leave  
  802181:	c3                   	ret    

00802182 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802188:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80218e:	74 1a                	je     8021aa <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802190:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802195:	89 c2                	mov    %eax,%edx
  802197:	c1 e2 07             	shl    $0x7,%edx
  80219a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8021a1:	8b 52 50             	mov    0x50(%edx),%edx
  8021a4:	39 ca                	cmp    %ecx,%edx
  8021a6:	75 18                	jne    8021c0 <ipc_find_env+0x3e>
  8021a8:	eb 05                	jmp    8021af <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8021af:	89 c2                	mov    %eax,%edx
  8021b1:	c1 e2 07             	shl    $0x7,%edx
  8021b4:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8021bb:	8b 40 40             	mov    0x40(%eax),%eax
  8021be:	eb 0c                	jmp    8021cc <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021c0:	40                   	inc    %eax
  8021c1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c6:	75 cd                	jne    802195 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021c8:	66 b8 00 00          	mov    $0x0,%ax
}
  8021cc:	c9                   	leave  
  8021cd:	c3                   	ret    
	...

008021d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d6:	89 c2                	mov    %eax,%edx
  8021d8:	c1 ea 16             	shr    $0x16,%edx
  8021db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021e2:	f6 c2 01             	test   $0x1,%dl
  8021e5:	74 1e                	je     802205 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021e7:	c1 e8 0c             	shr    $0xc,%eax
  8021ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021f1:	a8 01                	test   $0x1,%al
  8021f3:	74 17                	je     80220c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021f5:	c1 e8 0c             	shr    $0xc,%eax
  8021f8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021ff:	ef 
  802200:	0f b7 c0             	movzwl %ax,%eax
  802203:	eb 0c                	jmp    802211 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
  80220a:	eb 05                	jmp    802211 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80220c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802211:	c9                   	leave  
  802212:	c3                   	ret    
	...

00802214 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	57                   	push   %edi
  802218:	56                   	push   %esi
  802219:	83 ec 10             	sub    $0x10,%esp
  80221c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80221f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802222:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802225:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802228:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80222b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80222e:	85 c0                	test   %eax,%eax
  802230:	75 2e                	jne    802260 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802232:	39 f1                	cmp    %esi,%ecx
  802234:	77 5a                	ja     802290 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802236:	85 c9                	test   %ecx,%ecx
  802238:	75 0b                	jne    802245 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80223a:	b8 01 00 00 00       	mov    $0x1,%eax
  80223f:	31 d2                	xor    %edx,%edx
  802241:	f7 f1                	div    %ecx
  802243:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802245:	31 d2                	xor    %edx,%edx
  802247:	89 f0                	mov    %esi,%eax
  802249:	f7 f1                	div    %ecx
  80224b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80224d:	89 f8                	mov    %edi,%eax
  80224f:	f7 f1                	div    %ecx
  802251:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802253:	89 f8                	mov    %edi,%eax
  802255:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802257:	83 c4 10             	add    $0x10,%esp
  80225a:	5e                   	pop    %esi
  80225b:	5f                   	pop    %edi
  80225c:	c9                   	leave  
  80225d:	c3                   	ret    
  80225e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802260:	39 f0                	cmp    %esi,%eax
  802262:	77 1c                	ja     802280 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802264:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	75 3c                	jne    8022a8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80226c:	39 f0                	cmp    %esi,%eax
  80226e:	0f 82 90 00 00 00    	jb     802304 <__udivdi3+0xf0>
  802274:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802277:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80227a:	0f 86 84 00 00 00    	jbe    802304 <__udivdi3+0xf0>
  802280:	31 f6                	xor    %esi,%esi
  802282:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802284:	89 f8                	mov    %edi,%eax
  802286:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802288:	83 c4 10             	add    $0x10,%esp
  80228b:	5e                   	pop    %esi
  80228c:	5f                   	pop    %edi
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    
  80228f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802290:	89 f2                	mov    %esi,%edx
  802292:	89 f8                	mov    %edi,%eax
  802294:	f7 f1                	div    %ecx
  802296:	89 c7                	mov    %eax,%edi
  802298:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80229a:	89 f8                	mov    %edi,%eax
  80229c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	5e                   	pop    %esi
  8022a2:	5f                   	pop    %edi
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    
  8022a5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022a8:	89 f9                	mov    %edi,%ecx
  8022aa:	d3 e0                	shl    %cl,%eax
  8022ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022af:	b8 20 00 00 00       	mov    $0x20,%eax
  8022b4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022b9:	88 c1                	mov    %al,%cl
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022c0:	09 ca                	or     %ecx,%edx
  8022c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8022c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022c8:	89 f9                	mov    %edi,%ecx
  8022ca:	d3 e2                	shl    %cl,%edx
  8022cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	88 c1                	mov    %al,%cl
  8022d3:	d3 ea                	shr    %cl,%edx
  8022d5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	89 f9                	mov    %edi,%ecx
  8022dc:	d3 e2                	shl    %cl,%edx
  8022de:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022e1:	88 c1                	mov    %al,%cl
  8022e3:	d3 ee                	shr    %cl,%esi
  8022e5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022ea:	89 f0                	mov    %esi,%eax
  8022ec:	89 ca                	mov    %ecx,%edx
  8022ee:	f7 75 ec             	divl   -0x14(%ebp)
  8022f1:	89 d1                	mov    %edx,%ecx
  8022f3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022f5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022f8:	39 d1                	cmp    %edx,%ecx
  8022fa:	72 28                	jb     802324 <__udivdi3+0x110>
  8022fc:	74 1a                	je     802318 <__udivdi3+0x104>
  8022fe:	89 f7                	mov    %esi,%edi
  802300:	31 f6                	xor    %esi,%esi
  802302:	eb 80                	jmp    802284 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802304:	31 f6                	xor    %esi,%esi
  802306:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80230b:	89 f8                	mov    %edi,%eax
  80230d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80230f:	83 c4 10             	add    $0x10,%esp
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	c9                   	leave  
  802315:	c3                   	ret    
  802316:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802318:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80231b:	89 f9                	mov    %edi,%ecx
  80231d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80231f:	39 c2                	cmp    %eax,%edx
  802321:	73 db                	jae    8022fe <__udivdi3+0xea>
  802323:	90                   	nop
		{
		  q0--;
  802324:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802327:	31 f6                	xor    %esi,%esi
  802329:	e9 56 ff ff ff       	jmp    802284 <__udivdi3+0x70>
	...

00802330 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	57                   	push   %edi
  802334:	56                   	push   %esi
  802335:	83 ec 20             	sub    $0x20,%esp
  802338:	8b 45 08             	mov    0x8(%ebp),%eax
  80233b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80233e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802341:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802344:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802347:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80234a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80234d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80234f:	85 ff                	test   %edi,%edi
  802351:	75 15                	jne    802368 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802353:	39 f1                	cmp    %esi,%ecx
  802355:	0f 86 99 00 00 00    	jbe    8023f4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80235b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80235d:	89 d0                	mov    %edx,%eax
  80235f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802361:	83 c4 20             	add    $0x20,%esp
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	c9                   	leave  
  802367:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802368:	39 f7                	cmp    %esi,%edi
  80236a:	0f 87 a4 00 00 00    	ja     802414 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802370:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802373:	83 f0 1f             	xor    $0x1f,%eax
  802376:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802379:	0f 84 a1 00 00 00    	je     802420 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80237f:	89 f8                	mov    %edi,%eax
  802381:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802384:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802386:	bf 20 00 00 00       	mov    $0x20,%edi
  80238b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80238e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802391:	89 f9                	mov    %edi,%ecx
  802393:	d3 ea                	shr    %cl,%edx
  802395:	09 c2                	or     %eax,%edx
  802397:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80239a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023a0:	d3 e0                	shl    %cl,%eax
  8023a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023a5:	89 f2                	mov    %esi,%edx
  8023a7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023b4:	89 f9                	mov    %edi,%ecx
  8023b6:	d3 e8                	shr    %cl,%eax
  8023b8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023ba:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023bc:	89 f2                	mov    %esi,%edx
  8023be:	f7 75 f0             	divl   -0x10(%ebp)
  8023c1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023c3:	f7 65 f4             	mull   -0xc(%ebp)
  8023c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8023c9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023cb:	39 d6                	cmp    %edx,%esi
  8023cd:	72 71                	jb     802440 <__umoddi3+0x110>
  8023cf:	74 7f                	je     802450 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d4:	29 c8                	sub    %ecx,%eax
  8023d6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8023d8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	89 f9                	mov    %edi,%ecx
  8023e1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8023e3:	09 d0                	or     %edx,%eax
  8023e5:	89 f2                	mov    %esi,%edx
  8023e7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023ea:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023ec:	83 c4 20             	add    $0x20,%esp
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	c9                   	leave  
  8023f2:	c3                   	ret    
  8023f3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023f4:	85 c9                	test   %ecx,%ecx
  8023f6:	75 0b                	jne    802403 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fd:	31 d2                	xor    %edx,%edx
  8023ff:	f7 f1                	div    %ecx
  802401:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802403:	89 f0                	mov    %esi,%eax
  802405:	31 d2                	xor    %edx,%edx
  802407:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80240c:	f7 f1                	div    %ecx
  80240e:	e9 4a ff ff ff       	jmp    80235d <__umoddi3+0x2d>
  802413:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802414:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802416:	83 c4 20             	add    $0x20,%esp
  802419:	5e                   	pop    %esi
  80241a:	5f                   	pop    %edi
  80241b:	c9                   	leave  
  80241c:	c3                   	ret    
  80241d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802420:	39 f7                	cmp    %esi,%edi
  802422:	72 05                	jb     802429 <__umoddi3+0xf9>
  802424:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802427:	77 0c                	ja     802435 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802429:	89 f2                	mov    %esi,%edx
  80242b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80242e:	29 c8                	sub    %ecx,%eax
  802430:	19 fa                	sbb    %edi,%edx
  802432:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802438:	83 c4 20             	add    $0x20,%esp
  80243b:	5e                   	pop    %esi
  80243c:	5f                   	pop    %edi
  80243d:	c9                   	leave  
  80243e:	c3                   	ret    
  80243f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802440:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802443:	89 c1                	mov    %eax,%ecx
  802445:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802448:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80244b:	eb 84                	jmp    8023d1 <__umoddi3+0xa1>
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802450:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802453:	72 eb                	jb     802440 <__umoddi3+0x110>
  802455:	89 f2                	mov    %esi,%edx
  802457:	e9 75 ff ff ff       	jmp    8023d1 <__umoddi3+0xa1>
