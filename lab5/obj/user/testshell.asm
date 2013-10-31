
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 63 04 00 00       	call   800494 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 84 00 00 00    	sub    $0x84,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	53                   	push   %ebx
  80004a:	57                   	push   %edi
  80004b:	e8 96 18 00 00       	call   8018e6 <seek>
	seek(kfd, off);
  800050:	83 c4 08             	add    $0x8,%esp
  800053:	53                   	push   %ebx
  800054:	56                   	push   %esi
  800055:	e8 8c 18 00 00       	call   8018e6 <seek>

	cprintf("shell produced incorrect output.\n");
  80005a:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  800061:	e8 72 05 00 00       	call   8005d8 <cprintf>
	cprintf("expected:\n===\n");
  800066:	c7 04 24 0b 2b 80 00 	movl   $0x802b0b,(%esp)
  80006d:	e8 66 05 00 00       	call   8005d8 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800078:	eb 0d                	jmp    800087 <wrong+0x53>
		sys_cputs(buf, n);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	50                   	push   %eax
  80007e:	53                   	push   %ebx
  80007f:	e8 d5 0e 00 00       	call   800f59 <sys_cputs>
  800084:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800087:	83 ec 04             	sub    $0x4,%esp
  80008a:	6a 63                	push   $0x63
  80008c:	53                   	push   %ebx
  80008d:	56                   	push   %esi
  80008e:	e8 f5 16 00 00       	call   801788 <read>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	7f e0                	jg     80007a <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 1a 2b 80 00       	push   $0x802b1a
  8000a2:	e8 31 05 00 00       	call   8005d8 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ad:	eb 0d                	jmp    8000bc <wrong+0x88>
		sys_cputs(buf, n);
  8000af:	83 ec 08             	sub    $0x8,%esp
  8000b2:	50                   	push   %eax
  8000b3:	53                   	push   %ebx
  8000b4:	e8 a0 0e 00 00       	call   800f59 <sys_cputs>
  8000b9:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	6a 63                	push   $0x63
  8000c1:	53                   	push   %ebx
  8000c2:	57                   	push   %edi
  8000c3:	e8 c0 16 00 00       	call   801788 <read>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f e0                	jg     8000af <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	68 15 2b 80 00       	push   $0x802b15
  8000d7:	e8 fc 04 00 00       	call   8005d8 <cprintf>
	exit();
  8000dc:	e8 03 04 00 00       	call   8004e4 <exit>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 4f 15 00 00       	call   80164b <close>
	close(1);
  8000fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800103:	e8 43 15 00 00       	call   80164b <close>
	opencons();
  800108:	e8 35 03 00 00       	call   800442 <opencons>
	opencons();
  80010d:	e8 30 03 00 00       	call   800442 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 00                	push   $0x0
  800117:	68 28 2b 80 00       	push   $0x802b28
  80011c:	e8 6b 1a 00 00       	call   801b8c <open>
  800121:	89 c6                	mov    %eax,%esi
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	85 c0                	test   %eax,%eax
  800128:	79 12                	jns    80013c <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  80012a:	50                   	push   %eax
  80012b:	68 35 2b 80 00       	push   $0x802b35
  800130:	6a 13                	push   $0x13
  800132:	68 4b 2b 80 00       	push   $0x802b4b
  800137:	e8 c4 03 00 00       	call   800500 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 fa 22 00 00       	call   802442 <pipe>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	79 12                	jns    800161 <umain+0x75>
		panic("pipe: %e", wfd);
  80014f:	50                   	push   %eax
  800150:	68 5c 2b 80 00       	push   $0x802b5c
  800155:	6a 15                	push   $0x15
  800157:	68 4b 2b 80 00       	push   $0x802b4b
  80015c:	e8 9f 03 00 00       	call   800500 <_panic>
	wfd = pfds[1];
  800161:	8b 7d e0             	mov    -0x20(%ebp),%edi

	cprintf("running sh -x < testshell.sh | cat\n");
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	68 c4 2a 80 00       	push   $0x802ac4
  80016c:	e8 67 04 00 00       	call   8005d8 <cprintf>
	if ((r = fork()) < 0)
  800171:	e8 ac 10 00 00       	call   801222 <fork>
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	79 12                	jns    80018f <umain+0xa3>
		panic("fork: %e", r);
  80017d:	50                   	push   %eax
  80017e:	68 65 2b 80 00       	push   $0x802b65
  800183:	6a 1a                	push   $0x1a
  800185:	68 4b 2b 80 00       	push   $0x802b4b
  80018a:	e8 71 03 00 00       	call   800500 <_panic>
	if (r == 0) {
  80018f:	85 c0                	test   %eax,%eax
  800191:	75 7d                	jne    800210 <umain+0x124>
		dup(rfd, 0);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	6a 00                	push   $0x0
  800198:	56                   	push   %esi
  800199:	e8 fb 14 00 00       	call   801699 <dup>
		dup(wfd, 1);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	6a 01                	push   $0x1
  8001a3:	57                   	push   %edi
  8001a4:	e8 f0 14 00 00       	call   801699 <dup>
		close(rfd);
  8001a9:	89 34 24             	mov    %esi,(%esp)
  8001ac:	e8 9a 14 00 00       	call   80164b <close>
		close(wfd);
  8001b1:	89 3c 24             	mov    %edi,(%esp)
  8001b4:	e8 92 14 00 00       	call   80164b <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b9:	6a 00                	push   $0x0
  8001bb:	68 6e 2b 80 00       	push   $0x802b6e
  8001c0:	68 32 2b 80 00       	push   $0x802b32
  8001c5:	68 71 2b 80 00       	push   $0x802b71
  8001ca:	e8 fd 1f 00 00       	call   8021cc <spawnl>
  8001cf:	89 c3                	mov    %eax,%ebx
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	79 12                	jns    8001ea <umain+0xfe>
			panic("spawn: %e", r);
  8001d8:	50                   	push   %eax
  8001d9:	68 75 2b 80 00       	push   $0x802b75
  8001de:	6a 21                	push   $0x21
  8001e0:	68 4b 2b 80 00       	push   $0x802b4b
  8001e5:	e8 16 03 00 00       	call   800500 <_panic>
		close(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 57 14 00 00       	call   80164b <close>
		close(1);
  8001f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fb:	e8 4b 14 00 00       	call   80164b <close>
		wait(r);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 c0 23 00 00       	call   8025c8 <wait>
		exit();
  800208:	e8 d7 02 00 00       	call   8004e4 <exit>
  80020d:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	56                   	push   %esi
  800214:	e8 32 14 00 00       	call   80164b <close>
	close(wfd);
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	e8 2a 14 00 00       	call   80164b <close>

	rfd = pfds[0];
  800221:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800224:	83 c4 08             	add    $0x8,%esp
  800227:	6a 00                	push   $0x0
  800229:	68 7f 2b 80 00       	push   $0x802b7f
  80022e:	e8 59 19 00 00       	call   801b8c <open>
  800233:	89 c6                	mov    %eax,%esi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x162>
		panic("open testshell.key for reading: %e", kfd);
  80023c:	50                   	push   %eax
  80023d:	68 e8 2a 80 00       	push   $0x802ae8
  800242:	6a 2c                	push   $0x2c
  800244:	68 4b 2b 80 00       	push   $0x802b4b
  800249:	e8 b2 02 00 00       	call   800500 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  80024e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800255:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025c:	83 ec 04             	sub    $0x4,%esp
  80025f:	6a 01                	push   $0x1
  800261:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	57                   	push   %edi
  800266:	e8 1d 15 00 00       	call   801788 <read>
  80026b:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026d:	83 c4 0c             	add    $0xc,%esp
  800270:	6a 01                	push   $0x1
  800272:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	56                   	push   %esi
  800277:	e8 0c 15 00 00       	call   801788 <read>
		if (n1 < 0)
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 db                	test   %ebx,%ebx
  800281:	79 12                	jns    800295 <umain+0x1a9>
			panic("reading testshell.out: %e", n1);
  800283:	53                   	push   %ebx
  800284:	68 8d 2b 80 00       	push   $0x802b8d
  800289:	6a 33                	push   $0x33
  80028b:	68 4b 2b 80 00       	push   $0x802b4b
  800290:	e8 6b 02 00 00       	call   800500 <_panic>
		if (n2 < 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	79 12                	jns    8002ab <umain+0x1bf>
			panic("reading testshell.key: %e", n2);
  800299:	50                   	push   %eax
  80029a:	68 a7 2b 80 00       	push   $0x802ba7
  80029f:	6a 35                	push   $0x35
  8002a1:	68 4b 2b 80 00       	push   $0x802b4b
  8002a6:	e8 55 02 00 00       	call   800500 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	75 06                	jne    8002b5 <umain+0x1c9>
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	75 14                	jne    8002c7 <umain+0x1db>
  8002b3:	eb 36                	jmp    8002eb <umain+0x1ff>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b5:	83 fb 01             	cmp    $0x1,%ebx
  8002b8:	75 0d                	jne    8002c7 <umain+0x1db>
  8002ba:	83 f8 01             	cmp    $0x1,%eax
  8002bd:	75 08                	jne    8002c7 <umain+0x1db>
  8002bf:	8a 45 e6             	mov    -0x1a(%ebp),%al
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 10                	je     8002d7 <umain+0x1eb>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8002cd:	56                   	push   %esi
  8002ce:	57                   	push   %edi
  8002cf:	e8 60 fd ff ff       	call   800034 <wrong>
  8002d4:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
  8002d7:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002db:	75 06                	jne    8002e3 <umain+0x1f7>
  8002dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e3:	ff 45 d4             	incl   -0x2c(%ebp)
			nloff = off+1;
	}
  8002e6:	e9 71 ff ff ff       	jmp    80025c <umain+0x170>
	cprintf("shell ran correctly\n");
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	68 c1 2b 80 00       	push   $0x802bc1
  8002f3:	e8 e0 02 00 00       	call   8005d8 <cprintf>
	: "c" (msr), "a" (val1), "d" (val2))

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f8:	cc                   	int3   
  8002f9:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8002fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800307:	b8 00 00 00 00       	mov    $0x0,%eax
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800314:	68 d6 2b 80 00       	push   $0x802bd6
  800319:	ff 75 0c             	pushl  0xc(%ebp)
  80031c:	e8 6d 08 00 00       	call   800b8e <strcpy>
	return 0;
}
  800321:	b8 00 00 00 00       	mov    $0x0,%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800334:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800338:	74 45                	je     80037f <devcons_write+0x57>
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
  80033f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800344:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80034a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80034f:	83 fb 7f             	cmp    $0x7f,%ebx
  800352:	76 05                	jbe    800359 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800354:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	53                   	push   %ebx
  80035d:	03 45 0c             	add    0xc(%ebp),%eax
  800360:	50                   	push   %eax
  800361:	57                   	push   %edi
  800362:	e8 e8 09 00 00       	call   800d4f <memmove>
		sys_cputs(buf, m);
  800367:	83 c4 08             	add    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	57                   	push   %edi
  80036c:	e8 e8 0b 00 00       	call   800f59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800371:	01 de                	add    %ebx,%esi
  800373:	89 f0                	mov    %esi,%eax
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	3b 75 10             	cmp    0x10(%ebp),%esi
  80037b:	72 cd                	jb     80034a <devcons_write+0x22>
  80037d:	eb 05                	jmp    800384 <devcons_write+0x5c>
  80037f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800384:	89 f0                	mov    %esi,%eax
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800394:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800398:	75 07                	jne    8003a1 <devcons_read+0x13>
  80039a:	eb 25                	jmp    8003c1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80039c:	e8 48 0c 00 00       	call   800fe9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8003a1:	e8 d9 0b 00 00       	call   800f7f <sys_cgetc>
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	74 f2                	je     80039c <devcons_read+0xe>
  8003aa:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	78 1d                	js     8003cd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8003b0:	83 f8 04             	cmp    $0x4,%eax
  8003b3:	74 13                	je     8003c8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b8:	88 10                	mov    %dl,(%eax)
	return 1;
  8003ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8003bf:	eb 0c                	jmp    8003cd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8003c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c6:	eb 05                	jmp    8003cd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003cd:	c9                   	leave  
  8003ce:	c3                   	ret    

008003cf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003db:	6a 01                	push   $0x1
  8003dd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003e0:	50                   	push   %eax
  8003e1:	e8 73 0b 00 00       	call   800f59 <sys_cputs>
  8003e6:	83 c4 10             	add    $0x10,%esp
}
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <getchar>:

int
getchar(void)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003f1:	6a 01                	push   $0x1
  8003f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	6a 00                	push   $0x0
  8003f9:	e8 8a 13 00 00       	call   801788 <read>
	if (r < 0)
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	85 c0                	test   %eax,%eax
  800403:	78 0f                	js     800414 <getchar+0x29>
		return r;
	if (r < 1)
  800405:	85 c0                	test   %eax,%eax
  800407:	7e 06                	jle    80040f <getchar+0x24>
		return -E_EOF;
	return c;
  800409:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80040d:	eb 05                	jmp    800414 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80040f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80041c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80041f:	50                   	push   %eax
  800420:	ff 75 08             	pushl  0x8(%ebp)
  800423:	e8 df 10 00 00       	call   801507 <fd_lookup>
  800428:	83 c4 10             	add    $0x10,%esp
  80042b:	85 c0                	test   %eax,%eax
  80042d:	78 11                	js     800440 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80042f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800432:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800438:	39 10                	cmp    %edx,(%eax)
  80043a:	0f 94 c0             	sete   %al
  80043d:	0f b6 c0             	movzbl %al,%eax
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <opencons>:

int
opencons(void)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800448:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80044b:	50                   	push   %eax
  80044c:	e8 43 10 00 00       	call   801494 <fd_alloc>
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 c0                	test   %eax,%eax
  800456:	78 3a                	js     800492 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	68 07 04 00 00       	push   $0x407
  800460:	ff 75 f4             	pushl  -0xc(%ebp)
  800463:	6a 00                	push   $0x0
  800465:	e8 a6 0b 00 00       	call   801010 <sys_page_alloc>
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 c0                	test   %eax,%eax
  80046f:	78 21                	js     800492 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800471:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80047a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80047c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80047f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800486:	83 ec 0c             	sub    $0xc,%esp
  800489:	50                   	push   %eax
  80048a:	e8 dd 0f 00 00       	call   80146c <fd2num>
  80048f:	83 c4 10             	add    $0x10,%esp
}
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80049f:	e8 21 0b 00 00       	call   800fc5 <sys_getenvid>
  8004a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8004b0:	c1 e0 07             	shl    $0x7,%eax
  8004b3:	29 d0                	sub    %edx,%eax
  8004b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ba:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004bf:	85 f6                	test   %esi,%esi
  8004c1:	7e 07                	jle    8004ca <libmain+0x36>
		binaryname = argv[0];
  8004c3:	8b 03                	mov    (%ebx),%eax
  8004c5:	a3 1c 40 80 00       	mov    %eax,0x80401c
	// call user main routine
	umain(argc, argv);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 18 fc ff ff       	call   8000ec <umain>

	// exit gracefully
	exit();
  8004d4:	e8 0b 00 00 00       	call   8004e4 <exit>
  8004d9:	83 c4 10             	add    $0x10,%esp
}
  8004dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004df:	5b                   	pop    %ebx
  8004e0:	5e                   	pop    %esi
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    
	...

008004e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004ea:	e8 87 11 00 00       	call   801676 <close_all>
	sys_env_destroy(0);
  8004ef:	83 ec 0c             	sub    $0xc,%esp
  8004f2:	6a 00                	push   $0x0
  8004f4:	e8 aa 0a 00 00       	call   800fa3 <sys_env_destroy>
  8004f9:	83 c4 10             	add    $0x10,%esp
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    
	...

00800500 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800505:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800508:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  80050e:	e8 b2 0a 00 00       	call   800fc5 <sys_getenvid>
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	ff 75 0c             	pushl  0xc(%ebp)
  800519:	ff 75 08             	pushl  0x8(%ebp)
  80051c:	53                   	push   %ebx
  80051d:	50                   	push   %eax
  80051e:	68 ec 2b 80 00       	push   $0x802bec
  800523:	e8 b0 00 00 00       	call   8005d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800528:	83 c4 18             	add    $0x18,%esp
  80052b:	56                   	push   %esi
  80052c:	ff 75 10             	pushl  0x10(%ebp)
  80052f:	e8 53 00 00 00       	call   800587 <vcprintf>
	cprintf("\n");
  800534:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  80053b:	e8 98 00 00 00       	call   8005d8 <cprintf>
  800540:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800543:	cc                   	int3   
  800544:	eb fd                	jmp    800543 <_panic+0x43>
	...

