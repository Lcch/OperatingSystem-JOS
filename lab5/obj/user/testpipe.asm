
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
  80003c:	c7 05 04 30 80 00 40 	movl   $0x802440,0x803004
  800043:	24 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	50                   	push   %eax
  80004a:	e8 03 1c 00 00       	call   801c52 <pipe>
  80004f:	89 c6                	mov    %eax,%esi
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", i);
  800058:	50                   	push   %eax
  800059:	68 4c 24 80 00       	push   $0x80244c
  80005e:	6a 0e                	push   $0xe
  800060:	68 55 24 80 00       	push   $0x802455
  800065:	e8 b6 02 00 00       	call   800320 <_panic>

	if ((pid = fork()) < 0)
  80006a:	e8 fb 0f 00 00       	call   80106a <fork>
  80006f:	89 c3                	mov    %eax,%ebx
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", i);
  800075:	56                   	push   %esi
  800076:	68 65 24 80 00       	push   $0x802465
  80007b:	6a 11                	push   $0x11
  80007d:	68 55 24 80 00       	push   $0x802455
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
  80009e:	68 6e 24 80 00       	push   $0x80246e
  8000a3:	e8 50 03 00 00       	call   8003f8 <cprintf>
		close(p[1]);
  8000a8:	83 c4 04             	add    $0x4,%esp
  8000ab:	ff 75 90             	pushl  -0x70(%ebp)
  8000ae:	e8 e0 13 00 00       	call   801493 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b8:	8b 40 48             	mov    0x48(%eax),%eax
  8000bb:	83 c4 0c             	add    $0xc,%esp
  8000be:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c1:	50                   	push   %eax
  8000c2:	68 8b 24 80 00       	push   $0x80248b
  8000c7:	e8 2c 03 00 00       	call   8003f8 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cc:	83 c4 0c             	add    $0xc,%esp
  8000cf:	6a 63                	push   $0x63
  8000d1:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d4:	50                   	push   %eax
  8000d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d8:	e8 7a 15 00 00       	call   801657 <readn>
  8000dd:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <umain+0xc4>
			panic("read: %e", i);
  8000e6:	50                   	push   %eax
  8000e7:	68 a8 24 80 00       	push   $0x8024a8
  8000ec:	6a 19                	push   $0x19
  8000ee:	68 55 24 80 00       	push   $0x802455
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
  800119:	68 b1 24 80 00       	push   $0x8024b1
  80011e:	e8 d5 02 00 00       	call   8003f8 <cprintf>
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	eb 15                	jmp    80013d <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	56                   	push   %esi
  800130:	68 cd 24 80 00       	push   $0x8024cd
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
  800156:	68 6e 24 80 00       	push   $0x80246e
  80015b:	e8 98 02 00 00       	call   8003f8 <cprintf>
		close(p[0]);
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 8c             	pushl  -0x74(%ebp)
  800166:	e8 28 13 00 00       	call   801493 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016b:	a1 04 40 80 00       	mov    0x804004,%eax
  800170:	8b 40 48             	mov    0x48(%eax),%eax
  800173:	83 c4 0c             	add    $0xc,%esp
  800176:	ff 75 90             	pushl  -0x70(%ebp)
  800179:	50                   	push   %eax
  80017a:	68 e0 24 80 00       	push   $0x8024e0
  80017f:	e8 74 02 00 00       	call   8003f8 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800184:	83 c4 04             	add    $0x4,%esp
  800187:	ff 35 00 30 80 00    	pushl  0x803000
  80018d:	e8 ca 07 00 00       	call   80095c <strlen>
  800192:	83 c4 0c             	add    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	ff 35 00 30 80 00    	pushl  0x803000
  80019c:	ff 75 90             	pushl  -0x70(%ebp)
  80019f:	e8 08 15 00 00       	call   8016ac <write>
  8001a4:	89 c6                	mov    %eax,%esi
  8001a6:	83 c4 04             	add    $0x4,%esp
  8001a9:	ff 35 00 30 80 00    	pushl  0x803000
  8001af:	e8 a8 07 00 00       	call   80095c <strlen>
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	39 c6                	cmp    %eax,%esi
  8001b9:	74 12                	je     8001cd <umain+0x199>
			panic("write: %e", i);
  8001bb:	56                   	push   %esi
  8001bc:	68 fd 24 80 00       	push   $0x8024fd
  8001c1:	6a 25                	push   $0x25
  8001c3:	68 55 24 80 00       	push   $0x802455
  8001c8:	e8 53 01 00 00       	call   800320 <_panic>
		close(p[1]);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	ff 75 90             	pushl  -0x70(%ebp)
  8001d3:	e8 bb 12 00 00       	call   801493 <close>
  8001d8:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	53                   	push   %ebx
  8001df:	e8 f4 1b 00 00       	call   801dd8 <wait>

	binaryname = "pipewriteeof";
  8001e4:	c7 05 04 30 80 00 07 	movl   $0x802507,0x803004
  8001eb:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ee:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 59 1a 00 00       	call   801c52 <pipe>
  8001f9:	89 c6                	mov    %eax,%esi
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	85 c0                	test   %eax,%eax
  800200:	79 12                	jns    800214 <umain+0x1e0>
		panic("pipe: %e", i);
  800202:	50                   	push   %eax
  800203:	68 4c 24 80 00       	push   $0x80244c
  800208:	6a 2c                	push   $0x2c
  80020a:	68 55 24 80 00       	push   $0x802455
  80020f:	e8 0c 01 00 00       	call   800320 <_panic>

	if ((pid = fork()) < 0)
  800214:	e8 51 0e 00 00       	call   80106a <fork>
  800219:	89 c3                	mov    %eax,%ebx
  80021b:	85 c0                	test   %eax,%eax
  80021d:	79 12                	jns    800231 <umain+0x1fd>
		panic("fork: %e", i);
  80021f:	56                   	push   %esi
  800220:	68 65 24 80 00       	push   $0x802465
  800225:	6a 2f                	push   $0x2f
  800227:	68 55 24 80 00       	push   $0x802455
  80022c:	e8 ef 00 00 00       	call   800320 <_panic>

	if (pid == 0) {
  800231:	85 c0                	test   %eax,%eax
  800233:	75 4a                	jne    80027f <umain+0x24b>
		close(p[0]);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 8c             	pushl  -0x74(%ebp)
  80023b:	e8 53 12 00 00       	call   801493 <close>
  800240:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	68 14 25 80 00       	push   $0x802514
  80024b:	e8 a8 01 00 00       	call   8003f8 <cprintf>
			if (write(p[1], "x", 1) != 1)
  800250:	83 c4 0c             	add    $0xc,%esp
  800253:	6a 01                	push   $0x1
  800255:	68 16 25 80 00       	push   $0x802516
  80025a:	ff 75 90             	pushl  -0x70(%ebp)
  80025d:	e8 4a 14 00 00       	call   8016ac <write>
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	83 f8 01             	cmp    $0x1,%eax
  800268:	74 d9                	je     800243 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 18 25 80 00       	push   $0x802518
  800272:	e8 81 01 00 00       	call   8003f8 <cprintf>
		exit();
  800277:	e8 88 00 00 00       	call   800304 <exit>
  80027c:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	ff 75 8c             	pushl  -0x74(%ebp)
  800285:	e8 09 12 00 00       	call   801493 <close>
	close(p[1]);
  80028a:	83 c4 04             	add    $0x4,%esp
  80028d:	ff 75 90             	pushl  -0x70(%ebp)
  800290:	e8 fe 11 00 00       	call   801493 <close>
	wait(pid);
  800295:	89 1c 24             	mov    %ebx,(%esp)
  800298:	e8 3b 1b 00 00       	call   801dd8 <wait>

	cprintf("pipe tests passed\n");
  80029d:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
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
  80030a:	e8 af 11 00 00       	call   8014be <close_all>
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
  80033e:	68 98 25 80 00       	push   $0x802598
  800343:	e8 b0 00 00 00       	call   8003f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800348:	83 c4 18             	add    $0x18,%esp
  80034b:	56                   	push   %esi
  80034c:	ff 75 10             	pushl  0x10(%ebp)
  80034f:	e8 53 00 00 00       	call   8003a7 <vcprintf>
	cprintf("\n");
  800354:	c7 04 24 89 24 80 00 	movl   $0x802489,(%esp)
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
  800460:	e8 8b 1d 00 00       	call   8021f0 <__udivdi3>
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
  80049c:	e8 6b 1e 00 00       	call   80230c <__umoddi3>
  8004a1:	83 c4 14             	add    $0x14,%esp
  8004a4:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
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
  8005e8:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
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
  800694:	8b 04 85 60 28 80 00 	mov    0x802860(,%eax,4),%eax
  80069b:	85 c0                	test   %eax,%eax
  80069d:	75 1a                	jne    8006b9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80069f:	52                   	push   %edx
  8006a0:	68 d3 25 80 00       	push   $0x8025d3
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
  8006ba:	68 15 2b 80 00       	push   $0x802b15
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
  8006f0:	c7 45 d0 cc 25 80 00 	movl   $0x8025cc,-0x30(%ebp)
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
  800d5e:	68 bf 28 80 00       	push   $0x8028bf
  800d63:	6a 42                	push   $0x42
  800d65:	68 dc 28 80 00       	push   $0x8028dc
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

00800f70 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800f76:	6a 00                	push   $0x0
  800f78:	ff 75 14             	pushl  0x14(%ebp)
  800f7b:	ff 75 10             	pushl  0x10(%ebp)
  800f7e:	ff 75 0c             	pushl  0xc(%ebp)
  800f81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f84:	ba 00 00 00 00       	mov    $0x0,%edx
  800f89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f8e:	e8 99 fd ff ff       	call   800d2c <syscall>
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    
  800f95:	00 00                	add    %al,(%eax)
	...

00800f98 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fa2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800fa4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa8:	75 14                	jne    800fbe <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	68 ec 28 80 00       	push   $0x8028ec
  800fb2:	6a 20                	push   $0x20
  800fb4:	68 30 2a 80 00       	push   $0x802a30
  800fb9:	e8 62 f3 ff ff       	call   800320 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	c1 e8 16             	shr    $0x16,%eax
  800fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	74 11                	je     800fdf <pgfault+0x47>
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fda:	f6 c4 08             	test   $0x8,%ah
  800fdd:	75 14                	jne    800ff3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 10 29 80 00       	push   $0x802910
  800fe7:	6a 24                	push   $0x24
  800fe9:	68 30 2a 80 00       	push   $0x802a30
  800fee:	e8 2d f3 ff ff       	call   800320 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	6a 07                	push   $0x7
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 2c fe ff ff       	call   800e30 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 12                	jns    80101d <pgfault+0x85>
  80100b:	50                   	push   %eax
  80100c:	68 34 29 80 00       	push   $0x802934
  801011:	6a 32                	push   $0x32
  801013:	68 30 2a 80 00       	push   $0x802a30
  801018:	e8 03 f3 ff ff       	call   800320 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  80101d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	68 00 10 00 00       	push   $0x1000
  80102b:	53                   	push   %ebx
  80102c:	68 00 f0 7f 00       	push   $0x7ff000
  801031:	e8 a3 fb ff ff       	call   800bd9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  801036:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80103d:	53                   	push   %ebx
  80103e:	6a 00                	push   $0x0
  801040:	68 00 f0 7f 00       	push   $0x7ff000
  801045:	6a 00                	push   $0x0
  801047:	e8 08 fe ff ff       	call   800e54 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 12                	jns    801065 <pgfault+0xcd>
  801053:	50                   	push   %eax
  801054:	68 58 29 80 00       	push   $0x802958
  801059:	6a 3a                	push   $0x3a
  80105b:	68 30 2a 80 00       	push   $0x802a30
  801060:	e8 bb f2 ff ff       	call   800320 <_panic>

	return;
}
  801065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801073:	68 98 0f 80 00       	push   $0x800f98
  801078:	e8 73 0f 00 00       	call   801ff0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80107d:	ba 07 00 00 00       	mov    $0x7,%edx
  801082:	89 d0                	mov    %edx,%eax
  801084:	cd 30                	int    $0x30
  801086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801089:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 12                	jns    8010a4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  801092:	50                   	push   %eax
  801093:	68 3b 2a 80 00       	push   $0x802a3b
  801098:	6a 7f                	push   $0x7f
  80109a:	68 30 2a 80 00       	push   $0x802a30
  80109f:	e8 7c f2 ff ff       	call   800320 <_panic>
	}
	int r;

	if (childpid == 0) {
  8010a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010a8:	75 25                	jne    8010cf <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  8010aa:	e8 36 fd ff ff       	call   800de5 <sys_getenvid>
  8010af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010bb:	c1 e0 07             	shl    $0x7,%eax
  8010be:	29 d0                	sub    %edx,%eax
  8010c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c5:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  8010ca:	e9 be 01 00 00       	jmp    80128d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  8010cf:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	c1 e8 16             	shr    $0x16,%eax
  8010d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e0:	a8 01                	test   $0x1,%al
  8010e2:	0f 84 10 01 00 00    	je     8011f8 <fork+0x18e>
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	c1 e8 0c             	shr    $0xc,%eax
  8010ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f4:	f6 c2 01             	test   $0x1,%dl
  8010f7:	0f 84 fb 00 00 00    	je     8011f8 <fork+0x18e>
  8010fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801104:	f6 c2 04             	test   $0x4,%dl
  801107:	0f 84 eb 00 00 00    	je     8011f8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80110d:	89 c6                	mov    %eax,%esi
  80110f:	c1 e6 0c             	shl    $0xc,%esi
  801112:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801118:	0f 84 da 00 00 00    	je     8011f8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  80111e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801125:	f6 c6 04             	test   $0x4,%dh
  801128:	74 37                	je     801161 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80112a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	25 07 0e 00 00       	and    $0xe07,%eax
  801139:	50                   	push   %eax
  80113a:	56                   	push   %esi
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	6a 00                	push   $0x0
  80113f:	e8 10 fd ff ff       	call   800e54 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	0f 89 a9 00 00 00    	jns    8011f8 <fork+0x18e>
  80114f:	50                   	push   %eax
  801150:	68 7c 29 80 00       	push   $0x80297c
  801155:	6a 54                	push   $0x54
  801157:	68 30 2a 80 00       	push   $0x802a30
  80115c:	e8 bf f1 ff ff       	call   800320 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801161:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801168:	f6 c2 02             	test   $0x2,%dl
  80116b:	75 0c                	jne    801179 <fork+0x10f>
  80116d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801174:	f6 c4 08             	test   $0x8,%ah
  801177:	74 57                	je     8011d0 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	68 05 08 00 00       	push   $0x805
  801181:	56                   	push   %esi
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	6a 00                	push   $0x0
  801186:	e8 c9 fc ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80118b:	83 c4 20             	add    $0x20,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 12                	jns    8011a4 <fork+0x13a>
  801192:	50                   	push   %eax
  801193:	68 7c 29 80 00       	push   $0x80297c
  801198:	6a 59                	push   $0x59
  80119a:	68 30 2a 80 00       	push   $0x802a30
  80119f:	e8 7c f1 ff ff       	call   800320 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	68 05 08 00 00       	push   $0x805
  8011ac:	56                   	push   %esi
  8011ad:	6a 00                	push   $0x0
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 9d fc ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	79 3a                	jns    8011f8 <fork+0x18e>
  8011be:	50                   	push   %eax
  8011bf:	68 7c 29 80 00       	push   $0x80297c
  8011c4:	6a 5c                	push   $0x5c
  8011c6:	68 30 2a 80 00       	push   $0x802a30
  8011cb:	e8 50 f1 ff ff       	call   800320 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	6a 05                	push   $0x5
  8011d5:	56                   	push   %esi
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	6a 00                	push   $0x0
  8011da:	e8 75 fc ff ff       	call   800e54 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8011df:	83 c4 20             	add    $0x20,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 12                	jns    8011f8 <fork+0x18e>
  8011e6:	50                   	push   %eax
  8011e7:	68 7c 29 80 00       	push   $0x80297c
  8011ec:	6a 60                	push   $0x60
  8011ee:	68 30 2a 80 00       	push   $0x802a30
  8011f3:	e8 28 f1 ff ff       	call   800320 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8011f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011fe:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801204:	0f 85 ca fe ff ff    	jne    8010d4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	6a 07                	push   $0x7
  80120f:	68 00 f0 bf ee       	push   $0xeebff000
  801214:	ff 75 e4             	pushl  -0x1c(%ebp)
  801217:	e8 14 fc ff ff       	call   800e30 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	79 15                	jns    801238 <fork+0x1ce>
  801223:	50                   	push   %eax
  801224:	68 a0 29 80 00       	push   $0x8029a0
  801229:	68 94 00 00 00       	push   $0x94
  80122e:	68 30 2a 80 00       	push   $0x802a30
  801233:	e8 e8 f0 ff ff       	call   800320 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	68 5c 20 80 00       	push   $0x80205c
  801240:	ff 75 e4             	pushl  -0x1c(%ebp)
  801243:	e8 9b fc ff ff       	call   800ee3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	79 15                	jns    801264 <fork+0x1fa>
  80124f:	50                   	push   %eax
  801250:	68 d8 29 80 00       	push   $0x8029d8
  801255:	68 99 00 00 00       	push   $0x99
  80125a:	68 30 2a 80 00       	push   $0x802a30
  80125f:	e8 bc f0 ff ff       	call   800320 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	6a 02                	push   $0x2
  801269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80126c:	e8 2c fc ff ff       	call   800e9d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	79 15                	jns    80128d <fork+0x223>
  801278:	50                   	push   %eax
  801279:	68 fc 29 80 00       	push   $0x8029fc
  80127e:	68 a4 00 00 00       	push   $0xa4
  801283:	68 30 2a 80 00       	push   $0x802a30
  801288:	e8 93 f0 ff ff       	call   800320 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80128d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <sfork>:

// Challenge!
int
sfork(void)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80129e:	68 58 2a 80 00       	push   $0x802a58
  8012a3:	68 b1 00 00 00       	push   $0xb1
  8012a8:	68 30 2a 80 00       	push   $0x802a30
  8012ad:	e8 6e f0 ff ff       	call   800320 <_panic>
	...

008012b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 e5 ff ff ff       	call   8012b4 <fd2num>
  8012cf:	83 c4 04             	add    $0x4,%esp
  8012d2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012d7:	c1 e0 0c             	shl    $0xc,%eax
}
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	53                   	push   %ebx
  8012e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012e8:	a8 01                	test   $0x1,%al
  8012ea:	74 34                	je     801320 <fd_alloc+0x44>
  8012ec:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012f1:	a8 01                	test   $0x1,%al
  8012f3:	74 32                	je     801327 <fd_alloc+0x4b>
  8012f5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012fa:	89 c1                	mov    %eax,%ecx
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	c1 ea 16             	shr    $0x16,%edx
  801301:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801308:	f6 c2 01             	test   $0x1,%dl
  80130b:	74 1f                	je     80132c <fd_alloc+0x50>
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 0c             	shr    $0xc,%edx
  801312:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	75 17                	jne    801335 <fd_alloc+0x59>
  80131e:	eb 0c                	jmp    80132c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801320:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801325:	eb 05                	jmp    80132c <fd_alloc+0x50>
  801327:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80132c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
  801333:	eb 17                	jmp    80134c <fd_alloc+0x70>
  801335:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133f:	75 b9                	jne    8012fa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801341:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801347:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134c:	5b                   	pop    %ebx
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801355:	83 f8 1f             	cmp    $0x1f,%eax
  801358:	77 36                	ja     801390 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80135f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801362:	89 c2                	mov    %eax,%edx
  801364:	c1 ea 16             	shr    $0x16,%edx
  801367:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 24                	je     801397 <fd_lookup+0x48>
  801373:	89 c2                	mov    %eax,%edx
  801375:	c1 ea 0c             	shr    $0xc,%edx
  801378:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137f:	f6 c2 01             	test   $0x1,%dl
  801382:	74 1a                	je     80139e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801384:	8b 55 0c             	mov    0xc(%ebp),%edx
  801387:	89 02                	mov    %eax,(%edx)
	return 0;
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
  80138e:	eb 13                	jmp    8013a3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801390:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801395:	eb 0c                	jmp    8013a3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb 05                	jmp    8013a3 <fd_lookup+0x54>
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013b2:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8013b8:	74 0d                	je     8013c7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bf:	eb 14                	jmp    8013d5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8013c1:	39 0a                	cmp    %ecx,(%edx)
  8013c3:	75 10                	jne    8013d5 <dev_lookup+0x30>
  8013c5:	eb 05                	jmp    8013cc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c7:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8013cc:	89 13                	mov    %edx,(%ebx)
			return 0;
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d3:	eb 31                	jmp    801406 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013d5:	40                   	inc    %eax
  8013d6:	8b 14 85 ec 2a 80 00 	mov    0x802aec(,%eax,4),%edx
  8013dd:	85 d2                	test   %edx,%edx
  8013df:	75 e0                	jne    8013c1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e6:	8b 40 48             	mov    0x48(%eax),%eax
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	51                   	push   %ecx
  8013ed:	50                   	push   %eax
  8013ee:	68 70 2a 80 00       	push   $0x802a70
  8013f3:	e8 00 f0 ff ff       	call   8003f8 <cprintf>
	*dev = 0;
  8013f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	83 ec 20             	sub    $0x20,%esp
  801413:	8b 75 08             	mov    0x8(%ebp),%esi
  801416:	8a 45 0c             	mov    0xc(%ebp),%al
  801419:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80141c:	56                   	push   %esi
  80141d:	e8 92 fe ff ff       	call   8012b4 <fd2num>
  801422:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801425:	89 14 24             	mov    %edx,(%esp)
  801428:	50                   	push   %eax
  801429:	e8 21 ff ff ff       	call   80134f <fd_lookup>
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 08             	add    $0x8,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 05                	js     80143c <fd_close+0x31>
	    || fd != fd2)
  801437:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80143a:	74 0d                	je     801449 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80143c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801440:	75 48                	jne    80148a <fd_close+0x7f>
  801442:	bb 00 00 00 00       	mov    $0x0,%ebx
  801447:	eb 41                	jmp    80148a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 36                	pushl  (%esi)
  801452:	e8 4e ff ff ff       	call   8013a5 <dev_lookup>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 1c                	js     80147c <fd_close+0x71>
		if (dev->dev_close)
  801460:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801463:	8b 40 10             	mov    0x10(%eax),%eax
  801466:	85 c0                	test   %eax,%eax
  801468:	74 0d                	je     801477 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80146a:	83 ec 0c             	sub    $0xc,%esp
  80146d:	56                   	push   %esi
  80146e:	ff d0                	call   *%eax
  801470:	89 c3                	mov    %eax,%ebx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	eb 05                	jmp    80147c <fd_close+0x71>
		else
			r = 0;
  801477:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	56                   	push   %esi
  801480:	6a 00                	push   $0x0
  801482:	e8 f3 f9 ff ff       	call   800e7a <sys_page_unmap>
	return r;
  801487:	83 c4 10             	add    $0x10,%esp
}
  80148a:	89 d8                	mov    %ebx,%eax
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 aa fe ff ff       	call   80134f <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 10                	js     8014bc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	6a 01                	push   $0x1
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	e8 52 ff ff ff       	call   80140b <fd_close>
  8014b9:	83 c4 10             	add    $0x10,%esp
}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <close_all>:

