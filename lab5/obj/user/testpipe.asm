
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
  80003c:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800043:	24 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	50                   	push   %eax
  80004a:	e8 b7 1b 00 00       	call   801c06 <pipe>
  80004f:	89 c6                	mov    %eax,%esi
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", i);
  800058:	50                   	push   %eax
  800059:	68 2c 24 80 00       	push   $0x80242c
  80005e:	6a 0e                	push   $0xe
  800060:	68 35 24 80 00       	push   $0x802435
  800065:	e8 b6 02 00 00       	call   800320 <_panic>

	if ((pid = fork()) < 0)
  80006a:	e8 d3 0f 00 00       	call   801042 <fork>
  80006f:	89 c3                	mov    %eax,%ebx
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", i);
  800075:	56                   	push   %esi
  800076:	68 45 24 80 00       	push   $0x802445
  80007b:	6a 11                	push   $0x11
  80007d:	68 35 24 80 00       	push   $0x802435
  800082:	e8 99 02 00 00       	call   800320 <_panic>

	if (pid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 85 b8 00 00 00    	jne    800147 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	8b 40 48             	mov    0x48(%eax),%eax
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	ff 75 90             	pushl  -0x70(%ebp)
  80009d:	50                   	push   %eax
  80009e:	68 4e 24 80 00       	push   $0x80244e
  8000a3:	e8 50 03 00 00       	call   8003f8 <cprintf>
		close(p[1]);
  8000a8:	83 c4 04             	add    $0x4,%esp
  8000ab:	ff 75 90             	pushl  -0x70(%ebp)
  8000ae:	e8 74 13 00 00       	call   801427 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b8:	8b 40 48             	mov    0x48(%eax),%eax
  8000bb:	83 c4 0c             	add    $0xc,%esp
  8000be:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c1:	50                   	push   %eax
  8000c2:	68 6b 24 80 00       	push   $0x80246b
  8000c7:	e8 2c 03 00 00       	call   8003f8 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cc:	83 c4 0c             	add    $0xc,%esp
  8000cf:	6a 63                	push   $0x63
  8000d1:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d4:	50                   	push   %eax
  8000d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d8:	e8 0e 15 00 00       	call   8015eb <readn>
  8000dd:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <umain+0xc4>
			panic("read: %e", i);
  8000e6:	50                   	push   %eax
  8000e7:	68 88 24 80 00       	push   $0x802488
  8000ec:	6a 19                	push   $0x19
  8000ee:	68 35 24 80 00       	push   $0x802435
  8000f3:	e8 28 02 00 00       	call   800320 <_panic>
		buf[i] = 0;
  8000f8:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	ff 35 00 30 80 00    	pushl  0x803000
  800106:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800109:	50                   	push   %eax
  80010a:	e8 58 09 00 00       	call   800a67 <strcmp>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	75 12                	jne    800128 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	68 91 24 80 00       	push   $0x802491
  80011e:	e8 d5 02 00 00       	call   8003f8 <cprintf>
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	eb 15                	jmp    80013d <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	56                   	push   %esi
  800130:	68 ad 24 80 00       	push   $0x8024ad
  800135:	e8 be 02 00 00       	call   8003f8 <cprintf>
  80013a:	83 c4 10             	add    $0x10,%esp
		exit();
  80013d:	e8 c2 01 00 00       	call   800304 <exit>
  800142:	e9 94 00 00 00       	jmp    8001db <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800147:	a1 04 40 80 00       	mov    0x804004,%eax
  80014c:	8b 40 48             	mov    0x48(%eax),%eax
  80014f:	83 ec 04             	sub    $0x4,%esp
  800152:	ff 75 8c             	pushl  -0x74(%ebp)
  800155:	50                   	push   %eax
  800156:	68 4e 24 80 00       	push   $0x80244e
  80015b:	e8 98 02 00 00       	call   8003f8 <cprintf>
		close(p[0]);
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 8c             	pushl  -0x74(%ebp)
  800166:	e8 bc 12 00 00       	call   801427 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016b:	a1 04 40 80 00       	mov    0x804004,%eax
  800170:	8b 40 48             	mov    0x48(%eax),%eax
  800173:	83 c4 0c             	add    $0xc,%esp
  800176:	ff 75 90             	pushl  -0x70(%ebp)
  800179:	50                   	push   %eax
  80017a:	68 c0 24 80 00       	push   $0x8024c0
  80017f:	e8 74 02 00 00       	call   8003f8 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800184:	83 c4 04             	add    $0x4,%esp
  800187:	ff 35 00 30 80 00    	pushl  0x803000
  80018d:	e8 ca 07 00 00       	call   80095c <strlen>
  800192:	83 c4 0c             	add    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	ff 35 00 30 80 00    	pushl  0x803000
  80019c:	ff 75 90             	pushl  -0x70(%ebp)
  80019f:	e8 9c 14 00 00       	call   801640 <write>
  8001a4:	89 c6                	mov    %eax,%esi
  8001a6:	83 c4 04             	add    $0x4,%esp
  8001a9:	ff 35 00 30 80 00    	pushl  0x803000
  8001af:	e8 a8 07 00 00       	call   80095c <strlen>
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	39 c6                	cmp    %eax,%esi
  8001b9:	74 12                	je     8001cd <umain+0x199>
			panic("write: %e", i);
  8001bb:	56                   	push   %esi
  8001bc:	68 dd 24 80 00       	push   $0x8024dd
  8001c1:	6a 25                	push   $0x25
  8001c3:	68 35 24 80 00       	push   $0x802435
  8001c8:	e8 53 01 00 00       	call   800320 <_panic>
		close(p[1]);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	ff 75 90             	pushl  -0x70(%ebp)
  8001d3:	e8 4f 12 00 00       	call   801427 <close>
  8001d8:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	53                   	push   %ebx
  8001df:	e8 a8 1b 00 00       	call   801d8c <wait>

	binaryname = "pipewriteeof";
  8001e4:	c7 05 04 30 80 00 e7 	movl   $0x8024e7,0x803004
  8001eb:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ee:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 0d 1a 00 00       	call   801c06 <pipe>
  8001f9:	89 c6                	mov    %eax,%esi
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	85 c0                	test   %eax,%eax
  800200:	79 12                	jns    800214 <umain+0x1e0>
		panic("pipe: %e", i);
  800202:	50                   	push   %eax
  800203:	68 2c 24 80 00       	push   $0x80242c
  800208:	6a 2c                	push   $0x2c
  80020a:	68 35 24 80 00       	push   $0x802435
  80020f:	e8 0c 01 00 00       	call   800320 <_panic>

	if ((pid = fork()) < 0)
  800214:	e8 29 0e 00 00       	call   801042 <fork>
  800219:	89 c3                	mov    %eax,%ebx
  80021b:	85 c0                	test   %eax,%eax
  80021d:	79 12                	jns    800231 <umain+0x1fd>
		panic("fork: %e", i);
  80021f:	56                   	push   %esi
  800220:	68 45 24 80 00       	push   $0x802445
  800225:	6a 2f                	push   $0x2f
  800227:	68 35 24 80 00       	push   $0x802435
  80022c:	e8 ef 00 00 00       	call   800320 <_panic>

	if (pid == 0) {
  800231:	85 c0                	test   %eax,%eax
  800233:	75 4a                	jne    80027f <umain+0x24b>
		close(p[0]);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 8c             	pushl  -0x74(%ebp)
  80023b:	e8 e7 11 00 00       	call   801427 <close>
  800240:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	68 f4 24 80 00       	push   $0x8024f4
  80024b:	e8 a8 01 00 00       	call   8003f8 <cprintf>
			if (write(p[1], "x", 1) != 1)
  800250:	83 c4 0c             	add    $0xc,%esp
  800253:	6a 01                	push   $0x1
  800255:	68 f6 24 80 00       	push   $0x8024f6
  80025a:	ff 75 90             	pushl  -0x70(%ebp)
  80025d:	e8 de 13 00 00       	call   801640 <write>
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	83 f8 01             	cmp    $0x1,%eax
  800268:	74 d9                	je     800243 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 f8 24 80 00       	push   $0x8024f8
  800272:	e8 81 01 00 00       	call   8003f8 <cprintf>
		exit();
  800277:	e8 88 00 00 00       	call   800304 <exit>
  80027c:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	ff 75 8c             	pushl  -0x74(%ebp)
  800285:	e8 9d 11 00 00       	call   801427 <close>
	close(p[1]);
  80028a:	83 c4 04             	add    $0x4,%esp
  80028d:	ff 75 90             	pushl  -0x70(%ebp)
  800290:	e8 92 11 00 00       	call   801427 <close>
	wait(pid);
  800295:	89 1c 24             	mov    %ebx,(%esp)
  800298:	e8 ef 1a 00 00       	call   801d8c <wait>

	cprintf("pipe tests passed\n");
  80029d:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  8002a4:	e8 4f 01 00 00       	call   8003f8 <cprintf>
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
  8002bf:	e8 21 0b 00 00       	call   800de5 <sys_getenvid>
  8002c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002d0:	c1 e0 07             	shl    $0x7,%eax
  8002d3:	29 d0                	sub    %edx,%eax
  8002d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002da:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002df:	85 f6                	test   %esi,%esi
  8002e1:	7e 07                	jle    8002ea <libmain+0x36>
		binaryname = argv[0];
  8002e3:	8b 03                	mov    (%ebx),%eax
  8002e5:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	53                   	push   %ebx
  8002ee:	56                   	push   %esi
  8002ef:	e8 40 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002f4:	e8 0b 00 00 00       	call   800304 <exit>
  8002f9:	83 c4 10             	add    $0x10,%esp
}
  8002fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	c9                   	leave  
  800302:	c3                   	ret    
	...

00800304 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80030a:	e8 43 11 00 00       	call   801452 <close_all>
	sys_env_destroy(0);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	6a 00                	push   $0x0
  800314:	e8 aa 0a 00 00       	call   800dc3 <sys_env_destroy>
  800319:	83 c4 10             	add    $0x10,%esp
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    
	...

00800320 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800325:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800328:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80032e:	e8 b2 0a 00 00       	call   800de5 <sys_getenvid>
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	ff 75 0c             	pushl  0xc(%ebp)
  800339:	ff 75 08             	pushl  0x8(%ebp)
  80033c:	53                   	push   %ebx
  80033d:	50                   	push   %eax
  80033e:	68 78 25 80 00       	push   $0x802578
  800343:	e8 b0 00 00 00       	call   8003f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800348:	83 c4 18             	add    $0x18,%esp
  80034b:	56                   	push   %esi
  80034c:	ff 75 10             	pushl  0x10(%ebp)
  80034f:	e8 53 00 00 00       	call   8003a7 <vcprintf>
	cprintf("\n");
  800354:	c7 04 24 19 2b 80 00 	movl   $0x802b19,(%esp)
  80035b:	e8 98 00 00 00       	call   8003f8 <cprintf>
  800360:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800363:	cc                   	int3   
  800364:	eb fd                	jmp    800363 <_panic+0x43>
	...

00800368 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	53                   	push   %ebx
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800372:	8b 03                	mov    (%ebx),%eax
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
  800377:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80037b:	40                   	inc    %eax
  80037c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80037e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800383:	75 1a                	jne    80039f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	68 ff 00 00 00       	push   $0xff
  80038d:	8d 43 08             	lea    0x8(%ebx),%eax
  800390:	50                   	push   %eax
  800391:	e8 e3 09 00 00       	call   800d79 <sys_cputs>
		b->idx = 0;
  800396:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039f:	ff 43 04             	incl   0x4(%ebx)
}
  8003a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    

