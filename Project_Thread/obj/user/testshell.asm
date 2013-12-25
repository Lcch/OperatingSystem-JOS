
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
  80004b:	e8 fa 18 00 00       	call   80194a <seek>
	seek(kfd, off);
  800050:	83 c4 08             	add    $0x8,%esp
  800053:	53                   	push   %ebx
  800054:	56                   	push   %esi
  800055:	e8 f0 18 00 00       	call   80194a <seek>

	cprintf("shell produced incorrect output.\n");
  80005a:	c7 04 24 20 2d 80 00 	movl   $0x802d20,(%esp)
  800061:	e8 6e 05 00 00       	call   8005d4 <cprintf>
	cprintf("expected:\n===\n");
  800066:	c7 04 24 8b 2d 80 00 	movl   $0x802d8b,(%esp)
  80006d:	e8 62 05 00 00       	call   8005d4 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800078:	eb 0d                	jmp    800087 <wrong+0x53>
		sys_cputs(buf, n);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	50                   	push   %eax
  80007e:	53                   	push   %ebx
  80007f:	e8 d1 0e 00 00       	call   800f55 <sys_cputs>
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
  80008e:	e8 59 17 00 00       	call   8017ec <read>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	7f e0                	jg     80007a <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 9a 2d 80 00       	push   $0x802d9a
  8000a2:	e8 2d 05 00 00       	call   8005d4 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ad:	eb 0d                	jmp    8000bc <wrong+0x88>
		sys_cputs(buf, n);
  8000af:	83 ec 08             	sub    $0x8,%esp
  8000b2:	50                   	push   %eax
  8000b3:	53                   	push   %ebx
  8000b4:	e8 9c 0e 00 00       	call   800f55 <sys_cputs>
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
  8000c3:	e8 24 17 00 00       	call   8017ec <read>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f e0                	jg     8000af <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	68 95 2d 80 00       	push   $0x802d95
  8000d7:	e8 f8 04 00 00       	call   8005d4 <cprintf>
	exit();
  8000dc:	e8 ff 03 00 00       	call   8004e0 <exit>
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
  8000f7:	e8 b3 15 00 00       	call   8016af <close>
	close(1);
  8000fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800103:	e8 a7 15 00 00       	call   8016af <close>
	opencons();
  800108:	e8 35 03 00 00       	call   800442 <opencons>
	opencons();
  80010d:	e8 30 03 00 00       	call   800442 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 00                	push   $0x0
  800117:	68 a8 2d 80 00       	push   $0x802da8
  80011c:	e8 cf 1a 00 00       	call   801bf0 <open>
  800121:	89 c6                	mov    %eax,%esi
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	85 c0                	test   %eax,%eax
  800128:	79 12                	jns    80013c <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  80012a:	50                   	push   %eax
  80012b:	68 b5 2d 80 00       	push   $0x802db5
  800130:	6a 13                	push   $0x13
  800132:	68 cb 2d 80 00       	push   $0x802dcb
  800137:	e8 c0 03 00 00       	call   8004fc <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 86 25 00 00       	call   8026ce <pipe>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	79 12                	jns    800161 <umain+0x75>
		panic("pipe: %e", wfd);
  80014f:	50                   	push   %eax
  800150:	68 dc 2d 80 00       	push   $0x802ddc
  800155:	6a 15                	push   $0x15
  800157:	68 cb 2d 80 00       	push   $0x802dcb
  80015c:	e8 9b 03 00 00       	call   8004fc <_panic>
	wfd = pfds[1];
  800161:	8b 7d e0             	mov    -0x20(%ebp),%edi

	cprintf("running sh -x < testshell.sh | cat\n");
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	68 44 2d 80 00       	push   $0x802d44
  80016c:	e8 63 04 00 00       	call   8005d4 <cprintf>
	if ((r = fork()) < 0)
  800171:	e8 14 11 00 00       	call   80128a <fork>
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	79 12                	jns    80018f <umain+0xa3>
		panic("fork: %e", r);
  80017d:	50                   	push   %eax
  80017e:	68 e5 2d 80 00       	push   $0x802de5
  800183:	6a 1a                	push   $0x1a
  800185:	68 cb 2d 80 00       	push   $0x802dcb
  80018a:	e8 6d 03 00 00       	call   8004fc <_panic>
	if (r == 0) {
  80018f:	85 c0                	test   %eax,%eax
  800191:	75 7d                	jne    800210 <umain+0x124>
		dup(rfd, 0);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	6a 00                	push   $0x0
  800198:	56                   	push   %esi
  800199:	e8 5f 15 00 00       	call   8016fd <dup>
		dup(wfd, 1);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	6a 01                	push   $0x1
  8001a3:	57                   	push   %edi
  8001a4:	e8 54 15 00 00       	call   8016fd <dup>
		close(rfd);
  8001a9:	89 34 24             	mov    %esi,(%esp)
  8001ac:	e8 fe 14 00 00       	call   8016af <close>
		close(wfd);
  8001b1:	89 3c 24             	mov    %edi,(%esp)
  8001b4:	e8 f6 14 00 00       	call   8016af <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b9:	6a 00                	push   $0x0
  8001bb:	68 ee 2d 80 00       	push   $0x802dee
  8001c0:	68 b2 2d 80 00       	push   $0x802db2
  8001c5:	68 f1 2d 80 00       	push   $0x802df1
  8001ca:	e8 87 22 00 00       	call   802456 <spawnl>
  8001cf:	89 c3                	mov    %eax,%ebx
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	79 12                	jns    8001ea <umain+0xfe>
			panic("spawn: %e", r);
  8001d8:	50                   	push   %eax
  8001d9:	68 f5 2d 80 00       	push   $0x802df5
  8001de:	6a 21                	push   $0x21
  8001e0:	68 cb 2d 80 00       	push   $0x802dcb
  8001e5:	e8 12 03 00 00       	call   8004fc <_panic>
		close(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 bb 14 00 00       	call   8016af <close>
		close(1);
  8001f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fb:	e8 af 14 00 00       	call   8016af <close>
		wait(r);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 4c 26 00 00       	call   802854 <wait>
		exit();
  800208:	e8 d3 02 00 00       	call   8004e0 <exit>
  80020d:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	56                   	push   %esi
  800214:	e8 96 14 00 00       	call   8016af <close>
	close(wfd);
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	e8 8e 14 00 00       	call   8016af <close>

	rfd = pfds[0];
  800221:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800224:	83 c4 08             	add    $0x8,%esp
  800227:	6a 00                	push   $0x0
  800229:	68 ff 2d 80 00       	push   $0x802dff
  80022e:	e8 bd 19 00 00       	call   801bf0 <open>
  800233:	89 c6                	mov    %eax,%esi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x162>
		panic("open testshell.key for reading: %e", kfd);
  80023c:	50                   	push   %eax
  80023d:	68 68 2d 80 00       	push   $0x802d68
  800242:	6a 2c                	push   $0x2c
  800244:	68 cb 2d 80 00       	push   $0x802dcb
  800249:	e8 ae 02 00 00       	call   8004fc <_panic>
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
  800266:	e8 81 15 00 00       	call   8017ec <read>
  80026b:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026d:	83 c4 0c             	add    $0xc,%esp
  800270:	6a 01                	push   $0x1
  800272:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	56                   	push   %esi
  800277:	e8 70 15 00 00       	call   8017ec <read>
		if (n1 < 0)
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 db                	test   %ebx,%ebx
  800281:	79 12                	jns    800295 <umain+0x1a9>
			panic("reading testshell.out: %e", n1);
  800283:	53                   	push   %ebx
  800284:	68 0d 2e 80 00       	push   $0x802e0d
  800289:	6a 33                	push   $0x33
  80028b:	68 cb 2d 80 00       	push   $0x802dcb
  800290:	e8 67 02 00 00       	call   8004fc <_panic>
		if (n2 < 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	79 12                	jns    8002ab <umain+0x1bf>
			panic("reading testshell.key: %e", n2);
  800299:	50                   	push   %eax
  80029a:	68 27 2e 80 00       	push   $0x802e27
  80029f:	6a 35                	push   $0x35
  8002a1:	68 cb 2d 80 00       	push   $0x802dcb
  8002a6:	e8 51 02 00 00       	call   8004fc <_panic>
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
  8002ee:	68 41 2e 80 00       	push   $0x802e41
  8002f3:	e8 dc 02 00 00       	call   8005d4 <cprintf>
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
  800314:	68 56 2e 80 00       	push   $0x802e56
  800319:	ff 75 0c             	pushl  0xc(%ebp)
  80031c:	e8 69 08 00 00       	call   800b8a <strcpy>
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
  800362:	e8 e4 09 00 00       	call   800d4b <memmove>
		sys_cputs(buf, m);
  800367:	83 c4 08             	add    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	57                   	push   %edi
  80036c:	e8 e4 0b 00 00       	call   800f55 <sys_cputs>
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
  80039c:	e8 44 0c 00 00       	call   800fe5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8003a1:	e8 d5 0b 00 00       	call   800f7b <sys_cgetc>
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
  8003e1:	e8 6f 0b 00 00       	call   800f55 <sys_cputs>
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
  8003f9:	e8 ee 13 00 00       	call   8017ec <read>
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
  800423:	e8 43 11 00 00       	call   80156b <fd_lookup>
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
  80044c:	e8 a7 10 00 00       	call   8014f8 <fd_alloc>
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 c0                	test   %eax,%eax
  800456:	78 3a                	js     800492 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	68 07 04 00 00       	push   $0x407
  800460:	ff 75 f4             	pushl  -0xc(%ebp)
  800463:	6a 00                	push   $0x0
  800465:	e8 a2 0b 00 00       	call   80100c <sys_page_alloc>
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
  80048a:	e8 41 10 00 00       	call   8014d0 <fd2num>
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
  80049f:	e8 1d 0b 00 00       	call   800fc1 <sys_getenvid>
  8004a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a9:	89 c2                	mov    %eax,%edx
  8004ab:	c1 e2 07             	shl    $0x7,%edx
  8004ae:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8004b5:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004ba:	85 f6                	test   %esi,%esi
  8004bc:	7e 07                	jle    8004c5 <libmain+0x31>
		binaryname = argv[0];
  8004be:	8b 03                	mov    (%ebx),%eax
  8004c0:	a3 1c 40 80 00       	mov    %eax,0x80401c
	// call user main routine
	umain(argc, argv);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 1d fc ff ff       	call   8000ec <umain>

	// exit gracefully
	exit();
  8004cf:	e8 0c 00 00 00       	call   8004e0 <exit>
  8004d4:	83 c4 10             	add    $0x10,%esp
}
  8004d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004da:	5b                   	pop    %ebx
  8004db:	5e                   	pop    %esi
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
	...

008004e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004e6:	e8 ef 11 00 00       	call   8016da <close_all>
	sys_env_destroy(0);
  8004eb:	83 ec 0c             	sub    $0xc,%esp
  8004ee:	6a 00                	push   $0x0
  8004f0:	e8 aa 0a 00 00       	call   800f9f <sys_env_destroy>
  8004f5:	83 c4 10             	add    $0x10,%esp
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    
	...

008004fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800501:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800504:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  80050a:	e8 b2 0a 00 00       	call   800fc1 <sys_getenvid>
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	53                   	push   %ebx
  800519:	50                   	push   %eax
  80051a:	68 6c 2e 80 00       	push   $0x802e6c
  80051f:	e8 b0 00 00 00       	call   8005d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800524:	83 c4 18             	add    $0x18,%esp
  800527:	56                   	push   %esi
  800528:	ff 75 10             	pushl  0x10(%ebp)
  80052b:	e8 53 00 00 00       	call   800583 <vcprintf>
	cprintf("\n");
  800530:	c7 04 24 98 2d 80 00 	movl   $0x802d98,(%esp)
  800537:	e8 98 00 00 00       	call   8005d4 <cprintf>
  80053c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80053f:	cc                   	int3   
  800540:	eb fd                	jmp    80053f <_panic+0x43>
	...

00800544 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	53                   	push   %ebx
  800548:	83 ec 04             	sub    $0x4,%esp
  80054b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80054e:	8b 03                	mov    (%ebx),%eax
  800550:	8b 55 08             	mov    0x8(%ebp),%edx
  800553:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800557:	40                   	inc    %eax
  800558:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80055a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80055f:	75 1a                	jne    80057b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	68 ff 00 00 00       	push   $0xff
  800569:	8d 43 08             	lea    0x8(%ebx),%eax
  80056c:	50                   	push   %eax
  80056d:	e8 e3 09 00 00       	call   800f55 <sys_cputs>
		b->idx = 0;
  800572:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800578:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80057b:	ff 43 04             	incl   0x4(%ebx)
}
  80057e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80058c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800593:	00 00 00 
	b.cnt = 0;
  800596:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80059d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005a0:	ff 75 0c             	pushl  0xc(%ebp)
  8005a3:	ff 75 08             	pushl  0x8(%ebp)
  8005a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005ac:	50                   	push   %eax
  8005ad:	68 44 05 80 00       	push   $0x800544
  8005b2:	e8 82 01 00 00       	call   800739 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005c6:	50                   	push   %eax
  8005c7:	e8 89 09 00 00       	call   800f55 <sys_cputs>

	return b.cnt;
}
  8005cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005d2:	c9                   	leave  
  8005d3:	c3                   	ret    

008005d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005d4:	55                   	push   %ebp
  8005d5:	89 e5                	mov    %esp,%ebp
  8005d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005dd:	50                   	push   %eax
  8005de:	ff 75 08             	pushl  0x8(%ebp)
  8005e1:	e8 9d ff ff ff       	call   800583 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005e6:	c9                   	leave  
  8005e7:	c3                   	ret    

008005e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	57                   	push   %edi
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
  8005ee:	83 ec 2c             	sub    $0x2c,%esp
  8005f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f4:	89 d6                	mov    %edx,%esi
  8005f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800602:	8b 45 10             	mov    0x10(%ebp),%eax
  800605:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800608:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80060b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800615:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800618:	72 0c                	jb     800626 <printnum+0x3e>
  80061a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80061d:	76 07                	jbe    800626 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80061f:	4b                   	dec    %ebx
  800620:	85 db                	test   %ebx,%ebx
  800622:	7f 31                	jg     800655 <printnum+0x6d>
  800624:	eb 3f                	jmp    800665 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	57                   	push   %edi
  80062a:	4b                   	dec    %ebx
  80062b:	53                   	push   %ebx
  80062c:	50                   	push   %eax
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 d4             	pushl  -0x2c(%ebp)
  800633:	ff 75 d0             	pushl  -0x30(%ebp)
  800636:	ff 75 dc             	pushl  -0x24(%ebp)
  800639:	ff 75 d8             	pushl  -0x28(%ebp)
  80063c:	e8 83 24 00 00       	call   802ac4 <__udivdi3>
  800641:	83 c4 18             	add    $0x18,%esp
  800644:	52                   	push   %edx
  800645:	50                   	push   %eax
  800646:	89 f2                	mov    %esi,%edx
  800648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064b:	e8 98 ff ff ff       	call   8005e8 <printnum>
  800650:	83 c4 20             	add    $0x20,%esp
  800653:	eb 10                	jmp    800665 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	57                   	push   %edi
  80065a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80065d:	4b                   	dec    %ebx
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 db                	test   %ebx,%ebx
  800663:	7f f0                	jg     800655 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	56                   	push   %esi
  800669:	83 ec 04             	sub    $0x4,%esp
  80066c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066f:	ff 75 d0             	pushl  -0x30(%ebp)
  800672:	ff 75 dc             	pushl  -0x24(%ebp)
  800675:	ff 75 d8             	pushl  -0x28(%ebp)
  800678:	e8 63 25 00 00       	call   802be0 <__umoddi3>
  80067d:	83 c4 14             	add    $0x14,%esp
  800680:	0f be 80 8f 2e 80 00 	movsbl 0x802e8f(%eax),%eax
  800687:	50                   	push   %eax
  800688:	ff 55 e4             	call   *-0x1c(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
}
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	c9                   	leave  
  800695:	c3                   	ret    