void
close_all(void)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	e8 c0 ff ff ff       	call   801493 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d3:	43                   	inc    %ebx
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	83 fb 20             	cmp    $0x20,%ebx
  8014da:	75 ee                	jne    8014ca <close_all+0xc>
		close(i);
}
  8014dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	57                   	push   %edi
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 2c             	sub    $0x2c,%esp
  8014ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	ff 75 08             	pushl  0x8(%ebp)
  8014f4:	e8 56 fe ff ff       	call   80134f <fd_lookup>
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	0f 88 c0 00 00 00    	js     8015c6 <dup+0xe5>
		return r;
	close(newfdnum);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	57                   	push   %edi
  80150a:	e8 84 ff ff ff       	call   801493 <close>

	newfd = INDEX2FD(newfdnum);
  80150f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801515:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801518:	83 c4 04             	add    $0x4,%esp
  80151b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151e:	e8 a1 fd ff ff       	call   8012c4 <fd2data>
  801523:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801525:	89 34 24             	mov    %esi,(%esp)
  801528:	e8 97 fd ff ff       	call   8012c4 <fd2data>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801533:	89 d8                	mov    %ebx,%eax
  801535:	c1 e8 16             	shr    $0x16,%eax
  801538:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80153f:	a8 01                	test   $0x1,%al
  801541:	74 37                	je     80157a <dup+0x99>
  801543:	89 d8                	mov    %ebx,%eax
  801545:	c1 e8 0c             	shr    $0xc,%eax
  801548:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80154f:	f6 c2 01             	test   $0x1,%dl
  801552:	74 26                	je     80157a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801554:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155b:	83 ec 0c             	sub    $0xc,%esp
  80155e:	25 07 0e 00 00       	and    $0xe07,%eax
  801563:	50                   	push   %eax
  801564:	ff 75 d4             	pushl  -0x2c(%ebp)
  801567:	6a 00                	push   $0x0
  801569:	53                   	push   %ebx
  80156a:	6a 00                	push   $0x0
  80156c:	e8 e3 f8 ff ff       	call   800e54 <sys_page_map>
  801571:	89 c3                	mov    %eax,%ebx
  801573:	83 c4 20             	add    $0x20,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 2d                	js     8015a7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	c1 ea 0c             	shr    $0xc,%edx
  801582:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801592:	52                   	push   %edx
  801593:	56                   	push   %esi
  801594:	6a 00                	push   $0x0
  801596:	50                   	push   %eax
  801597:	6a 00                	push   $0x0
  801599:	e8 b6 f8 ff ff       	call   800e54 <sys_page_map>
  80159e:	89 c3                	mov    %eax,%ebx
  8015a0:	83 c4 20             	add    $0x20,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	79 1d                	jns    8015c4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	56                   	push   %esi
  8015ab:	6a 00                	push   $0x0
  8015ad:	e8 c8 f8 ff ff       	call   800e7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b8:	6a 00                	push   $0x0
  8015ba:	e8 bb f8 ff ff       	call   800e7a <sys_page_unmap>
	return r;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb 02                	jmp    8015c6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015c6:	89 d8                	mov    %ebx,%eax
  8015c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 14             	sub    $0x14,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	53                   	push   %ebx
  8015df:	e8 6b fd ff ff       	call   80134f <fd_lookup>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 67                	js     801652 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	ff 30                	pushl  (%eax)
  8015f7:	e8 a9 fd ff ff       	call   8013a5 <dev_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 4f                	js     801652 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	8b 50 08             	mov    0x8(%eax),%edx
  801609:	83 e2 03             	and    $0x3,%edx
  80160c:	83 fa 01             	cmp    $0x1,%edx
  80160f:	75 21                	jne    801632 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801611:	a1 04 40 80 00       	mov    0x804004,%eax
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	53                   	push   %ebx
  80161d:	50                   	push   %eax
  80161e:	68 b1 2a 80 00       	push   $0x802ab1
  801623:	e8 d0 ed ff ff       	call   8003f8 <cprintf>
		return -E_INVAL;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801630:	eb 20                	jmp    801652 <read+0x82>
	}
	if (!dev->dev_read)
  801632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801635:	8b 52 08             	mov    0x8(%edx),%edx
  801638:	85 d2                	test   %edx,%edx
  80163a:	74 11                	je     80164d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	ff d2                	call   *%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 05                	jmp    801652 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80164d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	57                   	push   %edi
  80165b:	56                   	push   %esi
  80165c:	53                   	push   %ebx
  80165d:	83 ec 0c             	sub    $0xc,%esp
  801660:	8b 7d 08             	mov    0x8(%ebp),%edi
  801663:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801666:	85 f6                	test   %esi,%esi
  801668:	74 31                	je     80169b <readn+0x44>
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
  80166f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	89 f2                	mov    %esi,%edx
  801679:	29 c2                	sub    %eax,%edx
  80167b:	52                   	push   %edx
  80167c:	03 45 0c             	add    0xc(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	57                   	push   %edi
  801681:	e8 4a ff ff ff       	call   8015d0 <read>
		if (m < 0)
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 17                	js     8016a4 <readn+0x4d>
			return m;
		if (m == 0)
  80168d:	85 c0                	test   %eax,%eax
  80168f:	74 11                	je     8016a2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801691:	01 c3                	add    %eax,%ebx
  801693:	89 d8                	mov    %ebx,%eax
  801695:	39 f3                	cmp    %esi,%ebx
  801697:	72 db                	jb     801674 <readn+0x1d>
  801699:	eb 09                	jmp    8016a4 <readn+0x4d>
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a0:	eb 02                	jmp    8016a4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016a2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5f                   	pop    %edi
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 14             	sub    $0x14,%esp
  8016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	53                   	push   %ebx
  8016bb:	e8 8f fc ff ff       	call   80134f <fd_lookup>
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 62                	js     801729 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d1:	ff 30                	pushl  (%eax)
  8016d3:	e8 cd fc ff ff       	call   8013a5 <dev_lookup>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 4a                	js     801729 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e6:	75 21                	jne    801709 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ed:	8b 40 48             	mov    0x48(%eax),%eax
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	53                   	push   %ebx
  8016f4:	50                   	push   %eax
  8016f5:	68 cd 2a 80 00       	push   $0x802acd
  8016fa:	e8 f9 ec ff ff       	call   8003f8 <cprintf>
		return -E_INVAL;
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801707:	eb 20                	jmp    801729 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801709:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170c:	8b 52 0c             	mov    0xc(%edx),%edx
  80170f:	85 d2                	test   %edx,%edx
  801711:	74 11                	je     801724 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	ff 75 10             	pushl  0x10(%ebp)
  801719:	ff 75 0c             	pushl  0xc(%ebp)
  80171c:	50                   	push   %eax
  80171d:	ff d2                	call   *%edx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 05                	jmp    801729 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801724:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <seek>:

int
seek(int fdnum, off_t offset)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801734:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	ff 75 08             	pushl  0x8(%ebp)
  80173b:	e8 0f fc ff ff       	call   80134f <fd_lookup>
  801740:	83 c4 08             	add    $0x8,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	78 0e                	js     801755 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801747:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80174a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801750:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	53                   	push   %ebx
  80175b:	83 ec 14             	sub    $0x14,%esp
  80175e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801761:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801764:	50                   	push   %eax
  801765:	53                   	push   %ebx
  801766:	e8 e4 fb ff ff       	call   80134f <fd_lookup>
  80176b:	83 c4 08             	add    $0x8,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 5f                	js     8017d1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801772:	83 ec 08             	sub    $0x8,%esp
  801775:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801778:	50                   	push   %eax
  801779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177c:	ff 30                	pushl  (%eax)
  80177e:	e8 22 fc ff ff       	call   8013a5 <dev_lookup>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 47                	js     8017d1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801791:	75 21                	jne    8017b4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801793:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801798:	8b 40 48             	mov    0x48(%eax),%eax
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	53                   	push   %ebx
  80179f:	50                   	push   %eax
  8017a0:	68 90 2a 80 00       	push   $0x802a90
  8017a5:	e8 4e ec ff ff       	call   8003f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b2:	eb 1d                	jmp    8017d1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8017b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b7:	8b 52 18             	mov    0x18(%edx),%edx
  8017ba:	85 d2                	test   %edx,%edx
  8017bc:	74 0e                	je     8017cc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	50                   	push   %eax
  8017c5:	ff d2                	call   *%edx
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	eb 05                	jmp    8017d1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 14             	sub    $0x14,%esp
  8017dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	ff 75 08             	pushl  0x8(%ebp)
  8017e7:	e8 63 fb ff ff       	call   80134f <fd_lookup>
  8017ec:	83 c4 08             	add    $0x8,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 52                	js     801845 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fd:	ff 30                	pushl  (%eax)
  8017ff:	e8 a1 fb ff ff       	call   8013a5 <dev_lookup>
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 3a                	js     801845 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801812:	74 2c                	je     801840 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801814:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801817:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181e:	00 00 00 
	stat->st_isdir = 0;
  801821:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801828:	00 00 00 
	stat->st_dev = dev;
  80182b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	53                   	push   %ebx
  801835:	ff 75 f0             	pushl  -0x10(%ebp)
  801838:	ff 50 14             	call   *0x14(%eax)
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	eb 05                	jmp    801845 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801840:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	6a 00                	push   $0x0
  801854:	ff 75 08             	pushl  0x8(%ebp)
  801857:	e8 78 01 00 00       	call   8019d4 <open>
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 1b                	js     801880 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	50                   	push   %eax
  80186c:	e8 65 ff ff ff       	call   8017d6 <fstat>
  801871:	89 c6                	mov    %eax,%esi
	close(fd);
  801873:	89 1c 24             	mov    %ebx,(%esp)
  801876:	e8 18 fc ff ff       	call   801493 <close>
	return r;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	89 f3                	mov    %esi,%ebx
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	c9                   	leave  
  801888:	c3                   	ret    
  801889:	00 00                	add    %al,(%eax)
	...

0080188c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
  801891:	89 c3                	mov    %eax,%ebx
  801893:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801895:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80189c:	75 12                	jne    8018b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	6a 01                	push   $0x1
  8018a3:	e8 a6 08 00 00       	call   80214e <ipc_find_env>
  8018a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b0:	6a 07                	push   $0x7
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	53                   	push   %ebx
  8018b8:	ff 35 00 40 80 00    	pushl  0x804000
  8018be:	e8 36 08 00 00       	call   8020f9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8018c3:	83 c4 0c             	add    $0xc,%esp
  8018c6:	6a 00                	push   $0x0
  8018c8:	56                   	push   %esi
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 b4 07 00 00       	call   802084 <ipc_recv>
}
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	53                   	push   %ebx
  8018db:	83 ec 04             	sub    $0x4,%esp
  8018de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f6:	e8 91 ff ff ff       	call   80188c <fsipc>
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 2c                	js     80192b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	68 00 50 80 00       	push   $0x805000
  801907:	53                   	push   %ebx
  801908:	e8 a1 f0 ff ff       	call   8009ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190d:	a1 80 50 80 00       	mov    0x805080,%eax
  801912:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801918:	a1 84 50 80 00       	mov    0x805084,%eax
  80191d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	8b 40 0c             	mov    0xc(%eax),%eax
  80193c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 06 00 00 00       	mov    $0x6,%eax
  80194b:	e8 3c ff ff ff       	call   80188c <fsipc>
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801965:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 03 00 00 00       	mov    $0x3,%eax
  801975:	e8 12 ff ff ff       	call   80188c <fsipc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 4b                	js     8019cb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801980:	39 c6                	cmp    %eax,%esi
  801982:	73 16                	jae    80199a <devfile_read+0x48>
  801984:	68 fc 2a 80 00       	push   $0x802afc
  801989:	68 03 2b 80 00       	push   $0x802b03
  80198e:	6a 7d                	push   $0x7d
  801990:	68 18 2b 80 00       	push   $0x802b18
  801995:	e8 86 e9 ff ff       	call   800320 <_panic>
	assert(r <= PGSIZE);
  80199a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199f:	7e 16                	jle    8019b7 <devfile_read+0x65>
  8019a1:	68 23 2b 80 00       	push   $0x802b23
  8019a6:	68 03 2b 80 00       	push   $0x802b03
  8019ab:	6a 7e                	push   $0x7e
  8019ad:	68 18 2b 80 00       	push   $0x802b18
  8019b2:	e8 69 e9 ff ff       	call   800320 <_panic>
	memmove(buf, &fsipcbuf, r);
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	50                   	push   %eax
  8019bb:	68 00 50 80 00       	push   $0x805000
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	e8 a7 f1 ff ff       	call   800b6f <memmove>
	return r;
  8019c8:	83 c4 10             	add    $0x10,%esp
}
  8019cb:	89 d8                	mov    %ebx,%eax
  8019cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 1c             	sub    $0x1c,%esp
  8019dc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019df:	56                   	push   %esi
  8019e0:	e8 77 ef ff ff       	call   80095c <strlen>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ed:	7f 65                	jg     801a54 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	e8 e1 f8 ff ff       	call   8012dc <fd_alloc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 55                	js     801a59 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	56                   	push   %esi
  801a08:	68 00 50 80 00       	push   $0x805000
  801a0d:	e8 9c ef ff ff       	call   8009ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	e8 65 fe ff ff       	call   80188c <fsipc>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	79 12                	jns    801a42 <open+0x6e>
		fd_close(fd, 0);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	6a 00                	push   $0x0
  801a35:	ff 75 f4             	pushl  -0xc(%ebp)
  801a38:	e8 ce f9 ff ff       	call   80140b <fd_close>
		return r;
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	eb 17                	jmp    801a59 <open+0x85>
	}

	return fd2num(fd);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 f4             	pushl  -0xc(%ebp)
  801a48:	e8 67 f8 ff ff       	call   8012b4 <fd2num>
  801a4d:	89 c3                	mov    %eax,%ebx
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	eb 05                	jmp    801a59 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a54:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a59:	89 d8                	mov    %ebx,%eax
  801a5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    
	...