008003a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b7:	00 00 00 
	b.cnt = 0;
  8003ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c4:	ff 75 0c             	pushl  0xc(%ebp)
  8003c7:	ff 75 08             	pushl  0x8(%ebp)
  8003ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	68 68 03 80 00       	push   $0x800368
  8003d6:	e8 82 01 00 00       	call   80055d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003db:	83 c4 08             	add    $0x8,%esp
  8003de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ea:	50                   	push   %eax
  8003eb:	e8 89 09 00 00       	call   800d79 <sys_cputs>

	return b.cnt;
}
  8003f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800401:	50                   	push   %eax
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	e8 9d ff ff ff       	call   8003a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800418:	89 d6                	mov    %edx,%esi
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800423:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800426:	8b 45 10             	mov    0x10(%ebp),%eax
  800429:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80042c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800432:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800439:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80043c:	72 0c                	jb     80044a <printnum+0x3e>
  80043e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800441:	76 07                	jbe    80044a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800443:	4b                   	dec    %ebx
  800444:	85 db                	test   %ebx,%ebx
  800446:	7f 31                	jg     800479 <printnum+0x6d>
  800448:	eb 3f                	jmp    800489 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	57                   	push   %edi
  80044e:	4b                   	dec    %ebx
  80044f:	53                   	push   %ebx
  800450:	50                   	push   %eax
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 d4             	pushl  -0x2c(%ebp)
  800457:	ff 75 d0             	pushl  -0x30(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 6f 1d 00 00       	call   8021d4 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046f:	e8 98 ff ff ff       	call   80040c <printnum>
  800474:	83 c4 20             	add    $0x20,%esp
  800477:	eb 10                	jmp    800489 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	57                   	push   %edi
  80047e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800481:	4b                   	dec    %ebx
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 db                	test   %ebx,%ebx
  800487:	7f f0                	jg     800479 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	56                   	push   %esi
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	ff 75 d4             	pushl  -0x2c(%ebp)
  800493:	ff 75 d0             	pushl  -0x30(%ebp)
  800496:	ff 75 dc             	pushl  -0x24(%ebp)
  800499:	ff 75 d8             	pushl  -0x28(%ebp)
  80049c:	e8 4f 1e 00 00       	call   8022f0 <__umoddi3>
  8004a1:	83 c4 14             	add    $0x14,%esp
  8004a4:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
  8004ab:	50                   	push   %eax
  8004ac:	ff 55 e4             	call   *-0x1c(%ebp)
  8004af:	83 c4 10             	add    $0x10,%esp
}
  8004b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b5:	5b                   	pop    %ebx
  8004b6:	5e                   	pop    %esi
  8004b7:	5f                   	pop    %edi
  8004b8:	c9                   	leave  
  8004b9:	c3                   	ret    

008004ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bd:	83 fa 01             	cmp    $0x1,%edx
  8004c0:	7e 0e                	jle    8004d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ce:	eb 22                	jmp    8004f2 <getuint+0x38>
	else if (lflag)
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 10                	je     8004e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d9:	89 08                	mov    %ecx,(%eax)
  8004db:	8b 02                	mov    (%edx),%eax
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 0e                	jmp    8004f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f7:	83 fa 01             	cmp    $0x1,%edx
  8004fa:	7e 0e                	jle    80050a <getint+0x16>
		return va_arg(*ap, long long);
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800501:	89 08                	mov    %ecx,(%eax)
  800503:	8b 02                	mov    (%edx),%eax
  800505:	8b 52 04             	mov    0x4(%edx),%edx
  800508:	eb 1a                	jmp    800524 <getint+0x30>
	else if (lflag)
  80050a:	85 d2                	test   %edx,%edx
  80050c:	74 0c                	je     80051a <getint+0x26>
		return va_arg(*ap, long);
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	8d 4a 04             	lea    0x4(%edx),%ecx
  800513:	89 08                	mov    %ecx,(%eax)
  800515:	8b 02                	mov    (%edx),%eax
  800517:	99                   	cltd   
  800518:	eb 0a                	jmp    800524 <getint+0x30>
	else
		return va_arg(*ap, int);
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051f:	89 08                	mov    %ecx,(%eax)
  800521:	8b 02                	mov    (%edx),%eax
  800523:	99                   	cltd   
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80052f:	8b 10                	mov    (%eax),%edx
  800531:	3b 50 04             	cmp    0x4(%eax),%edx
  800534:	73 08                	jae    80053e <sprintputch+0x18>
		*b->buf++ = ch;
  800536:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800539:	88 0a                	mov    %cl,(%edx)
  80053b:	42                   	inc    %edx
  80053c:	89 10                	mov    %edx,(%eax)
}
  80053e:	c9                   	leave  
  80053f:	c3                   	ret    

00800540 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800546:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800549:	50                   	push   %eax
  80054a:	ff 75 10             	pushl  0x10(%ebp)
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	ff 75 08             	pushl  0x8(%ebp)
  800553:	e8 05 00 00 00       	call   80055d <vprintfmt>
	va_end(ap);
  800558:	83 c4 10             	add    $0x10,%esp
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 2c             	sub    $0x2c,%esp
  800566:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800569:	8b 75 10             	mov    0x10(%ebp),%esi
  80056c:	eb 13                	jmp    800581 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056e:	85 c0                	test   %eax,%eax
  800570:	0f 84 6d 03 00 00    	je     8008e3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	57                   	push   %edi
  80057a:	50                   	push   %eax
  80057b:	ff 55 08             	call   *0x8(%ebp)
  80057e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800581:	0f b6 06             	movzbl (%esi),%eax
  800584:	46                   	inc    %esi
  800585:	83 f8 25             	cmp    $0x25,%eax
  800588:	75 e4                	jne    80056e <vprintfmt+0x11>
  80058a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80058e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800595:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80059c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a8:	eb 28                	jmp    8005d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8005b0:	eb 20                	jmp    8005d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005b8:	eb 18                	jmp    8005d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005c3:	eb 0d                	jmp    8005d2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8a 06                	mov    (%esi),%al
  8005d4:	0f b6 d0             	movzbl %al,%edx
  8005d7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005da:	83 e8 23             	sub    $0x23,%eax
  8005dd:	3c 55                	cmp    $0x55,%al
  8005df:	0f 87 e0 02 00 00    	ja     8008c5 <vprintfmt+0x368>
  8005e5:	0f b6 c0             	movzbl %al,%eax
  8005e8:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ef:	83 ea 30             	sub    $0x30,%edx
  8005f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8005f5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8005f8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005fb:	83 fa 09             	cmp    $0x9,%edx
  8005fe:	77 44                	ja     800644 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	89 de                	mov    %ebx,%esi
  800602:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800605:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800606:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800609:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80060d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800610:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800613:	83 fb 09             	cmp    $0x9,%ebx
  800616:	76 ed                	jbe    800605 <vprintfmt+0xa8>
  800618:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80061b:	eb 29                	jmp    800646 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80062d:	eb 17                	jmp    800646 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80062f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800633:	78 85                	js     8005ba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	89 de                	mov    %ebx,%esi
  800637:	eb 99                	jmp    8005d2 <vprintfmt+0x75>
  800639:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80063b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800642:	eb 8e                	jmp    8005d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800646:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064a:	79 86                	jns    8005d2 <vprintfmt+0x75>
  80064c:	e9 74 ff ff ff       	jmp    8005c5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800651:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	89 de                	mov    %ebx,%esi
  800654:	e9 79 ff ff ff       	jmp    8005d2 <vprintfmt+0x75>
  800659:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	57                   	push   %edi
  800669:	ff 30                	pushl  (%eax)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800674:	e9 08 ff ff ff       	jmp    800581 <vprintfmt+0x24>
  800679:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	85 c0                	test   %eax,%eax
  800689:	79 02                	jns    80068d <vprintfmt+0x130>
  80068b:	f7 d8                	neg    %eax
  80068d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068f:	83 f8 0f             	cmp    $0xf,%eax
  800692:	7f 0b                	jg     80069f <vprintfmt+0x142>
  800694:	8b 04 85 40 28 80 00 	mov    0x802840(,%eax,4),%eax
  80069b:	85 c0                	test   %eax,%eax
  80069d:	75 1a                	jne    8006b9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80069f:	52                   	push   %edx
  8006a0:	68 b3 25 80 00       	push   $0x8025b3
  8006a5:	57                   	push   %edi
  8006a6:	ff 75 08             	pushl  0x8(%ebp)
  8006a9:	e8 92 fe ff ff       	call   800540 <printfmt>
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b4:	e9 c8 fe ff ff       	jmp    800581 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8006b9:	50                   	push   %eax
  8006ba:	68 fb 2a 80 00       	push   $0x802afb
  8006bf:	57                   	push   %edi
  8006c0:	ff 75 08             	pushl  0x8(%ebp)
  8006c3:	e8 78 fe ff ff       	call   800540 <printfmt>
  8006c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ce:	e9 ae fe ff ff       	jmp    800581 <vprintfmt+0x24>
  8006d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006d6:	89 de                	mov    %ebx,%esi
  8006d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	75 07                	jne    8006f7 <vprintfmt+0x19a>
				p = "(null)";
  8006f0:	c7 45 d0 ac 25 80 00 	movl   $0x8025ac,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8006f7:	85 db                	test   %ebx,%ebx
  8006f9:	7e 42                	jle    80073d <vprintfmt+0x1e0>
  8006fb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006ff:	74 3c                	je     80073d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	51                   	push   %ecx
  800705:	ff 75 d0             	pushl  -0x30(%ebp)
  800708:	e8 6f 02 00 00       	call   80097c <strnlen>
  80070d:	29 c3                	sub    %eax,%ebx
  80070f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	85 db                	test   %ebx,%ebx
  800717:	7e 24                	jle    80073d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800719:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80071d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800720:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	57                   	push   %edi
  800727:	53                   	push   %ebx
  800728:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	4e                   	dec    %esi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	85 f6                	test   %esi,%esi
  800731:	7f f0                	jg     800723 <vprintfmt+0x1c6>
  800733:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800736:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800740:	0f be 02             	movsbl (%edx),%eax
  800743:	85 c0                	test   %eax,%eax
  800745:	75 47                	jne    80078e <vprintfmt+0x231>
  800747:	eb 37                	jmp    800780 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800749:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80074d:	74 16                	je     800765 <vprintfmt+0x208>
  80074f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800752:	83 fa 5e             	cmp    $0x5e,%edx
  800755:	76 0e                	jbe    800765 <vprintfmt+0x208>
					putch('?', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	57                   	push   %edi
  80075b:	6a 3f                	push   $0x3f
  80075d:	ff 55 08             	call   *0x8(%ebp)
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	eb 0b                	jmp    800770 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	57                   	push   %edi
  800769:	50                   	push   %eax
  80076a:	ff 55 08             	call   *0x8(%ebp)
  80076d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800770:	ff 4d e4             	decl   -0x1c(%ebp)
  800773:	0f be 03             	movsbl (%ebx),%eax
  800776:	85 c0                	test   %eax,%eax
  800778:	74 03                	je     80077d <vprintfmt+0x220>
  80077a:	43                   	inc    %ebx
  80077b:	eb 1b                	jmp    800798 <vprintfmt+0x23b>
  80077d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800780:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800784:	7f 1e                	jg     8007a4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800789:	e9 f3 fd ff ff       	jmp    800581 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800791:	43                   	inc    %ebx
  800792:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800795:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800798:	85 f6                	test   %esi,%esi
  80079a:	78 ad                	js     800749 <vprintfmt+0x1ec>
  80079c:	4e                   	dec    %esi
  80079d:	79 aa                	jns    800749 <vprintfmt+0x1ec>
  80079f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007a2:	eb dc                	jmp    800780 <vprintfmt+0x223>
  8007a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	57                   	push   %edi
  8007ab:	6a 20                	push   $0x20
  8007ad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b0:	4b                   	dec    %ebx
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	85 db                	test   %ebx,%ebx
  8007b6:	7f ef                	jg     8007a7 <vprintfmt+0x24a>
  8007b8:	e9 c4 fd ff ff       	jmp    800581 <vprintfmt+0x24>
  8007bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c0:	89 ca                	mov    %ecx,%edx
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 2a fd ff ff       	call   8004f4 <getint>
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	78 0a                	js     8007dc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d7:	e9 b0 00 00 00       	jmp    80088c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	57                   	push   %edi
  8007e0:	6a 2d                	push   $0x2d
  8007e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007e5:	f7 db                	neg    %ebx
  8007e7:	83 d6 00             	adc    $0x0,%esi
  8007ea:	f7 de                	neg    %esi
  8007ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f4:	e9 93 00 00 00       	jmp    80088c <vprintfmt+0x32f>
  8007f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007fc:	89 ca                	mov    %ecx,%edx
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	e8 b4 fc ff ff       	call   8004ba <getuint>
  800806:	89 c3                	mov    %eax,%ebx
  800808:	89 d6                	mov    %edx,%esi
			base = 10;
  80080a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80080f:	eb 7b                	jmp    80088c <vprintfmt+0x32f>
  800811:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800814:	89 ca                	mov    %ecx,%edx
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 d6 fc ff ff       	call   8004f4 <getint>
  80081e:	89 c3                	mov    %eax,%ebx
  800820:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800822:	85 d2                	test   %edx,%edx
  800824:	78 07                	js     80082d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800826:	b8 08 00 00 00       	mov    $0x8,%eax
  80082b:	eb 5f                	jmp    80088c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	57                   	push   %edi
  800831:	6a 2d                	push   $0x2d
  800833:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800836:	f7 db                	neg    %ebx
  800838:	83 d6 00             	adc    $0x0,%esi
  80083b:	f7 de                	neg    %esi
  80083d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800840:	b8 08 00 00 00       	mov    $0x8,%eax
  800845:	eb 45                	jmp    80088c <vprintfmt+0x32f>
  800847:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	57                   	push   %edi
  80084e:	6a 30                	push   $0x30
  800850:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	57                   	push   %edi
  800857:	6a 78                	push   $0x78
  800859:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800865:	8b 18                	mov    (%eax),%ebx
  800867:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800874:	eb 16                	jmp    80088c <vprintfmt+0x32f>
  800876:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800879:	89 ca                	mov    %ecx,%edx
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	e8 37 fc ff ff       	call   8004ba <getuint>
  800883:	89 c3                	mov    %eax,%ebx
  800885:	89 d6                	mov    %edx,%esi
			base = 16;
  800887:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088c:	83 ec 0c             	sub    $0xc,%esp
  80088f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800893:	52                   	push   %edx
  800894:	ff 75 e4             	pushl  -0x1c(%ebp)
  800897:	50                   	push   %eax
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	89 fa                	mov    %edi,%edx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	e8 68 fb ff ff       	call   80040c <printnum>
			break;
  8008a4:	83 c4 20             	add    $0x20,%esp
  8008a7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008aa:	e9 d2 fc ff ff       	jmp    800581 <vprintfmt+0x24>
  8008af:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	57                   	push   %edi
  8008b6:	52                   	push   %edx
  8008b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c0:	e9 bc fc ff ff       	jmp    800581 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	57                   	push   %edi
  8008c9:	6a 25                	push   $0x25
  8008cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	eb 02                	jmp    8008d5 <vprintfmt+0x378>
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8008d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008dc:	75 f5                	jne    8008d3 <vprintfmt+0x376>
  8008de:	e9 9e fc ff ff       	jmp    800581 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8008e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 18             	sub    $0x18,%esp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800901:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800908:	85 c0                	test   %eax,%eax
  80090a:	74 26                	je     800932 <vsnprintf+0x47>
  80090c:	85 d2                	test   %edx,%edx
  80090e:	7e 29                	jle    800939 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800910:	ff 75 14             	pushl  0x14(%ebp)
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800919:	50                   	push   %eax
  80091a:	68 26 05 80 00       	push   $0x800526
  80091f:	e8 39 fc ff ff       	call   80055d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800924:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800927:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	eb 0c                	jmp    80093e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800937:	eb 05                	jmp    80093e <vsnprintf+0x53>
  800939:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800946:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800949:	50                   	push   %eax
  80094a:	ff 75 10             	pushl  0x10(%ebp)
  80094d:	ff 75 0c             	pushl  0xc(%ebp)
  800950:	ff 75 08             	pushl  0x8(%ebp)
  800953:	e8 93 ff ff ff       	call   8008eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    
	...

0080095c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800962:	80 3a 00             	cmpb   $0x0,(%edx)
  800965:	74 0e                	je     800975 <strlen+0x19>
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80096c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800971:	75 f9                	jne    80096c <strlen+0x10>
  800973:	eb 05                	jmp    80097a <strlen+0x1e>
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	85 d2                	test   %edx,%edx
  800987:	74 17                	je     8009a0 <strnlen+0x24>
  800989:	80 39 00             	cmpb   $0x0,(%ecx)
  80098c:	74 19                	je     8009a7 <strnlen+0x2b>
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800993:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800994:	39 d0                	cmp    %edx,%eax
  800996:	74 14                	je     8009ac <strnlen+0x30>
  800998:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80099c:	75 f5                	jne    800993 <strnlen+0x17>
  80099e:	eb 0c                	jmp    8009ac <strnlen+0x30>
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a5:	eb 05                	jmp    8009ac <strnlen+0x30>
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009c0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c3:	42                   	inc    %edx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	75 f5                	jne    8009bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d2:	53                   	push   %ebx
  8009d3:	e8 84 ff ff ff       	call   80095c <strlen>
  8009d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009e1:	50                   	push   %eax
  8009e2:	e8 c7 ff ff ff       	call   8009ae <strcpy>
	return dst;
}
  8009e7:	89 d8                	mov    %ebx,%eax
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fc:	85 f6                	test   %esi,%esi
  8009fe:	74 15                	je     800a15 <strncpy+0x27>
  800a00:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a05:	8a 1a                	mov    (%edx),%bl
  800a07:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0a:	80 3a 01             	cmpb   $0x1,(%edx)
  800a0d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a10:	41                   	inc    %ecx
  800a11:	39 ce                	cmp    %ecx,%esi
  800a13:	77 f0                	ja     800a05 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a25:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a28:	85 f6                	test   %esi,%esi
  800a2a:	74 32                	je     800a5e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a2c:	83 fe 01             	cmp    $0x1,%esi
  800a2f:	74 22                	je     800a53 <strlcpy+0x3a>
  800a31:	8a 0b                	mov    (%ebx),%cl
  800a33:	84 c9                	test   %cl,%cl
  800a35:	74 20                	je     800a57 <strlcpy+0x3e>
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a3e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a41:	88 08                	mov    %cl,(%eax)
  800a43:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a44:	39 f2                	cmp    %esi,%edx
  800a46:	74 11                	je     800a59 <strlcpy+0x40>
  800a48:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800a4c:	42                   	inc    %edx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	75 f0                	jne    800a41 <strlcpy+0x28>
  800a51:	eb 06                	jmp    800a59 <strlcpy+0x40>
  800a53:	89 f8                	mov    %edi,%eax
  800a55:	eb 02                	jmp    800a59 <strlcpy+0x40>
  800a57:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a59:	c6 00 00             	movb   $0x0,(%eax)
  800a5c:	eb 02                	jmp    800a60 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800a60:	29 f8                	sub    %edi,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a70:	8a 01                	mov    (%ecx),%al
  800a72:	84 c0                	test   %al,%al
  800a74:	74 10                	je     800a86 <strcmp+0x1f>
  800a76:	3a 02                	cmp    (%edx),%al
  800a78:	75 0c                	jne    800a86 <strcmp+0x1f>
		p++, q++;
  800a7a:	41                   	inc    %ecx
  800a7b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7c:	8a 01                	mov    (%ecx),%al
  800a7e:	84 c0                	test   %al,%al
  800a80:	74 04                	je     800a86 <strcmp+0x1f>
  800a82:	3a 02                	cmp    (%edx),%al
  800a84:	74 f4                	je     800a7a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	74 1b                	je     800abc <strncmp+0x2c>
  800aa1:	8a 1a                	mov    (%edx),%bl
  800aa3:	84 db                	test   %bl,%bl
  800aa5:	74 24                	je     800acb <strncmp+0x3b>
  800aa7:	3a 19                	cmp    (%ecx),%bl
  800aa9:	75 20                	jne    800acb <strncmp+0x3b>
  800aab:	48                   	dec    %eax
  800aac:	74 15                	je     800ac3 <strncmp+0x33>
		n--, p++, q++;
  800aae:	42                   	inc    %edx
  800aaf:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab0:	8a 1a                	mov    (%edx),%bl
  800ab2:	84 db                	test   %bl,%bl
  800ab4:	74 15                	je     800acb <strncmp+0x3b>
  800ab6:	3a 19                	cmp    (%ecx),%bl
  800ab8:	74 f1                	je     800aab <strncmp+0x1b>
  800aba:	eb 0f                	jmp    800acb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	eb 05                	jmp    800ac8 <strncmp+0x38>
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acb:	0f b6 02             	movzbl (%edx),%eax
  800ace:	0f b6 11             	movzbl (%ecx),%edx
  800ad1:	29 d0                	sub    %edx,%eax
  800ad3:	eb f3                	jmp    800ac8 <strncmp+0x38>

