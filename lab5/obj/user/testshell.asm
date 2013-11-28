
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
  80004b:	e8 be 18 00 00       	call   80190e <seek>
	seek(kfd, off);
  800050:	83 c4 08             	add    $0x8,%esp
  800053:	53                   	push   %ebx
  800054:	56                   	push   %esi
  800055:	e8 b4 18 00 00       	call   80190e <seek>

	cprintf("shell produced incorrect output.\n");
  80005a:	c7 04 24 00 2d 80 00 	movl   $0x802d00,(%esp)
  800061:	e8 72 05 00 00       	call   8005d8 <cprintf>
	cprintf("expected:\n===\n");
  800066:	c7 04 24 6b 2d 80 00 	movl   $0x802d6b,(%esp)
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
  80008e:	e8 1d 17 00 00       	call   8017b0 <read>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	7f e0                	jg     80007a <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 7a 2d 80 00       	push   $0x802d7a
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
  8000c3:	e8 e8 16 00 00       	call   8017b0 <read>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f e0                	jg     8000af <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	68 75 2d 80 00       	push   $0x802d75
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
  8000f7:	e8 77 15 00 00       	call   801673 <close>
	close(1);
  8000fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800103:	e8 6b 15 00 00       	call   801673 <close>
	opencons();
  800108:	e8 35 03 00 00       	call   800442 <opencons>
	opencons();
  80010d:	e8 30 03 00 00       	call   800442 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 00                	push   $0x0
  800117:	68 88 2d 80 00       	push   $0x802d88
  80011c:	e8 93 1a 00 00       	call   801bb4 <open>
  800121:	89 c6                	mov    %eax,%esi
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	85 c0                	test   %eax,%eax
  800128:	79 12                	jns    80013c <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  80012a:	50                   	push   %eax
  80012b:	68 95 2d 80 00       	push   $0x802d95
  800130:	6a 13                	push   $0x13
  800132:	68 ab 2d 80 00       	push   $0x802dab
  800137:	e8 c4 03 00 00       	call   800500 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 4e 25 00 00       	call   802696 <pipe>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	79 12                	jns    800161 <umain+0x75>
		panic("pipe: %e", wfd);
  80014f:	50                   	push   %eax
  800150:	68 bc 2d 80 00       	push   $0x802dbc
  800155:	6a 15                	push   $0x15
  800157:	68 ab 2d 80 00       	push   $0x802dab
  80015c:	e8 9f 03 00 00       	call   800500 <_panic>
	wfd = pfds[1];
  800161:	8b 7d e0             	mov    -0x20(%ebp),%edi

	cprintf("running sh -x < testshell.sh | cat\n");
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	68 24 2d 80 00       	push   $0x802d24
  80016c:	e8 67 04 00 00       	call   8005d8 <cprintf>
	if ((r = fork()) < 0)
  800171:	e8 d4 10 00 00       	call   80124a <fork>
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	79 12                	jns    80018f <umain+0xa3>
		panic("fork: %e", r);
  80017d:	50                   	push   %eax
  80017e:	68 c5 2d 80 00       	push   $0x802dc5
  800183:	6a 1a                	push   $0x1a
  800185:	68 ab 2d 80 00       	push   $0x802dab
  80018a:	e8 71 03 00 00       	call   800500 <_panic>
	if (r == 0) {
  80018f:	85 c0                	test   %eax,%eax
  800191:	75 7d                	jne    800210 <umain+0x124>
		dup(rfd, 0);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	6a 00                	push   $0x0
  800198:	56                   	push   %esi
  800199:	e8 23 15 00 00       	call   8016c1 <dup>
		dup(wfd, 1);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	6a 01                	push   $0x1
  8001a3:	57                   	push   %edi
  8001a4:	e8 18 15 00 00       	call   8016c1 <dup>
		close(rfd);
  8001a9:	89 34 24             	mov    %esi,(%esp)
  8001ac:	e8 c2 14 00 00       	call   801673 <close>
		close(wfd);
  8001b1:	89 3c 24             	mov    %edi,(%esp)
  8001b4:	e8 ba 14 00 00       	call   801673 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b9:	6a 00                	push   $0x0
  8001bb:	68 ce 2d 80 00       	push   $0x802dce
  8001c0:	68 92 2d 80 00       	push   $0x802d92
  8001c5:	68 d1 2d 80 00       	push   $0x802dd1
  8001ca:	e8 51 22 00 00       	call   802420 <spawnl>
  8001cf:	89 c3                	mov    %eax,%ebx
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	79 12                	jns    8001ea <umain+0xfe>
			panic("spawn: %e", r);
  8001d8:	50                   	push   %eax
  8001d9:	68 d5 2d 80 00       	push   $0x802dd5
  8001de:	6a 21                	push   $0x21
  8001e0:	68 ab 2d 80 00       	push   $0x802dab
  8001e5:	e8 16 03 00 00       	call   800500 <_panic>
		close(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 7f 14 00 00       	call   801673 <close>
		close(1);
  8001f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fb:	e8 73 14 00 00       	call   801673 <close>
		wait(r);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 14 26 00 00       	call   80281c <wait>
		exit();
  800208:	e8 d7 02 00 00       	call   8004e4 <exit>
  80020d:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	56                   	push   %esi
  800214:	e8 5a 14 00 00       	call   801673 <close>
	close(wfd);
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	e8 52 14 00 00       	call   801673 <close>

	rfd = pfds[0];
  800221:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800224:	83 c4 08             	add    $0x8,%esp
  800227:	6a 00                	push   $0x0
  800229:	68 df 2d 80 00       	push   $0x802ddf
  80022e:	e8 81 19 00 00       	call   801bb4 <open>
  800233:	89 c6                	mov    %eax,%esi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x162>
		panic("open testshell.key for reading: %e", kfd);
  80023c:	50                   	push   %eax
  80023d:	68 48 2d 80 00       	push   $0x802d48
  800242:	6a 2c                	push   $0x2c
  800244:	68 ab 2d 80 00       	push   $0x802dab
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
  800266:	e8 45 15 00 00       	call   8017b0 <read>
  80026b:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026d:	83 c4 0c             	add    $0xc,%esp
  800270:	6a 01                	push   $0x1
  800272:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	56                   	push   %esi
  800277:	e8 34 15 00 00       	call   8017b0 <read>
		if (n1 < 0)
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 db                	test   %ebx,%ebx
  800281:	79 12                	jns    800295 <umain+0x1a9>
			panic("reading testshell.out: %e", n1);
  800283:	53                   	push   %ebx
  800284:	68 ed 2d 80 00       	push   $0x802ded
  800289:	6a 33                	push   $0x33
  80028b:	68 ab 2d 80 00       	push   $0x802dab
  800290:	e8 6b 02 00 00       	call   800500 <_panic>
		if (n2 < 0)
  800295:	85 c0                	test   %eax,%eax
  800297:	79 12                	jns    8002ab <umain+0x1bf>
			panic("reading testshell.key: %e", n2);
  800299:	50                   	push   %eax
  80029a:	68 07 2e 80 00       	push   $0x802e07
  80029f:	6a 35                	push   $0x35
  8002a1:	68 ab 2d 80 00       	push   $0x802dab
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
  8002ee:	68 21 2e 80 00       	push   $0x802e21
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
  800314:	68 36 2e 80 00       	push   $0x802e36
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
  8003f9:	e8 b2 13 00 00       	call   8017b0 <read>
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
  800423:	e8 07 11 00 00       	call   80152f <fd_lookup>
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
  80044c:	e8 6b 10 00 00       	call   8014bc <fd_alloc>
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
  80048a:	e8 05 10 00 00       	call   801494 <fd2num>
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
  8004ea:	e8 af 11 00 00       	call   80169e <close_all>
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
  80051e:	68 4c 2e 80 00       	push   $0x802e4c
  800523:	e8 b0 00 00 00       	call   8005d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800528:	83 c4 18             	add    $0x18,%esp
  80052b:	56                   	push   %esi
  80052c:	ff 75 10             	pushl  0x10(%ebp)
  80052f:	e8 53 00 00 00       	call   800587 <vcprintf>
	cprintf("\n");
  800534:	c7 04 24 78 2d 80 00 	movl   $0x802d78,(%esp)
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
  800640:	e8 5f 24 00 00       	call   802aa4 <__udivdi3>
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
  80067c:	e8 3f 25 00 00       	call   802bc0 <__umoddi3>
  800681:	83 c4 14             	add    $0x14,%esp
  800684:	0f be 80 6f 2e 80 00 	movsbl 0x802e6f(%eax),%eax
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
  8007c8:	ff 24 85 c0 2f 80 00 	jmp    *0x802fc0(,%eax,4)
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
  800874:	8b 04 85 20 31 80 00 	mov    0x803120(,%eax,4),%eax
  80087b:	85 c0                	test   %eax,%eax
  80087d:	75 1a                	jne    800899 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80087f:	52                   	push   %edx
  800880:	68 87 2e 80 00       	push   $0x802e87
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
  80089a:	68 d5 33 80 00       	push   $0x8033d5
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
  8008d0:	c7 45 d0 80 2e 80 00 	movl   $0x802e80,-0x30(%ebp)
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
  800f3e:	68 7f 31 80 00       	push   $0x80317f
  800f43:	6a 42                	push   $0x42
  800f45:	68 9c 31 80 00       	push   $0x80319c
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

00801150 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  801156:	6a 00                	push   $0x0
  801158:	ff 75 14             	pushl  0x14(%ebp)
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	ff 75 0c             	pushl  0xc(%ebp)
  801161:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801164:	ba 00 00 00 00       	mov    $0x0,%edx
  801169:	b8 0f 00 00 00       	mov    $0xf,%eax
  80116e:	e8 99 fd ff ff       	call   800f0c <syscall>
  801173:	c9                   	leave  
  801174:	c3                   	ret    
  801175:	00 00                	add    %al,(%eax)
	...

00801178 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801182:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  801184:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801188:	75 14                	jne    80119e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	68 ac 31 80 00       	push   $0x8031ac
  801192:	6a 20                	push   $0x20
  801194:	68 f0 32 80 00       	push   $0x8032f0
  801199:	e8 62 f3 ff ff       	call   800500 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  80119e:	89 d8                	mov    %ebx,%eax
  8011a0:	c1 e8 16             	shr    $0x16,%eax
  8011a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011aa:	a8 01                	test   $0x1,%al
  8011ac:	74 11                	je     8011bf <pgfault+0x47>
  8011ae:	89 d8                	mov    %ebx,%eax
  8011b0:	c1 e8 0c             	shr    $0xc,%eax
  8011b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ba:	f6 c4 08             	test   $0x8,%ah
  8011bd:	75 14                	jne    8011d3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  8011bf:	83 ec 04             	sub    $0x4,%esp
  8011c2:	68 d0 31 80 00       	push   $0x8031d0
  8011c7:	6a 24                	push   $0x24
  8011c9:	68 f0 32 80 00       	push   $0x8032f0
  8011ce:	e8 2d f3 ff ff       	call   800500 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	6a 07                	push   $0x7
  8011d8:	68 00 f0 7f 00       	push   $0x7ff000
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 2c fe ff ff       	call   801010 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 12                	jns    8011fd <pgfault+0x85>
  8011eb:	50                   	push   %eax
  8011ec:	68 f4 31 80 00       	push   $0x8031f4
  8011f1:	6a 32                	push   $0x32
  8011f3:	68 f0 32 80 00       	push   $0x8032f0
  8011f8:	e8 03 f3 ff ff       	call   800500 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  8011fd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  801203:	83 ec 04             	sub    $0x4,%esp
  801206:	68 00 10 00 00       	push   $0x1000
  80120b:	53                   	push   %ebx
  80120c:	68 00 f0 7f 00       	push   $0x7ff000
  801211:	e8 a3 fb ff ff       	call   800db9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  801216:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80121d:	53                   	push   %ebx
  80121e:	6a 00                	push   $0x0
  801220:	68 00 f0 7f 00       	push   $0x7ff000
  801225:	6a 00                	push   $0x0
  801227:	e8 08 fe ff ff       	call   801034 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  80122c:	83 c4 20             	add    $0x20,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	79 12                	jns    801245 <pgfault+0xcd>
  801233:	50                   	push   %eax
  801234:	68 18 32 80 00       	push   $0x803218
  801239:	6a 3a                	push   $0x3a
  80123b:	68 f0 32 80 00       	push   $0x8032f0
  801240:	e8 bb f2 ff ff       	call   800500 <_panic>

	return;
}
  801245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801253:	68 78 11 80 00       	push   $0x801178
  801258:	e8 47 16 00 00       	call   8028a4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80125d:	ba 07 00 00 00       	mov    $0x7,%edx
  801262:	89 d0                	mov    %edx,%eax
  801264:	cd 30                	int    $0x30
  801266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801269:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	79 12                	jns    801284 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  801272:	50                   	push   %eax
  801273:	68 fb 32 80 00       	push   $0x8032fb
  801278:	6a 7f                	push   $0x7f
  80127a:	68 f0 32 80 00       	push   $0x8032f0
  80127f:	e8 7c f2 ff ff       	call   800500 <_panic>
	}
	int r;

	if (childpid == 0) {
  801284:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801288:	75 25                	jne    8012af <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  80128a:	e8 36 fd ff ff       	call   800fc5 <sys_getenvid>
  80128f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801294:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80129b:	c1 e0 07             	shl    $0x7,%eax
  80129e:	29 d0                	sub    %edx,%eax
  8012a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a5:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  8012aa:	e9 be 01 00 00       	jmp    80146d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  8012af:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	c1 e8 16             	shr    $0x16,%eax
  8012b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c0:	a8 01                	test   $0x1,%al
  8012c2:	0f 84 10 01 00 00    	je     8013d8 <fork+0x18e>
  8012c8:	89 d8                	mov    %ebx,%eax
  8012ca:	c1 e8 0c             	shr    $0xc,%eax
  8012cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d4:	f6 c2 01             	test   $0x1,%dl
  8012d7:	0f 84 fb 00 00 00    	je     8013d8 <fork+0x18e>
  8012dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e4:	f6 c2 04             	test   $0x4,%dl
  8012e7:	0f 84 eb 00 00 00    	je     8013d8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  8012ed:	89 c6                	mov    %eax,%esi
  8012ef:	c1 e6 0c             	shl    $0xc,%esi
  8012f2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  8012f8:	0f 84 da 00 00 00    	je     8013d8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  8012fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801305:	f6 c6 04             	test   $0x4,%dh
  801308:	74 37                	je     801341 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80130a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	25 07 0e 00 00       	and    $0xe07,%eax
  801319:	50                   	push   %eax
  80131a:	56                   	push   %esi
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	6a 00                	push   $0x0
  80131f:	e8 10 fd ff ff       	call   801034 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801324:	83 c4 20             	add    $0x20,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	0f 89 a9 00 00 00    	jns    8013d8 <fork+0x18e>
  80132f:	50                   	push   %eax
  801330:	68 3c 32 80 00       	push   $0x80323c
  801335:	6a 54                	push   $0x54
  801337:	68 f0 32 80 00       	push   $0x8032f0
  80133c:	e8 bf f1 ff ff       	call   800500 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801341:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801348:	f6 c2 02             	test   $0x2,%dl
  80134b:	75 0c                	jne    801359 <fork+0x10f>
  80134d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801354:	f6 c4 08             	test   $0x8,%ah
  801357:	74 57                	je     8013b0 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	68 05 08 00 00       	push   $0x805
  801361:	56                   	push   %esi
  801362:	57                   	push   %edi
  801363:	56                   	push   %esi
  801364:	6a 00                	push   $0x0
  801366:	e8 c9 fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 12                	jns    801384 <fork+0x13a>
  801372:	50                   	push   %eax
  801373:	68 3c 32 80 00       	push   $0x80323c
  801378:	6a 59                	push   $0x59
  80137a:	68 f0 32 80 00       	push   $0x8032f0
  80137f:	e8 7c f1 ff ff       	call   800500 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	68 05 08 00 00       	push   $0x805
  80138c:	56                   	push   %esi
  80138d:	6a 00                	push   $0x0
  80138f:	56                   	push   %esi
  801390:	6a 00                	push   $0x0
  801392:	e8 9d fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801397:	83 c4 20             	add    $0x20,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 3a                	jns    8013d8 <fork+0x18e>
  80139e:	50                   	push   %eax
  80139f:	68 3c 32 80 00       	push   $0x80323c
  8013a4:	6a 5c                	push   $0x5c
  8013a6:	68 f0 32 80 00       	push   $0x8032f0
  8013ab:	e8 50 f1 ff ff       	call   800500 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	6a 05                	push   $0x5
  8013b5:	56                   	push   %esi
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 75 fc ff ff       	call   801034 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8013bf:	83 c4 20             	add    $0x20,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	79 12                	jns    8013d8 <fork+0x18e>
  8013c6:	50                   	push   %eax
  8013c7:	68 3c 32 80 00       	push   $0x80323c
  8013cc:	6a 60                	push   $0x60
  8013ce:	68 f0 32 80 00       	push   $0x8032f0
  8013d3:	e8 28 f1 ff ff       	call   800500 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8013d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013de:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8013e4:	0f 85 ca fe ff ff    	jne    8012b4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8013ea:	83 ec 04             	sub    $0x4,%esp
  8013ed:	6a 07                	push   $0x7
  8013ef:	68 00 f0 bf ee       	push   $0xeebff000
  8013f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f7:	e8 14 fc ff ff       	call   801010 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	79 15                	jns    801418 <fork+0x1ce>
  801403:	50                   	push   %eax
  801404:	68 60 32 80 00       	push   $0x803260
  801409:	68 94 00 00 00       	push   $0x94
  80140e:	68 f0 32 80 00       	push   $0x8032f0
  801413:	e8 e8 f0 ff ff       	call   800500 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	68 10 29 80 00       	push   $0x802910
  801420:	ff 75 e4             	pushl  -0x1c(%ebp)
  801423:	e8 9b fc ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 15                	jns    801444 <fork+0x1fa>
  80142f:	50                   	push   %eax
  801430:	68 98 32 80 00       	push   $0x803298
  801435:	68 99 00 00 00       	push   $0x99
  80143a:	68 f0 32 80 00       	push   $0x8032f0
  80143f:	e8 bc f0 ff ff       	call   800500 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 02                	push   $0x2
  801449:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144c:	e8 2c fc ff ff       	call   80107d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	79 15                	jns    80146d <fork+0x223>
  801458:	50                   	push   %eax
  801459:	68 bc 32 80 00       	push   $0x8032bc
  80145e:	68 a4 00 00 00       	push   $0xa4
  801463:	68 f0 32 80 00       	push   $0x8032f0
  801468:	e8 93 f0 ff ff       	call   800500 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80146d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	5f                   	pop    %edi
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <sfork>:

// Challenge!
int
sfork(void)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80147e:	68 18 33 80 00       	push   $0x803318
  801483:	68 b1 00 00 00       	push   $0xb1
  801488:	68 f0 32 80 00       	push   $0x8032f0
  80148d:	e8 6e f0 ff ff       	call   800500 <_panic>
	...

00801494 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	05 00 00 00 30       	add    $0x30000000,%eax
  80149f:	c1 e8 0c             	shr    $0xc,%eax
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 e5 ff ff ff       	call   801494 <fd2num>
  8014af:	83 c4 04             	add    $0x4,%esp
  8014b2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014b7:	c1 e0 0c             	shl    $0xc,%eax
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014c8:	a8 01                	test   $0x1,%al
  8014ca:	74 34                	je     801500 <fd_alloc+0x44>
  8014cc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014d1:	a8 01                	test   $0x1,%al
  8014d3:	74 32                	je     801507 <fd_alloc+0x4b>
  8014d5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8014da:	89 c1                	mov    %eax,%ecx
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	c1 ea 16             	shr    $0x16,%edx
  8014e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e8:	f6 c2 01             	test   $0x1,%dl
  8014eb:	74 1f                	je     80150c <fd_alloc+0x50>
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	c1 ea 0c             	shr    $0xc,%edx
  8014f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f9:	f6 c2 01             	test   $0x1,%dl
  8014fc:	75 17                	jne    801515 <fd_alloc+0x59>
  8014fe:	eb 0c                	jmp    80150c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801500:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801505:	eb 05                	jmp    80150c <fd_alloc+0x50>
  801507:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80150c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80150e:	b8 00 00 00 00       	mov    $0x0,%eax
  801513:	eb 17                	jmp    80152c <fd_alloc+0x70>
  801515:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80151a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151f:	75 b9                	jne    8014da <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801521:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801527:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80152c:	5b                   	pop    %ebx
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801535:	83 f8 1f             	cmp    $0x1f,%eax
  801538:	77 36                	ja     801570 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80153a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80153f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801542:	89 c2                	mov    %eax,%edx
  801544:	c1 ea 16             	shr    $0x16,%edx
  801547:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80154e:	f6 c2 01             	test   $0x1,%dl
  801551:	74 24                	je     801577 <fd_lookup+0x48>
  801553:	89 c2                	mov    %eax,%edx
  801555:	c1 ea 0c             	shr    $0xc,%edx
  801558:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155f:	f6 c2 01             	test   $0x1,%dl
  801562:	74 1a                	je     80157e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801564:	8b 55 0c             	mov    0xc(%ebp),%edx
  801567:	89 02                	mov    %eax,(%edx)
	return 0;
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	eb 13                	jmp    801583 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801570:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801575:	eb 0c                	jmp    801583 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157c:	eb 05                	jmp    801583 <fd_lookup+0x54>
  80157e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	53                   	push   %ebx
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801592:	39 0d 20 40 80 00    	cmp    %ecx,0x804020
  801598:	74 0d                	je     8015a7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
  80159f:	eb 14                	jmp    8015b5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8015a1:	39 0a                	cmp    %ecx,(%edx)
  8015a3:	75 10                	jne    8015b5 <dev_lookup+0x30>
  8015a5:	eb 05                	jmp    8015ac <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a7:	ba 20 40 80 00       	mov    $0x804020,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8015ac:	89 13                	mov    %edx,(%ebx)
			return 0;
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	eb 31                	jmp    8015e6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015b5:	40                   	inc    %eax
  8015b6:	8b 14 85 ac 33 80 00 	mov    0x8033ac(,%eax,4),%edx
  8015bd:	85 d2                	test   %edx,%edx
  8015bf:	75 e0                	jne    8015a1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c1:	a1 04 50 80 00       	mov    0x805004,%eax
  8015c6:	8b 40 48             	mov    0x48(%eax),%eax
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	51                   	push   %ecx
  8015cd:	50                   	push   %eax
  8015ce:	68 30 33 80 00       	push   $0x803330
  8015d3:	e8 00 f0 ff ff       	call   8005d8 <cprintf>
	*dev = 0;
  8015d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 20             	sub    $0x20,%esp
  8015f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f6:	8a 45 0c             	mov    0xc(%ebp),%al
  8015f9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fc:	56                   	push   %esi
  8015fd:	e8 92 fe ff ff       	call   801494 <fd2num>
  801602:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801605:	89 14 24             	mov    %edx,(%esp)
  801608:	50                   	push   %eax
  801609:	e8 21 ff ff ff       	call   80152f <fd_lookup>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 05                	js     80161c <fd_close+0x31>
	    || fd != fd2)
  801617:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80161a:	74 0d                	je     801629 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80161c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801620:	75 48                	jne    80166a <fd_close+0x7f>
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
  801627:	eb 41                	jmp    80166a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 36                	pushl  (%esi)
  801632:	e8 4e ff ff ff       	call   801585 <dev_lookup>
  801637:	89 c3                	mov    %eax,%ebx
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 1c                	js     80165c <fd_close+0x71>
		if (dev->dev_close)
  801640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801643:	8b 40 10             	mov    0x10(%eax),%eax
  801646:	85 c0                	test   %eax,%eax
  801648:	74 0d                	je     801657 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	56                   	push   %esi
  80164e:	ff d0                	call   *%eax
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb 05                	jmp    80165c <fd_close+0x71>
		else
			r = 0;
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	56                   	push   %esi
  801660:	6a 00                	push   $0x0
  801662:	e8 f3 f9 ff ff       	call   80105a <sys_page_unmap>
	return r;
  801667:	83 c4 10             	add    $0x10,%esp
}
  80166a:	89 d8                	mov    %ebx,%eax
  80166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 aa fe ff ff       	call   80152f <fd_lookup>
  801685:	83 c4 08             	add    $0x8,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 10                	js     80169c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	6a 01                	push   $0x1
  801691:	ff 75 f4             	pushl  -0xc(%ebp)
  801694:	e8 52 ff ff ff       	call   8015eb <fd_close>
  801699:	83 c4 10             	add    $0x10,%esp
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <close_all>:

void
close_all(void)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	53                   	push   %ebx
  8016ae:	e8 c0 ff ff ff       	call   801673 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b3:	43                   	inc    %ebx
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	83 fb 20             	cmp    $0x20,%ebx
  8016ba:	75 ee                	jne    8016aa <close_all+0xc>
		close(i);
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 2c             	sub    $0x2c,%esp
  8016ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 56 fe ff ff       	call   80152f <fd_lookup>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	83 c4 08             	add    $0x8,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	0f 88 c0 00 00 00    	js     8017a6 <dup+0xe5>
		return r;
	close(newfdnum);
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	57                   	push   %edi
  8016ea:	e8 84 ff ff ff       	call   801673 <close>

	newfd = INDEX2FD(newfdnum);
  8016ef:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016f5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016f8:	83 c4 04             	add    $0x4,%esp
  8016fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fe:	e8 a1 fd ff ff       	call   8014a4 <fd2data>
  801703:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801705:	89 34 24             	mov    %esi,(%esp)
  801708:	e8 97 fd ff ff       	call   8014a4 <fd2data>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801713:	89 d8                	mov    %ebx,%eax
  801715:	c1 e8 16             	shr    $0x16,%eax
  801718:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80171f:	a8 01                	test   $0x1,%al
  801721:	74 37                	je     80175a <dup+0x99>
  801723:	89 d8                	mov    %ebx,%eax
  801725:	c1 e8 0c             	shr    $0xc,%eax
  801728:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80172f:	f6 c2 01             	test   $0x1,%dl
  801732:	74 26                	je     80175a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801734:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	25 07 0e 00 00       	and    $0xe07,%eax
  801743:	50                   	push   %eax
  801744:	ff 75 d4             	pushl  -0x2c(%ebp)
  801747:	6a 00                	push   $0x0
  801749:	53                   	push   %ebx
  80174a:	6a 00                	push   $0x0
  80174c:	e8 e3 f8 ff ff       	call   801034 <sys_page_map>
  801751:	89 c3                	mov    %eax,%ebx
  801753:	83 c4 20             	add    $0x20,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 2d                	js     801787 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80175a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	c1 ea 0c             	shr    $0xc,%edx
  801762:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801772:	52                   	push   %edx
  801773:	56                   	push   %esi
  801774:	6a 00                	push   $0x0
  801776:	50                   	push   %eax
  801777:	6a 00                	push   $0x0
  801779:	e8 b6 f8 ff ff       	call   801034 <sys_page_map>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 20             	add    $0x20,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	79 1d                	jns    8017a4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	56                   	push   %esi
  80178b:	6a 00                	push   $0x0
  80178d:	e8 c8 f8 ff ff       	call   80105a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801792:	83 c4 08             	add    $0x8,%esp
  801795:	ff 75 d4             	pushl  -0x2c(%ebp)
  801798:	6a 00                	push   $0x0
  80179a:	e8 bb f8 ff ff       	call   80105a <sys_page_unmap>
	return r;
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	eb 02                	jmp    8017a6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017a4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017a6:	89 d8                	mov    %ebx,%eax
  8017a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5f                   	pop    %edi
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	53                   	push   %ebx
  8017b4:	83 ec 14             	sub    $0x14,%esp
  8017b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bd:	50                   	push   %eax
  8017be:	53                   	push   %ebx
  8017bf:	e8 6b fd ff ff       	call   80152f <fd_lookup>
  8017c4:	83 c4 08             	add    $0x8,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 67                	js     801832 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d5:	ff 30                	pushl  (%eax)
  8017d7:	e8 a9 fd ff ff       	call   801585 <dev_lookup>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 4f                	js     801832 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e6:	8b 50 08             	mov    0x8(%eax),%edx
  8017e9:	83 e2 03             	and    $0x3,%edx
  8017ec:	83 fa 01             	cmp    $0x1,%edx
  8017ef:	75 21                	jne    801812 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f1:	a1 04 50 80 00       	mov    0x805004,%eax
  8017f6:	8b 40 48             	mov    0x48(%eax),%eax
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	50                   	push   %eax
  8017fe:	68 71 33 80 00       	push   $0x803371
  801803:	e8 d0 ed ff ff       	call   8005d8 <cprintf>
		return -E_INVAL;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801810:	eb 20                	jmp    801832 <read+0x82>
	}
	if (!dev->dev_read)
  801812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801815:	8b 52 08             	mov    0x8(%edx),%edx
  801818:	85 d2                	test   %edx,%edx
  80181a:	74 11                	je     80182d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	ff 75 10             	pushl  0x10(%ebp)
  801822:	ff 75 0c             	pushl  0xc(%ebp)
  801825:	50                   	push   %eax
  801826:	ff d2                	call   *%edx
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	eb 05                	jmp    801832 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80182d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	8b 7d 08             	mov    0x8(%ebp),%edi
  801843:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801846:	85 f6                	test   %esi,%esi
  801848:	74 31                	je     80187b <readn+0x44>
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
  80184f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	89 f2                	mov    %esi,%edx
  801859:	29 c2                	sub    %eax,%edx
  80185b:	52                   	push   %edx
  80185c:	03 45 0c             	add    0xc(%ebp),%eax
  80185f:	50                   	push   %eax
  801860:	57                   	push   %edi
  801861:	e8 4a ff ff ff       	call   8017b0 <read>
		if (m < 0)
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 17                	js     801884 <readn+0x4d>
			return m;
		if (m == 0)
  80186d:	85 c0                	test   %eax,%eax
  80186f:	74 11                	je     801882 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801871:	01 c3                	add    %eax,%ebx
  801873:	89 d8                	mov    %ebx,%eax
  801875:	39 f3                	cmp    %esi,%ebx
  801877:	72 db                	jb     801854 <readn+0x1d>
  801879:	eb 09                	jmp    801884 <readn+0x4d>
  80187b:	b8 00 00 00 00       	mov    $0x0,%eax
  801880:	eb 02                	jmp    801884 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801882:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801884:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5f                   	pop    %edi
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	53                   	push   %ebx
  801890:	83 ec 14             	sub    $0x14,%esp
  801893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801896:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801899:	50                   	push   %eax
  80189a:	53                   	push   %ebx
  80189b:	e8 8f fc ff ff       	call   80152f <fd_lookup>
  8018a0:	83 c4 08             	add    $0x8,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 62                	js     801909 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ad:	50                   	push   %eax
  8018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b1:	ff 30                	pushl  (%eax)
  8018b3:	e8 cd fc ff ff       	call   801585 <dev_lookup>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	78 4a                	js     801909 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c6:	75 21                	jne    8018e9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c8:	a1 04 50 80 00       	mov    0x805004,%eax
  8018cd:	8b 40 48             	mov    0x48(%eax),%eax
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	50                   	push   %eax
  8018d5:	68 8d 33 80 00       	push   $0x80338d
  8018da:	e8 f9 ec ff ff       	call   8005d8 <cprintf>
		return -E_INVAL;
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018e7:	eb 20                	jmp    801909 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ef:	85 d2                	test   %edx,%edx
  8018f1:	74 11                	je     801904 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	ff 75 10             	pushl  0x10(%ebp)
  8018f9:	ff 75 0c             	pushl  0xc(%ebp)
  8018fc:	50                   	push   %eax
  8018fd:	ff d2                	call   *%edx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	eb 05                	jmp    801909 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801904:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801909:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <seek>:

int
seek(int fdnum, off_t offset)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801914:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	ff 75 08             	pushl  0x8(%ebp)
  80191b:	e8 0f fc ff ff       	call   80152f <fd_lookup>
  801920:	83 c4 08             	add    $0x8,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	78 0e                	js     801935 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801927:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80192a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	53                   	push   %ebx
  80193b:	83 ec 14             	sub    $0x14,%esp
  80193e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801941:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	53                   	push   %ebx
  801946:	e8 e4 fb ff ff       	call   80152f <fd_lookup>
  80194b:	83 c4 08             	add    $0x8,%esp
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 5f                	js     8019b1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801958:	50                   	push   %eax
  801959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195c:	ff 30                	pushl  (%eax)
  80195e:	e8 22 fc ff ff       	call   801585 <dev_lookup>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	78 47                	js     8019b1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801971:	75 21                	jne    801994 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801973:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801978:	8b 40 48             	mov    0x48(%eax),%eax
  80197b:	83 ec 04             	sub    $0x4,%esp
  80197e:	53                   	push   %ebx
  80197f:	50                   	push   %eax
  801980:	68 50 33 80 00       	push   $0x803350
  801985:	e8 4e ec ff ff       	call   8005d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801992:	eb 1d                	jmp    8019b1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801994:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801997:	8b 52 18             	mov    0x18(%edx),%edx
  80199a:	85 d2                	test   %edx,%edx
  80199c:	74 0e                	je     8019ac <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	50                   	push   %eax
  8019a5:	ff d2                	call   *%edx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	eb 05                	jmp    8019b1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	53                   	push   %ebx
  8019ba:	83 ec 14             	sub    $0x14,%esp
  8019bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c3:	50                   	push   %eax
  8019c4:	ff 75 08             	pushl  0x8(%ebp)
  8019c7:	e8 63 fb ff ff       	call   80152f <fd_lookup>
  8019cc:	83 c4 08             	add    $0x8,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 52                	js     801a25 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d3:	83 ec 08             	sub    $0x8,%esp
  8019d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019dd:	ff 30                	pushl  (%eax)
  8019df:	e8 a1 fb ff ff       	call   801585 <dev_lookup>
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 3a                	js     801a25 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8019eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f2:	74 2c                	je     801a20 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019fe:	00 00 00 
	stat->st_isdir = 0;
  801a01:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a08:	00 00 00 
	stat->st_dev = dev;
  801a0b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	53                   	push   %ebx
  801a15:	ff 75 f0             	pushl  -0x10(%ebp)
  801a18:	ff 50 14             	call   *0x14(%eax)
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb 05                	jmp    801a25 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a20:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	6a 00                	push   $0x0
  801a34:	ff 75 08             	pushl  0x8(%ebp)
  801a37:	e8 78 01 00 00       	call   801bb4 <open>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 1b                	js     801a60 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a45:	83 ec 08             	sub    $0x8,%esp
  801a48:	ff 75 0c             	pushl  0xc(%ebp)
  801a4b:	50                   	push   %eax
  801a4c:	e8 65 ff ff ff       	call   8019b6 <fstat>
  801a51:	89 c6                	mov    %eax,%esi
	close(fd);
  801a53:	89 1c 24             	mov    %ebx,(%esp)
  801a56:	e8 18 fc ff ff       	call   801673 <close>
	return r;
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	89 f3                	mov    %esi,%ebx
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    
  801a69:	00 00                	add    %al,(%eax)
	...