00801a64 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	ff 75 08             	pushl  0x8(%ebp)
  801a72:	e8 4d f8 ff ff       	call   8012c4 <fd2data>
  801a77:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a79:	83 c4 08             	add    $0x8,%esp
  801a7c:	68 2f 2b 80 00       	push   $0x802b2f
  801a81:	56                   	push   %esi
  801a82:	e8 27 ef ff ff       	call   8009ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a87:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8a:	2b 03                	sub    (%ebx),%eax
  801a8c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a92:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a99:	00 00 00 
	stat->st_dev = &devpipe;
  801a9c:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801aa3:	30 80 00 
	return 0;
}
  801aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  801aab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abc:	53                   	push   %ebx
  801abd:	6a 00                	push   $0x0
  801abf:	e8 b6 f3 ff ff       	call   800e7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac4:	89 1c 24             	mov    %ebx,(%esp)
  801ac7:	e8 f8 f7 ff ff       	call   8012c4 <fd2data>
  801acc:	83 c4 08             	add    $0x8,%esp
  801acf:	50                   	push   %eax
  801ad0:	6a 00                	push   $0x0
  801ad2:	e8 a3 f3 ff ff       	call   800e7a <sys_page_unmap>
}
  801ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	57                   	push   %edi
  801ae0:	56                   	push   %esi
  801ae1:	53                   	push   %ebx
  801ae2:	83 ec 1c             	sub    $0x1c,%esp
  801ae5:	89 c7                	mov    %eax,%edi
  801ae7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aea:	a1 04 40 80 00       	mov    0x804004,%eax
  801aef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	57                   	push   %edi
  801af6:	e8 b1 06 00 00       	call   8021ac <pageref>
  801afb:	89 c6                	mov    %eax,%esi
  801afd:	83 c4 04             	add    $0x4,%esp
  801b00:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b03:	e8 a4 06 00 00       	call   8021ac <pageref>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	39 c6                	cmp    %eax,%esi
  801b0d:	0f 94 c0             	sete   %al
  801b10:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b1c:	39 cb                	cmp    %ecx,%ebx
  801b1e:	75 08                	jne    801b28 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5f                   	pop    %edi
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b28:	83 f8 01             	cmp    $0x1,%eax
  801b2b:	75 bd                	jne    801aea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2d:	8b 42 58             	mov    0x58(%edx),%eax
  801b30:	6a 01                	push   $0x1
  801b32:	50                   	push   %eax
  801b33:	53                   	push   %ebx
  801b34:	68 36 2b 80 00       	push   $0x802b36
  801b39:	e8 ba e8 ff ff       	call   8003f8 <cprintf>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	eb a7                	jmp    801aea <_pipeisclosed+0xe>