00800548 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	53                   	push   %ebx
  80054c:	83 ec 04             	sub    $0x4,%esp
  80054f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800552:	8b 03                	mov    (%ebx),%eax
  800554:	8b 55 08             	mov    0x8(%ebp),%edx
  800557:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80055b:	40                   	inc    %eax
  80055c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80055e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800563:	75 1a                	jne    80057f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	68 ff 00 00 00       	push   $0xff
  80056d:	8d 43 08             	lea    0x8(%ebx),%eax
  800570:	50                   	push   %eax
  800571:	e8 e3 09 00 00       	call   800f59 <sys_cputs>
		b->idx = 0;
  800576:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80057c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80057f:	ff 43 04             	incl   0x4(%ebx)
}
  800582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800590:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800597:	00 00 00 
	b.cnt = 0;
  80059a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005b0:	50                   	push   %eax
  8005b1:	68 48 05 80 00       	push   $0x800548
  8005b6:	e8 82 01 00 00       	call   80073d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005bb:	83 c4 08             	add    $0x8,%esp
  8005be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005ca:	50                   	push   %eax
  8005cb:	e8 89 09 00 00       	call   800f59 <sys_cputs>

	return b.cnt;
}
  8005d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005d6:	c9                   	leave  
  8005d7:	c3                   	ret    

008005d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005e1:	50                   	push   %eax
  8005e2:	ff 75 08             	pushl  0x8(%ebp)
  8005e5:	e8 9d ff ff ff       	call   800587 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	57                   	push   %edi
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	83 ec 2c             	sub    $0x2c,%esp
  8005f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f8:	89 d6                	mov    %edx,%esi
  8005fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800606:	8b 45 10             	mov    0x10(%ebp),%eax
  800609:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80060c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800612:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800619:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80061c:	72 0c                	jb     80062a <printnum+0x3e>
  80061e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800621:	76 07                	jbe    80062a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800623:	4b                   	dec    %ebx
  800624:	85 db                	test   %ebx,%ebx
  800626:	7f 31                	jg     800659 <printnum+0x6d>
  800628:	eb 3f                	jmp    800669 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80062a:	83 ec 0c             	sub    $0xc,%esp
  80062d:	57                   	push   %edi
  80062e:	4b                   	dec    %ebx
  80062f:	53                   	push   %ebx
  800630:	50                   	push   %eax
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	ff 75 d4             	pushl  -0x2c(%ebp)
  800637:	ff 75 d0             	pushl  -0x30(%ebp)
  80063a:	ff 75 dc             	pushl  -0x24(%ebp)
  80063d:	ff 75 d8             	pushl  -0x28(%ebp)
  800640:	e8 0b 22 00 00       	call   802850 <__udivdi3>
  800645:	83 c4 18             	add    $0x18,%esp
  800648:	52                   	push   %edx
  800649:	50                   	push   %eax
  80064a:	89 f2                	mov    %esi,%edx
  80064c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064f:	e8 98 ff ff ff       	call   8005ec <printnum>
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	eb 10                	jmp    800669 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	56                   	push   %esi
  80065d:	57                   	push   %edi
  80065e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800661:	4b                   	dec    %ebx
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 db                	test   %ebx,%ebx
  800667:	7f f0                	jg     800659 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	56                   	push   %esi
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	ff 75 d4             	pushl  -0x2c(%ebp)
  800673:	ff 75 d0             	pushl  -0x30(%ebp)
  800676:	ff 75 dc             	pushl  -0x24(%ebp)
  800679:	ff 75 d8             	pushl  -0x28(%ebp)
  80067c:	e8 eb 22 00 00       	call   80296c <__umoddi3>
  800681:	83 c4 14             	add    $0x14,%esp
  800684:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  80068b:	50                   	push   %eax
  80068c:	ff 55 e4             	call   *-0x1c(%ebp)
  80068f:	83 c4 10             	add    $0x10,%esp
}
  800692:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80069d:	83 fa 01             	cmp    $0x1,%edx
  8006a0:	7e 0e                	jle    8006b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	8b 52 04             	mov    0x4(%edx),%edx
  8006ae:	eb 22                	jmp    8006d2 <getuint+0x38>
	else if (lflag)
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	74 10                	je     8006c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b9:	89 08                	mov    %ecx,(%eax)
  8006bb:	8b 02                	mov    (%edx),%eax
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c2:	eb 0e                	jmp    8006d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c9:	89 08                	mov    %ecx,(%eax)
  8006cb:	8b 02                	mov    (%edx),%eax
  8006cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d7:	83 fa 01             	cmp    $0x1,%edx
  8006da:	7e 0e                	jle    8006ea <getint+0x16>
		return va_arg(*ap, long long);
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e1:	89 08                	mov    %ecx,(%eax)
  8006e3:	8b 02                	mov    (%edx),%eax
  8006e5:	8b 52 04             	mov    0x4(%edx),%edx
  8006e8:	eb 1a                	jmp    800704 <getint+0x30>
	else if (lflag)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 0c                	je     8006fa <getint+0x26>
		return va_arg(*ap, long);
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f3:	89 08                	mov    %ecx,(%eax)
  8006f5:	8b 02                	mov    (%edx),%eax
  8006f7:	99                   	cltd   
  8006f8:	eb 0a                	jmp    800704 <getint+0x30>
	else
		return va_arg(*ap, int);
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ff:	89 08                	mov    %ecx,(%eax)
  800701:	8b 02                	mov    (%edx),%eax
  800703:	99                   	cltd   
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80070c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	3b 50 04             	cmp    0x4(%eax),%edx
  800714:	73 08                	jae    80071e <sprintputch+0x18>
		*b->buf++ = ch;
  800716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800719:	88 0a                	mov    %cl,(%edx)
  80071b:	42                   	inc    %edx
  80071c:	89 10                	mov    %edx,(%eax)
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 05 00 00 00       	call   80073d <vprintfmt>
	va_end(ap);
  800738:	83 c4 10             	add    $0x10,%esp
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	57                   	push   %edi
  800741:	56                   	push   %esi
  800742:	53                   	push   %ebx
  800743:	83 ec 2c             	sub    $0x2c,%esp
  800746:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800749:	8b 75 10             	mov    0x10(%ebp),%esi
  80074c:	eb 13                	jmp    800761 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80074e:	85 c0                	test   %eax,%eax
  800750:	0f 84 6d 03 00 00    	je     800ac3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	57                   	push   %edi
  80075a:	50                   	push   %eax
  80075b:	ff 55 08             	call   *0x8(%ebp)
  80075e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800761:	0f b6 06             	movzbl (%esi),%eax
  800764:	46                   	inc    %esi
  800765:	83 f8 25             	cmp    $0x25,%eax
  800768:	75 e4                	jne    80074e <vprintfmt+0x11>
  80076a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80076e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800775:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80077c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800783:	b9 00 00 00 00       	mov    $0x0,%ecx
  800788:	eb 28                	jmp    8007b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80078c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800790:	eb 20                	jmp    8007b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800794:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800798:	eb 18                	jmp    8007b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80079c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007a3:	eb 0d                	jmp    8007b2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8a 06                	mov    (%esi),%al
  8007b4:	0f b6 d0             	movzbl %al,%edx
  8007b7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007ba:	83 e8 23             	sub    $0x23,%eax
  8007bd:	3c 55                	cmp    $0x55,%al
  8007bf:	0f 87 e0 02 00 00    	ja     800aa5 <vprintfmt+0x368>
  8007c5:	0f b6 c0             	movzbl %al,%eax
  8007c8:	ff 24 85 60 2d 80 00 	jmp    *0x802d60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007cf:	83 ea 30             	sub    $0x30,%edx
  8007d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8007d5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8007d8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007db:	83 fa 09             	cmp    $0x9,%edx
  8007de:	77 44                	ja     800824 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e0:	89 de                	mov    %ebx,%esi
  8007e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8007e6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8007e9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8007ed:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007f0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007f3:	83 fb 09             	cmp    $0x9,%ebx
  8007f6:	76 ed                	jbe    8007e5 <vprintfmt+0xa8>
  8007f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007fb:	eb 29                	jmp    800826 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 00                	mov    (%eax),%eax
  800808:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80080d:	eb 17                	jmp    800826 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80080f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800813:	78 85                	js     80079a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	89 de                	mov    %ebx,%esi
  800817:	eb 99                	jmp    8007b2 <vprintfmt+0x75>
  800819:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80081b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800822:	eb 8e                	jmp    8007b2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800824:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800826:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80082a:	79 86                	jns    8007b2 <vprintfmt+0x75>
  80082c:	e9 74 ff ff ff       	jmp    8007a5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800831:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800832:	89 de                	mov    %ebx,%esi
  800834:	e9 79 ff ff ff       	jmp    8007b2 <vprintfmt+0x75>
  800839:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	57                   	push   %edi
  800849:	ff 30                	pushl  (%eax)
  80084b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80084e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800854:	e9 08 ff ff ff       	jmp    800761 <vprintfmt+0x24>
  800859:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)
  800865:	8b 00                	mov    (%eax),%eax
  800867:	85 c0                	test   %eax,%eax
  800869:	79 02                	jns    80086d <vprintfmt+0x130>
  80086b:	f7 d8                	neg    %eax
  80086d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086f:	83 f8 0f             	cmp    $0xf,%eax
  800872:	7f 0b                	jg     80087f <vprintfmt+0x142>
  800874:	8b 04 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%eax
  80087b:	85 c0                	test   %eax,%eax
  80087d:	75 1a                	jne    800899 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80087f:	52                   	push   %edx
  800880:	68 27 2c 80 00       	push   $0x802c27
  800885:	57                   	push   %edi
  800886:	ff 75 08             	pushl  0x8(%ebp)
  800889:	e8 92 fe ff ff       	call   800720 <printfmt>
  80088e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800894:	e9 c8 fe ff ff       	jmp    800761 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800899:	50                   	push   %eax
  80089a:	68 75 31 80 00       	push   $0x803175
  80089f:	57                   	push   %edi
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 78 fe ff ff       	call   800720 <printfmt>
  8008a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008ae:	e9 ae fe ff ff       	jmp    800761 <vprintfmt+0x24>
  8008b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8008b6:	89 de                	mov    %ebx,%esi
  8008b8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008be:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c1:	8d 50 04             	lea    0x4(%eax),%edx
  8008c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c7:	8b 00                	mov    (%eax),%eax
  8008c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	75 07                	jne    8008d7 <vprintfmt+0x19a>
				p = "(null)";
  8008d0:	c7 45 d0 20 2c 80 00 	movl   $0x802c20,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8008d7:	85 db                	test   %ebx,%ebx
  8008d9:	7e 42                	jle    80091d <vprintfmt+0x1e0>
  8008db:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008df:	74 3c                	je     80091d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	51                   	push   %ecx
  8008e5:	ff 75 d0             	pushl  -0x30(%ebp)
  8008e8:	e8 6f 02 00 00       	call   800b5c <strnlen>
  8008ed:	29 c3                	sub    %eax,%ebx
  8008ef:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	85 db                	test   %ebx,%ebx
  8008f7:	7e 24                	jle    80091d <vprintfmt+0x1e0>
					putch(padc, putdat);
  8008f9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8008fd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800900:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	57                   	push   %edi
  800907:	53                   	push   %ebx
  800908:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80090b:	4e                   	dec    %esi
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	85 f6                	test   %esi,%esi
  800911:	7f f0                	jg     800903 <vprintfmt+0x1c6>
  800913:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800916:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800920:	0f be 02             	movsbl (%edx),%eax
  800923:	85 c0                	test   %eax,%eax
  800925:	75 47                	jne    80096e <vprintfmt+0x231>
  800927:	eb 37                	jmp    800960 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800929:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80092d:	74 16                	je     800945 <vprintfmt+0x208>
  80092f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800932:	83 fa 5e             	cmp    $0x5e,%edx
  800935:	76 0e                	jbe    800945 <vprintfmt+0x208>
					putch('?', putdat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	57                   	push   %edi
  80093b:	6a 3f                	push   $0x3f
  80093d:	ff 55 08             	call   *0x8(%ebp)
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	eb 0b                	jmp    800950 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800945:	83 ec 08             	sub    $0x8,%esp
  800948:	57                   	push   %edi
  800949:	50                   	push   %eax
  80094a:	ff 55 08             	call   *0x8(%ebp)
  80094d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800950:	ff 4d e4             	decl   -0x1c(%ebp)
  800953:	0f be 03             	movsbl (%ebx),%eax
  800956:	85 c0                	test   %eax,%eax
  800958:	74 03                	je     80095d <vprintfmt+0x220>
  80095a:	43                   	inc    %ebx
  80095b:	eb 1b                	jmp    800978 <vprintfmt+0x23b>
  80095d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800960:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800964:	7f 1e                	jg     800984 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800969:	e9 f3 fd ff ff       	jmp    800761 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800971:	43                   	inc    %ebx
  800972:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800975:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800978:	85 f6                	test   %esi,%esi
  80097a:	78 ad                	js     800929 <vprintfmt+0x1ec>
  80097c:	4e                   	dec    %esi
  80097d:	79 aa                	jns    800929 <vprintfmt+0x1ec>
  80097f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800982:	eb dc                	jmp    800960 <vprintfmt+0x223>
  800984:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	57                   	push   %edi
  80098b:	6a 20                	push   $0x20
  80098d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800990:	4b                   	dec    %ebx
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	85 db                	test   %ebx,%ebx
  800996:	7f ef                	jg     800987 <vprintfmt+0x24a>
  800998:	e9 c4 fd ff ff       	jmp    800761 <vprintfmt+0x24>
  80099d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a0:	89 ca                	mov    %ecx,%edx
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a5:	e8 2a fd ff ff       	call   8006d4 <getint>
  8009aa:	89 c3                	mov    %eax,%ebx
  8009ac:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	78 0a                	js     8009bc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b7:	e9 b0 00 00 00       	jmp    800a6c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	57                   	push   %edi
  8009c0:	6a 2d                	push   $0x2d
  8009c2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009c5:	f7 db                	neg    %ebx
  8009c7:	83 d6 00             	adc    $0x0,%esi
  8009ca:	f7 de                	neg    %esi
  8009cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d4:	e9 93 00 00 00       	jmp    800a6c <vprintfmt+0x32f>
  8009d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009dc:	89 ca                	mov    %ecx,%edx
  8009de:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e1:	e8 b4 fc ff ff       	call   80069a <getuint>
  8009e6:	89 c3                	mov    %eax,%ebx
  8009e8:	89 d6                	mov    %edx,%esi
			base = 10;
  8009ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009ef:	eb 7b                	jmp    800a6c <vprintfmt+0x32f>
  8009f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8009f4:	89 ca                	mov    %ecx,%edx
  8009f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f9:	e8 d6 fc ff ff       	call   8006d4 <getint>
  8009fe:	89 c3                	mov    %eax,%ebx
  800a00:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800a02:	85 d2                	test   %edx,%edx
  800a04:	78 07                	js     800a0d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a06:	b8 08 00 00 00       	mov    $0x8,%eax
  800a0b:	eb 5f                	jmp    800a6c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	57                   	push   %edi
  800a11:	6a 2d                	push   $0x2d
  800a13:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800a16:	f7 db                	neg    %ebx
  800a18:	83 d6 00             	adc    $0x0,%esi
  800a1b:	f7 de                	neg    %esi
  800a1d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800a20:	b8 08 00 00 00       	mov    $0x8,%eax
  800a25:	eb 45                	jmp    800a6c <vprintfmt+0x32f>
  800a27:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	57                   	push   %edi
  800a2e:	6a 30                	push   $0x30
  800a30:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a33:	83 c4 08             	add    $0x8,%esp
  800a36:	57                   	push   %edi
  800a37:	6a 78                	push   $0x78
  800a39:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3f:	8d 50 04             	lea    0x4(%eax),%edx
  800a42:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a45:	8b 18                	mov    (%eax),%ebx
  800a47:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a54:	eb 16                	jmp    800a6c <vprintfmt+0x32f>
  800a56:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a59:	89 ca                	mov    %ecx,%edx
  800a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5e:	e8 37 fc ff ff       	call   80069a <getuint>
  800a63:	89 c3                	mov    %eax,%ebx
  800a65:	89 d6                	mov    %edx,%esi
			base = 16;
  800a67:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800a73:	52                   	push   %edx
  800a74:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a77:	50                   	push   %eax
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	89 fa                	mov    %edi,%edx
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	e8 68 fb ff ff       	call   8005ec <printnum>
			break;
  800a84:	83 c4 20             	add    $0x20,%esp
  800a87:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a8a:	e9 d2 fc ff ff       	jmp    800761 <vprintfmt+0x24>
  800a8f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a92:	83 ec 08             	sub    $0x8,%esp
  800a95:	57                   	push   %edi
  800a96:	52                   	push   %edx
  800a97:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a9a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aa0:	e9 bc fc ff ff       	jmp    800761 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa5:	83 ec 08             	sub    $0x8,%esp
  800aa8:	57                   	push   %edi
  800aa9:	6a 25                	push   $0x25
  800aab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aae:	83 c4 10             	add    $0x10,%esp
  800ab1:	eb 02                	jmp    800ab5 <vprintfmt+0x378>
  800ab3:	89 c6                	mov    %eax,%esi
  800ab5:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ab8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800abc:	75 f5                	jne    800ab3 <vprintfmt+0x376>
  800abe:	e9 9e fc ff ff       	jmp    800761 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 18             	sub    $0x18,%esp
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ada:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ade:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	74 26                	je     800b12 <vsnprintf+0x47>
  800aec:	85 d2                	test   %edx,%edx
  800aee:	7e 29                	jle    800b19 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af0:	ff 75 14             	pushl  0x14(%ebp)
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af9:	50                   	push   %eax
  800afa:	68 06 07 80 00       	push   $0x800706
  800aff:	e8 39 fc ff ff       	call   80073d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	eb 0c                	jmp    800b1e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b17:	eb 05                	jmp    800b1e <vsnprintf+0x53>
  800b19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b29:	50                   	push   %eax
  800b2a:	ff 75 10             	pushl  0x10(%ebp)
  800b2d:	ff 75 0c             	pushl  0xc(%ebp)
  800b30:	ff 75 08             	pushl  0x8(%ebp)
  800b33:	e8 93 ff ff ff       	call   800acb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    
	...

00800b3c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b42:	80 3a 00             	cmpb   $0x0,(%edx)
  800b45:	74 0e                	je     800b55 <strlen+0x19>
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b4c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b4d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b51:	75 f9                	jne    800b4c <strlen+0x10>
  800b53:	eb 05                	jmp    800b5a <strlen+0x1e>
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b65:	85 d2                	test   %edx,%edx
  800b67:	74 17                	je     800b80 <strnlen+0x24>
  800b69:	80 39 00             	cmpb   $0x0,(%ecx)
  800b6c:	74 19                	je     800b87 <strnlen+0x2b>
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b73:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b74:	39 d0                	cmp    %edx,%eax
  800b76:	74 14                	je     800b8c <strnlen+0x30>
  800b78:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b7c:	75 f5                	jne    800b73 <strnlen+0x17>
  800b7e:	eb 0c                	jmp    800b8c <strnlen+0x30>
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	eb 05                	jmp    800b8c <strnlen+0x30>
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	53                   	push   %ebx
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ba0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ba3:	42                   	inc    %edx
  800ba4:	84 c9                	test   %cl,%cl
  800ba6:	75 f5                	jne    800b9d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb2:	53                   	push   %ebx
  800bb3:	e8 84 ff ff ff       	call   800b3c <strlen>
  800bb8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bc1:	50                   	push   %eax
  800bc2:	e8 c7 ff ff ff       	call   800b8e <strcpy>
	return dst;
}
  800bc7:	89 d8                	mov    %ebx,%eax
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bdc:	85 f6                	test   %esi,%esi
  800bde:	74 15                	je     800bf5 <strncpy+0x27>
  800be0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800be5:	8a 1a                	mov    (%edx),%bl
  800be7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bea:	80 3a 01             	cmpb   $0x1,(%edx)
  800bed:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf0:	41                   	inc    %ecx
  800bf1:	39 ce                	cmp    %ecx,%esi
  800bf3:	77 f0                	ja     800be5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c05:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c08:	85 f6                	test   %esi,%esi
  800c0a:	74 32                	je     800c3e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c0c:	83 fe 01             	cmp    $0x1,%esi
  800c0f:	74 22                	je     800c33 <strlcpy+0x3a>
  800c11:	8a 0b                	mov    (%ebx),%cl
  800c13:	84 c9                	test   %cl,%cl
  800c15:	74 20                	je     800c37 <strlcpy+0x3e>
  800c17:	89 f8                	mov    %edi,%eax
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c1e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c21:	88 08                	mov    %cl,(%eax)
  800c23:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c24:	39 f2                	cmp    %esi,%edx
  800c26:	74 11                	je     800c39 <strlcpy+0x40>
  800c28:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800c2c:	42                   	inc    %edx
  800c2d:	84 c9                	test   %cl,%cl
  800c2f:	75 f0                	jne    800c21 <strlcpy+0x28>
  800c31:	eb 06                	jmp    800c39 <strlcpy+0x40>
  800c33:	89 f8                	mov    %edi,%eax
  800c35:	eb 02                	jmp    800c39 <strlcpy+0x40>
  800c37:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c39:	c6 00 00             	movb   $0x0,(%eax)
  800c3c:	eb 02                	jmp    800c40 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800c40:	29 f8                	sub    %edi,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c50:	8a 01                	mov    (%ecx),%al
  800c52:	84 c0                	test   %al,%al
  800c54:	74 10                	je     800c66 <strcmp+0x1f>
  800c56:	3a 02                	cmp    (%edx),%al
  800c58:	75 0c                	jne    800c66 <strcmp+0x1f>
		p++, q++;
  800c5a:	41                   	inc    %ecx
  800c5b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c5c:	8a 01                	mov    (%ecx),%al
  800c5e:	84 c0                	test   %al,%al
  800c60:	74 04                	je     800c66 <strcmp+0x1f>
  800c62:	3a 02                	cmp    (%edx),%al
  800c64:	74 f4                	je     800c5a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c66:	0f b6 c0             	movzbl %al,%eax
  800c69:	0f b6 12             	movzbl (%edx),%edx
  800c6c:	29 d0                	sub    %edx,%eax
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	53                   	push   %ebx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	74 1b                	je     800c9c <strncmp+0x2c>
  800c81:	8a 1a                	mov    (%edx),%bl
  800c83:	84 db                	test   %bl,%bl
  800c85:	74 24                	je     800cab <strncmp+0x3b>
  800c87:	3a 19                	cmp    (%ecx),%bl
  800c89:	75 20                	jne    800cab <strncmp+0x3b>
  800c8b:	48                   	dec    %eax
  800c8c:	74 15                	je     800ca3 <strncmp+0x33>
		n--, p++, q++;
  800c8e:	42                   	inc    %edx
  800c8f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c90:	8a 1a                	mov    (%edx),%bl
  800c92:	84 db                	test   %bl,%bl
  800c94:	74 15                	je     800cab <strncmp+0x3b>
  800c96:	3a 19                	cmp    (%ecx),%bl
  800c98:	74 f1                	je     800c8b <strncmp+0x1b>
  800c9a:	eb 0f                	jmp    800cab <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca1:	eb 05                	jmp    800ca8 <strncmp+0x38>
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cab:	0f b6 02             	movzbl (%edx),%eax
  800cae:	0f b6 11             	movzbl (%ecx),%edx
  800cb1:	29 d0                	sub    %edx,%eax
  800cb3:	eb f3                	jmp    800ca8 <strncmp+0x38>