00801a6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a75:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a7c:	75 12                	jne    801a90 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	6a 01                	push   $0x1
  801a83:	e8 7a 0f 00 00       	call   802a02 <ipc_find_env>
  801a88:	a3 00 50 80 00       	mov    %eax,0x805000
  801a8d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a90:	6a 07                	push   $0x7
  801a92:	68 00 60 80 00       	push   $0x806000
  801a97:	53                   	push   %ebx
  801a98:	ff 35 00 50 80 00    	pushl  0x805000
  801a9e:	e8 0a 0f 00 00       	call   8029ad <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801aa3:	83 c4 0c             	add    $0xc,%esp
  801aa6:	6a 00                	push   $0x0
  801aa8:	56                   	push   %esi
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 88 0e 00 00       	call   802938 <ipc_recv>
}
  801ab0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab3:	5b                   	pop    %ebx
  801ab4:	5e                   	pop    %esi
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801acc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad6:	e8 91 ff ff ff       	call   801a6c <fsipc>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 2c                	js     801b0b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	68 00 60 80 00       	push   $0x806000
  801ae7:	53                   	push   %ebx
  801ae8:	e8 a1 f0 ff ff       	call   800b8e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aed:	a1 80 60 80 00       	mov    0x806080,%eax
  801af2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af8:	a1 84 60 80 00       	mov    0x806084,%eax
  801afd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
  801b26:	b8 06 00 00 00       	mov    $0x6,%eax
  801b2b:	e8 3c ff ff ff       	call   801a6c <fsipc>
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	56                   	push   %esi
  801b36:	53                   	push   %ebx
  801b37:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b45:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b50:	b8 03 00 00 00       	mov    $0x3,%eax
  801b55:	e8 12 ff ff ff       	call   801a6c <fsipc>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 4b                	js     801bab <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b60:	39 c6                	cmp    %eax,%esi
  801b62:	73 16                	jae    801b7a <devfile_read+0x48>
  801b64:	68 bc 33 80 00       	push   $0x8033bc
  801b69:	68 c3 33 80 00       	push   $0x8033c3
  801b6e:	6a 7d                	push   $0x7d
  801b70:	68 d8 33 80 00       	push   $0x8033d8
  801b75:	e8 86 e9 ff ff       	call   800500 <_panic>
	assert(r <= PGSIZE);
  801b7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b7f:	7e 16                	jle    801b97 <devfile_read+0x65>
  801b81:	68 e3 33 80 00       	push   $0x8033e3
  801b86:	68 c3 33 80 00       	push   $0x8033c3
  801b8b:	6a 7e                	push   $0x7e
  801b8d:	68 d8 33 80 00       	push   $0x8033d8
  801b92:	e8 69 e9 ff ff       	call   800500 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	50                   	push   %eax
  801b9b:	68 00 60 80 00       	push   $0x806000
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	e8 a7 f1 ff ff       	call   800d4f <memmove>
	return r;
  801ba8:	83 c4 10             	add    $0x10,%esp
}
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 1c             	sub    $0x1c,%esp
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bbf:	56                   	push   %esi
  801bc0:	e8 77 ef ff ff       	call   800b3c <strlen>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bcd:	7f 65                	jg     801c34 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 e1 f8 ff ff       	call   8014bc <fd_alloc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	78 55                	js     801c39 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	56                   	push   %esi
  801be8:	68 00 60 80 00       	push   $0x806000
  801bed:	e8 9c ef ff ff       	call   800b8e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf5:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bfd:	b8 01 00 00 00       	mov    $0x1,%eax
  801c02:	e8 65 fe ff ff       	call   801a6c <fsipc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	79 12                	jns    801c22 <open+0x6e>
		fd_close(fd, 0);
  801c10:	83 ec 08             	sub    $0x8,%esp
  801c13:	6a 00                	push   $0x0
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	e8 ce f9 ff ff       	call   8015eb <fd_close>
		return r;
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	eb 17                	jmp    801c39 <open+0x85>
	}

	return fd2num(fd);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	ff 75 f4             	pushl  -0xc(%ebp)
  801c28:	e8 67 f8 ff ff       	call   801494 <fd2num>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	eb 05                	jmp    801c39 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c34:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    
	...

00801c44 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	57                   	push   %edi
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 1c             	sub    $0x1c,%esp
  801c4d:	89 c7                	mov    %eax,%edi
  801c4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c55:	89 d0                	mov    %edx,%eax
  801c57:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c5c:	74 0c                	je     801c6a <map_segment+0x26>
		va -= i;
  801c5e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  801c61:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801c64:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801c67:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c6a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c6e:	0f 84 ee 00 00 00    	je     801d62 <map_segment+0x11e>
  801c74:	be 00 00 00 00       	mov    $0x0,%esi
  801c79:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801c7e:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801c81:	77 20                	ja     801ca3 <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	ff 75 14             	pushl  0x14(%ebp)
  801c89:	03 75 e4             	add    -0x1c(%ebp),%esi
  801c8c:	56                   	push   %esi
  801c8d:	57                   	push   %edi
  801c8e:	e8 7d f3 ff ff       	call   801010 <sys_page_alloc>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 c0                	test   %eax,%eax
  801c98:	0f 89 ac 00 00 00    	jns    801d4a <map_segment+0x106>
  801c9e:	e9 c4 00 00 00       	jmp    801d67 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	6a 07                	push   $0x7
  801ca8:	68 00 00 40 00       	push   $0x400000
  801cad:	6a 00                	push   $0x0
  801caf:	e8 5c f3 ff ff       	call   801010 <sys_page_alloc>
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 a8 00 00 00    	js     801d67 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cbf:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cc8:	50                   	push   %eax
  801cc9:	ff 75 08             	pushl  0x8(%ebp)
  801ccc:	e8 3d fc ff ff       	call   80190e <seek>
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	0f 88 8b 00 00 00    	js     801d67 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cdc:	83 ec 04             	sub    $0x4,%esp
  801cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce2:	29 f0                	sub    %esi,%eax
  801ce4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ce9:	76 05                	jbe    801cf0 <map_segment+0xac>
  801ceb:	b8 00 10 00 00       	mov    $0x1000,%eax
  801cf0:	50                   	push   %eax
  801cf1:	68 00 00 40 00       	push   $0x400000
  801cf6:	ff 75 08             	pushl  0x8(%ebp)
  801cf9:	e8 39 fb ff ff       	call   801837 <readn>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 62                	js     801d67 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d05:	83 ec 0c             	sub    $0xc,%esp
  801d08:	ff 75 14             	pushl  0x14(%ebp)
  801d0b:	03 75 e4             	add    -0x1c(%ebp),%esi
  801d0e:	56                   	push   %esi
  801d0f:	57                   	push   %edi
  801d10:	68 00 00 40 00       	push   $0x400000
  801d15:	6a 00                	push   $0x0
  801d17:	e8 18 f3 ff ff       	call   801034 <sys_page_map>
  801d1c:	83 c4 20             	add    $0x20,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	79 15                	jns    801d38 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  801d23:	50                   	push   %eax
  801d24:	68 ef 33 80 00       	push   $0x8033ef
  801d29:	68 84 01 00 00       	push   $0x184
  801d2e:	68 0c 34 80 00       	push   $0x80340c
  801d33:	e8 c8 e7 ff ff       	call   800500 <_panic>
			sys_page_unmap(0, UTEMP);
  801d38:	83 ec 08             	sub    $0x8,%esp
  801d3b:	68 00 00 40 00       	push   $0x400000
  801d40:	6a 00                	push   $0x0
  801d42:	e8 13 f3 ff ff       	call   80105a <sys_page_unmap>
  801d47:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d4a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d50:	89 de                	mov    %ebx,%esi
  801d52:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801d55:	0f 87 23 ff ff ff    	ja     801c7e <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d60:	eb 05                	jmp    801d67 <map_segment+0x123>
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	57                   	push   %edi
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	83 ec 2c             	sub    $0x2c,%esp
  801d78:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d7b:	89 d7                	mov    %edx,%edi
  801d7d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d80:	8b 02                	mov    (%edx),%eax
  801d82:	85 c0                	test   %eax,%eax
  801d84:	74 31                	je     801db7 <init_stack+0x48>
  801d86:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d8b:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	50                   	push   %eax
  801d94:	e8 a3 ed ff ff       	call   800b3c <strlen>
  801d99:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d9d:	43                   	inc    %ebx
  801d9e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801da5:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	75 e1                	jne    801d90 <init_stack+0x21>
  801daf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801db2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801db5:	eb 18                	jmp    801dcf <init_stack+0x60>
  801db7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801dbe:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801dca:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dcf:	f7 de                	neg    %esi
  801dd1:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801dd7:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dda:	89 f2                	mov    %esi,%edx
  801ddc:	83 e2 fc             	and    $0xfffffffc,%edx
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	f7 d0                	not    %eax
  801de3:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801de6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801de9:	83 e8 08             	sub    $0x8,%eax
  801dec:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801df1:	0f 86 fb 00 00 00    	jbe    801ef2 <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	6a 07                	push   $0x7
  801dfc:	68 00 00 40 00       	push   $0x400000
  801e01:	6a 00                	push   $0x0
  801e03:	e8 08 f2 ff ff       	call   801010 <sys_page_alloc>
  801e08:	89 c6                	mov    %eax,%esi
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 e9 00 00 00    	js     801efe <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e15:	85 db                	test   %ebx,%ebx
  801e17:	7e 3e                	jle    801e57 <init_stack+0xe8>
  801e19:	be 00 00 00 00       	mov    $0x0,%esi
  801e1e:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801e21:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801e24:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801e2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e2d:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e30:	83 ec 08             	sub    $0x8,%esp
  801e33:	ff 34 b7             	pushl  (%edi,%esi,4)
  801e36:	53                   	push   %ebx
  801e37:	e8 52 ed ff ff       	call   800b8e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e3c:	83 c4 04             	add    $0x4,%esp
  801e3f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801e42:	e8 f5 ec ff ff       	call   800b3c <strlen>
  801e47:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e4b:	46                   	inc    %esi
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801e52:	7c d0                	jl     801e24 <init_stack+0xb5>
  801e54:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e5a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801e5d:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e64:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801e6b:	74 19                	je     801e86 <init_stack+0x117>
  801e6d:	68 7c 34 80 00       	push   $0x80347c
  801e72:	68 c3 33 80 00       	push   $0x8033c3
  801e77:	68 51 01 00 00       	push   $0x151
  801e7c:	68 0c 34 80 00       	push   $0x80340c
  801e81:	e8 7a e6 ff ff       	call   800500 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e89:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e91:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801e94:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e97:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ea1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801ea4:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	6a 07                	push   $0x7
  801eab:	ff 75 08             	pushl  0x8(%ebp)
  801eae:	ff 75 d8             	pushl  -0x28(%ebp)
  801eb1:	68 00 00 40 00       	push   $0x400000
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 77 f1 ff ff       	call   801034 <sys_page_map>
  801ebd:	89 c6                	mov    %eax,%esi
  801ebf:	83 c4 20             	add    $0x20,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 18                	js     801ede <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	68 00 00 40 00       	push   $0x400000
  801ece:	6a 00                	push   $0x0
  801ed0:	e8 85 f1 ff ff       	call   80105a <sys_page_unmap>
  801ed5:	89 c6                	mov    %eax,%esi
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	79 1b                	jns    801ef9 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	68 00 00 40 00       	push   $0x400000
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 6d f1 ff ff       	call   80105a <sys_page_unmap>
	return r;
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	eb 0c                	jmp    801efe <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ef2:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801ef7:	eb 05                	jmp    801efe <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801ef9:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801efe:	89 f0                	mov    %esi,%eax
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801f14:	6a 00                	push   $0x0
  801f16:	ff 75 08             	pushl  0x8(%ebp)
  801f19:	e8 96 fc ff ff       	call   801bb4 <open>
  801f1e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 45 02 00 00    	js     802174 <spawn+0x26c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f2f:	83 ec 04             	sub    $0x4,%esp
  801f32:	68 00 02 00 00       	push   $0x200
  801f37:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801f3d:	50                   	push   %eax
  801f3e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f44:	e8 ee f8 ff ff       	call   801837 <readn>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f51:	75 0c                	jne    801f5f <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801f53:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f5a:	45 4c 46 
  801f5d:	74 38                	je     801f97 <spawn+0x8f>
		close(fd);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f68:	e8 06 f7 ff ff       	call   801673 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f6d:	83 c4 0c             	add    $0xc,%esp
  801f70:	68 7f 45 4c 46       	push   $0x464c457f
  801f75:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801f7b:	68 18 34 80 00       	push   $0x803418
  801f80:	e8 53 e6 ff ff       	call   8005d8 <cprintf>
		return -E_NOT_EXEC;
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801f8f:	ff ff ff 
  801f92:	e9 f1 01 00 00       	jmp    802188 <spawn+0x280>
  801f97:	ba 07 00 00 00       	mov    $0x7,%edx
  801f9c:	89 d0                	mov    %edx,%eax
  801f9e:	cd 30                	int    $0x30
  801fa0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801fa6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801fac:	85 c0                	test   %eax,%eax
  801fae:	0f 88 d4 01 00 00    	js     802188 <spawn+0x280>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801fb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801fb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801fc0:	c1 e0 07             	shl    $0x7,%eax
  801fc3:	29 d0                	sub    %edx,%eax
  801fc5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801fcb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801fd1:	b9 11 00 00 00       	mov    $0x11,%ecx
  801fd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801fd8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801fde:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801fed:	68 00 d0 bf ee       	push   $0xeebfd000
  801ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ffb:	e8 6f fd ff ff       	call   801d6f <init_stack>
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 77 01 00 00    	js     802182 <spawn+0x27a>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80200b:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802011:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802018:	00 
  802019:	74 5d                	je     802078 <spawn+0x170>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80201b:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802022:	be 00 00 00 00       	mov    $0x0,%esi
  802027:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  80202d:	83 3b 01             	cmpl   $0x1,(%ebx)
  802030:	75 35                	jne    802067 <spawn+0x15f>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802032:	8b 43 18             	mov    0x18(%ebx),%eax
  802035:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802038:	83 f8 01             	cmp    $0x1,%eax
  80203b:	19 c0                	sbb    %eax,%eax
  80203d:	83 e0 fe             	and    $0xfffffffe,%eax
  802040:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802043:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802046:	8b 53 08             	mov    0x8(%ebx),%edx
  802049:	50                   	push   %eax
  80204a:	ff 73 04             	pushl  0x4(%ebx)
  80204d:	ff 73 10             	pushl  0x10(%ebx)
  802050:	57                   	push   %edi
  802051:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802057:	e8 e8 fb ff ff       	call   801c44 <map_segment>
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	0f 88 e4 00 00 00    	js     80214b <spawn+0x243>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802067:	46                   	inc    %esi
  802068:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80206f:	39 f0                	cmp    %esi,%eax
  802071:	7e 05                	jle    802078 <spawn+0x170>
  802073:	83 c3 20             	add    $0x20,%ebx
  802076:	eb b5                	jmp    80202d <spawn+0x125>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802078:	83 ec 0c             	sub    $0xc,%esp
  80207b:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802081:	e8 ed f5 ff ff       	call   801673 <close>
  802086:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  802089:	bb 00 00 00 00       	mov    $0x0,%ebx
  80208e:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  802094:	89 d8                	mov    %ebx,%eax
  802096:	c1 e8 16             	shr    $0x16,%eax
  802099:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020a0:	a8 01                	test   $0x1,%al
  8020a2:	74 3e                	je     8020e2 <spawn+0x1da>
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	c1 e8 0c             	shr    $0xc,%eax
  8020a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020b0:	f6 c2 01             	test   $0x1,%dl
  8020b3:	74 2d                	je     8020e2 <spawn+0x1da>
  8020b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020bc:	f6 c6 04             	test   $0x4,%dh
  8020bf:	74 21                	je     8020e2 <spawn+0x1da>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  8020c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020c8:	83 ec 0c             	sub    $0xc,%esp
  8020cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8020d0:	50                   	push   %eax
  8020d1:	53                   	push   %ebx
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 59 ef ff ff       	call   801034 <sys_page_map>
        if (r < 0) return r;
  8020db:	83 c4 20             	add    $0x20,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 13                	js     8020f5 <spawn+0x1ed>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8020e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e8:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020ee:	75 a4                	jne    802094 <spawn+0x18c>
  8020f0:	e9 a1 00 00 00       	jmp    802196 <spawn+0x28e>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8020f5:	50                   	push   %eax
  8020f6:	68 32 34 80 00       	push   $0x803432
  8020fb:	68 85 00 00 00       	push   $0x85
  802100:	68 0c 34 80 00       	push   $0x80340c
  802105:	e8 f6 e3 ff ff       	call   800500 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80210a:	50                   	push   %eax
  80210b:	68 48 34 80 00       	push   $0x803448
  802110:	68 88 00 00 00       	push   $0x88
  802115:	68 0c 34 80 00       	push   $0x80340c
  80211a:	e8 e1 e3 ff ff       	call   800500 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80211f:	83 ec 08             	sub    $0x8,%esp
  802122:	6a 02                	push   $0x2
  802124:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80212a:	e8 4e ef ff ff       	call   80107d <sys_env_set_status>
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	79 52                	jns    802188 <spawn+0x280>
		panic("sys_env_set_status: %e", r);
  802136:	50                   	push   %eax
  802137:	68 62 34 80 00       	push   $0x803462
  80213c:	68 8b 00 00 00       	push   $0x8b
  802141:	68 0c 34 80 00       	push   $0x80340c
  802146:	e8 b5 e3 ff ff       	call   800500 <_panic>
  80214b:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  80214d:	83 ec 0c             	sub    $0xc,%esp
  802150:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802156:	e8 48 ee ff ff       	call   800fa3 <sys_env_destroy>
	close(fd);
  80215b:	83 c4 04             	add    $0x4,%esp
  80215e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802164:	e8 0a f5 ff ff       	call   801673 <close>
	return r;
  802169:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80216c:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802172:	eb 14                	jmp    802188 <spawn+0x280>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802174:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80217a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802180:	eb 06                	jmp    802188 <spawn+0x280>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  802182:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802188:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80218e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	c9                   	leave  
  802195:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802196:	83 ec 08             	sub    $0x8,%esp
  802199:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80219f:	50                   	push   %eax
  8021a0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8021a6:	e8 f5 ee ff ff       	call   8010a0 <sys_env_set_trapframe>
  8021ab:	83 c4 10             	add    $0x10,%esp
  8021ae:	85 c0                	test   %eax,%eax
  8021b0:	0f 89 69 ff ff ff    	jns    80211f <spawn+0x217>
  8021b6:	e9 4f ff ff ff       	jmp    80210a <spawn+0x202>