00800696 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800699:	83 fa 01             	cmp    $0x1,%edx
  80069c:	7e 0e                	jle    8006ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a3:	89 08                	mov    %ecx,(%eax)
  8006a5:	8b 02                	mov    (%edx),%eax
  8006a7:	8b 52 04             	mov    0x4(%edx),%edx
  8006aa:	eb 22                	jmp    8006ce <getuint+0x38>
	else if (lflag)
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	74 10                	je     8006c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b5:	89 08                	mov    %ecx,(%eax)
  8006b7:	8b 02                	mov    (%edx),%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006be:	eb 0e                	jmp    8006ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c5:	89 08                	mov    %ecx,(%eax)
  8006c7:	8b 02                	mov    (%edx),%eax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d3:	83 fa 01             	cmp    $0x1,%edx
  8006d6:	7e 0e                	jle    8006e6 <getint+0x16>
		return va_arg(*ap, long long);
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006dd:	89 08                	mov    %ecx,(%eax)
  8006df:	8b 02                	mov    (%edx),%eax
  8006e1:	8b 52 04             	mov    0x4(%edx),%edx
  8006e4:	eb 1a                	jmp    800700 <getint+0x30>
	else if (lflag)
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	74 0c                	je     8006f6 <getint+0x26>
		return va_arg(*ap, long);
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ef:	89 08                	mov    %ecx,(%eax)
  8006f1:	8b 02                	mov    (%edx),%eax
  8006f3:	99                   	cltd   
  8006f4:	eb 0a                	jmp    800700 <getint+0x30>
	else
		return va_arg(*ap, int);
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006fb:	89 08                	mov    %ecx,(%eax)
  8006fd:	8b 02                	mov    (%edx),%eax
  8006ff:	99                   	cltd   
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800708:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	3b 50 04             	cmp    0x4(%eax),%edx
  800710:	73 08                	jae    80071a <sprintputch+0x18>
		*b->buf++ = ch;
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800715:	88 0a                	mov    %cl,(%edx)
  800717:	42                   	inc    %edx
  800718:	89 10                	mov    %edx,(%eax)
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800725:	50                   	push   %eax
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	ff 75 08             	pushl  0x8(%ebp)
  80072f:	e8 05 00 00 00       	call   800739 <vprintfmt>
	va_end(ap);
  800734:	83 c4 10             	add    $0x10,%esp
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	57                   	push   %edi
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	83 ec 2c             	sub    $0x2c,%esp
  800742:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800745:	8b 75 10             	mov    0x10(%ebp),%esi
  800748:	eb 13                	jmp    80075d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80074a:	85 c0                	test   %eax,%eax
  80074c:	0f 84 6d 03 00 00    	je     800abf <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	57                   	push   %edi
  800756:	50                   	push   %eax
  800757:	ff 55 08             	call   *0x8(%ebp)
  80075a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075d:	0f b6 06             	movzbl (%esi),%eax
  800760:	46                   	inc    %esi
  800761:	83 f8 25             	cmp    $0x25,%eax
  800764:	75 e4                	jne    80074a <vprintfmt+0x11>
  800766:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80076a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800771:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800778:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80077f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800784:	eb 28                	jmp    8007ae <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800788:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80078c:	eb 20                	jmp    8007ae <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800790:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800794:	eb 18                	jmp    8007ae <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800798:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80079f:	eb 0d                	jmp    8007ae <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8a 06                	mov    (%esi),%al
  8007b0:	0f b6 d0             	movzbl %al,%edx
  8007b3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8007b6:	83 e8 23             	sub    $0x23,%eax
  8007b9:	3c 55                	cmp    $0x55,%al
  8007bb:	0f 87 e0 02 00 00    	ja     800aa1 <vprintfmt+0x368>
  8007c1:	0f b6 c0             	movzbl %al,%eax
  8007c4:	ff 24 85 e0 2f 80 00 	jmp    *0x802fe0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007cb:	83 ea 30             	sub    $0x30,%edx
  8007ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8007d1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8007d4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007d7:	83 fa 09             	cmp    $0x9,%edx
  8007da:	77 44                	ja     800820 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dc:	89 de                	mov    %ebx,%esi
  8007de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8007e2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8007e5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8007e9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007ec:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8007ef:	83 fb 09             	cmp    $0x9,%ebx
  8007f2:	76 ed                	jbe    8007e1 <vprintfmt+0xa8>
  8007f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007f7:	eb 29                	jmp    800822 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800807:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800809:	eb 17                	jmp    800822 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80080b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080f:	78 85                	js     800796 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	89 de                	mov    %ebx,%esi
  800813:	eb 99                	jmp    8007ae <vprintfmt+0x75>
  800815:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800817:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80081e:	eb 8e                	jmp    8007ae <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800820:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800822:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800826:	79 86                	jns    8007ae <vprintfmt+0x75>
  800828:	e9 74 ff ff ff       	jmp    8007a1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80082d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082e:	89 de                	mov    %ebx,%esi
  800830:	e9 79 ff ff ff       	jmp    8007ae <vprintfmt+0x75>
  800835:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 50 04             	lea    0x4(%eax),%edx
  80083e:	89 55 14             	mov    %edx,0x14(%ebp)
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	57                   	push   %edi
  800845:	ff 30                	pushl  (%eax)
  800847:	ff 55 08             	call   *0x8(%ebp)
			break;
  80084a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800850:	e9 08 ff ff ff       	jmp    80075d <vprintfmt+0x24>
  800855:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	8b 00                	mov    (%eax),%eax
  800863:	85 c0                	test   %eax,%eax
  800865:	79 02                	jns    800869 <vprintfmt+0x130>
  800867:	f7 d8                	neg    %eax
  800869:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086b:	83 f8 0f             	cmp    $0xf,%eax
  80086e:	7f 0b                	jg     80087b <vprintfmt+0x142>
  800870:	8b 04 85 40 31 80 00 	mov    0x803140(,%eax,4),%eax
  800877:	85 c0                	test   %eax,%eax
  800879:	75 1a                	jne    800895 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80087b:	52                   	push   %edx
  80087c:	68 a7 2e 80 00       	push   $0x802ea7
  800881:	57                   	push   %edi
  800882:	ff 75 08             	pushl  0x8(%ebp)
  800885:	e8 92 fe ff ff       	call   80071c <printfmt>
  80088a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800890:	e9 c8 fe ff ff       	jmp    80075d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800895:	50                   	push   %eax
  800896:	68 f5 33 80 00       	push   $0x8033f5
  80089b:	57                   	push   %edi
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 78 fe ff ff       	call   80071c <printfmt>
  8008a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8008aa:	e9 ae fe ff ff       	jmp    80075d <vprintfmt+0x24>
  8008af:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8008b2:	89 de                	mov    %ebx,%esi
  8008b4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8d 50 04             	lea    0x4(%eax),%edx
  8008c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c3:	8b 00                	mov    (%eax),%eax
  8008c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	75 07                	jne    8008d3 <vprintfmt+0x19a>
				p = "(null)";
  8008cc:	c7 45 d0 a0 2e 80 00 	movl   $0x802ea0,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8008d3:	85 db                	test   %ebx,%ebx
  8008d5:	7e 42                	jle    800919 <vprintfmt+0x1e0>
  8008d7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008db:	74 3c                	je     800919 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	51                   	push   %ecx
  8008e1:	ff 75 d0             	pushl  -0x30(%ebp)
  8008e4:	e8 6f 02 00 00       	call   800b58 <strnlen>
  8008e9:	29 c3                	sub    %eax,%ebx
  8008eb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	85 db                	test   %ebx,%ebx
  8008f3:	7e 24                	jle    800919 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8008f5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8008f9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8008fc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	57                   	push   %edi
  800903:	53                   	push   %ebx
  800904:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800907:	4e                   	dec    %esi
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	85 f6                	test   %esi,%esi
  80090d:	7f f0                	jg     8008ff <vprintfmt+0x1c6>
  80090f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800912:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800919:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80091c:	0f be 02             	movsbl (%edx),%eax
  80091f:	85 c0                	test   %eax,%eax
  800921:	75 47                	jne    80096a <vprintfmt+0x231>
  800923:	eb 37                	jmp    80095c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800925:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800929:	74 16                	je     800941 <vprintfmt+0x208>
  80092b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80092e:	83 fa 5e             	cmp    $0x5e,%edx
  800931:	76 0e                	jbe    800941 <vprintfmt+0x208>
					putch('?', putdat);
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	57                   	push   %edi
  800937:	6a 3f                	push   $0x3f
  800939:	ff 55 08             	call   *0x8(%ebp)
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	eb 0b                	jmp    80094c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	57                   	push   %edi
  800945:	50                   	push   %eax
  800946:	ff 55 08             	call   *0x8(%ebp)
  800949:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094c:	ff 4d e4             	decl   -0x1c(%ebp)
  80094f:	0f be 03             	movsbl (%ebx),%eax
  800952:	85 c0                	test   %eax,%eax
  800954:	74 03                	je     800959 <vprintfmt+0x220>
  800956:	43                   	inc    %ebx
  800957:	eb 1b                	jmp    800974 <vprintfmt+0x23b>
  800959:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800960:	7f 1e                	jg     800980 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800965:	e9 f3 fd ff ff       	jmp    80075d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80096d:	43                   	inc    %ebx
  80096e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800971:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800974:	85 f6                	test   %esi,%esi
  800976:	78 ad                	js     800925 <vprintfmt+0x1ec>
  800978:	4e                   	dec    %esi
  800979:	79 aa                	jns    800925 <vprintfmt+0x1ec>
  80097b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80097e:	eb dc                	jmp    80095c <vprintfmt+0x223>
  800980:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800983:	83 ec 08             	sub    $0x8,%esp
  800986:	57                   	push   %edi
  800987:	6a 20                	push   $0x20
  800989:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80098c:	4b                   	dec    %ebx
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	85 db                	test   %ebx,%ebx
  800992:	7f ef                	jg     800983 <vprintfmt+0x24a>
  800994:	e9 c4 fd ff ff       	jmp    80075d <vprintfmt+0x24>
  800999:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80099c:	89 ca                	mov    %ecx,%edx
  80099e:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a1:	e8 2a fd ff ff       	call   8006d0 <getint>
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8009aa:	85 d2                	test   %edx,%edx
  8009ac:	78 0a                	js     8009b8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b3:	e9 b0 00 00 00       	jmp    800a68 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	57                   	push   %edi
  8009bc:	6a 2d                	push   $0x2d
  8009be:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009c1:	f7 db                	neg    %ebx
  8009c3:	83 d6 00             	adc    $0x0,%esi
  8009c6:	f7 de                	neg    %esi
  8009c8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d0:	e9 93 00 00 00       	jmp    800a68 <vprintfmt+0x32f>
  8009d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d8:	89 ca                	mov    %ecx,%edx
  8009da:	8d 45 14             	lea    0x14(%ebp),%eax
  8009dd:	e8 b4 fc ff ff       	call   800696 <getuint>
  8009e2:	89 c3                	mov    %eax,%ebx
  8009e4:	89 d6                	mov    %edx,%esi
			base = 10;
  8009e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009eb:	eb 7b                	jmp    800a68 <vprintfmt+0x32f>
  8009ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8009f0:	89 ca                	mov    %ecx,%edx
  8009f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f5:	e8 d6 fc ff ff       	call   8006d0 <getint>
  8009fa:	89 c3                	mov    %eax,%ebx
  8009fc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	78 07                	js     800a09 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800a02:	b8 08 00 00 00       	mov    $0x8,%eax
  800a07:	eb 5f                	jmp    800a68 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	57                   	push   %edi
  800a0d:	6a 2d                	push   $0x2d
  800a0f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800a12:	f7 db                	neg    %ebx
  800a14:	83 d6 00             	adc    $0x0,%esi
  800a17:	f7 de                	neg    %esi
  800a19:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800a1c:	b8 08 00 00 00       	mov    $0x8,%eax
  800a21:	eb 45                	jmp    800a68 <vprintfmt+0x32f>
  800a23:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800a26:	83 ec 08             	sub    $0x8,%esp
  800a29:	57                   	push   %edi
  800a2a:	6a 30                	push   $0x30
  800a2c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a2f:	83 c4 08             	add    $0x8,%esp
  800a32:	57                   	push   %edi
  800a33:	6a 78                	push   $0x78
  800a35:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a38:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3b:	8d 50 04             	lea    0x4(%eax),%edx
  800a3e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a41:	8b 18                	mov    (%eax),%ebx
  800a43:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a48:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a50:	eb 16                	jmp    800a68 <vprintfmt+0x32f>
  800a52:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a55:	89 ca                	mov    %ecx,%edx
  800a57:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5a:	e8 37 fc ff ff       	call   800696 <getuint>
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	89 d6                	mov    %edx,%esi
			base = 16;
  800a63:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800a6f:	52                   	push   %edx
  800a70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a73:	50                   	push   %eax
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	89 fa                	mov    %edi,%edx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	e8 68 fb ff ff       	call   8005e8 <printnum>
			break;
  800a80:	83 c4 20             	add    $0x20,%esp
  800a83:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a86:	e9 d2 fc ff ff       	jmp    80075d <vprintfmt+0x24>
  800a8b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a8e:	83 ec 08             	sub    $0x8,%esp
  800a91:	57                   	push   %edi
  800a92:	52                   	push   %edx
  800a93:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a99:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a9c:	e9 bc fc ff ff       	jmp    80075d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa1:	83 ec 08             	sub    $0x8,%esp
  800aa4:	57                   	push   %edi
  800aa5:	6a 25                	push   $0x25
  800aa7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aaa:	83 c4 10             	add    $0x10,%esp
  800aad:	eb 02                	jmp    800ab1 <vprintfmt+0x378>
  800aaf:	89 c6                	mov    %eax,%esi
  800ab1:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ab4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ab8:	75 f5                	jne    800aaf <vprintfmt+0x376>
  800aba:	e9 9e fc ff ff       	jmp    80075d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800abf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	83 ec 18             	sub    $0x18,%esp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ada:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ae4:	85 c0                	test   %eax,%eax
  800ae6:	74 26                	je     800b0e <vsnprintf+0x47>
  800ae8:	85 d2                	test   %edx,%edx
  800aea:	7e 29                	jle    800b15 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aec:	ff 75 14             	pushl  0x14(%ebp)
  800aef:	ff 75 10             	pushl  0x10(%ebp)
  800af2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af5:	50                   	push   %eax
  800af6:	68 02 07 80 00       	push   $0x800702
  800afb:	e8 39 fc ff ff       	call   800739 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b03:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	eb 0c                	jmp    800b1a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b13:	eb 05                	jmp    800b1a <vsnprintf+0x53>
  800b15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b25:	50                   	push   %eax
  800b26:	ff 75 10             	pushl  0x10(%ebp)
  800b29:	ff 75 0c             	pushl  0xc(%ebp)
  800b2c:	ff 75 08             	pushl  0x8(%ebp)
  800b2f:	e8 93 ff ff ff       	call   800ac7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    
	...

00800b38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b3e:	80 3a 00             	cmpb   $0x0,(%edx)
  800b41:	74 0e                	je     800b51 <strlen+0x19>
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b48:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b49:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b4d:	75 f9                	jne    800b48 <strlen+0x10>
  800b4f:	eb 05                	jmp    800b56 <strlen+0x1e>
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b61:	85 d2                	test   %edx,%edx
  800b63:	74 17                	je     800b7c <strnlen+0x24>
  800b65:	80 39 00             	cmpb   $0x0,(%ecx)
  800b68:	74 19                	je     800b83 <strnlen+0x2b>
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b6f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b70:	39 d0                	cmp    %edx,%eax
  800b72:	74 14                	je     800b88 <strnlen+0x30>
  800b74:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b78:	75 f5                	jne    800b6f <strnlen+0x17>
  800b7a:	eb 0c                	jmp    800b88 <strnlen+0x30>
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	eb 05                	jmp    800b88 <strnlen+0x30>
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	53                   	push   %ebx
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b9c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b9f:	42                   	inc    %edx
  800ba0:	84 c9                	test   %cl,%cl
  800ba2:	75 f5                	jne    800b99 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bae:	53                   	push   %ebx
  800baf:	e8 84 ff ff ff       	call   800b38 <strlen>
  800bb4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bb7:	ff 75 0c             	pushl  0xc(%ebp)
  800bba:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bbd:	50                   	push   %eax
  800bbe:	e8 c7 ff ff ff       	call   800b8a <strcpy>
	return dst;
}
  800bc3:	89 d8                	mov    %ebx,%eax
  800bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd8:	85 f6                	test   %esi,%esi
  800bda:	74 15                	je     800bf1 <strncpy+0x27>
  800bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800be1:	8a 1a                	mov    (%edx),%bl
  800be3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be6:	80 3a 01             	cmpb   $0x1,(%edx)
  800be9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bec:	41                   	inc    %ecx
  800bed:	39 ce                	cmp    %ecx,%esi
  800bef:	77 f0                	ja     800be1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c01:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c04:	85 f6                	test   %esi,%esi
  800c06:	74 32                	je     800c3a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800c08:	83 fe 01             	cmp    $0x1,%esi
  800c0b:	74 22                	je     800c2f <strlcpy+0x3a>
  800c0d:	8a 0b                	mov    (%ebx),%cl
  800c0f:	84 c9                	test   %cl,%cl
  800c11:	74 20                	je     800c33 <strlcpy+0x3e>
  800c13:	89 f8                	mov    %edi,%eax
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c1a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c1d:	88 08                	mov    %cl,(%eax)
  800c1f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c20:	39 f2                	cmp    %esi,%edx
  800c22:	74 11                	je     800c35 <strlcpy+0x40>
  800c24:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800c28:	42                   	inc    %edx
  800c29:	84 c9                	test   %cl,%cl
  800c2b:	75 f0                	jne    800c1d <strlcpy+0x28>
  800c2d:	eb 06                	jmp    800c35 <strlcpy+0x40>
  800c2f:	89 f8                	mov    %edi,%eax
  800c31:	eb 02                	jmp    800c35 <strlcpy+0x40>
  800c33:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c35:	c6 00 00             	movb   $0x0,(%eax)
  800c38:	eb 02                	jmp    800c3c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800c3c:	29 f8                	sub    %edi,%eax
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c49:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c4c:	8a 01                	mov    (%ecx),%al
  800c4e:	84 c0                	test   %al,%al
  800c50:	74 10                	je     800c62 <strcmp+0x1f>
  800c52:	3a 02                	cmp    (%edx),%al
  800c54:	75 0c                	jne    800c62 <strcmp+0x1f>
		p++, q++;
  800c56:	41                   	inc    %ecx
  800c57:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c58:	8a 01                	mov    (%ecx),%al
  800c5a:	84 c0                	test   %al,%al
  800c5c:	74 04                	je     800c62 <strcmp+0x1f>
  800c5e:	3a 02                	cmp    (%edx),%al
  800c60:	74 f4                	je     800c56 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c62:	0f b6 c0             	movzbl %al,%eax
  800c65:	0f b6 12             	movzbl (%edx),%edx
  800c68:	29 d0                	sub    %edx,%eax
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	53                   	push   %ebx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	74 1b                	je     800c98 <strncmp+0x2c>
  800c7d:	8a 1a                	mov    (%edx),%bl
  800c7f:	84 db                	test   %bl,%bl
  800c81:	74 24                	je     800ca7 <strncmp+0x3b>
  800c83:	3a 19                	cmp    (%ecx),%bl
  800c85:	75 20                	jne    800ca7 <strncmp+0x3b>
  800c87:	48                   	dec    %eax
  800c88:	74 15                	je     800c9f <strncmp+0x33>
		n--, p++, q++;
  800c8a:	42                   	inc    %edx
  800c8b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c8c:	8a 1a                	mov    (%edx),%bl
  800c8e:	84 db                	test   %bl,%bl
  800c90:	74 15                	je     800ca7 <strncmp+0x3b>
  800c92:	3a 19                	cmp    (%ecx),%bl
  800c94:	74 f1                	je     800c87 <strncmp+0x1b>
  800c96:	eb 0f                	jmp    800ca7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9d:	eb 05                	jmp    800ca4 <strncmp+0x38>
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca7:	0f b6 02             	movzbl (%edx),%eax
  800caa:	0f b6 11             	movzbl (%ecx),%edx
  800cad:	29 d0                	sub    %edx,%eax
  800caf:	eb f3                	jmp    800ca4 <strncmp+0x38>