00800cb5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cbe:	8a 10                	mov    (%eax),%dl
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	74 18                	je     800cdc <strchr+0x27>
		if (*s == c)
  800cc4:	38 ca                	cmp    %cl,%dl
  800cc6:	75 06                	jne    800cce <strchr+0x19>
  800cc8:	eb 17                	jmp    800ce1 <strchr+0x2c>
  800cca:	38 ca                	cmp    %cl,%dl
  800ccc:	74 13                	je     800ce1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cce:	40                   	inc    %eax
  800ccf:	8a 10                	mov    (%eax),%dl
  800cd1:	84 d2                	test   %dl,%dl
  800cd3:	75 f5                	jne    800cca <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cda:	eb 05                	jmp    800ce1 <strchr+0x2c>
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cec:	8a 10                	mov    (%eax),%dl
  800cee:	84 d2                	test   %dl,%dl
  800cf0:	74 11                	je     800d03 <strfind+0x20>
		if (*s == c)
  800cf2:	38 ca                	cmp    %cl,%dl
  800cf4:	75 06                	jne    800cfc <strfind+0x19>
  800cf6:	eb 0b                	jmp    800d03 <strfind+0x20>
  800cf8:	38 ca                	cmp    %cl,%dl
  800cfa:	74 07                	je     800d03 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cfc:	40                   	inc    %eax
  800cfd:	8a 10                	mov    (%eax),%dl
  800cff:	84 d2                	test   %dl,%dl
  800d01:	75 f5                	jne    800cf8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d14:	85 c9                	test   %ecx,%ecx
  800d16:	74 30                	je     800d48 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1e:	75 25                	jne    800d45 <memset+0x40>
  800d20:	f6 c1 03             	test   $0x3,%cl
  800d23:	75 20                	jne    800d45 <memset+0x40>
		c &= 0xFF;
  800d25:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	c1 e3 08             	shl    $0x8,%ebx
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	c1 e6 18             	shl    $0x18,%esi
  800d32:	89 d0                	mov    %edx,%eax
  800d34:	c1 e0 10             	shl    $0x10,%eax
  800d37:	09 f0                	or     %esi,%eax
  800d39:	09 d0                	or     %edx,%eax
  800d3b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d3d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d40:	fc                   	cld    
  800d41:	f3 ab                	rep stos %eax,%es:(%edi)
  800d43:	eb 03                	jmp    800d48 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d45:	fc                   	cld    
  800d46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d48:	89 f8                	mov    %edi,%eax
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d5d:	39 c6                	cmp    %eax,%esi
  800d5f:	73 34                	jae    800d95 <memmove+0x46>
  800d61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d64:	39 d0                	cmp    %edx,%eax
  800d66:	73 2d                	jae    800d95 <memmove+0x46>
		s += n;
		d += n;
  800d68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6b:	f6 c2 03             	test   $0x3,%dl
  800d6e:	75 1b                	jne    800d8b <memmove+0x3c>
  800d70:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d76:	75 13                	jne    800d8b <memmove+0x3c>
  800d78:	f6 c1 03             	test   $0x3,%cl
  800d7b:	75 0e                	jne    800d8b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d7d:	83 ef 04             	sub    $0x4,%edi
  800d80:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d83:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d86:	fd                   	std    
  800d87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d89:	eb 07                	jmp    800d92 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d8b:	4f                   	dec    %edi
  800d8c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8f:	fd                   	std    
  800d90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d92:	fc                   	cld    
  800d93:	eb 20                	jmp    800db5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d95:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d9b:	75 13                	jne    800db0 <memmove+0x61>
  800d9d:	a8 03                	test   $0x3,%al
  800d9f:	75 0f                	jne    800db0 <memmove+0x61>
  800da1:	f6 c1 03             	test   $0x3,%cl
  800da4:	75 0a                	jne    800db0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800da6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800da9:	89 c7                	mov    %eax,%edi
  800dab:	fc                   	cld    
  800dac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dae:	eb 05                	jmp    800db5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800db0:	89 c7                	mov    %eax,%edi
  800db2:	fc                   	cld    
  800db3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dbc:	ff 75 10             	pushl  0x10(%ebp)
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	ff 75 08             	pushl  0x8(%ebp)
  800dc5:	e8 85 ff ff ff       	call   800d4f <memmove>
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	74 32                	je     800e11 <memcmp+0x45>
		if (*s1 != *s2)
  800ddf:	8a 03                	mov    (%ebx),%al
  800de1:	8a 0e                	mov    (%esi),%cl
  800de3:	38 c8                	cmp    %cl,%al
  800de5:	74 19                	je     800e00 <memcmp+0x34>
  800de7:	eb 0d                	jmp    800df6 <memcmp+0x2a>
  800de9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800ded:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800df1:	42                   	inc    %edx
  800df2:	38 c8                	cmp    %cl,%al
  800df4:	74 10                	je     800e06 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800df6:	0f b6 c0             	movzbl %al,%eax
  800df9:	0f b6 c9             	movzbl %cl,%ecx
  800dfc:	29 c8                	sub    %ecx,%eax
  800dfe:	eb 16                	jmp    800e16 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e00:	4f                   	dec    %edi
  800e01:	ba 00 00 00 00       	mov    $0x0,%edx
  800e06:	39 fa                	cmp    %edi,%edx
  800e08:	75 df                	jne    800de9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0f:	eb 05                	jmp    800e16 <memcmp+0x4a>
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e26:	39 d0                	cmp    %edx,%eax
  800e28:	73 12                	jae    800e3c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e2a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800e2d:	38 08                	cmp    %cl,(%eax)
  800e2f:	75 06                	jne    800e37 <memfind+0x1c>
  800e31:	eb 09                	jmp    800e3c <memfind+0x21>
  800e33:	38 08                	cmp    %cl,(%eax)
  800e35:	74 05                	je     800e3c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e37:	40                   	inc    %eax
  800e38:	39 c2                	cmp    %eax,%edx
  800e3a:	77 f7                	ja     800e33 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e4a:	eb 01                	jmp    800e4d <strtol+0xf>
		s++;
  800e4c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e4d:	8a 02                	mov    (%edx),%al
  800e4f:	3c 20                	cmp    $0x20,%al
  800e51:	74 f9                	je     800e4c <strtol+0xe>
  800e53:	3c 09                	cmp    $0x9,%al
  800e55:	74 f5                	je     800e4c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e57:	3c 2b                	cmp    $0x2b,%al
  800e59:	75 08                	jne    800e63 <strtol+0x25>
		s++;
  800e5b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e61:	eb 13                	jmp    800e76 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e63:	3c 2d                	cmp    $0x2d,%al
  800e65:	75 0a                	jne    800e71 <strtol+0x33>
		s++, neg = 1;
  800e67:	8d 52 01             	lea    0x1(%edx),%edx
  800e6a:	bf 01 00 00 00       	mov    $0x1,%edi
  800e6f:	eb 05                	jmp    800e76 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e76:	85 db                	test   %ebx,%ebx
  800e78:	74 05                	je     800e7f <strtol+0x41>
  800e7a:	83 fb 10             	cmp    $0x10,%ebx
  800e7d:	75 28                	jne    800ea7 <strtol+0x69>
  800e7f:	8a 02                	mov    (%edx),%al
  800e81:	3c 30                	cmp    $0x30,%al
  800e83:	75 10                	jne    800e95 <strtol+0x57>
  800e85:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e89:	75 0a                	jne    800e95 <strtol+0x57>
		s += 2, base = 16;
  800e8b:	83 c2 02             	add    $0x2,%edx
  800e8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e93:	eb 12                	jmp    800ea7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800e95:	85 db                	test   %ebx,%ebx
  800e97:	75 0e                	jne    800ea7 <strtol+0x69>
  800e99:	3c 30                	cmp    $0x30,%al
  800e9b:	75 05                	jne    800ea2 <strtol+0x64>
		s++, base = 8;
  800e9d:	42                   	inc    %edx
  800e9e:	b3 08                	mov    $0x8,%bl
  800ea0:	eb 05                	jmp    800ea7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ea2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eae:	8a 0a                	mov    (%edx),%cl
  800eb0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800eb3:	80 fb 09             	cmp    $0x9,%bl
  800eb6:	77 08                	ja     800ec0 <strtol+0x82>
			dig = *s - '0';
  800eb8:	0f be c9             	movsbl %cl,%ecx
  800ebb:	83 e9 30             	sub    $0x30,%ecx
  800ebe:	eb 1e                	jmp    800ede <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ec0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ec3:	80 fb 19             	cmp    $0x19,%bl
  800ec6:	77 08                	ja     800ed0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ec8:	0f be c9             	movsbl %cl,%ecx
  800ecb:	83 e9 57             	sub    $0x57,%ecx
  800ece:	eb 0e                	jmp    800ede <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ed0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ed3:	80 fb 19             	cmp    $0x19,%bl
  800ed6:	77 13                	ja     800eeb <strtol+0xad>
			dig = *s - 'A' + 10;
  800ed8:	0f be c9             	movsbl %cl,%ecx
  800edb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ede:	39 f1                	cmp    %esi,%ecx
  800ee0:	7d 0d                	jge    800eef <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ee2:	42                   	inc    %edx
  800ee3:	0f af c6             	imul   %esi,%eax
  800ee6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ee9:	eb c3                	jmp    800eae <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	eb 02                	jmp    800ef1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800eef:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ef1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef5:	74 05                	je     800efc <strtol+0xbe>
		*endptr = (char *) s;
  800ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800efa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800efc:	85 ff                	test   %edi,%edi
  800efe:	74 04                	je     800f04 <strtol+0xc6>
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	f7 d8                	neg    %eax
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    
  800f09:	00 00                	add    %al,(%eax)
	...