008021bb <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	57                   	push   %edi
  8021bf:	56                   	push   %esi
  8021c0:	53                   	push   %ebx
  8021c1:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  8021c7:	6a 00                	push   $0x0
  8021c9:	ff 75 08             	pushl  0x8(%ebp)
  8021cc:	e8 e3 f9 ff ff       	call   801bb4 <open>
  8021d1:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	0f 88 a9 01 00 00    	js     80238b <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  8021e2:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8021e8:	83 ec 04             	sub    $0x4,%esp
  8021eb:	68 00 02 00 00       	push   $0x200
  8021f0:	57                   	push   %edi
  8021f1:	50                   	push   %eax
  8021f2:	e8 40 f6 ff ff       	call   801837 <readn>
  8021f7:	83 c4 10             	add    $0x10,%esp
  8021fa:	3d 00 02 00 00       	cmp    $0x200,%eax
  8021ff:	75 0c                	jne    80220d <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  802201:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802208:	45 4c 46 
  80220b:	74 34                	je     802241 <exec+0x86>
		close(fd);
  80220d:	83 ec 0c             	sub    $0xc,%esp
  802210:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802216:	e8 58 f4 ff ff       	call   801673 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80221b:	83 c4 0c             	add    $0xc,%esp
  80221e:	68 7f 45 4c 46       	push   $0x464c457f
  802223:	ff 37                	pushl  (%edi)
  802225:	68 18 34 80 00       	push   $0x803418
  80222a:	e8 a9 e3 ff ff       	call   8005d8 <cprintf>
		return -E_NOT_EXEC;
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  802239:	ff ff ff 
  80223c:	e9 4a 01 00 00       	jmp    80238b <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802241:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802244:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  802249:	0f 84 8b 00 00 00    	je     8022da <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80224f:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  802256:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  80225d:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802260:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  802265:	83 3b 01             	cmpl   $0x1,(%ebx)
  802268:	75 62                	jne    8022cc <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80226a:	8b 43 18             	mov    0x18(%ebx),%eax
  80226d:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802270:	83 f8 01             	cmp    $0x1,%eax
  802273:	19 c0                	sbb    %eax,%eax
  802275:	83 e0 fe             	and    $0xfffffffe,%eax
  802278:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  80227b:	8b 4b 14             	mov    0x14(%ebx),%ecx
  80227e:	8b 53 08             	mov    0x8(%ebx),%edx
  802281:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802287:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  80228d:	50                   	push   %eax
  80228e:	ff 73 04             	pushl  0x4(%ebx)
  802291:	ff 73 10             	pushl  0x10(%ebx)
  802294:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
  80229f:	e8 a0 f9 ff ff       	call   801c44 <map_segment>
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	0f 88 a3 00 00 00    	js     802352 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  8022af:	8b 53 14             	mov    0x14(%ebx),%edx
  8022b2:	8b 43 08             	mov    0x8(%ebx),%eax
  8022b5:	25 ff 0f 00 00       	and    $0xfff,%eax
  8022ba:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  8022c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8022c6:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8022cc:	46                   	inc    %esi
  8022cd:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  8022d1:	39 f0                	cmp    %esi,%eax
  8022d3:	7e 0f                	jle    8022e4 <exec+0x129>
  8022d5:	83 c3 20             	add    $0x20,%ebx
  8022d8:	eb 8b                	jmp    802265 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  8022da:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  8022e1:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  8022e4:	83 ec 0c             	sub    $0xc,%esp
  8022e7:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  8022ed:	e8 81 f3 ff ff       	call   801673 <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  8022f2:	83 c4 04             	add    $0x4,%esp
  8022f5:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  8022fb:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  802301:	8b 55 0c             	mov    0xc(%ebp),%edx
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
  802309:	e8 61 fa ff ff       	call   801d6f <init_stack>
  80230e:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	78 70                	js     80238b <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  80231b:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  80231f:	50                   	push   %eax
  802320:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802326:	03 47 1c             	add    0x1c(%edi),%eax
  802329:	50                   	push   %eax
  80232a:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  802330:	ff 77 18             	pushl  0x18(%edi)
  802333:	e8 18 ee ff ff       	call   801150 <sys_exec>
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	85 c0                	test   %eax,%eax
  80233d:	79 42                	jns    802381 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  80233f:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802345:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  80234b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  802350:	eb 0c                	jmp    80235e <exec+0x1a3>
  802352:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  802358:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80235e:	83 ec 0c             	sub    $0xc,%esp
  802361:	6a 00                	push   $0x0
  802363:	e8 3b ec ff ff       	call   800fa3 <sys_env_destroy>
	close(fd);
  802368:	89 1c 24             	mov    %ebx,(%esp)
  80236b:	e8 03 f3 ff ff       	call   801673 <close>
	return r;
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  802379:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  80237f:	eb 0a                	jmp    80238b <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  802381:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  802388:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  80238b:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	c9                   	leave  
  802398:	c3                   	ret    

00802399 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	56                   	push   %esi
  80239d:	53                   	push   %ebx
  80239e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8023a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023a8:	74 5f                	je     802409 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8023aa:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8023af:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8023b0:	89 c2                	mov    %eax,%edx
  8023b2:	83 c0 04             	add    $0x4,%eax
  8023b5:	83 3a 00             	cmpl   $0x0,(%edx)
  8023b8:	75 f5                	jne    8023af <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023ba:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8023c1:	83 e0 f0             	and    $0xfffffff0,%eax
  8023c4:	29 c4                	sub    %eax,%esp
  8023c6:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8023ca:	83 e0 f0             	and    $0xfffffff0,%eax
  8023cd:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8023cf:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8023d1:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8023d8:	00 

	va_start(vl, arg0);
  8023d9:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8023dc:	89 ce                	mov    %ecx,%esi
  8023de:	85 c9                	test   %ecx,%ecx
  8023e0:	74 14                	je     8023f6 <execl+0x5d>
  8023e2:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8023e7:	40                   	inc    %eax
  8023e8:	89 d1                	mov    %edx,%ecx
  8023ea:	83 c2 04             	add    $0x4,%edx
  8023ed:	8b 09                	mov    (%ecx),%ecx
  8023ef:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023f2:	39 f0                	cmp    %esi,%eax
  8023f4:	72 f1                	jb     8023e7 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  8023f6:	83 ec 08             	sub    $0x8,%esp
  8023f9:	53                   	push   %ebx
  8023fa:	ff 75 08             	pushl  0x8(%ebp)
  8023fd:	e8 b9 fd ff ff       	call   8021bb <exec>
}
  802402:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802405:	5b                   	pop    %ebx
  802406:	5e                   	pop    %esi
  802407:	c9                   	leave  
  802408:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802409:	83 ec 20             	sub    $0x20,%esp
  80240c:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802410:	83 e0 f0             	and    $0xfffffff0,%eax
  802413:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802415:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802417:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80241e:	eb d6                	jmp    8023f6 <execl+0x5d>