00800cb1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cba:	8a 10                	mov    (%eax),%dl
  800cbc:	84 d2                	test   %dl,%dl
  800cbe:	74 18                	je     800cd8 <strchr+0x27>
		if (*s == c)
  800cc0:	38 ca                	cmp    %cl,%dl
  800cc2:	75 06                	jne    800cca <strchr+0x19>
  800cc4:	eb 17                	jmp    800cdd <strchr+0x2c>
  800cc6:	38 ca                	cmp    %cl,%dl
  800cc8:	74 13                	je     800cdd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cca:	40                   	inc    %eax
  800ccb:	8a 10                	mov    (%eax),%dl
  800ccd:	84 d2                	test   %dl,%dl
  800ccf:	75 f5                	jne    800cc6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	eb 05                	jmp    800cdd <strchr+0x2c>
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ce8:	8a 10                	mov    (%eax),%dl
  800cea:	84 d2                	test   %dl,%dl
  800cec:	74 11                	je     800cff <strfind+0x20>
		if (*s == c)
  800cee:	38 ca                	cmp    %cl,%dl
  800cf0:	75 06                	jne    800cf8 <strfind+0x19>
  800cf2:	eb 0b                	jmp    800cff <strfind+0x20>
  800cf4:	38 ca                	cmp    %cl,%dl
  800cf6:	74 07                	je     800cff <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cf8:	40                   	inc    %eax
  800cf9:	8a 10                	mov    (%eax),%dl
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	75 f5                	jne    800cf4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d10:	85 c9                	test   %ecx,%ecx
  800d12:	74 30                	je     800d44 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1a:	75 25                	jne    800d41 <memset+0x40>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 20                	jne    800d41 <memset+0x40>
		c &= 0xFF;
  800d21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d24:	89 d3                	mov    %edx,%ebx
  800d26:	c1 e3 08             	shl    $0x8,%ebx
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	c1 e6 18             	shl    $0x18,%esi
  800d2e:	89 d0                	mov    %edx,%eax
  800d30:	c1 e0 10             	shl    $0x10,%eax
  800d33:	09 f0                	or     %esi,%eax
  800d35:	09 d0                	or     %edx,%eax
  800d37:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d39:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d3c:	fc                   	cld    
  800d3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3f:	eb 03                	jmp    800d44 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d41:	fc                   	cld    
  800d42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d59:	39 c6                	cmp    %eax,%esi
  800d5b:	73 34                	jae    800d91 <memmove+0x46>
  800d5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d60:	39 d0                	cmp    %edx,%eax
  800d62:	73 2d                	jae    800d91 <memmove+0x46>
		s += n;
		d += n;
  800d64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d67:	f6 c2 03             	test   $0x3,%dl
  800d6a:	75 1b                	jne    800d87 <memmove+0x3c>
  800d6c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d72:	75 13                	jne    800d87 <memmove+0x3c>
  800d74:	f6 c1 03             	test   $0x3,%cl
  800d77:	75 0e                	jne    800d87 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d79:	83 ef 04             	sub    $0x4,%edi
  800d7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d82:	fd                   	std    
  800d83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d85:	eb 07                	jmp    800d8e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d87:	4f                   	dec    %edi
  800d88:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8b:	fd                   	std    
  800d8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8e:	fc                   	cld    
  800d8f:	eb 20                	jmp    800db1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d97:	75 13                	jne    800dac <memmove+0x61>
  800d99:	a8 03                	test   $0x3,%al
  800d9b:	75 0f                	jne    800dac <memmove+0x61>
  800d9d:	f6 c1 03             	test   $0x3,%cl
  800da0:	75 0a                	jne    800dac <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800da2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800da5:	89 c7                	mov    %eax,%edi
  800da7:	fc                   	cld    
  800da8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800daa:	eb 05                	jmp    800db1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dac:	89 c7                	mov    %eax,%edi
  800dae:	fc                   	cld    
  800daf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800db8:	ff 75 10             	pushl  0x10(%ebp)
  800dbb:	ff 75 0c             	pushl  0xc(%ebp)
  800dbe:	ff 75 08             	pushl  0x8(%ebp)
  800dc1:	e8 85 ff ff ff       	call   800d4b <memmove>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd7:	85 ff                	test   %edi,%edi
  800dd9:	74 32                	je     800e0d <memcmp+0x45>
		if (*s1 != *s2)
  800ddb:	8a 03                	mov    (%ebx),%al
  800ddd:	8a 0e                	mov    (%esi),%cl
  800ddf:	38 c8                	cmp    %cl,%al
  800de1:	74 19                	je     800dfc <memcmp+0x34>
  800de3:	eb 0d                	jmp    800df2 <memcmp+0x2a>
  800de5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800de9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800ded:	42                   	inc    %edx
  800dee:	38 c8                	cmp    %cl,%al
  800df0:	74 10                	je     800e02 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800df2:	0f b6 c0             	movzbl %al,%eax
  800df5:	0f b6 c9             	movzbl %cl,%ecx
  800df8:	29 c8                	sub    %ecx,%eax
  800dfa:	eb 16                	jmp    800e12 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dfc:	4f                   	dec    %edi
  800dfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800e02:	39 fa                	cmp    %edi,%edx
  800e04:	75 df                	jne    800de5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	eb 05                	jmp    800e12 <memcmp+0x4a>
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	c9                   	leave  
  800e16:	c3                   	ret    

00800e17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e1d:	89 c2                	mov    %eax,%edx
  800e1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e22:	39 d0                	cmp    %edx,%eax
  800e24:	73 12                	jae    800e38 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e26:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800e29:	38 08                	cmp    %cl,(%eax)
  800e2b:	75 06                	jne    800e33 <memfind+0x1c>
  800e2d:	eb 09                	jmp    800e38 <memfind+0x21>
  800e2f:	38 08                	cmp    %cl,(%eax)
  800e31:	74 05                	je     800e38 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e33:	40                   	inc    %eax
  800e34:	39 c2                	cmp    %eax,%edx
  800e36:	77 f7                	ja     800e2f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e46:	eb 01                	jmp    800e49 <strtol+0xf>
		s++;
  800e48:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e49:	8a 02                	mov    (%edx),%al
  800e4b:	3c 20                	cmp    $0x20,%al
  800e4d:	74 f9                	je     800e48 <strtol+0xe>
  800e4f:	3c 09                	cmp    $0x9,%al
  800e51:	74 f5                	je     800e48 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e53:	3c 2b                	cmp    $0x2b,%al
  800e55:	75 08                	jne    800e5f <strtol+0x25>
		s++;
  800e57:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e58:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5d:	eb 13                	jmp    800e72 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e5f:	3c 2d                	cmp    $0x2d,%al
  800e61:	75 0a                	jne    800e6d <strtol+0x33>
		s++, neg = 1;
  800e63:	8d 52 01             	lea    0x1(%edx),%edx
  800e66:	bf 01 00 00 00       	mov    $0x1,%edi
  800e6b:	eb 05                	jmp    800e72 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	74 05                	je     800e7b <strtol+0x41>
  800e76:	83 fb 10             	cmp    $0x10,%ebx
  800e79:	75 28                	jne    800ea3 <strtol+0x69>
  800e7b:	8a 02                	mov    (%edx),%al
  800e7d:	3c 30                	cmp    $0x30,%al
  800e7f:	75 10                	jne    800e91 <strtol+0x57>
  800e81:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e85:	75 0a                	jne    800e91 <strtol+0x57>
		s += 2, base = 16;
  800e87:	83 c2 02             	add    $0x2,%edx
  800e8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e8f:	eb 12                	jmp    800ea3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800e91:	85 db                	test   %ebx,%ebx
  800e93:	75 0e                	jne    800ea3 <strtol+0x69>
  800e95:	3c 30                	cmp    $0x30,%al
  800e97:	75 05                	jne    800e9e <strtol+0x64>
		s++, base = 8;
  800e99:	42                   	inc    %edx
  800e9a:	b3 08                	mov    $0x8,%bl
  800e9c:	eb 05                	jmp    800ea3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800e9e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eaa:	8a 0a                	mov    (%edx),%cl
  800eac:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800eaf:	80 fb 09             	cmp    $0x9,%bl
  800eb2:	77 08                	ja     800ebc <strtol+0x82>
			dig = *s - '0';
  800eb4:	0f be c9             	movsbl %cl,%ecx
  800eb7:	83 e9 30             	sub    $0x30,%ecx
  800eba:	eb 1e                	jmp    800eda <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ebc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ebf:	80 fb 19             	cmp    $0x19,%bl
  800ec2:	77 08                	ja     800ecc <strtol+0x92>
			dig = *s - 'a' + 10;
  800ec4:	0f be c9             	movsbl %cl,%ecx
  800ec7:	83 e9 57             	sub    $0x57,%ecx
  800eca:	eb 0e                	jmp    800eda <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ecc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ecf:	80 fb 19             	cmp    $0x19,%bl
  800ed2:	77 13                	ja     800ee7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ed4:	0f be c9             	movsbl %cl,%ecx
  800ed7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eda:	39 f1                	cmp    %esi,%ecx
  800edc:	7d 0d                	jge    800eeb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ede:	42                   	inc    %edx
  800edf:	0f af c6             	imul   %esi,%eax
  800ee2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ee5:	eb c3                	jmp    800eaa <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	eb 02                	jmp    800eed <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800eeb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800eed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef1:	74 05                	je     800ef8 <strtol+0xbe>
		*endptr = (char *) s;
  800ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ef6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ef8:	85 ff                	test   %edi,%edi
  800efa:	74 04                	je     800f00 <strtol+0xc6>
  800efc:	89 c8                	mov    %ecx,%eax
  800efe:	f7 d8                	neg    %eax
}
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    
  800f05:	00 00                	add    %al,(%eax)
	...

00800f08 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 1c             	sub    $0x1c,%esp
  800f11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f14:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800f17:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f19:	8b 75 14             	mov    0x14(%ebp),%esi
  800f1c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f25:	cd 30                	int    $0x30
  800f27:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f2d:	74 1c                	je     800f4b <syscall+0x43>
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	7e 18                	jle    800f4b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	50                   	push   %eax
  800f37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3a:	68 9f 31 80 00       	push   $0x80319f
  800f3f:	6a 42                	push   $0x42
  800f41:	68 bc 31 80 00       	push   $0x8031bc
  800f46:	e8 b1 f5 ff ff       	call   8004fc <_panic>

	return ret;
}
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f5b:	6a 00                	push   $0x0
  800f5d:	6a 00                	push   $0x0
  800f5f:	6a 00                	push   $0x0
  800f61:	ff 75 0c             	pushl  0xc(%ebp)
  800f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f67:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f71:	e8 92 ff ff ff       	call   800f08 <syscall>
  800f76:	83 c4 10             	add    $0x10,%esp
	return;
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f81:	6a 00                	push   $0x0
  800f83:	6a 00                	push   $0x0
  800f85:	6a 00                	push   $0x0
  800f87:	6a 00                	push   $0x0
  800f89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 01 00 00 00       	mov    $0x1,%eax
  800f98:	e8 6b ff ff ff       	call   800f08 <syscall>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa5:	6a 00                	push   $0x0
  800fa7:	6a 00                	push   $0x0
  800fa9:	6a 00                	push   $0x0
  800fab:	6a 00                	push   $0x0
  800fad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb5:	b8 03 00 00 00       	mov    $0x3,%eax
  800fba:	e8 49 ff ff ff       	call   800f08 <syscall>
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fc7:	6a 00                	push   $0x0
  800fc9:	6a 00                	push   $0x0
  800fcb:	6a 00                	push   $0x0
  800fcd:	6a 00                	push   $0x0
  800fcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd9:	b8 02 00 00 00       	mov    $0x2,%eax
  800fde:	e8 25 ff ff ff       	call   800f08 <syscall>
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <sys_yield>:

void
sys_yield(void)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800feb:	6a 00                	push   $0x0
  800fed:	6a 00                	push   $0x0
  800fef:	6a 00                	push   $0x0
  800ff1:	6a 00                	push   $0x0
  800ff3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffd:	b8 0b 00 00 00       	mov    $0xb,%eax
  801002:	e8 01 ff ff ff       	call   800f08 <syscall>
  801007:	83 c4 10             	add    $0x10,%esp
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801012:	6a 00                	push   $0x0
  801014:	6a 00                	push   $0x0
  801016:	ff 75 10             	pushl  0x10(%ebp)
  801019:	ff 75 0c             	pushl  0xc(%ebp)
  80101c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101f:	ba 01 00 00 00       	mov    $0x1,%edx
  801024:	b8 04 00 00 00       	mov    $0x4,%eax
  801029:	e8 da fe ff ff       	call   800f08 <syscall>
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801036:	ff 75 18             	pushl  0x18(%ebp)
  801039:	ff 75 14             	pushl  0x14(%ebp)
  80103c:	ff 75 10             	pushl  0x10(%ebp)
  80103f:	ff 75 0c             	pushl  0xc(%ebp)
  801042:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801045:	ba 01 00 00 00       	mov    $0x1,%edx
  80104a:	b8 05 00 00 00       	mov    $0x5,%eax
  80104f:	e8 b4 fe ff ff       	call   800f08 <syscall>
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80105c:	6a 00                	push   $0x0
  80105e:	6a 00                	push   $0x0
  801060:	6a 00                	push   $0x0
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801068:	ba 01 00 00 00       	mov    $0x1,%edx
  80106d:	b8 06 00 00 00       	mov    $0x6,%eax
  801072:	e8 91 fe ff ff       	call   800f08 <syscall>
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80107f:	6a 00                	push   $0x0
  801081:	6a 00                	push   $0x0
  801083:	6a 00                	push   $0x0
  801085:	ff 75 0c             	pushl  0xc(%ebp)
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	ba 01 00 00 00       	mov    $0x1,%edx
  801090:	b8 08 00 00 00       	mov    $0x8,%eax
  801095:	e8 6e fe ff ff       	call   800f08 <syscall>
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8010a2:	6a 00                	push   $0x0
  8010a4:	6a 00                	push   $0x0
  8010a6:	6a 00                	push   $0x0
  8010a8:	ff 75 0c             	pushl  0xc(%ebp)
  8010ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ae:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b8:	e8 4b fe ff ff       	call   800f08 <syscall>
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010c5:	6a 00                	push   $0x0
  8010c7:	6a 00                	push   $0x0
  8010c9:	6a 00                	push   $0x0
  8010cb:	ff 75 0c             	pushl  0xc(%ebp)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8010d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010db:	e8 28 fe ff ff       	call   800f08 <syscall>
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010e8:	6a 00                	push   $0x0
  8010ea:	ff 75 14             	pushl  0x14(%ebp)
  8010ed:	ff 75 10             	pushl  0x10(%ebp)
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801100:	e8 03 fe ff ff       	call   800f08 <syscall>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	6a 00                	push   $0x0
  801115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801118:	ba 01 00 00 00       	mov    $0x1,%edx
  80111d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801122:	e8 e1 fd ff ff       	call   800f08 <syscall>
}
  801127:	c9                   	leave  
  801128:	c3                   	ret    

00801129 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  80112f:	6a 00                	push   $0x0
  801131:	6a 00                	push   $0x0
  801133:	6a 00                	push   $0x0
  801135:	ff 75 0c             	pushl  0xc(%ebp)
  801138:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	b8 0e 00 00 00       	mov    $0xe,%eax
  801145:	e8 be fd ff ff       	call   800f08 <syscall>
}
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  801152:	6a 00                	push   $0x0
  801154:	ff 75 14             	pushl  0x14(%ebp)
  801157:	ff 75 10             	pushl  0x10(%ebp)
  80115a:	ff 75 0c             	pushl  0xc(%ebp)
  80115d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801160:	ba 00 00 00 00       	mov    $0x0,%edx
  801165:	b8 0f 00 00 00       	mov    $0xf,%eax
  80116a:	e8 99 fd ff ff       	call   800f08 <syscall>
} 
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  801177:	6a 00                	push   $0x0
  801179:	6a 00                	push   $0x0
  80117b:	6a 00                	push   $0x0
  80117d:	6a 00                	push   $0x0
  80117f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801182:	ba 00 00 00 00       	mov    $0x0,%edx
  801187:	b8 11 00 00 00       	mov    $0x11,%eax
  80118c:	e8 77 fd ff ff       	call   800f08 <syscall>
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <sys_getpid>:

envid_t
sys_getpid(void)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  801199:	6a 00                	push   $0x0
  80119b:	6a 00                	push   $0x0
  80119d:	6a 00                	push   $0x0
  80119f:	6a 00                	push   $0x0
  8011a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8011b0:	e8 53 fd ff ff       	call   800f08 <syscall>
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    
	...

008011b8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011c2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  8011c4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011c8:	75 14                	jne    8011de <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	68 cc 31 80 00       	push   $0x8031cc
  8011d2:	6a 20                	push   $0x20
  8011d4:	68 10 33 80 00       	push   $0x803310
  8011d9:	e8 1e f3 ff ff       	call   8004fc <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	c1 e8 16             	shr    $0x16,%eax
  8011e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ea:	a8 01                	test   $0x1,%al
  8011ec:	74 11                	je     8011ff <pgfault+0x47>
  8011ee:	89 d8                	mov    %ebx,%eax
  8011f0:	c1 e8 0c             	shr    $0xc,%eax
  8011f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011fa:	f6 c4 08             	test   $0x8,%ah
  8011fd:	75 14                	jne    801213 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	68 f0 31 80 00       	push   $0x8031f0
  801207:	6a 24                	push   $0x24
  801209:	68 10 33 80 00       	push   $0x803310
  80120e:	e8 e9 f2 ff ff       	call   8004fc <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	6a 07                	push   $0x7
  801218:	68 00 f0 7f 00       	push   $0x7ff000
  80121d:	6a 00                	push   $0x0
  80121f:	e8 e8 fd ff ff       	call   80100c <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 12                	jns    80123d <pgfault+0x85>
  80122b:	50                   	push   %eax
  80122c:	68 14 32 80 00       	push   $0x803214
  801231:	6a 32                	push   $0x32
  801233:	68 10 33 80 00       	push   $0x803310
  801238:	e8 bf f2 ff ff       	call   8004fc <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  80123d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	68 00 10 00 00       	push   $0x1000
  80124b:	53                   	push   %ebx
  80124c:	68 00 f0 7f 00       	push   $0x7ff000
  801251:	e8 5f fb ff ff       	call   800db5 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  801256:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80125d:	53                   	push   %ebx
  80125e:	6a 00                	push   $0x0
  801260:	68 00 f0 7f 00       	push   $0x7ff000
  801265:	6a 00                	push   $0x0
  801267:	e8 c4 fd ff ff       	call   801030 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  80126c:	83 c4 20             	add    $0x20,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	79 12                	jns    801285 <pgfault+0xcd>
  801273:	50                   	push   %eax
  801274:	68 38 32 80 00       	push   $0x803238
  801279:	6a 3a                	push   $0x3a
  80127b:	68 10 33 80 00       	push   $0x803310
  801280:	e8 77 f2 ff ff       	call   8004fc <_panic>

	return;
}
  801285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801293:	68 b8 11 80 00       	push   $0x8011b8
  801298:	e8 37 16 00 00       	call   8028d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80129d:	ba 07 00 00 00       	mov    $0x7,%edx
  8012a2:	89 d0                	mov    %edx,%eax
  8012a4:	cd 30                	int    $0x30
  8012a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a9:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	79 12                	jns    8012c4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  8012b2:	50                   	push   %eax
  8012b3:	68 1b 33 80 00       	push   $0x80331b
  8012b8:	6a 7f                	push   $0x7f
  8012ba:	68 10 33 80 00       	push   $0x803310
  8012bf:	e8 38 f2 ff ff       	call   8004fc <_panic>
	}
	int r;

	if (childpid == 0) {
  8012c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012c8:	75 20                	jne    8012ea <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  8012ca:	e8 f2 fc ff ff       	call   800fc1 <sys_getenvid>
  8012cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	c1 e2 07             	shl    $0x7,%edx
  8012d9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8012e0:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  8012e5:	e9 be 01 00 00       	jmp    8014a8 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  8012ef:	89 d8                	mov    %ebx,%eax
  8012f1:	c1 e8 16             	shr    $0x16,%eax
  8012f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fb:	a8 01                	test   $0x1,%al
  8012fd:	0f 84 10 01 00 00    	je     801413 <fork+0x189>
  801303:	89 d8                	mov    %ebx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	0f 84 fb 00 00 00    	je     801413 <fork+0x189>
  801318:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131f:	f6 c2 04             	test   $0x4,%dl
  801322:	0f 84 eb 00 00 00    	je     801413 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801328:	89 c6                	mov    %eax,%esi
  80132a:	c1 e6 0c             	shl    $0xc,%esi
  80132d:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801333:	0f 84 da 00 00 00    	je     801413 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801339:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801340:	f6 c6 04             	test   $0x4,%dh
  801343:	74 37                	je     80137c <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801345:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	25 07 0e 00 00       	and    $0xe07,%eax
  801354:	50                   	push   %eax
  801355:	56                   	push   %esi
  801356:	57                   	push   %edi
  801357:	56                   	push   %esi
  801358:	6a 00                	push   $0x0
  80135a:	e8 d1 fc ff ff       	call   801030 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80135f:	83 c4 20             	add    $0x20,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	0f 89 a9 00 00 00    	jns    801413 <fork+0x189>
  80136a:	50                   	push   %eax
  80136b:	68 5c 32 80 00       	push   $0x80325c
  801370:	6a 54                	push   $0x54
  801372:	68 10 33 80 00       	push   $0x803310
  801377:	e8 80 f1 ff ff       	call   8004fc <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80137c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801383:	f6 c2 02             	test   $0x2,%dl
  801386:	75 0c                	jne    801394 <fork+0x10a>
  801388:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138f:	f6 c4 08             	test   $0x8,%ah
  801392:	74 57                	je     8013eb <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	68 05 08 00 00       	push   $0x805
  80139c:	56                   	push   %esi
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	6a 00                	push   $0x0
  8013a1:	e8 8a fc ff ff       	call   801030 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8013a6:	83 c4 20             	add    $0x20,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	79 12                	jns    8013bf <fork+0x135>
  8013ad:	50                   	push   %eax
  8013ae:	68 5c 32 80 00       	push   $0x80325c
  8013b3:	6a 59                	push   $0x59
  8013b5:	68 10 33 80 00       	push   $0x803310
  8013ba:	e8 3d f1 ff ff       	call   8004fc <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	68 05 08 00 00       	push   $0x805
  8013c7:	56                   	push   %esi
  8013c8:	6a 00                	push   $0x0
  8013ca:	56                   	push   %esi
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 5e fc ff ff       	call   801030 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8013d2:	83 c4 20             	add    $0x20,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	79 3a                	jns    801413 <fork+0x189>
  8013d9:	50                   	push   %eax
  8013da:	68 5c 32 80 00       	push   $0x80325c
  8013df:	6a 5c                	push   $0x5c
  8013e1:	68 10 33 80 00       	push   $0x803310
  8013e6:	e8 11 f1 ff ff       	call   8004fc <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	6a 05                	push   $0x5
  8013f0:	56                   	push   %esi
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 36 fc ff ff       	call   801030 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8013fa:	83 c4 20             	add    $0x20,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	79 12                	jns    801413 <fork+0x189>
  801401:	50                   	push   %eax
  801402:	68 5c 32 80 00       	push   $0x80325c
  801407:	6a 60                	push   $0x60
  801409:	68 10 33 80 00       	push   $0x803310
  80140e:	e8 e9 f0 ff ff       	call   8004fc <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801413:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801419:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80141f:	0f 85 ca fe ff ff    	jne    8012ef <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	6a 07                	push   $0x7
  80142a:	68 00 f0 bf ee       	push   $0xeebff000
  80142f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801432:	e8 d5 fb ff ff       	call   80100c <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	79 15                	jns    801453 <fork+0x1c9>
  80143e:	50                   	push   %eax
  80143f:	68 80 32 80 00       	push   $0x803280
  801444:	68 94 00 00 00       	push   $0x94
  801449:	68 10 33 80 00       	push   $0x803310
  80144e:	e8 a9 f0 ff ff       	call   8004fc <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	68 40 29 80 00       	push   $0x802940
  80145b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145e:	e8 5c fc ff ff       	call   8010bf <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	79 15                	jns    80147f <fork+0x1f5>
  80146a:	50                   	push   %eax
  80146b:	68 b8 32 80 00       	push   $0x8032b8
  801470:	68 99 00 00 00       	push   $0x99
  801475:	68 10 33 80 00       	push   $0x803310
  80147a:	e8 7d f0 ff ff       	call   8004fc <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	6a 02                	push   $0x2
  801484:	ff 75 e4             	pushl  -0x1c(%ebp)
  801487:	e8 ed fb ff ff       	call   801079 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	79 15                	jns    8014a8 <fork+0x21e>
  801493:	50                   	push   %eax
  801494:	68 dc 32 80 00       	push   $0x8032dc
  801499:	68 a4 00 00 00       	push   $0xa4
  80149e:	68 10 33 80 00       	push   $0x803310
  8014a3:	e8 54 f0 ff ff       	call   8004fc <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8014a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <sfork>:

// Challenge!
int
sfork(void)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014b9:	68 38 33 80 00       	push   $0x803338
  8014be:	68 b1 00 00 00       	push   $0xb1
  8014c3:	68 10 33 80 00       	push   $0x803310
  8014c8:	e8 2f f0 ff ff       	call   8004fc <_panic>
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014db:	c1 e8 0c             	shr    $0xc,%eax
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014e3:	ff 75 08             	pushl  0x8(%ebp)
  8014e6:	e8 e5 ff ff ff       	call   8014d0 <fd2num>
  8014eb:	83 c4 04             	add    $0x4,%esp
  8014ee:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014f3:	c1 e0 0c             	shl    $0xc,%eax
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014ff:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801504:	a8 01                	test   $0x1,%al
  801506:	74 34                	je     80153c <fd_alloc+0x44>
  801508:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80150d:	a8 01                	test   $0x1,%al
  80150f:	74 32                	je     801543 <fd_alloc+0x4b>
  801511:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801516:	89 c1                	mov    %eax,%ecx
  801518:	89 c2                	mov    %eax,%edx
  80151a:	c1 ea 16             	shr    $0x16,%edx
  80151d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801524:	f6 c2 01             	test   $0x1,%dl
  801527:	74 1f                	je     801548 <fd_alloc+0x50>
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 0c             	shr    $0xc,%edx
  80152e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	75 17                	jne    801551 <fd_alloc+0x59>
  80153a:	eb 0c                	jmp    801548 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80153c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801541:	eb 05                	jmp    801548 <fd_alloc+0x50>
  801543:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801548:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80154a:	b8 00 00 00 00       	mov    $0x0,%eax
  80154f:	eb 17                	jmp    801568 <fd_alloc+0x70>
  801551:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801556:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80155b:	75 b9                	jne    801516 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80155d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801563:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801568:	5b                   	pop    %ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801571:	83 f8 1f             	cmp    $0x1f,%eax
  801574:	77 36                	ja     8015ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801576:	05 00 00 0d 00       	add    $0xd0000,%eax
  80157b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80157e:	89 c2                	mov    %eax,%edx
  801580:	c1 ea 16             	shr    $0x16,%edx
  801583:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80158a:	f6 c2 01             	test   $0x1,%dl
  80158d:	74 24                	je     8015b3 <fd_lookup+0x48>
  80158f:	89 c2                	mov    %eax,%edx
  801591:	c1 ea 0c             	shr    $0xc,%edx
  801594:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80159b:	f6 c2 01             	test   $0x1,%dl
  80159e:	74 1a                	je     8015ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8015a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015aa:	eb 13                	jmp    8015bf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b1:	eb 0c                	jmp    8015bf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb 05                	jmp    8015bf <fd_lookup+0x54>
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015ce:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  8015d4:	74 0d                	je     8015e3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015db:	eb 14                	jmp    8015f1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8015dd:	39 0a                	cmp    %ecx,(%edx)
  8015df:	75 10                	jne    8015f1 <dev_lookup+0x30>
  8015e1:	eb 05                	jmp    8015e8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e3:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8015e8:	89 13                	mov    %edx,(%ebx)
			return 0;
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ef:	eb 31                	jmp    801622 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015f1:	40                   	inc    %eax
  8015f2:	8b 14 85 cc 33 80 00 	mov    0x8033cc(,%eax,4),%edx
  8015f9:	85 d2                	test   %edx,%edx
  8015fb:	75 e0                	jne    8015dd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015fd:	a1 04 50 80 00       	mov    0x805004,%eax
  801602:	8b 40 48             	mov    0x48(%eax),%eax
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	51                   	push   %ecx
  801609:	50                   	push   %eax
  80160a:	68 50 33 80 00       	push   $0x803350
  80160f:	e8 c0 ef ff ff       	call   8005d4 <cprintf>
	*dev = 0;
  801614:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
  80162c:	83 ec 20             	sub    $0x20,%esp
  80162f:	8b 75 08             	mov    0x8(%ebp),%esi
  801632:	8a 45 0c             	mov    0xc(%ebp),%al
  801635:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801638:	56                   	push   %esi
  801639:	e8 92 fe ff ff       	call   8014d0 <fd2num>
  80163e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801641:	89 14 24             	mov    %edx,(%esp)
  801644:	50                   	push   %eax
  801645:	e8 21 ff ff ff       	call   80156b <fd_lookup>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 05                	js     801658 <fd_close+0x31>
	    || fd != fd2)
  801653:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801656:	74 0d                	je     801665 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801658:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80165c:	75 48                	jne    8016a6 <fd_close+0x7f>
  80165e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801663:	eb 41                	jmp    8016a6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	ff 36                	pushl  (%esi)
  80166e:	e8 4e ff ff ff       	call   8015c1 <dev_lookup>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 1c                	js     801698 <fd_close+0x71>
		if (dev->dev_close)
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	8b 40 10             	mov    0x10(%eax),%eax
  801682:	85 c0                	test   %eax,%eax
  801684:	74 0d                	je     801693 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	56                   	push   %esi
  80168a:	ff d0                	call   *%eax
  80168c:	89 c3                	mov    %eax,%ebx
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb 05                	jmp    801698 <fd_close+0x71>
		else
			r = 0;
  801693:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	56                   	push   %esi
  80169c:	6a 00                	push   $0x0
  80169e:	e8 b3 f9 ff ff       	call   801056 <sys_page_unmap>
	return r;
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 08             	pushl  0x8(%ebp)
  8016bc:	e8 aa fe ff ff       	call   80156b <fd_lookup>
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 10                	js     8016d8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	6a 01                	push   $0x1
  8016cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d0:	e8 52 ff ff ff       	call   801627 <fd_close>
  8016d5:	83 c4 10             	add    $0x10,%esp
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <close_all>:

void
close_all(void)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	e8 c0 ff ff ff       	call   8016af <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ef:	43                   	inc    %ebx
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	83 fb 20             	cmp    $0x20,%ebx
  8016f6:	75 ee                	jne    8016e6 <close_all+0xc>
		close(i);
}
  8016f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	57                   	push   %edi
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	83 ec 2c             	sub    $0x2c,%esp
  801706:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801709:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	ff 75 08             	pushl  0x8(%ebp)
  801710:	e8 56 fe ff ff       	call   80156b <fd_lookup>
  801715:	89 c3                	mov    %eax,%ebx
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	0f 88 c0 00 00 00    	js     8017e2 <dup+0xe5>
		return r;
	close(newfdnum);
  801722:	83 ec 0c             	sub    $0xc,%esp
  801725:	57                   	push   %edi
  801726:	e8 84 ff ff ff       	call   8016af <close>

	newfd = INDEX2FD(newfdnum);
  80172b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801731:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801734:	83 c4 04             	add    $0x4,%esp
  801737:	ff 75 e4             	pushl  -0x1c(%ebp)
  80173a:	e8 a1 fd ff ff       	call   8014e0 <fd2data>
  80173f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801741:	89 34 24             	mov    %esi,(%esp)
  801744:	e8 97 fd ff ff       	call   8014e0 <fd2data>
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	c1 e8 16             	shr    $0x16,%eax
  801754:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80175b:	a8 01                	test   $0x1,%al
  80175d:	74 37                	je     801796 <dup+0x99>
  80175f:	89 d8                	mov    %ebx,%eax
  801761:	c1 e8 0c             	shr    $0xc,%eax
  801764:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80176b:	f6 c2 01             	test   $0x1,%dl
  80176e:	74 26                	je     801796 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801770:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	25 07 0e 00 00       	and    $0xe07,%eax
  80177f:	50                   	push   %eax
  801780:	ff 75 d4             	pushl  -0x2c(%ebp)
  801783:	6a 00                	push   $0x0
  801785:	53                   	push   %ebx
  801786:	6a 00                	push   $0x0
  801788:	e8 a3 f8 ff ff       	call   801030 <sys_page_map>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	83 c4 20             	add    $0x20,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 2d                	js     8017c3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801796:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801799:	89 c2                	mov    %eax,%edx
  80179b:	c1 ea 0c             	shr    $0xc,%edx
  80179e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017ae:	52                   	push   %edx
  8017af:	56                   	push   %esi
  8017b0:	6a 00                	push   $0x0
  8017b2:	50                   	push   %eax
  8017b3:	6a 00                	push   $0x0
  8017b5:	e8 76 f8 ff ff       	call   801030 <sys_page_map>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	83 c4 20             	add    $0x20,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	79 1d                	jns    8017e0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	56                   	push   %esi
  8017c7:	6a 00                	push   $0x0
  8017c9:	e8 88 f8 ff ff       	call   801056 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ce:	83 c4 08             	add    $0x8,%esp
  8017d1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 7b f8 ff ff       	call   801056 <sys_page_unmap>
	return r;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	eb 02                	jmp    8017e2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017e0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5f                   	pop    %edi
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 14             	sub    $0x14,%esp
  8017f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f9:	50                   	push   %eax
  8017fa:	53                   	push   %ebx
  8017fb:	e8 6b fd ff ff       	call   80156b <fd_lookup>
  801800:	83 c4 08             	add    $0x8,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 67                	js     80186e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	50                   	push   %eax
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	ff 30                	pushl  (%eax)
  801813:	e8 a9 fd ff ff       	call   8015c1 <dev_lookup>
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 4f                	js     80186e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801822:	8b 50 08             	mov    0x8(%eax),%edx
  801825:	83 e2 03             	and    $0x3,%edx
  801828:	83 fa 01             	cmp    $0x1,%edx
  80182b:	75 21                	jne    80184e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80182d:	a1 04 50 80 00       	mov    0x805004,%eax
  801832:	8b 40 48             	mov    0x48(%eax),%eax
  801835:	83 ec 04             	sub    $0x4,%esp
  801838:	53                   	push   %ebx
  801839:	50                   	push   %eax
  80183a:	68 91 33 80 00       	push   $0x803391
  80183f:	e8 90 ed ff ff       	call   8005d4 <cprintf>
		return -E_INVAL;
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184c:	eb 20                	jmp    80186e <read+0x82>
	}
	if (!dev->dev_read)
  80184e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801851:	8b 52 08             	mov    0x8(%edx),%edx
  801854:	85 d2                	test   %edx,%edx
  801856:	74 11                	je     801869 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	ff 75 10             	pushl  0x10(%ebp)
  80185e:	ff 75 0c             	pushl  0xc(%ebp)
  801861:	50                   	push   %eax
  801862:	ff d2                	call   *%edx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	eb 05                	jmp    80186e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801869:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80187f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801882:	85 f6                	test   %esi,%esi
  801884:	74 31                	je     8018b7 <readn+0x44>
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	89 f2                	mov    %esi,%edx
  801895:	29 c2                	sub    %eax,%edx
  801897:	52                   	push   %edx
  801898:	03 45 0c             	add    0xc(%ebp),%eax
  80189b:	50                   	push   %eax
  80189c:	57                   	push   %edi
  80189d:	e8 4a ff ff ff       	call   8017ec <read>
		if (m < 0)
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 17                	js     8018c0 <readn+0x4d>
			return m;
		if (m == 0)
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	74 11                	je     8018be <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018ad:	01 c3                	add    %eax,%ebx
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	39 f3                	cmp    %esi,%ebx
  8018b3:	72 db                	jb     801890 <readn+0x1d>
  8018b5:	eb 09                	jmp    8018c0 <readn+0x4d>
  8018b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bc:	eb 02                	jmp    8018c0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018be:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5f                   	pop    %edi
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 14             	sub    $0x14,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	53                   	push   %ebx
  8018d7:	e8 8f fc ff ff       	call   80156b <fd_lookup>
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 62                	js     801945 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ed:	ff 30                	pushl  (%eax)
  8018ef:	e8 cd fc ff ff       	call   8015c1 <dev_lookup>
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	85 c0                	test   %eax,%eax
  8018f9:	78 4a                	js     801945 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801902:	75 21                	jne    801925 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801904:	a1 04 50 80 00       	mov    0x805004,%eax
  801909:	8b 40 48             	mov    0x48(%eax),%eax
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	53                   	push   %ebx
  801910:	50                   	push   %eax
  801911:	68 ad 33 80 00       	push   $0x8033ad
  801916:	e8 b9 ec ff ff       	call   8005d4 <cprintf>
		return -E_INVAL;
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801923:	eb 20                	jmp    801945 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801925:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801928:	8b 52 0c             	mov    0xc(%edx),%edx
  80192b:	85 d2                	test   %edx,%edx
  80192d:	74 11                	je     801940 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80192f:	83 ec 04             	sub    $0x4,%esp
  801932:	ff 75 10             	pushl  0x10(%ebp)
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	50                   	push   %eax
  801939:	ff d2                	call   *%edx
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 05                	jmp    801945 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801940:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801945:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <seek>:

int
seek(int fdnum, off_t offset)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801950:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	ff 75 08             	pushl  0x8(%ebp)
  801957:	e8 0f fc ff ff       	call   80156b <fd_lookup>
  80195c:	83 c4 08             	add    $0x8,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 0e                	js     801971 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801963:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801966:	8b 55 0c             	mov    0xc(%ebp),%edx
  801969:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	53                   	push   %ebx
  801977:	83 ec 14             	sub    $0x14,%esp
  80197a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801980:	50                   	push   %eax
  801981:	53                   	push   %ebx
  801982:	e8 e4 fb ff ff       	call   80156b <fd_lookup>
  801987:	83 c4 08             	add    $0x8,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 5f                	js     8019ed <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801998:	ff 30                	pushl  (%eax)
  80199a:	e8 22 fc ff ff       	call   8015c1 <dev_lookup>
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 47                	js     8019ed <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019ad:	75 21                	jne    8019d0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019af:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019b4:	8b 40 48             	mov    0x48(%eax),%eax
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	53                   	push   %ebx
  8019bb:	50                   	push   %eax
  8019bc:	68 70 33 80 00       	push   $0x803370
  8019c1:	e8 0e ec ff ff       	call   8005d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ce:	eb 1d                	jmp    8019ed <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8019d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d3:	8b 52 18             	mov    0x18(%edx),%edx
  8019d6:	85 d2                	test   %edx,%edx
  8019d8:	74 0e                	je     8019e8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	50                   	push   %eax
  8019e1:	ff d2                	call   *%edx
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	eb 05                	jmp    8019ed <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 14             	sub    $0x14,%esp
  8019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	ff 75 08             	pushl  0x8(%ebp)
  801a03:	e8 63 fb ff ff       	call   80156b <fd_lookup>
  801a08:	83 c4 08             	add    $0x8,%esp
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 52                	js     801a61 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a15:	50                   	push   %eax
  801a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a19:	ff 30                	pushl  (%eax)
  801a1b:	e8 a1 fb ff ff       	call   8015c1 <dev_lookup>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 3a                	js     801a61 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a2e:	74 2c                	je     801a5c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a30:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a33:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a3a:	00 00 00 
	stat->st_isdir = 0;
  801a3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a44:	00 00 00 
	stat->st_dev = dev;
  801a47:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	53                   	push   %ebx
  801a51:	ff 75 f0             	pushl  -0x10(%ebp)
  801a54:	ff 50 14             	call   *0x14(%eax)
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	eb 05                	jmp    801a61 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a5c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	6a 00                	push   $0x0
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 78 01 00 00       	call   801bf0 <open>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 1b                	js     801a9c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	ff 75 0c             	pushl  0xc(%ebp)
  801a87:	50                   	push   %eax
  801a88:	e8 65 ff ff ff       	call   8019f2 <fstat>
  801a8d:	89 c6                	mov    %eax,%esi
	close(fd);
  801a8f:	89 1c 24             	mov    %ebx,(%esp)
  801a92:	e8 18 fc ff ff       	call   8016af <close>
	return r;
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	89 f3                	mov    %esi,%ebx
}
  801a9c:	89 d8                	mov    %ebx,%eax
  801a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa1:	5b                   	pop    %ebx
  801aa2:	5e                   	pop    %esi
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    
  801aa5:	00 00                	add    %al,(%eax)
	...

00801aa8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ab1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ab8:	75 12                	jne    801acc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	6a 01                	push   $0x1
  801abf:	e8 6e 0f 00 00       	call   802a32 <ipc_find_env>
  801ac4:	a3 00 50 80 00       	mov    %eax,0x805000
  801ac9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801acc:	6a 07                	push   $0x7
  801ace:	68 00 60 80 00       	push   $0x806000
  801ad3:	53                   	push   %ebx
  801ad4:	ff 35 00 50 80 00    	pushl  0x805000
  801ada:	e8 fe 0e 00 00       	call   8029dd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801adf:	83 c4 0c             	add    $0xc,%esp
  801ae2:	6a 00                	push   $0x0
  801ae4:	56                   	push   %esi
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 7c 0e 00 00       	call   802968 <ipc_recv>
}
  801aec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	8b 40 0c             	mov    0xc(%eax),%eax
  801b03:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801b08:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b12:	e8 91 ff ff ff       	call   801aa8 <fsipc>
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 2c                	js     801b47 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	68 00 60 80 00       	push   $0x806000
  801b23:	53                   	push   %ebx
  801b24:	e8 61 f0 ff ff       	call   800b8a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b29:	a1 80 60 80 00       	mov    0x806080,%eax
  801b2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b34:	a1 84 60 80 00       	mov    0x806084,%eax
  801b39:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	8b 40 0c             	mov    0xc(%eax),%eax
  801b58:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b62:	b8 06 00 00 00       	mov    $0x6,%eax
  801b67:	e8 3c ff ff ff       	call   801aa8 <fsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b76:	8b 45 08             	mov    0x8(%ebp),%eax
  801b79:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b81:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b87:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b91:	e8 12 ff ff ff       	call   801aa8 <fsipc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 4b                	js     801be7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b9c:	39 c6                	cmp    %eax,%esi
  801b9e:	73 16                	jae    801bb6 <devfile_read+0x48>
  801ba0:	68 dc 33 80 00       	push   $0x8033dc
  801ba5:	68 e3 33 80 00       	push   $0x8033e3
  801baa:	6a 7d                	push   $0x7d
  801bac:	68 f8 33 80 00       	push   $0x8033f8
  801bb1:	e8 46 e9 ff ff       	call   8004fc <_panic>
	assert(r <= PGSIZE);
  801bb6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bbb:	7e 16                	jle    801bd3 <devfile_read+0x65>
  801bbd:	68 03 34 80 00       	push   $0x803403
  801bc2:	68 e3 33 80 00       	push   $0x8033e3
  801bc7:	6a 7e                	push   $0x7e
  801bc9:	68 f8 33 80 00       	push   $0x8033f8
  801bce:	e8 29 e9 ff ff       	call   8004fc <_panic>
	memmove(buf, &fsipcbuf, r);
  801bd3:	83 ec 04             	sub    $0x4,%esp
  801bd6:	50                   	push   %eax
  801bd7:	68 00 60 80 00       	push   $0x806000
  801bdc:	ff 75 0c             	pushl  0xc(%ebp)
  801bdf:	e8 67 f1 ff ff       	call   800d4b <memmove>
	return r;
  801be4:	83 c4 10             	add    $0x10,%esp
}
  801be7:	89 d8                	mov    %ebx,%eax
  801be9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 1c             	sub    $0x1c,%esp
  801bf8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bfb:	56                   	push   %esi
  801bfc:	e8 37 ef ff ff       	call   800b38 <strlen>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c09:	7f 65                	jg     801c70 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c11:	50                   	push   %eax
  801c12:	e8 e1 f8 ff ff       	call   8014f8 <fd_alloc>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 55                	js     801c75 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c20:	83 ec 08             	sub    $0x8,%esp
  801c23:	56                   	push   %esi
  801c24:	68 00 60 80 00       	push   $0x806000
  801c29:	e8 5c ef ff ff       	call   800b8a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c39:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3e:	e8 65 fe ff ff       	call   801aa8 <fsipc>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	79 12                	jns    801c5e <open+0x6e>
		fd_close(fd, 0);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	6a 00                	push   $0x0
  801c51:	ff 75 f4             	pushl  -0xc(%ebp)
  801c54:	e8 ce f9 ff ff       	call   801627 <fd_close>
		return r;
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	eb 17                	jmp    801c75 <open+0x85>
	}

	return fd2num(fd);
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	e8 67 f8 ff ff       	call   8014d0 <fd2num>
  801c69:	89 c3                	mov    %eax,%ebx
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	eb 05                	jmp    801c75 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c75:	89 d8                	mov    %ebx,%eax
  801c77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    
	...