00800f0c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	83 ec 1c             	sub    $0x1c,%esp
  800f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f18:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800f1b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1d:	8b 75 14             	mov    0x14(%ebp),%esi
  800f20:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f29:	cd 30                	int    $0x30
  800f2b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f31:	74 1c                	je     800f4f <syscall+0x43>
  800f33:	85 c0                	test   %eax,%eax
  800f35:	7e 18                	jle    800f4f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	50                   	push   %eax
  800f3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3e:	68 1f 2f 80 00       	push   $0x802f1f
  800f43:	6a 42                	push   $0x42
  800f45:	68 3c 2f 80 00       	push   $0x802f3c
  800f4a:	e8 b1 f5 ff ff       	call   800500 <_panic>

	return ret;
}
  800f4f:	89 d0                	mov    %edx,%eax
  800f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f5f:	6a 00                	push   $0x0
  800f61:	6a 00                	push   $0x0
  800f63:	6a 00                	push   $0x0
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	e8 92 ff ff ff       	call   800f0c <syscall>
  800f7a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f85:	6a 00                	push   $0x0
  800f87:	6a 00                	push   $0x0
  800f89:	6a 00                	push   $0x0
  800f8b:	6a 00                	push   $0x0
  800f8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f92:	ba 00 00 00 00       	mov    $0x0,%edx
  800f97:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9c:	e8 6b ff ff ff       	call   800f0c <syscall>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa9:	6a 00                	push   $0x0
  800fab:	6a 00                	push   $0x0
  800fad:	6a 00                	push   $0x0
  800faf:	6a 00                	push   $0x0
  800fb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb4:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbe:	e8 49 ff ff ff       	call   800f0c <syscall>
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fcb:	6a 00                	push   $0x0
  800fcd:	6a 00                	push   $0x0
  800fcf:	6a 00                	push   $0x0
  800fd1:	6a 00                	push   $0x0
  800fd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdd:	b8 02 00 00 00       	mov    $0x2,%eax
  800fe2:	e8 25 ff ff ff       	call   800f0c <syscall>
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <sys_yield>:

void
sys_yield(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fef:	6a 00                	push   $0x0
  800ff1:	6a 00                	push   $0x0
  800ff3:	6a 00                	push   $0x0
  800ff5:	6a 00                	push   $0x0
  800ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffc:	ba 00 00 00 00       	mov    $0x0,%edx
  801001:	b8 0b 00 00 00       	mov    $0xb,%eax
  801006:	e8 01 ff ff ff       	call   800f0c <syscall>
  80100b:	83 c4 10             	add    $0x10,%esp
}
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    

00801010 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801016:	6a 00                	push   $0x0
  801018:	6a 00                	push   $0x0
  80101a:	ff 75 10             	pushl  0x10(%ebp)
  80101d:	ff 75 0c             	pushl  0xc(%ebp)
  801020:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801023:	ba 01 00 00 00       	mov    $0x1,%edx
  801028:	b8 04 00 00 00       	mov    $0x4,%eax
  80102d:	e8 da fe ff ff       	call   800f0c <syscall>
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80103a:	ff 75 18             	pushl  0x18(%ebp)
  80103d:	ff 75 14             	pushl  0x14(%ebp)
  801040:	ff 75 10             	pushl  0x10(%ebp)
  801043:	ff 75 0c             	pushl  0xc(%ebp)
  801046:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801049:	ba 01 00 00 00       	mov    $0x1,%edx
  80104e:	b8 05 00 00 00       	mov    $0x5,%eax
  801053:	e8 b4 fe ff ff       	call   800f0c <syscall>
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801060:	6a 00                	push   $0x0
  801062:	6a 00                	push   $0x0
  801064:	6a 00                	push   $0x0
  801066:	ff 75 0c             	pushl  0xc(%ebp)
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	ba 01 00 00 00       	mov    $0x1,%edx
  801071:	b8 06 00 00 00       	mov    $0x6,%eax
  801076:	e8 91 fe ff ff       	call   800f0c <syscall>
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801083:	6a 00                	push   $0x0
  801085:	6a 00                	push   $0x0
  801087:	6a 00                	push   $0x0
  801089:	ff 75 0c             	pushl  0xc(%ebp)
  80108c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108f:	ba 01 00 00 00       	mov    $0x1,%edx
  801094:	b8 08 00 00 00       	mov    $0x8,%eax
  801099:	e8 6e fe ff ff       	call   800f0c <syscall>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8010a6:	6a 00                	push   $0x0
  8010a8:	6a 00                	push   $0x0
  8010aa:	6a 00                	push   $0x0
  8010ac:	ff 75 0c             	pushl  0xc(%ebp)
  8010af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b2:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8010bc:	e8 4b fe ff ff       	call   800f0c <syscall>
}
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010c9:	6a 00                	push   $0x0
  8010cb:	6a 00                	push   $0x0
  8010cd:	6a 00                	push   $0x0
  8010cf:	ff 75 0c             	pushl  0xc(%ebp)
  8010d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8010da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010df:	e8 28 fe ff ff       	call   800f0c <syscall>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010ec:	6a 00                	push   $0x0
  8010ee:	ff 75 14             	pushl  0x14(%ebp)
  8010f1:	ff 75 10             	pushl  0x10(%ebp)
  8010f4:	ff 75 0c             	pushl  0xc(%ebp)
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  801104:	e8 03 fe ff ff       	call   800f0c <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801111:	6a 00                	push   $0x0
  801113:	6a 00                	push   $0x0
  801115:	6a 00                	push   $0x0
  801117:	6a 00                	push   $0x0
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	ba 01 00 00 00       	mov    $0x1,%edx
  801121:	b8 0d 00 00 00       	mov    $0xd,%eax
  801126:	e8 e1 fd ff ff       	call   800f0c <syscall>
}
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  801133:	6a 00                	push   $0x0
  801135:	6a 00                	push   $0x0
  801137:	6a 00                	push   $0x0
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113f:	ba 00 00 00 00       	mov    $0x0,%edx
  801144:	b8 0e 00 00 00       	mov    $0xe,%eax
  801149:	e8 be fd ff ff       	call   800f0c <syscall>
}
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	53                   	push   %ebx
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80115a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  80115c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801160:	75 14                	jne    801176 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	68 4c 2f 80 00       	push   $0x802f4c
  80116a:	6a 20                	push   $0x20
  80116c:	68 90 30 80 00       	push   $0x803090
  801171:	e8 8a f3 ff ff       	call   800500 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  801176:	89 d8                	mov    %ebx,%eax
  801178:	c1 e8 16             	shr    $0x16,%eax
  80117b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801182:	a8 01                	test   $0x1,%al
  801184:	74 11                	je     801197 <pgfault+0x47>
  801186:	89 d8                	mov    %ebx,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801192:	f6 c4 08             	test   $0x8,%ah
  801195:	75 14                	jne    8011ab <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  801197:	83 ec 04             	sub    $0x4,%esp
  80119a:	68 70 2f 80 00       	push   $0x802f70
  80119f:	6a 24                	push   $0x24
  8011a1:	68 90 30 80 00       	push   $0x803090
  8011a6:	e8 55 f3 ff ff       	call   800500 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	6a 07                	push   $0x7
  8011b0:	68 00 f0 7f 00       	push   $0x7ff000
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 54 fe ff ff       	call   801010 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 12                	jns    8011d5 <pgfault+0x85>
  8011c3:	50                   	push   %eax
  8011c4:	68 94 2f 80 00       	push   $0x802f94
  8011c9:	6a 32                	push   $0x32
  8011cb:	68 90 30 80 00       	push   $0x803090
  8011d0:	e8 2b f3 ff ff       	call   800500 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  8011d5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  8011db:	83 ec 04             	sub    $0x4,%esp
  8011de:	68 00 10 00 00       	push   $0x1000
  8011e3:	53                   	push   %ebx
  8011e4:	68 00 f0 7f 00       	push   $0x7ff000
  8011e9:	e8 cb fb ff ff       	call   800db9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  8011ee:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011f5:	53                   	push   %ebx
  8011f6:	6a 00                	push   $0x0
  8011f8:	68 00 f0 7f 00       	push   $0x7ff000
  8011fd:	6a 00                	push   $0x0
  8011ff:	e8 30 fe ff ff       	call   801034 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  801204:	83 c4 20             	add    $0x20,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	79 12                	jns    80121d <pgfault+0xcd>
  80120b:	50                   	push   %eax
  80120c:	68 b8 2f 80 00       	push   $0x802fb8
  801211:	6a 3a                	push   $0x3a
  801213:	68 90 30 80 00       	push   $0x803090
  801218:	e8 e3 f2 ff ff       	call   800500 <_panic>

	return;
}
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80122b:	68 50 11 80 00       	push   $0x801150
  801230:	e8 1b 14 00 00       	call   802650 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801235:	ba 07 00 00 00       	mov    $0x7,%edx
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	cd 30                	int    $0x30
  80123e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801241:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	79 12                	jns    80125c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  80124a:	50                   	push   %eax
  80124b:	68 9b 30 80 00       	push   $0x80309b
  801250:	6a 7f                	push   $0x7f
  801252:	68 90 30 80 00       	push   $0x803090
  801257:	e8 a4 f2 ff ff       	call   800500 <_panic>
	}
	int r;

	if (childpid == 0) {
  80125c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801260:	75 25                	jne    801287 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  801262:	e8 5e fd ff ff       	call   800fc5 <sys_getenvid>
  801267:	25 ff 03 00 00       	and    $0x3ff,%eax
  80126c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801273:	c1 e0 07             	shl    $0x7,%eax
  801276:	29 d0                	sub    %edx,%eax
  801278:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80127d:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  801282:	e9 be 01 00 00       	jmp    801445 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  80128c:	89 d8                	mov    %ebx,%eax
  80128e:	c1 e8 16             	shr    $0x16,%eax
  801291:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801298:	a8 01                	test   $0x1,%al
  80129a:	0f 84 10 01 00 00    	je     8013b0 <fork+0x18e>
  8012a0:	89 d8                	mov    %ebx,%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
  8012a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	0f 84 fb 00 00 00    	je     8013b0 <fork+0x18e>
  8012b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012bc:	f6 c2 04             	test   $0x4,%dl
  8012bf:	0f 84 eb 00 00 00    	je     8013b0 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8012c5:	89 c6                	mov    %eax,%esi
  8012c7:	c1 e6 0c             	shl    $0xc,%esi
  8012ca:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8012d0:	0f 84 da 00 00 00    	je     8013b0 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  8012d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012dd:	f6 c6 04             	test   $0x4,%dh
  8012e0:	74 37                	je     801319 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8012e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f1:	50                   	push   %eax
  8012f2:	56                   	push   %esi
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 38 fd ff ff       	call   801034 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8012fc:	83 c4 20             	add    $0x20,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	0f 89 a9 00 00 00    	jns    8013b0 <fork+0x18e>
  801307:	50                   	push   %eax
  801308:	68 dc 2f 80 00       	push   $0x802fdc
  80130d:	6a 54                	push   $0x54
  80130f:	68 90 30 80 00       	push   $0x803090
  801314:	e8 e7 f1 ff ff       	call   800500 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801319:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801320:	f6 c2 02             	test   $0x2,%dl
  801323:	75 0c                	jne    801331 <fork+0x10f>
  801325:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132c:	f6 c4 08             	test   $0x8,%ah
  80132f:	74 57                	je     801388 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801331:	83 ec 0c             	sub    $0xc,%esp
  801334:	68 05 08 00 00       	push   $0x805
  801339:	56                   	push   %esi
  80133a:	57                   	push   %edi
  80133b:	56                   	push   %esi
  80133c:	6a 00                	push   $0x0
  80133e:	e8 f1 fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801343:	83 c4 20             	add    $0x20,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	79 12                	jns    80135c <fork+0x13a>
  80134a:	50                   	push   %eax
  80134b:	68 dc 2f 80 00       	push   $0x802fdc
  801350:	6a 59                	push   $0x59
  801352:	68 90 30 80 00       	push   $0x803090
  801357:	e8 a4 f1 ff ff       	call   800500 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	68 05 08 00 00       	push   $0x805
  801364:	56                   	push   %esi
  801365:	6a 00                	push   $0x0
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 c5 fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80136f:	83 c4 20             	add    $0x20,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	79 3a                	jns    8013b0 <fork+0x18e>
  801376:	50                   	push   %eax
  801377:	68 dc 2f 80 00       	push   $0x802fdc
  80137c:	6a 5c                	push   $0x5c
  80137e:	68 90 30 80 00       	push   $0x803090
  801383:	e8 78 f1 ff ff       	call   800500 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	6a 05                	push   $0x5
  80138d:	56                   	push   %esi
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	6a 00                	push   $0x0
  801392:	e8 9d fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801397:	83 c4 20             	add    $0x20,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 12                	jns    8013b0 <fork+0x18e>
  80139e:	50                   	push   %eax
  80139f:	68 dc 2f 80 00       	push   $0x802fdc
  8013a4:	6a 60                	push   $0x60
  8013a6:	68 90 30 80 00       	push   $0x803090
  8013ab:	e8 50 f1 ff ff       	call   800500 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8013b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013b6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8013bc:	0f 85 ca fe ff ff    	jne    80128c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	6a 07                	push   $0x7
  8013c7:	68 00 f0 bf ee       	push   $0xeebff000
  8013cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013cf:	e8 3c fc ff ff       	call   801010 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	79 15                	jns    8013f0 <fork+0x1ce>
  8013db:	50                   	push   %eax
  8013dc:	68 00 30 80 00       	push   $0x803000
  8013e1:	68 94 00 00 00       	push   $0x94
  8013e6:	68 90 30 80 00       	push   $0x803090
  8013eb:	e8 10 f1 ff ff       	call   800500 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	68 bc 26 80 00       	push   $0x8026bc
  8013f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013fb:	e8 c3 fc ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	79 15                	jns    80141c <fork+0x1fa>
  801407:	50                   	push   %eax
  801408:	68 38 30 80 00       	push   $0x803038
  80140d:	68 99 00 00 00       	push   $0x99
  801412:	68 90 30 80 00       	push   $0x803090
  801417:	e8 e4 f0 ff ff       	call   800500 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	6a 02                	push   $0x2
  801421:	ff 75 e4             	pushl  -0x1c(%ebp)
  801424:	e8 54 fc ff ff       	call   80107d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	79 15                	jns    801445 <fork+0x223>
  801430:	50                   	push   %eax
  801431:	68 5c 30 80 00       	push   $0x80305c
  801436:	68 a4 00 00 00       	push   $0xa4
  80143b:	68 90 30 80 00       	push   $0x803090
  801440:	e8 bb f0 ff ff       	call   800500 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801448:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <sfork>:

// Challenge!
int
sfork(void)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801456:	68 b8 30 80 00       	push   $0x8030b8
  80145b:	68 b1 00 00 00       	push   $0xb1
  801460:	68 90 30 80 00       	push   $0x803090
  801465:	e8 96 f0 ff ff       	call   800500 <_panic>
	...

0080146c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	05 00 00 00 30       	add    $0x30000000,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80147f:	ff 75 08             	pushl  0x8(%ebp)
  801482:	e8 e5 ff ff ff       	call   80146c <fd2num>
  801487:	83 c4 04             	add    $0x4,%esp
  80148a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80148f:	c1 e0 0c             	shl    $0xc,%eax
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80149b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014a0:	a8 01                	test   $0x1,%al
  8014a2:	74 34                	je     8014d8 <fd_alloc+0x44>
  8014a4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014a9:	a8 01                	test   $0x1,%al
  8014ab:	74 32                	je     8014df <fd_alloc+0x4b>
  8014ad:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8014b2:	89 c1                	mov    %eax,%ecx
  8014b4:	89 c2                	mov    %eax,%edx
  8014b6:	c1 ea 16             	shr    $0x16,%edx
  8014b9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014c0:	f6 c2 01             	test   $0x1,%dl
  8014c3:	74 1f                	je     8014e4 <fd_alloc+0x50>
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	c1 ea 0c             	shr    $0xc,%edx
  8014ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d1:	f6 c2 01             	test   $0x1,%dl
  8014d4:	75 17                	jne    8014ed <fd_alloc+0x59>
  8014d6:	eb 0c                	jmp    8014e4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014d8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8014dd:	eb 05                	jmp    8014e4 <fd_alloc+0x50>
  8014df:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8014e4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 17                	jmp    801504 <fd_alloc+0x70>
  8014ed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f7:	75 b9                	jne    8014b2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801504:	5b                   	pop    %ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150d:	83 f8 1f             	cmp    $0x1f,%eax
  801510:	77 36                	ja     801548 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801512:	05 00 00 0d 00       	add    $0xd0000,%eax
  801517:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	c1 ea 16             	shr    $0x16,%edx
  80151f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801526:	f6 c2 01             	test   $0x1,%dl
  801529:	74 24                	je     80154f <fd_lookup+0x48>
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	c1 ea 0c             	shr    $0xc,%edx
  801530:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801537:	f6 c2 01             	test   $0x1,%dl
  80153a:	74 1a                	je     801556 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80153c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153f:	89 02                	mov    %eax,(%edx)
	return 0;
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
  801546:	eb 13                	jmp    80155b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801548:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154d:	eb 0c                	jmp    80155b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801554:	eb 05                	jmp    80155b <fd_lookup+0x54>
  801556:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80156a:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  801570:	74 0d                	je     80157f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
  801577:	eb 14                	jmp    80158d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801579:	39 0a                	cmp    %ecx,(%edx)
  80157b:	75 10                	jne    80158d <dev_lookup+0x30>
  80157d:	eb 05                	jmp    801584 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157f:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801584:	89 13                	mov    %edx,(%ebx)
			return 0;
  801586:	b8 00 00 00 00       	mov    $0x0,%eax
  80158b:	eb 31                	jmp    8015be <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80158d:	40                   	inc    %eax
  80158e:	8b 14 85 4c 31 80 00 	mov    0x80314c(,%eax,4),%edx
  801595:	85 d2                	test   %edx,%edx
  801597:	75 e0                	jne    801579 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801599:	a1 04 50 80 00       	mov    0x805004,%eax
  80159e:	8b 40 48             	mov    0x48(%eax),%eax
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	51                   	push   %ecx
  8015a5:	50                   	push   %eax
  8015a6:	68 d0 30 80 00       	push   $0x8030d0
  8015ab:	e8 28 f0 ff ff       	call   8005d8 <cprintf>
	*dev = 0;
  8015b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 20             	sub    $0x20,%esp
  8015cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ce:	8a 45 0c             	mov    0xc(%ebp),%al
  8015d1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015d4:	56                   	push   %esi
  8015d5:	e8 92 fe ff ff       	call   80146c <fd2num>
  8015da:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015dd:	89 14 24             	mov    %edx,(%esp)
  8015e0:	50                   	push   %eax
  8015e1:	e8 21 ff ff ff       	call   801507 <fd_lookup>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 05                	js     8015f4 <fd_close+0x31>
	    || fd != fd2)
  8015ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f2:	74 0d                	je     801601 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8015f4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015f8:	75 48                	jne    801642 <fd_close+0x7f>
  8015fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ff:	eb 41                	jmp    801642 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	ff 36                	pushl  (%esi)
  80160a:	e8 4e ff ff ff       	call   80155d <dev_lookup>
  80160f:	89 c3                	mov    %eax,%ebx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 1c                	js     801634 <fd_close+0x71>
		if (dev->dev_close)
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	8b 40 10             	mov    0x10(%eax),%eax
  80161e:	85 c0                	test   %eax,%eax
  801620:	74 0d                	je     80162f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	56                   	push   %esi
  801626:	ff d0                	call   *%eax
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 05                	jmp    801634 <fd_close+0x71>
		else
			r = 0;
  80162f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	56                   	push   %esi
  801638:	6a 00                	push   $0x0
  80163a:	e8 1b fa ff ff       	call   80105a <sys_page_unmap>
	return r;
  80163f:	83 c4 10             	add    $0x10,%esp
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	e8 aa fe ff ff       	call   801507 <fd_lookup>
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	85 c0                	test   %eax,%eax
  801662:	78 10                	js     801674 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	6a 01                	push   $0x1
  801669:	ff 75 f4             	pushl  -0xc(%ebp)
  80166c:	e8 52 ff ff ff       	call   8015c3 <fd_close>
  801671:	83 c4 10             	add    $0x10,%esp
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <close_all>:

void
close_all(void)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80167d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	53                   	push   %ebx
  801686:	e8 c0 ff ff ff       	call   80164b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80168b:	43                   	inc    %ebx
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	83 fb 20             	cmp    $0x20,%ebx
  801692:	75 ee                	jne    801682 <close_all+0xc>
		close(i);
}
  801694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	57                   	push   %edi
  80169d:	56                   	push   %esi
  80169e:	53                   	push   %ebx
  80169f:	83 ec 2c             	sub    $0x2c,%esp
  8016a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 56 fe ff ff       	call   801507 <fd_lookup>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	0f 88 c0 00 00 00    	js     80177e <dup+0xe5>
		return r;
	close(newfdnum);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	57                   	push   %edi
  8016c2:	e8 84 ff ff ff       	call   80164b <close>

	newfd = INDEX2FD(newfdnum);
  8016c7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016cd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016d0:	83 c4 04             	add    $0x4,%esp
  8016d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016d6:	e8 a1 fd ff ff       	call   80147c <fd2data>
  8016db:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016dd:	89 34 24             	mov    %esi,(%esp)
  8016e0:	e8 97 fd ff ff       	call   80147c <fd2data>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016eb:	89 d8                	mov    %ebx,%eax
  8016ed:	c1 e8 16             	shr    $0x16,%eax
  8016f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016f7:	a8 01                	test   $0x1,%al
  8016f9:	74 37                	je     801732 <dup+0x99>
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	c1 e8 0c             	shr    $0xc,%eax
  801700:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801707:	f6 c2 01             	test   $0x1,%dl
  80170a:	74 26                	je     801732 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80170c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	25 07 0e 00 00       	and    $0xe07,%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80171f:	6a 00                	push   $0x0
  801721:	53                   	push   %ebx
  801722:	6a 00                	push   $0x0
  801724:	e8 0b f9 ff ff       	call   801034 <sys_page_map>
  801729:	89 c3                	mov    %eax,%ebx
  80172b:	83 c4 20             	add    $0x20,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 2d                	js     80175f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801735:	89 c2                	mov    %eax,%edx
  801737:	c1 ea 0c             	shr    $0xc,%edx
  80173a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80174a:	52                   	push   %edx
  80174b:	56                   	push   %esi
  80174c:	6a 00                	push   $0x0
  80174e:	50                   	push   %eax
  80174f:	6a 00                	push   $0x0
  801751:	e8 de f8 ff ff       	call   801034 <sys_page_map>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 20             	add    $0x20,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	79 1d                	jns    80177c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	56                   	push   %esi
  801763:	6a 00                	push   $0x0
  801765:	e8 f0 f8 ff ff       	call   80105a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80176a:	83 c4 08             	add    $0x8,%esp
  80176d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801770:	6a 00                	push   $0x0
  801772:	e8 e3 f8 ff ff       	call   80105a <sys_page_unmap>
	return r;
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	eb 02                	jmp    80177e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80177c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5f                   	pop    %edi
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 14             	sub    $0x14,%esp
  80178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801792:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801795:	50                   	push   %eax
  801796:	53                   	push   %ebx
  801797:	e8 6b fd ff ff       	call   801507 <fd_lookup>
  80179c:	83 c4 08             	add    $0x8,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 67                	js     80180a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ad:	ff 30                	pushl  (%eax)
  8017af:	e8 a9 fd ff ff       	call   80155d <dev_lookup>
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 4f                	js     80180a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017be:	8b 50 08             	mov    0x8(%eax),%edx
  8017c1:	83 e2 03             	and    $0x3,%edx
  8017c4:	83 fa 01             	cmp    $0x1,%edx
  8017c7:	75 21                	jne    8017ea <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c9:	a1 04 50 80 00       	mov    0x805004,%eax
  8017ce:	8b 40 48             	mov    0x48(%eax),%eax
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	50                   	push   %eax
  8017d6:	68 11 31 80 00       	push   $0x803111
  8017db:	e8 f8 ed ff ff       	call   8005d8 <cprintf>
		return -E_INVAL;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e8:	eb 20                	jmp    80180a <read+0x82>
	}
	if (!dev->dev_read)
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	8b 52 08             	mov    0x8(%edx),%edx
  8017f0:	85 d2                	test   %edx,%edx
  8017f2:	74 11                	je     801805 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	ff 75 10             	pushl  0x10(%ebp)
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	50                   	push   %eax
  8017fe:	ff d2                	call   *%edx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	eb 05                	jmp    80180a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801805:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80180a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	57                   	push   %edi
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	8b 7d 08             	mov    0x8(%ebp),%edi
  80181b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80181e:	85 f6                	test   %esi,%esi
  801820:	74 31                	je     801853 <readn+0x44>
  801822:	b8 00 00 00 00       	mov    $0x0,%eax
  801827:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80182c:	83 ec 04             	sub    $0x4,%esp
  80182f:	89 f2                	mov    %esi,%edx
  801831:	29 c2                	sub    %eax,%edx
  801833:	52                   	push   %edx
  801834:	03 45 0c             	add    0xc(%ebp),%eax
  801837:	50                   	push   %eax
  801838:	57                   	push   %edi
  801839:	e8 4a ff ff ff       	call   801788 <read>
		if (m < 0)
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	78 17                	js     80185c <readn+0x4d>
			return m;
		if (m == 0)
  801845:	85 c0                	test   %eax,%eax
  801847:	74 11                	je     80185a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801849:	01 c3                	add    %eax,%ebx
  80184b:	89 d8                	mov    %ebx,%eax
  80184d:	39 f3                	cmp    %esi,%ebx
  80184f:	72 db                	jb     80182c <readn+0x1d>
  801851:	eb 09                	jmp    80185c <readn+0x4d>
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
  801858:	eb 02                	jmp    80185c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80185a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80185c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185f:	5b                   	pop    %ebx
  801860:	5e                   	pop    %esi
  801861:	5f                   	pop    %edi
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 14             	sub    $0x14,%esp
  80186b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801871:	50                   	push   %eax
  801872:	53                   	push   %ebx
  801873:	e8 8f fc ff ff       	call   801507 <fd_lookup>
  801878:	83 c4 08             	add    $0x8,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 62                	js     8018e1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801885:	50                   	push   %eax
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	ff 30                	pushl  (%eax)
  80188b:	e8 cd fc ff ff       	call   80155d <dev_lookup>
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	78 4a                	js     8018e1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80189e:	75 21                	jne    8018c1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a0:	a1 04 50 80 00       	mov    0x805004,%eax
  8018a5:	8b 40 48             	mov    0x48(%eax),%eax
  8018a8:	83 ec 04             	sub    $0x4,%esp
  8018ab:	53                   	push   %ebx
  8018ac:	50                   	push   %eax
  8018ad:	68 2d 31 80 00       	push   $0x80312d
  8018b2:	e8 21 ed ff ff       	call   8005d8 <cprintf>
		return -E_INVAL;
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bf:	eb 20                	jmp    8018e1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c7:	85 d2                	test   %edx,%edx
  8018c9:	74 11                	je     8018dc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	ff 75 10             	pushl  0x10(%ebp)
  8018d1:	ff 75 0c             	pushl  0xc(%ebp)
  8018d4:	50                   	push   %eax
  8018d5:	ff d2                	call   *%edx
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	eb 05                	jmp    8018e1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 08             	pushl  0x8(%ebp)
  8018f3:	e8 0f fc ff ff       	call   801507 <fd_lookup>
  8018f8:	83 c4 08             	add    $0x8,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 0e                	js     80190d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
  801905:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801908:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 14             	sub    $0x14,%esp
  801916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801919:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191c:	50                   	push   %eax
  80191d:	53                   	push   %ebx
  80191e:	e8 e4 fb ff ff       	call   801507 <fd_lookup>
  801923:	83 c4 08             	add    $0x8,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 5f                	js     801989 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801934:	ff 30                	pushl  (%eax)
  801936:	e8 22 fc ff ff       	call   80155d <dev_lookup>
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 47                	js     801989 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801942:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801945:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801949:	75 21                	jne    80196c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80194b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801950:	8b 40 48             	mov    0x48(%eax),%eax
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	53                   	push   %ebx
  801957:	50                   	push   %eax
  801958:	68 f0 30 80 00       	push   $0x8030f0
  80195d:	e8 76 ec ff ff       	call   8005d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80196a:	eb 1d                	jmp    801989 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80196c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80196f:	8b 52 18             	mov    0x18(%edx),%edx
  801972:	85 d2                	test   %edx,%edx
  801974:	74 0e                	je     801984 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	ff 75 0c             	pushl  0xc(%ebp)
  80197c:	50                   	push   %eax
  80197d:	ff d2                	call   *%edx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	eb 05                	jmp    801989 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801984:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 14             	sub    $0x14,%esp
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 63 fb ff ff       	call   801507 <fd_lookup>
  8019a4:	83 c4 08             	add    $0x8,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 52                	js     8019fd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b5:	ff 30                	pushl  (%eax)
  8019b7:	e8 a1 fb ff ff       	call   80155d <dev_lookup>
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 3a                	js     8019fd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019ca:	74 2c                	je     8019f8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019d6:	00 00 00 
	stat->st_isdir = 0;
  8019d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e0:	00 00 00 
	stat->st_dev = dev;
  8019e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	53                   	push   %ebx
  8019ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f0:	ff 50 14             	call   *0x14(%eax)
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	eb 05                	jmp    8019fd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	6a 00                	push   $0x0
  801a0c:	ff 75 08             	pushl  0x8(%ebp)
  801a0f:	e8 78 01 00 00       	call   801b8c <open>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 1b                	js     801a38 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	50                   	push   %eax
  801a24:	e8 65 ff ff ff       	call   80198e <fstat>
  801a29:	89 c6                	mov    %eax,%esi
	close(fd);
  801a2b:	89 1c 24             	mov    %ebx,(%esp)
  801a2e:	e8 18 fc ff ff       	call   80164b <close>
	return r;
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	89 f3                	mov    %esi,%ebx
}
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    
  801a41:	00 00                	add    %al,(%eax)
	...

00801a44 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a4d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a54:	75 12                	jne    801a68 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	6a 01                	push   $0x1
  801a5b:	e8 4e 0d 00 00       	call   8027ae <ipc_find_env>
  801a60:	a3 00 50 80 00       	mov    %eax,0x805000
  801a65:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a68:	6a 07                	push   $0x7
  801a6a:	68 00 60 80 00       	push   $0x806000
  801a6f:	53                   	push   %ebx
  801a70:	ff 35 00 50 80 00    	pushl  0x805000
  801a76:	e8 de 0c 00 00       	call   802759 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801a7b:	83 c4 0c             	add    $0xc,%esp
  801a7e:	6a 00                	push   $0x0
  801a80:	56                   	push   %esi
  801a81:	6a 00                	push   $0x0
  801a83:	e8 5c 0c 00 00       	call   8026e4 <ipc_recv>
}
  801a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a99:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa9:	b8 05 00 00 00       	mov    $0x5,%eax
  801aae:	e8 91 ff ff ff       	call   801a44 <fsipc>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 2c                	js     801ae3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ab7:	83 ec 08             	sub    $0x8,%esp
  801aba:	68 00 60 80 00       	push   $0x806000
  801abf:	53                   	push   %ebx
  801ac0:	e8 c9 f0 ff ff       	call   800b8e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ac5:	a1 80 60 80 00       	mov    0x806080,%eax
  801aca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ad0:	a1 84 60 80 00       	mov    0x806084,%eax
  801ad5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 40 0c             	mov    0xc(%eax),%eax
  801af4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801af9:	ba 00 00 00 00       	mov    $0x0,%edx
  801afe:	b8 06 00 00 00       	mov    $0x6,%eax
  801b03:	e8 3c ff ff ff       	call   801a44 <fsipc>
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	8b 40 0c             	mov    0xc(%eax),%eax
  801b18:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b1d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
  801b28:	b8 03 00 00 00       	mov    $0x3,%eax
  801b2d:	e8 12 ff ff ff       	call   801a44 <fsipc>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 4b                	js     801b83 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b38:	39 c6                	cmp    %eax,%esi
  801b3a:	73 16                	jae    801b52 <devfile_read+0x48>
  801b3c:	68 5c 31 80 00       	push   $0x80315c
  801b41:	68 63 31 80 00       	push   $0x803163
  801b46:	6a 7d                	push   $0x7d
  801b48:	68 78 31 80 00       	push   $0x803178
  801b4d:	e8 ae e9 ff ff       	call   800500 <_panic>
	assert(r <= PGSIZE);
  801b52:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b57:	7e 16                	jle    801b6f <devfile_read+0x65>
  801b59:	68 83 31 80 00       	push   $0x803183
  801b5e:	68 63 31 80 00       	push   $0x803163
  801b63:	6a 7e                	push   $0x7e
  801b65:	68 78 31 80 00       	push   $0x803178
  801b6a:	e8 91 e9 ff ff       	call   800500 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b6f:	83 ec 04             	sub    $0x4,%esp
  801b72:	50                   	push   %eax
  801b73:	68 00 60 80 00       	push   $0x806000
  801b78:	ff 75 0c             	pushl  0xc(%ebp)
  801b7b:	e8 cf f1 ff ff       	call   800d4f <memmove>
	return r;
  801b80:	83 c4 10             	add    $0x10,%esp
}
  801b83:	89 d8                	mov    %ebx,%eax
  801b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 1c             	sub    $0x1c,%esp
  801b94:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b97:	56                   	push   %esi
  801b98:	e8 9f ef ff ff       	call   800b3c <strlen>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ba5:	7f 65                	jg     801c0c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba7:	83 ec 0c             	sub    $0xc,%esp
  801baa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	e8 e1 f8 ff ff       	call   801494 <fd_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 55                	js     801c11 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	56                   	push   %esi
  801bc0:	68 00 60 80 00       	push   $0x806000
  801bc5:	e8 c4 ef ff ff       	call   800b8e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcd:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801bda:	e8 65 fe ff ff       	call   801a44 <fsipc>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	79 12                	jns    801bfa <open+0x6e>
		fd_close(fd, 0);
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	6a 00                	push   $0x0
  801bed:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf0:	e8 ce f9 ff ff       	call   8015c3 <fd_close>
		return r;
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	eb 17                	jmp    801c11 <open+0x85>
	}

	return fd2num(fd);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	e8 67 f8 ff ff       	call   80146c <fd2num>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	eb 05                	jmp    801c11 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c0c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c11:	89 d8                	mov    %ebx,%eax
  801c13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    
	...