00802420 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	56                   	push   %esi
  802424:	53                   	push   %ebx
  802425:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802428:	8d 45 14             	lea    0x14(%ebp),%eax
  80242b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80242f:	74 5f                	je     802490 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802431:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802436:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802437:	89 c2                	mov    %eax,%edx
  802439:	83 c0 04             	add    $0x4,%eax
  80243c:	83 3a 00             	cmpl   $0x0,(%edx)
  80243f:	75 f5                	jne    802436 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802441:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802448:	83 e0 f0             	and    $0xfffffff0,%eax
  80244b:	29 c4                	sub    %eax,%esp
  80244d:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802451:	83 e0 f0             	and    $0xfffffff0,%eax
  802454:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802456:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802458:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  80245f:	00 

	va_start(vl, arg0);
  802460:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802463:	89 ce                	mov    %ecx,%esi
  802465:	85 c9                	test   %ecx,%ecx
  802467:	74 14                	je     80247d <spawnl+0x5d>
  802469:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80246e:	40                   	inc    %eax
  80246f:	89 d1                	mov    %edx,%ecx
  802471:	83 c2 04             	add    $0x4,%edx
  802474:	8b 09                	mov    (%ecx),%ecx
  802476:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802479:	39 f0                	cmp    %esi,%eax
  80247b:	72 f1                	jb     80246e <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80247d:	83 ec 08             	sub    $0x8,%esp
  802480:	53                   	push   %ebx
  802481:	ff 75 08             	pushl  0x8(%ebp)
  802484:	e8 7f fa ff ff       	call   801f08 <spawn>
}
  802489:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5e                   	pop    %esi
  80248e:	c9                   	leave  
  80248f:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802490:	83 ec 20             	sub    $0x20,%esp
  802493:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802497:	83 e0 f0             	and    $0xfffffff0,%eax
  80249a:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80249c:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80249e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8024a5:	eb d6                	jmp    80247d <spawnl+0x5d>
	...

008024a8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024a8:	55                   	push   %ebp
  8024a9:	89 e5                	mov    %esp,%ebp
  8024ab:	56                   	push   %esi
  8024ac:	53                   	push   %ebx
  8024ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024b0:	83 ec 0c             	sub    $0xc,%esp
  8024b3:	ff 75 08             	pushl  0x8(%ebp)
  8024b6:	e8 e9 ef ff ff       	call   8014a4 <fd2data>
  8024bb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8024bd:	83 c4 08             	add    $0x8,%esp
  8024c0:	68 a2 34 80 00       	push   $0x8034a2
  8024c5:	56                   	push   %esi
  8024c6:	e8 c3 e6 ff ff       	call   800b8e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8024ce:	2b 03                	sub    (%ebx),%eax
  8024d0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8024d6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8024dd:	00 00 00 
	stat->st_dev = &devpipe;
  8024e0:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8024e7:	40 80 00 
	return 0;
}
  8024ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024f2:	5b                   	pop    %ebx
  8024f3:	5e                   	pop    %esi
  8024f4:	c9                   	leave  
  8024f5:	c3                   	ret    

008024f6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	53                   	push   %ebx
  8024fa:	83 ec 0c             	sub    $0xc,%esp
  8024fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802500:	53                   	push   %ebx
  802501:	6a 00                	push   $0x0
  802503:	e8 52 eb ff ff       	call   80105a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802508:	89 1c 24             	mov    %ebx,(%esp)
  80250b:	e8 94 ef ff ff       	call   8014a4 <fd2data>
  802510:	83 c4 08             	add    $0x8,%esp
  802513:	50                   	push   %eax
  802514:	6a 00                	push   $0x0
  802516:	e8 3f eb ff ff       	call   80105a <sys_page_unmap>
}
  80251b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80251e:	c9                   	leave  
  80251f:	c3                   	ret    

00802520 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	57                   	push   %edi
  802524:	56                   	push   %esi
  802525:	53                   	push   %ebx
  802526:	83 ec 1c             	sub    $0x1c,%esp
  802529:	89 c7                	mov    %eax,%edi
  80252b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80252e:	a1 04 50 80 00       	mov    0x805004,%eax
  802533:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802536:	83 ec 0c             	sub    $0xc,%esp
  802539:	57                   	push   %edi
  80253a:	e8 21 05 00 00       	call   802a60 <pageref>
  80253f:	89 c6                	mov    %eax,%esi
  802541:	83 c4 04             	add    $0x4,%esp
  802544:	ff 75 e4             	pushl  -0x1c(%ebp)
  802547:	e8 14 05 00 00       	call   802a60 <pageref>
  80254c:	83 c4 10             	add    $0x10,%esp
  80254f:	39 c6                	cmp    %eax,%esi
  802551:	0f 94 c0             	sete   %al
  802554:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802557:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80255d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802560:	39 cb                	cmp    %ecx,%ebx
  802562:	75 08                	jne    80256c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	c9                   	leave  
  80256b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80256c:	83 f8 01             	cmp    $0x1,%eax
  80256f:	75 bd                	jne    80252e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802571:	8b 42 58             	mov    0x58(%edx),%eax
  802574:	6a 01                	push   $0x1
  802576:	50                   	push   %eax
  802577:	53                   	push   %ebx
  802578:	68 a9 34 80 00       	push   $0x8034a9
  80257d:	e8 56 e0 ff ff       	call   8005d8 <cprintf>
  802582:	83 c4 10             	add    $0x10,%esp
  802585:	eb a7                	jmp    80252e <_pipeisclosed+0xe>

00802587 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	57                   	push   %edi
  80258b:	56                   	push   %esi
  80258c:	53                   	push   %ebx
  80258d:	83 ec 28             	sub    $0x28,%esp
  802590:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802593:	56                   	push   %esi
  802594:	e8 0b ef ff ff       	call   8014a4 <fd2data>
  802599:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80259b:	83 c4 10             	add    $0x10,%esp
  80259e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025a2:	75 4a                	jne    8025ee <devpipe_write+0x67>
  8025a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8025a9:	eb 56                	jmp    802601 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8025ab:	89 da                	mov    %ebx,%edx
  8025ad:	89 f0                	mov    %esi,%eax
  8025af:	e8 6c ff ff ff       	call   802520 <_pipeisclosed>
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	75 4d                	jne    802605 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8025b8:	e8 2c ea ff ff       	call   800fe9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8025c0:	8b 13                	mov    (%ebx),%edx
  8025c2:	83 c2 20             	add    $0x20,%edx
  8025c5:	39 d0                	cmp    %edx,%eax
  8025c7:	73 e2                	jae    8025ab <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025c9:	89 c2                	mov    %eax,%edx
  8025cb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8025d1:	79 05                	jns    8025d8 <devpipe_write+0x51>
  8025d3:	4a                   	dec    %edx
  8025d4:	83 ca e0             	or     $0xffffffe0,%edx
  8025d7:	42                   	inc    %edx
  8025d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025db:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8025de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025e2:	40                   	inc    %eax
  8025e3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025e6:	47                   	inc    %edi
  8025e7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8025ea:	77 07                	ja     8025f3 <devpipe_write+0x6c>
  8025ec:	eb 13                	jmp    802601 <devpipe_write+0x7a>
  8025ee:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8025f6:	8b 13                	mov    (%ebx),%edx
  8025f8:	83 c2 20             	add    $0x20,%edx
  8025fb:	39 d0                	cmp    %edx,%eax
  8025fd:	73 ac                	jae    8025ab <devpipe_write+0x24>
  8025ff:	eb c8                	jmp    8025c9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802601:	89 f8                	mov    %edi,%eax
  802603:	eb 05                	jmp    80260a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802605:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80260a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	c9                   	leave  
  802611:	c3                   	ret    

00802612 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802612:	55                   	push   %ebp
  802613:	89 e5                	mov    %esp,%ebp
  802615:	57                   	push   %edi
  802616:	56                   	push   %esi
  802617:	53                   	push   %ebx
  802618:	83 ec 18             	sub    $0x18,%esp
  80261b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80261e:	57                   	push   %edi
  80261f:	e8 80 ee ff ff       	call   8014a4 <fd2data>
  802624:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802626:	83 c4 10             	add    $0x10,%esp
  802629:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80262d:	75 44                	jne    802673 <devpipe_read+0x61>
  80262f:	be 00 00 00 00       	mov    $0x0,%esi
  802634:	eb 4f                	jmp    802685 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802636:	89 f0                	mov    %esi,%eax
  802638:	eb 54                	jmp    80268e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80263a:	89 da                	mov    %ebx,%edx
  80263c:	89 f8                	mov    %edi,%eax
  80263e:	e8 dd fe ff ff       	call   802520 <_pipeisclosed>
  802643:	85 c0                	test   %eax,%eax
  802645:	75 42                	jne    802689 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802647:	e8 9d e9 ff ff       	call   800fe9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80264c:	8b 03                	mov    (%ebx),%eax
  80264e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802651:	74 e7                	je     80263a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802653:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802658:	79 05                	jns    80265f <devpipe_read+0x4d>
  80265a:	48                   	dec    %eax
  80265b:	83 c8 e0             	or     $0xffffffe0,%eax
  80265e:	40                   	inc    %eax
  80265f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802663:	8b 55 0c             	mov    0xc(%ebp),%edx
  802666:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802669:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80266b:	46                   	inc    %esi
  80266c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80266f:	77 07                	ja     802678 <devpipe_read+0x66>
  802671:	eb 12                	jmp    802685 <devpipe_read+0x73>
  802673:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802678:	8b 03                	mov    (%ebx),%eax
  80267a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80267d:	75 d4                	jne    802653 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80267f:	85 f6                	test   %esi,%esi
  802681:	75 b3                	jne    802636 <devpipe_read+0x24>
  802683:	eb b5                	jmp    80263a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802685:	89 f0                	mov    %esi,%eax
  802687:	eb 05                	jmp    80268e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802689:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80268e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802691:	5b                   	pop    %ebx
  802692:	5e                   	pop    %esi
  802693:	5f                   	pop    %edi
  802694:	c9                   	leave  
  802695:	c3                   	ret    

00802696 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	57                   	push   %edi
  80269a:	56                   	push   %esi
  80269b:	53                   	push   %ebx
  80269c:	83 ec 28             	sub    $0x28,%esp
  80269f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8026a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8026a5:	50                   	push   %eax
  8026a6:	e8 11 ee ff ff       	call   8014bc <fd_alloc>
  8026ab:	89 c3                	mov    %eax,%ebx
  8026ad:	83 c4 10             	add    $0x10,%esp
  8026b0:	85 c0                	test   %eax,%eax
  8026b2:	0f 88 24 01 00 00    	js     8027dc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b8:	83 ec 04             	sub    $0x4,%esp
  8026bb:	68 07 04 00 00       	push   $0x407
  8026c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8026c3:	6a 00                	push   $0x0
  8026c5:	e8 46 e9 ff ff       	call   801010 <sys_page_alloc>
  8026ca:	89 c3                	mov    %eax,%ebx
  8026cc:	83 c4 10             	add    $0x10,%esp
  8026cf:	85 c0                	test   %eax,%eax
  8026d1:	0f 88 05 01 00 00    	js     8027dc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8026d7:	83 ec 0c             	sub    $0xc,%esp
  8026da:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8026dd:	50                   	push   %eax
  8026de:	e8 d9 ed ff ff       	call   8014bc <fd_alloc>
  8026e3:	89 c3                	mov    %eax,%ebx
  8026e5:	83 c4 10             	add    $0x10,%esp
  8026e8:	85 c0                	test   %eax,%eax
  8026ea:	0f 88 dc 00 00 00    	js     8027cc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026f0:	83 ec 04             	sub    $0x4,%esp
  8026f3:	68 07 04 00 00       	push   $0x407
  8026f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8026fb:	6a 00                	push   $0x0
  8026fd:	e8 0e e9 ff ff       	call   801010 <sys_page_alloc>
  802702:	89 c3                	mov    %eax,%ebx
  802704:	83 c4 10             	add    $0x10,%esp
  802707:	85 c0                	test   %eax,%eax
  802709:	0f 88 bd 00 00 00    	js     8027cc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80270f:	83 ec 0c             	sub    $0xc,%esp
  802712:	ff 75 e4             	pushl  -0x1c(%ebp)
  802715:	e8 8a ed ff ff       	call   8014a4 <fd2data>
  80271a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80271c:	83 c4 0c             	add    $0xc,%esp
  80271f:	68 07 04 00 00       	push   $0x407
  802724:	50                   	push   %eax
  802725:	6a 00                	push   $0x0
  802727:	e8 e4 e8 ff ff       	call   801010 <sys_page_alloc>
  80272c:	89 c3                	mov    %eax,%ebx
  80272e:	83 c4 10             	add    $0x10,%esp
  802731:	85 c0                	test   %eax,%eax
  802733:	0f 88 83 00 00 00    	js     8027bc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802739:	83 ec 0c             	sub    $0xc,%esp
  80273c:	ff 75 e0             	pushl  -0x20(%ebp)
  80273f:	e8 60 ed ff ff       	call   8014a4 <fd2data>
  802744:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80274b:	50                   	push   %eax
  80274c:	6a 00                	push   $0x0
  80274e:	56                   	push   %esi
  80274f:	6a 00                	push   $0x0
  802751:	e8 de e8 ff ff       	call   801034 <sys_page_map>
  802756:	89 c3                	mov    %eax,%ebx
  802758:	83 c4 20             	add    $0x20,%esp
  80275b:	85 c0                	test   %eax,%eax
  80275d:	78 4f                	js     8027ae <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80275f:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802768:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80276a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80276d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802774:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80277a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80277d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80277f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802782:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802789:	83 ec 0c             	sub    $0xc,%esp
  80278c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80278f:	e8 00 ed ff ff       	call   801494 <fd2num>
  802794:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802796:	83 c4 04             	add    $0x4,%esp
  802799:	ff 75 e0             	pushl  -0x20(%ebp)
  80279c:	e8 f3 ec ff ff       	call   801494 <fd2num>
  8027a1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8027a4:	83 c4 10             	add    $0x10,%esp
  8027a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ac:	eb 2e                	jmp    8027dc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8027ae:	83 ec 08             	sub    $0x8,%esp
  8027b1:	56                   	push   %esi
  8027b2:	6a 00                	push   $0x0
  8027b4:	e8 a1 e8 ff ff       	call   80105a <sys_page_unmap>
  8027b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8027bc:	83 ec 08             	sub    $0x8,%esp
  8027bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8027c2:	6a 00                	push   $0x0
  8027c4:	e8 91 e8 ff ff       	call   80105a <sys_page_unmap>
  8027c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8027cc:	83 ec 08             	sub    $0x8,%esp
  8027cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8027d2:	6a 00                	push   $0x0
  8027d4:	e8 81 e8 ff ff       	call   80105a <sys_page_unmap>
  8027d9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8027dc:	89 d8                	mov    %ebx,%eax
  8027de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027e1:	5b                   	pop    %ebx
  8027e2:	5e                   	pop    %esi
  8027e3:	5f                   	pop    %edi
  8027e4:	c9                   	leave  
  8027e5:	c3                   	ret    