00801c80 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	83 ec 1c             	sub    $0x1c,%esp
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c8e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c91:	89 d0                	mov    %edx,%eax
  801c93:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c98:	74 0c                	je     801ca6 <map_segment+0x26>
		va -= i;
  801c9a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  801c9d:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801ca0:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801ca3:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ca6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801caa:	0f 84 ee 00 00 00    	je     801d9e <map_segment+0x11e>
  801cb0:	be 00 00 00 00       	mov    $0x0,%esi
  801cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801cba:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801cbd:	77 20                	ja     801cdf <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cbf:	83 ec 04             	sub    $0x4,%esp
  801cc2:	ff 75 14             	pushl  0x14(%ebp)
  801cc5:	03 75 e4             	add    -0x1c(%ebp),%esi
  801cc8:	56                   	push   %esi
  801cc9:	57                   	push   %edi
  801cca:	e8 3d f3 ff ff       	call   80100c <sys_page_alloc>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 89 ac 00 00 00    	jns    801d86 <map_segment+0x106>
  801cda:	e9 c4 00 00 00       	jmp    801da3 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	6a 07                	push   $0x7
  801ce4:	68 00 00 40 00       	push   $0x400000
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 1c f3 ff ff       	call   80100c <sys_page_alloc>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 a8 00 00 00    	js     801da3 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cfb:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  801cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801d01:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d04:	50                   	push   %eax
  801d05:	ff 75 08             	pushl  0x8(%ebp)
  801d08:	e8 3d fc ff ff       	call   80194a <seek>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 8b 00 00 00    	js     801da3 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d18:	83 ec 04             	sub    $0x4,%esp
  801d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1e:	29 f0                	sub    %esi,%eax
  801d20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d25:	76 05                	jbe    801d2c <map_segment+0xac>
  801d27:	b8 00 10 00 00       	mov    $0x1000,%eax
  801d2c:	50                   	push   %eax
  801d2d:	68 00 00 40 00       	push   $0x400000
  801d32:	ff 75 08             	pushl  0x8(%ebp)
  801d35:	e8 39 fb ff ff       	call   801873 <readn>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 62                	js     801da3 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	ff 75 14             	pushl  0x14(%ebp)
  801d47:	03 75 e4             	add    -0x1c(%ebp),%esi
  801d4a:	56                   	push   %esi
  801d4b:	57                   	push   %edi
  801d4c:	68 00 00 40 00       	push   $0x400000
  801d51:	6a 00                	push   $0x0
  801d53:	e8 d8 f2 ff ff       	call   801030 <sys_page_map>
  801d58:	83 c4 20             	add    $0x20,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	79 15                	jns    801d74 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  801d5f:	50                   	push   %eax
  801d60:	68 0f 34 80 00       	push   $0x80340f
  801d65:	68 84 01 00 00       	push   $0x184
  801d6a:	68 2c 34 80 00       	push   $0x80342c
  801d6f:	e8 88 e7 ff ff       	call   8004fc <_panic>
			sys_page_unmap(0, UTEMP);
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	68 00 00 40 00       	push   $0x400000
  801d7c:	6a 00                	push   $0x0
  801d7e:	e8 d3 f2 ff ff       	call   801056 <sys_page_unmap>
  801d83:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d86:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d8c:	89 de                	mov    %ebx,%esi
  801d8e:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801d91:	0f 87 23 ff ff ff    	ja     801cba <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9c:	eb 05                	jmp    801da3 <map_segment+0x123>
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da6:	5b                   	pop    %ebx
  801da7:	5e                   	pop    %esi
  801da8:	5f                   	pop    %edi
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 2c             	sub    $0x2c,%esp
  801db4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801db7:	89 d7                	mov    %edx,%edi
  801db9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801dbc:	8b 02                	mov    (%edx),%eax
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	74 31                	je     801df3 <init_stack+0x48>
  801dc2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801dc7:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801dcc:	83 ec 0c             	sub    $0xc,%esp
  801dcf:	50                   	push   %eax
  801dd0:	e8 63 ed ff ff       	call   800b38 <strlen>
  801dd5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801dd9:	43                   	inc    %ebx
  801dda:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801de1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	85 c0                	test   %eax,%eax
  801de9:	75 e1                	jne    801dcc <init_stack+0x21>
  801deb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801dee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801df1:	eb 18                	jmp    801e0b <init_stack+0x60>
  801df3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801dfa:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801e01:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801e06:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e0b:	f7 de                	neg    %esi
  801e0d:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801e13:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e16:	89 f2                	mov    %esi,%edx
  801e18:	83 e2 fc             	and    $0xfffffffc,%edx
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	f7 d0                	not    %eax
  801e1f:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e25:	83 e8 08             	sub    $0x8,%eax
  801e28:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e2d:	0f 86 fb 00 00 00    	jbe    801f2e <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	6a 07                	push   $0x7
  801e38:	68 00 00 40 00       	push   $0x400000
  801e3d:	6a 00                	push   $0x0
  801e3f:	e8 c8 f1 ff ff       	call   80100c <sys_page_alloc>
  801e44:	89 c6                	mov    %eax,%esi
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	0f 88 e9 00 00 00    	js     801f3a <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e51:	85 db                	test   %ebx,%ebx
  801e53:	7e 3e                	jle    801e93 <init_stack+0xe8>
  801e55:	be 00 00 00 00       	mov    $0x0,%esi
  801e5a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801e5d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801e60:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e69:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e6c:	83 ec 08             	sub    $0x8,%esp
  801e6f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801e72:	53                   	push   %ebx
  801e73:	e8 12 ed ff ff       	call   800b8a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e78:	83 c4 04             	add    $0x4,%esp
  801e7b:	ff 34 b7             	pushl  (%edi,%esi,4)
  801e7e:	e8 b5 ec ff ff       	call   800b38 <strlen>
  801e83:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e87:	46                   	inc    %esi
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801e8e:	7c d0                	jl     801e60 <init_stack+0xb5>
  801e90:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e96:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e99:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ea0:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801ea7:	74 19                	je     801ec2 <init_stack+0x117>
  801ea9:	68 9c 34 80 00       	push   $0x80349c
  801eae:	68 e3 33 80 00       	push   $0x8033e3
  801eb3:	68 51 01 00 00       	push   $0x151
  801eb8:	68 2c 34 80 00       	push   $0x80342c
  801ebd:	e8 3a e6 ff ff       	call   8004fc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec5:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801eca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ecd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801ed0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ed3:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ed6:	89 d0                	mov    %edx,%eax
  801ed8:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801edd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801ee0:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801ee2:	83 ec 0c             	sub    $0xc,%esp
  801ee5:	6a 07                	push   $0x7
  801ee7:	ff 75 08             	pushl  0x8(%ebp)
  801eea:	ff 75 d8             	pushl  -0x28(%ebp)
  801eed:	68 00 00 40 00       	push   $0x400000
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 37 f1 ff ff       	call   801030 <sys_page_map>
  801ef9:	89 c6                	mov    %eax,%esi
  801efb:	83 c4 20             	add    $0x20,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 18                	js     801f1a <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801f02:	83 ec 08             	sub    $0x8,%esp
  801f05:	68 00 00 40 00       	push   $0x400000
  801f0a:	6a 00                	push   $0x0
  801f0c:	e8 45 f1 ff ff       	call   801056 <sys_page_unmap>
  801f11:	89 c6                	mov    %eax,%esi
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	85 c0                	test   %eax,%eax
  801f18:	79 1b                	jns    801f35 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	68 00 00 40 00       	push   $0x400000
  801f22:	6a 00                	push   $0x0
  801f24:	e8 2d f1 ff ff       	call   801056 <sys_page_unmap>
	return r;
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	eb 0c                	jmp    801f3a <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f2e:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801f33:	eb 05                	jmp    801f3a <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801f35:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801f3a:	89 f0                	mov    %esi,%eax
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	57                   	push   %edi
  801f48:	56                   	push   %esi
  801f49:	53                   	push   %ebx
  801f4a:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f50:	6a 00                	push   $0x0
  801f52:	ff 75 08             	pushl  0x8(%ebp)
  801f55:	e8 96 fc ff ff       	call   801bf0 <open>
  801f5a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	0f 88 3f 02 00 00    	js     8021aa <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f6b:	83 ec 04             	sub    $0x4,%esp
  801f6e:	68 00 02 00 00       	push   $0x200
  801f73:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f79:	50                   	push   %eax
  801f7a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f80:	e8 ee f8 ff ff       	call   801873 <readn>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f8d:	75 0c                	jne    801f9b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801f8f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f96:	45 4c 46 
  801f99:	74 38                	je     801fd3 <spawn+0x8f>
		close(fd);
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801fa4:	e8 06 f7 ff ff       	call   8016af <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801fa9:	83 c4 0c             	add    $0xc,%esp
  801fac:	68 7f 45 4c 46       	push   $0x464c457f
  801fb1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801fb7:	68 38 34 80 00       	push   $0x803438
  801fbc:	e8 13 e6 ff ff       	call   8005d4 <cprintf>
		return -E_NOT_EXEC;
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801fcb:	ff ff ff 
  801fce:	e9 eb 01 00 00       	jmp    8021be <spawn+0x27a>
  801fd3:	ba 07 00 00 00       	mov    $0x7,%edx
  801fd8:	89 d0                	mov    %edx,%eax
  801fda:	cd 30                	int    $0x30
  801fdc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801fe2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	0f 88 ce 01 00 00    	js     8021be <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ff0:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ff5:	89 c2                	mov    %eax,%edx
  801ff7:	c1 e2 07             	shl    $0x7,%edx
  801ffa:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  802001:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802007:	b9 11 00 00 00       	mov    $0x11,%ecx
  80200c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80200e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802014:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  802023:	68 00 d0 bf ee       	push   $0xeebfd000
  802028:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202b:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802031:	e8 75 fd ff ff       	call   801dab <init_stack>
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	85 c0                	test   %eax,%eax
  80203b:	0f 88 77 01 00 00    	js     8021b8 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802041:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802047:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  80204e:	00 
  80204f:	74 5d                	je     8020ae <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802051:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802058:	be 00 00 00 00       	mov    $0x0,%esi
  80205d:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  802063:	83 3b 01             	cmpl   $0x1,(%ebx)
  802066:	75 35                	jne    80209d <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802068:	8b 43 18             	mov    0x18(%ebx),%eax
  80206b:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80206e:	83 f8 01             	cmp    $0x1,%eax
  802071:	19 c0                	sbb    %eax,%eax
  802073:	83 e0 fe             	and    $0xfffffffe,%eax
  802076:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802079:	8b 4b 14             	mov    0x14(%ebx),%ecx
  80207c:	8b 53 08             	mov    0x8(%ebx),%edx
  80207f:	50                   	push   %eax
  802080:	ff 73 04             	pushl  0x4(%ebx)
  802083:	ff 73 10             	pushl  0x10(%ebx)
  802086:	57                   	push   %edi
  802087:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80208d:	e8 ee fb ff ff       	call   801c80 <map_segment>
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	0f 88 e4 00 00 00    	js     802181 <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80209d:	46                   	inc    %esi
  80209e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020a5:	39 f0                	cmp    %esi,%eax
  8020a7:	7e 05                	jle    8020ae <spawn+0x16a>
  8020a9:	83 c3 20             	add    $0x20,%ebx
  8020ac:	eb b5                	jmp    802063 <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8020b7:	e8 f3 f5 ff ff       	call   8016af <close>
  8020bc:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8020bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c4:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  8020ca:	89 d8                	mov    %ebx,%eax
  8020cc:	c1 e8 16             	shr    $0x16,%eax
  8020cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020d6:	a8 01                	test   $0x1,%al
  8020d8:	74 3e                	je     802118 <spawn+0x1d4>
  8020da:	89 d8                	mov    %ebx,%eax
  8020dc:	c1 e8 0c             	shr    $0xc,%eax
  8020df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020e6:	f6 c2 01             	test   $0x1,%dl
  8020e9:	74 2d                	je     802118 <spawn+0x1d4>
  8020eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020f2:	f6 c6 04             	test   $0x4,%dh
  8020f5:	74 21                	je     802118 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  8020f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	25 07 0e 00 00       	and    $0xe07,%eax
  802106:	50                   	push   %eax
  802107:	53                   	push   %ebx
  802108:	56                   	push   %esi
  802109:	53                   	push   %ebx
  80210a:	6a 00                	push   $0x0
  80210c:	e8 1f ef ff ff       	call   801030 <sys_page_map>
        if (r < 0) return r;
  802111:	83 c4 20             	add    $0x20,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	78 13                	js     80212b <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802118:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80211e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802124:	75 a4                	jne    8020ca <spawn+0x186>
  802126:	e9 a1 00 00 00       	jmp    8021cc <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  80212b:	50                   	push   %eax
  80212c:	68 52 34 80 00       	push   $0x803452
  802131:	68 85 00 00 00       	push   $0x85
  802136:	68 2c 34 80 00       	push   $0x80342c
  80213b:	e8 bc e3 ff ff       	call   8004fc <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  802140:	50                   	push   %eax
  802141:	68 68 34 80 00       	push   $0x803468
  802146:	68 88 00 00 00       	push   $0x88
  80214b:	68 2c 34 80 00       	push   $0x80342c
  802150:	e8 a7 e3 ff ff       	call   8004fc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802155:	83 ec 08             	sub    $0x8,%esp
  802158:	6a 02                	push   $0x2
  80215a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802160:	e8 14 ef ff ff       	call   801079 <sys_env_set_status>
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	79 52                	jns    8021be <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  80216c:	50                   	push   %eax
  80216d:	68 82 34 80 00       	push   $0x803482
  802172:	68 8b 00 00 00       	push   $0x8b
  802177:	68 2c 34 80 00       	push   $0x80342c
  80217c:	e8 7b e3 ff ff       	call   8004fc <_panic>
  802181:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80218c:	e8 0e ee ff ff       	call   800f9f <sys_env_destroy>
	close(fd);
  802191:	83 c4 04             	add    $0x4,%esp
  802194:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80219a:	e8 10 f5 ff ff       	call   8016af <close>
	return r;
  80219f:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8021a2:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8021a8:	eb 14                	jmp    8021be <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8021aa:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8021b0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8021b6:	eb 06                	jmp    8021be <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  8021b8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021be:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8021c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021dc:	e8 bb ee ff ff       	call   80109c <sys_env_set_trapframe>
  8021e1:	83 c4 10             	add    $0x10,%esp
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	0f 89 69 ff ff ff    	jns    802155 <spawn+0x211>
  8021ec:	e9 4f ff ff ff       	jmp    802140 <spawn+0x1fc>

008021f1 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	57                   	push   %edi
  8021f5:	56                   	push   %esi
  8021f6:	53                   	push   %ebx
  8021f7:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  8021fd:	6a 00                	push   $0x0
  8021ff:	ff 75 08             	pushl  0x8(%ebp)
  802202:	e8 e9 f9 ff ff       	call   801bf0 <open>
  802207:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  80220d:	83 c4 10             	add    $0x10,%esp
  802210:	85 c0                	test   %eax,%eax
  802212:	0f 88 a9 01 00 00    	js     8023c1 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  802218:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80221e:	83 ec 04             	sub    $0x4,%esp
  802221:	68 00 02 00 00       	push   $0x200
  802226:	57                   	push   %edi
  802227:	50                   	push   %eax
  802228:	e8 46 f6 ff ff       	call   801873 <readn>
  80222d:	83 c4 10             	add    $0x10,%esp
  802230:	3d 00 02 00 00       	cmp    $0x200,%eax
  802235:	75 0c                	jne    802243 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  802237:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80223e:	45 4c 46 
  802241:	74 34                	je     802277 <exec+0x86>
		close(fd);
  802243:	83 ec 0c             	sub    $0xc,%esp
  802246:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  80224c:	e8 5e f4 ff ff       	call   8016af <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802251:	83 c4 0c             	add    $0xc,%esp
  802254:	68 7f 45 4c 46       	push   $0x464c457f
  802259:	ff 37                	pushl  (%edi)
  80225b:	68 38 34 80 00       	push   $0x803438
  802260:	e8 6f e3 ff ff       	call   8005d4 <cprintf>
		return -E_NOT_EXEC;
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  80226f:	ff ff ff 
  802272:	e9 4a 01 00 00       	jmp    8023c1 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802277:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80227a:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  80227f:	0f 84 8b 00 00 00    	je     802310 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802285:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  80228c:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  802293:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802296:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  80229b:	83 3b 01             	cmpl   $0x1,(%ebx)
  80229e:	75 62                	jne    802302 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8022a0:	8b 43 18             	mov    0x18(%ebx),%eax
  8022a3:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8022a6:	83 f8 01             	cmp    $0x1,%eax
  8022a9:	19 c0                	sbb    %eax,%eax
  8022ab:	83 e0 fe             	and    $0xfffffffe,%eax
  8022ae:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  8022b1:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8022b4:	8b 53 08             	mov    0x8(%ebx),%edx
  8022b7:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8022bd:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  8022c3:	50                   	push   %eax
  8022c4:	ff 73 04             	pushl  0x4(%ebx)
  8022c7:	ff 73 10             	pushl  0x10(%ebx)
  8022ca:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  8022d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d5:	e8 a6 f9 ff ff       	call   801c80 <map_segment>
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	0f 88 a3 00 00 00    	js     802388 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  8022e5:	8b 53 14             	mov    0x14(%ebx),%edx
  8022e8:	8b 43 08             	mov    0x8(%ebx),%eax
  8022eb:	25 ff 0f 00 00       	and    $0xfff,%eax
  8022f0:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  8022f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8022fc:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802302:	46                   	inc    %esi
  802303:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  802307:	39 f0                	cmp    %esi,%eax
  802309:	7e 0f                	jle    80231a <exec+0x129>
  80230b:	83 c3 20             	add    $0x20,%ebx
  80230e:	eb 8b                	jmp    80229b <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  802310:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  802317:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  80231a:	83 ec 0c             	sub    $0xc,%esp
  80231d:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802323:	e8 87 f3 ff ff       	call   8016af <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802328:	83 c4 04             	add    $0x4,%esp
  80232b:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  802331:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  802337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233a:	b8 00 00 00 00       	mov    $0x0,%eax
  80233f:	e8 67 fa ff ff       	call   801dab <init_stack>
  802344:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	85 c0                	test   %eax,%eax
  80234f:	78 70                	js     8023c1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  802351:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  802355:	50                   	push   %eax
  802356:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80235c:	03 47 1c             	add    0x1c(%edi),%eax
  80235f:	50                   	push   %eax
  802360:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  802366:	ff 77 18             	pushl  0x18(%edi)
  802369:	e8 de ed ff ff       	call   80114c <sys_exec>
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	85 c0                	test   %eax,%eax
  802373:	79 42                	jns    8023b7 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802375:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  80237b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  802381:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  802386:	eb 0c                	jmp    802394 <exec+0x1a3>
  802388:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  80238e:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  802394:	83 ec 0c             	sub    $0xc,%esp
  802397:	6a 00                	push   $0x0
  802399:	e8 01 ec ff ff       	call   800f9f <sys_env_destroy>
	close(fd);
  80239e:	89 1c 24             	mov    %ebx,(%esp)
  8023a1:	e8 09 f3 ff ff       	call   8016af <close>
	return r;
  8023a6:	83 c4 10             	add    $0x10,%esp
  8023a9:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  8023af:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  8023b5:	eb 0a                	jmp    8023c1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  8023b7:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  8023be:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  8023c1:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  8023c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ca:	5b                   	pop    %ebx
  8023cb:	5e                   	pop    %esi
  8023cc:	5f                   	pop    %edi
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    

008023cf <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
  8023d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8023da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023de:	74 5f                	je     80243f <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8023e0:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8023e5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023e6:	89 c2                	mov    %eax,%edx
  8023e8:	83 c0 04             	add    $0x4,%eax
  8023eb:	83 3a 00             	cmpl   $0x0,(%edx)
  8023ee:	75 f5                	jne    8023e5 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023f0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8023f7:	83 e0 f0             	and    $0xfffffff0,%eax
  8023fa:	29 c4                	sub    %eax,%esp
  8023fc:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802400:	83 e0 f0             	and    $0xfffffff0,%eax
  802403:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802405:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802407:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  80240e:	00 

	va_start(vl, arg0);
  80240f:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802412:	89 ce                	mov    %ecx,%esi
  802414:	85 c9                	test   %ecx,%ecx
  802416:	74 14                	je     80242c <execl+0x5d>
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80241d:	40                   	inc    %eax
  80241e:	89 d1                	mov    %edx,%ecx
  802420:	83 c2 04             	add    $0x4,%edx
  802423:	8b 09                	mov    (%ecx),%ecx
  802425:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802428:	39 f0                	cmp    %esi,%eax
  80242a:	72 f1                	jb     80241d <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  80242c:	83 ec 08             	sub    $0x8,%esp
  80242f:	53                   	push   %ebx
  802430:	ff 75 08             	pushl  0x8(%ebp)
  802433:	e8 b9 fd ff ff       	call   8021f1 <exec>
}
  802438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	c9                   	leave  
  80243e:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80243f:	83 ec 20             	sub    $0x20,%esp
  802442:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802446:	83 e0 f0             	and    $0xfffffff0,%eax
  802449:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80244b:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80244d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802454:	eb d6                	jmp    80242c <execl+0x5d>

00802456 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	56                   	push   %esi
  80245a:	53                   	push   %ebx
  80245b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80245e:	8d 45 14             	lea    0x14(%ebp),%eax
  802461:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802465:	74 5f                	je     8024c6 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802467:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80246c:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80246d:	89 c2                	mov    %eax,%edx
  80246f:	83 c0 04             	add    $0x4,%eax
  802472:	83 3a 00             	cmpl   $0x0,(%edx)
  802475:	75 f5                	jne    80246c <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802477:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80247e:	83 e0 f0             	and    $0xfffffff0,%eax
  802481:	29 c4                	sub    %eax,%esp
  802483:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802487:	83 e0 f0             	and    $0xfffffff0,%eax
  80248a:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80248c:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80248e:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802495:	00 

	va_start(vl, arg0);
  802496:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802499:	89 ce                	mov    %ecx,%esi
  80249b:	85 c9                	test   %ecx,%ecx
  80249d:	74 14                	je     8024b3 <spawnl+0x5d>
  80249f:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8024a4:	40                   	inc    %eax
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	83 c2 04             	add    $0x4,%edx
  8024aa:	8b 09                	mov    (%ecx),%ecx
  8024ac:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8024af:	39 f0                	cmp    %esi,%eax
  8024b1:	72 f1                	jb     8024a4 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8024b3:	83 ec 08             	sub    $0x8,%esp
  8024b6:	53                   	push   %ebx
  8024b7:	ff 75 08             	pushl  0x8(%ebp)
  8024ba:	e8 85 fa ff ff       	call   801f44 <spawn>
}
  8024bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024c2:	5b                   	pop    %ebx
  8024c3:	5e                   	pop    %esi
  8024c4:	c9                   	leave  
  8024c5:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8024c6:	83 ec 20             	sub    $0x20,%esp
  8024c9:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8024cd:	83 e0 f0             	and    $0xfffffff0,%eax
  8024d0:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8024d2:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8024d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8024db:	eb d6                	jmp    8024b3 <spawnl+0x5d>
  8024dd:	00 00                	add    %al,(%eax)
	...