00800ad5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ade:	8a 10                	mov    (%eax),%dl
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	74 18                	je     800afc <strchr+0x27>
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	75 06                	jne    800aee <strchr+0x19>
  800ae8:	eb 17                	jmp    800b01 <strchr+0x2c>
  800aea:	38 ca                	cmp    %cl,%dl
  800aec:	74 13                	je     800b01 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aee:	40                   	inc    %eax
  800aef:	8a 10                	mov    (%eax),%dl
  800af1:	84 d2                	test   %dl,%dl
  800af3:	75 f5                	jne    800aea <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	eb 05                	jmp    800b01 <strchr+0x2c>
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b0c:	8a 10                	mov    (%eax),%dl
  800b0e:	84 d2                	test   %dl,%dl
  800b10:	74 11                	je     800b23 <strfind+0x20>
		if (*s == c)
  800b12:	38 ca                	cmp    %cl,%dl
  800b14:	75 06                	jne    800b1c <strfind+0x19>
  800b16:	eb 0b                	jmp    800b23 <strfind+0x20>
  800b18:	38 ca                	cmp    %cl,%dl
  800b1a:	74 07                	je     800b23 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1c:	40                   	inc    %eax
  800b1d:	8a 10                	mov    (%eax),%dl
  800b1f:	84 d2                	test   %dl,%dl
  800b21:	75 f5                	jne    800b18 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b34:	85 c9                	test   %ecx,%ecx
  800b36:	74 30                	je     800b68 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b38:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3e:	75 25                	jne    800b65 <memset+0x40>
  800b40:	f6 c1 03             	test   $0x3,%cl
  800b43:	75 20                	jne    800b65 <memset+0x40>
		c &= 0xFF;
  800b45:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	c1 e3 08             	shl    $0x8,%ebx
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	c1 e6 18             	shl    $0x18,%esi
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e0 10             	shl    $0x10,%eax
  800b57:	09 f0                	or     %esi,%eax
  800b59:	09 d0                	or     %edx,%eax
  800b5b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b60:	fc                   	cld    
  800b61:	f3 ab                	rep stos %eax,%es:(%edi)
  800b63:	eb 03                	jmp    800b68 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b65:	fc                   	cld    
  800b66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b68:	89 f8                	mov    %edi,%eax
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7d:	39 c6                	cmp    %eax,%esi
  800b7f:	73 34                	jae    800bb5 <memmove+0x46>
  800b81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b84:	39 d0                	cmp    %edx,%eax
  800b86:	73 2d                	jae    800bb5 <memmove+0x46>
		s += n;
		d += n;
  800b88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8b:	f6 c2 03             	test   $0x3,%dl
  800b8e:	75 1b                	jne    800bab <memmove+0x3c>
  800b90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b96:	75 13                	jne    800bab <memmove+0x3c>
  800b98:	f6 c1 03             	test   $0x3,%cl
  800b9b:	75 0e                	jne    800bab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9d:	83 ef 04             	sub    $0x4,%edi
  800ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 07                	jmp    800bb2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bab:	4f                   	dec    %edi
  800bac:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800baf:	fd                   	std    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb2:	fc                   	cld    
  800bb3:	eb 20                	jmp    800bd5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbb:	75 13                	jne    800bd0 <memmove+0x61>
  800bbd:	a8 03                	test   $0x3,%al
  800bbf:	75 0f                	jne    800bd0 <memmove+0x61>
  800bc1:	f6 c1 03             	test   $0x3,%cl
  800bc4:	75 0a                	jne    800bd0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	fc                   	cld    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb 05                	jmp    800bd5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	fc                   	cld    
  800bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdc:	ff 75 10             	pushl  0x10(%ebp)
  800bdf:	ff 75 0c             	pushl  0xc(%ebp)
  800be2:	ff 75 08             	pushl  0x8(%ebp)
  800be5:	e8 85 ff ff ff       	call   800b6f <memmove>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	74 32                	je     800c31 <memcmp+0x45>
		if (*s1 != *s2)
  800bff:	8a 03                	mov    (%ebx),%al
  800c01:	8a 0e                	mov    (%esi),%cl
  800c03:	38 c8                	cmp    %cl,%al
  800c05:	74 19                	je     800c20 <memcmp+0x34>
  800c07:	eb 0d                	jmp    800c16 <memcmp+0x2a>
  800c09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800c0d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800c11:	42                   	inc    %edx
  800c12:	38 c8                	cmp    %cl,%al
  800c14:	74 10                	je     800c26 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800c16:	0f b6 c0             	movzbl %al,%eax
  800c19:	0f b6 c9             	movzbl %cl,%ecx
  800c1c:	29 c8                	sub    %ecx,%eax
  800c1e:	eb 16                	jmp    800c36 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c20:	4f                   	dec    %edi
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	39 fa                	cmp    %edi,%edx
  800c28:	75 df                	jne    800c09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2f:	eb 05                	jmp    800c36 <memcmp+0x4a>
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c41:	89 c2                	mov    %eax,%edx
  800c43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c46:	39 d0                	cmp    %edx,%eax
  800c48:	73 12                	jae    800c5c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c4d:	38 08                	cmp    %cl,(%eax)
  800c4f:	75 06                	jne    800c57 <memfind+0x1c>
  800c51:	eb 09                	jmp    800c5c <memfind+0x21>
  800c53:	38 08                	cmp    %cl,(%eax)
  800c55:	74 05                	je     800c5c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c57:	40                   	inc    %eax
  800c58:	39 c2                	cmp    %eax,%edx
  800c5a:	77 f7                	ja     800c53 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	eb 01                	jmp    800c6d <strtol+0xf>
		s++;
  800c6c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6d:	8a 02                	mov    (%edx),%al
  800c6f:	3c 20                	cmp    $0x20,%al
  800c71:	74 f9                	je     800c6c <strtol+0xe>
  800c73:	3c 09                	cmp    $0x9,%al
  800c75:	74 f5                	je     800c6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c77:	3c 2b                	cmp    $0x2b,%al
  800c79:	75 08                	jne    800c83 <strtol+0x25>
		s++;
  800c7b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c81:	eb 13                	jmp    800c96 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c83:	3c 2d                	cmp    $0x2d,%al
  800c85:	75 0a                	jne    800c91 <strtol+0x33>
		s++, neg = 1;
  800c87:	8d 52 01             	lea    0x1(%edx),%edx
  800c8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c8f:	eb 05                	jmp    800c96 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c96:	85 db                	test   %ebx,%ebx
  800c98:	74 05                	je     800c9f <strtol+0x41>
  800c9a:	83 fb 10             	cmp    $0x10,%ebx
  800c9d:	75 28                	jne    800cc7 <strtol+0x69>
  800c9f:	8a 02                	mov    (%edx),%al
  800ca1:	3c 30                	cmp    $0x30,%al
  800ca3:	75 10                	jne    800cb5 <strtol+0x57>
  800ca5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca9:	75 0a                	jne    800cb5 <strtol+0x57>
		s += 2, base = 16;
  800cab:	83 c2 02             	add    $0x2,%edx
  800cae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cb3:	eb 12                	jmp    800cc7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	75 0e                	jne    800cc7 <strtol+0x69>
  800cb9:	3c 30                	cmp    $0x30,%al
  800cbb:	75 05                	jne    800cc2 <strtol+0x64>
		s++, base = 8;
  800cbd:	42                   	inc    %edx
  800cbe:	b3 08                	mov    $0x8,%bl
  800cc0:	eb 05                	jmp    800cc7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cce:	8a 0a                	mov    (%edx),%cl
  800cd0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cd3:	80 fb 09             	cmp    $0x9,%bl
  800cd6:	77 08                	ja     800ce0 <strtol+0x82>
			dig = *s - '0';
  800cd8:	0f be c9             	movsbl %cl,%ecx
  800cdb:	83 e9 30             	sub    $0x30,%ecx
  800cde:	eb 1e                	jmp    800cfe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ce0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ce3:	80 fb 19             	cmp    $0x19,%bl
  800ce6:	77 08                	ja     800cf0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ce8:	0f be c9             	movsbl %cl,%ecx
  800ceb:	83 e9 57             	sub    $0x57,%ecx
  800cee:	eb 0e                	jmp    800cfe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cf0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cf3:	80 fb 19             	cmp    $0x19,%bl
  800cf6:	77 13                	ja     800d0b <strtol+0xad>
			dig = *s - 'A' + 10;
  800cf8:	0f be c9             	movsbl %cl,%ecx
  800cfb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cfe:	39 f1                	cmp    %esi,%ecx
  800d00:	7d 0d                	jge    800d0f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800d02:	42                   	inc    %edx
  800d03:	0f af c6             	imul   %esi,%eax
  800d06:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d09:	eb c3                	jmp    800cce <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d0b:	89 c1                	mov    %eax,%ecx
  800d0d:	eb 02                	jmp    800d11 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d0f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d15:	74 05                	je     800d1c <strtol+0xbe>
		*endptr = (char *) s;
  800d17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d1a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d1c:	85 ff                	test   %edi,%edi
  800d1e:	74 04                	je     800d24 <strtol+0xc6>
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	f7 d8                	neg    %eax
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    
  800d29:	00 00                	add    %al,(%eax)
	...