008027e6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8027e6:	55                   	push   %ebp
  8027e7:	89 e5                	mov    %esp,%ebp
  8027e9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ef:	50                   	push   %eax
  8027f0:	ff 75 08             	pushl  0x8(%ebp)
  8027f3:	e8 37 ed ff ff       	call   80152f <fd_lookup>
  8027f8:	83 c4 10             	add    $0x10,%esp
  8027fb:	85 c0                	test   %eax,%eax
  8027fd:	78 18                	js     802817 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8027ff:	83 ec 0c             	sub    $0xc,%esp
  802802:	ff 75 f4             	pushl  -0xc(%ebp)
  802805:	e8 9a ec ff ff       	call   8014a4 <fd2data>
	return _pipeisclosed(fd, p);
  80280a:	89 c2                	mov    %eax,%edx
  80280c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80280f:	e8 0c fd ff ff       	call   802520 <_pipeisclosed>
  802814:	83 c4 10             	add    $0x10,%esp
}
  802817:	c9                   	leave  
  802818:	c3                   	ret    
  802819:	00 00                	add    %al,(%eax)
	...

0080281c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80281c:	55                   	push   %ebp
  80281d:	89 e5                	mov    %esp,%ebp
  80281f:	57                   	push   %edi
  802820:	56                   	push   %esi
  802821:	53                   	push   %ebx
  802822:	83 ec 0c             	sub    $0xc,%esp
  802825:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802828:	85 c0                	test   %eax,%eax
  80282a:	75 16                	jne    802842 <wait+0x26>
  80282c:	68 c1 34 80 00       	push   $0x8034c1
  802831:	68 c3 33 80 00       	push   $0x8033c3
  802836:	6a 09                	push   $0x9
  802838:	68 cc 34 80 00       	push   $0x8034cc
  80283d:	e8 be dc ff ff       	call   800500 <_panic>
	e = &envs[ENVX(envid)];
  802842:	89 c6                	mov    %eax,%esi
  802844:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80284a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802851:	89 f2                	mov    %esi,%edx
  802853:	c1 e2 07             	shl    $0x7,%edx
  802856:	29 ca                	sub    %ecx,%edx
  802858:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  80285e:	8b 7a 40             	mov    0x40(%edx),%edi
  802861:	39 c7                	cmp    %eax,%edi
  802863:	75 37                	jne    80289c <wait+0x80>
  802865:	89 f0                	mov    %esi,%eax
  802867:	c1 e0 07             	shl    $0x7,%eax
  80286a:	29 c8                	sub    %ecx,%eax
  80286c:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802871:	8b 40 50             	mov    0x50(%eax),%eax
  802874:	85 c0                	test   %eax,%eax
  802876:	74 24                	je     80289c <wait+0x80>
  802878:	c1 e6 07             	shl    $0x7,%esi
  80287b:	29 ce                	sub    %ecx,%esi
  80287d:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  802883:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802889:	e8 5b e7 ff ff       	call   800fe9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80288e:	8b 43 40             	mov    0x40(%ebx),%eax
  802891:	39 f8                	cmp    %edi,%eax
  802893:	75 07                	jne    80289c <wait+0x80>
  802895:	8b 46 50             	mov    0x50(%esi),%eax
  802898:	85 c0                	test   %eax,%eax
  80289a:	75 ed                	jne    802889 <wait+0x6d>
		sys_yield();
}
  80289c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	c9                   	leave  
  8028a3:	c3                   	ret    

008028a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028a4:	55                   	push   %ebp
  8028a5:	89 e5                	mov    %esp,%ebp
  8028a7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028aa:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8028b1:	75 52                	jne    802905 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8028b3:	83 ec 04             	sub    $0x4,%esp
  8028b6:	6a 07                	push   $0x7
  8028b8:	68 00 f0 bf ee       	push   $0xeebff000
  8028bd:	6a 00                	push   $0x0
  8028bf:	e8 4c e7 ff ff       	call   801010 <sys_page_alloc>
		if (r < 0) {
  8028c4:	83 c4 10             	add    $0x10,%esp
  8028c7:	85 c0                	test   %eax,%eax
  8028c9:	79 12                	jns    8028dd <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8028cb:	50                   	push   %eax
  8028cc:	68 d7 34 80 00       	push   $0x8034d7
  8028d1:	6a 24                	push   $0x24
  8028d3:	68 f2 34 80 00       	push   $0x8034f2
  8028d8:	e8 23 dc ff ff       	call   800500 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  8028dd:	83 ec 08             	sub    $0x8,%esp
  8028e0:	68 10 29 80 00       	push   $0x802910
  8028e5:	6a 00                	push   $0x0
  8028e7:	e8 d7 e7 ff ff       	call   8010c3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8028ec:	83 c4 10             	add    $0x10,%esp
  8028ef:	85 c0                	test   %eax,%eax
  8028f1:	79 12                	jns    802905 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8028f3:	50                   	push   %eax
  8028f4:	68 00 35 80 00       	push   $0x803500
  8028f9:	6a 2a                	push   $0x2a
  8028fb:	68 f2 34 80 00       	push   $0x8034f2
  802900:	e8 fb db ff ff       	call   800500 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802905:	8b 45 08             	mov    0x8(%ebp),%eax
  802908:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80290d:	c9                   	leave  
  80290e:	c3                   	ret    
	...

00802910 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802910:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802911:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802916:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802918:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80291b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80291f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802922:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802926:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80292a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80292c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80292f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  802930:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  802933:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802934:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802935:	c3                   	ret    
	...

00802938 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802938:	55                   	push   %ebp
  802939:	89 e5                	mov    %esp,%ebp
  80293b:	56                   	push   %esi
  80293c:	53                   	push   %ebx
  80293d:	8b 75 08             	mov    0x8(%ebp),%esi
  802940:	8b 45 0c             	mov    0xc(%ebp),%eax
  802943:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802946:	85 c0                	test   %eax,%eax
  802948:	74 0e                	je     802958 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80294a:	83 ec 0c             	sub    $0xc,%esp
  80294d:	50                   	push   %eax
  80294e:	e8 b8 e7 ff ff       	call   80110b <sys_ipc_recv>
  802953:	83 c4 10             	add    $0x10,%esp
  802956:	eb 10                	jmp    802968 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802958:	83 ec 0c             	sub    $0xc,%esp
  80295b:	68 00 00 c0 ee       	push   $0xeec00000
  802960:	e8 a6 e7 ff ff       	call   80110b <sys_ipc_recv>
  802965:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802968:	85 c0                	test   %eax,%eax
  80296a:	75 26                	jne    802992 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80296c:	85 f6                	test   %esi,%esi
  80296e:	74 0a                	je     80297a <ipc_recv+0x42>
  802970:	a1 04 50 80 00       	mov    0x805004,%eax
  802975:	8b 40 74             	mov    0x74(%eax),%eax
  802978:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80297a:	85 db                	test   %ebx,%ebx
  80297c:	74 0a                	je     802988 <ipc_recv+0x50>
  80297e:	a1 04 50 80 00       	mov    0x805004,%eax
  802983:	8b 40 78             	mov    0x78(%eax),%eax
  802986:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802988:	a1 04 50 80 00       	mov    0x805004,%eax
  80298d:	8b 40 70             	mov    0x70(%eax),%eax
  802990:	eb 14                	jmp    8029a6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802992:	85 f6                	test   %esi,%esi
  802994:	74 06                	je     80299c <ipc_recv+0x64>
  802996:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80299c:	85 db                	test   %ebx,%ebx
  80299e:	74 06                	je     8029a6 <ipc_recv+0x6e>
  8029a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8029a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029a9:	5b                   	pop    %ebx
  8029aa:	5e                   	pop    %esi
  8029ab:	c9                   	leave  
  8029ac:	c3                   	ret    

008029ad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029ad:	55                   	push   %ebp
  8029ae:	89 e5                	mov    %esp,%ebp
  8029b0:	57                   	push   %edi
  8029b1:	56                   	push   %esi
  8029b2:	53                   	push   %ebx
  8029b3:	83 ec 0c             	sub    $0xc,%esp
  8029b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8029b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8029bc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8029bf:	85 db                	test   %ebx,%ebx
  8029c1:	75 25                	jne    8029e8 <ipc_send+0x3b>
  8029c3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8029c8:	eb 1e                	jmp    8029e8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8029ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029cd:	75 07                	jne    8029d6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8029cf:	e8 15 e6 ff ff       	call   800fe9 <sys_yield>
  8029d4:	eb 12                	jmp    8029e8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8029d6:	50                   	push   %eax
  8029d7:	68 28 35 80 00       	push   $0x803528
  8029dc:	6a 43                	push   $0x43
  8029de:	68 3b 35 80 00       	push   $0x80353b
  8029e3:	e8 18 db ff ff       	call   800500 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8029e8:	56                   	push   %esi
  8029e9:	53                   	push   %ebx
  8029ea:	57                   	push   %edi
  8029eb:	ff 75 08             	pushl  0x8(%ebp)
  8029ee:	e8 f3 e6 ff ff       	call   8010e6 <sys_ipc_try_send>
  8029f3:	83 c4 10             	add    $0x10,%esp
  8029f6:	85 c0                	test   %eax,%eax
  8029f8:	75 d0                	jne    8029ca <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8029fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029fd:	5b                   	pop    %ebx
  8029fe:	5e                   	pop    %esi
  8029ff:	5f                   	pop    %edi
  802a00:	c9                   	leave  
  802a01:	c3                   	ret    

00802a02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a02:	55                   	push   %ebp
  802a03:	89 e5                	mov    %esp,%ebp
  802a05:	53                   	push   %ebx
  802a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802a09:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802a0f:	74 22                	je     802a33 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a11:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802a16:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802a1d:	89 c2                	mov    %eax,%edx
  802a1f:	c1 e2 07             	shl    $0x7,%edx
  802a22:	29 ca                	sub    %ecx,%edx
  802a24:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a2a:	8b 52 50             	mov    0x50(%edx),%edx
  802a2d:	39 da                	cmp    %ebx,%edx
  802a2f:	75 1d                	jne    802a4e <ipc_find_env+0x4c>
  802a31:	eb 05                	jmp    802a38 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a33:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802a38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802a3f:	c1 e0 07             	shl    $0x7,%eax
  802a42:	29 d0                	sub    %edx,%eax
  802a44:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802a49:	8b 40 40             	mov    0x40(%eax),%eax
  802a4c:	eb 0c                	jmp    802a5a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a4e:	40                   	inc    %eax
  802a4f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a54:	75 c0                	jne    802a16 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a56:	66 b8 00 00          	mov    $0x0,%ax
}
  802a5a:	5b                   	pop    %ebx
  802a5b:	c9                   	leave  
  802a5c:	c3                   	ret    
  802a5d:	00 00                	add    %al,(%eax)
	...