00801b43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 28             	sub    $0x28,%esp
  801b4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b4f:	56                   	push   %esi
  801b50:	e8 6f f7 ff ff       	call   8012c4 <fd2data>
  801b55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5e:	75 4a                	jne    801baa <devpipe_write+0x67>
  801b60:	bf 00 00 00 00       	mov    $0x0,%edi
  801b65:	eb 56                	jmp    801bbd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b67:	89 da                	mov    %ebx,%edx
  801b69:	89 f0                	mov    %esi,%eax
  801b6b:	e8 6c ff ff ff       	call   801adc <_pipeisclosed>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	75 4d                	jne    801bc1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b74:	e8 90 f2 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b79:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7c:	8b 13                	mov    (%ebx),%edx
  801b7e:	83 c2 20             	add    $0x20,%edx
  801b81:	39 d0                	cmp    %edx,%eax
  801b83:	73 e2                	jae    801b67 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b85:	89 c2                	mov    %eax,%edx
  801b87:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b8d:	79 05                	jns    801b94 <devpipe_write+0x51>
  801b8f:	4a                   	dec    %edx
  801b90:	83 ca e0             	or     $0xffffffe0,%edx
  801b93:	42                   	inc    %edx
  801b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b97:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b9a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b9e:	40                   	inc    %eax
  801b9f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba2:	47                   	inc    %edi
  801ba3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ba6:	77 07                	ja     801baf <devpipe_write+0x6c>
  801ba8:	eb 13                	jmp    801bbd <devpipe_write+0x7a>
  801baa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801baf:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb2:	8b 13                	mov    (%ebx),%edx
  801bb4:	83 c2 20             	add    $0x20,%edx
  801bb7:	39 d0                	cmp    %edx,%eax
  801bb9:	73 ac                	jae    801b67 <devpipe_write+0x24>
  801bbb:	eb c8                	jmp    801b85 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbd:	89 f8                	mov    %edi,%eax
  801bbf:	eb 05                	jmp    801bc6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 18             	sub    $0x18,%esp
  801bd7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bda:	57                   	push   %edi
  801bdb:	e8 e4 f6 ff ff       	call   8012c4 <fd2data>
  801be0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be9:	75 44                	jne    801c2f <devpipe_read+0x61>
  801beb:	be 00 00 00 00       	mov    $0x0,%esi
  801bf0:	eb 4f                	jmp    801c41 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	eb 54                	jmp    801c4a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf6:	89 da                	mov    %ebx,%edx
  801bf8:	89 f8                	mov    %edi,%eax
  801bfa:	e8 dd fe ff ff       	call   801adc <_pipeisclosed>
  801bff:	85 c0                	test   %eax,%eax
  801c01:	75 42                	jne    801c45 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c03:	e8 01 f2 ff ff       	call   800e09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c08:	8b 03                	mov    (%ebx),%eax
  801c0a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c0d:	74 e7                	je     801bf6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c14:	79 05                	jns    801c1b <devpipe_read+0x4d>
  801c16:	48                   	dec    %eax
  801c17:	83 c8 e0             	or     $0xffffffe0,%eax
  801c1a:	40                   	inc    %eax
  801c1b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c22:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c25:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c27:	46                   	inc    %esi
  801c28:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c2b:	77 07                	ja     801c34 <devpipe_read+0x66>
  801c2d:	eb 12                	jmp    801c41 <devpipe_read+0x73>
  801c2f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801c34:	8b 03                	mov    (%ebx),%eax
  801c36:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c39:	75 d4                	jne    801c0f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c3b:	85 f6                	test   %esi,%esi
  801c3d:	75 b3                	jne    801bf2 <devpipe_read+0x24>
  801c3f:	eb b5                	jmp    801bf6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c41:	89 f0                	mov    %esi,%eax
  801c43:	eb 05                	jmp    801c4a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 28             	sub    $0x28,%esp
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 75 f6 ff ff       	call   8012dc <fd_alloc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 24 01 00 00    	js     801d98 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 07 04 00 00       	push   $0x407
  801c7c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 aa f1 ff ff       	call   800e30 <sys_page_alloc>
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	0f 88 05 01 00 00    	js     801d98 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c93:	83 ec 0c             	sub    $0xc,%esp
  801c96:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 3d f6 ff ff       	call   8012dc <fd_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	0f 88 dc 00 00 00    	js     801d88 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cac:	83 ec 04             	sub    $0x4,%esp
  801caf:	68 07 04 00 00       	push   $0x407
  801cb4:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 72 f1 ff ff       	call   800e30 <sys_page_alloc>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	0f 88 bd 00 00 00    	js     801d88 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cd1:	e8 ee f5 ff ff       	call   8012c4 <fd2data>
  801cd6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 c4 0c             	add    $0xc,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	50                   	push   %eax
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 48 f1 ff ff       	call   800e30 <sys_page_alloc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	0f 88 83 00 00 00    	js     801d78 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 e0             	pushl  -0x20(%ebp)
  801cfb:	e8 c4 f5 ff ff       	call   8012c4 <fd2data>
  801d00:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d07:	50                   	push   %eax
  801d08:	6a 00                	push   $0x0
  801d0a:	56                   	push   %esi
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 42 f1 ff ff       	call   800e54 <sys_page_map>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 4f                	js     801d6a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d1b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d24:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d30:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d36:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d39:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d3e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d4b:	e8 64 f5 ff ff       	call   8012b4 <fd2num>
  801d50:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d52:	83 c4 04             	add    $0x4,%esp
  801d55:	ff 75 e0             	pushl  -0x20(%ebp)
  801d58:	e8 57 f5 ff ff       	call   8012b4 <fd2num>
  801d5d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d68:	eb 2e                	jmp    801d98 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	56                   	push   %esi
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 05 f1 ff ff       	call   800e7a <sys_page_unmap>
  801d75:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	ff 75 e0             	pushl  -0x20(%ebp)
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 f5 f0 ff ff       	call   800e7a <sys_page_unmap>
  801d85:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d88:	83 ec 08             	sub    $0x8,%esp
  801d8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 e5 f0 ff ff       	call   800e7a <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dab:	50                   	push   %eax
  801dac:	ff 75 08             	pushl  0x8(%ebp)
  801daf:	e8 9b f5 ff ff       	call   80134f <fd_lookup>
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 18                	js     801dd3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dbb:	83 ec 0c             	sub    $0xc,%esp
  801dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc1:	e8 fe f4 ff ff       	call   8012c4 <fd2data>
	return _pipeisclosed(fd, p);
  801dc6:	89 c2                	mov    %eax,%edx
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	e8 0c fd ff ff       	call   801adc <_pipeisclosed>
  801dd0:	83 c4 10             	add    $0x10,%esp
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    
  801dd5:	00 00                	add    %al,(%eax)
	...