00800d2c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 1c             	sub    $0x1c,%esp
  800d35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d38:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d3b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800d40:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d49:	cd 30                	int    $0x30
  800d4b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d51:	74 1c                	je     800d6f <syscall+0x43>
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 18                	jle    800d6f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d5e:	68 9f 28 80 00       	push   $0x80289f
  800d63:	6a 42                	push   $0x42
  800d65:	68 bc 28 80 00       	push   $0x8028bc
  800d6a:	e8 b1 f5 ff ff       	call   800320 <_panic>

	return ret;
}
  800d6f:	89 d0                	mov    %edx,%eax
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d7f:	6a 00                	push   $0x0
  800d81:	6a 00                	push   $0x0
  800d83:	6a 00                	push   $0x0
  800d85:	ff 75 0c             	pushl  0xc(%ebp)
  800d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d90:	b8 00 00 00 00       	mov    $0x0,%eax
  800d95:	e8 92 ff ff ff       	call   800d2c <syscall>
  800d9a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800da5:	6a 00                	push   $0x0
  800da7:	6a 00                	push   $0x0
  800da9:	6a 00                	push   $0x0
  800dab:	6a 00                	push   $0x0
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbc:	e8 6b ff ff ff       	call   800d2c <syscall>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	6a 00                	push   $0x0
  800dcf:	6a 00                	push   $0x0
  800dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd4:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dde:	e8 49 ff ff ff       	call   800d2c <syscall>
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfd:	b8 02 00 00 00       	mov    $0x2,%eax
  800e02:	e8 25 ff ff ff       	call   800d2c <syscall>
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <sys_yield>:

void
sys_yield(void)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	6a 00                	push   $0x0
  800e15:	6a 00                	push   $0x0
  800e17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e26:	e8 01 ff ff ff       	call   800d2c <syscall>
  800e2b:	83 c4 10             	add    $0x10,%esp
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e36:	6a 00                	push   $0x0
  800e38:	6a 00                	push   $0x0
  800e3a:	ff 75 10             	pushl  0x10(%ebp)
  800e3d:	ff 75 0c             	pushl  0xc(%ebp)
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	ba 01 00 00 00       	mov    $0x1,%edx
  800e48:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4d:	e8 da fe ff ff       	call   800d2c <syscall>
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e5a:	ff 75 18             	pushl  0x18(%ebp)
  800e5d:	ff 75 14             	pushl  0x14(%ebp)
  800e60:	ff 75 10             	pushl  0x10(%ebp)
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e69:	ba 01 00 00 00       	mov    $0x1,%edx
  800e6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e73:	e8 b4 fe ff ff       	call   800d2c <syscall>
}
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e80:	6a 00                	push   $0x0
  800e82:	6a 00                	push   $0x0
  800e84:	6a 00                	push   $0x0
  800e86:	ff 75 0c             	pushl  0xc(%ebp)
  800e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e91:	b8 06 00 00 00       	mov    $0x6,%eax
  800e96:	e8 91 fe ff ff       	call   800d2c <syscall>
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ea3:	6a 00                	push   $0x0
  800ea5:	6a 00                	push   $0x0
  800ea7:	6a 00                	push   $0x0
  800ea9:	ff 75 0c             	pushl  0xc(%ebp)
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb9:	e8 6e fe ff ff       	call   800d2c <syscall>
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ec6:	6a 00                	push   $0x0
  800ec8:	6a 00                	push   $0x0
  800eca:	6a 00                	push   $0x0
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed7:	b8 09 00 00 00       	mov    $0x9,%eax
  800edc:	e8 4b fe ff ff       	call   800d2c <syscall>
}
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ee9:	6a 00                	push   $0x0
  800eeb:	6a 00                	push   $0x0
  800eed:	6a 00                	push   $0x0
  800eef:	ff 75 0c             	pushl  0xc(%ebp)
  800ef2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef5:	ba 01 00 00 00       	mov    $0x1,%edx
  800efa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eff:	e8 28 fe ff ff       	call   800d2c <syscall>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f0c:	6a 00                	push   $0x0
  800f0e:	ff 75 14             	pushl  0x14(%ebp)
  800f11:	ff 75 10             	pushl  0x10(%ebp)
  800f14:	ff 75 0c             	pushl  0xc(%ebp)
  800f17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f24:	e8 03 fe ff ff       	call   800d2c <syscall>
}
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f31:	6a 00                	push   $0x0
  800f33:	6a 00                	push   $0x0
  800f35:	6a 00                	push   $0x0
  800f37:	6a 00                	push   $0x0
  800f39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f46:	e8 e1 fd ff ff       	call   800d2c <syscall>
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800f53:	6a 00                	push   $0x0
  800f55:	6a 00                	push   $0x0
  800f57:	6a 00                	push   $0x0
  800f59:	ff 75 0c             	pushl  0xc(%ebp)
  800f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f64:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f69:	e8 be fd ff ff       	call   800d2c <syscall>
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	53                   	push   %ebx
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f7a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800f7c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f80:	75 14                	jne    800f96 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 cc 28 80 00       	push   $0x8028cc
  800f8a:	6a 20                	push   $0x20
  800f8c:	68 10 2a 80 00       	push   $0x802a10
  800f91:	e8 8a f3 ff ff       	call   800320 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	c1 e8 16             	shr    $0x16,%eax
  800f9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa2:	a8 01                	test   $0x1,%al
  800fa4:	74 11                	je     800fb7 <pgfault+0x47>
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	c1 e8 0c             	shr    $0xc,%eax
  800fab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb2:	f6 c4 08             	test   $0x8,%ah
  800fb5:	75 14                	jne    800fcb <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	68 f0 28 80 00       	push   $0x8028f0
  800fbf:	6a 24                	push   $0x24
  800fc1:	68 10 2a 80 00       	push   $0x802a10
  800fc6:	e8 55 f3 ff ff       	call   800320 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	6a 07                	push   $0x7
  800fd0:	68 00 f0 7f 00       	push   $0x7ff000
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 54 fe ff ff       	call   800e30 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 12                	jns    800ff5 <pgfault+0x85>
  800fe3:	50                   	push   %eax
  800fe4:	68 14 29 80 00       	push   $0x802914
  800fe9:	6a 32                	push   $0x32
  800feb:	68 10 2a 80 00       	push   $0x802a10
  800ff0:	e8 2b f3 ff ff       	call   800320 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800ff5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	68 00 10 00 00       	push   $0x1000
  801003:	53                   	push   %ebx
  801004:	68 00 f0 7f 00       	push   $0x7ff000
  801009:	e8 cb fb ff ff       	call   800bd9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  80100e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801015:	53                   	push   %ebx
  801016:	6a 00                	push   $0x0
  801018:	68 00 f0 7f 00       	push   $0x7ff000
  80101d:	6a 00                	push   $0x0
  80101f:	e8 30 fe ff ff       	call   800e54 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 12                	jns    80103d <pgfault+0xcd>
  80102b:	50                   	push   %eax
  80102c:	68 38 29 80 00       	push   $0x802938
  801031:	6a 3a                	push   $0x3a
  801033:	68 10 2a 80 00       	push   $0x802a10
  801038:	e8 e3 f2 ff ff       	call   800320 <_panic>

	return;
}
  80103d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80104b:	68 70 0f 80 00       	push   $0x800f70
  801050:	e8 4f 0f 00 00       	call   801fa4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801055:	ba 07 00 00 00       	mov    $0x7,%edx
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	cd 30                	int    $0x30
  80105e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801061:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	79 12                	jns    80107c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  80106a:	50                   	push   %eax
  80106b:	68 1b 2a 80 00       	push   $0x802a1b
  801070:	6a 7b                	push   $0x7b
  801072:	68 10 2a 80 00       	push   $0x802a10
  801077:	e8 a4 f2 ff ff       	call   800320 <_panic>
	}
	int r;

	if (childpid == 0) {
  80107c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801080:	75 25                	jne    8010a7 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  801082:	e8 5e fd ff ff       	call   800de5 <sys_getenvid>
  801087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801093:	c1 e0 07             	shl    $0x7,%eax
  801096:	29 d0                	sub    %edx,%eax
  801098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109d:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  8010a2:	e9 7b 01 00 00       	jmp    801222 <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	c1 e8 16             	shr    $0x16,%eax
  8010b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b8:	a8 01                	test   $0x1,%al
  8010ba:	0f 84 cd 00 00 00    	je     80118d <fork+0x14b>
  8010c0:	89 d8                	mov    %ebx,%eax
  8010c2:	c1 e8 0c             	shr    $0xc,%eax
  8010c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	0f 84 b8 00 00 00    	je     80118d <fork+0x14b>
  8010d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010dc:	f6 c2 04             	test   $0x4,%dl
  8010df:	0f 84 a8 00 00 00    	je     80118d <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8010e5:	89 c6                	mov    %eax,%esi
  8010e7:	c1 e6 0c             	shl    $0xc,%esi
  8010ea:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8010f0:	0f 84 97 00 00 00    	je     80118d <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010f6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010fd:	f6 c2 02             	test   $0x2,%dl
  801100:	75 0c                	jne    80110e <fork+0xcc>
  801102:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801109:	f6 c4 08             	test   $0x8,%ah
  80110c:	74 57                	je     801165 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	68 05 08 00 00       	push   $0x805
  801116:	56                   	push   %esi
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	6a 00                	push   $0x0
  80111b:	e8 34 fd ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801120:	83 c4 20             	add    $0x20,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	79 12                	jns    801139 <fork+0xf7>
  801127:	50                   	push   %eax
  801128:	68 5c 29 80 00       	push   $0x80295c
  80112d:	6a 55                	push   $0x55
  80112f:	68 10 2a 80 00       	push   $0x802a10
  801134:	e8 e7 f1 ff ff       	call   800320 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801139:	83 ec 0c             	sub    $0xc,%esp
  80113c:	68 05 08 00 00       	push   $0x805
  801141:	56                   	push   %esi
  801142:	6a 00                	push   $0x0
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 08 fd ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 3a                	jns    80118d <fork+0x14b>
  801153:	50                   	push   %eax
  801154:	68 5c 29 80 00       	push   $0x80295c
  801159:	6a 58                	push   $0x58
  80115b:	68 10 2a 80 00       	push   $0x802a10
  801160:	e8 bb f1 ff ff       	call   800320 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	6a 05                	push   $0x5
  80116a:	56                   	push   %esi
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	6a 00                	push   $0x0
  80116f:	e8 e0 fc ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801174:	83 c4 20             	add    $0x20,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	79 12                	jns    80118d <fork+0x14b>
  80117b:	50                   	push   %eax
  80117c:	68 5c 29 80 00       	push   $0x80295c
  801181:	6a 5c                	push   $0x5c
  801183:	68 10 2a 80 00       	push   $0x802a10
  801188:	e8 93 f1 ff ff       	call   800320 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80118d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801193:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801199:	0f 85 0d ff ff ff    	jne    8010ac <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	6a 07                	push   $0x7
  8011a4:	68 00 f0 bf ee       	push   $0xeebff000
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	e8 7f fc ff ff       	call   800e30 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	79 15                	jns    8011cd <fork+0x18b>
  8011b8:	50                   	push   %eax
  8011b9:	68 80 29 80 00       	push   $0x802980
  8011be:	68 90 00 00 00       	push   $0x90
  8011c3:	68 10 2a 80 00       	push   $0x802a10
  8011c8:	e8 53 f1 ff ff       	call   800320 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	68 10 20 80 00       	push   $0x802010
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	e8 06 fd ff ff       	call   800ee3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 15                	jns    8011f9 <fork+0x1b7>
  8011e4:	50                   	push   %eax
  8011e5:	68 b8 29 80 00       	push   $0x8029b8
  8011ea:	68 95 00 00 00       	push   $0x95
  8011ef:	68 10 2a 80 00       	push   $0x802a10
  8011f4:	e8 27 f1 ff ff       	call   800320 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	6a 02                	push   $0x2
  8011fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801201:	e8 97 fc ff ff       	call   800e9d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	79 15                	jns    801222 <fork+0x1e0>
  80120d:	50                   	push   %eax
  80120e:	68 dc 29 80 00       	push   $0x8029dc
  801213:	68 a0 00 00 00       	push   $0xa0
  801218:	68 10 2a 80 00       	push   $0x802a10
  80121d:	e8 fe f0 ff ff       	call   800320 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <sfork>:

// Challenge!
int
sfork(void)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801233:	68 38 2a 80 00       	push   $0x802a38
  801238:	68 ad 00 00 00       	push   $0xad
  80123d:	68 10 2a 80 00       	push   $0x802a10
  801242:	e8 d9 f0 ff ff       	call   800320 <_panic>
	...

00801248 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	05 00 00 00 30       	add    $0x30000000,%eax
  801253:	c1 e8 0c             	shr    $0xc,%eax
}
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 e5 ff ff ff       	call   801248 <fd2num>
  801263:	83 c4 04             	add    $0x4,%esp
  801266:	05 20 00 0d 00       	add    $0xd0020,%eax
  80126b:	c1 e0 0c             	shl    $0xc,%eax
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	53                   	push   %ebx
  801274:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801277:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80127c:	a8 01                	test   $0x1,%al
  80127e:	74 34                	je     8012b4 <fd_alloc+0x44>
  801280:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801285:	a8 01                	test   $0x1,%al
  801287:	74 32                	je     8012bb <fd_alloc+0x4b>
  801289:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80128e:	89 c1                	mov    %eax,%ecx
  801290:	89 c2                	mov    %eax,%edx
  801292:	c1 ea 16             	shr    $0x16,%edx
  801295:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129c:	f6 c2 01             	test   $0x1,%dl
  80129f:	74 1f                	je     8012c0 <fd_alloc+0x50>
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	c1 ea 0c             	shr    $0xc,%edx
  8012a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ad:	f6 c2 01             	test   $0x1,%dl
  8012b0:	75 17                	jne    8012c9 <fd_alloc+0x59>
  8012b2:	eb 0c                	jmp    8012c0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012b4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012b9:	eb 05                	jmp    8012c0 <fd_alloc+0x50>
  8012bb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012c0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 17                	jmp    8012e0 <fd_alloc+0x70>
  8012c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d3:	75 b9                	jne    80128e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e0:	5b                   	pop    %ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e9:	83 f8 1f             	cmp    $0x1f,%eax
  8012ec:	77 36                	ja     801324 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ee:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012f3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f6:	89 c2                	mov    %eax,%edx
  8012f8:	c1 ea 16             	shr    $0x16,%edx
  8012fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	74 24                	je     80132b <fd_lookup+0x48>
  801307:	89 c2                	mov    %eax,%edx
  801309:	c1 ea 0c             	shr    $0xc,%edx
  80130c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801313:	f6 c2 01             	test   $0x1,%dl
  801316:	74 1a                	je     801332 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131b:	89 02                	mov    %eax,(%edx)
	return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 13                	jmp    801337 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801329:	eb 0c                	jmp    801337 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801330:	eb 05                	jmp    801337 <fd_lookup+0x54>
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	53                   	push   %ebx
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801346:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  80134c:	74 0d                	je     80135b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
  801353:	eb 14                	jmp    801369 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801355:	39 0a                	cmp    %ecx,(%edx)
  801357:	75 10                	jne    801369 <dev_lookup+0x30>
  801359:	eb 05                	jmp    801360 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135b:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801360:	89 13                	mov    %edx,(%ebx)
			return 0;
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	eb 31                	jmp    80139a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801369:	40                   	inc    %eax
  80136a:	8b 14 85 cc 2a 80 00 	mov    0x802acc(,%eax,4),%edx
  801371:	85 d2                	test   %edx,%edx
  801373:	75 e0                	jne    801355 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801375:	a1 04 40 80 00       	mov    0x804004,%eax
  80137a:	8b 40 48             	mov    0x48(%eax),%eax
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	51                   	push   %ecx
  801381:	50                   	push   %eax
  801382:	68 50 2a 80 00       	push   $0x802a50
  801387:	e8 6c f0 ff ff       	call   8003f8 <cprintf>
	*dev = 0;
  80138c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 20             	sub    $0x20,%esp
  8013a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8013aa:	8a 45 0c             	mov    0xc(%ebp),%al
  8013ad:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b0:	56                   	push   %esi
  8013b1:	e8 92 fe ff ff       	call   801248 <fd2num>
  8013b6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013b9:	89 14 24             	mov    %edx,(%esp)
  8013bc:	50                   	push   %eax
  8013bd:	e8 21 ff ff ff       	call   8012e3 <fd_lookup>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 05                	js     8013d0 <fd_close+0x31>
	    || fd != fd2)
  8013cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ce:	74 0d                	je     8013dd <fd_close+0x3e>
		return (must_exist ? r : 0);
  8013d0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013d4:	75 48                	jne    80141e <fd_close+0x7f>
  8013d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013db:	eb 41                	jmp    80141e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 36                	pushl  (%esi)
  8013e6:	e8 4e ff ff ff       	call   801339 <dev_lookup>
  8013eb:	89 c3                	mov    %eax,%ebx
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 1c                	js     801410 <fd_close+0x71>
		if (dev->dev_close)
  8013f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f7:	8b 40 10             	mov    0x10(%eax),%eax
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 0d                	je     80140b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	56                   	push   %esi
  801402:	ff d0                	call   *%eax
  801404:	89 c3                	mov    %eax,%ebx
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	eb 05                	jmp    801410 <fd_close+0x71>
		else
			r = 0;
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	56                   	push   %esi
  801414:	6a 00                	push   $0x0
  801416:	e8 5f fa ff ff       	call   800e7a <sys_page_unmap>
	return r;
  80141b:	83 c4 10             	add    $0x10,%esp
}
  80141e:	89 d8                	mov    %ebx,%eax
  801420:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	ff 75 08             	pushl  0x8(%ebp)
  801434:	e8 aa fe ff ff       	call   8012e3 <fd_lookup>
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 10                	js     801450 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	6a 01                	push   $0x1
  801445:	ff 75 f4             	pushl  -0xc(%ebp)
  801448:	e8 52 ff ff ff       	call   80139f <fd_close>
  80144d:	83 c4 10             	add    $0x10,%esp
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <close_all>:

void
close_all(void)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	53                   	push   %ebx
  801456:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801459:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	53                   	push   %ebx
  801462:	e8 c0 ff ff ff       	call   801427 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801467:	43                   	inc    %ebx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	83 fb 20             	cmp    $0x20,%ebx
  80146e:	75 ee                	jne    80145e <close_all+0xc>
		close(i);
}
  801470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 2c             	sub    $0x2c,%esp
  80147e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801481:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	ff 75 08             	pushl  0x8(%ebp)
  801488:	e8 56 fe ff ff       	call   8012e3 <fd_lookup>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	83 c4 08             	add    $0x8,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	0f 88 c0 00 00 00    	js     80155a <dup+0xe5>
		return r;
	close(newfdnum);
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	57                   	push   %edi
  80149e:	e8 84 ff ff ff       	call   801427 <close>

	newfd = INDEX2FD(newfdnum);
  8014a3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014a9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014ac:	83 c4 04             	add    $0x4,%esp
  8014af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b2:	e8 a1 fd ff ff       	call   801258 <fd2data>
  8014b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014b9:	89 34 24             	mov    %esi,(%esp)
  8014bc:	e8 97 fd ff ff       	call   801258 <fd2data>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	c1 e8 16             	shr    $0x16,%eax
  8014cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d3:	a8 01                	test   $0x1,%al
  8014d5:	74 37                	je     80150e <dup+0x99>
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	c1 e8 0c             	shr    $0xc,%eax
  8014dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e3:	f6 c2 01             	test   $0x1,%dl
  8014e6:	74 26                	je     80150e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014fb:	6a 00                	push   $0x0
  8014fd:	53                   	push   %ebx
  8014fe:	6a 00                	push   $0x0
  801500:	e8 4f f9 ff ff       	call   800e54 <sys_page_map>
  801505:	89 c3                	mov    %eax,%ebx
  801507:	83 c4 20             	add    $0x20,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 2d                	js     80153b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801511:	89 c2                	mov    %eax,%edx
  801513:	c1 ea 0c             	shr    $0xc,%edx
  801516:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801526:	52                   	push   %edx
  801527:	56                   	push   %esi
  801528:	6a 00                	push   $0x0
  80152a:	50                   	push   %eax
  80152b:	6a 00                	push   $0x0
  80152d:	e8 22 f9 ff ff       	call   800e54 <sys_page_map>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	83 c4 20             	add    $0x20,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	79 1d                	jns    801558 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	56                   	push   %esi
  80153f:	6a 00                	push   $0x0
  801541:	e8 34 f9 ff ff       	call   800e7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154c:	6a 00                	push   $0x0
  80154e:	e8 27 f9 ff ff       	call   800e7a <sys_page_unmap>
	return r;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	eb 02                	jmp    80155a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801558:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5f                   	pop    %edi
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	e8 6b fd ff ff       	call   8012e3 <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 67                	js     8015e6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	ff 30                	pushl  (%eax)
  80158b:	e8 a9 fd ff ff       	call   801339 <dev_lookup>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 4f                	js     8015e6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	8b 50 08             	mov    0x8(%eax),%edx
  80159d:	83 e2 03             	and    $0x3,%edx
  8015a0:	83 fa 01             	cmp    $0x1,%edx
  8015a3:	75 21                	jne    8015c6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	83 ec 04             	sub    $0x4,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	50                   	push   %eax
  8015b2:	68 91 2a 80 00       	push   $0x802a91
  8015b7:	e8 3c ee ff ff       	call   8003f8 <cprintf>
		return -E_INVAL;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c4:	eb 20                	jmp    8015e6 <read+0x82>
	}
	if (!dev->dev_read)
  8015c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c9:	8b 52 08             	mov    0x8(%edx),%edx
  8015cc:	85 d2                	test   %edx,%edx
  8015ce:	74 11                	je     8015e1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	ff 75 10             	pushl  0x10(%ebp)
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	50                   	push   %eax
  8015da:	ff d2                	call   *%edx
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb 05                	jmp    8015e6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fa:	85 f6                	test   %esi,%esi
  8015fc:	74 31                	je     80162f <readn+0x44>
  8015fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801603:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	89 f2                	mov    %esi,%edx
  80160d:	29 c2                	sub    %eax,%edx
  80160f:	52                   	push   %edx
  801610:	03 45 0c             	add    0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	57                   	push   %edi
  801615:	e8 4a ff ff ff       	call   801564 <read>
		if (m < 0)
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 17                	js     801638 <readn+0x4d>
			return m;
		if (m == 0)
  801621:	85 c0                	test   %eax,%eax
  801623:	74 11                	je     801636 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801625:	01 c3                	add    %eax,%ebx
  801627:	89 d8                	mov    %ebx,%eax
  801629:	39 f3                	cmp    %esi,%ebx
  80162b:	72 db                	jb     801608 <readn+0x1d>
  80162d:	eb 09                	jmp    801638 <readn+0x4d>
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
  801634:	eb 02                	jmp    801638 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801636:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	53                   	push   %ebx
  80164f:	e8 8f fc ff ff       	call   8012e3 <fd_lookup>
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 62                	js     8016bd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 cd fc ff ff       	call   801339 <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 4a                	js     8016bd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167a:	75 21                	jne    80169d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80167c:	a1 04 40 80 00       	mov    0x804004,%eax
  801681:	8b 40 48             	mov    0x48(%eax),%eax
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	53                   	push   %ebx
  801688:	50                   	push   %eax
  801689:	68 ad 2a 80 00       	push   $0x802aad
  80168e:	e8 65 ed ff ff       	call   8003f8 <cprintf>
		return -E_INVAL;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169b:	eb 20                	jmp    8016bd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 11                	je     8016b8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	ff 75 10             	pushl  0x10(%ebp)
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	50                   	push   %eax
  8016b1:	ff d2                	call   *%edx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	eb 05                	jmp    8016bd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 0f fc ff ff       	call   8012e3 <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 0e                	js     8016e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	83 ec 14             	sub    $0x14,%esp
  8016f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	53                   	push   %ebx
  8016fa:	e8 e4 fb ff ff       	call   8012e3 <fd_lookup>
  8016ff:	83 c4 08             	add    $0x8,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 5f                	js     801765 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	ff 30                	pushl  (%eax)
  801712:	e8 22 fc ff ff       	call   801339 <dev_lookup>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 47                	js     801765 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801725:	75 21                	jne    801748 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801727:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80172c:	8b 40 48             	mov    0x48(%eax),%eax
  80172f:	83 ec 04             	sub    $0x4,%esp
  801732:	53                   	push   %ebx
  801733:	50                   	push   %eax
  801734:	68 70 2a 80 00       	push   $0x802a70
  801739:	e8 ba ec ff ff       	call   8003f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801746:	eb 1d                	jmp    801765 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174b:	8b 52 18             	mov    0x18(%edx),%edx
  80174e:	85 d2                	test   %edx,%edx
  801750:	74 0e                	je     801760 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	50                   	push   %eax
  801759:	ff d2                	call   *%edx
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	eb 05                	jmp    801765 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	ff 75 08             	pushl  0x8(%ebp)
  80177b:	e8 63 fb ff ff       	call   8012e3 <fd_lookup>
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 52                	js     8017d9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 a1 fb ff ff       	call   801339 <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 3a                	js     8017d9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a6:	74 2c                	je     8017d4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b2:	00 00 00 
	stat->st_isdir = 0;
  8017b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bc:	00 00 00 
	stat->st_dev = dev;
  8017bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	53                   	push   %ebx
  8017c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cc:	ff 50 14             	call   *0x14(%eax)
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	eb 05                	jmp    8017d9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	ff 75 08             	pushl  0x8(%ebp)
  8017eb:	e8 8b 01 00 00       	call   80197b <open>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 1b                	js     801814 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	ff 75 0c             	pushl  0xc(%ebp)
  8017ff:	50                   	push   %eax
  801800:	e8 65 ff ff ff       	call   80176a <fstat>
  801805:	89 c6                	mov    %eax,%esi
	close(fd);
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 18 fc ff ff       	call   801427 <close>
	return r;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	89 f3                	mov    %esi,%ebx
}
  801814:	89 d8                	mov    %ebx,%eax
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    
  80181d:	00 00                	add    %al,(%eax)
	...