00802a60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a60:	55                   	push   %ebp
  802a61:	89 e5                	mov    %esp,%ebp
  802a63:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a66:	89 c2                	mov    %eax,%edx
  802a68:	c1 ea 16             	shr    $0x16,%edx
  802a6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a72:	f6 c2 01             	test   $0x1,%dl
  802a75:	74 1e                	je     802a95 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a77:	c1 e8 0c             	shr    $0xc,%eax
  802a7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a81:	a8 01                	test   $0x1,%al
  802a83:	74 17                	je     802a9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a85:	c1 e8 0c             	shr    $0xc,%eax
  802a88:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802a8f:	ef 
  802a90:	0f b7 c0             	movzwl %ax,%eax
  802a93:	eb 0c                	jmp    802aa1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802a95:	b8 00 00 00 00       	mov    $0x0,%eax
  802a9a:	eb 05                	jmp    802aa1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802a9c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802aa1:	c9                   	leave  
  802aa2:	c3                   	ret    
	...

00802aa4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802aa4:	55                   	push   %ebp
  802aa5:	89 e5                	mov    %esp,%ebp
  802aa7:	57                   	push   %edi
  802aa8:	56                   	push   %esi
  802aa9:	83 ec 10             	sub    $0x10,%esp
  802aac:	8b 7d 08             	mov    0x8(%ebp),%edi
  802aaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ab2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802ab8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802abb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802abe:	85 c0                	test   %eax,%eax
  802ac0:	75 2e                	jne    802af0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802ac2:	39 f1                	cmp    %esi,%ecx
  802ac4:	77 5a                	ja     802b20 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ac6:	85 c9                	test   %ecx,%ecx
  802ac8:	75 0b                	jne    802ad5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802aca:	b8 01 00 00 00       	mov    $0x1,%eax
  802acf:	31 d2                	xor    %edx,%edx
  802ad1:	f7 f1                	div    %ecx
  802ad3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802ad5:	31 d2                	xor    %edx,%edx
  802ad7:	89 f0                	mov    %esi,%eax
  802ad9:	f7 f1                	div    %ecx
  802adb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802add:	89 f8                	mov    %edi,%eax
  802adf:	f7 f1                	div    %ecx
  802ae1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802ae3:	89 f8                	mov    %edi,%eax
  802ae5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802ae7:	83 c4 10             	add    $0x10,%esp
  802aea:	5e                   	pop    %esi
  802aeb:	5f                   	pop    %edi
  802aec:	c9                   	leave  
  802aed:	c3                   	ret    
  802aee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802af0:	39 f0                	cmp    %esi,%eax
  802af2:	77 1c                	ja     802b10 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802af4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802af7:	83 f7 1f             	xor    $0x1f,%edi
  802afa:	75 3c                	jne    802b38 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802afc:	39 f0                	cmp    %esi,%eax
  802afe:	0f 82 90 00 00 00    	jb     802b94 <__udivdi3+0xf0>
  802b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b07:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802b0a:	0f 86 84 00 00 00    	jbe    802b94 <__udivdi3+0xf0>
  802b10:	31 f6                	xor    %esi,%esi
  802b12:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b14:	89 f8                	mov    %edi,%eax
  802b16:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b18:	83 c4 10             	add    $0x10,%esp
  802b1b:	5e                   	pop    %esi
  802b1c:	5f                   	pop    %edi
  802b1d:	c9                   	leave  
  802b1e:	c3                   	ret    
  802b1f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b20:	89 f2                	mov    %esi,%edx
  802b22:	89 f8                	mov    %edi,%eax
  802b24:	f7 f1                	div    %ecx
  802b26:	89 c7                	mov    %eax,%edi
  802b28:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b2a:	89 f8                	mov    %edi,%eax
  802b2c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b2e:	83 c4 10             	add    $0x10,%esp
  802b31:	5e                   	pop    %esi
  802b32:	5f                   	pop    %edi
  802b33:	c9                   	leave  
  802b34:	c3                   	ret    
  802b35:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b38:	89 f9                	mov    %edi,%ecx
  802b3a:	d3 e0                	shl    %cl,%eax
  802b3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b3f:	b8 20 00 00 00       	mov    $0x20,%eax
  802b44:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b49:	88 c1                	mov    %al,%cl
  802b4b:	d3 ea                	shr    %cl,%edx
  802b4d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802b50:	09 ca                	or     %ecx,%edx
  802b52:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b58:	89 f9                	mov    %edi,%ecx
  802b5a:	d3 e2                	shl    %cl,%edx
  802b5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802b5f:	89 f2                	mov    %esi,%edx
  802b61:	88 c1                	mov    %al,%cl
  802b63:	d3 ea                	shr    %cl,%edx
  802b65:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802b68:	89 f2                	mov    %esi,%edx
  802b6a:	89 f9                	mov    %edi,%ecx
  802b6c:	d3 e2                	shl    %cl,%edx
  802b6e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802b71:	88 c1                	mov    %al,%cl
  802b73:	d3 ee                	shr    %cl,%esi
  802b75:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b77:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802b7a:	89 f0                	mov    %esi,%eax
  802b7c:	89 ca                	mov    %ecx,%edx
  802b7e:	f7 75 ec             	divl   -0x14(%ebp)
  802b81:	89 d1                	mov    %edx,%ecx
  802b83:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b85:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b88:	39 d1                	cmp    %edx,%ecx
  802b8a:	72 28                	jb     802bb4 <__udivdi3+0x110>
  802b8c:	74 1a                	je     802ba8 <__udivdi3+0x104>
  802b8e:	89 f7                	mov    %esi,%edi
  802b90:	31 f6                	xor    %esi,%esi
  802b92:	eb 80                	jmp    802b14 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b94:	31 f6                	xor    %esi,%esi
  802b96:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802b9b:	89 f8                	mov    %edi,%eax
  802b9d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802b9f:	83 c4 10             	add    $0x10,%esp
  802ba2:	5e                   	pop    %esi
  802ba3:	5f                   	pop    %edi
  802ba4:	c9                   	leave  
  802ba5:	c3                   	ret    
  802ba6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bab:	89 f9                	mov    %edi,%ecx
  802bad:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802baf:	39 c2                	cmp    %eax,%edx
  802bb1:	73 db                	jae    802b8e <__udivdi3+0xea>
  802bb3:	90                   	nop
		{
		  q0--;
  802bb4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bb7:	31 f6                	xor    %esi,%esi
  802bb9:	e9 56 ff ff ff       	jmp    802b14 <__udivdi3+0x70>
	...

00802bc0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802bc0:	55                   	push   %ebp
  802bc1:	89 e5                	mov    %esp,%ebp
  802bc3:	57                   	push   %edi
  802bc4:	56                   	push   %esi
  802bc5:	83 ec 20             	sub    $0x20,%esp
  802bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  802bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802bce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802bd4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802bd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802bdd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802bdf:	85 ff                	test   %edi,%edi
  802be1:	75 15                	jne    802bf8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802be3:	39 f1                	cmp    %esi,%ecx
  802be5:	0f 86 99 00 00 00    	jbe    802c84 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802beb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802bed:	89 d0                	mov    %edx,%eax
  802bef:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bf1:	83 c4 20             	add    $0x20,%esp
  802bf4:	5e                   	pop    %esi
  802bf5:	5f                   	pop    %edi
  802bf6:	c9                   	leave  
  802bf7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802bf8:	39 f7                	cmp    %esi,%edi
  802bfa:	0f 87 a4 00 00 00    	ja     802ca4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802c00:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802c03:	83 f0 1f             	xor    $0x1f,%eax
  802c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802c09:	0f 84 a1 00 00 00    	je     802cb0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802c0f:	89 f8                	mov    %edi,%eax
  802c11:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c14:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802c16:	bf 20 00 00 00       	mov    $0x20,%edi
  802c1b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c21:	89 f9                	mov    %edi,%ecx
  802c23:	d3 ea                	shr    %cl,%edx
  802c25:	09 c2                	or     %eax,%edx
  802c27:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c30:	d3 e0                	shl    %cl,%eax
  802c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c35:	89 f2                	mov    %esi,%edx
  802c37:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802c39:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802c3c:	d3 e0                	shl    %cl,%eax
  802c3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802c41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802c44:	89 f9                	mov    %edi,%ecx
  802c46:	d3 e8                	shr    %cl,%eax
  802c48:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802c4a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802c4c:	89 f2                	mov    %esi,%edx
  802c4e:	f7 75 f0             	divl   -0x10(%ebp)
  802c51:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802c53:	f7 65 f4             	mull   -0xc(%ebp)
  802c56:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802c59:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c5b:	39 d6                	cmp    %edx,%esi
  802c5d:	72 71                	jb     802cd0 <__umoddi3+0x110>
  802c5f:	74 7f                	je     802ce0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c64:	29 c8                	sub    %ecx,%eax
  802c66:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802c68:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c6b:	d3 e8                	shr    %cl,%eax
  802c6d:	89 f2                	mov    %esi,%edx
  802c6f:	89 f9                	mov    %edi,%ecx
  802c71:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802c73:	09 d0                	or     %edx,%eax
  802c75:	89 f2                	mov    %esi,%edx
  802c77:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802c7a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c7c:	83 c4 20             	add    $0x20,%esp
  802c7f:	5e                   	pop    %esi
  802c80:	5f                   	pop    %edi
  802c81:	c9                   	leave  
  802c82:	c3                   	ret    
  802c83:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802c84:	85 c9                	test   %ecx,%ecx
  802c86:	75 0b                	jne    802c93 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802c88:	b8 01 00 00 00       	mov    $0x1,%eax
  802c8d:	31 d2                	xor    %edx,%edx
  802c8f:	f7 f1                	div    %ecx
  802c91:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802c93:	89 f0                	mov    %esi,%eax
  802c95:	31 d2                	xor    %edx,%edx
  802c97:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c9c:	f7 f1                	div    %ecx
  802c9e:	e9 4a ff ff ff       	jmp    802bed <__umoddi3+0x2d>
  802ca3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802ca4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ca6:	83 c4 20             	add    $0x20,%esp
  802ca9:	5e                   	pop    %esi
  802caa:	5f                   	pop    %edi
  802cab:	c9                   	leave  
  802cac:	c3                   	ret    
  802cad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802cb0:	39 f7                	cmp    %esi,%edi
  802cb2:	72 05                	jb     802cb9 <__umoddi3+0xf9>
  802cb4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802cb7:	77 0c                	ja     802cc5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802cb9:	89 f2                	mov    %esi,%edx
  802cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cbe:	29 c8                	sub    %ecx,%eax
  802cc0:	19 fa                	sbb    %edi,%edx
  802cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802cc8:	83 c4 20             	add    $0x20,%esp
  802ccb:	5e                   	pop    %esi
  802ccc:	5f                   	pop    %edi
  802ccd:	c9                   	leave  
  802cce:	c3                   	ret    
  802ccf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802cd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802cd3:	89 c1                	mov    %eax,%ecx
  802cd5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802cd8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802cdb:	eb 84                	jmp    802c61 <__umoddi3+0xa1>
  802cdd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ce0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802ce3:	72 eb                	jb     802cd0 <__umoddi3+0x110>
  802ce5:	89 f2                	mov    %esi,%edx
  802ce7:	e9 75 ff ff ff       	jmp    802c61 <__umoddi3+0xa1>