00801c1c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c28:	6a 00                	push   $0x0
  801c2a:	ff 75 08             	pushl  0x8(%ebp)
  801c2d:	e8 5a ff ff ff       	call   801b8c <open>
  801c32:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 36 05 00 00    	js     802179 <spawn+0x55d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	68 00 02 00 00       	push   $0x200
  801c4b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c51:	50                   	push   %eax
  801c52:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c58:	e8 b2 fb ff ff       	call   80180f <readn>
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c65:	75 0c                	jne    801c73 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801c67:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c6e:	45 4c 46 
  801c71:	74 38                	je     801cab <spawn+0x8f>
		close(fd);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c7c:	e8 ca f9 ff ff       	call   80164b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c81:	83 c4 0c             	add    $0xc,%esp
  801c84:	68 7f 45 4c 46       	push   $0x464c457f
  801c89:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c8f:	68 8f 31 80 00       	push   $0x80318f
  801c94:	e8 3f e9 ff ff       	call   8005d8 <cprintf>
		return -E_NOT_EXEC;
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801ca3:	ff ff ff 
  801ca6:	e9 da 04 00 00       	jmp    802185 <spawn+0x569>
  801cab:	ba 07 00 00 00       	mov    $0x7,%edx
  801cb0:	89 d0                	mov    %edx,%eax
  801cb2:	cd 30                	int    $0x30
  801cb4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801cba:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	0f 88 bd 04 00 00    	js     802185 <spawn+0x569>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ccd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801cd4:	89 c6                	mov    %eax,%esi
  801cd6:	c1 e6 07             	shl    $0x7,%esi
  801cd9:	29 d6                	sub    %edx,%esi
  801cdb:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ce1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ce7:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cee:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cf4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfd:	8b 02                	mov    (%edx),%eax
  801cff:	85 c0                	test   %eax,%eax
  801d01:	74 39                	je     801d3c <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d03:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d0d:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	50                   	push   %eax
  801d13:	e8 24 ee ff ff       	call   800b3c <strlen>
  801d18:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d1c:	43                   	inc    %ebx
  801d1d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d24:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 e1                	jne    801d0f <spawn+0xf3>
  801d2e:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  801d34:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801d3a:	eb 1e                	jmp    801d5a <spawn+0x13e>
  801d3c:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801d43:	00 00 00 
  801d46:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801d4d:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d50:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801d55:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d5a:	f7 de                	neg    %esi
  801d5c:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d62:	89 fa                	mov    %edi,%edx
  801d64:	83 e2 fc             	and    $0xfffffffc,%edx
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	f7 d0                	not    %eax
  801d6b:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801d6e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d74:	83 e8 08             	sub    $0x8,%eax
  801d77:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d7c:	0f 86 11 04 00 00    	jbe    802193 <spawn+0x577>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d82:	83 ec 04             	sub    $0x4,%esp
  801d85:	6a 07                	push   $0x7
  801d87:	68 00 00 40 00       	push   $0x400000
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 7d f2 ff ff       	call   801010 <sys_page_alloc>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	0f 88 01 04 00 00    	js     80219f <spawn+0x583>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d9e:	85 db                	test   %ebx,%ebx
  801da0:	7e 44                	jle    801de6 <spawn+0x1ca>
  801da2:	be 00 00 00 00       	mov    $0x0,%esi
  801da7:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801dad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801db0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801db6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dbc:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dc5:	57                   	push   %edi
  801dc6:	e8 c3 ed ff ff       	call   800b8e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dcb:	83 c4 04             	add    $0x4,%esp
  801dce:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dd1:	e8 66 ed ff ff       	call   800b3c <strlen>
  801dd6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801dda:	46                   	inc    %esi
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801de4:	7c ca                	jl     801db0 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801de6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801dec:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801df2:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801df9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dff:	74 19                	je     801e1a <spawn+0x1fe>
  801e01:	68 1c 32 80 00       	push   $0x80321c
  801e06:	68 63 31 80 00       	push   $0x803163
  801e0b:	68 f5 00 00 00       	push   $0xf5
  801e10:	68 a9 31 80 00       	push   $0x8031a9
  801e15:	e8 e6 e6 ff ff       	call   800500 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e1a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e20:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e25:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e2b:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801e2e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801e34:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e37:	89 d0                	mov    %edx,%eax
  801e39:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801e3e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	6a 07                	push   $0x7
  801e49:	68 00 d0 bf ee       	push   $0xeebfd000
  801e4e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e54:	68 00 00 40 00       	push   $0x400000
  801e59:	6a 00                	push   $0x0
  801e5b:	e8 d4 f1 ff ff       	call   801034 <sys_page_map>
  801e60:	89 c3                	mov    %eax,%ebx
  801e62:	83 c4 20             	add    $0x20,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 18                	js     801e81 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e69:	83 ec 08             	sub    $0x8,%esp
  801e6c:	68 00 00 40 00       	push   $0x400000
  801e71:	6a 00                	push   $0x0
  801e73:	e8 e2 f1 ff ff       	call   80105a <sys_page_unmap>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	79 1d                	jns    801e9e <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e81:	83 ec 08             	sub    $0x8,%esp
  801e84:	68 00 00 40 00       	push   $0x400000
  801e89:	6a 00                	push   $0x0
  801e8b:	e8 ca f1 ff ff       	call   80105a <sys_page_unmap>
  801e90:	83 c4 10             	add    $0x10,%esp
	return r;
  801e93:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801e99:	e9 e7 02 00 00       	jmp    802185 <spawn+0x569>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e9e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ea4:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801eab:	00 
  801eac:	0f 84 c3 01 00 00    	je     802075 <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801eb2:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801eb9:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ebf:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ec6:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801ec9:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ecf:	83 3a 01             	cmpl   $0x1,(%edx)
  801ed2:	0f 85 7c 01 00 00    	jne    802054 <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ed8:	8b 42 18             	mov    0x18(%edx),%eax
  801edb:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801ede:	83 f8 01             	cmp    $0x1,%eax
  801ee1:	19 db                	sbb    %ebx,%ebx
  801ee3:	83 e3 fe             	and    $0xfffffffe,%ebx
  801ee6:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ee9:	8b 42 04             	mov    0x4(%edx),%eax
  801eec:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801ef2:	8b 52 10             	mov    0x10(%edx),%edx
  801ef5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801efb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f01:	8b 40 14             	mov    0x14(%eax),%eax
  801f04:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801f0a:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801f10:	8b 52 08             	mov    0x8(%edx),%edx
  801f13:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f19:	89 d0                	mov    %edx,%eax
  801f1b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f20:	74 1a                	je     801f3c <spawn+0x320>
		va -= i;
  801f22:	29 c2                	sub    %eax,%edx
  801f24:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801f2a:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801f30:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801f36:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f3c:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801f43:	0f 84 0b 01 00 00    	je     802054 <spawn+0x438>
  801f49:	bf 00 00 00 00       	mov    $0x0,%edi
  801f4e:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801f53:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801f59:	72 28                	jb     801f83 <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	53                   	push   %ebx
  801f5f:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801f65:	57                   	push   %edi
  801f66:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f6c:	e8 9f f0 ff ff       	call   801010 <sys_page_alloc>
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 c0                	test   %eax,%eax
  801f76:	0f 89 c4 00 00 00    	jns    802040 <spawn+0x424>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	e9 cf 01 00 00       	jmp    802152 <spawn+0x536>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f83:	83 ec 04             	sub    $0x4,%esp
  801f86:	6a 07                	push   $0x7
  801f88:	68 00 00 40 00       	push   $0x400000
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 7c f0 ff ff       	call   801010 <sys_page_alloc>
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	0f 88 a9 01 00 00    	js     802148 <spawn+0x52c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f9f:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801fa2:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801fa8:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fab:	50                   	push   %eax
  801fac:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fb2:	e8 2f f9 ff ff       	call   8018e6 <seek>
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	0f 88 8a 01 00 00    	js     80214c <spawn+0x530>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fc2:	83 ec 04             	sub    $0x4,%esp
  801fc5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801fcb:	29 f8                	sub    %edi,%eax
  801fcd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fd2:	76 05                	jbe    801fd9 <spawn+0x3bd>
  801fd4:	b8 00 10 00 00       	mov    $0x1000,%eax
  801fd9:	50                   	push   %eax
  801fda:	68 00 00 40 00       	push   $0x400000
  801fdf:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fe5:	e8 25 f8 ff ff       	call   80180f <readn>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	0f 88 5b 01 00 00    	js     802150 <spawn+0x534>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ff5:	83 ec 0c             	sub    $0xc,%esp
  801ff8:	53                   	push   %ebx
  801ff9:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801fff:	57                   	push   %edi
  802000:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802006:	68 00 00 40 00       	push   $0x400000
  80200b:	6a 00                	push   $0x0
  80200d:	e8 22 f0 ff ff       	call   801034 <sys_page_map>
  802012:	83 c4 20             	add    $0x20,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	79 15                	jns    80202e <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  802019:	50                   	push   %eax
  80201a:	68 b5 31 80 00       	push   $0x8031b5
  80201f:	68 28 01 00 00       	push   $0x128
  802024:	68 a9 31 80 00       	push   $0x8031a9
  802029:	e8 d2 e4 ff ff       	call   800500 <_panic>
			sys_page_unmap(0, UTEMP);
  80202e:	83 ec 08             	sub    $0x8,%esp
  802031:	68 00 00 40 00       	push   $0x400000
  802036:	6a 00                	push   $0x0
  802038:	e8 1d f0 ff ff       	call   80105a <sys_page_unmap>
  80203d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802040:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802046:	89 f7                	mov    %esi,%edi
  802048:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  80204e:	0f 87 ff fe ff ff    	ja     801f53 <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802054:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  80205a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802061:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802067:	7e 0c                	jle    802075 <spawn+0x459>
  802069:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802070:	e9 54 fe ff ff       	jmp    801ec9 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802075:	83 ec 0c             	sub    $0xc,%esp
  802078:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80207e:	e8 c8 f5 ff ff       	call   80164b <close>
  802083:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802086:	bb 00 00 00 00       	mov    $0x0,%ebx
  80208b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  802091:	89 d8                	mov    %ebx,%eax
  802093:	c1 e8 16             	shr    $0x16,%eax
  802096:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80209d:	a8 01                	test   $0x1,%al
  80209f:	74 3e                	je     8020df <spawn+0x4c3>
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	c1 e8 0c             	shr    $0xc,%eax
  8020a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020ad:	f6 c2 01             	test   $0x1,%dl
  8020b0:	74 2d                	je     8020df <spawn+0x4c3>
  8020b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020b9:	f6 c6 04             	test   $0x4,%dh
  8020bc:	74 21                	je     8020df <spawn+0x4c3>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  8020be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020c5:	83 ec 0c             	sub    $0xc,%esp
  8020c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8020cd:	50                   	push   %eax
  8020ce:	53                   	push   %ebx
  8020cf:	56                   	push   %esi
  8020d0:	53                   	push   %ebx
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 5c ef ff ff       	call   801034 <sys_page_map>
        if (r < 0) return r;
  8020d8:	83 c4 20             	add    $0x20,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 13                	js     8020f2 <spawn+0x4d6>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8020df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020eb:	75 a4                	jne    802091 <spawn+0x475>
  8020ed:	e9 b5 00 00 00       	jmp    8021a7 <spawn+0x58b>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020f2:	50                   	push   %eax
  8020f3:	68 d2 31 80 00       	push   $0x8031d2
  8020f8:	68 86 00 00 00       	push   $0x86
  8020fd:	68 a9 31 80 00       	push   $0x8031a9
  802102:	e8 f9 e3 ff ff       	call   800500 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802107:	50                   	push   %eax
  802108:	68 e8 31 80 00       	push   $0x8031e8
  80210d:	68 89 00 00 00       	push   $0x89
  802112:	68 a9 31 80 00       	push   $0x8031a9
  802117:	e8 e4 e3 ff ff       	call   800500 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80211c:	83 ec 08             	sub    $0x8,%esp
  80211f:	6a 02                	push   $0x2
  802121:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802127:	e8 51 ef ff ff       	call   80107d <sys_env_set_status>
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	79 52                	jns    802185 <spawn+0x569>
		panic("sys_env_set_status: %e", r);
  802133:	50                   	push   %eax
  802134:	68 02 32 80 00       	push   $0x803202
  802139:	68 8c 00 00 00       	push   $0x8c
  80213e:	68 a9 31 80 00       	push   $0x8031a9
  802143:	e8 b8 e3 ff ff       	call   800500 <_panic>
  802148:	89 c3                	mov    %eax,%ebx
  80214a:	eb 06                	jmp    802152 <spawn+0x536>
  80214c:	89 c3                	mov    %eax,%ebx
  80214e:	eb 02                	jmp    802152 <spawn+0x536>
  802150:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  802152:	83 ec 0c             	sub    $0xc,%esp
  802155:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80215b:	e8 43 ee ff ff       	call   800fa3 <sys_env_destroy>
	close(fd);
  802160:	83 c4 04             	add    $0x4,%esp
  802163:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802169:	e8 dd f4 ff ff       	call   80164b <close>
	return r;
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802177:	eb 0c                	jmp    802185 <spawn+0x569>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802179:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80217f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802185:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80218b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	c9                   	leave  
  802192:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802193:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  80219a:	ff ff ff 
  80219d:	eb e6                	jmp    802185 <spawn+0x569>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80219f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8021a5:	eb de                	jmp    802185 <spawn+0x569>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021a7:	83 ec 08             	sub    $0x8,%esp
  8021aa:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021b0:	50                   	push   %eax
  8021b1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021b7:	e8 e4 ee ff ff       	call   8010a0 <sys_env_set_trapframe>
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	0f 89 55 ff ff ff    	jns    80211c <spawn+0x500>
  8021c7:	e9 3b ff ff ff       	jmp    802107 <spawn+0x4eb>

008021cc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	56                   	push   %esi
  8021d0:	53                   	push   %ebx
  8021d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8021d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021db:	74 5f                	je     80223c <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021dd:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8021e2:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021e3:	89 c2                	mov    %eax,%edx
  8021e5:	83 c0 04             	add    $0x4,%eax
  8021e8:	83 3a 00             	cmpl   $0x0,(%edx)
  8021eb:	75 f5                	jne    8021e2 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021ed:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8021f4:	83 e0 f0             	and    $0xfffffff0,%eax
  8021f7:	29 c4                	sub    %eax,%esp
  8021f9:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8021fd:	83 e0 f0             	and    $0xfffffff0,%eax
  802200:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802202:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802204:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  80220b:	00 

	va_start(vl, arg0);
  80220c:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80220f:	89 ce                	mov    %ecx,%esi
  802211:	85 c9                	test   %ecx,%ecx
  802213:	74 14                	je     802229 <spawnl+0x5d>
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80221a:	40                   	inc    %eax
  80221b:	89 d1                	mov    %edx,%ecx
  80221d:	83 c2 04             	add    $0x4,%edx
  802220:	8b 09                	mov    (%ecx),%ecx
  802222:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802225:	39 f0                	cmp    %esi,%eax
  802227:	72 f1                	jb     80221a <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	53                   	push   %ebx
  80222d:	ff 75 08             	pushl  0x8(%ebp)
  802230:	e8 e7 f9 ff ff       	call   801c1c <spawn>
}
  802235:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	c9                   	leave  
  80223b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80223c:	83 ec 20             	sub    $0x20,%esp
  80223f:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802243:	83 e0 f0             	and    $0xfffffff0,%eax
  802246:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802248:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80224a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802251:	eb d6                	jmp    802229 <spawnl+0x5d>
	...