00801820 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	89 c3                	mov    %eax,%ebx
  801827:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801829:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801830:	75 12                	jne    801844 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	6a 01                	push   $0x1
  801837:	e8 f9 08 00 00       	call   802135 <ipc_find_env>
  80183c:	a3 00 40 80 00       	mov    %eax,0x804000
  801841:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801844:	6a 07                	push   $0x7
  801846:	68 00 50 80 00       	push   $0x805000
  80184b:	53                   	push   %ebx
  80184c:	ff 35 00 40 80 00    	pushl  0x804000
  801852:	e8 89 08 00 00       	call   8020e0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801857:	83 c4 0c             	add    $0xc,%esp
  80185a:	6a 00                	push   $0x0
  80185c:	56                   	push   %esi
  80185d:	6a 00                	push   $0x0
  80185f:	e8 d4 07 00 00       	call   802038 <ipc_recv>
}
  801864:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 05 00 00 00       	mov    $0x5,%eax
  80188a:	e8 91 ff ff ff       	call   801820 <fsipc>
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 39                	js     8018cc <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	68 dc 2a 80 00       	push   $0x802adc
  80189b:	e8 58 eb ff ff       	call   8003f8 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a0:	83 c4 08             	add    $0x8,%esp
  8018a3:	68 00 50 80 00       	push   $0x805000
  8018a8:	53                   	push   %ebx
  8018a9:	e8 00 f1 ff ff       	call   8009ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ae:	a1 80 50 80 00       	mov    0x805080,%eax
  8018b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ec:	e8 2f ff ff ff       	call   801820 <fsipc>
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801901:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801906:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80190c:	ba 00 00 00 00       	mov    $0x0,%edx
  801911:	b8 03 00 00 00       	mov    $0x3,%eax
  801916:	e8 05 ff ff ff       	call   801820 <fsipc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 51                	js     801972 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801921:	39 c6                	cmp    %eax,%esi
  801923:	73 19                	jae    80193e <devfile_read+0x4b>
  801925:	68 e2 2a 80 00       	push   $0x802ae2
  80192a:	68 e9 2a 80 00       	push   $0x802ae9
  80192f:	68 80 00 00 00       	push   $0x80
  801934:	68 fe 2a 80 00       	push   $0x802afe
  801939:	e8 e2 e9 ff ff       	call   800320 <_panic>
	assert(r <= PGSIZE);
  80193e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801943:	7e 19                	jle    80195e <devfile_read+0x6b>
  801945:	68 09 2b 80 00       	push   $0x802b09
  80194a:	68 e9 2a 80 00       	push   $0x802ae9
  80194f:	68 81 00 00 00       	push   $0x81
  801954:	68 fe 2a 80 00       	push   $0x802afe
  801959:	e8 c2 e9 ff ff       	call   800320 <_panic>
	memmove(buf, &fsipcbuf, r);
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	50                   	push   %eax
  801962:	68 00 50 80 00       	push   $0x805000
  801967:	ff 75 0c             	pushl  0xc(%ebp)
  80196a:	e8 00 f2 ff ff       	call   800b6f <memmove>
	return r;
  80196f:	83 c4 10             	add    $0x10,%esp
}
  801972:	89 d8                	mov    %ebx,%eax
  801974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	83 ec 1c             	sub    $0x1c,%esp
  801983:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801986:	56                   	push   %esi
  801987:	e8 d0 ef ff ff       	call   80095c <strlen>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801994:	7f 72                	jg     801a08 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	e8 ce f8 ff ff       	call   801270 <fd_alloc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 62                	js     801a0d <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	56                   	push   %esi
  8019af:	68 00 50 80 00       	push   $0x805000
  8019b4:	e8 f5 ef ff ff       	call   8009ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bc:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c9:	e8 52 fe ff ff       	call   801820 <fsipc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	79 12                	jns    8019e9 <open+0x6e>
		fd_close(fd, 0);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	6a 00                	push   $0x0
  8019dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019df:	e8 bb f9 ff ff       	call   80139f <fd_close>
		return r;
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	eb 24                	jmp    801a0d <open+0x92>
	}


	cprintf("OPEN\n");
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	68 15 2b 80 00       	push   $0x802b15
  8019f1:	e8 02 ea ff ff       	call   8003f8 <cprintf>

	return fd2num(fd);
  8019f6:	83 c4 04             	add    $0x4,%esp
  8019f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fc:	e8 47 f8 ff ff       	call   801248 <fd2num>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	eb 05                	jmp    801a0d <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a08:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801a0d:	89 d8                	mov    %ebx,%eax
  801a0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    
	...

00801a18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 2d f8 ff ff       	call   801258 <fd2data>
  801a2b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	68 1b 2b 80 00       	push   $0x802b1b
  801a35:	56                   	push   %esi
  801a36:	e8 73 ef ff ff       	call   8009ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3e:	2b 03                	sub    (%ebx),%eax
  801a40:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a46:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a4d:	00 00 00 
	stat->st_dev = &devpipe;
  801a50:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801a57:	30 80 00 
	return 0;
}
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a70:	53                   	push   %ebx
  801a71:	6a 00                	push   $0x0
  801a73:	e8 02 f4 ff ff       	call   800e7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a78:	89 1c 24             	mov    %ebx,(%esp)
  801a7b:	e8 d8 f7 ff ff       	call   801258 <fd2data>
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	50                   	push   %eax
  801a84:	6a 00                	push   $0x0
  801a86:	e8 ef f3 ff ff       	call   800e7a <sys_page_unmap>
}
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 1c             	sub    $0x1c,%esp
  801a99:	89 c7                	mov    %eax,%edi
  801a9b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	57                   	push   %edi
  801aaa:	e8 e1 06 00 00       	call   802190 <pageref>
  801aaf:	89 c6                	mov    %eax,%esi
  801ab1:	83 c4 04             	add    $0x4,%esp
  801ab4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab7:	e8 d4 06 00 00       	call   802190 <pageref>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	39 c6                	cmp    %eax,%esi
  801ac1:	0f 94 c0             	sete   %al
  801ac4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ac7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801acd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad0:	39 cb                	cmp    %ecx,%ebx
  801ad2:	75 08                	jne    801adc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5f                   	pop    %edi
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801adc:	83 f8 01             	cmp    $0x1,%eax
  801adf:	75 bd                	jne    801a9e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae1:	8b 42 58             	mov    0x58(%edx),%eax
  801ae4:	6a 01                	push   $0x1
  801ae6:	50                   	push   %eax
  801ae7:	53                   	push   %ebx
  801ae8:	68 22 2b 80 00       	push   $0x802b22
  801aed:	e8 06 e9 ff ff       	call   8003f8 <cprintf>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	eb a7                	jmp    801a9e <_pipeisclosed+0xe>