008024e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	56                   	push   %esi
  8024e4:	53                   	push   %ebx
  8024e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024e8:	83 ec 0c             	sub    $0xc,%esp
  8024eb:	ff 75 08             	pushl  0x8(%ebp)
  8024ee:	e8 ed ef ff ff       	call   8014e0 <fd2data>
  8024f3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8024f5:	83 c4 08             	add    $0x8,%esp
  8024f8:	68 c2 34 80 00       	push   $0x8034c2
  8024fd:	56                   	push   %esi
  8024fe:	e8 87 e6 ff ff       	call   800b8a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802503:	8b 43 04             	mov    0x4(%ebx),%eax
  802506:	2b 03                	sub    (%ebx),%eax
  802508:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80250e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802515:	00 00 00 
	stat->st_dev = &devpipe;
  802518:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  80251f:	40 80 00 
	return 0;
}
  802522:	b8 00 00 00 00       	mov    $0x0,%eax
  802527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80252a:	5b                   	pop    %ebx
  80252b:	5e                   	pop    %esi
  80252c:	c9                   	leave  
  80252d:	c3                   	ret    

0080252e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	53                   	push   %ebx
  802532:	83 ec 0c             	sub    $0xc,%esp
  802535:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802538:	53                   	push   %ebx
  802539:	6a 00                	push   $0x0
  80253b:	e8 16 eb ff ff       	call   801056 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802540:	89 1c 24             	mov    %ebx,(%esp)
  802543:	e8 98 ef ff ff       	call   8014e0 <fd2data>
  802548:	83 c4 08             	add    $0x8,%esp
  80254b:	50                   	push   %eax
  80254c:	6a 00                	push   $0x0
  80254e:	e8 03 eb ff ff       	call   801056 <sys_page_unmap>
}
  802553:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802556:	c9                   	leave  
  802557:	c3                   	ret    

00802558 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	57                   	push   %edi
  80255c:	56                   	push   %esi
  80255d:	53                   	push   %ebx
  80255e:	83 ec 1c             	sub    $0x1c,%esp
  802561:	89 c7                	mov    %eax,%edi
  802563:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802566:	a1 04 50 80 00       	mov    0x805004,%eax
  80256b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80256e:	83 ec 0c             	sub    $0xc,%esp
  802571:	57                   	push   %edi
  802572:	e8 09 05 00 00       	call   802a80 <pageref>
  802577:	89 c6                	mov    %eax,%esi
  802579:	83 c4 04             	add    $0x4,%esp
  80257c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80257f:	e8 fc 04 00 00       	call   802a80 <pageref>
  802584:	83 c4 10             	add    $0x10,%esp
  802587:	39 c6                	cmp    %eax,%esi
  802589:	0f 94 c0             	sete   %al
  80258c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80258f:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802595:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802598:	39 cb                	cmp    %ecx,%ebx
  80259a:	75 08                	jne    8025a4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80259c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259f:	5b                   	pop    %ebx
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	c9                   	leave  
  8025a3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8025a4:	83 f8 01             	cmp    $0x1,%eax
  8025a7:	75 bd                	jne    802566 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8025a9:	8b 42 58             	mov    0x58(%edx),%eax
  8025ac:	6a 01                	push   $0x1
  8025ae:	50                   	push   %eax
  8025af:	53                   	push   %ebx
  8025b0:	68 c9 34 80 00       	push   $0x8034c9
  8025b5:	e8 1a e0 ff ff       	call   8005d4 <cprintf>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	eb a7                	jmp    802566 <_pipeisclosed+0xe>

008025bf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025bf:	55                   	push   %ebp
  8025c0:	89 e5                	mov    %esp,%ebp
  8025c2:	57                   	push   %edi
  8025c3:	56                   	push   %esi
  8025c4:	53                   	push   %ebx
  8025c5:	83 ec 28             	sub    $0x28,%esp
  8025c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8025cb:	56                   	push   %esi
  8025cc:	e8 0f ef ff ff       	call   8014e0 <fd2data>
  8025d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025da:	75 4a                	jne    802626 <devpipe_write+0x67>
  8025dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8025e1:	eb 56                	jmp    802639 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8025e3:	89 da                	mov    %ebx,%edx
  8025e5:	89 f0                	mov    %esi,%eax
  8025e7:	e8 6c ff ff ff       	call   802558 <_pipeisclosed>
  8025ec:	85 c0                	test   %eax,%eax
  8025ee:	75 4d                	jne    80263d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8025f0:	e8 f0 e9 ff ff       	call   800fe5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8025f8:	8b 13                	mov    (%ebx),%edx
  8025fa:	83 c2 20             	add    $0x20,%edx
  8025fd:	39 d0                	cmp    %edx,%eax
  8025ff:	73 e2                	jae    8025e3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802601:	89 c2                	mov    %eax,%edx
  802603:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802609:	79 05                	jns    802610 <devpipe_write+0x51>
  80260b:	4a                   	dec    %edx
  80260c:	83 ca e0             	or     $0xffffffe0,%edx
  80260f:	42                   	inc    %edx
  802610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802613:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802616:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80261a:	40                   	inc    %eax
  80261b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80261e:	47                   	inc    %edi
  80261f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802622:	77 07                	ja     80262b <devpipe_write+0x6c>
  802624:	eb 13                	jmp    802639 <devpipe_write+0x7a>
  802626:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80262b:	8b 43 04             	mov    0x4(%ebx),%eax
  80262e:	8b 13                	mov    (%ebx),%edx
  802630:	83 c2 20             	add    $0x20,%edx
  802633:	39 d0                	cmp    %edx,%eax
  802635:	73 ac                	jae    8025e3 <devpipe_write+0x24>
  802637:	eb c8                	jmp    802601 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802639:	89 f8                	mov    %edi,%eax
  80263b:	eb 05                	jmp    802642 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80263d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802645:	5b                   	pop    %ebx
  802646:	5e                   	pop    %esi
  802647:	5f                   	pop    %edi
  802648:	c9                   	leave  
  802649:	c3                   	ret    

0080264a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80264a:	55                   	push   %ebp
  80264b:	89 e5                	mov    %esp,%ebp
  80264d:	57                   	push   %edi
  80264e:	56                   	push   %esi
  80264f:	53                   	push   %ebx
  802650:	83 ec 18             	sub    $0x18,%esp
  802653:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802656:	57                   	push   %edi
  802657:	e8 84 ee ff ff       	call   8014e0 <fd2data>
  80265c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80265e:	83 c4 10             	add    $0x10,%esp
  802661:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802665:	75 44                	jne    8026ab <devpipe_read+0x61>
  802667:	be 00 00 00 00       	mov    $0x0,%esi
  80266c:	eb 4f                	jmp    8026bd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80266e:	89 f0                	mov    %esi,%eax
  802670:	eb 54                	jmp    8026c6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802672:	89 da                	mov    %ebx,%edx
  802674:	89 f8                	mov    %edi,%eax
  802676:	e8 dd fe ff ff       	call   802558 <_pipeisclosed>
  80267b:	85 c0                	test   %eax,%eax
  80267d:	75 42                	jne    8026c1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80267f:	e8 61 e9 ff ff       	call   800fe5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802684:	8b 03                	mov    (%ebx),%eax
  802686:	3b 43 04             	cmp    0x4(%ebx),%eax
  802689:	74 e7                	je     802672 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80268b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802690:	79 05                	jns    802697 <devpipe_read+0x4d>
  802692:	48                   	dec    %eax
  802693:	83 c8 e0             	or     $0xffffffe0,%eax
  802696:	40                   	inc    %eax
  802697:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80269b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80269e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8026a1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8026a3:	46                   	inc    %esi
  8026a4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8026a7:	77 07                	ja     8026b0 <devpipe_read+0x66>
  8026a9:	eb 12                	jmp    8026bd <devpipe_read+0x73>
  8026ab:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8026b0:	8b 03                	mov    (%ebx),%eax
  8026b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8026b5:	75 d4                	jne    80268b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8026b7:	85 f6                	test   %esi,%esi
  8026b9:	75 b3                	jne    80266e <devpipe_read+0x24>
  8026bb:	eb b5                	jmp    802672 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8026bd:	89 f0                	mov    %esi,%eax
  8026bf:	eb 05                	jmp    8026c6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8026c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8026c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c9:	5b                   	pop    %ebx
  8026ca:	5e                   	pop    %esi
  8026cb:	5f                   	pop    %edi
  8026cc:	c9                   	leave  
  8026cd:	c3                   	ret    

008026ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8026ce:	55                   	push   %ebp
  8026cf:	89 e5                	mov    %esp,%ebp
  8026d1:	57                   	push   %edi
  8026d2:	56                   	push   %esi
  8026d3:	53                   	push   %ebx
  8026d4:	83 ec 28             	sub    $0x28,%esp
  8026d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8026da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8026dd:	50                   	push   %eax
  8026de:	e8 15 ee ff ff       	call   8014f8 <fd_alloc>
  8026e3:	89 c3                	mov    %eax,%ebx
  8026e5:	83 c4 10             	add    $0x10,%esp
  8026e8:	85 c0                	test   %eax,%eax
  8026ea:	0f 88 24 01 00 00    	js     802814 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026f0:	83 ec 04             	sub    $0x4,%esp
  8026f3:	68 07 04 00 00       	push   $0x407
  8026f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8026fb:	6a 00                	push   $0x0
  8026fd:	e8 0a e9 ff ff       	call   80100c <sys_page_alloc>
  802702:	89 c3                	mov    %eax,%ebx
  802704:	83 c4 10             	add    $0x10,%esp
  802707:	85 c0                	test   %eax,%eax
  802709:	0f 88 05 01 00 00    	js     802814 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80270f:	83 ec 0c             	sub    $0xc,%esp
  802712:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802715:	50                   	push   %eax
  802716:	e8 dd ed ff ff       	call   8014f8 <fd_alloc>
  80271b:	89 c3                	mov    %eax,%ebx
  80271d:	83 c4 10             	add    $0x10,%esp
  802720:	85 c0                	test   %eax,%eax
  802722:	0f 88 dc 00 00 00    	js     802804 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802728:	83 ec 04             	sub    $0x4,%esp
  80272b:	68 07 04 00 00       	push   $0x407
  802730:	ff 75 e0             	pushl  -0x20(%ebp)
  802733:	6a 00                	push   $0x0
  802735:	e8 d2 e8 ff ff       	call   80100c <sys_page_alloc>
  80273a:	89 c3                	mov    %eax,%ebx
  80273c:	83 c4 10             	add    $0x10,%esp
  80273f:	85 c0                	test   %eax,%eax
  802741:	0f 88 bd 00 00 00    	js     802804 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802747:	83 ec 0c             	sub    $0xc,%esp
  80274a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80274d:	e8 8e ed ff ff       	call   8014e0 <fd2data>
  802752:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802754:	83 c4 0c             	add    $0xc,%esp
  802757:	68 07 04 00 00       	push   $0x407
  80275c:	50                   	push   %eax
  80275d:	6a 00                	push   $0x0
  80275f:	e8 a8 e8 ff ff       	call   80100c <sys_page_alloc>
  802764:	89 c3                	mov    %eax,%ebx
  802766:	83 c4 10             	add    $0x10,%esp
  802769:	85 c0                	test   %eax,%eax
  80276b:	0f 88 83 00 00 00    	js     8027f4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802771:	83 ec 0c             	sub    $0xc,%esp
  802774:	ff 75 e0             	pushl  -0x20(%ebp)
  802777:	e8 64 ed ff ff       	call   8014e0 <fd2data>
  80277c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802783:	50                   	push   %eax
  802784:	6a 00                	push   $0x0
  802786:	56                   	push   %esi
  802787:	6a 00                	push   $0x0
  802789:	e8 a2 e8 ff ff       	call   801030 <sys_page_map>
  80278e:	89 c3                	mov    %eax,%ebx
  802790:	83 c4 20             	add    $0x20,%esp
  802793:	85 c0                	test   %eax,%eax
  802795:	78 4f                	js     8027e6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802797:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80279d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8027a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8027ac:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8027b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8027b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8027c1:	83 ec 0c             	sub    $0xc,%esp
  8027c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8027c7:	e8 04 ed ff ff       	call   8014d0 <fd2num>
  8027cc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8027ce:	83 c4 04             	add    $0x4,%esp
  8027d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8027d4:	e8 f7 ec ff ff       	call   8014d0 <fd2num>
  8027d9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8027dc:	83 c4 10             	add    $0x10,%esp
  8027df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027e4:	eb 2e                	jmp    802814 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8027e6:	83 ec 08             	sub    $0x8,%esp
  8027e9:	56                   	push   %esi
  8027ea:	6a 00                	push   $0x0
  8027ec:	e8 65 e8 ff ff       	call   801056 <sys_page_unmap>
  8027f1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8027f4:	83 ec 08             	sub    $0x8,%esp
  8027f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8027fa:	6a 00                	push   $0x0
  8027fc:	e8 55 e8 ff ff       	call   801056 <sys_page_unmap>
  802801:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802804:	83 ec 08             	sub    $0x8,%esp
  802807:	ff 75 e4             	pushl  -0x1c(%ebp)
  80280a:	6a 00                	push   $0x0
  80280c:	e8 45 e8 ff ff       	call   801056 <sys_page_unmap>
  802811:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802814:	89 d8                	mov    %ebx,%eax
  802816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802819:	5b                   	pop    %ebx
  80281a:	5e                   	pop    %esi
  80281b:	5f                   	pop    %edi
  80281c:	c9                   	leave  
  80281d:	c3                   	ret    

0080281e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80281e:	55                   	push   %ebp
  80281f:	89 e5                	mov    %esp,%ebp
  802821:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802827:	50                   	push   %eax
  802828:	ff 75 08             	pushl  0x8(%ebp)
  80282b:	e8 3b ed ff ff       	call   80156b <fd_lookup>
  802830:	83 c4 10             	add    $0x10,%esp
  802833:	85 c0                	test   %eax,%eax
  802835:	78 18                	js     80284f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802837:	83 ec 0c             	sub    $0xc,%esp
  80283a:	ff 75 f4             	pushl  -0xc(%ebp)
  80283d:	e8 9e ec ff ff       	call   8014e0 <fd2data>
	return _pipeisclosed(fd, p);
  802842:	89 c2                	mov    %eax,%edx
  802844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802847:	e8 0c fd ff ff       	call   802558 <_pipeisclosed>
  80284c:	83 c4 10             	add    $0x10,%esp
}
  80284f:	c9                   	leave  
  802850:	c3                   	ret    
  802851:	00 00                	add    %al,(%eax)
	...

00802854 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802854:	55                   	push   %ebp
  802855:	89 e5                	mov    %esp,%ebp
  802857:	57                   	push   %edi
  802858:	56                   	push   %esi
  802859:	53                   	push   %ebx
  80285a:	83 ec 0c             	sub    $0xc,%esp
  80285d:	8b 55 08             	mov    0x8(%ebp),%edx
	const volatile struct Env *e;

	assert(envid != 0);
  802860:	85 d2                	test   %edx,%edx
  802862:	75 16                	jne    80287a <wait+0x26>
  802864:	68 e1 34 80 00       	push   $0x8034e1
  802869:	68 e3 33 80 00       	push   $0x8033e3
  80286e:	6a 09                	push   $0x9
  802870:	68 ec 34 80 00       	push   $0x8034ec
  802875:	e8 82 dc ff ff       	call   8004fc <_panic>
	e = &envs[ENVX(envid)];
  80287a:	89 d0                	mov    %edx,%eax
  80287c:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802881:	89 c1                	mov    %eax,%ecx
  802883:	c1 e1 07             	shl    $0x7,%ecx
  802886:	8d 8c 81 08 00 c0 ee 	lea    -0x113ffff8(%ecx,%eax,4),%ecx
  80288d:	8b 79 40             	mov    0x40(%ecx),%edi
  802890:	39 d7                	cmp    %edx,%edi
  802892:	75 36                	jne    8028ca <wait+0x76>
  802894:	89 c2                	mov    %eax,%edx
  802896:	c1 e2 07             	shl    $0x7,%edx
  802899:	8d 94 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%edx
  8028a0:	8b 52 50             	mov    0x50(%edx),%edx
  8028a3:	85 d2                	test   %edx,%edx
  8028a5:	74 23                	je     8028ca <wait+0x76>
  8028a7:	89 c2                	mov    %eax,%edx
  8028a9:	c1 e2 07             	shl    $0x7,%edx
  8028ac:	8d 34 82             	lea    (%edx,%eax,4),%esi
  8028af:	89 cb                	mov    %ecx,%ebx
  8028b1:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  8028b7:	e8 29 e7 ff ff       	call   800fe5 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8028bc:	8b 43 40             	mov    0x40(%ebx),%eax
  8028bf:	39 f8                	cmp    %edi,%eax
  8028c1:	75 07                	jne    8028ca <wait+0x76>
  8028c3:	8b 46 50             	mov    0x50(%esi),%eax
  8028c6:	85 c0                	test   %eax,%eax
  8028c8:	75 ed                	jne    8028b7 <wait+0x63>
		sys_yield();
}
  8028ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028cd:	5b                   	pop    %ebx
  8028ce:	5e                   	pop    %esi
  8028cf:	5f                   	pop    %edi
  8028d0:	c9                   	leave  
  8028d1:	c3                   	ret    
	...