00802254 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	56                   	push   %esi
  802258:	53                   	push   %ebx
  802259:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80225c:	83 ec 0c             	sub    $0xc,%esp
  80225f:	ff 75 08             	pushl  0x8(%ebp)
  802262:	e8 15 f2 ff ff       	call   80147c <fd2data>
  802267:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802269:	83 c4 08             	add    $0x8,%esp
  80226c:	68 42 32 80 00       	push   $0x803242
  802271:	56                   	push   %esi
  802272:	e8 17 e9 ff ff       	call   800b8e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802277:	8b 43 04             	mov    0x4(%ebx),%eax
  80227a:	2b 03                	sub    (%ebx),%eax
  80227c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802282:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802289:	00 00 00 
	stat->st_dev = &devpipe;
  80228c:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802293:	40 80 00 
	return 0;
}
  802296:	b8 00 00 00 00       	mov    $0x0,%eax
  80229b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229e:	5b                   	pop    %ebx
  80229f:	5e                   	pop    %esi
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    

008022a2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022a2:	55                   	push   %ebp
  8022a3:	89 e5                	mov    %esp,%ebp
  8022a5:	53                   	push   %ebx
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022ac:	53                   	push   %ebx
  8022ad:	6a 00                	push   $0x0
  8022af:	e8 a6 ed ff ff       	call   80105a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022b4:	89 1c 24             	mov    %ebx,(%esp)
  8022b7:	e8 c0 f1 ff ff       	call   80147c <fd2data>
  8022bc:	83 c4 08             	add    $0x8,%esp
  8022bf:	50                   	push   %eax
  8022c0:	6a 00                	push   $0x0
  8022c2:	e8 93 ed ff ff       	call   80105a <sys_page_unmap>
}
  8022c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	57                   	push   %edi
  8022d0:	56                   	push   %esi
  8022d1:	53                   	push   %ebx
  8022d2:	83 ec 1c             	sub    $0x1c,%esp
  8022d5:	89 c7                	mov    %eax,%edi
  8022d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022da:	a1 04 50 80 00       	mov    0x805004,%eax
  8022df:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022e2:	83 ec 0c             	sub    $0xc,%esp
  8022e5:	57                   	push   %edi
  8022e6:	e8 21 05 00 00       	call   80280c <pageref>
  8022eb:	89 c6                	mov    %eax,%esi
  8022ed:	83 c4 04             	add    $0x4,%esp
  8022f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022f3:	e8 14 05 00 00       	call   80280c <pageref>
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	39 c6                	cmp    %eax,%esi
  8022fd:	0f 94 c0             	sete   %al
  802300:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802303:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802309:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80230c:	39 cb                	cmp    %ecx,%ebx
  80230e:	75 08                	jne    802318 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	c9                   	leave  
  802317:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802318:	83 f8 01             	cmp    $0x1,%eax
  80231b:	75 bd                	jne    8022da <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80231d:	8b 42 58             	mov    0x58(%edx),%eax
  802320:	6a 01                	push   $0x1
  802322:	50                   	push   %eax
  802323:	53                   	push   %ebx
  802324:	68 49 32 80 00       	push   $0x803249
  802329:	e8 aa e2 ff ff       	call   8005d8 <cprintf>
  80232e:	83 c4 10             	add    $0x10,%esp
  802331:	eb a7                	jmp    8022da <_pipeisclosed+0xe>

00802333 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	57                   	push   %edi
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	83 ec 28             	sub    $0x28,%esp
  80233c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80233f:	56                   	push   %esi
  802340:	e8 37 f1 ff ff       	call   80147c <fd2data>
  802345:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802347:	83 c4 10             	add    $0x10,%esp
  80234a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80234e:	75 4a                	jne    80239a <devpipe_write+0x67>
  802350:	bf 00 00 00 00       	mov    $0x0,%edi
  802355:	eb 56                	jmp    8023ad <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802357:	89 da                	mov    %ebx,%edx
  802359:	89 f0                	mov    %esi,%eax
  80235b:	e8 6c ff ff ff       	call   8022cc <_pipeisclosed>
  802360:	85 c0                	test   %eax,%eax
  802362:	75 4d                	jne    8023b1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802364:	e8 80 ec ff ff       	call   800fe9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802369:	8b 43 04             	mov    0x4(%ebx),%eax
  80236c:	8b 13                	mov    (%ebx),%edx
  80236e:	83 c2 20             	add    $0x20,%edx
  802371:	39 d0                	cmp    %edx,%eax
  802373:	73 e2                	jae    802357 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802375:	89 c2                	mov    %eax,%edx
  802377:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80237d:	79 05                	jns    802384 <devpipe_write+0x51>
  80237f:	4a                   	dec    %edx
  802380:	83 ca e0             	or     $0xffffffe0,%edx
  802383:	42                   	inc    %edx
  802384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802387:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80238a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80238e:	40                   	inc    %eax
  80238f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802392:	47                   	inc    %edi
  802393:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802396:	77 07                	ja     80239f <devpipe_write+0x6c>
  802398:	eb 13                	jmp    8023ad <devpipe_write+0x7a>
  80239a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80239f:	8b 43 04             	mov    0x4(%ebx),%eax
  8023a2:	8b 13                	mov    (%ebx),%edx
  8023a4:	83 c2 20             	add    $0x20,%edx
  8023a7:	39 d0                	cmp    %edx,%eax
  8023a9:	73 ac                	jae    802357 <devpipe_write+0x24>
  8023ab:	eb c8                	jmp    802375 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023ad:	89 f8                	mov    %edi,%eax
  8023af:	eb 05                	jmp    8023b6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5f                   	pop    %edi
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 18             	sub    $0x18,%esp
  8023c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023ca:	57                   	push   %edi
  8023cb:	e8 ac f0 ff ff       	call   80147c <fd2data>
  8023d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023d9:	75 44                	jne    80241f <devpipe_read+0x61>
  8023db:	be 00 00 00 00       	mov    $0x0,%esi
  8023e0:	eb 4f                	jmp    802431 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8023e2:	89 f0                	mov    %esi,%eax
  8023e4:	eb 54                	jmp    80243a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023e6:	89 da                	mov    %ebx,%edx
  8023e8:	89 f8                	mov    %edi,%eax
  8023ea:	e8 dd fe ff ff       	call   8022cc <_pipeisclosed>
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	75 42                	jne    802435 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023f3:	e8 f1 eb ff ff       	call   800fe9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023f8:	8b 03                	mov    (%ebx),%eax
  8023fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023fd:	74 e7                	je     8023e6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023ff:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802404:	79 05                	jns    80240b <devpipe_read+0x4d>
  802406:	48                   	dec    %eax
  802407:	83 c8 e0             	or     $0xffffffe0,%eax
  80240a:	40                   	inc    %eax
  80240b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80240f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802412:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802415:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802417:	46                   	inc    %esi
  802418:	39 75 10             	cmp    %esi,0x10(%ebp)
  80241b:	77 07                	ja     802424 <devpipe_read+0x66>
  80241d:	eb 12                	jmp    802431 <devpipe_read+0x73>
  80241f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802424:	8b 03                	mov    (%ebx),%eax
  802426:	3b 43 04             	cmp    0x4(%ebx),%eax
  802429:	75 d4                	jne    8023ff <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80242b:	85 f6                	test   %esi,%esi
  80242d:	75 b3                	jne    8023e2 <devpipe_read+0x24>
  80242f:	eb b5                	jmp    8023e6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802431:	89 f0                	mov    %esi,%eax
  802433:	eb 05                	jmp    80243a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802435:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80243a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5f                   	pop    %edi
  802440:	c9                   	leave  
  802441:	c3                   	ret    

00802442 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	57                   	push   %edi
  802446:	56                   	push   %esi
  802447:	53                   	push   %ebx
  802448:	83 ec 28             	sub    $0x28,%esp
  80244b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80244e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802451:	50                   	push   %eax
  802452:	e8 3d f0 ff ff       	call   801494 <fd_alloc>
  802457:	89 c3                	mov    %eax,%ebx
  802459:	83 c4 10             	add    $0x10,%esp
  80245c:	85 c0                	test   %eax,%eax
  80245e:	0f 88 24 01 00 00    	js     802588 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802464:	83 ec 04             	sub    $0x4,%esp
  802467:	68 07 04 00 00       	push   $0x407
  80246c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80246f:	6a 00                	push   $0x0
  802471:	e8 9a eb ff ff       	call   801010 <sys_page_alloc>
  802476:	89 c3                	mov    %eax,%ebx
  802478:	83 c4 10             	add    $0x10,%esp
  80247b:	85 c0                	test   %eax,%eax
  80247d:	0f 88 05 01 00 00    	js     802588 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802483:	83 ec 0c             	sub    $0xc,%esp
  802486:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802489:	50                   	push   %eax
  80248a:	e8 05 f0 ff ff       	call   801494 <fd_alloc>
  80248f:	89 c3                	mov    %eax,%ebx
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	85 c0                	test   %eax,%eax
  802496:	0f 88 dc 00 00 00    	js     802578 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249c:	83 ec 04             	sub    $0x4,%esp
  80249f:	68 07 04 00 00       	push   $0x407
  8024a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8024a7:	6a 00                	push   $0x0
  8024a9:	e8 62 eb ff ff       	call   801010 <sys_page_alloc>
  8024ae:	89 c3                	mov    %eax,%ebx
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	85 c0                	test   %eax,%eax
  8024b5:	0f 88 bd 00 00 00    	js     802578 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024bb:	83 ec 0c             	sub    $0xc,%esp
  8024be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024c1:	e8 b6 ef ff ff       	call   80147c <fd2data>
  8024c6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024c8:	83 c4 0c             	add    $0xc,%esp
  8024cb:	68 07 04 00 00       	push   $0x407
  8024d0:	50                   	push   %eax
  8024d1:	6a 00                	push   $0x0
  8024d3:	e8 38 eb ff ff       	call   801010 <sys_page_alloc>
  8024d8:	89 c3                	mov    %eax,%ebx
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	85 c0                	test   %eax,%eax
  8024df:	0f 88 83 00 00 00    	js     802568 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e5:	83 ec 0c             	sub    $0xc,%esp
  8024e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8024eb:	e8 8c ef ff ff       	call   80147c <fd2data>
  8024f0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024f7:	50                   	push   %eax
  8024f8:	6a 00                	push   $0x0
  8024fa:	56                   	push   %esi
  8024fb:	6a 00                	push   $0x0
  8024fd:	e8 32 eb ff ff       	call   801034 <sys_page_map>
  802502:	89 c3                	mov    %eax,%ebx
  802504:	83 c4 20             	add    $0x20,%esp
  802507:	85 c0                	test   %eax,%eax
  802509:	78 4f                	js     80255a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80250b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802514:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802516:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802519:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802520:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802529:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80252b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80252e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802535:	83 ec 0c             	sub    $0xc,%esp
  802538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80253b:	e8 2c ef ff ff       	call   80146c <fd2num>
  802540:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802542:	83 c4 04             	add    $0x4,%esp
  802545:	ff 75 e0             	pushl  -0x20(%ebp)
  802548:	e8 1f ef ff ff       	call   80146c <fd2num>
  80254d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	bb 00 00 00 00       	mov    $0x0,%ebx
  802558:	eb 2e                	jmp    802588 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80255a:	83 ec 08             	sub    $0x8,%esp
  80255d:	56                   	push   %esi
  80255e:	6a 00                	push   $0x0
  802560:	e8 f5 ea ff ff       	call   80105a <sys_page_unmap>
  802565:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802568:	83 ec 08             	sub    $0x8,%esp
  80256b:	ff 75 e0             	pushl  -0x20(%ebp)
  80256e:	6a 00                	push   $0x0
  802570:	e8 e5 ea ff ff       	call   80105a <sys_page_unmap>
  802575:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802578:	83 ec 08             	sub    $0x8,%esp
  80257b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80257e:	6a 00                	push   $0x0
  802580:	e8 d5 ea ff ff       	call   80105a <sys_page_unmap>
  802585:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802588:	89 d8                	mov    %ebx,%eax
  80258a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	c9                   	leave  
  802591:	c3                   	ret    

00802592 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
  802595:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80259b:	50                   	push   %eax
  80259c:	ff 75 08             	pushl  0x8(%ebp)
  80259f:	e8 63 ef ff ff       	call   801507 <fd_lookup>
  8025a4:	83 c4 10             	add    $0x10,%esp
  8025a7:	85 c0                	test   %eax,%eax
  8025a9:	78 18                	js     8025c3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025ab:	83 ec 0c             	sub    $0xc,%esp
  8025ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b1:	e8 c6 ee ff ff       	call   80147c <fd2data>
	return _pipeisclosed(fd, p);
  8025b6:	89 c2                	mov    %eax,%edx
  8025b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025bb:	e8 0c fd ff ff       	call   8022cc <_pipeisclosed>
  8025c0:	83 c4 10             	add    $0x10,%esp
}
  8025c3:	c9                   	leave  
  8025c4:	c3                   	ret    
  8025c5:	00 00                	add    %al,(%eax)
	...

008025c8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025c8:	55                   	push   %ebp
  8025c9:	89 e5                	mov    %esp,%ebp
  8025cb:	57                   	push   %edi
  8025cc:	56                   	push   %esi
  8025cd:	53                   	push   %ebx
  8025ce:	83 ec 0c             	sub    $0xc,%esp
  8025d1:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  8025d4:	85 c0                	test   %eax,%eax
  8025d6:	75 16                	jne    8025ee <wait+0x26>
  8025d8:	68 61 32 80 00       	push   $0x803261
  8025dd:	68 63 31 80 00       	push   $0x803163
  8025e2:	6a 09                	push   $0x9
  8025e4:	68 6c 32 80 00       	push   $0x80326c
  8025e9:	e8 12 df ff ff       	call   800500 <_panic>
	e = &envs[ENVX(envid)];
  8025ee:	89 c6                	mov    %eax,%esi
  8025f0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025f6:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  8025fd:	89 f2                	mov    %esi,%edx
  8025ff:	c1 e2 07             	shl    $0x7,%edx
  802602:	29 ca                	sub    %ecx,%edx
  802604:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  80260a:	8b 7a 40             	mov    0x40(%edx),%edi
  80260d:	39 c7                	cmp    %eax,%edi
  80260f:	75 37                	jne    802648 <wait+0x80>
  802611:	89 f0                	mov    %esi,%eax
  802613:	c1 e0 07             	shl    $0x7,%eax
  802616:	29 c8                	sub    %ecx,%eax
  802618:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80261d:	8b 40 50             	mov    0x50(%eax),%eax
  802620:	85 c0                	test   %eax,%eax
  802622:	74 24                	je     802648 <wait+0x80>
  802624:	c1 e6 07             	shl    $0x7,%esi
  802627:	29 ce                	sub    %ecx,%esi
  802629:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  80262f:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802635:	e8 af e9 ff ff       	call   800fe9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80263a:	8b 43 40             	mov    0x40(%ebx),%eax
  80263d:	39 f8                	cmp    %edi,%eax
  80263f:	75 07                	jne    802648 <wait+0x80>
  802641:	8b 46 50             	mov    0x50(%esi),%eax
  802644:	85 c0                	test   %eax,%eax
  802646:	75 ed                	jne    802635 <wait+0x6d>
		sys_yield();
}
  802648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264b:	5b                   	pop    %ebx
  80264c:	5e                   	pop    %esi
  80264d:	5f                   	pop    %edi
  80264e:	c9                   	leave  
  80264f:	c3                   	ret    