00801af7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 28             	sub    $0x28,%esp
  801b00:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b03:	56                   	push   %esi
  801b04:	e8 4f f7 ff ff       	call   801258 <fd2data>
  801b09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b12:	75 4a                	jne    801b5e <devpipe_write+0x67>
  801b14:	bf 00 00 00 00       	mov    $0x0,%edi
  801b19:	eb 56                	jmp    801b71 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1b:	89 da                	mov    %ebx,%edx
  801b1d:	89 f0                	mov    %esi,%eax
  801b1f:	e8 6c ff ff ff       	call   801a90 <_pipeisclosed>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	75 4d                	jne    801b75 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b28:	e8 dc f2 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b2d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b30:	8b 13                	mov    (%ebx),%edx
  801b32:	83 c2 20             	add    $0x20,%edx
  801b35:	39 d0                	cmp    %edx,%eax
  801b37:	73 e2                	jae    801b1b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b41:	79 05                	jns    801b48 <devpipe_write+0x51>
  801b43:	4a                   	dec    %edx
  801b44:	83 ca e0             	or     $0xffffffe0,%edx
  801b47:	42                   	inc    %edx
  801b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b52:	40                   	inc    %eax
  801b53:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b56:	47                   	inc    %edi
  801b57:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b5a:	77 07                	ja     801b63 <devpipe_write+0x6c>
  801b5c:	eb 13                	jmp    801b71 <devpipe_write+0x7a>
  801b5e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b63:	8b 43 04             	mov    0x4(%ebx),%eax
  801b66:	8b 13                	mov    (%ebx),%edx
  801b68:	83 c2 20             	add    $0x20,%edx
  801b6b:	39 d0                	cmp    %edx,%eax
  801b6d:	73 ac                	jae    801b1b <devpipe_write+0x24>
  801b6f:	eb c8                	jmp    801b39 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b71:	89 f8                	mov    %edi,%eax
  801b73:	eb 05                	jmp    801b7a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5f                   	pop    %edi
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 18             	sub    $0x18,%esp
  801b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8e:	57                   	push   %edi
  801b8f:	e8 c4 f6 ff ff       	call   801258 <fd2data>
  801b94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b9d:	75 44                	jne    801be3 <devpipe_read+0x61>
  801b9f:	be 00 00 00 00       	mov    $0x0,%esi
  801ba4:	eb 4f                	jmp    801bf5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ba6:	89 f0                	mov    %esi,%eax
  801ba8:	eb 54                	jmp    801bfe <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801baa:	89 da                	mov    %ebx,%edx
  801bac:	89 f8                	mov    %edi,%eax
  801bae:	e8 dd fe ff ff       	call   801a90 <_pipeisclosed>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	75 42                	jne    801bf9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb7:	e8 4d f2 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bbc:	8b 03                	mov    (%ebx),%eax
  801bbe:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bc1:	74 e7                	je     801baa <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bc8:	79 05                	jns    801bcf <devpipe_read+0x4d>
  801bca:	48                   	dec    %eax
  801bcb:	83 c8 e0             	or     $0xffffffe0,%eax
  801bce:	40                   	inc    %eax
  801bcf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bd9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdb:	46                   	inc    %esi
  801bdc:	39 75 10             	cmp    %esi,0x10(%ebp)
  801bdf:	77 07                	ja     801be8 <devpipe_read+0x66>
  801be1:	eb 12                	jmp    801bf5 <devpipe_read+0x73>
  801be3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801be8:	8b 03                	mov    (%ebx),%eax
  801bea:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bed:	75 d4                	jne    801bc3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bef:	85 f6                	test   %esi,%esi
  801bf1:	75 b3                	jne    801ba6 <devpipe_read+0x24>
  801bf3:	eb b5                	jmp    801baa <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf5:	89 f0                	mov    %esi,%eax
  801bf7:	eb 05                	jmp    801bfe <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	57                   	push   %edi
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 28             	sub    $0x28,%esp
  801c0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	e8 55 f6 ff ff       	call   801270 <fd_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 24 01 00 00    	js     801d4c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	68 07 04 00 00       	push   $0x407
  801c30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c33:	6a 00                	push   $0x0
  801c35:	e8 f6 f1 ff ff       	call   800e30 <sys_page_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 05 01 00 00    	js     801d4c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c4d:	50                   	push   %eax
  801c4e:	e8 1d f6 ff ff       	call   801270 <fd_alloc>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	0f 88 dc 00 00 00    	js     801d3c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c60:	83 ec 04             	sub    $0x4,%esp
  801c63:	68 07 04 00 00       	push   $0x407
  801c68:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 be f1 ff ff       	call   800e30 <sys_page_alloc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 bd 00 00 00    	js     801d3c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c85:	e8 ce f5 ff ff       	call   801258 <fd2data>
  801c8a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8c:	83 c4 0c             	add    $0xc,%esp
  801c8f:	68 07 04 00 00       	push   $0x407
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 94 f1 ff ff       	call   800e30 <sys_page_alloc>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	0f 88 83 00 00 00    	js     801d2c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 e0             	pushl  -0x20(%ebp)
  801caf:	e8 a4 f5 ff ff       	call   801258 <fd2data>
  801cb4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbb:	50                   	push   %eax
  801cbc:	6a 00                	push   $0x0
  801cbe:	56                   	push   %esi
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 8e f1 ff ff       	call   800e54 <sys_page_map>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	83 c4 20             	add    $0x20,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 4f                	js     801d1e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ccf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cd8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cdd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ced:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cf2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cff:	e8 44 f5 ff ff       	call   801248 <fd2num>
  801d04:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d06:	83 c4 04             	add    $0x4,%esp
  801d09:	ff 75 e0             	pushl  -0x20(%ebp)
  801d0c:	e8 37 f5 ff ff       	call   801248 <fd2num>
  801d11:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1c:	eb 2e                	jmp    801d4c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	56                   	push   %esi
  801d22:	6a 00                	push   $0x0
  801d24:	e8 51 f1 ff ff       	call   800e7a <sys_page_unmap>
  801d29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d2c:	83 ec 08             	sub    $0x8,%esp
  801d2f:	ff 75 e0             	pushl  -0x20(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 41 f1 ff ff       	call   800e7a <sys_page_unmap>
  801d39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d42:	6a 00                	push   $0x0
  801d44:	e8 31 f1 ff ff       	call   800e7a <sys_page_unmap>
  801d49:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d4c:	89 d8                	mov    %ebx,%eax
  801d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5f                   	pop    %edi
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	ff 75 08             	pushl  0x8(%ebp)
  801d63:	e8 7b f5 ff ff       	call   8012e3 <fd_lookup>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 18                	js     801d87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d6f:	83 ec 0c             	sub    $0xc,%esp
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	e8 de f4 ff ff       	call   801258 <fd2data>
	return _pipeisclosed(fd, p);
  801d7a:	89 c2                	mov    %eax,%edx
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	e8 0c fd ff ff       	call   801a90 <_pipeisclosed>
  801d84:	83 c4 10             	add    $0x10,%esp
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    
  801d89:	00 00                	add    %al,(%eax)
	...

00801d8c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	75 16                	jne    801db2 <wait+0x26>
  801d9c:	68 3a 2b 80 00       	push   $0x802b3a
  801da1:	68 e9 2a 80 00       	push   $0x802ae9
  801da6:	6a 09                	push   $0x9
  801da8:	68 45 2b 80 00       	push   $0x802b45
  801dad:	e8 6e e5 ff ff       	call   800320 <_panic>
	e = &envs[ENVX(envid)];
  801db2:	89 c6                	mov    %eax,%esi
  801db4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dba:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  801dc1:	89 f2                	mov    %esi,%edx
  801dc3:	c1 e2 07             	shl    $0x7,%edx
  801dc6:	29 ca                	sub    %ecx,%edx
  801dc8:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  801dce:	8b 7a 40             	mov    0x40(%edx),%edi
  801dd1:	39 c7                	cmp    %eax,%edi
  801dd3:	75 37                	jne    801e0c <wait+0x80>
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	c1 e0 07             	shl    $0x7,%eax
  801dda:	29 c8                	sub    %ecx,%eax
  801ddc:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  801de1:	8b 40 50             	mov    0x50(%eax),%eax
  801de4:	85 c0                	test   %eax,%eax
  801de6:	74 24                	je     801e0c <wait+0x80>
  801de8:	c1 e6 07             	shl    $0x7,%esi
  801deb:	29 ce                	sub    %ecx,%esi
  801ded:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  801df3:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801df9:	e8 0b f0 ff ff       	call   800e09 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dfe:	8b 43 40             	mov    0x40(%ebx),%eax
  801e01:	39 f8                	cmp    %edi,%eax
  801e03:	75 07                	jne    801e0c <wait+0x80>
  801e05:	8b 46 50             	mov    0x50(%esi),%eax
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	75 ed                	jne    801df9 <wait+0x6d>
		sys_yield();
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e24:	68 50 2b 80 00       	push   $0x802b50
  801e29:	ff 75 0c             	pushl  0xc(%ebp)
  801e2c:	e8 7d eb ff ff       	call   8009ae <strcpy>
	return 0;
}
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	57                   	push   %edi
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e48:	74 45                	je     801e8f <devcons_write+0x57>
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e54:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e5d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e5f:	83 fb 7f             	cmp    $0x7f,%ebx
  801e62:	76 05                	jbe    801e69 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801e64:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e69:	83 ec 04             	sub    $0x4,%esp
  801e6c:	53                   	push   %ebx
  801e6d:	03 45 0c             	add    0xc(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	57                   	push   %edi
  801e72:	e8 f8 ec ff ff       	call   800b6f <memmove>
		sys_cputs(buf, m);
  801e77:	83 c4 08             	add    $0x8,%esp
  801e7a:	53                   	push   %ebx
  801e7b:	57                   	push   %edi
  801e7c:	e8 f8 ee ff ff       	call   800d79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e81:	01 de                	add    %ebx,%esi
  801e83:	89 f0                	mov    %esi,%eax
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e8b:	72 cd                	jb     801e5a <devcons_write+0x22>
  801e8d:	eb 05                	jmp    801e94 <devcons_write+0x5c>
  801e8f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e94:	89 f0                	mov    %esi,%eax
  801e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e99:	5b                   	pop    %ebx
  801e9a:	5e                   	pop    %esi
  801e9b:	5f                   	pop    %edi
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ea4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea8:	75 07                	jne    801eb1 <devcons_read+0x13>
  801eaa:	eb 25                	jmp    801ed1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eac:	e8 58 ef ff ff       	call   800e09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb1:	e8 e9 ee ff ff       	call   800d9f <sys_cgetc>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	74 f2                	je     801eac <devcons_read+0xe>
  801eba:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 1d                	js     801edd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec0:	83 f8 04             	cmp    $0x4,%eax
  801ec3:	74 13                	je     801ed8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec8:	88 10                	mov    %dl,(%eax)
	return 1;
  801eca:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecf:	eb 0c                	jmp    801edd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed6:	eb 05                	jmp    801edd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eeb:	6a 01                	push   $0x1
  801eed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	e8 83 ee ff ff       	call   800d79 <sys_cputs>
  801ef6:	83 c4 10             	add    $0x10,%esp
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <getchar>:

int
getchar(void)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f01:	6a 01                	push   $0x1
  801f03:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	6a 00                	push   $0x0
  801f09:	e8 56 f6 ff ff       	call   801564 <read>
	if (r < 0)
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 0f                	js     801f24 <getchar+0x29>
		return r;
	if (r < 1)
  801f15:	85 c0                	test   %eax,%eax
  801f17:	7e 06                	jle    801f1f <getchar+0x24>
		return -E_EOF;
	return c;
  801f19:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1d:	eb 05                	jmp    801f24 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f1f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    

00801f26 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2f:	50                   	push   %eax
  801f30:	ff 75 08             	pushl  0x8(%ebp)
  801f33:	e8 ab f3 ff ff       	call   8012e3 <fd_lookup>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 11                	js     801f50 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f42:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f48:	39 10                	cmp    %edx,(%eax)
  801f4a:	0f 94 c0             	sete   %al
  801f4d:	0f b6 c0             	movzbl %al,%eax
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <opencons>:

int
opencons(void)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5b:	50                   	push   %eax
  801f5c:	e8 0f f3 ff ff       	call   801270 <fd_alloc>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	78 3a                	js     801fa2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f68:	83 ec 04             	sub    $0x4,%esp
  801f6b:	68 07 04 00 00       	push   $0x407
  801f70:	ff 75 f4             	pushl  -0xc(%ebp)
  801f73:	6a 00                	push   $0x0
  801f75:	e8 b6 ee ff ff       	call   800e30 <sys_page_alloc>
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 21                	js     801fa2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f81:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	50                   	push   %eax
  801f9a:	e8 a9 f2 ff ff       	call   801248 <fd2num>
  801f9f:	83 c4 10             	add    $0x10,%esp
}
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    