008028d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028d4:	55                   	push   %ebp
  8028d5:	89 e5                	mov    %esp,%ebp
  8028d7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028da:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8028e1:	75 52                	jne    802935 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8028e3:	83 ec 04             	sub    $0x4,%esp
  8028e6:	6a 07                	push   $0x7
  8028e8:	68 00 f0 bf ee       	push   $0xeebff000
  8028ed:	6a 00                	push   $0x0
  8028ef:	e8 18 e7 ff ff       	call   80100c <sys_page_alloc>
		if (r < 0) {
  8028f4:	83 c4 10             	add    $0x10,%esp
  8028f7:	85 c0                	test   %eax,%eax
  8028f9:	79 12                	jns    80290d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8028fb:	50                   	push   %eax
  8028fc:	68 f7 34 80 00       	push   $0x8034f7
  802901:	6a 24                	push   $0x24
  802903:	68 12 35 80 00       	push   $0x803512
  802908:	e8 ef db ff ff       	call   8004fc <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80290d:	83 ec 08             	sub    $0x8,%esp
  802910:	68 40 29 80 00       	push   $0x802940
  802915:	6a 00                	push   $0x0
  802917:	e8 a3 e7 ff ff       	call   8010bf <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80291c:	83 c4 10             	add    $0x10,%esp
  80291f:	85 c0                	test   %eax,%eax
  802921:	79 12                	jns    802935 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802923:	50                   	push   %eax
  802924:	68 20 35 80 00       	push   $0x803520
  802929:	6a 2a                	push   $0x2a
  80292b:	68 12 35 80 00       	push   $0x803512
  802930:	e8 c7 db ff ff       	call   8004fc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802935:	8b 45 08             	mov    0x8(%ebp),%eax
  802938:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80293d:	c9                   	leave  
  80293e:	c3                   	ret    
	...

00802940 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802940:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802941:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802946:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802948:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80294b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80294f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802952:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802956:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80295a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80295c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80295f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802960:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  802963:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802964:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802965:	c3                   	ret    
	...

00802968 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802968:	55                   	push   %ebp
  802969:	89 e5                	mov    %esp,%ebp
  80296b:	56                   	push   %esi
  80296c:	53                   	push   %ebx
  80296d:	8b 75 08             	mov    0x8(%ebp),%esi
  802970:	8b 45 0c             	mov    0xc(%ebp),%eax
  802973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802976:	85 c0                	test   %eax,%eax
  802978:	74 0e                	je     802988 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80297a:	83 ec 0c             	sub    $0xc,%esp
  80297d:	50                   	push   %eax
  80297e:	e8 84 e7 ff ff       	call   801107 <sys_ipc_recv>
  802983:	83 c4 10             	add    $0x10,%esp
  802986:	eb 10                	jmp    802998 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802988:	83 ec 0c             	sub    $0xc,%esp
  80298b:	68 00 00 c0 ee       	push   $0xeec00000
  802990:	e8 72 e7 ff ff       	call   801107 <sys_ipc_recv>
  802995:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802998:	85 c0                	test   %eax,%eax
  80299a:	75 26                	jne    8029c2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80299c:	85 f6                	test   %esi,%esi
  80299e:	74 0a                	je     8029aa <ipc_recv+0x42>
  8029a0:	a1 04 50 80 00       	mov    0x805004,%eax
  8029a5:	8b 40 74             	mov    0x74(%eax),%eax
  8029a8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8029aa:	85 db                	test   %ebx,%ebx
  8029ac:	74 0a                	je     8029b8 <ipc_recv+0x50>
  8029ae:	a1 04 50 80 00       	mov    0x805004,%eax
  8029b3:	8b 40 78             	mov    0x78(%eax),%eax
  8029b6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8029b8:	a1 04 50 80 00       	mov    0x805004,%eax
  8029bd:	8b 40 70             	mov    0x70(%eax),%eax
  8029c0:	eb 14                	jmp    8029d6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8029c2:	85 f6                	test   %esi,%esi
  8029c4:	74 06                	je     8029cc <ipc_recv+0x64>
  8029c6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8029cc:	85 db                	test   %ebx,%ebx
  8029ce:	74 06                	je     8029d6 <ipc_recv+0x6e>
  8029d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8029d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029d9:	5b                   	pop    %ebx
  8029da:	5e                   	pop    %esi
  8029db:	c9                   	leave  
  8029dc:	c3                   	ret    

008029dd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029dd:	55                   	push   %ebp
  8029de:	89 e5                	mov    %esp,%ebp
  8029e0:	57                   	push   %edi
  8029e1:	56                   	push   %esi
  8029e2:	53                   	push   %ebx
  8029e3:	83 ec 0c             	sub    $0xc,%esp
  8029e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8029ec:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8029ef:	85 db                	test   %ebx,%ebx
  8029f1:	75 25                	jne    802a18 <ipc_send+0x3b>
  8029f3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8029f8:	eb 1e                	jmp    802a18 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8029fa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029fd:	75 07                	jne    802a06 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8029ff:	e8 e1 e5 ff ff       	call   800fe5 <sys_yield>
  802a04:	eb 12                	jmp    802a18 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802a06:	50                   	push   %eax
  802a07:	68 48 35 80 00       	push   $0x803548
  802a0c:	6a 43                	push   $0x43
  802a0e:	68 5b 35 80 00       	push   $0x80355b
  802a13:	e8 e4 da ff ff       	call   8004fc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802a18:	56                   	push   %esi
  802a19:	53                   	push   %ebx
  802a1a:	57                   	push   %edi
  802a1b:	ff 75 08             	pushl  0x8(%ebp)
  802a1e:	e8 bf e6 ff ff       	call   8010e2 <sys_ipc_try_send>
  802a23:	83 c4 10             	add    $0x10,%esp
  802a26:	85 c0                	test   %eax,%eax
  802a28:	75 d0                	jne    8029fa <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a2d:	5b                   	pop    %ebx
  802a2e:	5e                   	pop    %esi
  802a2f:	5f                   	pop    %edi
  802a30:	c9                   	leave  
  802a31:	c3                   	ret    

00802a32 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a32:	55                   	push   %ebp
  802a33:	89 e5                	mov    %esp,%ebp
  802a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802a38:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  802a3e:	74 1a                	je     802a5a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a40:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802a45:	89 c2                	mov    %eax,%edx
  802a47:	c1 e2 07             	shl    $0x7,%edx
  802a4a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802a51:	8b 52 50             	mov    0x50(%edx),%edx
  802a54:	39 ca                	cmp    %ecx,%edx
  802a56:	75 18                	jne    802a70 <ipc_find_env+0x3e>
  802a58:	eb 05                	jmp    802a5f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a5a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802a5f:	89 c2                	mov    %eax,%edx
  802a61:	c1 e2 07             	shl    $0x7,%edx
  802a64:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  802a6b:	8b 40 40             	mov    0x40(%eax),%eax
  802a6e:	eb 0c                	jmp    802a7c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a70:	40                   	inc    %eax
  802a71:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a76:	75 cd                	jne    802a45 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a78:	66 b8 00 00          	mov    $0x0,%ax
}
  802a7c:	c9                   	leave  
  802a7d:	c3                   	ret    
	...

00802a80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a80:	55                   	push   %ebp
  802a81:	89 e5                	mov    %esp,%ebp
  802a83:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a86:	89 c2                	mov    %eax,%edx
  802a88:	c1 ea 16             	shr    $0x16,%edx
  802a8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a92:	f6 c2 01             	test   $0x1,%dl
  802a95:	74 1e                	je     802ab5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a97:	c1 e8 0c             	shr    $0xc,%eax
  802a9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802aa1:	a8 01                	test   $0x1,%al
  802aa3:	74 17                	je     802abc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802aa5:	c1 e8 0c             	shr    $0xc,%eax
  802aa8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802aaf:	ef 
  802ab0:	0f b7 c0             	movzwl %ax,%eax
  802ab3:	eb 0c                	jmp    802ac1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  802aba:	eb 05                	jmp    802ac1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802abc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802ac1:	c9                   	leave  
  802ac2:	c3                   	ret    
	...

00802ac4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802ac4:	55                   	push   %ebp
  802ac5:	89 e5                	mov    %esp,%ebp
  802ac7:	57                   	push   %edi
  802ac8:	56                   	push   %esi
  802ac9:	83 ec 10             	sub    $0x10,%esp
  802acc:	8b 7d 08             	mov    0x8(%ebp),%edi
  802acf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ad2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802ad8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802adb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ade:	85 c0                	test   %eax,%eax
  802ae0:	75 2e                	jne    802b10 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802ae2:	39 f1                	cmp    %esi,%ecx
  802ae4:	77 5a                	ja     802b40 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ae6:	85 c9                	test   %ecx,%ecx
  802ae8:	75 0b                	jne    802af5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802aea:	b8 01 00 00 00       	mov    $0x1,%eax
  802aef:	31 d2                	xor    %edx,%edx
  802af1:	f7 f1                	div    %ecx
  802af3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802af5:	31 d2                	xor    %edx,%edx
  802af7:	89 f0                	mov    %esi,%eax
  802af9:	f7 f1                	div    %ecx
  802afb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802afd:	89 f8                	mov    %edi,%eax
  802aff:	f7 f1                	div    %ecx
  802b01:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b03:	89 f8                	mov    %edi,%eax
  802b05:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b07:	83 c4 10             	add    $0x10,%esp
  802b0a:	5e                   	pop    %esi
  802b0b:	5f                   	pop    %edi
  802b0c:	c9                   	leave  
  802b0d:	c3                   	ret    
  802b0e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b10:	39 f0                	cmp    %esi,%eax
  802b12:	77 1c                	ja     802b30 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b14:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802b17:	83 f7 1f             	xor    $0x1f,%edi
  802b1a:	75 3c                	jne    802b58 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b1c:	39 f0                	cmp    %esi,%eax
  802b1e:	0f 82 90 00 00 00    	jb     802bb4 <__udivdi3+0xf0>
  802b24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b27:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802b2a:	0f 86 84 00 00 00    	jbe    802bb4 <__udivdi3+0xf0>
  802b30:	31 f6                	xor    %esi,%esi
  802b32:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b34:	89 f8                	mov    %edi,%eax
  802b36:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b38:	83 c4 10             	add    $0x10,%esp
  802b3b:	5e                   	pop    %esi
  802b3c:	5f                   	pop    %edi
  802b3d:	c9                   	leave  
  802b3e:	c3                   	ret    
  802b3f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b40:	89 f2                	mov    %esi,%edx
  802b42:	89 f8                	mov    %edi,%eax
  802b44:	f7 f1                	div    %ecx
  802b46:	89 c7                	mov    %eax,%edi
  802b48:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b4a:	89 f8                	mov    %edi,%eax
  802b4c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b4e:	83 c4 10             	add    $0x10,%esp
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	c9                   	leave  
  802b54:	c3                   	ret    
  802b55:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b58:	89 f9                	mov    %edi,%ecx
  802b5a:	d3 e0                	shl    %cl,%eax
  802b5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b5f:	b8 20 00 00 00       	mov    $0x20,%eax
  802b64:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b69:	88 c1                	mov    %al,%cl
  802b6b:	d3 ea                	shr    %cl,%edx
  802b6d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802b70:	09 ca                	or     %ecx,%edx
  802b72:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b78:	89 f9                	mov    %edi,%ecx
  802b7a:	d3 e2                	shl    %cl,%edx
  802b7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802b7f:	89 f2                	mov    %esi,%edx
  802b81:	88 c1                	mov    %al,%cl
  802b83:	d3 ea                	shr    %cl,%edx
  802b85:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802b88:	89 f2                	mov    %esi,%edx
  802b8a:	89 f9                	mov    %edi,%ecx
  802b8c:	d3 e2                	shl    %cl,%edx
  802b8e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802b91:	88 c1                	mov    %al,%cl
  802b93:	d3 ee                	shr    %cl,%esi
  802b95:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b97:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802b9a:	89 f0                	mov    %esi,%eax
  802b9c:	89 ca                	mov    %ecx,%edx
  802b9e:	f7 75 ec             	divl   -0x14(%ebp)
  802ba1:	89 d1                	mov    %edx,%ecx
  802ba3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ba5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ba8:	39 d1                	cmp    %edx,%ecx
  802baa:	72 28                	jb     802bd4 <__udivdi3+0x110>
  802bac:	74 1a                	je     802bc8 <__udivdi3+0x104>
  802bae:	89 f7                	mov    %esi,%edi
  802bb0:	31 f6                	xor    %esi,%esi
  802bb2:	eb 80                	jmp    802b34 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802bb4:	31 f6                	xor    %esi,%esi
  802bb6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802bbb:	89 f8                	mov    %edi,%eax
  802bbd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802bbf:	83 c4 10             	add    $0x10,%esp
  802bc2:	5e                   	pop    %esi
  802bc3:	5f                   	pop    %edi
  802bc4:	c9                   	leave  
  802bc5:	c3                   	ret    
  802bc6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bcb:	89 f9                	mov    %edi,%ecx
  802bcd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bcf:	39 c2                	cmp    %eax,%edx
  802bd1:	73 db                	jae    802bae <__udivdi3+0xea>
  802bd3:	90                   	nop
		{
		  q0--;
  802bd4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bd7:	31 f6                	xor    %esi,%esi
  802bd9:	e9 56 ff ff ff       	jmp    802b34 <__udivdi3+0x70>
	...

00802be0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802be0:	55                   	push   %ebp
  802be1:	89 e5                	mov    %esp,%ebp
  802be3:	57                   	push   %edi
  802be4:	56                   	push   %esi
  802be5:	83 ec 20             	sub    $0x20,%esp
  802be8:	8b 45 08             	mov    0x8(%ebp),%eax
  802beb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802bee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802bf4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802bf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802bfd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802bff:	85 ff                	test   %edi,%edi
  802c01:	75 15                	jne    802c18 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802c03:	39 f1                	cmp    %esi,%ecx
  802c05:	0f 86 99 00 00 00    	jbe    802ca4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c0b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802c0d:	89 d0                	mov    %edx,%eax
  802c0f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c11:	83 c4 20             	add    $0x20,%esp
  802c14:	5e                   	pop    %esi
  802c15:	5f                   	pop    %edi
  802c16:	c9                   	leave  
  802c17:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802c18:	39 f7                	cmp    %esi,%edi
  802c1a:	0f 87 a4 00 00 00    	ja     802cc4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802c20:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802c23:	83 f0 1f             	xor    $0x1f,%eax
  802c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802c29:	0f 84 a1 00 00 00    	je     802cd0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802c2f:	89 f8                	mov    %edi,%eax
  802c31:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c34:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802c36:	bf 20 00 00 00       	mov    $0x20,%edi
  802c3b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c41:	89 f9                	mov    %edi,%ecx
  802c43:	d3 ea                	shr    %cl,%edx
  802c45:	09 c2                	or     %eax,%edx
  802c47:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c4d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c50:	d3 e0                	shl    %cl,%eax
  802c52:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c55:	89 f2                	mov    %esi,%edx
  802c57:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802c59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802c5c:	d3 e0                	shl    %cl,%eax
  802c5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802c64:	89 f9                	mov    %edi,%ecx
  802c66:	d3 e8                	shr    %cl,%eax
  802c68:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802c6a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802c6c:	89 f2                	mov    %esi,%edx
  802c6e:	f7 75 f0             	divl   -0x10(%ebp)
  802c71:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802c73:	f7 65 f4             	mull   -0xc(%ebp)
  802c76:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802c79:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c7b:	39 d6                	cmp    %edx,%esi
  802c7d:	72 71                	jb     802cf0 <__umoddi3+0x110>
  802c7f:	74 7f                	je     802d00 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c84:	29 c8                	sub    %ecx,%eax
  802c86:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802c88:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c8b:	d3 e8                	shr    %cl,%eax
  802c8d:	89 f2                	mov    %esi,%edx
  802c8f:	89 f9                	mov    %edi,%ecx
  802c91:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802c93:	09 d0                	or     %edx,%eax
  802c95:	89 f2                	mov    %esi,%edx
  802c97:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c9a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c9c:	83 c4 20             	add    $0x20,%esp
  802c9f:	5e                   	pop    %esi
  802ca0:	5f                   	pop    %edi
  802ca1:	c9                   	leave  
  802ca2:	c3                   	ret    
  802ca3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ca4:	85 c9                	test   %ecx,%ecx
  802ca6:	75 0b                	jne    802cb3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ca8:	b8 01 00 00 00       	mov    $0x1,%eax
  802cad:	31 d2                	xor    %edx,%edx
  802caf:	f7 f1                	div    %ecx
  802cb1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802cb3:	89 f0                	mov    %esi,%eax
  802cb5:	31 d2                	xor    %edx,%edx
  802cb7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cbc:	f7 f1                	div    %ecx
  802cbe:	e9 4a ff ff ff       	jmp    802c0d <__umoddi3+0x2d>
  802cc3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802cc4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cc6:	83 c4 20             	add    $0x20,%esp
  802cc9:	5e                   	pop    %esi
  802cca:	5f                   	pop    %edi
  802ccb:	c9                   	leave  
  802ccc:	c3                   	ret    
  802ccd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802cd0:	39 f7                	cmp    %esi,%edi
  802cd2:	72 05                	jb     802cd9 <__umoddi3+0xf9>
  802cd4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802cd7:	77 0c                	ja     802ce5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802cd9:	89 f2                	mov    %esi,%edx
  802cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cde:	29 c8                	sub    %ecx,%eax
  802ce0:	19 fa                	sbb    %edi,%edx
  802ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ce8:	83 c4 20             	add    $0x20,%esp
  802ceb:	5e                   	pop    %esi
  802cec:	5f                   	pop    %edi
  802ced:	c9                   	leave  
  802cee:	c3                   	ret    
  802cef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802cf0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802cf3:	89 c1                	mov    %eax,%ecx
  802cf5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802cf8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802cfb:	eb 84                	jmp    802c81 <__umoddi3+0xa1>
  802cfd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802d00:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802d03:	72 eb                	jb     802cf0 <__umoddi3+0x110>
  802d05:	89 f2                	mov    %esi,%edx
  802d07:	e9 75 ff ff ff       	jmp    802c81 <__umoddi3+0xa1>