00802650 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802650:	55                   	push   %ebp
  802651:	89 e5                	mov    %esp,%ebp
  802653:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802656:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80265d:	75 52                	jne    8026b1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80265f:	83 ec 04             	sub    $0x4,%esp
  802662:	6a 07                	push   $0x7
  802664:	68 00 f0 bf ee       	push   $0xeebff000
  802669:	6a 00                	push   $0x0
  80266b:	e8 a0 e9 ff ff       	call   801010 <sys_page_alloc>
		if (r < 0) {
  802670:	83 c4 10             	add    $0x10,%esp
  802673:	85 c0                	test   %eax,%eax
  802675:	79 12                	jns    802689 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802677:	50                   	push   %eax
  802678:	68 77 32 80 00       	push   $0x803277
  80267d:	6a 24                	push   $0x24
  80267f:	68 92 32 80 00       	push   $0x803292
  802684:	e8 77 de ff ff       	call   800500 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802689:	83 ec 08             	sub    $0x8,%esp
  80268c:	68 bc 26 80 00       	push   $0x8026bc
  802691:	6a 00                	push   $0x0
  802693:	e8 2b ea ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802698:	83 c4 10             	add    $0x10,%esp
  80269b:	85 c0                	test   %eax,%eax
  80269d:	79 12                	jns    8026b1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80269f:	50                   	push   %eax
  8026a0:	68 a0 32 80 00       	push   $0x8032a0
  8026a5:	6a 2a                	push   $0x2a
  8026a7:	68 92 32 80 00       	push   $0x803292
  8026ac:	e8 4f de ff ff       	call   800500 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b4:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026b9:	c9                   	leave  
  8026ba:	c3                   	ret    
	...

008026bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026bd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026c4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8026c7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8026cb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8026ce:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8026d2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8026d6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8026d8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8026db:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8026dc:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8026df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8026e0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026e1:	c3                   	ret    
	...

008026e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026e4:	55                   	push   %ebp
  8026e5:	89 e5                	mov    %esp,%ebp
  8026e7:	56                   	push   %esi
  8026e8:	53                   	push   %ebx
  8026e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8026ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8026f2:	85 c0                	test   %eax,%eax
  8026f4:	74 0e                	je     802704 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8026f6:	83 ec 0c             	sub    $0xc,%esp
  8026f9:	50                   	push   %eax
  8026fa:	e8 0c ea ff ff       	call   80110b <sys_ipc_recv>
  8026ff:	83 c4 10             	add    $0x10,%esp
  802702:	eb 10                	jmp    802714 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802704:	83 ec 0c             	sub    $0xc,%esp
  802707:	68 00 00 c0 ee       	push   $0xeec00000
  80270c:	e8 fa e9 ff ff       	call   80110b <sys_ipc_recv>
  802711:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802714:	85 c0                	test   %eax,%eax
  802716:	75 26                	jne    80273e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802718:	85 f6                	test   %esi,%esi
  80271a:	74 0a                	je     802726 <ipc_recv+0x42>
  80271c:	a1 04 50 80 00       	mov    0x805004,%eax
  802721:	8b 40 74             	mov    0x74(%eax),%eax
  802724:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802726:	85 db                	test   %ebx,%ebx
  802728:	74 0a                	je     802734 <ipc_recv+0x50>
  80272a:	a1 04 50 80 00       	mov    0x805004,%eax
  80272f:	8b 40 78             	mov    0x78(%eax),%eax
  802732:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802734:	a1 04 50 80 00       	mov    0x805004,%eax
  802739:	8b 40 70             	mov    0x70(%eax),%eax
  80273c:	eb 14                	jmp    802752 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80273e:	85 f6                	test   %esi,%esi
  802740:	74 06                	je     802748 <ipc_recv+0x64>
  802742:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802748:	85 db                	test   %ebx,%ebx
  80274a:	74 06                	je     802752 <ipc_recv+0x6e>
  80274c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802752:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802755:	5b                   	pop    %ebx
  802756:	5e                   	pop    %esi
  802757:	c9                   	leave  
  802758:	c3                   	ret    

00802759 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802759:	55                   	push   %ebp
  80275a:	89 e5                	mov    %esp,%ebp
  80275c:	57                   	push   %edi
  80275d:	56                   	push   %esi
  80275e:	53                   	push   %ebx
  80275f:	83 ec 0c             	sub    $0xc,%esp
  802762:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802765:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802768:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80276b:	85 db                	test   %ebx,%ebx
  80276d:	75 25                	jne    802794 <ipc_send+0x3b>
  80276f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802774:	eb 1e                	jmp    802794 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802776:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802779:	75 07                	jne    802782 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80277b:	e8 69 e8 ff ff       	call   800fe9 <sys_yield>
  802780:	eb 12                	jmp    802794 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802782:	50                   	push   %eax
  802783:	68 c8 32 80 00       	push   $0x8032c8
  802788:	6a 43                	push   $0x43
  80278a:	68 db 32 80 00       	push   $0x8032db
  80278f:	e8 6c dd ff ff       	call   800500 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802794:	56                   	push   %esi
  802795:	53                   	push   %ebx
  802796:	57                   	push   %edi
  802797:	ff 75 08             	pushl  0x8(%ebp)
  80279a:	e8 47 e9 ff ff       	call   8010e6 <sys_ipc_try_send>
  80279f:	83 c4 10             	add    $0x10,%esp
  8027a2:	85 c0                	test   %eax,%eax
  8027a4:	75 d0                	jne    802776 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8027a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a9:	5b                   	pop    %ebx
  8027aa:	5e                   	pop    %esi
  8027ab:	5f                   	pop    %edi
  8027ac:	c9                   	leave  
  8027ad:	c3                   	ret    

008027ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027ae:	55                   	push   %ebp
  8027af:	89 e5                	mov    %esp,%ebp
  8027b1:	53                   	push   %ebx
  8027b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8027b5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8027bb:	74 22                	je     8027df <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027bd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8027c2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8027c9:	89 c2                	mov    %eax,%edx
  8027cb:	c1 e2 07             	shl    $0x7,%edx
  8027ce:	29 ca                	sub    %ecx,%edx
  8027d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d6:	8b 52 50             	mov    0x50(%edx),%edx
  8027d9:	39 da                	cmp    %ebx,%edx
  8027db:	75 1d                	jne    8027fa <ipc_find_env+0x4c>
  8027dd:	eb 05                	jmp    8027e4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027df:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8027e4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8027eb:	c1 e0 07             	shl    $0x7,%eax
  8027ee:	29 d0                	sub    %edx,%eax
  8027f0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027f5:	8b 40 40             	mov    0x40(%eax),%eax
  8027f8:	eb 0c                	jmp    802806 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027fa:	40                   	inc    %eax
  8027fb:	3d 00 04 00 00       	cmp    $0x400,%eax
  802800:	75 c0                	jne    8027c2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802802:	66 b8 00 00          	mov    $0x0,%ax
}
  802806:	5b                   	pop    %ebx
  802807:	c9                   	leave  
  802808:	c3                   	ret    
  802809:	00 00                	add    %al,(%eax)
	...

0080280c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80280c:	55                   	push   %ebp
  80280d:	89 e5                	mov    %esp,%ebp
  80280f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802812:	89 c2                	mov    %eax,%edx
  802814:	c1 ea 16             	shr    $0x16,%edx
  802817:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80281e:	f6 c2 01             	test   $0x1,%dl
  802821:	74 1e                	je     802841 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802823:	c1 e8 0c             	shr    $0xc,%eax
  802826:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80282d:	a8 01                	test   $0x1,%al
  80282f:	74 17                	je     802848 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802831:	c1 e8 0c             	shr    $0xc,%eax
  802834:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80283b:	ef 
  80283c:	0f b7 c0             	movzwl %ax,%eax
  80283f:	eb 0c                	jmp    80284d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802841:	b8 00 00 00 00       	mov    $0x0,%eax
  802846:	eb 05                	jmp    80284d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802848:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80284d:	c9                   	leave  
  80284e:	c3                   	ret    
	...

00802850 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802850:	55                   	push   %ebp
  802851:	89 e5                	mov    %esp,%ebp
  802853:	57                   	push   %edi
  802854:	56                   	push   %esi
  802855:	83 ec 10             	sub    $0x10,%esp
  802858:	8b 7d 08             	mov    0x8(%ebp),%edi
  80285b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80285e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802861:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802864:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802867:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80286a:	85 c0                	test   %eax,%eax
  80286c:	75 2e                	jne    80289c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80286e:	39 f1                	cmp    %esi,%ecx
  802870:	77 5a                	ja     8028cc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802872:	85 c9                	test   %ecx,%ecx
  802874:	75 0b                	jne    802881 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802876:	b8 01 00 00 00       	mov    $0x1,%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	f7 f1                	div    %ecx
  80287f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802881:	31 d2                	xor    %edx,%edx
  802883:	89 f0                	mov    %esi,%eax
  802885:	f7 f1                	div    %ecx
  802887:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802889:	89 f8                	mov    %edi,%eax
  80288b:	f7 f1                	div    %ecx
  80288d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80288f:	89 f8                	mov    %edi,%eax
  802891:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802893:	83 c4 10             	add    $0x10,%esp
  802896:	5e                   	pop    %esi
  802897:	5f                   	pop    %edi
  802898:	c9                   	leave  
  802899:	c3                   	ret    
  80289a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80289c:	39 f0                	cmp    %esi,%eax
  80289e:	77 1c                	ja     8028bc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028a0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8028a3:	83 f7 1f             	xor    $0x1f,%edi
  8028a6:	75 3c                	jne    8028e4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028a8:	39 f0                	cmp    %esi,%eax
  8028aa:	0f 82 90 00 00 00    	jb     802940 <__udivdi3+0xf0>
  8028b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8028b3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8028b6:	0f 86 84 00 00 00    	jbe    802940 <__udivdi3+0xf0>
  8028bc:	31 f6                	xor    %esi,%esi
  8028be:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028c0:	89 f8                	mov    %edi,%eax
  8028c2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028c4:	83 c4 10             	add    $0x10,%esp
  8028c7:	5e                   	pop    %esi
  8028c8:	5f                   	pop    %edi
  8028c9:	c9                   	leave  
  8028ca:	c3                   	ret    
  8028cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028cc:	89 f2                	mov    %esi,%edx
  8028ce:	89 f8                	mov    %edi,%eax
  8028d0:	f7 f1                	div    %ecx
  8028d2:	89 c7                	mov    %eax,%edi
  8028d4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028d6:	89 f8                	mov    %edi,%eax
  8028d8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028da:	83 c4 10             	add    $0x10,%esp
  8028dd:	5e                   	pop    %esi
  8028de:	5f                   	pop    %edi
  8028df:	c9                   	leave  
  8028e0:	c3                   	ret    
  8028e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028e4:	89 f9                	mov    %edi,%ecx
  8028e6:	d3 e0                	shl    %cl,%eax
  8028e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028eb:	b8 20 00 00 00       	mov    $0x20,%eax
  8028f0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8028f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028f5:	88 c1                	mov    %al,%cl
  8028f7:	d3 ea                	shr    %cl,%edx
  8028f9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8028fc:	09 ca                	or     %ecx,%edx
  8028fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802904:	89 f9                	mov    %edi,%ecx
  802906:	d3 e2                	shl    %cl,%edx
  802908:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80290b:	89 f2                	mov    %esi,%edx
  80290d:	88 c1                	mov    %al,%cl
  80290f:	d3 ea                	shr    %cl,%edx
  802911:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802914:	89 f2                	mov    %esi,%edx
  802916:	89 f9                	mov    %edi,%ecx
  802918:	d3 e2                	shl    %cl,%edx
  80291a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80291d:	88 c1                	mov    %al,%cl
  80291f:	d3 ee                	shr    %cl,%esi
  802921:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802923:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802926:	89 f0                	mov    %esi,%eax
  802928:	89 ca                	mov    %ecx,%edx
  80292a:	f7 75 ec             	divl   -0x14(%ebp)
  80292d:	89 d1                	mov    %edx,%ecx
  80292f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802931:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802934:	39 d1                	cmp    %edx,%ecx
  802936:	72 28                	jb     802960 <__udivdi3+0x110>
  802938:	74 1a                	je     802954 <__udivdi3+0x104>
  80293a:	89 f7                	mov    %esi,%edi
  80293c:	31 f6                	xor    %esi,%esi
  80293e:	eb 80                	jmp    8028c0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802940:	31 f6                	xor    %esi,%esi
  802942:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802947:	89 f8                	mov    %edi,%eax
  802949:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80294b:	83 c4 10             	add    $0x10,%esp
  80294e:	5e                   	pop    %esi
  80294f:	5f                   	pop    %edi
  802950:	c9                   	leave  
  802951:	c3                   	ret    
  802952:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802954:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802957:	89 f9                	mov    %edi,%ecx
  802959:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80295b:	39 c2                	cmp    %eax,%edx
  80295d:	73 db                	jae    80293a <__udivdi3+0xea>
  80295f:	90                   	nop
		{
		  q0--;
  802960:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802963:	31 f6                	xor    %esi,%esi
  802965:	e9 56 ff ff ff       	jmp    8028c0 <__udivdi3+0x70>
	...

0080296c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80296c:	55                   	push   %ebp
  80296d:	89 e5                	mov    %esp,%ebp
  80296f:	57                   	push   %edi
  802970:	56                   	push   %esi
  802971:	83 ec 20             	sub    $0x20,%esp
  802974:	8b 45 08             	mov    0x8(%ebp),%eax
  802977:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80297a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80297d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802980:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802983:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802986:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802989:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80298b:	85 ff                	test   %edi,%edi
  80298d:	75 15                	jne    8029a4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80298f:	39 f1                	cmp    %esi,%ecx
  802991:	0f 86 99 00 00 00    	jbe    802a30 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802997:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802999:	89 d0                	mov    %edx,%eax
  80299b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80299d:	83 c4 20             	add    $0x20,%esp
  8029a0:	5e                   	pop    %esi
  8029a1:	5f                   	pop    %edi
  8029a2:	c9                   	leave  
  8029a3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029a4:	39 f7                	cmp    %esi,%edi
  8029a6:	0f 87 a4 00 00 00    	ja     802a50 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029ac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8029af:	83 f0 1f             	xor    $0x1f,%eax
  8029b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8029b5:	0f 84 a1 00 00 00    	je     802a5c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029bb:	89 f8                	mov    %edi,%eax
  8029bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8029c0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8029c7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8029ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029cd:	89 f9                	mov    %edi,%ecx
  8029cf:	d3 ea                	shr    %cl,%edx
  8029d1:	09 c2                	or     %eax,%edx
  8029d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8029d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029d9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8029dc:	d3 e0                	shl    %cl,%eax
  8029de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029e1:	89 f2                	mov    %esi,%edx
  8029e3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8029e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8029e8:	d3 e0                	shl    %cl,%eax
  8029ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8029f0:	89 f9                	mov    %edi,%ecx
  8029f2:	d3 e8                	shr    %cl,%eax
  8029f4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8029f6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029f8:	89 f2                	mov    %esi,%edx
  8029fa:	f7 75 f0             	divl   -0x10(%ebp)
  8029fd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8029ff:	f7 65 f4             	mull   -0xc(%ebp)
  802a02:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802a05:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a07:	39 d6                	cmp    %edx,%esi
  802a09:	72 71                	jb     802a7c <__umoddi3+0x110>
  802a0b:	74 7f                	je     802a8c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a10:	29 c8                	sub    %ecx,%eax
  802a12:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802a14:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802a17:	d3 e8                	shr    %cl,%eax
  802a19:	89 f2                	mov    %esi,%edx
  802a1b:	89 f9                	mov    %edi,%ecx
  802a1d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802a1f:	09 d0                	or     %edx,%eax
  802a21:	89 f2                	mov    %esi,%edx
  802a23:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802a26:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a28:	83 c4 20             	add    $0x20,%esp
  802a2b:	5e                   	pop    %esi
  802a2c:	5f                   	pop    %edi
  802a2d:	c9                   	leave  
  802a2e:	c3                   	ret    
  802a2f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a30:	85 c9                	test   %ecx,%ecx
  802a32:	75 0b                	jne    802a3f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a34:	b8 01 00 00 00       	mov    $0x1,%eax
  802a39:	31 d2                	xor    %edx,%edx
  802a3b:	f7 f1                	div    %ecx
  802a3d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a3f:	89 f0                	mov    %esi,%eax
  802a41:	31 d2                	xor    %edx,%edx
  802a43:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a48:	f7 f1                	div    %ecx
  802a4a:	e9 4a ff ff ff       	jmp    802999 <__umoddi3+0x2d>
  802a4f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a52:	83 c4 20             	add    $0x20,%esp
  802a55:	5e                   	pop    %esi
  802a56:	5f                   	pop    %edi
  802a57:	c9                   	leave  
  802a58:	c3                   	ret    
  802a59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a5c:	39 f7                	cmp    %esi,%edi
  802a5e:	72 05                	jb     802a65 <__umoddi3+0xf9>
  802a60:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802a63:	77 0c                	ja     802a71 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a65:	89 f2                	mov    %esi,%edx
  802a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a6a:	29 c8                	sub    %ecx,%eax
  802a6c:	19 fa                	sbb    %edi,%edx
  802a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a74:	83 c4 20             	add    $0x20,%esp
  802a77:	5e                   	pop    %esi
  802a78:	5f                   	pop    %edi
  802a79:	c9                   	leave  
  802a7a:	c3                   	ret    
  802a7b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a7c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802a7f:	89 c1                	mov    %eax,%ecx
  802a81:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802a84:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802a87:	eb 84                	jmp    802a0d <__umoddi3+0xa1>
  802a89:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802a8f:	72 eb                	jb     802a7c <__umoddi3+0x110>
  802a91:	89 f2                	mov    %esi,%edx
  802a93:	e9 75 ff ff ff       	jmp    802a0d <__umoddi3+0xa1>