00801fa4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801faa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb1:	75 52                	jne    802005 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	6a 07                	push   $0x7
  801fb8:	68 00 f0 bf ee       	push   $0xeebff000
  801fbd:	6a 00                	push   $0x0
  801fbf:	e8 6c ee ff ff       	call   800e30 <sys_page_alloc>
		if (r < 0) {
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 12                	jns    801fdd <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801fcb:	50                   	push   %eax
  801fcc:	68 5c 2b 80 00       	push   $0x802b5c
  801fd1:	6a 24                	push   $0x24
  801fd3:	68 77 2b 80 00       	push   $0x802b77
  801fd8:	e8 43 e3 ff ff       	call   800320 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801fdd:	83 ec 08             	sub    $0x8,%esp
  801fe0:	68 10 20 80 00       	push   $0x802010
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 f7 ee ff ff       	call   800ee3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	79 12                	jns    802005 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801ff3:	50                   	push   %eax
  801ff4:	68 88 2b 80 00       	push   $0x802b88
  801ff9:	6a 2a                	push   $0x2a
  801ffb:	68 77 2b 80 00       	push   $0x802b77
  802000:	e8 1b e3 ff ff       	call   800320 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802005:	8b 45 08             	mov    0x8(%ebp),%eax
  802008:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    
	...

00802010 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802010:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802011:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802016:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802018:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80201b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80201f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802022:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802026:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80202a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80202c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80202f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802030:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  802033:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802034:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802035:	c3                   	ret    
	...

00802038 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	57                   	push   %edi
  80203c:	56                   	push   %esi
  80203d:	53                   	push   %ebx
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	8b 7d 08             	mov    0x8(%ebp),%edi
  802044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802047:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	57                   	push   %edi
  80204d:	68 b0 2b 80 00       	push   $0x802bb0
  802052:	e8 a1 e3 ff ff       	call   8003f8 <cprintf>
	int r;
	if (pg != NULL) {
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 db                	test   %ebx,%ebx
  80205c:	74 28                	je     802086 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	68 c0 2b 80 00       	push   $0x802bc0
  802066:	e8 8d e3 ff ff       	call   8003f8 <cprintf>
		r = sys_ipc_recv(pg);
  80206b:	89 1c 24             	mov    %ebx,(%esp)
  80206e:	e8 b8 ee ff ff       	call   800f2b <sys_ipc_recv>
  802073:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  802075:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  80207c:	e8 77 e3 ff ff       	call   8003f8 <cprintf>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	eb 12                	jmp    802098 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802086:	83 ec 0c             	sub    $0xc,%esp
  802089:	68 00 00 c0 ee       	push   $0xeec00000
  80208e:	e8 98 ee ff ff       	call   800f2b <sys_ipc_recv>
  802093:	89 c3                	mov    %eax,%ebx
  802095:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802098:	85 db                	test   %ebx,%ebx
  80209a:	75 26                	jne    8020c2 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80209c:	85 ff                	test   %edi,%edi
  80209e:	74 0a                	je     8020aa <ipc_recv+0x72>
  8020a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a5:	8b 40 74             	mov    0x74(%eax),%eax
  8020a8:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8020aa:	85 f6                	test   %esi,%esi
  8020ac:	74 0a                	je     8020b8 <ipc_recv+0x80>
  8020ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b3:	8b 40 78             	mov    0x78(%eax),%eax
  8020b6:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  8020b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8020bd:	8b 58 70             	mov    0x70(%eax),%ebx
  8020c0:	eb 14                	jmp    8020d6 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8020c2:	85 ff                	test   %edi,%edi
  8020c4:	74 06                	je     8020cc <ipc_recv+0x94>
  8020c6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  8020cc:	85 f6                	test   %esi,%esi
  8020ce:	74 06                	je     8020d6 <ipc_recv+0x9e>
  8020d0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  8020d6:	89 d8                	mov    %ebx,%eax
  8020d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	53                   	push   %ebx
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8020f2:	85 db                	test   %ebx,%ebx
  8020f4:	75 25                	jne    80211b <ipc_send+0x3b>
  8020f6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8020fb:	eb 1e                	jmp    80211b <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8020fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802100:	75 07                	jne    802109 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802102:	e8 02 ed ff ff       	call   800e09 <sys_yield>
  802107:	eb 12                	jmp    80211b <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802109:	50                   	push   %eax
  80210a:	68 c7 2b 80 00       	push   $0x802bc7
  80210f:	6a 45                	push   $0x45
  802111:	68 da 2b 80 00       	push   $0x802bda
  802116:	e8 05 e2 ff ff       	call   800320 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80211b:	56                   	push   %esi
  80211c:	53                   	push   %ebx
  80211d:	57                   	push   %edi
  80211e:	ff 75 08             	pushl  0x8(%ebp)
  802121:	e8 e0 ed ff ff       	call   800f06 <sys_ipc_try_send>
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	85 c0                	test   %eax,%eax
  80212b:	75 d0                	jne    8020fd <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80212d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	c9                   	leave  
  802134:	c3                   	ret    

00802135 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802135:	55                   	push   %ebp
  802136:	89 e5                	mov    %esp,%ebp
  802138:	53                   	push   %ebx
  802139:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80213c:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802142:	74 22                	je     802166 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802144:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802149:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802150:	89 c2                	mov    %eax,%edx
  802152:	c1 e2 07             	shl    $0x7,%edx
  802155:	29 ca                	sub    %ecx,%edx
  802157:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80215d:	8b 52 50             	mov    0x50(%edx),%edx
  802160:	39 da                	cmp    %ebx,%edx
  802162:	75 1d                	jne    802181 <ipc_find_env+0x4c>
  802164:	eb 05                	jmp    80216b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802166:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80216b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802172:	c1 e0 07             	shl    $0x7,%eax
  802175:	29 d0                	sub    %edx,%eax
  802177:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80217c:	8b 40 40             	mov    0x40(%eax),%eax
  80217f:	eb 0c                	jmp    80218d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802181:	40                   	inc    %eax
  802182:	3d 00 04 00 00       	cmp    $0x400,%eax
  802187:	75 c0                	jne    802149 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802189:	66 b8 00 00          	mov    $0x0,%ax
}
  80218d:	5b                   	pop    %ebx
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802196:	89 c2                	mov    %eax,%edx
  802198:	c1 ea 16             	shr    $0x16,%edx
  80219b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021a2:	f6 c2 01             	test   $0x1,%dl
  8021a5:	74 1e                	je     8021c5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021a7:	c1 e8 0c             	shr    $0xc,%eax
  8021aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021b1:	a8 01                	test   $0x1,%al
  8021b3:	74 17                	je     8021cc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b5:	c1 e8 0c             	shr    $0xc,%eax
  8021b8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021bf:	ef 
  8021c0:	0f b7 c0             	movzwl %ax,%eax
  8021c3:	eb 0c                	jmp    8021d1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8021c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ca:	eb 05                	jmp    8021d1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021cc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    
	...

008021d4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	57                   	push   %edi
  8021d8:	56                   	push   %esi
  8021d9:	83 ec 10             	sub    $0x10,%esp
  8021dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021df:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021e2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8021e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8021e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021eb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021ee:	85 c0                	test   %eax,%eax
  8021f0:	75 2e                	jne    802220 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8021f2:	39 f1                	cmp    %esi,%ecx
  8021f4:	77 5a                	ja     802250 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021f6:	85 c9                	test   %ecx,%ecx
  8021f8:	75 0b                	jne    802205 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ff:	31 d2                	xor    %edx,%edx
  802201:	f7 f1                	div    %ecx
  802203:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802205:	31 d2                	xor    %edx,%edx
  802207:	89 f0                	mov    %esi,%eax
  802209:	f7 f1                	div    %ecx
  80220b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80220d:	89 f8                	mov    %edi,%eax
  80220f:	f7 f1                	div    %ecx
  802211:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802213:	89 f8                	mov    %edi,%eax
  802215:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	5e                   	pop    %esi
  80221b:	5f                   	pop    %edi
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    
  80221e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802220:	39 f0                	cmp    %esi,%eax
  802222:	77 1c                	ja     802240 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802224:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	75 3c                	jne    802268 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80222c:	39 f0                	cmp    %esi,%eax
  80222e:	0f 82 90 00 00 00    	jb     8022c4 <__udivdi3+0xf0>
  802234:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802237:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80223a:	0f 86 84 00 00 00    	jbe    8022c4 <__udivdi3+0xf0>
  802240:	31 f6                	xor    %esi,%esi
  802242:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802244:	89 f8                	mov    %edi,%eax
  802246:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802248:	83 c4 10             	add    $0x10,%esp
  80224b:	5e                   	pop    %esi
  80224c:	5f                   	pop    %edi
  80224d:	c9                   	leave  
  80224e:	c3                   	ret    
  80224f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802250:	89 f2                	mov    %esi,%edx
  802252:	89 f8                	mov    %edi,%eax
  802254:	f7 f1                	div    %ecx
  802256:	89 c7                	mov    %eax,%edi
  802258:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80225a:	89 f8                	mov    %edi,%eax
  80225c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	c9                   	leave  
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802268:	89 f9                	mov    %edi,%ecx
  80226a:	d3 e0                	shl    %cl,%eax
  80226c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80226f:	b8 20 00 00 00       	mov    $0x20,%eax
  802274:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802279:	88 c1                	mov    %al,%cl
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802280:	09 ca                	or     %ecx,%edx
  802282:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802288:	89 f9                	mov    %edi,%ecx
  80228a:	d3 e2                	shl    %cl,%edx
  80228c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80228f:	89 f2                	mov    %esi,%edx
  802291:	88 c1                	mov    %al,%cl
  802293:	d3 ea                	shr    %cl,%edx
  802295:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802298:	89 f2                	mov    %esi,%edx
  80229a:	89 f9                	mov    %edi,%ecx
  80229c:	d3 e2                	shl    %cl,%edx
  80229e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022a1:	88 c1                	mov    %al,%cl
  8022a3:	d3 ee                	shr    %cl,%esi
  8022a5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022a7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022aa:	89 f0                	mov    %esi,%eax
  8022ac:	89 ca                	mov    %ecx,%edx
  8022ae:	f7 75 ec             	divl   -0x14(%ebp)
  8022b1:	89 d1                	mov    %edx,%ecx
  8022b3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022b5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022b8:	39 d1                	cmp    %edx,%ecx
  8022ba:	72 28                	jb     8022e4 <__udivdi3+0x110>
  8022bc:	74 1a                	je     8022d8 <__udivdi3+0x104>
  8022be:	89 f7                	mov    %esi,%edi
  8022c0:	31 f6                	xor    %esi,%esi
  8022c2:	eb 80                	jmp    802244 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022c4:	31 f6                	xor    %esi,%esi
  8022c6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022cb:	89 f8                	mov    %edi,%eax
  8022cd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022cf:	83 c4 10             	add    $0x10,%esp
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    
  8022d6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8022d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022db:	89 f9                	mov    %edi,%ecx
  8022dd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022df:	39 c2                	cmp    %eax,%edx
  8022e1:	73 db                	jae    8022be <__udivdi3+0xea>
  8022e3:	90                   	nop
		{
		  q0--;
  8022e4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022e7:	31 f6                	xor    %esi,%esi
  8022e9:	e9 56 ff ff ff       	jmp    802244 <__udivdi3+0x70>
	...

008022f0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	57                   	push   %edi
  8022f4:	56                   	push   %esi
  8022f5:	83 ec 20             	sub    $0x20,%esp
  8022f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802301:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802304:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802307:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80230a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80230d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80230f:	85 ff                	test   %edi,%edi
  802311:	75 15                	jne    802328 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802313:	39 f1                	cmp    %esi,%ecx
  802315:	0f 86 99 00 00 00    	jbe    8023b4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80231b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80231d:	89 d0                	mov    %edx,%eax
  80231f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802321:	83 c4 20             	add    $0x20,%esp
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	c9                   	leave  
  802327:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802328:	39 f7                	cmp    %esi,%edi
  80232a:	0f 87 a4 00 00 00    	ja     8023d4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802330:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802333:	83 f0 1f             	xor    $0x1f,%eax
  802336:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802339:	0f 84 a1 00 00 00    	je     8023e0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80233f:	89 f8                	mov    %edi,%eax
  802341:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802344:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802346:	bf 20 00 00 00       	mov    $0x20,%edi
  80234b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80234e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802351:	89 f9                	mov    %edi,%ecx
  802353:	d3 ea                	shr    %cl,%edx
  802355:	09 c2                	or     %eax,%edx
  802357:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802360:	d3 e0                	shl    %cl,%eax
  802362:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802365:	89 f2                	mov    %esi,%edx
  802367:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802369:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802371:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802374:	89 f9                	mov    %edi,%ecx
  802376:	d3 e8                	shr    %cl,%eax
  802378:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80237a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80237c:	89 f2                	mov    %esi,%edx
  80237e:	f7 75 f0             	divl   -0x10(%ebp)
  802381:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802383:	f7 65 f4             	mull   -0xc(%ebp)
  802386:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802389:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80238b:	39 d6                	cmp    %edx,%esi
  80238d:	72 71                	jb     802400 <__umoddi3+0x110>
  80238f:	74 7f                	je     802410 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802394:	29 c8                	sub    %ecx,%eax
  802396:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802398:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	89 f9                	mov    %edi,%ecx
  8023a1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8023a3:	09 d0                	or     %edx,%eax
  8023a5:	89 f2                	mov    %esi,%edx
  8023a7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023aa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023ac:	83 c4 20             	add    $0x20,%esp
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	c9                   	leave  
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023b4:	85 c9                	test   %ecx,%ecx
  8023b6:	75 0b                	jne    8023c3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	f7 f1                	div    %ecx
  8023c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023c3:	89 f0                	mov    %esi,%eax
  8023c5:	31 d2                	xor    %edx,%edx
  8023c7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023cc:	f7 f1                	div    %ecx
  8023ce:	e9 4a ff ff ff       	jmp    80231d <__umoddi3+0x2d>
  8023d3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8023d4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023d6:	83 c4 20             	add    $0x20,%esp
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	c9                   	leave  
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023e0:	39 f7                	cmp    %esi,%edi
  8023e2:	72 05                	jb     8023e9 <__umoddi3+0xf9>
  8023e4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8023e7:	77 0c                	ja     8023f5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023e9:	89 f2                	mov    %esi,%edx
  8023eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ee:	29 c8                	sub    %ecx,%eax
  8023f0:	19 fa                	sbb    %edi,%edx
  8023f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8023f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023f8:	83 c4 20             	add    $0x20,%esp
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    
  8023ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802400:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802403:	89 c1                	mov    %eax,%ecx
  802405:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802408:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80240b:	eb 84                	jmp    802391 <__umoddi3+0xa1>
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802410:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802413:	72 eb                	jb     802400 <__umoddi3+0x110>
  802415:	89 f2                	mov    %esi,%edx
  802417:	e9 75 ff ff ff       	jmp    802391 <__umoddi3+0xa1>