00801dd8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  801de4:	85 c0                	test   %eax,%eax
  801de6:	75 16                	jne    801dfe <wait+0x26>
  801de8:	68 4e 2b 80 00       	push   $0x802b4e
  801ded:	68 03 2b 80 00       	push   $0x802b03
  801df2:	6a 09                	push   $0x9
  801df4:	68 59 2b 80 00       	push   $0x802b59
  801df9:	e8 22 e5 ff ff       	call   800320 <_panic>
	e = &envs[ENVX(envid)];
  801dfe:	89 c6                	mov    %eax,%esi
  801e00:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e06:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	c1 e2 07             	shl    $0x7,%edx
  801e12:	29 ca                	sub    %ecx,%edx
  801e14:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  801e1a:	8b 7a 40             	mov    0x40(%edx),%edi
  801e1d:	39 c7                	cmp    %eax,%edi
  801e1f:	75 37                	jne    801e58 <wait+0x80>
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	c1 e0 07             	shl    $0x7,%eax
  801e26:	29 c8                	sub    %ecx,%eax
  801e28:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  801e2d:	8b 40 50             	mov    0x50(%eax),%eax
  801e30:	85 c0                	test   %eax,%eax
  801e32:	74 24                	je     801e58 <wait+0x80>
  801e34:	c1 e6 07             	shl    $0x7,%esi
  801e37:	29 ce                	sub    %ecx,%esi
  801e39:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  801e3f:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801e45:	e8 bf ef ff ff       	call   800e09 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e4a:	8b 43 40             	mov    0x40(%ebx),%eax
  801e4d:	39 f8                	cmp    %edi,%eax
  801e4f:	75 07                	jne    801e58 <wait+0x80>
  801e51:	8b 46 50             	mov    0x50(%esi),%eax
  801e54:	85 c0                	test   %eax,%eax
  801e56:	75 ed                	jne    801e45 <wait+0x6d>
		sys_yield();
}
  801e58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5f                   	pop    %edi
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e70:	68 64 2b 80 00       	push   $0x802b64
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	e8 31 eb ff ff       	call   8009ae <strcpy>
	return 0;
}
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	57                   	push   %edi
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e94:	74 45                	je     801edb <devcons_write+0x57>
  801e96:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801eab:	83 fb 7f             	cmp    $0x7f,%ebx
  801eae:	76 05                	jbe    801eb5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801eb0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	03 45 0c             	add    0xc(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	57                   	push   %edi
  801ebe:	e8 ac ec ff ff       	call   800b6f <memmove>
		sys_cputs(buf, m);
  801ec3:	83 c4 08             	add    $0x8,%esp
  801ec6:	53                   	push   %ebx
  801ec7:	57                   	push   %edi
  801ec8:	e8 ac ee ff ff       	call   800d79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecd:	01 de                	add    %ebx,%esi
  801ecf:	89 f0                	mov    %esi,%eax
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed7:	72 cd                	jb     801ea6 <devcons_write+0x22>
  801ed9:	eb 05                	jmp    801ee0 <devcons_write+0x5c>
  801edb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ee0:	89 f0                	mov    %esi,%eax
  801ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ef0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ef4:	75 07                	jne    801efd <devcons_read+0x13>
  801ef6:	eb 25                	jmp    801f1d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ef8:	e8 0c ef ff ff       	call   800e09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801efd:	e8 9d ee ff ff       	call   800d9f <sys_cgetc>
  801f02:	85 c0                	test   %eax,%eax
  801f04:	74 f2                	je     801ef8 <devcons_read+0xe>
  801f06:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 1d                	js     801f29 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f0c:	83 f8 04             	cmp    $0x4,%eax
  801f0f:	74 13                	je     801f24 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f14:	88 10                	mov    %dl,(%eax)
	return 1;
  801f16:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1b:	eb 0c                	jmp    801f29 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f22:	eb 05                	jmp    801f29 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f31:	8b 45 08             	mov    0x8(%ebp),%eax
  801f34:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f37:	6a 01                	push   $0x1
  801f39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3c:	50                   	push   %eax
  801f3d:	e8 37 ee ff ff       	call   800d79 <sys_cputs>
  801f42:	83 c4 10             	add    $0x10,%esp
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <getchar>:

int
getchar(void)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f4d:	6a 01                	push   $0x1
  801f4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	6a 00                	push   $0x0
  801f55:	e8 76 f6 ff ff       	call   8015d0 <read>
	if (r < 0)
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 0f                	js     801f70 <getchar+0x29>
		return r;
	if (r < 1)
  801f61:	85 c0                	test   %eax,%eax
  801f63:	7e 06                	jle    801f6b <getchar+0x24>
		return -E_EOF;
	return c;
  801f65:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f69:	eb 05                	jmp    801f70 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f6b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	ff 75 08             	pushl  0x8(%ebp)
  801f7f:	e8 cb f3 ff ff       	call   80134f <fd_lookup>
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 11                	js     801f9c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f94:	39 10                	cmp    %edx,(%eax)
  801f96:	0f 94 c0             	sete   %al
  801f99:	0f b6 c0             	movzbl %al,%eax
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    

00801f9e <opencons>:

int
opencons(void)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa7:	50                   	push   %eax
  801fa8:	e8 2f f3 ff ff       	call   8012dc <fd_alloc>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 3a                	js     801fee <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	68 07 04 00 00       	push   $0x407
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 6a ee ff ff       	call   800e30 <sys_page_alloc>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 21                	js     801fee <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fcd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	50                   	push   %eax
  801fe6:	e8 c9 f2 ff ff       	call   8012b4 <fd2num>
  801feb:	83 c4 10             	add    $0x10,%esp
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ff6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ffd:	75 52                	jne    802051 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801fff:	83 ec 04             	sub    $0x4,%esp
  802002:	6a 07                	push   $0x7
  802004:	68 00 f0 bf ee       	push   $0xeebff000
  802009:	6a 00                	push   $0x0
  80200b:	e8 20 ee ff ff       	call   800e30 <sys_page_alloc>
		if (r < 0) {
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	79 12                	jns    802029 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802017:	50                   	push   %eax
  802018:	68 70 2b 80 00       	push   $0x802b70
  80201d:	6a 24                	push   $0x24
  80201f:	68 8b 2b 80 00       	push   $0x802b8b
  802024:	e8 f7 e2 ff ff       	call   800320 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802029:	83 ec 08             	sub    $0x8,%esp
  80202c:	68 5c 20 80 00       	push   $0x80205c
  802031:	6a 00                	push   $0x0
  802033:	e8 ab ee ff ff       	call   800ee3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	85 c0                	test   %eax,%eax
  80203d:	79 12                	jns    802051 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80203f:	50                   	push   %eax
  802040:	68 9c 2b 80 00       	push   $0x802b9c
  802045:	6a 2a                	push   $0x2a
  802047:	68 8b 2b 80 00       	push   $0x802b8b
  80204c:	e8 cf e2 ff ff       	call   800320 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802051:	8b 45 08             	mov    0x8(%ebp),%eax
  802054:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802059:	c9                   	leave  
  80205a:	c3                   	ret    
	...

0080205c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80205c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80205d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802062:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802064:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802067:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80206b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80206e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802072:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802076:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  802078:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80207b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  80207c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80207f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802080:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802081:	c3                   	ret    
	...

00802084 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	8b 75 08             	mov    0x8(%ebp),%esi
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802092:	85 c0                	test   %eax,%eax
  802094:	74 0e                	je     8020a4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	50                   	push   %eax
  80209a:	e8 8c ee ff ff       	call   800f2b <sys_ipc_recv>
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	eb 10                	jmp    8020b4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	68 00 00 c0 ee       	push   $0xeec00000
  8020ac:	e8 7a ee ff ff       	call   800f2b <sys_ipc_recv>
  8020b1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	75 26                	jne    8020de <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8020b8:	85 f6                	test   %esi,%esi
  8020ba:	74 0a                	je     8020c6 <ipc_recv+0x42>
  8020bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c1:	8b 40 74             	mov    0x74(%eax),%eax
  8020c4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8020c6:	85 db                	test   %ebx,%ebx
  8020c8:	74 0a                	je     8020d4 <ipc_recv+0x50>
  8020ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cf:	8b 40 78             	mov    0x78(%eax),%eax
  8020d2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8020d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d9:	8b 40 70             	mov    0x70(%eax),%eax
  8020dc:	eb 14                	jmp    8020f2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8020de:	85 f6                	test   %esi,%esi
  8020e0:	74 06                	je     8020e8 <ipc_recv+0x64>
  8020e2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8020e8:	85 db                	test   %ebx,%ebx
  8020ea:	74 06                	je     8020f2 <ipc_recv+0x6e>
  8020ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8020f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	57                   	push   %edi
  8020fd:	56                   	push   %esi
  8020fe:	53                   	push   %ebx
  8020ff:	83 ec 0c             	sub    $0xc,%esp
  802102:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802105:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802108:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80210b:	85 db                	test   %ebx,%ebx
  80210d:	75 25                	jne    802134 <ipc_send+0x3b>
  80210f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802114:	eb 1e                	jmp    802134 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802116:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802119:	75 07                	jne    802122 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80211b:	e8 e9 ec ff ff       	call   800e09 <sys_yield>
  802120:	eb 12                	jmp    802134 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802122:	50                   	push   %eax
  802123:	68 c4 2b 80 00       	push   $0x802bc4
  802128:	6a 43                	push   $0x43
  80212a:	68 d7 2b 80 00       	push   $0x802bd7
  80212f:	e8 ec e1 ff ff       	call   800320 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802134:	56                   	push   %esi
  802135:	53                   	push   %ebx
  802136:	57                   	push   %edi
  802137:	ff 75 08             	pushl  0x8(%ebp)
  80213a:	e8 c7 ed ff ff       	call   800f06 <sys_ipc_try_send>
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	85 c0                	test   %eax,%eax
  802144:	75 d0                	jne    802116 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802146:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802149:	5b                   	pop    %ebx
  80214a:	5e                   	pop    %esi
  80214b:	5f                   	pop    %edi
  80214c:	c9                   	leave  
  80214d:	c3                   	ret    

0080214e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	53                   	push   %ebx
  802152:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802155:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80215b:	74 22                	je     80217f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80215d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802162:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802169:	89 c2                	mov    %eax,%edx
  80216b:	c1 e2 07             	shl    $0x7,%edx
  80216e:	29 ca                	sub    %ecx,%edx
  802170:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802176:	8b 52 50             	mov    0x50(%edx),%edx
  802179:	39 da                	cmp    %ebx,%edx
  80217b:	75 1d                	jne    80219a <ipc_find_env+0x4c>
  80217d:	eb 05                	jmp    802184 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802184:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80218b:	c1 e0 07             	shl    $0x7,%eax
  80218e:	29 d0                	sub    %edx,%eax
  802190:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802195:	8b 40 40             	mov    0x40(%eax),%eax
  802198:	eb 0c                	jmp    8021a6 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219a:	40                   	inc    %eax
  80219b:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a0:	75 c0                	jne    802162 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a2:	66 b8 00 00          	mov    $0x0,%ax
}
  8021a6:	5b                   	pop    %ebx
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    
  8021a9:	00 00                	add    %al,(%eax)
	...

008021ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b2:	89 c2                	mov    %eax,%edx
  8021b4:	c1 ea 16             	shr    $0x16,%edx
  8021b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021be:	f6 c2 01             	test   $0x1,%dl
  8021c1:	74 1e                	je     8021e1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c3:	c1 e8 0c             	shr    $0xc,%eax
  8021c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021cd:	a8 01                	test   $0x1,%al
  8021cf:	74 17                	je     8021e8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d1:	c1 e8 0c             	shr    $0xc,%eax
  8021d4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021db:	ef 
  8021dc:	0f b7 c0             	movzwl %ax,%eax
  8021df:	eb 0c                	jmp    8021ed <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8021e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e6:	eb 05                	jmp    8021ed <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    
	...

008021f0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	57                   	push   %edi
  8021f4:	56                   	push   %esi
  8021f5:	83 ec 10             	sub    $0x10,%esp
  8021f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021fe:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802201:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802204:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802207:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80220a:	85 c0                	test   %eax,%eax
  80220c:	75 2e                	jne    80223c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80220e:	39 f1                	cmp    %esi,%ecx
  802210:	77 5a                	ja     80226c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802212:	85 c9                	test   %ecx,%ecx
  802214:	75 0b                	jne    802221 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f1                	div    %ecx
  80221f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802221:	31 d2                	xor    %edx,%edx
  802223:	89 f0                	mov    %esi,%eax
  802225:	f7 f1                	div    %ecx
  802227:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802229:	89 f8                	mov    %edi,%eax
  80222b:	f7 f1                	div    %ecx
  80222d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80222f:	89 f8                	mov    %edi,%eax
  802231:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	c9                   	leave  
  802239:	c3                   	ret    
  80223a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80223c:	39 f0                	cmp    %esi,%eax
  80223e:	77 1c                	ja     80225c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802240:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802243:	83 f7 1f             	xor    $0x1f,%edi
  802246:	75 3c                	jne    802284 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802248:	39 f0                	cmp    %esi,%eax
  80224a:	0f 82 90 00 00 00    	jb     8022e0 <__udivdi3+0xf0>
  802250:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802253:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802256:	0f 86 84 00 00 00    	jbe    8022e0 <__udivdi3+0xf0>
  80225c:	31 f6                	xor    %esi,%esi
  80225e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802260:	89 f8                	mov    %edi,%eax
  802262:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	c9                   	leave  
  80226a:	c3                   	ret    
  80226b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80226c:	89 f2                	mov    %esi,%edx
  80226e:	89 f8                	mov    %edi,%eax
  802270:	f7 f1                	div    %ecx
  802272:	89 c7                	mov    %eax,%edi
  802274:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802276:	89 f8                	mov    %edi,%eax
  802278:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	5e                   	pop    %esi
  80227e:	5f                   	pop    %edi
  80227f:	c9                   	leave  
  802280:	c3                   	ret    
  802281:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802284:	89 f9                	mov    %edi,%ecx
  802286:	d3 e0                	shl    %cl,%eax
  802288:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80228b:	b8 20 00 00 00       	mov    $0x20,%eax
  802290:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802295:	88 c1                	mov    %al,%cl
  802297:	d3 ea                	shr    %cl,%edx
  802299:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80229c:	09 ca                	or     %ecx,%edx
  80229e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8022a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022a4:	89 f9                	mov    %edi,%ecx
  8022a6:	d3 e2                	shl    %cl,%edx
  8022a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8022ab:	89 f2                	mov    %esi,%edx
  8022ad:	88 c1                	mov    %al,%cl
  8022af:	d3 ea                	shr    %cl,%edx
  8022b1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8022b4:	89 f2                	mov    %esi,%edx
  8022b6:	89 f9                	mov    %edi,%ecx
  8022b8:	d3 e2                	shl    %cl,%edx
  8022ba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022bd:	88 c1                	mov    %al,%cl
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022c3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022c6:	89 f0                	mov    %esi,%eax
  8022c8:	89 ca                	mov    %ecx,%edx
  8022ca:	f7 75 ec             	divl   -0x14(%ebp)
  8022cd:	89 d1                	mov    %edx,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022d1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022d4:	39 d1                	cmp    %edx,%ecx
  8022d6:	72 28                	jb     802300 <__udivdi3+0x110>
  8022d8:	74 1a                	je     8022f4 <__udivdi3+0x104>
  8022da:	89 f7                	mov    %esi,%edi
  8022dc:	31 f6                	xor    %esi,%esi
  8022de:	eb 80                	jmp    802260 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022e0:	31 f6                	xor    %esi,%esi
  8022e2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022e7:	89 f8                	mov    %edi,%eax
  8022e9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022eb:	83 c4 10             	add    $0x10,%esp
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    
  8022f2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8022f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022f7:	89 f9                	mov    %edi,%ecx
  8022f9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022fb:	39 c2                	cmp    %eax,%edx
  8022fd:	73 db                	jae    8022da <__udivdi3+0xea>
  8022ff:	90                   	nop
		{
		  q0--;
  802300:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802303:	31 f6                	xor    %esi,%esi
  802305:	e9 56 ff ff ff       	jmp    802260 <__udivdi3+0x70>
	...

0080230c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	57                   	push   %edi
  802310:	56                   	push   %esi
  802311:	83 ec 20             	sub    $0x20,%esp
  802314:	8b 45 08             	mov    0x8(%ebp),%eax
  802317:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80231a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80231d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802320:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802323:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802326:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802329:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80232b:	85 ff                	test   %edi,%edi
  80232d:	75 15                	jne    802344 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80232f:	39 f1                	cmp    %esi,%ecx
  802331:	0f 86 99 00 00 00    	jbe    8023d0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802337:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802339:	89 d0                	mov    %edx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80233d:	83 c4 20             	add    $0x20,%esp
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	c9                   	leave  
  802343:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802344:	39 f7                	cmp    %esi,%edi
  802346:	0f 87 a4 00 00 00    	ja     8023f0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80234c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80234f:	83 f0 1f             	xor    $0x1f,%eax
  802352:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802355:	0f 84 a1 00 00 00    	je     8023fc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80235b:	89 f8                	mov    %edi,%eax
  80235d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802360:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802362:	bf 20 00 00 00       	mov    $0x20,%edi
  802367:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80236a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80236d:	89 f9                	mov    %edi,%ecx
  80236f:	d3 ea                	shr    %cl,%edx
  802371:	09 c2                	or     %eax,%edx
  802373:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802379:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80237c:	d3 e0                	shl    %cl,%eax
  80237e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802381:	89 f2                	mov    %esi,%edx
  802383:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802385:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802388:	d3 e0                	shl    %cl,%eax
  80238a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80238d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802390:	89 f9                	mov    %edi,%ecx
  802392:	d3 e8                	shr    %cl,%eax
  802394:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802396:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802398:	89 f2                	mov    %esi,%edx
  80239a:	f7 75 f0             	divl   -0x10(%ebp)
  80239d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80239f:	f7 65 f4             	mull   -0xc(%ebp)
  8023a2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8023a5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023a7:	39 d6                	cmp    %edx,%esi
  8023a9:	72 71                	jb     80241c <__umoddi3+0x110>
  8023ab:	74 7f                	je     80242c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023b0:	29 c8                	sub    %ecx,%eax
  8023b2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8023b4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 f2                	mov    %esi,%edx
  8023bb:	89 f9                	mov    %edi,%ecx
  8023bd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8023bf:	09 d0                	or     %edx,%eax
  8023c1:	89 f2                	mov    %esi,%edx
  8023c3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023c6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023c8:	83 c4 20             	add    $0x20,%esp
  8023cb:	5e                   	pop    %esi
  8023cc:	5f                   	pop    %edi
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    
  8023cf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023d0:	85 c9                	test   %ecx,%ecx
  8023d2:	75 0b                	jne    8023df <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d9:	31 d2                	xor    %edx,%edx
  8023db:	f7 f1                	div    %ecx
  8023dd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023df:	89 f0                	mov    %esi,%eax
  8023e1:	31 d2                	xor    %edx,%edx
  8023e3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e8:	f7 f1                	div    %ecx
  8023ea:	e9 4a ff ff ff       	jmp    802339 <__umoddi3+0x2d>
  8023ef:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8023f0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023f2:	83 c4 20             	add    $0x20,%esp
  8023f5:	5e                   	pop    %esi
  8023f6:	5f                   	pop    %edi
  8023f7:	c9                   	leave  
  8023f8:	c3                   	ret    
  8023f9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023fc:	39 f7                	cmp    %esi,%edi
  8023fe:	72 05                	jb     802405 <__umoddi3+0xf9>
  802400:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802403:	77 0c                	ja     802411 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802405:	89 f2                	mov    %esi,%edx
  802407:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80240a:	29 c8                	sub    %ecx,%eax
  80240c:	19 fa                	sbb    %edi,%edx
  80240e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802411:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802414:	83 c4 20             	add    $0x20,%esp
  802417:	5e                   	pop    %esi
  802418:	5f                   	pop    %edi
  802419:	c9                   	leave  
  80241a:	c3                   	ret    
  80241b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80241c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80241f:	89 c1                	mov    %eax,%ecx
  802421:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802424:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802427:	eb 84                	jmp    8023ad <__umoddi3+0xa1>
  802429:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80242c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80242f:	72 eb                	jb     80241c <__umoddi3+0x110>
  802431:	89 f2                	mov    %esi,%edx
  802433:	e9 75 ff ff ff       	jmp    8023ad <__umoddi3+0xa1>
